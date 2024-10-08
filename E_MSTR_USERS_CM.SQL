  CREATE TABLE EDW.E_MSTR_USERS_CM 
   ("USER_ID" VARCHAR2(4000 BYTE), 
	  "EMPLOYEE_NAME_DESC" VARCHAR2(4000 BYTE), 
  	"ENABLED" VARCHAR2(4000 BYTE)
   ) 
   ORGANIZATION EXTERNAL 
    ( TYPE ORACLE_LOADER
      DEFAULT DIRECTORY "ETL"
      ACCESS PARAMETERS
      ( RECORDS DELIMITED BY NEWLINE 
      CHARACTERSET AL32UTF8
      STRING SIZES ARE IN CHARACTERS 
      BADFILE "ETL_LOGS":'User_Info_Bad.txt' 
      DISCARDFILE "ETL_LOGS":'User_Info_Discard.txt' 
      LOGFILE "ETL_LOGS":'User_Info_Log.txt'

      FIELDS TERMINATED BY ',' Optionally Enclosed By '"' LRTRIM 
      MISSING FIELD VALUES ARE NULL
      REJECT ROWS WITH ALL NULL FIELDS                                )
      LOCATION
       ( "ETL":'User_CM.csv'
       )
    )
   REJECT LIMIT UNLIMITED ;
