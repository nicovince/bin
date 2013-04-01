#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys, re
import smtplib
import logging
from email.mime.text import MIMEText
from webparser import AmazonHtmlParser
from webparser import get_page
from optparse import OptionParser
import utils


url = "http://www.amazon.fr/Lego-le-Seigneur-des-Anneaux/dp/B0088O0KI2/ref=sr_1_1_title_1?s=videogames&ie=UTF8&qid=1364062396&sr=1-1"
url="http://www.amazon.fr/gp/product/B0088O0JQK/ref=oh_details_o00_s00_i00?ie=UTF8&psc=1"
url ="http://www.amazon.fr/Take-2-BioShock-Infinite/dp/B004Z6A9GK/ref=pd_sim_vg_4"

def get_infos(url):
    web_page = get_page(url)
    web_page_clean = web_page.decode('utf-8', 'ignore')
    parser = AmazonHtmlParser()
    parser.feed(web_page_clean)
    priceList = parser.get_price()
    return [priceList[0], parser.get_title()]

def main():
    # Options parsing
    parser = OptionParser("%prog [options]")
    parser.add_option("-u", "--url", dest='url', default=url,
                      help="Amazon url of the object to monitor (default : %default)")
    parser.add_option("-p", "--price", dest='trigger_price',
                      default=0, type=float,
                      help="Price below which a notification is sent (default %default)")
    parser.add_option("-t", "--to", dest='dest_email', default='nico.vince@gmail.com',
                      help="Email address to whom notification is sent (default %default)")
    parser.add_option("-n", "--no-mail", dest='send_email', default=True, action="store_false",
                      help="Disable mail notification")
    (options, args) = parser.parse_args()

    # Retrieve datas
    [price, item] = get_infos(options.url)
    print item + " costs " + str(price) + " euros"
    if price < options.trigger_price:
        subject = "[Amazon] " + item + " price reduction"
        content = "Price of " + item + " (" + str(price) + ") is below trigger price (" + str(options.trigger_price) + ")"
        print content
        if (options.send_email):
            utils.send_mail(subject, content, options.dest_email, options.dest_email)


if __name__ == "__main__":
    main()
