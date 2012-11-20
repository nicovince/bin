#!/opt/bin/env /opt/bin/python2.6

#type        : post processing result, either 'SUCCESS' or 'ERROR'
#archiveName : name of the archive, e.g. 'Usenet_Post5'
#destDir     : where the archive ended up, e.g. '/ext2/usenet/Usenet_Post5'
#elapsedTime : a pretty string showing how long post processing took, e.g.
#             '10m 37s'
#parMessage  : optional post processing message. e.g. '(No Pars)'

import os, sys
import re

# Retrieve video from list of files
def getVideos(files):
    videoList = list()
    videoRegex=".*(mp4)|(avi)$"
    # iterate over files
    for f in files:
        # Does filename matches video regex 
        result = re.search(videoRegex,f, re.I)
        if result != None:
            # Append the file to the videoList to be returned
            videoList.append(f)
            print "Candidate : " + f
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
        print videoDestDir + "-" + videoRegex
        # Does regex matches to usenetDestDir?
        result = re.search(videoRegex,destDir,re.I)
        if result != None:
            print "Matching for " + videoDestDir
            # do not go further through regexes after a match has been found
            return videoDestDir


##
# @brief Move the videos to the target folder
#
# @param videoList List of videos to be moved
# @param videoDestDir Destination folder for the videos
#
# @return List of videos successfully copied to destination folder
def moveVideosToDestination(videoList, videoDestDir):
    #TODO: To be completed
    for f in videoList:
        print f + " would be copied to" + videoDestDir

## Start of script ##
print "### Start of post processing script"

print "### Args :"
if len(sys.argv) != 6:
    print "Wrong number or arguments"
    print "Got " + str(len(sys.argv))
    for arg in sys.argv:
        print arg
    sys.exit(1)

type = sys.argv[1]
archiveName = sys.argv[2]
destDir = sys.argv[3]
elapsedTime = sys.argv[4]
parMessage = sys.argv[5]

print "type : " + type
print "archiveName : " + archiveName
print "destDir : " + destDir
print "elapsedTime : " + elapsedTime
print "parMessage : " + parMessage
print "###"


videosPath='/mnt/disk1/share/videos/'

regexes=dict([(videosPath + 'Walking_Dead_S3', '.*walking.*dead.*s[0-9]?3.*')
              ,(videosPath + 'Boardwalk.Empire_S03', '.*boardwalk.*empire.*s[0-9]?3.*')
              ,(videosPath + 'How_I_Met_Your_Mother_S8', '.*how.*i.*met.*your.*mother.*s[0-9]?8.*')
              ,(videosPath + 'The_Big_Bang_Theory_S6', '.*the.*big.*bang.*theory.*s[0-9]?6.*')
              ,(videosPath + 'Dexter_S7', '.*dexter.*s[0-9]?7.*')
              ])

videoDestDir = getDestination(destDir, regexes)
videos = getVideos(os.listdir(destDir))

moveVideosToDestination(videos, videoDestDir)

#TODO: Split into more functions : 
# moveVideosToDestination(videoList, videoDestinationDir) return list of video copied
#   -> no copy when target already exists
