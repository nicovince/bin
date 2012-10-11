#!/usr/bin/env python

import os
import re
import sys

from optparse import OptionParser

# Return filelist stripped of comments
def readFilelist(filename):
    fp = open(filename)
    regexComment = re.compile("^//.*$")
    regexFile = re.compile("^.*$")
    result = list()
    for line in fp:
        if (regexComment.match(line) == None):
            result.append(regexFile.match(line).group(0))
    fp.close()
    return result


# Check files exists
def checkFilesExist(files):
    for f in files:
        if not os.access(f, os.F_OK|os.R_OK):
            print f + " does not exists"
            return False
    return True

# determine filetype based on extention
def isVerilog(fileName):
    regexVerilog = re.compile(".*\.((vh?)|(sv))$")
    if (regexVerilog.match(fileName) != None):
        return True
    else:
        return False

def isVhdl(fileName):
    regexVhdl = re.compile(".*\.vhdl?$")
    if (regexVhdl.match(fileName) != None):
        return True
    else:
        return False

# Get module and constant renaming for verilog
def getRenamesVerilog(filename, prefix):
    fp = open(filename)
    regexModuleName = re.compile("^ *module *(\w+) *.*$")
    regexDefine = re.compile("^ *`define *(\w+) *.*$")
    searchAndReplace = list()
    for line in fp:
        if regexModuleName.match(line) != None:
            moduleName = regexModuleName.match(line).group(1)
            if parsedArgs.debug:
                print "[getRenamesVerilog]: module match : " + moduleName
            searchAndReplace.append([moduleName, prefix + "_" + moduleName]);
        elif regexDefine.match(line) != None:
            defineName = regexDefine.match(line).group(1)
            if parsedArgs.debug:
                print "[getRenamesVerilog]: define match : " + defineName
            searchAndReplace.append([defineName, prefix.upper() + "_" + defineName]);

    fp.close()
    return searchAndReplace

# Retrieve list of renaming to do for vhdl
def getRenamesVhdl(filename, prefix):
    fp = open(filename)
    regexEntityName = re.compile("^ *entity *(\w+) *.*$", re.IGNORECASE)
    regexPackageName = re.compile("^ *package *(\w+) *.*$", re.IGNORECASE)
    regexConstantName =re.compile("^ *constant *(\w+) *.*$", re.IGNORECASE)
    searchAndReplace = list()
    for line in fp:
        if regexEntityName.match(line) != None:
            entityName = regexEntityName.match(line).group(1)
            if parsedArgs.debug:
                print "[getRenamesVhdl]: entity match : " + entityName
            searchAndReplace.append([entityName, prefix + "_" + entityName])
        elif regexPackageName.match(line) != None:
            entityName = regexPackageName.match(line).group(1)
            if parsedArgs.debug:
                print "[getRenamesVhdl]: Package match : " + entityName
            searchAndReplace.append([entityName, prefix + "_" + entityName])
        elif regexConstantName.match(line) != None:
            entityName = regexConstantName.match(line).group(1)
            if parsedArgs.debug:
                print "[getRenamesVhdl]: Constant match : " + entityName
            searchAndReplace.append([entityName, prefix + "_" + entityName])
    fp.close()
    return searchAndReplace

# get replacements to do from list of file
def getSearchAndReplace(files):
    verilogSearchAndReplace = list()
    vhdlSearchAndReplace = list()
    fileRenames = list()
    for f in files:
        fileRenames.append([os.path.basename(f), parsedArgs.macro + "_" + os.path.basename(f)])
        if isVerilog(f):
            if parsedArgs.debug:
                print "[getSearchAndReplace]: " + f + " is Verilog"
            fileSearchAndReplace = getRenamesVerilog(f, parsedArgs.macro)
            if len(fileSearchAndReplace):
                verilogSearchAndReplace += fileSearchAndReplace
        elif isVhdl(f):
            if parsedArgs.debug:
                print "[getSearchAndReplace]: " + f + " is Vhdl"
            fileSearchAndReplace = getRenamesVhdl(f, parsedArgs.macro)
            if len(fileSearchAndReplace):
                vhdlSearchAndReplace += fileSearchAndReplace
        else:
            if parsedArgs.debug:
                print "[getSearchAndReplace]: Could not determine type of " + f

    return (fileRenames, verilogSearchAndReplace, vhdlSearchAndReplace)



# adds prefix in front of each element of list l)
def prefixListElements(l, prefix):
    result = list()
    for el in l:
        result.append(prefix + el)
    return result


def patchFile(srcFile, destFile, commonDir, destDir, searchesAndReplaces):
    fileRenames =  searchesAndReplaces[0]
    verilogSearchAndReplace = searchesAndReplaces[1]
    vhdlSearchAndReplace = searchesAndReplaces[2]

    if parsedArgs.debug:
        print "[patchFile]: " + verilogSearchAndReplace.__repr__()
        print "[patchFile]: " + vhdlSearchAndReplace.__repr__()
        print "[patchFile]: " + fileRenames.__repr__()
        print "[patchFile]: " + commonDir
        print "[patchFile]: " + destDir

    fdDst = open(destDir + "/" + destFile + ".new", 'w')
    fdSrc = open(commonDir + "/" + srcFile, 'r')
    for line in fdSrc:
        fdDst.write(line)
    fdDst.close()
    fdSrc.close()


#################################################################################

parser = OptionParser();

parser.add_option(
    "-D",
    "--debug",
    action  = "store_true",
    dest    = "debug",
    default = False,
    help    = "Display all debug information"
    )

parser.add_option(
    "-c",
    "--common-dir",
    action  = "store",
    dest    = "common_dir",
    default = "not_set",
    help    = "Path to common directory to be used for common macro modules"
    )

parser.add_option(
    "-d",
    "--destination-dir",
    action  = "store",
    dest    = "destination_dir",
    default = "not_set",
    help    = "Path to common directory of the macro"
    )

parser.add_option(
    "-f",
    "--filelist",
    action  = "store",
    dest    = "filelist",
    default = "not_set",
    help    = "filelist containing the list of the common modules to import (as named in common directory"
    )

parser.add_option(
    "-m",
    "--macro",
    action  = "store",
    dest    = "macro",
    default = "not_set",
    help    = "macro name for which import of common modules is done"
    )


(parsedArgs, args) = parser.parse_args()

if parsedArgs.debug:
    print "debug set"

# Check filelist accessible
if not os.access(parsedArgs.filelist, os.F_OK|os.R_OK):
    print "filelist name : " + parsedArgs.filelist + " not accessible"
    sys.exit(1)


filesInCommon = readFilelist(parsedArgs.filelist)
files = prefixListElements(filesInCommon, parsedArgs.common_dir + "/")

# check content of filelist is accessible
if not checkFilesExist(files):
    sys.exit(1)
else:
    if parsedArgs.debug:
        print "All files given in " + parsedArgs.filelist + " exists and readable"

# Read Hdl to build replacement lists
(fileRenames, verilogSearchAndReplace, vhdlSearchAndReplace) = getSearchAndReplace(files)

#print verilogSearchAndReplace
#print vhdlSearchAndReplace
#print fileRenames

searchesAndReplaces = [fileRenames, verilogSearchAndReplace, vhdlSearchAndReplace]
patchFile(filesInCommon[0], parsedArgs.common_dir, parsedArgs.destination_dir, searchesAndReplaces)
