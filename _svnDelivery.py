#!/usr/bin/env python

import os
import re
import string
import sys
import smtplib

from python_common import *
from optparse import OptionParser

try :
    import pysvn
except Exception as e :
    raise Exception("Error during pysvn import.\n" + str(e))

## Parsing mail's functions
#sys.path.append("/delivery/lib/latest/scripts/")
sys.path.append("/home/vincent/nobackup/delivery/vincent_dev/swenv/scripts/")
from docBookToHtml import *
try :
    from svnLogDisplay import *
except Exception as e :
    sys.stderr.write(str(e)+"\n");
    sys.exit(1);



###############################################
###############################################
##              Line Parsing                 ##
###############################################
###############################################
parser = OptionParser();

parser.add_option(
    "-d",
    "--debug",
    action  = "store_true",
    dest    = "debug",
    default = False,
    help    = "Display all debug information"
    )

parser.add_option(
    "-r",
    "--rel",
    default =  "",
    action  = "store",
    dest    = "relName" ,
    help    = "Releasename"
)

parser.add_option(
    "--del_dir",
    default =  "",
    action  = "store",
    dest    = "delDir" ,
    help    = "Delivery directory"
)

parser.add_option(
    "--svnrange",
    default =  "default",
    action  = "store",
    dest    = "svnrange" ,
    help    = "Range for svn"
)

parser.add_option(
    "-t",
    "--tools",
    default =  False,
    action  = "store_true",
    dest    = "tools" ,
    help    = "For tools"
)

parser.add_option(
    "-f",
    "--fpga",
    default =  False,
    action  = "store_true",
    dest    = "fpga" ,
    help    = "For FPGA"
)

parser.add_option(
    "-p",
    "--palladium",
    default =  False,
    action  = "store_true",
    dest    = "palladium" ,
    help    = "For palladium"
)

parser.add_option(
    "-a",
    "--asic",
    default =  False,
    action  = "store_true",
    dest    = "asic" ,
    help    = "For ASIC"
)

parser.add_option(
    "--device",
    default =  "ASIC",
    action  = "store",
    dest    = "device" ,
    help    = "ASIC, PPS122_MAC, PPS122_DLP, PPS122_SCS_MEAS, PPSZSP_MAC, PPSZSP_DLP, PPSZSP_SCS_MEAS, MIPS_MAC, MIPS_DLP, MIPS_SCS_MEAS, ARMWIMAX_MAC, ARMWIMAX_PHYBE, ARMWIMAX_PHYFE or DIGRF2AFE"
)

parser.add_option(
    "--family",
    default = "default",
    action  = "store",
    dest    = "family" ,
    help    = "Precise the device family for ASIC and FPGA"
)

parser.add_option(
    "--fileList",
    default = None,
    action  = "store",
    dest    = "fileList" ,
    help    = "Precise the file list parsed by filepp"
)

parser.add_option(
    "--history",
    default = False,
    action  = "store_true",
    dest    = "history" ,
    help    = "Allows to add history from the branch creation"
)

parser.add_option(
    "--gen_txt",
    default = None,
    action  = "store",
    dest    = "txt_file" ,
    help    = "The file name generated in txt"
)

parser.add_option(
    "--message",
    default = "default",
    action  = "store",
    dest    = "message_file" ,
    help    = "Insert a message in first point"
)

parser.add_option(
    "--toAll",
    action  = "store_true",
    dest    = "toAll" ,
    default = False,
    help    = "Deliver to all"
)

parser.add_option(
    "--toDsp",
    action  = "store_true",
    dest    = "send_dsp" ,
    default = False,
    help    = "Deliver to dsp"
)

(parsedArgs, args) = parser.parse_args()

if not parsedArgs.tools and not parsedArgs.fpga and not parsedArgs.asic and not parsedArgs.palladium:
    parser.error("Please define which branch you want to use it")



## Create log class
log.init(parsedArgs.debug, None, "SvnDel" )





###############################################
###############################################
##                CLASS                      ##
###############################################
###############################################

