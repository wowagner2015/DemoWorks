import mstr_servers_availability as sc
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import sys

def mstr_servers_availability_email_alert(subject, body, send_to, reply_to):
    # Set up email message
    msg = MIMEMultipart()
    msg['From'] = 'CorpAppsBI-MSTR@email.com'
    msg['To'] = send_to
    msg['Subject'] = subject
    msg.add_header('reply-to', reply_to)
    msg.attach(MIMEText(body, 'plain'))

    # Send email
    smtp_server = 'smarthost.email_host_dns.com'
    smtp_port = 25
    smtp_conn = smtplib.SMTP(smtp_server, smtp_port)
    smtp_conn.ehlo()
    smtp_conn.starttls()
    smtp_conn.sendmail('wagnerw@email.com', send_to, msg.as_string())
    smtp_conn.quit()

if len(sys.argv) > 1:
    send_to = sys.argv[1]
else:
    send_to = 'wagnerw@email.com'

if len(sys.argv) > 2:
    reply_to = sys.argv[2]
else:
    reply_to = 'wagnerw@yemail.com'

subject = "All Good"
body = "All Good"

# Check if the 3rd argument is "SEND EMAIL"
if len(sys.argv) > 3:
    send_email_flag = sys.argv[3]
else:
    send_email_flag = None

# Loop through server types and call mstr_servers_availability function
server_statuses = {}
for server_type in ['Web1', 'Web2', 'IServer1', 'IServer2']:
    server_status = sc.mstr_servers_availability(server_type)
    server_statuses[server_type] = server_status

# Check for system down
web_down = False
iserver_down = False
down_servers = []
email_sent = False
for pair in [('Web1', 'Web2'), ('IServer1', 'IServer2')]:
    if server_statuses[pair[0]] is None and server_statuses[pair[1]] is None:
        # Both servers in pair are down
        down_servers += pair
        if pair[0].startswith('Web'):
            web_down = True
        elif pair[0].startswith('IServer'):
            iserver_down = True
    elif server_statuses[pair[0]] is None:
        # First server in pair is down
        down_servers.append(pair[0])
        if pair[0].startswith('Web'):
            web_down = True
        elif pair[0].startswith('IServer'):
            iserver_down = True
    elif server_statuses[pair[1]] is None:
        # Second server in pair is down
        down_servers.append(pair[1])
        if pair[0].startswith('Web'):
            web_down = True
        elif pair[0].startswith('IServer'):
            iserver_down = True

# Send email if system is down
if len(down_servers) == 4:
    body = 'SEVERE ERROR: The entire system is down. The following servers are down:\n\n'
    body += '\n'.join(down_servers)
    subject = 'SEVERE ERROR: The entire MicroStrategy Reporting system is down: ' + ', '.join(down_servers)
    mstr_servers_availability_email_alert_new1(subject=subject, body=body, send_to=send_to, reply_to=reply_to)
    email_sent = True
elif len(down_servers) > 0:
    body = 'The following servers are down:\n\n'
    body += '\n'.join(down_servers)
    subject = 'Warning: ' + ', '.join(down_servers)
    if web_down and iserver_down:
        subject += ' (MicroStrategy IServer and Web Server are down)'
    elif web_down:
        subject += ' (MicroStrategy Web Server is down)'
    elif iserver_down:
        subject += ' (MicroStrategy IServer is down)'
    mstr_servers_availability_email_alert(subject=subject, body=body, send_to=send_to, reply_to=reply_to)
    email_sent = True

# Execute the following only if email was not sent previously and the 3rd parm is "SEND EMAIL"
if not email_sent and send_email_flag == "SEND EMAIL":
    mstr_servers_availability_email_alert(subject, body, send_to, reply_to)
