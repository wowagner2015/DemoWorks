   CREATE TABLE EDW.E_MSTR_USERS_USER_GROUPS_CM
   ("USER_ID" VARCHAR2(4000 BYTE), 
	"ENABLED" VARCHAR2(4000 BYTE),
	"USER_GROUPS" VARCHAR2(4000 BYTE)    
   ) 
   ORGANIZATION EXTERNAL 
    ( TYPE ORACLE_LOADER
      DEFAULT DIRECTORY "EM"
      ACCESS PARAMETERS
      ( RECORDS DELIMITED BY NEWLINE 
      CHARACTERSET AL32UTF8
      STRING SIZES ARE IN CHARACTERS 
      BADFILE "ETL_LOGS":'User_Group_CM.txt' 
      DISCARDFILE "ETL_LOGS":'User_Group_CM.txt' 
      LOGFILE "ETL_LOGS":'User_Group_CM.txt'
 
      FIELDS TERMINATED BY ',' Optionally Enclosed By '"' LRTRIM 
      MISSING FIELD VALUES ARE NULL
      REJECT ROWS WITH ALL NULL FIELDS                            )
      LOCATION
       ( "EM":'Users_User_Groups_CM.csv'
       )
    )
   REJECT LIMIT UNLIMITED ;
