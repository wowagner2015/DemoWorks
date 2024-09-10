#!/bin/bash
export PATH=/opt/bin:/usr/local/bin:/usr/contrib/bin:/bin:/usr/bin:/usr/local/bin/perl
## By Will Wagner
## Run MicroStrategy Triggers
## This script triggers MicroStrategy Command Manager's events that are passed as parameters
## Command and Parameters: ./run_mstr_trigger.sh '<MSTR Event>' '<YYYY-MM-DD-HH-MI>'
############################################################################################################################## 

TRIGGER=$1
DATE_STAMP=${2:-`date '+%Y-%m-%d-%H-%M'`}

SCRIPT_DIR=/DataMarts
LOG_FILE=$SCRIPT_DIR/Logs/$SCRIPT_$DATE_STAMP.log

LOGPATH="/DataMarts/Logs/" # log location for Command Manager scripts
LOGNAME="cm_automation"_"$DATE_STAMP.log"

PASS="`ckms-remotecli -tlscert /path/to/cert.pem -tlskey /path/to/key.pem -group group_name -key group_name.mstr.trigger.password -env env_name 2>/dev/null`"

MSTRCMDDIR="/path/to/mstr/bin" # Path to MicroStrategy Command Manager
CMDMGR="mstrcmdmgr" # MicroStrategy Command Manager
MSTR_USER="mstr_user"
PROJECT_SOURCE="ProjectSource"

TRIGGER_FILE=`echo $TRIGGER | sed 's/ /_/g'`.scp
echo 'TRIGGER EVENT "'$TRIGGER'";' > "$SCRIPT_DIR/$TRIGGER_FILE"

## Preprocessor (Gets all users from Enterprise Manager report and copies them into User_Info.csv file)
CMDMGR_RUN=$CMDMGR" -n "$PROJECT_SOURCE" -u "$MSTR_USER" -p "$PASS" -f "$SCRIPT_DIR/$TRIGGER_FILE" -o "$LOGPATH$LOGNAME
echo '###################' $TRIGGER '###################' >> $LOGPATH$LOGNAME

## Change current directory to MicroStrategy Command Manager
cd $MSTRCMDDIR                                              > /dev/null

echo '#####' $CMDMGR_RUN '#################' >> $LOG_FILE
## Run scp file using MicroStrategy Command Manager
stdbuf -oL nohup sh -x $CMDMGR_RUN                          &>> $LOG_FILE
sleep 7
