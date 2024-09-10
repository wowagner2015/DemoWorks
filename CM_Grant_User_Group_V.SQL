/* Add users to User Groups based on ServiceNow (SNOW) request and existing MSTR User Groups
   CM Script Output Example:
   ALTER USER "wagnerw" FULLNAME "Will Wagner" FULLNAME "Will Wagner" DESCRIPTION "Costa Mesa - Business Intelligence Developer <CR>  
   Employee Hierarchy Access: Jim Fox > Alison Brie > Will Wagner" TRUSTEDLOGIN "wagnerw" ALLOWSTDAUTH FALSE IN GROUP "Finance - Procurement Users" ENABLED; */

CREATE OR REPLACE FORCE EDITIONABLE VIEW EDW.CM_Grant_User_Group_V (CM_Grant_User_Group) AS 
  Select 
Cast('ALTER USER "' || Trim(M.User_ID) || '" FULLNAME "' || Trim(M.Employee_Name_DESC) || 
     '" DESCRIPTION "' || SubStr(Trim(M.Employee_Title_Location_DESC) || ' ' || chr(10) || 
     'Employee Hierarchy Access: ' || Trim(Replace(M.Hierarchy_Names_DESC, '-->', '>')), 1, 248) ||
     '" TRUSTEDLOGIN "' || Trim(M.User_ID) || 
     '" ALLOWSTDAUTH FALSE IN GROUP "'|| Trim(SNOW.MSTR_User_Sub_Group) || '"  ENABLED;' As VarChar(4000))
     CM_Grant_User_Group
From
EDW.L_Employee_Hierarchy_Curr_V M
Join EDW.E_MSTR_USERS_V EM
On M.User_ID = EM.User_ID
Join EDW.F_SNOW_TASKS_ADD_USER_GROUP_V SNOW
on Trim(Lower(SNOW.User_id)) = M.USER_ID
Join EDW.E_MSTR_USER_GROUPS_V MSTR_USER_GROUPS
On Trim(SNOW.MSTR_User_Sub_Group) = Trim(MSTR_USER_GROUPS.User_Group)
Left Outer Join EDW.E_MSTR_USERS_USER_GROUPS_V Exist
On Trim(Lower(SNOW.User_id)) = Exist.User_ID
And Trim(SNOW.MSTR_User_Sub_Group) = Exist.User_Group
Where Exist.User_ID Is Null
And SNOW_Req_Processed <> 1;
