############################################################################################################
# Script: mstr_servers_status.py
# Description: This module provides a function to check the availability of input
#              MicroStrategy servers. The function takes a server_type as the first
#              argument and an optional environment as the second argument. It
#              returns a 2-element list containing the server name and its status.
#
#              Server types include Web1, Web2, IServer1, and IServer2. The function
#              queries the server information using an API endpoint and processes
#              the response to extract the desired information.
#
# Usage: import mstr_servers_status
#        server_status = mstr_servers_status.mstr_servers_status(server_type, environment)
#
# Example: server_status = mstr_servers_status.mstr_servers_status("Web1", "UAT")
#
# Arguments: server_type: A string indicating the type of server to check,
#                         e.g., 'Web1', 'Web2', 'IServer1', or 'IServer2'.
#            environment: (Optional) A string indicating the environment, e.g., 'PRD', 'DEV', or 'UAT'.
#                         Defaults to 'PRD'.
#
# Dependencies: - requests: A library for making HTTP requests
#               - re: A library for working with regular expressions
#               - pandas: A library for data manipulation and analysis
#               - numpy: A library for numerical operations
#               - json: A library for working with JSON data
#
# Created by: Wil Wagner
# Created on: May 9, 2023
#
# Modified by:
# Modified on:
############################################################################################################

import requests
import re
import pandas as pd
import numpy as np
import json

def mstr_servers_status(server_type, environment='PRD'):

    env = environment.lower()
    if env not in ('prd', 'dev', 'uat'):
        raise ValueError("Invalid environment value. Allowed values are 'PRD', 'DEV', and 'UAT'.")

    api_url = f'https://api.libra.ops.corp.gq1.host_name.com:4443//v1.0/members/metrics/?vip=mstr{env}.fin.vip.corp.gq1.host_name.com&stale'
    arr = np.array(pd.DataFrame(requests.get(api_url).json()).to_numpy())

    if server_type.lower() in ('web1', 'web2', 'web'):
        port_number = 8000
    elif server_type.lower() in ('iserver1', 'iserver2', 'iserver'):
        port_number = 9080
    else:
        port_number = 0000

    for i in range(4):
        try:
            if arr[i][0]['real_port'] == port_number and (server_type.lower() in ('iserver', 'web') or bool(re.search('0' + server_type[-1], arr[i][0]['name']))):
                return [arr[i][0]['name'], arr[i][0]['status']]
                break
        except:
            return ['Error', 'Error']
