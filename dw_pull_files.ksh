#!/bin/ksh -x

LOG_DIR=/ETL/DW/Logs
FILE_DIR=/ETL/DW/Data
SCRIPTS_DIR=/ETL/DW/Scripts

ARCHIVE_FILE_DIR=/ETL/DW/Data/Archive
EMAIL_LIST=prod@company.com

SCRIPT_NM=`basename $0`
TS=`date +%Y%m%d%H%M%S`
LOG_FILE=$LOG_DIR/$SCRIPT_NM.$TS

sftpHost=us2.expense.com
sftpUser=expense-01
sftpPath=out
sftpFileSuffix=Approved_Expenses_By_Sent_for_Payment_Date__
sftpConnect='sftp '$sftpUser'@'$sftpHost':'$sftpPath
sftpArchivePath=dw/dw_archive

# Write the Job Description and startDate to the LogFile
startDate=`date -d "0 days ago" '+%Y-%m-%d'`
echo $startDate >> $LOG_FILE

extract_oldest_file=$(echo "ls -tr1" | $sftpConnect | grep $sftpFileSuffix | head -1)
extract_latest_file=$(echo "ls -t1" | $sftpConnect | grep $sftpFileSuffix | head -1)

echo $LOG_FILE  >> "$LOG_FILE"
sleep_time=3

echo 'extract_oldest_file:' $extract_oldest_file   >> $LOG_FILE
echo 'extract_latest_file:' $extract_latest_file   >> $LOG_FILE

   echo 'Start Time: ' `date` >> "$LOG_FILE"

   if [[($extract_oldest_file == '')]]
      then
          echo 'Couldn''''t retrieve file name from FTP site' >> "$LOG_FILE"
      else
          echo 'extract_oldest_file: ' $extract_oldest_file >> "$LOG_FILE"
          echo 'extract_latest_file: ' $extract_latest_file >> "$LOG_FILE"

##########################################################################
#  Transfer oldest file from Remote server to local Inbox folder
##########################################################################

   i=0
   current_output_before=''
   start=$SECONDS

   until [[(($current_output_before != '') && ($current_output_before == $current_output_after)) || ($(($i*$sleep_time)) -gt 1080)]]
   do
     current_output_before=$current_output_after

     current_output_after=$(echo "ls -lt" | $sftpConnect | grep $extract_oldest_file)

     if [[ $i -gt 0 ]]
        then
            echo ' Date: ' `date`  >> "$LOG_FILE"
            echo 'Before ' $i ' ' $current_output_before >> "$LOG_FILE"
            echo 'After  ' $i ' ' $current_output_after  >> "$LOG_FILE"
     fi

     sleep $sleep_time
     ((i++))
   done

   echo 'FTP $(($i*$sleep_time))  Duration: ' $(($i*$sleep_time)) 'seconds' >> "$LOG_FILE"
   echo 'FTP $((SECONDS - start)) Duration: ' $((SECONDS - start)) 'seconds' >> "$LOG_FILE"

##########################################################################

cd $FILE_DIR
current_output_after=$(echo "get $extract_oldest_file" | $sftpConnect | grep $extract_oldest_file)
echo 'SFTP transfer of ' $extract_oldest_file ' file is done ' $current_output_after  >> "$LOG_FILE"

   echo 'Start ' $FILE_DIR/$extract_oldest_file ' file decryption'  >> "$LOG_FILE"

   gpg --homedir /home/`whoami`/.gnupg -v --batch --yes --output $FILE_DIR/Decrypted_Zipped_File.csv.zip $FILE_DIR/$extract_oldest_file   >> "$LOG_FILE"

   echo 'File ' $FILE_DIR/$extract_oldest_file decrypted to $FILE_DIR/Decrypted_Zipped_File.csv.zip  >> "$LOG_FILE"

   echo 'Start unzipping ' $FILE_DIR/Decrypted_Zipped_File.csv.zip  >> "$LOG_FILE"
   unzip -o $FILE_DIR/Decrypted_Zipped_File.csv.zip -d $FILE_DIR >> "$LOG_FILE"
   echo 'File unzipped to "'$FILE_DIR/'Approved Expenses (By Sent for Payment Date).csv"'  >> "$LOG_FILE"

   iconv -f utf-16 -t utf-8 "$FILE_DIR/Approved Expenses (By Sent for Payment Date).csv" | sed 's/\,[[:digit:]][[:digit:]][[:digit:]]*\,[^ ]*\r/&<br>~~|~~<\/br>/g' > "$FILE_DIR/Approved_Expenses_External_Table.csv"

   fi

cnt=`ls -l "$FILE_DIR/Approved_Expenses_External_Table.csv"|wc -l`
echo $cnt    >> "$LOG_FILE"

if [[ $cnt -eq 0 ]]
then
 echo "-- File not found in target dir. Pull Failed.. " >> $LOG_FILE
 exit 1
else
 echo "-- File found in target dir. Pull Successful.. " >> $LOG_FILE

fi

status=$?
echo 'Transfer Status: ' $status  >> "$LOG_FILE"

#Notify file transfer status
if [[ status -ne 0 ]]
then
  cat $LOG_FILE |mail -s "dwops@`hostname` : File transfer: FAILED" $EMAIL_LIST
else
  echo "*** File Pull - Completed ***" >> $LOG_FILE

  echo "File transfer done file created. " >> $LOG_FILE

# File archiving - Copying into /Data/Archive Linux folder and /dw/dw_archive FTP folder
cp $FILE_DIR/Approved_Expenses_External_Table.csv $ARCHIVE_FILE_DIR/$sftpFileSuffix`echo $extract_oldest_file | sed -e s/[^0-9]//g`.csv

(echo "Archiving $extract_oldest_file file into /dw/dw_archive Concur FTP folder") |mailx  -r "user_name@company.com" -s "Archiving $(echo "rename $extract_oldest_file /dw/dw_archive/$extract_oldest_file" | $sftpConnect | grep $extract_oldest_file)" wagnerw@oath.com
fi

echo ' ' >> "$LOG_FILE"
echo 'End Time: ' `date` >> "$LOG_FILE"
echo ' ' >> "$LOG_FILE"
echo '**** The End of FTP File Extract *****' >> "$LOG_FILE"
mv "$LOG_FILE" $LOG_FILE-`echo $extract_oldest_file | sed -e s/[^0-9]//g`.log
### exit $status
