Create Or Replace Procedure SP_GET_DATA
AS
BEGIN
Merge into findw.W_Run_ETL_Log t
  using
  (select *
   from findw.E_Run_ETL) s
  on (t.FILE_NM = s.FILE_NM)
  When matched then
     Update set t.FILE_PRIV     = s.FILE_PRIV
              , t.FILE_LINKS    = s.FILE_LINKS
              , t.FILE_OWNER    = s.FILE_OWNER
              , t.FILE_OWNER_GR = s.FILE_OWNER_GR
              , t.FILE_SZ       = s.FILE_SZ
              , t.FILE_MONTH    = s.FILE_MONTH
              , t.FILE_DAY      = s.FILE_DAY
              , t.FILE_TM       = s.FILE_TM              
  When not matched then
     Insert (t.FILE_PRIV, t.FILE_LINKS, t.FILE_OWNER, t.FILE_OWNER_GR, t.FILE_SZ, t.FILE_MONTH, t.FILE_DAY, t.FILE_TM, t.FILE_NM)
     Values (s.FILE_PRIV, s.FILE_LINKS, s.FILE_OWNER, s.FILE_OWNER_GR, s.FILE_SZ, s.FILE_MONTH, s.FILE_DAY, s.FILE_TM, s.FILE_NM);
 
   Commit;
END;
