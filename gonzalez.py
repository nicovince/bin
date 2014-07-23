#!/usr/bin/env python

import dbus
import subprocess
bus = dbus.SessionBus()

class KonsoleWindow:
    # Create new konsole window
    def __init__(self):
        self.bus = dbus.SessionBus()
        # Create new konsole window
        p = subprocess.Popen(['konsole', '--nofork'])
        subprocess.call(['sleep', '3'])
        # dbus id of the new konsole created
        self.serviceName = "org.kde.konsole-%s" % p.pid
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

