#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys, re
import smtplib
import logging
from email.mime.text import MIMEText
from webparser import AmazonHtmlParser
from webparser import getPage

url="http://www.amazon.fr/gp/product/B0088O0JQK/ref=oh_details_o00_s00_i00?ie=UTF8&psc=1"
url ="http://www.amazon.fr/Take-2-BioShock-Infinite/dp/B004Z6A9GK/ref=pd_sim_vg_4"
url = "http://www.amazon.fr/Lego-le-Seigneur-des-Anneaux/dp/B0088O0KI2/ref=sr_1_1_title_1?s=videogames&ie=UTF8&qid=1364062396&sr=1-1"

def getInfos(url):
    web_page = getPage(url)
    web_page_clean = web_page.decode('utf-8', 'ignore')
    parser = AmazonHtmlParser()
    parser.feed(web_page_clean)
    priceList = parser.getPrice()
    return [priceList[0], parser.getTitle()]



if __name__ == "__main__":
    [price, item] = getInfos(url)
    print item + " costs " + str(price) + " euros"
