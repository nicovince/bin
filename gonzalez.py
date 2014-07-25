#!/usr/bin/env python

import sys
import time
import dbus
import json
import subprocess
bus = dbus.SessionBus()

class KonsoleWindow:
    # Create new konsole window
    def __init__(self):
        self.bus = dbus.SessionBus()
        # Create new konsole window
        p = subprocess.Popen(['konsole', '--nofork'])
        # dbus id of the new konsole created
        self.serviceName = "org.kde.konsole-%s" % p.pid
        # Wait for newly created konsole's service to be available
        self.waitServiceAvailable()
        self.dbusObj = self.bus.get_object(self.serviceName, "/Konsole")
        self.tabList = list()

    # Create tab in konsole with given name
    # and return TabSession object
    def createTab(self, name):
        tab = TabSession(self)
        self.tabList.append(tab)
        tab.setTitle(name)
        return tab

    # Check if service attached to the konsole is available in the list of services presented
    # by dbus
    def isServiceAvailable(self):
        return True if dbus.UTF8String(self.serviceName) in self.bus.list_names() else False

    # Wait for dbus service to be available, timeout given in seconds
    def waitServiceAvailable(self, timeout=5):
        timeoutMs = timeout * 1000
        step = 100.0
        cnt = 0
        while not(self.isServiceAvailable()) and (cnt < timeoutMs):
            time.sleep(step/1000.0)
            cnt += step
        if cnt >= timeoutMs:
            print "Service %s is not available after %d seconds" % (self.serviceName, timeout)
            sys.exit(1)




class TabSession:
    # Create new tab in konsole
    def __init__(self, konsole):
        self.bus = dbus.SessionBus()
        self.parentKonsole = konsole
        sessionId = self.parentKonsole.dbusObj.newSession()
        self.dbusPath = "/Sessions/%d" % sessionId.real
        self.dbusObj = self.bus.get_object(self.parentKonsole.serviceName, self.dbusPath)

    # Set title of tab
    def setTitle(self, title):
        self.title = title
        self.dbusObj.setTitle(0,title)
        self.dbusObj.setTitle(1,title)

    # Execute command in tab
    def sendCmd(self, cmd):
        self.dbusObj.sendText("%s\n" % cmd)

class Gonzalez:
    def __init__(self, config):
        self.config = config
        self.process()

    # Process configuration
    def process(self):
        for kc in self.config["Konsoles"]:
            self.processKonsole(kc)

    # TODO process functions should go in appropriates classes
    # Process Konsole Configuration
    def processKonsole(self, konsoleConfig):
        konsole = KonsoleWindow()
        for tc in konsoleConfig["Tabs"]:
            self.processTab(konsole, tc)

    # Process Tab Configuration
    def processTab(self, konsole, tabConfig):
        tab = konsole.createTab(tabConfig["Name"])
        for cmdConf in tabConfig["Cmds"]:
            self.processCmd(tab, cmdConf)

    # Process Command config
    def processCmd(self, tab, cmdConf):
        tab.sendCmd(cmdConf["Cmd"])
        if 'delay' in cmdConf.keys():
            time.sleep(cmdConf["delay"])


def test():
    konsole = KonsoleWindow()
    tab = konsole.createTab("coucou")
    tab.sendCmd("ls")

def main():
    Gonzalez(json.load(open("/home/nvincent/bin/test.json")))

if __name__ == '__main__':
    main()
