#!/usr/bin/env python
import sys
import os.path
import argparse

# Import smtplib for the actual sending function
import smtplib
# For guessing MIME type based on file name extension
import mimetypes

# Import the email modules we'll need
from email import encoders
from email.message import Message
from email.mime.audio import MIMEAudio
from email.mime.base import MIMEBase
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


def send(me, you, subject, mailbody, attachment):
    print(me)
    print(you)
    print(subject)
    print(mailbody)
    print(attachment)
    # Create mail
    outer = MIMEMultipart()
    outer["Subject"] = subject
    outer["From"] = me
    outer["To"] = you[0]

    # set body mail
    ctype, encoding = mimetypes.guess_type(mailbody)
    maintype, subtype = ctype.split("/", 1)
    fp = open(mailbody)
    msg = MIMEText(fp.read(), _subtype=subtype)
    outer.attach(msg)

    # Set attachement
    ctype, encoding = mimetypes.guess_type(attachment)
    maintype, subtype = ctype.split("/", 1)
    fp = open(attachment, "rb")
    msg = MIMEBase(maintype, subtype)
    msg.set_payload(fp.read())
    fp.close()
    # Encode the payload using Base64
    encoders.encode_base64(msg)
    # Set the filename parameter
    msg.add_header("Content-Disposition", "attachment", filename=os.path.basename(attachment))
    outer.attach(msg)

    composed = outer.as_string()
    # Send the message via our own SMTP server, but don"t include the
    # envelope header.
    s = smtplib.SMTP("smtp.free.fr")
    s.sendmail(me, you, composed)
    s.quit()

def main():
    parser = argparse.ArgumentParser()
    # Positional arguments
    parser.add_argument("subject", type=str, help="Mail subject")
    parser.add_argument("body", type=str, help="File containing content of mail")
    parser.add_argument("mail_from", metavar="from", type=str, help="email FROM field")
    parser.add_argument("to",  type=str, nargs="+", help="list of recipients")
    # optional arguments
    parser.add_argument("--attach", type=str, help="File attachment")
    args = parser.parse_args()

    send(args.mail_from, args.to, args.subject, args.body, args.attach)


if __name__ == "__main__":
    main()
