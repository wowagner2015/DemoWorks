#!/bin/ksh -x

cd "$(dirname "$0")"

EMAIL_LIST="wagnerw@yahooinc.com"

server=`python3 get_available_iserver.py`
echo $server

if [[ "$server" != "None" && "$server" != "Error" ]];
   then
   (echo "Server $server is up and running") |mailx  -r "business-systems-analytics@yahooinc.com" -s "Subject - $server is up and running" $EMAIL_LIST &>>/dev/null
   else
   mail -s "dwops@`hostname` : ALL Iservers are down" $EMAIL_LIST 2>/dev/null
fi
