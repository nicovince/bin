#!/usr/bin/env python
import os
import logging
import datetime
import time
from stat import *
import shutil
import re
from string import Template

class BootStrap:
    def __init__(self):
        self.dotFilesRoot = os.path.join(os.environ['HOME'], '.dotfiles')
        self.dryRun = True
        self.backupDir = os.path.join(self.dotFilesRoot,
                                      "backup_" + BootStrap.getTimeStamp())

    @staticmethod
    def getTimeStamp():
        t = time.time()
        ts = datetime.datetime.fromtimestamp(t).strftime('%Y-%m-%d_%H.%M.%S')
        return ts

    # Process templated file, asking template var to user
    # and return completed file
    @staticmethod
    def processFile(templateFileName):
        templateFile = open(templateFileName, "r")
        fileContent = templateFile.read()
        # Search template pattern, excluding escaped $$
        regex = "[^$]\$[a-zA-Z0-9_]*"
        matches = re.findall(regex,fileContent)
        d = dict()
        for m in matches:
            key = re.sub(".?\$", "", m)
            if key not in d:
                val = raw_input("What is " + str(key) + " : ")
                d[key] = val

        s = Template(fileContent)
        return s.safe_substitute(d)

    def createBackupDir(self):
        directory = self.backupDir
        if not os.path.exists(directory):
            logging.info("Create Backup directory : %s", str(directory))
            if not self.dryRun:
                os.makedirs(directory)

    def setDryRun(self, val):
        self.dryRun = val

    def setDotFilesRoot(self, pathname):
        self.dotFilesRoot = pathname

    def setBackupDir(self, pathname):
        self.backupDir = pathname

    # Copy src tree to destination
    def copyTree(self, src, dst):
        logging.debug("Copy dir %s to %s", src, dst)
        if not self.dryRun:
            shutil.copytree(src, dst)

    # Copy src to dest if not in dry run
    def copyFile(self, src, dst):
        logging.debug("Copy file %s to %s", src, dst)
        if not self.dryRun:
            # copyfile needs the file to exist,
            # so create an empty one if necessary
            if not os.path.exists(dst):
                f = open(dst, "w")
                f.close()
            shutil.copyfile(src, dst)
        return

    def copyLink(self, src, dst):
        realSrc = os.path.realpath(src)
        logging.debug("Copy link %s (%s) to %s", src, realSrc, dst)
        if not self.dryRun:
            os.symlink(realSrc, dst)


    def removePathName(self, pathname):
        logging.debug("Remove %s", pathname)
        mode = os.stat(pathname).st_mode
        if not self.dryRun:
            if S_ISDIR(mode):
                shutil.rmtree(pathname)
            elif S_ISREG(mode) or S_ISLNK(mode):
                os.remove(pathname)


    # Link src to destination
    def linkPathName(self, src, dst):
        logging.debug("Linking %s to %s", src, dst)
        if not self.dryRun:
            # First remove file, it should have been backed up
            if os.path.exists(dst):
                logging.debug("remove original file %s", dst)
                self.removePathName(dst)
            os.symlink(os.path.abspath(src), os.path.abspath(dst))

    # Copy src file or directory to backup directory
    # if source is a symlink, new symlink is created in backup dir
    # return backup filename
    def backupPathName(self, pathname):
        logging.info("Backup %s", pathname)
        filename = os.path.basename(pathname)
        dst = os.path.join(self.backupDir, filename)
        while os.path.exists(dst):
            newDst = dst + "." + BootStrap.getTimeStamp()
            logging.warning("Backup file %s already exists, using %s instead", dst, newDst)
            dst = newDst
        # select what to do based on source (dir, link, file...)
        if os.path.isdir(pathname):
            self.copyTree(pathname, dst)
        elif os.path.islink(pathname):
            self.copyLink(pathname, dst)
        elif os.path.isfile(pathname):
            self.copyFile(pathname, dst)
        return dst

    def bootStrapFile(self, src, dst):
        logging.info("Import %s to %s", src, dst)
        # backup existing destination file
        if os.path.exists(dst):
            self.backupPathName(dst)
        self.linkPathName(src, dst)
        return

    def bootStrap(self):
        self.createBackupDir()
        self.bootStrapLinks()
        self.bootStrapTemplates()

    # link configuration file, if destination exist it is backed up
    def bootStrapLinks(self):
        for src,dst in self.getLinkFiles():
            if os.path.exists(src):
                self.bootStrapFile(src, dst)
            else:
                logging.warning("Skipping missing file : %s", src)
        return

    def bootStrapTemplate(self, template, dst):
        logging.info("Import Template file %s to %s ", template, dst)
        out = BootStrap.processFile(template)
        if os.path.exists(dst):
            self.backupPathName(dst)
            self.removePathName(dst)
        f = open(dst, 'w')
        f.write(out)
        f.close()
        return

    # Process template files, if destination exists it is backed up
    def bootStrapTemplates(self):
        for template, dst in self.getTemplateFiles():
            if os.path.exists(template):
                self.bootStrapTemplate(template, dst)
            else:
                logging.warning("Skipping missing template file : %s", template)
        return



    # Return list of (src,dst) files that needs to be linked
    def getLinkFiles(self):
        fileList =  ['.bashrc',
                     '.bash_aliases',
                     '.bash_colors',
                     '.inputrc',
                     '.screenrc',
                     '.gitignore_global',
                     '.gitconfig',
                     ]
        srcFileList = []
        dstFileList = []
        for f in fileList:
            srcFileList.append(os.path.join(self.dotFilesRoot, f))
            dstFileList.append(os.path.join(os.environ['HOME'], f))
        return zip(srcFileList, dstFileList)

    # Return list of (template, dst) file that needs to be processed
    def getTemplateFiles(self):
        fileList = ['template.gitconfig_user']
        templateFileList = []
        dstFileList = []
        for f in fileList:
            templateFileList.append(os.path.join(self.dotFilesRoot, f))
            f2 = re.sub("template", "", f)
            dstFileList.append(os.path.join(os.environ['HOME'], f2))
        return zip(templateFileList, dstFileList)



