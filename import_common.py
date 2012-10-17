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
    searchAndReplace = dict()
    for line in fp:
        if regexModuleName.match(line) != None:
            moduleName = regexModuleName.match(line).group(1)
            if parsedArgs.debug:
                print "[getRenamesVerilog]: module match : " + moduleName
            searchAndReplace.update({moduleName : prefix + "_" + moduleName});
        elif regexDefine.match(line) != None:
            defineName = regexDefine.match(line).group(1)
            if parsedArgs.debug:
                print "[getRenamesVerilog]: define match : " + defineName
            searchAndReplace.update({defineName : prefix.upper() + "_" + defineName});

    fp.close()
    return searchAndReplace

# Retrieve list of renaming to do for vhdl
def getRenamesVhdl(filename, prefix):
    fp = open(filename)
    regexEntityName = re.compile("^ *entity *(\w+) *.*$", re.IGNORECASE)
    regexPackageName = re.compile("^ *package *(body)? *(\w+) *.*$", re.IGNORECASE)
    regexConstantName =re.compile("^ *constant *(\w+) *.*$", re.IGNORECASE)
    searchAndReplace = dict()
    for line in fp:
        if regexEntityName.match(line) != None:
            entityName = regexEntityName.match(line).group(1)
            if parsedArgs.debug:
                print "[getRenamesVhdl]: entity match : " + entityName + "[" + line +"]"
            searchAndReplace.update({entityName : prefix + "_" + entityName})
        elif regexPackageName.match(line) != None:
            packageName = regexPackageName.match(line).group(2)
            if parsedArgs.debug:
                print "[getRenamesVhdl]: Package match : " + packageName + "[" + line +"]"
            searchAndReplace.update({packageName : prefix + "_" + packageName})
        # Do not replace constants as they are protected by vhdl namespace
        #elif regexConstantName.match(line) != None:
        #    constantName = regexConstantName.match(line).group(1)
        #    if parsedArgs.debug:
        #        print "[getRenamesVhdl]: Constant match : " + constantName + "[" + line +"]"
        #    searchAndReplace.update({constantName : prefix + "_" + constantName})
    fp.close()
    return searchAndReplace

# get replacements to do from list of file
def getSearchAndReplace(files):
    verilogSearchAndReplace = dict()
    vhdlSearchAndReplace = dict()
    fileRenames = dict()
    for f in files:
        dst = parsedArgs.destination_dir + "/" + os.path.dirname(parsedArgs.destination_dir) + "/" + os.path.basename(f)
        fileRenames[f] = dst
        if isVerilog(f):
            if parsedArgs.debug:
                print "[getSearchAndReplace]: " + f + " is Verilog"
            fileSearchAndReplace = getRenamesVerilog(f, macroName)
            if len(fileSearchAndReplace):
                verilogSearchAndReplace.update(fileSearchAndReplace)
        elif isVhdl(f):
            if parsedArgs.debug:
                print "[getSearchAndReplace]: " + f + " is Vhdl"
            fileSearchAndReplace = getRenamesVhdl(f, macroName)
            if len(fileSearchAndReplace):
                vhdlSearchAndReplace.update(fileSearchAndReplace)
        else:
            if parsedArgs.debug:
                print "[getSearchAndReplace]: Could not determine type of " + f

    return (verilogSearchAndReplace, vhdlSearchAndReplace)



# adds prefix in front of each element of list l)
def prefixListElements(l, prefix):
    result = list()
    for el in l:
        result.append(prefix + el)
    return result

# Adds prefix in front of the basename of each file 
def prefixFilenames(files, prefix):
    result = list()
    for f in files:
        result.append(os.path.dirname(f) + "/" + prefix + os.path.basename(f))
    return result

# Builds regex of the search pattern and return an hash table indexed by the regex
def getWordsRegExp(searchAndReplace, flag=0):
    result = dict()
    for (search, replace) in searchAndReplace.iteritems():
        regex = re.compile(r"\b" + search + r"\b", flag)
        result[regex] = replace;
    return result




