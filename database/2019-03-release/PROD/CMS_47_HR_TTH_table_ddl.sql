--=============================================================================
-- Time To Hire Pilot Weekly Data Table
--=============================================================================

--------------------------------------------
-- Backout statement
--------------------------------------------
/*
-- Time To Hire Pilot Weekly Data Table
DROP TABLE HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT;
*/

SET DEFINE OFF;

--------------------------------------------------------
-- DDL to alter Table CMS_TIME_TO_HIRE_WEEKLY_PILOT
--------------------------------------------------------
ALTER TABLE HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT
  ADD 
	(
	   ACTION_ACTIVE_PRIOR_STRAT_CON NUMBER(10), -- flag if Request_Status = 'Request Created' then 1 else 0
       ACHIEVED_STRAT_CON      NUMBER(10),
       ACHIEVED_CLASS          NUMBER(10),
       ACHIEVED_QUALS          NUMBER(10),
       ACHIEVED_SELECTION      NUMBER(10),
       OFFER_START             DATE,          
       OFFER_END               DATE, 
       ACHIEVED_OFFER          NUMBER(10),
       MISSED_OFFER          NUMBER(10)
	);