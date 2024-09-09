create or replace Procedure SP_Update_SNOW_TASKS_MSTR_PROC
    As
    Begin 
    Merge Into EDW.F_SNOW_TASKS SNOW
       Using 
       (Select SNOW.Task_Number, MSTR_User_Recon.User_ID, MSTR_Groups.Close_Notes
                  From EDW.F_SNOW_MSTR_EM_User_Recon_V MSTR_User_Recon
                  Join
                  (Select Task_Number, User_ID, Full_Name,
                    'Hello ' || Full_Name || ',' || chr(10) || chr(10) || 'Your access to Finance MicroStrategy has been processed.' || chr(10) || 'User "' || User_ID || '" created/modified with the following access: ' || Trim(LISTAGG(MSTR_USer_Group, ', ') Within Group (Order By MSTR_USer_Group)) || chr(10) || 'Please attempt to access Finance MicroStrategy by using the link yo/bi.' || chr(10) || 'If you discover that you are still encountering any issues, or have other questions, please submit a ticket using the link yo/corpbiticket.' || chr(10) || chr(10) || 'Thank you for letting us serve you.' || chr(10) || 'Corp Apps BI Team.'                   
                     As Close_Notes
                    From EDW.F_SNOW_MSTR_EM_RECON_V 
                    Group By Task_Number, User_ID, Full_Name
                    ) MSTR_Groups
                    On  MSTR_User_Recon.Task_Number = MSTR_Groups.Task_Number
                    And MSTR_User_Recon.User_ID     = MSTR_Groups.User_ID
                  Join EDW.F_SNOW_TASKS SNOW
                    On MSTR_Groups.Task_Number = SNOW.Task_Number
                    Where MSTR_User_Recon.Enabled = 1 And MSTR_User_Recon.SNOW_and_MSTR_Insync = 1 And SNOW.MSTR_PROCESSED_DATE Is Null) 
       Recon
       On (SNOW.Task_Number = Recon.Task_Number
       And SubStr(SNOW.REQ_DISPLAY_VALUE, INSTR(SNOW.REQ_DISPLAY_VALUE, '(') + 1, Length(SNOW.REQ_DISPLAY_VALUE) - INSTR(SNOW.REQ_DISPLAY_VALUE, '(') - 1) = Recon.User_ID)
    When Matched 
       Then Update 
            Set SNOW.MSTR_PROCESSED_DATE = SysDate, 
                SNOW.Close_Notes = Recon.Close_Notes;              
       Commit;
    End; 
                   
Grant Execute On SP_UPDATE_SNOW_TASKS_MSTR_PROC To EDW;
