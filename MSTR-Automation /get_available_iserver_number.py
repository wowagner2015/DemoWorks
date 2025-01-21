import mstr_servers_availability as sc
import re

try:

    server = sc.mstr_servers_availability('IServer')

    if bool(re.search('01', server)):
       print('1')
    elif bool(re.search('02', server)):
       print('2')
    else: print('0')

except: print('0')
