#!/opt/bin/env /opt/bin/python2.6

import os, sys, re
import urllib2
import smtplib
import logging
from email.mime.text import MIMEText
from HTMLParser import HTMLParser
from htmlentitydefs import name2codepoint

# Parser for xbox market html pages
class XboxMarketHtmlParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.match = False
        self.price = list()
    def handle_starttag(self, tag, attrs):
        if tag == "span":
            for attr in attrs:
                if (attr[0] == "class" and attr[1] == "MSPoints SilverPrice ProductPrice"):
                    self.match = True
    def handle_data(self, data):
        if self.match:
            self.price.append(data.replace(',',''))
            self.match = False
    def getPrice(self):
        return self.price




# Send mail, subject is prefixed with "[Hella Nzb] "
def sendMail(subject, content):
    dest = "nico.vince@gmail.com"
    sender = "nico.vince@gmail.com"
    # setup mail
    msg = MIMEText(content)
    msg['From'] = sender
    msg['To'] = dest
    msg['Subject'] = "[Xbox Market] " + subject
    # setup smtp
    s = smtplib.SMTP('smtp.free.fr')
    s.sendmail(sender, [dest], msg.as_string())
    s.quit()

def getPrice(data):
    price = list()
    pattern="^\s*<span class=\"ProductPrices\"><span class=\"MSPoints SilverPrice ProductPrice\">(?P<price>[,0-9]+)</span></span>\s*$"
    regex=re.compile(pattern)
    for l in data.splitlines():
        result = regex.match(l)
        if result != None:
            price.append(result.groupdict()['price'].replace(',',''))
    return price



def getPage(url):
    usock = urllib2.urlopen(url)
    data = usock.read()
    usock.close()
    return data


url = "http://marketplace.xbox.com/en-US/Product/Gears-of-War-3-Season-Pass/b38b82ce-1dc6-4028-a69b-514babca6db0"



logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-10s %(levelname)-8s %(message)s',
                    datefmt='%Y/%m/%d %H:%M:%S',
                    filename='/home/admin/monitorXboxMarket.log',
                    filemode='a')
logger = logging.getLogger('XboxMarket')

#fd = open('gow3SeasonPass.html')
#data = fd.read()
data = getPage(url)
#price = getPrice(data)
currentPrice="2400"
parser = XboxMarketHtmlParser()
parser.feed(data)
price2 = parser.getPrice()
prices = ""
for p in price2:
    prices += p + " "
    if p < currentPrice:
        sendMail("Gow3 Season Pass","Price of Season pass is " + p + "\n" + str(price2))
logger.info("Gow Season Pass : " + prices)
