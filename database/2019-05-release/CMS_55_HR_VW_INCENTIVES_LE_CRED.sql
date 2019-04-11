--------------------------------------------------------
--  DDL for View VW_INCENTIVES_LE_CRED
--------------------------------------------------------

CREATE OR REPLACE FORCE VIEW HHS_CMS_HR.VW_INCENTIVES_LE_CRED (
        PROC_ID
        ,SEQ_NUM
        ,START_DATE
        ,END_DATE
        ,WORK_SCHEDULE
        ,POS_TITLE
        ,CALCULATED_YEARS
        ,CALCULATED_MONTHS
        ,CREDITABLE_YEARS
        ,CREDITABLE_MONTHS 
  ) AS 
SELECT PROC_ID
        ,SEQ_NUM
        ,START_DATE
        ,END_DATE
        ,WORK_SCHEDULE
        ,POS_TITLE
        ,CALCULATED_YEARS
        ,CALCULATED_MONTHS
        ,CREDITABLE_YEARS
        ,CREDITABLE_MONTHS 
FROM HHS_CMS_HR.INCENTIVES_LE_CRED
;
