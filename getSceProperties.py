#!/usr/bin/env python

from xml.dom import minidom
import os
import re
import sys

# Retrieve list of properties for a given envConfig file
def getProperties(envConfig):
    # check if the file exists
    if os.path.isfile(envConfig):
        xmldoc = minidom.parse(envConfig)
        coverage_list = xmldoc.getElementsByTagName("Coverage")
        if len(coverage_list):
            coverage = coverage_list[0]
            properties = coverage.attributes.keys()
        else:
            properties = []
    else:
        properties = []

    return properties

def removeDuplicates(l):
    if l:
        l.sort()
        last = l[-1]
        for i in range(len(l)-2, -1, -1):
            if last == l[i]:
                del l[i]
            else:
                last = l[i]


# retrieve argument
files = sys.argv
# remove script name
del(files[0])

removeDuplicates(files)

props = []
for f in files:
    sceProps = getProperties(f)
    props = props + sceProps

removeDuplicates(props)
for p in props:
    print p
