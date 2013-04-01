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
                elif (attr[0] == "class" and attr[1] == "MSPoints GoldPrice ProductPrice"):
                    self.match = True
    def handle_data(self, data):
        if self.match:
            self.price.append(data.replace(',',''))
            self.match = False
    def getPrice(self):
        return self.price

