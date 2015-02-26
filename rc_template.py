#!/usr/bin/env python
from string import Template
import re
import sys

# Process templated file, asking template var to user
# and return completed file
def processFile(templateFileName):
    templateFile = open(templateFileName, "r")
    fileContent = templateFile.read()
    # Search template pattern, excluding escaped $$
    regex = "[^$]\$[a-zA-Z0-9_]*"
    matches = re.findall(regex,fileContent)
    d = dict()
    print "Processing templated file : " + str(templateFileName)
    for m in matches:
        key = re.sub(".?\$", "", m)
        if key not in d:
            val = raw_input("What is " + str(key) + " : ")
            d[key] = val

    s = Template(fileContent)
    return s.safe_substitute(d)


def main():
    processFile("template.gitconfig")


if __name__ == "__main__":
    main()

