#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys, re
import urllib2
import smtplib
import logging
from email.mime.text import MIMEText
from HTMLParser import HTMLParser
from htmlentitydefs import name2codepoint

def getPage(url):
    usock = urllib2.urlopen(url)
    data = usock.read()
    usock.close()
    return data

# Parser for xbox market html pages
class AmazonHtmlParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.matchActualPriceValue = False
        self.matchPriceLarge = False
        self.matchTitle = False
        self.price = list()
    def handle_starttag(self, tag, attrs):
        if tag == "span":
            for attr in attrs:
                if (attr[0] == "id" and attr[1] == "actualPriceValue"):
                    # Price parsing
                    self.matchActualPriceValue = True
                elif (attr[0] == "id" and attr[1] == "btAsinTitle"):
                    # title parsing
                    self.matchTitle = True
        elif tag == "b":
            for attr in attrs:
                if (self.matchActualPriceValue and attr[0] == "class" and attr[1] == "priceLarge"):
                    # found all tags/attributes for price
                    self.matchPriceLarge = True

    def handle_data(self, data):
        if (self.matchActualPriceValue and self.matchPriceLarge):
            # Price
            # Remove EUR prefix
            strPrice = data.replace(',','.').replace("EUR ","")
            # cast to float
            self.price.append(float(strPrice.encode('utf-8','ignore')))
            self.matchActualPriceValue = False
            self.matchPriceLarge = False
        elif (self.matchTitle):
            # Title
            self.title = data
            self.matchTitle = False

    def getPrice(self):
        return self.price
    def getTitle(self):
        return self.title
        

url="http://www.amazon.fr/gp/product/B0088O0JQK/ref=oh_details_o00_s00_i00?ie=UTF8&psc=1"
url ="http://www.amazon.fr/Take-2-BioShock-Infinite/dp/B004Z6A9GK/ref=pd_sim_vg_4"
url = "http://www.amazon.fr/Lego-le-Seigneur-des-Anneaux/dp/B0088O0KI2/ref=sr_1_1_title_1?s=videogames&ie=UTF8&qid=1364062396&sr=1-1"


if __name__ == "__main__":
    data = getPage(url)
    fd = open('amazon.html','r')
    #data = fd.read()
    fd.close()
    #dataclean = data.replace("è","e")
    dataclean = data.decode('utf-8','ignore')
    parser = AmazonHtmlParser()
    parser.feed(dataclean)
    priceList = parser.getPrice()
    print parser.getTitle()
    print priceList
    for price in priceList:
        print price
