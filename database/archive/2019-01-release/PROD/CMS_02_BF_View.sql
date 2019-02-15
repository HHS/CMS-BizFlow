-- CMS_36_BF_HHS_VW_PROCESS.sql
-- CMS_41_BF_HHS_VW_CLASSIFICATION.sql
-- CMS_42_BF_HHS_VW_CONSULTATION.sql
-- CMS_43_BF_HHW_VW_ELIGQUAL_PROC.sql
-- CMS_44_BF_HHS_VW_WORKITEM.sql

--------------------------------------------------------
-- DDL for View HHS_VW_PROCESS
--  Modified by Taeho Lee on January 7th, 2019 
--  For user story #253961
--  Update 5 CMS Database Views in BizFlow database to return CMS process instances only
--------------------------------------------------------

CREATE OR REPLACE VIEW "BIZFLOW"."HHS_VW_PROCESS"
AS
    SELECT
        A.PROCID                      AS PROCESS_ID
        , HHS_FN_GET_RPTLOOKUPVAL('procs.state', A.STATE) AS STATE_LABEL
        , A.STATE                     AS STATE
        , A.CMNTCNT                   AS COMMENT_COUNT
        , A.ATTACHCNT                 AS ATTACHMENT_COUNT
        , A.NAME                      AS NAME
        , A.CREATIONDTIME             AS CREATION_DATE
        , A.CREATOR                   AS CREATOR_ID
        , A.CREATORNAME               AS CREATOR_NAME
        , A.CMPLTDTIME                AS COMPLETION_DATE
        , A.PARENTPROCID              AS PARENT_PROCESS_ID
        , B.NAME                      AS PARENT_PROCESS_NAME
        , A.PARENTACTSEQ              AS PARENT_ACTIVITY_ID
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestNum') AS V_REQUEST_NUMBER
        , HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, A.CMPLTDTIME) AS COMPLETION_DURATION
    FROM
        PROCS A
        LEFT JOIN PROCS B ON A.PARENTPROCID = B.PROCID
        JOIN PROCDEF PD ON PD.PROCDEFID = A.ORGPROCDEFID
        JOIN FLDRLIST FL ON FL.FLDRID = PD.FLDRID
    WHERE FL.NAME IN ('CMS')         
/

--------------------------------------------------------
-- DDL for View HHS_VW_CLASSIFICATION_PROC
--  Modified by Taeho Lee on January 7th, 2019 
--  For user story #253961
--  Update 5 CMS Database Views in BizFlow database to return CMS process instances only
--------------------------------------------------------

