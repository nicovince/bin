#!/usr/bin/env python

import xml.etree.ElementTree as ET

def main():
    tree = ET.parse('config.xml')
    root = tree.getroot()
    for serie in root.findall('serie'):
        print serie.find('name').text
        for season in serie.findall('season'):
            print season.find('regex').text

if __name__ == "__main__":
    main()
