#!/bin/bash 
export PATH=/opt/bin:/usr/local/bin:/usr/contrib/bin:/bin:/usr/bin:/DW

ETLDir=/ETL/DW

SCRIPT_NM=`basename $0`
TS=`date +%Y%m%d%H%M%S`
LOG_FILE=$ETLDir/Logs/$SCRIPT_NM.$TS.log

GET_FTP_FILE=$ETLDir/Scripts/dw_pull_files.ksh
GET_NON_COMPLIANCE_FTP_FILE=$ETLDir/Scripts/dw_pull_files_non_compliance.ksh
GET_PENDING_APPROVAL_FTP_FILE=$ETLDir/Scripts/dw_pull_files_pending_approval.ksh

stdbuf -oL nohup sh -x $GET_FTP_FILE                &>> $LOG_FILE
stdbuf -oL nohup sh -x $GET_NON_COMPLIANCE_FTP_FILE &>> $LOG_FILE
stdbuf -oL nohup sh -x $GET_PENDING_APPROVAL_FTP_FILE &>> $LOG_FILE

ls $ETLDir/Data/Archive -a -l -X
