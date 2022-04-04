#!/usr/bin/env python3

import sys
import time
import json
import os
import argparse
import dbus


bus = dbus.SessionBus()

class KonsoleWindow:
    # Create new konsole window
    def __init__(self, service_name=None):
        # NOTE: service_name used to be different on each konsole window
        # (suffixed with pid), now they all share the same service name even
        # with the --no-fork option. For now, no new windows are created
        self.bus = dbus.SessionBus()
        if service_name is None:
            self.virgin = False
            self.service_name = "org.kde.konsole"
            # Wait for newly created konsole's service to be available
            self.wait_service_available()
        else:
            self.virgin = False
            self.service_name = service_name
        self.dbus_obj = self.bus.get_object(self.service_name, os.environ["KONSOLE_DBUS_WINDOW"])
        self.tab_list = [TabSession(self, True)]

    # Create tab in konsole with given name
    # and return TabSession object
    def create_named_tab(self, name):
        tab = self.create_tab()
        tab.set_title(name)
        return tab

    def create_tab(self):
        tab = TabSession(self)
        self.tab_list.append(tab)
        return tab

    # Check if service attached to the konsole is available in the list of services presented
    # by dbus
    def is_service_available(self):
        return dbus.UTF8String(self.service_name) in self.bus.list_names()

    # Wait for dbus service to be available, timeout given in seconds
    def wait_service_available(self, timeout=5):
        timeout_ms = timeout * 1000
        step = 100.0
        cnt = 0
        while not(self.is_service_available()) and (cnt < timeout_ms):
            time.sleep(step/1000.0)
            cnt += step
        if cnt >= timeout_ms:
            print("Service %s is not available after %d seconds" % (self.service_name, timeout))
            sys.exit(1)

    # Setup konsole configuration
    def process_config(self, konsole_cfg):
        first = True
        for tab_cfg in konsole_cfg["Tabs"]:
            # do not create tab for first one as it already exists when working on a new konsole
            if first and self.virgin:
                first = False
                tab = self.tab_list[0]
            else:
                tab = self.create_tab()
            tab.process_config(tab_cfg)


class TabSession:
    # Create new tab in konsole
    def __init__(self, konsole, first=False):
        self.bus = dbus.SessionBus()
        self.parent_konsole = konsole
        if not first:
            session_id = self.parent_konsole.dbus_obj.newSession()
            self.dbus_path = "/Sessions/%d" % session_id.real
        else:
            self.dbus_path = "/Sessions/1"

        self.dbus_obj = self.bus.get_object(self.parent_konsole.service_name, self.dbus_path)

    # Set title of tab
    def set_title(self, title):
        self.dbus_obj.setTitle(0,title)
        self.dbus_obj.setTitle(1,title)

    # Execute command in tab
    def send_cmd(self, cmd, exec_cmd=True):
        if exec_cmd:
            self.dbus_obj.sendText("%s\n" % cmd)
        else:
            self.dbus_obj.sendText("%s" % cmd)

    # Setup tab configuration
    def process_config(self, tab_cfg):
        self.set_title(tab_cfg["Name"])
        for cmd_cfg in tab_cfg["Cmds"]:
            self.process_cmd(cmd_cfg)

    # Process Command config
    def process_cmd(self, cmd_cfg):
        exec_cmd = True
        if "Exec" in cmd_cfg:
            assert isinstance(cmd_cfg["Exec"], bool), "Exec field must be a boolean"
            exec_cmd = cmd_cfg["Exec"]
        self.send_cmd(cmd_cfg["Cmd"], exec_cmd)
        if 'delay' in cmd_cfg.keys():
            time.sleep(cmd_cfg["delay"])


class Gonzalez:
    def __init__(self, config, service_name=None):
        self.config = config
        self.service_name = service_name
        self.process()

    # Process configuration
    def process(self):
        for konsole_cfg in self.config["Konsoles"]:
            konsole = KonsoleWindow(service_name=self.service_name)
            konsole.process_config(konsole_cfg)


def test():
    konsole = KonsoleWindow()
    tab = konsole.create_named_tab("coucou")
    tab.send_cmd("ls")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("filename",
                        help="Json file where configuration is given")
    parser.add_argument("-s", "--service-name", dest="service_name",
                        default=None,
                        help="Dbus service name for the Konsole where the tabs needs to be crated")
    args = parser.parse_args()
    with open(args.filename, 'r', encoding='utf-8') as json_cfg_fd:
        json_cfg = json.load(json_cfg_fd)
        Gonzalez(config=json_cfg, service_name=args.service_name)

if __name__ == '__main__':
    main()
