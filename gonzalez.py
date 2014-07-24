#!/usr/bin/env python

import sys
import time
import dbus
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
        self.waitServiceAvailable()
        # use dbus.SessionBus().list_names() to look if self.serviceName is available instead of dirty sleep
        # dbus object
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


if __name__ == '__main__':
    konsole = KonsoleWindow()
    tab = konsole.createTab("coucou")
    tab.sendCmd("ls")
else:
    p = subprocess.Popen(['konsole', '--nofork'])
    subprocess.call(['sleep', '3'])
    konsole_name = "org.kde.konsole-%s" % p.pid
    konsoleObj = bus.get_object(konsole_name, "/Konsole")
    session = konsoleObj.newSession()
    sessionObj = bus.get_object(konsole_name,"/Sessions/%d" % session.real)
    #subprocess.call(['sleep', '1'])
    sessionObj.setTitle(0, "title")
    sessionObj.setTitle(1, "title")

