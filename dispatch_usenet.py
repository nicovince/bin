#!/opt/bin/env /opt/bin/python2.6

#type        : post processing result, either 'SUCCESS' or 'ERROR'
#archiveName : name of the archive, e.g. 'Usenet_Post5'
#destDir     : where the archive ended up, e.g. '/ext2/usenet/Usenet_Post5'
#elapsedTime : a pretty string showing how long post processing took, e.g.
#             '10m 37s'
#parMessage  : optional post processing message. e.g. '(No Pars)'

import os, sys
import re

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


videosPath='/mnt/disk1/share/videos/'

regexes=dict([(videosPath + 'Walking_Dead_S3', '.*walking.*dead.*s[0-9]?3.*'),
            (videosPath + 'Boardwalk.Empire_S03', '.*boardwalk.*empire.*s[0-9]?3.*')])
            (videosPath + 'How_I_Met_Your_Mother_S8', '.*how.*i.*met.*your.*mother.*s[0-9]?8.*')])
            (videosPath + 'The_Big_Bang_Theory_S6', '.*the.*big.*bang.*theory.*s[0-9]?6.*')])
            (videosPath + 'Dexter_S7', '.*dexter.*s[0-9]?7.*')])

# loop through regexes to find a match for the download
for (videoDestDir,videoRegex) in regexes.items():
    print videoDestDir + "-" + videoRegex
    result = re.search(videoRegex,destDir,re.I)
    if result != None:
        print "Matching for " + videoDestDir
        print destDir
        print os.listdir(destDir)


# Retrieve video from list of files
def getVideo(files):

