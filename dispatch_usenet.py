#!/opt/bin/env /opt/bin/python2.6

#type        : post processing result, either 'SUCCESS' or 'ERROR'
#archiveName : name of the archive, e.g. 'Usenet_Post5'
#destDir     : where the archive ended up, e.g. '/ext2/usenet/Usenet_Post5'
#elapsedTime : a pretty string showing how long post processing took, e.g.
#             '10m 37s'
#parMessage  : optional post processing message. e.g. '(No Pars)'

import os, sys
import re
import logging
import shutil
import smtplib
from email.mime.text import MIMEText

# Retrieve video from folder
def getVideos(folder):
    files = os.listdir(folder)
    videoList = list()
    videoRegex=".*(mp4)|(avi)$"
    # iterate over files
    for f in files:
        # Does filename matches video regex 
        result = re.search(videoRegex,f, re.I)
        if result != None:
            # Append the file to the videoList to be returned
            videoList.append(folder + "/" + f)
            logger.debug("Candidate : " + f)
    return videoList

##
# @brief Get the path where the video should be copied to
# It retrieve the destination from regexes given as first argument which is a dictionnary 
# for which the key is the destination folder and the value is the regex.
# The regex is used to match against the hellanzb destination folder
#
# @param usenetDestDir Path where hellanzb put the downloaded stuff
# @param videoRegexes Dictionnary of regexes, one entry per season of a serie
#
# @return Directory where the video downloaded should go
def getDestination(usenetDestDir, videoRegexes):
    # loop through regexes to find a match for the download
    for (videoDestDir, videoRegex) in videoRegexes.iteritems():
        logger.debug(videoDestDir + "-" + videoRegex)
        # Does regex matches to usenetDestDir?
        result = re.search(videoRegex,usenetDestDir,re.I)
        if result != None:
            logger.debug("Matching for " + videoDestDir)
            logger.debug("result.string : " + result.string)
            logger.debug("result.re : " + str(result.re))
            logger.debug("result.group : " + result.group())
            # do not go further through regexes after a match has been found
            return videoDestDir
    return ""


##
# @brief Move the videos to the target folder
#
# @param videoList List of videos to be moved
# @param videoDestDir Destination folder for the videos
#
# @return List of videos successfully copied to destination folder
def moveVideosToDestination(videoList, videoDestDir):
    res = list()
    # Test if destination exists, create it if necessary
    if not(os.path.isdir(videoDestDir)):
        logger.info("Create dir " + videoDestDir)
        os.mkdir(videoDestDir, 0755)
    for f in videoList:
        video = os.path.basename(f)
        if os.path.exists(videoDestDir + "/" + video):
            logger.error(video + " already exists in " + videoDestDir + ". Copy not done")
        else:
            shutil.move(f,videoDestDir)
            log = "mv \"" + f + "\" " + videoDestDir
            logger.info(log)
            res.append(videoDestDir + "/" + f)
    return res

# Send mail, subject is prefixed with "[Hella Nzb] "
def sendMail(subject, content):
    dest = "nico.vince@gmail.com"
    sender = "nico.vince@gmail.com"
    # setup mail
    msg = MIMEText(content)
    msg['From'] = sender
    msg['To'] = dest
    msg['Subject'] = "[HellaNzb] " + subject
    # setup smtp
    s = smtplib.SMTP('smtp.free.fr')
    s.sendmail(sender, [dest], msg.as_string())
    s.quit()

