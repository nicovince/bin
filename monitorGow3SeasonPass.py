#!/opt/bin/env /opt/bin/python2.6

import os, sys, re
import urllib2
import smtplib
from email.mime.text import MIMEText

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

#fd = open('gow3SeasonPass.html')
#data = fd.read()
data = getPage(url)
price = getPrice(data)
currentPrice="2400"
for p in price:
    if p < currentPrice:
        sendMail("Gow3 Season Pass","Price of Season pass is " + p + "\n" + str(price))
