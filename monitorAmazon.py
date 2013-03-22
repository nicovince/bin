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
        self.price = list()
    def handle_starttag(self, tag, attrs):
        #print tag
        #print attrs
        if tag == "span":
            for attr in attrs:
                if (attr[0] == "id" and attr[1] == "actualPriceValue"):
                    self.matchActualPriceValue = True
        elif tag == "b":
            for attr in attrs:
                if (self.matchActualPriceValue and attr[0] == "class" and attr[1] == "priceLarge"):
                    self.matchPriceLarge = True

    def handle_data(self, data):
        if (self.matchActualPriceValue and self.matchPriceLarge):
            self.price.append(data.replace(',','.').replace("EUR ",""))
            self.matchActualPriceValue = False
            self.matchPriceLarge = False
    def getPrice(self):
        return self.price

url ="http://www.amazon.fr/Take-2-BioShock-Infinite/dp/B004Z6A9GK/ref=pd_sim_vg_4"
url="http://www.amazon.fr/gp/product/B0088O0JQK/ref=oh_details_o00_s00_i00?ie=UTF8&psc=1"


#data = getPage(url)
fd = open('amazon.html','r')
data = fd.read()
#dataclean = data.replace("è","e")
dataclean = data.decode('utf-8','ignore')
fd_clean = open('clean.html','w')
fd_clean.write(dataclean)
fd_clean.close()
parser = AmazonHtmlParser()
parser.feed(dataclean)
price2 = parser.getPrice()
print price2
for price in price2:
    print price
