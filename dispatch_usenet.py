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
from optparse import OptionParser
from optparse import OptionGroup


##
# @brief Recursiverly create directory path
#
# @param dir Path of the directory to create
def createDir(dir):
    parent = os.path.dirname(dir)
    if not(os.path.isdir(parent)):
           createDir(parent)
    else:
           os.mkdir(dir,0755)

# Retrieve video from folder
def getVideos(folder):
    if not os.path.exists(folder):
        logger.error("folder " + folder + " does not exists")
        sys.exit(1)
    files = os.listdir(folder)
    videoList = list()
    videoRegex=".*(mp4)|(avi)|(mkv)$"
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
        # Does regex matches to usenetDestDir?
        result = re.search(videoRegex,usenetDestDir,re.I)
        if result != None:
            logger.debug("Matching for " + videoDestDir)
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
def moveVideosToDestination(videoList, videoDestDir, dryRun):
    res = list()
    # Test if destination exists, create it if necessary
    if not(os.path.isdir(videoDestDir)):
        if not(dryRun):
            createDir(videoDestDir)
            logger.info("Create dir " + videoDestDir)
        else:
            logger.info("dryRun is set, " + videoDestDir +
                        " would be created")
    for f in videoList:
        video = os.path.basename(f)
        if os.path.exists(videoDestDir + "/" + video):
            logger.error(video + " already exists in " + videoDestDir + ". Copy not done")
        else:
            if not(dryRun):
                shutil.move(f,videoDestDir)
                log = "mv \"" + f + "\" " + videoDestDir
            else:
                log = "dryRun is set, would mv " + f + " " + videoDestDir
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




