-- Set active 'Career Ladder Promotion Denial' and 'Administrative Leave' action
UPDATE HHS_CMS_HR.TBL_LOOKUP 
   SET TBL_ACTIVE = '1'
 WHERE TBL_ID IN (1794, 1796);
