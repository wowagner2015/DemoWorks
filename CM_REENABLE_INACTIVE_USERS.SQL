-- Reenable inactive MicroStrategy users
CREATE OR REPLACE FORCE EDITIONABLE VIEW "EDW".CM_REENABLE_INACTIVE_USERS_V ("CM_REENABLE_INACTIVE_USERS") AS 
Select Distinct 'ALTER USER "' || Trim(EM.User_ID) || '" ENABLED;' CM_Reenable_Inactive_Users
From (Select Distinct User_ID From FINDW_RO.F_SNOW_TASKS_V Where To_Char(SNOW_Closed_Date, 'YYYY-MM-DD') = '9999-12-31' And MSTR_Processed_Date Is Null) SNOW
Join "FINDW_RO"."E_MSTR_USERS_V" EM   
On SNOW.User_ID = EM.User_ID
And EM.ENABLED = 0
Join FINDW_RO.L_Employee_Hierarchy_Curr_V EH
On SNOW.User_ID = EH.User_ID
Join "FINDW"."R_SNOW_MODULE_USER_GROUP" SM
On SM.SNOW_MODULE In (Select Distinct SNOW_MODULE From FINDW_RO.F_SNOW_TASKS_V SMT Where To_Char(SNOW_Closed_Date, 'YYYY-MM-DD') = '9999-12-31' And MSTR_Processed_Date Is Null And SMT.User_ID = EM.User_ID);
