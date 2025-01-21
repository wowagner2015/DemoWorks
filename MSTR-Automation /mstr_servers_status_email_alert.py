####################################################################################################################
# Script: mstr_servers_status_email_alert.py
# Description: This script monitors MicroStrategy server statuses and sends email alerts based on specific conditions:
#              1. Sends a "SEVERE ERROR" email if both IServers and both Web Servers are down.
#              2. Sends a "Warning" email if at least one server is down.
#              3. Sends an "All Servers are up and running" email if all servers are operational and the
#                 "--send_email" switch is used for email testing or confirmation purposes.
#
#              The script includes a retry mechanism to handle transient issues by rechecking server statuses
#              multiple times before sending an alert. Command-line arguments offer flexibility in configuring
#              email recipients, environment settings, retry duration, and interval between retries.
#
# Usage: python3 mstr_servers_status_email_alert.py [send_to] [reply_to] [--env {DEV,UAT,PRD}] 
#        [--send_email] [--retry_seconds <seconds>] [--retry_interval <seconds>]
#
#       - `send_to` and `reply_to` can be provided as positional arguments without switches for quick setup.
#       - Named arguments allow for further customization and are optional.
#
# Example: python3 mstr_servers_status_email_alert.py "bi-cio-alert@yahooprod.opsgenie.net" 
#          "Business-Systems-Analytics@email.com" --env UAT --send_email
#
# Arguments:
#   send_to (positional)       Email address to send the alert to. Default: 'wagnerw@yahooinc.com'.
#   reply_to (positional)      Email address for the 'reply-to' header. Default: 'wagnerw@yahooinc.com'.
#   --env {DEV,UAT,PRD}        Environment for server status checks. Default: 'PRD'.
#   --send_email               Forces sending an email alert, regardless of server status. Useful for testing.
#   --retry_seconds <seconds>  Total duration to retry checking server statuses. Default: 300 seconds.
#   --retry_interval <seconds> Time between retry attempts. Default: 7 seconds.
#
# Dependencies: - Assumes the existence of a module for checking MicroStrategy server statuses.
#
# Created by: Will Wagner
# Created on: May 9, 2023
#
# Last Modified by: Will Wagner
# Last Modified on: March 28, 2024
####################################################################################################################

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import argparse
import time
import mstr_servers_status as sc

def send_email_alert(subject, body, send_to, reply_to):
    msg = MIMEMultipart()
    msg['From'] = 'CorpAppsBI-MSTR@yahooinc.com'
    msg['To'] = send_to
    msg['Subject'] = subject
    msg.add_header('reply-to', reply_to)

    # Attach the body as HTML
    msg.attach(MIMEText(body, 'html'))

    # SMTP server configuration
    smtp_server = 'smarthost.yahoo.com'
    smtp_port = 25
    smtp_conn = smtplib.SMTP(smtp_server, smtp_port)
    smtp_conn.ehlo()
    smtp_conn.starttls()
    smtp_conn.sendmail(msg['From'], send_to, msg.as_string())
    smtp_conn.quit()

def check_server_status_with_retries(env, total_retry_seconds, retry_interval):
    start_time = time.time()
    while (time.time() - start_time) < total_retry_seconds:
        # Fetch the status for each server
        server_statuses = {server_type: sc.mstr_servers_status(server_type, env)
                           for server_type in ['Web1', 'Web2', 'IServer1', 'IServer2']}
        # Check if all servers are up
        if all(status == 0 for _, status in server_statuses.values()):
            return True, server_statuses, False  # All servers are up, no severe error
        # Check for severe error condition: all IServers and Web Servers are down
        if all(server_statuses[server][1] != 0 for server in ['Web1', 'Web2', 'IServer1', 'IServer2']):
            return False, server_statuses, True  # Severe error present
        time.sleep(retry_interval)  # Wait before retrying
    return False, server_statuses, False  # Exhausted retries, some servers might still be down

def main(send_to, reply_to, env, send_email, retry_seconds, retry_interval):
    all_servers_up, server_statuses, severe_error = check_server_status_with_retries(env, retry_seconds, retry_interval)

    if severe_error:
        subject = "SEVERE ERROR: All IServers and Web Servers are Down"
        body_content = "<p><strong>SEVERE ERROR:</strong> All IServers and Web Servers are down. Immediate attention required.</p>"
    elif not all_servers_up:
        subject = "MicroStrategy Server Status Alert - Warning: Some MicroStrategy servers are down"
        body_content = "<ul>"
        for server, status in server_statuses.items():
            color = "red" if status[1] != 0 else "green"
            weight = "bold" if status[1] != 0 else "normal"
            status_icon = "🛑" if status[1] != 0 else "✔️"  # Use stop sign for down, check mark for up
            status_text = "DO:WN" if status[1] != 0 else "UP"
            body_content += f"<li style='color: {color}; font-weight: {weight};'>{status_icon} {server}: {status_text}</li>"
        body_content += "</ul>"
    else:
        subject = "MicroStrategy Server Status Alert - All Servers are up and running"
        body_content = "<li>All MicroStrategy servers are currently operational.</li>"

    if all_servers_up and not send_email:
    # "All servers are up, but --send_email not specified. Skipping email."
        return    
        
    body_start = "<p>Please find the current server status below:</p>"
    body_end = f"<a href='https://libra.ops.corp.yahoo.com:4443/vipDetails?vipName=mstr{env.lower()}.fin.vip.corp.gq1.yahoo.com&IPVersion=IPv4'>Server Status Overview</a>"
    body = body_start + body_content + body_end

    send_email_alert(subject, body, send_to, reply_to)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Monitors MicroStrategy server statuses and sends email alerts.")
    parser.add_argument('send_to', nargs='?', default='wagnerw@yahooinc.com', help="Email address to send the alert to.")
    parser.add_argument('reply_to', nargs='?', default='wagnerw@yahooinc.com', help="Email address for the 'reply-to' header.")
    parser.add_argument('--env', default='PRD', choices=['DEV', 'UAT', 'PRD'], help="Environment for the server status check.")
    parser.add_argument('--send_email', action='store_true', help="Force sending an email alert, regardless of server status.")
    parser.add_argument('--retry_seconds', type=int, default=300, help="Total seconds to retry checking server status before sending an alert.")
    parser.add_argument('--retry_interval', type=int, default=7, help="Seconds to wait between retry attempts.")

    args = parser.parse_args()
    main(args.send_to, args.reply_to, args.env, args.send_email, args.retry_seconds, args.retry_interval)
