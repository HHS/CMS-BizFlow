UPDATE HHS_CMS_HR.TBL_LOOKUP 
   SET TBL_NAME = LTRIM(TBL_NAME) 
 WHERE TBL_ID = '1776';

-- Hide 'Career Ladder Promotion Denial' and 'Administrative Leave' action until May release
UPDATE HHS_CMS_HR.TBL_LOOKUP 
   SET TBL_ACTIVE = '0'
 WHERE TBL_ID IN (1794, 1796);
