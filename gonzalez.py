#!/usr/bin/env python

import dbus
bus = dbus.SessionBus()
konsoleObj = bus.get_object("org.kde.konsole-26946", "/Konsole")
session = konsoleObj.newSession()
session.setTitle(0, "title")
session.setTitle(1, "title")
