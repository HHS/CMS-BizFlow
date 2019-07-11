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
        , HHS_FN_GETREQUESTDT(A.PROCID) AS REQUEST_DATE -- Request Date
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