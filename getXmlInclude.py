#!/usr/bin/env python

import xml.etree.ElementTree as ET
import sys
import os

##
# @brief Parse an xml file recursively to get the included files
#
# @param filename Name of the xml file to parse
#
# @return List of files included in filename
def get_included_files(filename):
    files = list()
    tree = ET.parse(filename)
    root = tree.getroot()
    # iterate over file elements found in the xml whatever the depth
    for filenode in root.findall('.//file'):
        # filename is under attribute 'name'
        f = filenode.attrib['name']
        # adds the file to the list of dependency
        files.append(f)
        if os.path.isfile(f):
            # concatenate dependencies of f to the current dependency list
            files.extend(get_included_files(f))
    return files

if __name__ == "__main__":
    deps = get_included_files(sys.argv[1])
    str_deps = ""
    for i in deps:
        str_deps += i
    print str_deps
