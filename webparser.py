from HTMLParser import HTMLParser
from htmlentitydefs import name2codepoint
import urllib2

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
                elif (attr[0] == "class" and attr[1] == "MSPoints GoldPrice ProductPrice"):
                    self.match = True
    def handle_data(self, data):
        if self.match:
            self.price.append(data.replace(',',''))
            self.match = False
    def getPrice(self):
        return self.price

# Parser for amazon html pages
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
        
# retrieve html content of url
def getPage(url):
    usock = urllib2.urlopen(url)
    data = usock.read()
    usock.close()
    return data

