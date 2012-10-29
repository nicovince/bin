#!/usr/bin/env python

'''
Common functions
'''

import os
import sys
import pwd
import time
import datetime
import random
import smtplib

## Parsing mail's functions
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

#sys.path.append("/delivery/lib/latest/scripts/")
sys.path.append("/home/vincent/nobackup/delivery/vincent_dev/swenv/scripts/")
from docBookToHtml import *



###############################################
###############################################
##               CLASS COMMON                ##
###############################################
###############################################

class CommonC :

    def __init__(self) :

        self.USER_LOGIN = getUserLogin()
        self.LOCK_FILE = None
        self.SUPER_USER = ['gregory', 'christopher', 'vincent', 'ctiouajni', 'osarr']
        self.RELTOOLS = os.getenv('RELTOOLS')
        if self.RELTOOLS == None :
            self.RELTOOLS = "latest"
        self.VERTOOLS = os.getenv('VERTOOLS')
        if self.VERTOOLS == None :
            self.VERTOOLS = "default"
        self.DIRTOOLS = "/delivery/tools_env"
        self.ATOMICS_SPY = False
        self.ATOMICS_LOG = None


    ## Display the self variable
    def display(self) :
        res = str();
        res += "# USER_LOGIN    = " + str(self.USER_LOGIN) + "\n"
        res += "# LOCK_FILE     = " + str(self.LOCK_FILE) + "\n"
        res += "# SUPER_USER    = " + str(self.SUPER_USER) + "\n"
        res += "# RELTOOLS      = " + str(self.RELTOOLS) + "\n"
        res += "# VERTOOLS      = " + str(self.VERTOOLS) + "\n"
        res += "# DIRTOOLS      = " + str(self.DIRTOOLS) + "\n"
        res += "# ATOMICS_SPY   = " + str(self.ATOMICS_SPY) + "\n"
        res += "# ATOMICS_LOG   = " + str(self.ATOMICS_LOG) + "\n"
        return res





###############################################
###############################################
##                CLASS LOG                  ##
###############################################
###############################################

class LogC(object):
    def __init__(self):
        self.fileName = None
        self.progName = None
        self.debug = False

    def init(self, dbg, file_name=None, prog_name=None):
        self.debug = dbg
        if file_name != None :
            self.fileName = str(file_name)
            try:
                os.remove(self.fileName)
            except :
                pass
        if prog_name != None :
            self.progName = str(prog_name)

    def writeLog(self, msg, color):
        if self.debug :
            print color + str(msg) + color_reset
        msg += "\n"
        if (self.fileName != None) :
            try :
                f = open(self.fileName, 'a+')
                f.write(msg)
                f.close()
            except IOError, OSError:
                pass

    def formatMsg(self, msg, level, item=None) :
        mes  = str(datetime.datetime.today().isoformat("_"))
        if (item != None) :
            mes += " [{0:^10}".format(item)
        elif (self.progName != None) :
            mes += " [{0:^10}".format(self.progName)
        else :
            mes += " [{0:^10}".format(" ")
        mes += "-{0:^10}] == ".format(str(level)) + str(msg)
        return mes

    ## Print information only the screen
    def dbg(self, code, msg):
        print color_debug + " DBG " + str(code) + " : " + str(msg) + color_reset

    ## Use to indicate where the program computes
    def info(self, msg, item=None):
        if (item == None) :
            self.writeLog(self.formatMsg(msg, "info"), color_info2)
        else :
            self.writeLog(self.formatMsg(msg, "info", item), color_info2)

    ## Use to prevent the user that a warning occurs
    def warn(self, msg, item=None):
        if (item == None) :
            self.writeLog(self.formatMsg(msg, "warn"), color_warn)
        else :
            self.writeLog(self.formatMsg(msg, "warn", item), color_warn)

    ## Use to prevent the user that an error occurs
    def error(self, msg, item=None):
        if (item == None) :
            self.writeLog(self.formatMsg(msg, "error"), color_error)
        else :
            self.writeLog(self.formatMsg(msg, "error", item), color_error)

    ## Exit
    def exit(self, code, msg, item=None):
        self.debug = False
        if (item == None) :
            self.writeLog(self.formatMsg(msg, "exit " + str(code)), color_error)
        else :
            self.writeLog(self.formatMsg(msg, "exit " + str(code), item), color_error)
        if (item == None) :
            sys.exit(color_error + "  ERROR :   Exit Code " + str(code) + "\n    " + str(msg) + "\n" + color_reset)
        else :
            sys.exit(color_error + "  ERROR " + str(item) + " :   Exit Code " + str(code) + "\n    " + str(msg) + "\n" + color_reset)

    ## Exit and close database
    def exitDB(self, code, msg, db, cursor, item=None):
        closedb(db,cursor)
        if (item == None) :
            self.exit(code, msg)
        else :
            self.exit(code, msg, item)


    ## Print info
    def pinfo(self, msg, item=None):
        print color_info1 + str(msg) + color_reset

    ## Print warning
    def pwarn(self, msg, item=None):
        print color_warn + str(msg) + color_reset

    ## Print error
    def perr(self, msg, item=None):
        print color_error + str(msg) + color_reset