# set the mail's body depending on what was found and downloaded
def setMailBody(videos, videosMoved, destDir, videoDestDir):
    body = ""
    if (len(videoDestDir) == 0):
        body += "Destination folder could not be determined.\n"
        if (len(videos) > 0):
            body += "The following videos were found :\n"
            for v in videos:
                body += " * " + v + "\n"
    # No videos found
    elif (len(videos) == 0):
        body += "No videos were found in " + destDir + " :\n"
        for f in os.listdir(destDir):
            body += f + "\n"
    # No videos moved
    elif (len(videosMoved) == 0):
        body += "The following videos : \n"
        for v in videos:
            body += " * " + os.path.basename(v) + "\n"
        body += "could not be moved to destination folder :\n"
        body += destDir + "\n"
    # Videos moved
    elif (len(videosMoved) > 0):
        body += "The following videos :\n"
        for v in videosMoved:
            body += " * " + os.path.basename(v) + "\n"
        body += "have been moved to destination folder :\n"
        body += videoDestDir + "\n"
        # Display videos not moved if any
        if (len(videosMoved) != len(videos)):
            body += "The following videos : \n"
            for v in videos:
                if v not in videosMoved:
                    body += " * " + os.path.basename(v) + "\n"
            body += "could not be moved to destination folder"

    return body




## Start of script ##

# Setup logging capability
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-10s %(levelname)-8s %(message)s',
                    datefmt='%Y/%m/%d %H:%M:%S',
                    filename='/home/admin/dispatchHellanzb.log',
                    filemode='a')
# Log to console as well
console = logging.StreamHandler()
console.setLevel(logging.DEBUG)
consoleFormatter = logging.Formatter('%(name)s: %(levelname)s %(message)s')
console.setFormatter(consoleFormatter)
logging.getLogger('').addHandler(console)
logger = logging.getLogger('dispatch')

logger.info("### Start of post processing script")

# Check args count
logger.debug("Args :")
if len(sys.argv) != 6:
    logger.error( "Wrong number or arguments. Got " + str(len(sys.argv)))
    for arg in sys.argv:
        logger.error(arg)
    sys.exit(1)

# Retrieve args in meaningfull variables
args = dict()
args['type']        = sys.argv[1]
args['archiveName'] = sys.argv[2]
args['destDir']     = sys.argv[3]
args['elapsedTime'] = sys.argv[4]
args['parMessage']  = sys.argv[5]

# Display args
logger.debug("type        : " + args['type'])
logger.debug("archiveName : " + args['archiveName'])
logger.debug("destDir     : " + args['destDir'])
logger.debug("elapsedTime : " + args['elapsedTime'])
logger.debug("parMessage  : " + args['parMessage'])


# Setup regexes and path for each kind of download
videosPath='/mnt/disk1/share/videos/'

regexes=dict([(videosPath + 'Walking_Dead_S3', '.*walking.*dead.*s[0-9]?3.*')
              ,(videosPath + 'Boardwalk.Empire_S03', '.*boardwalk.*empire.*s[0-9]?3.*')
              ,(videosPath + 'How_I_Met_Your_Mother_S8', '.*how.*i.*met.*your.*mother.*s[0-9]?8.*')
              ,(videosPath + 'The_Big_Bang_Theory_S6', '.*the.*big.*bang.*theory.*s[0-9]?6.*')
              ,(videosPath + 'Dexter_S7', '.*dexter.*s[0-9]?7.*')
              ,(videosPath + 'Homeland_S2', '.*homeland.*s[0-9]?2.*')
              ,('/home/admin/dev/testing/dummy', '.*dummy.*')
              ])

# Retrieve where the downloaded thing should go
videoDestDir = getDestination(args['destDir'], regexes)
if (len(videoDestDir) == 0):
    logger.error("Could not determine destination for download : " + args['destDir'])
# Get the videos out of the downloaded stuff
videos = getVideos(args['destDir'])
if (len(videos) == 0):
    logger.warning("No video were found in " + videoDestDir)

# Move if we got anything and a destination
videosMoved = list()
if (len(videos) > 0) and (len(videoDestDir) > 0):
    videosMoved = moveVideosToDestination(videos, videoDestDir)


# Send status mail
mailBody = setMailBody(videos, videosMoved, args['destDir'], videoDestDir)
sendMail(args['archiveName'],mailBody)
