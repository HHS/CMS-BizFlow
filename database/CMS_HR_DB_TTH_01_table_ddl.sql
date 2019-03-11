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
-- DDL for Table CMS_TIME_TO_HIRE_WEEKLY_PILOT
--------------------------------------------------------
CREATE TABLE HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT
(
	DATA_PULLED_ON        DATE,
	WEEK_OF               DATE,
	COMPONENT             VARCHAR2(151),
	REQUEST_NUMBER        VARCHAR2(20),
	PROCESS_ID            NUMBER(10),
	ACTION_ACTIVE_PRIOR_STRAT_CON NUMBER(10),
	STRAT_CON_START       DATE,
	STRAT_CON_END         DATE,
	ACHIEVED_STRAT_CON    NUMBER(10),
	MISSED_STRAT_CON      NUMBER(10),
	CLASS_START           DATE,
	CLASS_END             DATE,
	ACHIEVED_CLASS        NUMBER(10),
	MISSED_CLASS          NUMBER(10),
	QUALS_START           DATE,
	QUALS_END             DATE,
	ACHIEVED_QUALS        NUMBER(10),
	MISSED_QUALS          NUMBER(10),
	SELECTION_START       DATE,
	SELECTION_END         DATE,
	ACHIEVED_SELECTION    NUMBER(10),
	MISSED_SELECTION      NUMBER(10)
	OFFER_START           DATE,          
    OFFER_END             DATE, 
    ACHIEVED_OFFER        NUMBER(10),
    MISSED_OFFER          NUMBER(10)       
       
);

