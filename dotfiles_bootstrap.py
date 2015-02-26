#!/usr/bin/env python

class BootStrap:
    def __init__(self):
        self.backupDir = None
        self.dotFilesRoot = None
        self.dryRun = True

    def createBackupDir(self):
        directory = self.backupDir
        if not os.path.exists(directory):
            print "Create Backup directory : " + str(directory)
            if not self.dryRun:
                os.makedirs(directory)

    def backupFile(self, src):
        print "TODO"

def main():
    boot = BootStrap()
    boot.backupFile("/tmp/titi")

if __name__ == "__main__":
    main()

