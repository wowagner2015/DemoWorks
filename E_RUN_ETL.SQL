  CREATE TABLE "FINDW"."E_RUN_ETL" 
   ("FILE_PRIV" VARCHAR2(11 BYTE), 
	  "FILE_LINKS" NUMBER, 
	  "FILE_OWNER" VARCHAR2(25 BYTE), 
	  "FILE_OWNER_GR" VARCHAR2(25 BYTE), 
  	"FILE_SZ" NUMBER, 
	  "FILE_MONTH" VARCHAR2(3 BYTE), 
	  "FILE_DAY" NUMBER, 
	  "FILE_TM" VARCHAR2(6 BYTE), 
	  "FILE_NM" VARCHAR2(128 BYTE)
   ) 
   ORGANIZATION EXTERNAL 
    ( TYPE ORACLE_LOADER
      DEFAULT DIRECTORY "ETL_SCRIPTS"
      ACCESS PARAMETERS
      ( Records Delimited By NewLine
           Preprocessor "ETL_SCRIPTS":'run_etl.sh'
           LOGFILE 'ETL_LOGS':'run_etl.log'
           Skip 1
           Fields Terminated By WhiteSpace ldrtrim 
                     )
      LOCATION
       ( "ETL_SCRIPTS":'run_etl.sh'
       )
    );
