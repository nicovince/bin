#!/usr/bin/env python

import xml.etree.ElementTree as ET

def main():
    tree = ET.parse('config.xml')
    root = tree.getroot()
    for serie in root.findall('serie'):
        print serie.find('name').text
        for season in serie.findall('season'):
            print season.find('regex').text

from merlotte import *
def main_merlotte():
    xmlParser = Merlotte('config.xml')
    regexes = xmlParser.get_regexes_dict()
    print regexes

if __name__ == "__main__":
    main()
    print "---"
    main_merlotte()
