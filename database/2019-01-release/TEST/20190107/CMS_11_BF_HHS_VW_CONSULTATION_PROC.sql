--------------------------------------------------------
-- DDL for View HHS_VW_CONSULTATION_PROC
--  Modified by Taeho Lee on January 7th, 2019 
--  For user story #253961
--  Update 5 CMS Database Views in BizFlow database to return CMS process instances only
--------------------------------------------------------

CREATE OR REPLACE VIEW "BIZFLOW"."HHS_VW_CONSULTATION_PROC" 
AS
    SELECT
        A.PROCID                      AS PROCESS_ID
        , HHS_FN_GET_RPTLOOKUPVAL('procs.state', A.STATE) AS PROCESS_STATE_DESC
        , A.STATE                     AS PROCESS_STATE         -- #1 State
        , A.NAME                      AS PROCESS_NAME          -- #2 Name
        , A.CREATIONDTIME             AS PROCESS_CREATION_DATE -- #3 Create DATE
        , A.CREATOR                   AS PROCESS_CREATOR_ID
        , A.CREATORNAME               AS PROCESS_CREATOR_NAME  -- #4 Initiator Name
        , B.NAME                      AS CURRENT_ACTIVITY_NAME -- #5 Current Step
        , C.PRTCPNAME                 AS CURRENT_USER_NAME
        , C.PRTCP                     AS CURRENT_USER_ID       -- #6 Current Participant
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestStatus') AS REQUEST_STATUS -- #7 Current Status
        , TO_DATE(REPLACE(FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'D', 'requestStatusDate'), 'T', ' '),  'YYYY-MM-DD HH24:MI:SS') AS REQUEST_STATUS_DATE -- #8 Current State DATE
        , HHS_FN_GET_BUSDAYSDIFF(TO_DATE(REPLACE(FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'D', 'requestStatusDate'), 'T', ' '),  'YYYY-MM-DD HH24:MI:SS'), SYSDATE) AS REQUEST_STATUS_AGE -- #9. Current State Age
        , A.CMPLTDTIME                AS PROCESS_COMPLETION_DATE -- #10 Complete DATE
        --, HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, A.CMPLTDTIME) AS PROCESS_AGE -- #11 Days to Complete (Process)
        , CASE
            WHEN A.CMPLTDTIME IS NOT NULL THEN HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, A.CMPLTDTIME)
            ELSE HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, SYS_EXTRACT_UTC(SYSTIMESTAMP))
        END AS PROCESS_AGE
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Create Request') AS CREATE_REQUEST_AGE -- #13 Days to Complete (Create Request - Accumulated days)
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Review Request') AS REVIEW_REQUEST_AGE -- #13 Days to Complete (Review Request - Accumulated days)
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Modify Request') AS MODIFY_REQUEST_AGE -- #13 Days to Complete (Modify Request - Accumulated days)
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Hold Strategic Consultation Meeting') AS HOLD_MEETING_AGE -- #13 Days to Complete (Hold Strategic Consultation Meeting - Accumulated days)
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Acknowledge Strat Cons Meeting') AS ACK_MEETING_AGE -- #14 Days to Complete (Acknowledge Strat Cons Meeting - Accumulated days)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Acknowledge Strat Cons Meeting'), 0) AS ACK_MEETING_COMPLETION_COUNT
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Approve Strat Cons Meeting') AS APRV_MEETING_AGE -- #16 Days to Complete (Approve Strat Cons Meeting - Accumulated days)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Approve Strat Cons Meeting'), 0) AS APRV_MEETING_COMPLETION_COUNT
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'adminCode') AS V_ADMIN_CODE
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'cancelReason') AS V_CANCEL_REASON
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestNum') AS V_REQUEST_NUMBER
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestType') AS V_REQUEST_TYPE
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'classificationType') AS V_CLASSIFICATION_TYPE
    FROM
        PROCS A
        LEFT JOIN ACT B ON A.PROCID = B.PROCID AND B.STATE IN ('R', 'V', 'E') AND B.TYPE = 'P'
        LEFT JOIN WITEM C ON A.PROCID = C.PROCID AND B.ACTSEQ = C.ACTSEQ AND C.STATE IN ('I','V','E','P','R')
        JOIN PROCDEF PD ON PD.PROCDEFID = A.ORGPROCDEFID
        JOIN FLDRLIST FL ON FL.FLDRID = PD.FLDRID
    --WHERE A.PREPROCDEFNAME = 'Strategic Consultation'
    WHERE PD.NAME = 'Strategic Consultation'
      AND FL.NAME IN ('CMS')    
    ORDER BY A.PROCID
/
