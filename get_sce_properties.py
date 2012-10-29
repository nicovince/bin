#!/usr/bin/env python

from xml.dom import minidom
import os
import re
import sys

#################
### FUNCTIONS ###
#################

# Brief help
def print_help():
    print "Usage : " + sys.argv[0] + " </path/to/tb_module>"
    print "This scripts outputs for each scenario all the properties defined in envConfig.lte"
    print "The output is printed on stdout as a CSV (semi-colon separators) file."


# Retrieve list of properties for a given envConfig file
def getProperties(envConfig):
    # check if the file exists
    if os.path.isfile(envConfig):
        xmldoc = minidom.parse(envConfig)
        coverage_list = xmldoc.getElementsByTagName("Coverage")
        coverage = coverage_list[0]

        properties = coverage.attributes.keys()
    else:
        properties = []

    return properties


# Retrieve list of scenario for a given folder, scenario folder should start with "sce"
def getScenarii(folder):
    ls = os.listdir(folder)
    scenarii = []
    for f in ls:
        # Check for sce at begining of folder name
        if re.match("sce", f):
            scenarii.append(f)
    scenarii.sort()
    return scenarii



############
### MAIN ###
############

# retrieve module simulation folder
module = sys.argv[1]

if not(os.path.isdir(module)):
    print_help()
    exit(255)


scenarii = getScenarii(module)
for sce in scenarii:
    envConfig = module + "/" + sce + "/envConfig.lte"
    props = getProperties(envConfig)
    # create string for properties
    props_str = ""
    for p in props:
        props_str = props_str + p + " "

    # display
    print sce + ";;" + props_str + ";"

