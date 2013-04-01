import smtplib
from email.mime.text import MIMEText

def send_mail(subject, content, dest, sender):
    # setup mail
    msg = MIMEText(content)
    msg['From'] = sender
    msg['To'] = dest
    msg['Subject'] = subject
    # setup smtp
    s = smtplib.SMTP('smtp.free.fr')
    s.sendmail(sender, [dest], msg.as_string())
    s.quit()