class TestBootStrap:
    def __init__(self):
        self.boot = BootStrap()
        self.boot.setDryRun(False)
        sandbox = "sandbox"
        dotFilesRoot = os.path.join(sandbox, "dotfiles")
        # create dotfile directory
        if not os.path.exists(dotFilesRoot):
            os.makedirs(dotFilesRoot)
        # set backup
        self.boot.setBackupDir(os.path.join(dotFilesRoot, "backup"))

        # create initial config file in sandbox/
        confFile = os.path.join(sandbox, "confrc")
        if not os.path.exists(confFile):
            print "here"
            fd = open(confFile, 'w')
            fd.write("default OS config\n")
            fd.close()
        # create conf folder + file 
        confFold = os.path.join(sandbox, "confFolder")
        if not os.path.exists(confFold):
            os.makedirs(confFold)
        confFoldFile = os.path.join(confFold, "confFoldFile")
        if not os.path.exists(confFoldFile):
            fd = open(confFoldFile, "w")
            fd.write("default OS Config for folder file\n")
            fd.close()

        # create initial config file in sandbox/dotfile/
        dotConfFile = os.path.join(dotFilesRoot, "confrc")
        fd = open(dotConfFile, 'w')
        fd.write("my dotfile config\n")
        fd.close()

        dotConfFold = os.path.join(dotFilesRoot, "confFolder")
        if not os.path.exists(dotConfFold):
            os.makedirs(dotConfFold)
        dotConfFoldFile = os.path.join(dotConfFold, "confFoldFile")
        fd = open(dotConfFoldFile, "w")
        fd.write("default OS Config for folder file")
        fd.close()

        self.sandbox = sandbox
        self.dotConfFile = dotConfFile
        self.dotConfFoldFile = dotConfFoldFile
        self.confFile = confFile
        self.confFold = confFold

    # test various backups
    def testBackups(self):
        # test backup on regular file
        self.testBackup(self.confFile)
        # test backup on folder
        self.testBackup(self.confFold)

    # test one backup
    def testBackup(self, pathname):
        self.boot.createBackupDir()
        self.boot.backupPathName(pathname)
        #TODO add check that result backup is same as src

    def testBootStraps(self):
        self.testBootStrap(self.dotConfFile)

    def testBootStrap(self, pathname):
        self.boot.createBackupDir()
        self.boot.bootStrapFile(pathname,
                                os.path.join(self.sandbox,
                                             os.path.basename(pathname)))

def test():
    logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)
    tbs = TestBootStrap()
    #tbs.testBackups()
    tbs.testBootStraps()
    boot = BootStrap()
    boot.bootStrapLinks()

def main():
    logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)
    boot = BootStrap()
    boot.setDryRun(False)
    boot.bootStrap()



if __name__ == "__main__":
    main()