def patchFile(srcFile, destFile, searchesAndReplaces, mapCommonFilenames, mapBasenameFiles):
    #fileRenames =  searchesAndReplaces[0]
    verilogSearchAndReplace = searchesAndReplaces[0]
    vhdlSearchAndReplace = searchesAndReplaces[1]

    if parsedArgs.debug:
        print "[patchFile]: " + verilogSearchAndReplace.__repr__()
        print "[patchFile]: " + vhdlSearchAndReplace.__repr__()
        print "[patchFile]: src : " + src
        print "[patchFile]: dst : " + dst

    fdDst = open(destFile + ".new", 'w')
    fdSrc = open(srcFile, 'r')
    for line in fdSrc:
        newLine = line
        # 'r' preceding strings in re is used to take what is in quote as raw
        # Verilog 
        for (search,replace) in verilogSearchAndReplace.iteritems():
            newLine = re.sub(search, replace, newLine)
        # Vhdl
        for (search,replace) in vhdlSearchAndReplace.iteritems():
            newLine = re.sub(search, replace, newLine)
        # filename with path
        for (search,replace) in mapCommonFilenames.iteritems():
            newLine = re.sub(search, replace, newLine)
        # basename of file
        for (search,replace) in mapBasenameFiles.iteritems():
            newLine = re.sub(search, replace, newLine)

        fdDst.write(newLine)

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
    help    = "Path to common directory to export common modules from"
    )

parser.add_option(
    "-d",
    "--destination-dir",
    action  = "store",
    dest    = "destination_dir",
    default = "not_set",
    help    = "Path to macro to import"
    )

parser.add_option(
    "-f",
    "--filelist",
    action  = "store",
    dest    = "filelist",
    default = "not_set",
    help    = "filelist containing the list of the common modules to import (as named in common directory)"
    )


(parsedArgs, args) = parser.parse_args()

if parsedArgs.debug:
    print "debug set"

if parsedArgs.destination_dir == "not_set":
    print "destination_dir not specified"
    parser.print_help()
    sys.exit(1)
if parsedArgs.common_dir == "not_set":
    print "common_dir not specified"
    parser.print_help()
    sys.exit(1)

# retrieve macro name from destination directory
macroName = os.path.basename(parsedArgs.destination_dir)

# Check filelist accessible
if not os.access(parsedArgs.filelist, os.F_OK|os.R_OK):
    print "filelist name : " + parsedArgs.filelist + " not accessible"
    sys.exit(1)


# path relatives to common and dest dirs
srcCommonFiles = readFilelist(parsedArgs.filelist)
dstCommonFiles = prefixFilenames(srcCommonFiles, macroName + "_")
# path absolutes
srcFiles = prefixListElements(srcCommonFiles, parsedArgs.common_dir + "/")
dstFiles = prefixListElements(dstCommonFiles, parsedArgs.destination_dir + "/")
# basenames
srcBasenames = list()
for f in srcCommonFiles:
    srcBasenames.append(os.path.basename(f))
dstBasenames = list()
for f in dstCommonFiles:
    dstBasenames.append(os.path.basename(f))


# map with absolute paths
mapFiles = dict(zip(srcFiles, dstFiles))
# map with relatives paths from common_dir and dest_dir
mapCommonFilenames = dict(zip(srcCommonFiles, dstCommonFiles))
# map with basenames
mapBasenameFiles = dict(zip(srcBasenames, dstBasenames))


# check content of filelist is accessible
if not checkFilesExist(srcFiles):
    sys.exit(1)
else:
    if parsedArgs.debug:
        print "All files given in " + parsedArgs.filelist + " exists and readable"

# Read Hdl to build replacement lists
(verilogSearchAndReplace, vhdlSearchAndReplace) = getSearchAndReplace(srcFiles)

# hashes with regex instead of string for the search pattern (key)
verilogRegexSaR = getWordsRegExp(verilogSearchAndReplace)
vhdlRegexSaR = getWordsRegExp(vhdlSearchAndReplace, re.IGNORECASE)
mapCommonFilenamesRegex = getWordsRegExp(mapCommonFilenames)
mapBasenameFilesRegex = getWordsRegExp(mapBasenameFiles)

searchesAndReplaces = [verilogRegexSaR, vhdlRegexSaR]
for (src,dst) in mapFiles.iteritems():
    print src + " -> " + dst
    patchFile(src, dst, searchesAndReplaces, mapCommonFilenamesRegex, mapBasenameFilesRegex)