CREATE OR REPLACE VIEW "BIZFLOW"."HHS_VW_CLASSIFICATION_PROC" 
AS
    SELECT
        A.PROCID                      AS PROCESS_ID
        , HHS_FN_GET_RPTLOOKUPVAL('procs.state', A.STATE) AS PROCESS_STATE_DESC
        , A.STATE                     AS PROCESS_STATE -- #1 State
        , A.NAME                      AS PROCESS_NAME -- #2 Name
        , A.CREATIONDTIME             AS PROCESS_CREATION_DATE -- #3 Create DATE
        , A.CREATOR                   AS PROCESS_CREATOR_ID
        , A.CREATORNAME               AS PROCESS_CREATOR_NAME -- #4 Initiator Name
        , B.NAME                      AS CURRENT_ACTIVITY_NAME -- #5 Current Step
        , C.PRTCPNAME                 AS CURRENT_USER_NAME
        , C.PRTCP                     AS CURRENT_USER_ID -- #6 Current Participant
        , FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestStatus') AS REQUEST_STATUS -- #7 Current Status
        , TO_DATE(REPLACE(FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'D', 'requestStatusDate'), 'T', ' '),  'YYYY-MM-DD HH24:MI:SS') AS REQUEST_STATUS_DATE -- #8 Current State DATE
        , HHS_FN_GET_BUSDAYSDIFF(TO_DATE(REPLACE(FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'D', 'requestStatusDate'), 'T', ' '),  'YYYY-MM-DD HH24:MI:SS'), SYSDATE) AS REQUEST_STATUS_AGE -- #9. Current State Age
        , A.CMPLTDTIME                AS PROCESS_COMPLETION_DATE -- #10 Complete DATE
        --, HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, A.CMPLTDTIME) AS PROCESS_AGE -- #11 Days to Complete (Process)
        , CASE
            WHEN A.CMPLTDTIME IS NOT NULL THEN HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, A.CMPLTDTIME)
            ELSE HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, SYS_EXTRACT_UTC(SYSTIMESTAMP))
        END AS PROCESS_AGE
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Complete PD Coversheet AND Classification Analysis') AS COMPLETE_PD_COVERSHEET_AGE -- #12 Days to Complete (Complete PD Coversheet AND Classification Analysis)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Complete PD Coversheet AND Classification Analysis'), 0) AS COMPLETE_PD_COVERSHEET_COUNT -- #13
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Confirm Classification Analysis') AS CONFIRM_ANALYSIS_AGE -- #14 Days to Complete (Confirm Classification Analysis)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Confirm Classification Analysis'), 0) AS CONFIRM_ANALYSIS_COUNT -- #15
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Confirm BUS Code') AS CONFIRM_BUS_CODE_AGE -- #16 Days to Complete (Confirm BUS code)
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Review DWC Entry') AS REVIEW_DWC_ENTRY_AGE -- #17 Days to Complete (Confirm Classification Analysis)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Review DWC Entry'), 0) AS REVIEW_DWC_ENTRY_COUNT -- #18 Completion count
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Approve PD Coversheet - SO') AS APPROVE_PD_COVERSHEET_AGE -- #19 Days to Complete (Approve PD Coversheet)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Approve PD Coversheet - SO'), 0) AS APPROVE_PD_COVERSHEET_COUNT -- #20 Completion count
        , HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Approve Coversheet AND Create Final Pkg') AS CREATE_FINAL_PKG_AGE -- #21 Days to Complete (Approve Coversheet AND Create Final Pkg)
        , NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Approve Coversheet AND Create Final Pkg'), 0) AS CREATE_FINAL_PKG_COUNT -- #22 Completion count
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
    --WHERE A.PREPROCDEFNAME = 'Classification'
    WHERE PD.NAME = 'Classification'
      AND FL.NAME IN ('CMS')
    ORDER BY A.PROCID
/

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
        JOIN FLDRLIST FL ON FL.FLDRID = A.INSTFLDRID
   WHERE A.PREPROCDEFNAME = 'Eligibility and Qualifications Review'
      AND FL.NAME IN ('CMS')    
    ORDER BY A.PROCID    
/

--------------------------------------------------------
-- DDL for View HHS_VW_WORKITEM
--  Modified by Taeho Lee on January 7th, 2019 
--  For user story #253961
--  Update 5 CMS Database Views in BizFlow database to return CMS process instances only
--------------------------------------------------------

CREATE OR REPLACE VIEW "BIZFLOW"."HHS_VW_WORKITEM" 
AS 
    SELECT
        C.PROCID                      AS PROCESS_ID
        , C.WITEMSEQ                  AS WORKITEM_ID
        , HHS_FN_GET_RPTLOOKUPVAL('witem.prtcptype', C.PRTCPTYPE) AS PARTICIPANT_TYPE
        , HHS_FN_GET_RPTLOOKUPVAL('witem.state', C.STATE) AS STATE_LABEL
        , C.STATE                     AS STATE
        , C.ACTSEQ                    AS ACTIVITY_ID
        , C.PRTCP                     AS PARTICIPANT_ID
        , C.PRTCPNAME                 AS PARTICIPANT_NAME
        , C.CMPLTUSR                  AS COMPLETER_ID
        , C.CMPLTUSRNAME              AS COMPLETER_NAME
        , C.CREATIONDTIME             AS CREATION_DATE
        , C.STARTDTIME                AS START_DATE
        , C.CMPLTDTIME                AS COMPLETION_DATE
        , ''                          AS COMPLETION_DURATION
    FROM WITEM C
        JOIN PROCS A ON A.PROCID = C.PROCID
        JOIN PROCDEF PD ON PD.PROCDEFID = A.ORGPROCDEFID
        JOIN FLDRLIST FL ON FL.FLDRID = PD.FLDRID
    --WHERE C.ONASYNC = 'F'
    WHERE FL.NAME IN ('CMS')
      AND C.ONASYNC = 'F'
/




