/* CM Output Example: CREATE USER "wagnerw" FULLNAME "Will Wagner" DESCRIPTION "Costa Mesa - Business Intelligence Developer <CR>  
   Employee Hierarchy Access: Jim Fox > Alison Brie > Will Wagner" TRUSTEDLOGIN "wagnerw" ALLOWSTDAUTH FALSE ENABLED; */

CREATE OR REPLACE FORCE EDITIONABLE VIEW EDW.CM_CREATE_SNOW_USERS_V (CM_CREATE_SNOW_USERS) AS 
  Select 
Cast('CREATE USER "' || Trim(M.User_ID) || '" FULLNAME "' || Trim(M.Employee_Name_DESC) || 
     '" DESCRIPTION "' || SubStr(Trim(M.Employee_Title_Location_DESC) || ' ' || chr(10) || 
     'Employee Hierarchy Access: ' || Trim(Replace(M.Hierarchy_Names_DESC, '-->', '>')), 1, 248) ||
     '" TRUSTEDLOGIN "' || Trim(M.User_ID) || 
     '" ALLOWSTDAUTH FALSE ENABLED;' As VarChar(4000))
     CM_Create_SNOW_Users
From
EDW.L_Employee_Hierarchy_Curr_V M
Left Outer Join EDW.E_MSTR_USERS_V EM
On M.User_ID = EM.User_ID
Join (Select Distinct User_ID From EDW.F_SNOW_TASKS_V) SNOW
on Trim(Lower(SNOW.User_id)) = M.USER_ID
Where EM.User_ID Is Null;
