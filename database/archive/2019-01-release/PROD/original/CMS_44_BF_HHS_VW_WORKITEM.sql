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