def main():
    # default log file
    logFile=os.getenv('HOME') + '/dispatchHellanzb.log'
    # default video folder
    defaultVideosPath='/mnt/disk1/share/videos/'
    # default verbosity : do not print on stdout
    verbose=False

    parser = OptionParser("%prog [options]")
    parser.add_option("-l", "--logFile", dest='logFile', default=logFile,
                      help="log file (default : %default)")
    parser.add_option("-d", "--videosFolder",
                      dest='videosPath', default=defaultVideosPath,
                      help="Video folder where the downloaded videos will be moved to. (default : %default)")
    parser.add_option("-n", "--dry-run",
                      dest="dryRun", action="store_true", default=False,
                      help="Do not move anything, do no send mail, just pretend it happened")
    parser.add_option("--send-mail", dest="forceSendMail", action="store_true",
                      default=False, help="Send mail, even if --dry-run options has been set")
    parser.add_option("--no-mail", dest="sendMail", action="store_false",
                      default=True, help="Do not send status mail (default : %default)")
    parser.add_option("-v", "--verbose",
                      dest="verbose", action="store_true", default=verbose,
                      help="Will display log message to console in addition to store them in logFile")

    # those options are passed to post processing script by hellanzb as positional args
    ppOptions = OptionGroup (parser, "Positionnal options of Hellanzb's post-processing script",
                                  "Those options are passed from post-processing script of Hellanzb to this script")
    ppOptions.add_option("--type", dest="processingResult",
                         help="Arg 1 passed by post process script."
                         "Post processing result, either 'SUCCESS' or 'ERROR'")
    ppOptions.add_option("--archiveName", dest="archiveName", default="UNSET",
                         help="Arg 2 passed by post process script."
                         "Name of the archive, e.g. 'Usenet_Post5'")
    ppOptions.add_option("--destDir", dest="destDir", default="UNSET",
                         help="Arg 3 passed by post process script."
                         "Where the archive ended up, e.g. '/mnt/disk1/share/hellanzb/usenet'")
    ppOptions.add_option("--elapsedTime", dest="elapsedTime",
                         help="Arg 4 passed by post process script."
                         "A pretty string showing how long post processing took, e.g. '10m 37s'")
    ppOptions.add_option("--parMessage", dest="parMessage",
                         help="Arg 5 passed by post process script."
                         "optional post processing message. e.g. '(No Pars)'")
    parser.add_option_group(ppOptions)


    (options, args) = parser.parse_args()
    # Setup logging capability
    logger = logging.getLogger('dispatch')
    logger.setLevel(logging.DEBUG)
    fileHandler = logging.FileHandler(filename=logFile,
                                      mode='a')
    fileHandler.setLevel(logging.INFO)
    fileFormatter = logging.Formatter(fmt='%(asctime)s %(name)-10s %(levelname)-8s %(message)s',
                                      datefmt='%Y/%m/%d %H:%M:%S')
    fileHandler.setFormatter(fileFormatter)
    logger.addHandler(fileHandler)
    # Log to console as well
    console = logging.StreamHandler()
    console.setLevel(logging.DEBUG)
    consoleFormatter = logging.Formatter('%(name)s: %(levelname)s %(message)s')
    console.setFormatter(consoleFormatter)
    if options.verbose:
        logger.addHandler(console)

    logger.info("### Start of post processing script")

    if options.dryRun and not(options.forceSendMail):
        options.sendMail = False

    # Check destDir and archiveName options has been set
    if (options.destDir == "UNSET") or (options.archiveName == "UNSET"):
        if options.destDir == "UNSET":
            missingOption = "destDir"
        elif options.archiveName == "UNSET":
            missingOption = "archiveName"
        logger.error(missingOption + " option has not been specified")
        parser.print_help()
        sys.exit(1)

    # Display args
    logger.debug("type : " + options.processingResult + " - "
                 "archiveName : " + options.archiveName + " - "
                 "destDir : " + options.destDir + " - "
                 "elapsedTime : " + options.elapsedTime + " - "
                 "parMessage : " + options.parMessage)


    # Setup regexes and path for each kind of download

    regexes=dict([ (options.videosPath + '/Walking_Dead_S3', '.*walking.*dead.*s[0-9]?3.*')
                  ,(options.videosPath + '/Boardwalk.Empire_S03', '.*boardwalk.*empire.*s[0-9]?3.*')
                  ,(options.videosPath + '/How_I_Met_Your_Mother_S8', '.*how.*i.*met.*your.*mother.*s[0-9]?8.*')
                  ,(options.videosPath + '/The_Big_Bang_Theory_S6', '.*the.*big.*bang.*theory.*s[0-9]?6.*')
                  ,(options.videosPath + '/Dexter_S7', '.*dexter.*s[0-9]?7.*')
                  ,(options.videosPath + '/Homeland_S2', '.*homeland.*s[0-9]?2.*')
                  ,(options.videosPath + '/Maison_Close_S02', '.*maison.*close.*s[0-9]?2.*')
                  ,(options.videosPath + '/Borgia_S02', '.*the.*borgia.*s[0-9]?2.*')
                  ,(options.videosPath + '/Modern.Family/Season.04', '.*modern.*family.*s[0-9]?4.*')
                  ,(options.videosPath + '/Falling.Skies_S02', '.*falling.*skies.*s[0-9]?2.*')
                  ,(options.videosPath + '/Game.of.Throne/Season_03', '.*game.*throne.*s[0-9]?3.*')
                  ,(options.videosPath + '/Defiance/Season_01', '.*defiance.*s[0-9]?1.*')
                  ,(options.videosPath + '/dummy', '.*dummy.*')
                  ])

    # Retrieve where the downloaded thing should go
    videoDestDir = getDestination(options.destDir, regexes)
    if (len(videoDestDir) == 0):
        logger.error("Could not determine destination for download : " + options.destDir)
    # Get the videos out of the downloaded stuff
    videos = getVideos(options.destDir)
    if (len(videos) == 0):
        logger.warning("No video were found in " + videoDestDir)

    # Move if we got anything and a destination
    videosMoved = list()
    if (len(videos) > 0) and (len(videoDestDir) > 0):
        videosMoved = moveVideosToDestination(videos, videoDestDir,
                                              options.dryRun)


    # Send status mail
    if options.sendMail:
        logger.info("Sending status mail")
        mailBody = setMailBody(videos, videosMoved, options.destDir, videoDestDir)
        sendMail(options.archiveName,mailBody)

logger = logging.getLogger('dispatch')
if __name__ == "__main__":
    main()

