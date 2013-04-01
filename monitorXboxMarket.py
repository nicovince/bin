#!/usr/bin/env python
#!/opt/bin/env /opt/bin/python2.6

import os, sys, re
import smtplib
import logging
from email.mime.text import MIMEText
from webparser import XboxMarketHtmlParser
from webparser import get_page




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

def get_price(data):
    price = list()
    pattern="^\s*<span class=\"ProductPrices\"><span class=\"MSPoints SilverPrice ProductPrice\">(?P<price>[,0-9]+)</span></span>\s*$"
    regex=re.compile(pattern)
    for l in data.splitlines():
        result = regex.match(l)
        if result != None:
            price.append(result.groupdict()['price'].replace(',',''))
    return price



url = "http://marketplace.xbox.com/en-US/Product/Gears-of-War-3-Season-Pass/b38b82ce-1dc6-4028-a69b-514babca6db0"



logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-10s %(levelname)-8s %(message)s',
                    datefmt='%Y/%m/%d %H:%M:%S',
                    filename=os.environ['HOME'] + '/monitorXboxMarket.log',
                    filemode='a')
logger = logging.getLogger('XboxMarket')

#fd = open('gow3SeasonPass.html')
#data = fd.read()
data = get_page(url)
#price = get_price(data)
currentPrice="2400"
parser = XboxMarketHtmlParser()
parser.feed(data)
price2 = parser.get_price()
prices = ""
print price2
for p in price2:
    prices += p + " "
    if p < currentPrice:
        sendMail("Gow3 Season Pass","Price of Season pass is " + p + "\n" + str(price2))
logger.info("Gow Season Pass : " + prices)
