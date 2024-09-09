Create Or Replace View EDW.CM_Process_SNOW_Req_V As 
Select CM_SNOW_Seq, CM_Process_SNOW_Req From (
Select 10000 + RowNum CM_SNOW_Seq, E.CM_Reenable_Inactive_Users CM_Process_SNOW_Req From EDW.CM_REENABLE_INACTIVE_USERS_V E
Union
Select 20000 + RowNum CM_SNOW_Seq, C.CM_Create_SNOW_Users CM_Process_SNOW_Req From EDW.CM_Create_SNOW_Users_V C
Union
Select 30000 + RowNum CM_SNOW_Seq, G.CM_Grant_User_Group CM_Process_SNOW_Req From EDW.CM_Grant_User_Group_V G) SNOW
Order by 1;