class SvnDelC :

    def _getRange(self,revRange) :
        m = re.search("([0-9]*):([0-9]*)",revRange);

        if(not m) :
            log.exit(1, str(revRange)+" is not a valid range")

        return (m.group(1),m.group(2));


    def _getUrl(self) :
        try :
            client = pysvn.Client()
            url = client.info('.').url

            if parsedArgs.fpga or parsedArgs.asic :
                res = re.findall("(.*)/synth_.*", url)[0]
            elif parsedArgs.palladium:
                res = re.findall("(.*)/simv/tops/palladium/.*", url)[0]
            else :
                res = url

        except :
            log.exit(2, "Can't find url\n")

        return(res)


    def __init__(self) :

        (self._LowRev,self._UpRev) = self._getRange(parsedArgs.svnrange);
        self._revName = parsedArgs.relName;
        self._toAll = parsedArgs.toAll;
        self._toDsp = parsedArgs.send_dsp;
        self._Family = parsedArgs.family;
        self._Device = parsedArgs.device;
        self._delDir = parsedArgs.delDir
        self._relRange = "Delivery from " + self._LowRev + " to " + self._UpRev
        self._Url = self._getUrl()
        self._urlText = "URL= " + self._Url

        ## tools
        if parsedArgs.tools :
            self._Image = "tools_delivery.jpg";
            self._InitSvnNumber = "40787";

        ## fpga
        elif parsedArgs.fpga :
            if self._Family == "sqn1210" :
                self._Image = "fpga_virtex5.jpg";
                self._InitSvnNumber = "40787";
            elif self._Family == "sqn1220" or self._Family == "sqn1220_mips" :
                self._InitSvnNumber = "49259";
                if self._Device == "DIGRF2AFE" :
                    self._Image = "fpga_spartan3a.jpg";
                else :
                    self._Image = "fpga_virtex5.jpg";
            elif self._Family == "sqn2130" :
                self._Image = "fpga_stratix2.jpg";
                self._InitSvnNumber = "40787";
            elif self._Family == "sqn2130a" :
                self._Image = "fpga_stratix2.jpg";
                self._InitSvnNumber = "49182";
            elif self._Family == "jabba" :
                self._Image = "fpga_virtex5.jpg";
                self._InitSvnNumber = "54515";
            elif self._Family == "shiva" :
                self._Image = "fpga_stratix3.jpg";
                self._InitSvnNumber = "1";
            elif self._Family == "sqn1310" :
                self._InitSvnNumber = "59099";
                self._Image = "fpga_virtex5.jpg";
            elif self._Family == "sqn3110" :
                self._InitSvnNumber = "10913";
                if self._Device == "DIGRF2AFE" :
                    self._Image = "fpga_virtex6.jpg";
                else :
                	self._Image = "fpga_stratix3.jpg";
            elif self._Family == "sqn3140" :
                self._InitSvnNumber = "17835";
                self._Image = "fpga_max2.jpg";
            elif self._Family == "sqn3210" :
                self._InitSvnNumber = "33631";
                self._Image = "fpga_stratix3.jpg";
            else :
                log.exit(3, "family is not defined : " + self._Family)

        ## asic
        elif parsedArgs.asic :
            if self._Family == "sqn1210" :
                self._Image = "asic_sqn1210.jpg";
                self._InitSvnNumber = "40787";
            elif self._Family == "sqn1220" :
                self._Image = "asic_sqn1220.png";
                self._InitSvnNumber = "49259";
            elif self._Family == "sqn2130" :
                self._Image = "asic_sqn2130.png";
                self._InitSvnNumber = "40787";
            elif self._Family == "sqn2130A" :
                self._Image = "asic_sqn2130A.png";
                self._InitSvnNumber = "49182";
            elif self._Family == "jabba" :
                self._Image = "asic_jabba.png";
                self._InitSvnNumber = "54515";
            elif self._Family == "shiva" :
                self._Image = "asic_shiva.png";
                self._InitSvnNumber = "1";
            elif self._Family == "sqn1310" :
                self._Image = "asic_sqn1310.png";
                self._InitSvnNumber = "59099";
            elif self._Family == "sqn3010" :
                self._Image = "asic_sqn3010.png";
                self._InitSvnNumber = "1";
            elif self._Family == "sqn3110" :
                self._Image = "asic_sqn3110.png";
                self._InitSvnNumber = "1";
            elif self._Family == "sqn3140" :
                self._Image = "asic_sqn3140.png";
                self._InitSvnNumber = "1";
            elif self._Family == "sqn3210" :
                self._Image = "asic_sqn3210.png";
                self._InitSvnNumber = "33631";
            else :
                log.exit(4, "family is not defined : " + self._Family)

        ## palladium
        elif parsedArgs.palladium :
            if self._Family == "sqn3210":
                #TODO: use a fancy palladium image
                self._Image = "palladium.jpg";
                self._InitSvnNumber = "33631";
            else :
                log.exit(4, "family is not defined : " + self._Family)

        ## Get the log comment
        self._Log = svnLogDisplay(1, self._InitSvnNumber, self._LowRev, self._UpRev, self._Url, self._Device,  "", parsedArgs.history, parsedArgs.fileList, debug=parsedArgs.debug)

        if parsedArgs.message_file != "default" :
            self._mesPerso = True
            self._mesPersoName = parsedArgs.message_file
        else :
            self._mesPerso = False
            self._mesPersoName = "default"

        if parsedArgs.txt_file != None :
            self._Logtxt = self._Log.display("text")
            self._genTxt = True
            self._genTxtName = parsedArgs.txt_file
        else :
            self._genTxt = False
            self._genTxtName = "default"


    def createMail(self) :
        toUsers  = list()
        ccUsers  = list()

        mess = DocBook2Html(self.getXml()).getHtml()
        fromUser = common.USER_LOGIN + "@sequans.com"
        toUsers.append(common.USER_LOGIN + "@sequans.com")

        if (self._genTxt) :
            try :
                f = open(self._genTxtName,'w')
            except  :
                log.exit(5, "Can't open : " + self._genTxtName)
            try :
                f.write(self._Logtxt)
                f.flush
                f.close()
            except IOError:
                pass

        if (parsedArgs.tools) :
            if (self._toAll) :
                ccUsers.append("bb-ic@sequans.com")
            if (self._toDsp) :
                ccUsers.append("dsp-algo@sequans.com")
                ccUsers.append("dsp-mc@sequans.com")
            mailName = "TOOLS DELIVERY : " + self._revName
        elif (parsedArgs.fpga) :
            if (self._toAll) :
                ccUsers.append("bb-ic@sequans.com")
                ccUsers.append("lte-delivery@sequans.com")
            mailName = "FPGA DELIVERY : " + self._revName
        elif (parsedArgs.asic) :
            if (self._toAll) :
                ccUsers.append("bb-ic@sequans.com")
            mailName = "ASIC DELIVERY " + string.upper(self._Family) + " : " + self._revName
        elif (parsedArgs.palladium) :
            if (self._toAll) :
                ccUsers.append("bb-ic@sequans.com")
                ccUsers.append("lte-delivery@sequans.com")
            mailName = "PALLADIUM DELIVERY " + string.upper(self._Family) + " " + string.upper(self._UpRev)

        sendMail(fromUser, toUsers, ccUsers, mailName, mess, html=True);


    def getXml(self) :

        ## create our own header and footer
        self._Log.disableDocBookHeader();
        self._Log.disableDocBookFooter();

        ## create header
        env_reltools = os.getenv('RELTOOLS')
        result = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE article PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN" "http://www.oasis-open.org/docarticle/xml/4.1.2/docarticlex.dtd">
