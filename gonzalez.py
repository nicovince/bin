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
        self.tabList = [TabSession(self, True)]

    # Create tab in konsole with given name
    # and return TabSession object
    def createNamedTab(self, name):
        tab = self.createTab()
        tab.setTitle(name)
        return tab

    def createTab(self):
        tab = TabSession(self)
        self.tabList.append(tab)
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

    # Setup konsole configuration
    def processConfig(self, konsoleConfig):
        first = True
        for tabConf in konsoleConfig["Tabs"]:
            # do not create tab for first one as it already exists
            if first:
                first = False
                tab = self.tabList[0]
            else:
                tab = self.createTab()
            tab.processConfig(tabConf)


class TabSession:
    # Create new tab in konsole
    def __init__(self, konsole, first=False):
        self.bus = dbus.SessionBus()
        self.parentKonsole = konsole
        if not first:
            sessionId = self.parentKonsole.dbusObj.newSession()
            self.dbusPath = "/Sessions/%d" % sessionId.real
        else:
            self.dbusPath = "/Sessions/1"

        self.dbusObj = self.bus.get_object(self.parentKonsole.serviceName, self.dbusPath)

    # Set title of tab
    def setTitle(self, title):
        self.title = title
        self.dbusObj.setTitle(0,title)
        self.dbusObj.setTitle(1,title)

    # Execute command in tab
    def sendCmd(self, cmd):
        self.dbusObj.sendText("%s\n" % cmd)

    # Setup tab configuration
    def processConfig(self, tabConfig):
        self.setTitle(tabConfig["Name"])
        for cmdConfig in tabConfig["Cmds"]:
            self.processCmd(cmdConfig)

    # Process Command config
    def processCmd(self, cmdConf):
        self.sendCmd(cmdConf["Cmd"])
        if 'delay' in cmdConf.keys():
            time.sleep(cmdConf["delay"])



class Gonzalez:
    def __init__(self, config):
        self.config = config
        self.process()

    # Process configuration
    def process(self):
        for kc in self.config["Konsoles"]:
            konsole = KonsoleWindow()
            konsole.processConfig(kc)

def test():
    konsole = KonsoleWindow()
    tab = konsole.createNamedTab("coucou")
    tab.sendCmd("ls")

def main():
    Gonzalez(json.load(open("/home/nvincent/bin/test.json")))

if __name__ == '__main__':
    main()