###############################################
###############################################
##                 FUNCTIONS                 ##
###############################################
###############################################


## User login
def getUserLogin() :
    try :
        return os.environ['USER']
    except :
        return "Unknown"

## Super user definition
def superUser() :
    return(common.SUPER_USER.__contains__(common.USER_LOGIN))

## Connect to Fpga database
def connectFpga() :
    import pgdb
    try :
        db     = pgdb.connect(database='lab', host='192.168.200.158', user='web_user', password='atQcG66u')
        cursor = db.cursor()
    except :
        log.perr("Impossible to connect to fpga database\n")
    return db,cursor

## Connect to Asic Retd database
def connectAsicRetd() :
    import pgdb
    try :
        db     = pgdb.connect(database='asic', host='retd.sequans.com', user='runlist', password='runL15t')
        cursor = db.cursor()
    except :
        log.perr("Impossible to connect to asic database\n")
    return db,cursor

## Connect to ATOMICS database
def connectAtomics() :
    import pgdb
    try :
        db     = pgdb.connect(database='atomics_asic', host='atomics.sequans.com', user='atomics', password='io9UWe9u')
        cursor = db.cursor()
    except :
        log.perr("Impossible to connect to atomics database\n")
    return db,cursor

## Close the database
def closedb(db,cursor) :
    cursor.close()
    db.close()

## Random number
def getRandomSeed() :
    return random.randint(1,65536)

## Create a integer range
def parseRange(rangestr) :
    result = list()
    try :
        if (rangestr!="") :
            list0=rangestr.split(",")
            for list1 in list0 :
                list2=list1.split("-")
                if (len(list2)==2) : #range found
                    for i in range(int(list2[0]),int(list2[1])+1) :
                        result.append(i)
                else :
                  result.append(int(list2[0]))
    except :
        parser.error(" There is a problem with your parsed options")

    return(result)

## Determine if the file is executable.
def filetest_exe(file) :
    """Determine if the file is executable."""
    if not os.path.exists(file):
        return 0
    stat = os.path.stat
    statinfo = os.stat(file)
    mode = stat.S_IMODE(statinfo[stat.ST_MODE])
    if ((stat.S_IXUSR & mode) or (stat.S_IXGRP & mode) or (stat.S_IXOTH & mode)):
        return True
    return False

## Remove a directory
def remove_files_in_dir(path) :
    for file in os.listdir(path) :
        try :
            os.remove(os.path.join(path, file))
        except (IOError, OSError) as e :
            pass

## Send email
def sendMail(fro, to, cc, subject, message, html=False, server="localhost"):
    assert type(to)==list
    assert type(cc)==list

    msg = MIMEMultipart()

    msg['From']    = fro
    msg['To']      = ", ".join(to)
    msg['Cc']      = ", ".join(cc)
    msg['Subject'] = subject

    if html :
        mess = HtmlMail(message).get_msg()
    else :
        mess = MIMEText(message)
    msg.attach(mess)

    while True :
        try :
            smtp = smtplib.SMTP(server)
            break
        except smtplib.SMTPConnectError :
            continue
    smtp.sendmail(fro, (to + cc), msg.as_string())
    smtp.close()



###############################################
###############################################
##                  COLOR                    ##
###############################################
###############################################

## Color definition
color            = dict()
color['red']     ='\033[31m'
color['green']   ='\033[32m'
color['brown']   ='\033[33m'
color['blue']    ='\033[34m'
color['magenta'] ='\033[35m'
color['cyan']    ='\033[36m'
color['grey']    ='\033[37m'
color['orange']  ='\033[38m'
color['black']   ='\033[39m'
color['reset']   ='\033[39m\033[49m\033[0m'
color['blink']   ='\033[5m'
color['bold']    ='\033[1m'
color_default    = color['cyan']

color_debug = color['brown']
color_info1 = color['green']
color_info2 = color['cyan']
color_cmd   = color['magenta']
color_warn  = color['blue']
color_error = color['red']
color_reset = color['reset']




###############################################
###############################################
##                MAIN PART                  ##
###############################################
###############################################

common = CommonC()
log    = LogC()