<article lang="">


    <para>


      <informaltable frame='None'>
       <tgroup cols='2'>
        <tbody>

          <row>
            <entry>
              <informalfigure>
                 <graphic fileref="/delivery/tools_env/'''+env_reltools+'''/images/'''+self._Image+'''"></graphic>
              </informalfigure>
            </entry>
            <entrytbl cols='3'>
              <tbody>
                <row>
                  <entry align="middle">
                    <refsect1 id="releasename">
                    <title>'''+self._revName+'''</title>
                    </refsect1>
                  </entry>
                </row>
                <row><entry align="middle">'''+self._relRange+'''</entry></row>
                <row><entry align="middle">'''+self._urlText+'''</entry></row>
                <row><entry align="middle">'''+self._delDir+'''</entry></row>
              </tbody>
            </entrytbl>
          </row>


        </tbody>
       </tgroup>
      </informaltable>


    </para>

    <toc></toc>

        '''

        if self._mesPerso :
            result += "<sect1><title>Information</title><para>"
            result += "<entry><itemizedlist>"
            record = False

            try :
                f = open(self._mesPersoName,'r')
            except  :
                log.exit(6, "Can't open : " + self._mesPersoName)
            for line in f.readlines() :
                if re.search("\S", line) :
                    if re.search("</>.*</>", line) :
                        result += "<listitem><para> " + re.findall("</>(.*)</>",line)[0] + " </para></listitem>"
                    elif re.search("^</>", line) :
                        result += "<listitem><para> " + re.findall("</>(.*)",line)[0] + " </para>\n"
                        record = True
                    elif re.search("</>$", line) :
                        result += "<para> " + re.findall("(.*)</>",line)[0] + " </para></listitem>"
                        record = False
                    elif record :
                        result += "<para>" + line + "</para>"
            try :
                f.close()
            except IOError:
                pass

            result += "</itemizedlist></entry>"
            result += "</para></sect1>"


        result += self._Log.display("docbook");

        ## Create footer
        result += "</article>\n";

        return result;




###############################################
###############################################
##                 MAIN                      ##
###############################################
###############################################

SvnDelC().createMail();

