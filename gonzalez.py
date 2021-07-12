#!/usr/bin/env python3

import sys
import time
import dbus
import json
import subprocess
import os
import argparse
bus = dbus.SessionBus()

class KonsoleWindow:
    # Create new konsole window
    def __init__(self, serviceName=None):
        # NOTE: serviceName used to be different on each konsole window
        # (suffixed with pid), now they all share the same service name even
        # with the --no-fork option. For now, no new windows are created
        self.bus = dbus.SessionBus()
        if serviceName == None:
            self.virgin = False
            self.serviceName = "org.kde.konsole"
            # Wait for newly created konsole's service to be available
            self.waitServiceAvailable()
        else:
            self.virgin = False
            self.serviceName = serviceName
        self.dbusObj = self.bus.get_object(self.serviceName, os.environ["KONSOLE_DBUS_WINDOW"])
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
            print("Service %s is not available after %d seconds" % (self.serviceName, timeout))
            sys.exit(1)

    # Setup konsole configuration
    def processConfig(self, konsoleConfig):
        first = True
        for tabConf in konsoleConfig["Tabs"]:
            # do not create tab for first one as it already exists when working on a new konsole
            if first and self.virgin:
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
    def sendCmd(self, cmd, exec_cmd=True):
        if exec_cmd:
            self.dbusObj.sendText("%s\n" % cmd)
        else:
            self.dbusObj.sendText("%s" % cmd)

    # Setup tab configuration
    def processConfig(self, tabConfig):
        self.setTitle(tabConfig["Name"])
        for cmdConfig in tabConfig["Cmds"]:
            self.processCmd(cmdConfig)

    # Process Command config
    def processCmd(self, cmdConf):
        exec_cmd = True
        if "Exec" in cmdConf:
            assert type(cmdConf["Exec"]) == bool, "Exec field must be a boolean"
            exec_cmd = cmdConf["Exec"]
        self.sendCmd(cmdConf["Cmd"], exec_cmd)
        if 'delay' in cmdConf.keys():
            time.sleep(cmdConf["delay"])


class Gonzalez:
    def __init__(self, config, serviceName=None):
        self.config = config
        self.serviceName = serviceName
        self.process()

    # Process configuration
    def process(self):
        for kc in self.config["Konsoles"]:
            konsole = KonsoleWindow(serviceName=self.serviceName)
            konsole.processConfig(kc)

def test():
    konsole = KonsoleWindow()
    tab = konsole.createNamedTab("coucou")
    tab.sendCmd("ls")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("filename",
                        help="Json file where configuration is given")
    parser.add_argument("-s", "--serviceName", dest="serviceName",
                        default=None,
                        help="Dbus service name of the konsole where tabs are created instead of creating a new konsole window")
    args = parser.parse_args()
    Gonzalez(config=json.load(open(args.filename)),
             serviceName=args.serviceName)

if __name__ == '__main__':
    main()

