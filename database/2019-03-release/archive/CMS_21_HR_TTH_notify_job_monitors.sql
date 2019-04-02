--BEGIN
--DBMS_SCHEDULER.DISABLE('NOTIFY_JOB_MONITORS');
--END;
--/

----------------------------------------------------------------------------
--  Oracle Scheduler to Create Job to execute Procedure
----------------------------------------------------------------------------
----------------------------------------------------------------------------

--------------------------------------------------------
--  DDL for Job NOTIFY_JOB_MONITORS
--------------------------------------------------------
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            JOB_NAME => '"HHS_CMS_HR"."NOTIFY_JOB_MONITORS"',
            JOB_TYPE => 'STORED_PROCEDURE',
            JOB_ACTION => 'HHS_CMS_HR.CMS_TTH_WEEKLY_DATA_PKS.NOTIFY_JOB_MONITORS',
            START_DATE => SYSTIMESTAMP,
            REPEAT_INTERVAL => 'FREQ=WEEKLY;BYDAY=FRI;BYHOUR=17;BYMINUTE=10;BYSECOND=0;',
            ENABLED => TRUE,
            COMMENTS => 'Run job every Friday at 5:10 pm - Send email after IMPORT_TTH_WEEKLY_PILOT_DATA job runs');

 
END;

