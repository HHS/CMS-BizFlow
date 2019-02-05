--BEGIN
--DBMS_SCHEDULER.DISABLE('IMPORT_TTH_WEEKLY_PILOT_DATA');
--END;
--/

----------------------------------------------------------------------------
--  Oracle Scheduler to Create Job to execute Package
----------------------------------------------------------------------------
----------------------------------------------------------------------------

--------------------------------------------------------
--  DDL for Job IMPORT_TTH_WEEKLY_PILOT_DATA
--------------------------------------------------------
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            JOB_NAME => '"HHS_CMS_HR"."IMPORT_TTH_WEEKLY_PILOT_DATA"',
            JOB_TYPE => 'STORED_PROCEDURE',
            JOB_ACTION => 'HHS_CMS_HR.CMS_TTH_WEEKLY_DATA_PKS.INSERT_CMS_TTH_WEEKLY_DATA',
            START_DATE => SYSTIMESTAMP,
            REPEAT_INTERVAL => 'FREQ=WEEKLY;BYDAY=FRI;BYHOUR=17;BYMINUTE=0;BYSECOND=0;',
            ENABLED => TRUE,
            COMMENTS => 'Run job every Friday at 5pm - Pull weekly data for TTH Pilot report');

 
END;

