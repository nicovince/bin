#!/usr/bin/env python

import dbus
import subprocess
bus = dbus.SessionBus()

p = subprocess.Popen(['konsole', '--nofork'])
subprocess.call(['sleep', '3'])
konsole_name = "org.kde.konsole-%s" % p.pid
konsoleObj = bus.get_object(konsole_name, "/Konsole")
session = konsoleObj.newSession()
sessionObj = bus.get_object(konsole_name,"/Sessions/%d" % session.real)
#subprocess.call(['sleep', '1'])
sessionObj.setTitle(0, "title")
sessionObj.setTitle(1, "title")
