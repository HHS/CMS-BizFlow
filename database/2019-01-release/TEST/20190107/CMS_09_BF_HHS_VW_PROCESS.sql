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




