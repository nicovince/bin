#!/usr/bin/env python

import xml.etree.ElementTree as ET
import sys
import os

def main():
    filename = sys.argv[1]
    tree = ET.parse(filename)
    root = tree.getroot()
    for child in root:
        print child.tag, child.attrib

if __name__ == "__main__":
    main()
