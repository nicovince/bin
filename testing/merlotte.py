#!/usr/bin/env python

import xml.etree.ElementTree as ET
class Merlotte:
    def __init__(self, xmlfile):
        self.__xmlfile = xmlfile
        self.__tree = ET.parse(self.__xmlfile)
        self.__root = self.__tree.getroot()

    def get_regexes_dict(self):
        ret = dict()
        # Loop over series
        for serie in self.__root.findall('serie'):
            serie_name = serie.find('name').text
            serie_path = serie_name.replace(' ', '_')
            path_elt = serie.find('path')
            # Update destination path
            if path_elt != None:
                serie_path = path_elt.text + "/"
            # loop over season
            for season in serie.findall('season'):
                season_path = serie_path
                # search path for season
                path_elt = season.find('path')
                if path_elt != None:
                    season_path += path_elt.text

                # search regex for season
                regex_elt = season.find('regex')
                regex_str = "NO REGEX"
                if regex_elt != None:
                    regex_str = regex_elt.text
                ret[season_path] = regex_str
        return ret


if __name__ == "__main__":
    print "This module should be used not called"
