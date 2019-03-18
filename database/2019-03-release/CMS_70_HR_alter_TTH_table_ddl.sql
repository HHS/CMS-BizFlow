--------------------------------------------------------
-- DDL to alter Table CMS_TIME_TO_HIRE_WEEKLY_PILOT
--------------------------------------------------------

ALTER TABLE HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT RENAME COLUMN OFFER_START TO TENT_OFFER_START;

ALTER TABLE HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT RENAME COLUMN OFFER_END TO TENT_OFFER_END;

ALTER TABLE HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT RENAME COLUMN ACHIEVED_OFFER TO ACHIEVED_TENT_OFFER;

ALTER TABLE HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT RENAME COLUMN MISSED_OFFER TO MISSED_TENT_OFFER;


ALTER TABLE HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT
  ADD 
	(
       OFCL_OFFER_START             DATE,          
       OFCL_OFFER_END               DATE, 
       ACHIEVED_OFCL_OFFER          NUMBER(10),
       MISSED_OFCL_OFFER            NUMBER(10)
	);
