#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys, re
import urllib2
import smtplib
import logging
from email.mime.text import MIMEText
from webparser import AmazonHtmlParser

def getPage(url):
    usock = urllib2.urlopen(url)
    data = usock.read()
    usock.close()
    return data

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
