--------------------------------------------------------
-- DDL for View HHS_VW_ELIGQUAL_PROC
--  Modified by Taeho Lee on January 7th, 2019 
--  For user story #253961
--  Update 5 CMS Database Views in BizFlow database to return CMS process instances only
--------------------------------------------------------

CREATE OR REPLACE VIEW "BIZFLOW"."HHS_VW_ELIGQUAL_PROC"
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
        , CASE
            WHEN A.CMPLTDTIME IS NOT NULL THEN HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, A.CMPLTDTIME)
            ELSE HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, SYS_EXTRACT_UTC(SYSTIMESTAMP))
        END AS PROCESS_AGE  -- #11 Days to Complete (Process)
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Conduct Eligibility and Qualifications Review') AS CONDUCT_REVIEW_AGE -- #12 Days to Complete (Conduct Eligibility and Qualifications Review)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Conduct Eligibility and Qualifications Review'), 0) AS CONDUCT_REVIEW_COUNT -- #13 Completion Count (Conduct Eligibility and Qualifications Review) 
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Update the Request') AS UPDATE_REQUEST_AGE -- #14 Days to Complete (Update the Request)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Update the Request'), 0) AS UPDATE_REQUEST_COUNT -- #15 Completion Count (Update the Request) 
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Approve Candidate for Appointment') AS APRV_CANDIDATE_AGE -- #16 Days to Complete (Approve Candidate for Appointment)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Approve Candidate for Appointment'), 0) AS APRV_CANDIDATE_COUNT -- #17 Completion Count (Approve Candidate for Appointment) 
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Select Candidate for Appointment') AS SELECT_CANDIDATE_AGE -- #18 Days to Complete (Select Candidate for Appointment)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Select Candidate for Appointment'), 0) AS SELECT_CANDIDATE_COUNT -- #19 Completion Count (Select Candidate for Appointment) 
        , (
            SELECT W.PRTCPNAME 
            FROM ACT V INNER JOIN WITEM W ON W.PROCID = V.PROCID AND W.ACTSEQ = V.ACTSEQ 
            WHERE V.PROCID = A.PROCID AND V.NAME = 'Approve Candidate for Appointment' 
                AND ROWNUM <= 1
        ) AS DCO_MANAGER_NAME -- #20 Name of the DCO Manager who processed the approval step
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'adminCode')            AS V_ADMIN_CODE
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'cancelReason')         AS V_CANCEL_REASON
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestNum')           AS V_REQUEST_NUMBER
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestType')          AS V_REQUEST_TYPE
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'classificationType')   AS V_CLASSIFICATION_TYPE
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'ineligReason')         AS V_INELIG_REASON
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'disqualReason')        AS V_DISQ_REASON
    FROM
        PROCS A
        LEFT JOIN ACT B ON A.PROCID = B.PROCID AND B.STATE IN ('R', 'V', 'E') AND B.TYPE = 'P'
        LEFT JOIN WITEM C ON A.PROCID = C.PROCID AND B.ACTSEQ = C.ACTSEQ AND C.STATE IN ('I','V','E','P','R')
        JOIN PROCDEF PD ON PD.PROCDEFID = A.ORGPROCDEFID
        JOIN FLDRLIST FL ON FL.FLDRID = PD.FLDRID
    --WHERE A.PREPROCDEFNAME = 'Eligibility and Qualifications Review'
    WHERE PD.NAME = 'Eligibility and Qualifications Review'
      AND FL.NAME IN ('CMS')    
    ORDER BY A.PROCID    
/
