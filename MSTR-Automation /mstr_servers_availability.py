import requests
import re
import pandas as pd
import numpy as np
import json

def mstr_servers_availability(server_type):

    arr=np.array(pd.DataFrame(requests.get('https://api.libra.ops.corp.gq1.yahoo.com:4443//v1.0/members/metrics/?vip=mstrprd.fin.vip.corp.gq1.yahoo.com&stale').json()).to_numpy())

    if server_type.lower() in ('web1','web2','web'):
        port_number=8000
    elif server_type.lower() in ('iserver1','iserver2','iserver'):
        port_number=9080
    else: port_number=0000

    for i in range(4):
        try:
            if arr[i][0]['real_port'] == port_number and arr[i][0]['status'] == 0 and (server_type.lower() in ('iserver','web') or bool(re.search('0' + server_type[-1], arr[i][0]['name']))):
                return arr[i][0]['name']
                break
        except: return 'Error'
