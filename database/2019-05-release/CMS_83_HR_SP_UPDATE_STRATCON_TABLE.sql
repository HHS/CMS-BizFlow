create or replace PROCEDURE SP_UPDATE_STRATCON_TABLE
  (
    I_PROCID            IN      NUMBER
  )
IS
  V_JOB_REQ_ID                NUMBER(20);
  V_JOB_REQ_NUM               NVARCHAR2(50);
  V_CLOBVALUE                 CLOB;
  V_VALUE                     NVARCHAR2(4000);
  V_VALUE_LOOKUP              NVARCHAR2(2000);
  V_REC_CNT                   NUMBER(10);
  --V_SSH_ID                    NUMBER(10);
  V_XMLDOC                    XMLTYPE;
  V_XMLVALUE                  XMLTYPE;
  --V_ISMODIFIED                NUMBER(1);
  --V_ISRESCHEDULED             NUMBER(1);
  V_ERRCODE                   NUMBER(10);
  V_ERRMSG                    VARCHAR2(512);
    E_INVALID_PROCID            EXCEPTION;
    E_INVALID_JOB_REQ_ID        EXCEPTION;
PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
    E_INVALID_STRATCON_DATA     EXCEPTION;
PRAGMA EXCEPTION_INIT(E_INVALID_STRATCON_DATA, -20905);
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_STRATCON_TABLE - BEGIN ============================');
    --DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
    --DBMS_OUTPUT.PUT_LINE(' ----------------');


    IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
      ------------------------------------------------------
      -- Transfer XML data into operational table
      --
      -- 1. Get Job Request Number
      -- 1.1 Select it from data xml from TBL_FORM_DTL table.
      -- 1.2 If not found, select it from BIZFLOW.RLVNTDATA table.
      -- 2. If Job Request Number not found in REQUEST table, insert record and get the ID.
      -- 3. For each target table,
      -- 3.1. If record found for the REQ_ID, update record.
      -- 3.2. If record not found for the REQ_ID, insert record.
      ------------------------------------------------------
      --DBMS_OUTPUT.PUT_LINE('Starting xml data retrieval and table update ----------');

      --------------------------------
      -- get Job Request Number
      --------------------------------
      BEGIN
        SELECT XMLQUERY('/DOCUMENT/PROCESS_VARIABLE/requestNum/text()'
                        PASSING FD.FIELD_DATA RETURNING CONTENT).GETSTRINGVAL()
          , FD.FIELD_DATA
        INTO V_JOB_REQ_NUM, V_XMLDOC
        FROM TBL_FORM_DTL FD
        WHERE FD.PROCID = I_PROCID;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN V_JOB_REQ_NUM := NULL;
      END;

      --DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (from xml) = ' || V_JOB_REQ_NUM);
      IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
        BEGIN
          SELECT VALUE
          INTO V_JOB_REQ_NUM
          FROM BIZFLOW.RLVNTDATA
          WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'requestNum';
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_JOB_REQ_NUM := NULL;
          RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_STRATCON_TABLE: Job Request Number is invalid.  I_PROCID = '
                                          || TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
        END;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (after pv check) = ' || V_JOB_REQ_NUM);
      IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
        RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_STRATCON_TABLE: Job Request Number is invalid.  I_PROCID = '
                                        || TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
      END IF;

      --------------------------------
      -- REQUEST table
      --------------------------------
      --DBMS_OUTPUT.PUT_LINE('    REQUEST table');
      BEGIN
        SELECT REQ_ID INTO V_JOB_REQ_ID
        FROM REQUEST
        WHERE REQ_JOB_REQ_NUMBER = V_JOB_REQ_NUM;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN V_JOB_REQ_ID := NULL;
      END;

      --DBMS_OUTPUT.PUT_LINE('        V_JOB_REQ_ID before = ' || V_JOB_REQ_ID);

      IF V_JOB_REQ_ID IS NULL THEN
        INSERT INTO REQUEST	(REQ_JOB_REQ_NUMBER, REQ_JOB_REQ_CREATE_DT)
        VALUES (V_JOB_REQ_NUM, SYSDATE)
        RETURN REQ_ID INTO V_JOB_REQ_ID;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('        V_JOB_REQ_ID after = ' || V_JOB_REQ_ID);
      IF V_JOB_REQ_ID IS NULL THEN
        RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_STRATCON_TABLE: Job Request ID is invalid.  I_PROCID = '
                                        || TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
      END IF;

      BEGIN
        --------------------------------
        -- REQUEST table update for cancellation
        --------------------------------
        MERGE INTO REQUEST TRG
        USING
          (
            SELECT
                V_JOB_REQ_ID AS REQ_ID
              , V_JOB_REQ_NUM AS REQ_JOB_REQ_NUMBER
              , X.REQ_CANCEL_DT_STR
              , TO_DATE(X.REQ_CANCEL_DT_STR, 'YYYY/MM/DD HH24:MI:SS') AS REQ_CANCEL_DT
              , X.REQ_CANCEL_REASON
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/PROCESS_VARIABLE'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         REQ_CANCEL_DT_STR                   NVARCHAR2(30)   PATH 'if (requestStatus/text() = "Request Cancelled") then requestStatusDate else ""'
              , REQ_CANCEL_REASON                 NVARCHAR2(140)  PATH 'cancelReason'
                ) X
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.REQ_ID = TRG.REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.REQ_CANCEL_DT           = SRC.REQ_CANCEL_DT
          , TRG.REQ_CANCEL_REASON     = SRC.REQ_CANCEL_REASON
        ;
      END;


      BEGIN

        --------------------------------
        -- STRATCON_GEN table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    STRATCON_GEN table');
        MERGE INTO STRATCON_GEN TRG
        USING
          (
            SELECT
                V_JOB_REQ_ID AS SG_REQ_ID
              , I_PROCID AS SG_PROCID
              , X.SG_AC_ID
              , X.SG_ADMIN_CD
              , X.SG_RT_ID
              , X.SG_CT_ID
              , X.SG_AT_ID
              , X.SG_VT_ID
              , X.SG_SAT_ID
              , X.SG_SO_ID
              , X.SG_SO_TITLE
              , X.SG_SO_ORG
              , X.SG_XO_ID
              , X.SG_XO_TITLE
              , X.SG_XO_ORG
              , X.SG_HRL_ID
              , X.SG_HRL_TITLE
              , X.SG_HRL_ORG
              , X.SG_SS_ID
              , X.SG_CS_ID
              , X.SG_SO_AGREE
              , X.SG_OTHER_CERT
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/GENERAL'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         SG_AC_ID                            NUMBER(20)      PATH 'SG_AC_ID'
              , SG_ADMIN_CD                       NVARCHAR2(8)    PATH 'SG_ADMIN_CD'
              , SG_RT_ID                          NUMBER(20)      PATH 'SG_RT_ID'
              , SG_CT_ID                          NUMBER(20)      PATH 'SG_CT_ID'
              , SG_AT_ID                          NUMBER(20)      PATH 'SG_AT_ID'
              , SG_VT_ID                          NUMBER(20)      PATH 'SG_VT_ID'
              , SG_SAT_ID                         NUMBER(20)      PATH 'SG_SAT_ID'
              , SG_SO_ID                          NVARCHAR2(10)   PATH 'SG_SO_ID'
              , SG_SO_TITLE                       NVARCHAR2(50)   PATH 'SG_SO_TITLE'
              , SG_SO_ORG                         NVARCHAR2(50)   PATH 'SG_SO_ORG'
              , SG_XO_ID                          NVARCHAR2(32)   PATH 'SG_XO_ID'
              , SG_XO_TITLE                       NVARCHAR2(200)   PATH 'SG_XO_TITLE'
              , SG_XO_ORG                         NVARCHAR2(200)   PATH 'SG_XO_ORG'
              , SG_HRL_ID                         NVARCHAR2(32)   PATH 'SG_HRL_ID'
              , SG_HRL_TITLE                      NVARCHAR2(200)   PATH 'SG_HRL_TITLE'
              , SG_HRL_ORG                        NVARCHAR2(200)   PATH 'SG_HRL_ORG'
              , SG_SS_ID                          NVARCHAR2(10)   PATH 'SG_SS_ID'
              , SG_CS_ID                          NVARCHAR2(10)   PATH 'SG_CS_ID'
              , SG_SO_AGREE                       CHAR(1)         PATH 'if (SG_SO_AGREE/text() = "true") then 1 else 0'
              , SG_OTHER_CERT                     NVARCHAR2(200)  PATH 'SG_OTHER_CERT'
                ) X
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.SG_REQ_ID = TRG.SG_REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.SG_PROCID       = SRC.SG_PROCID
          , TRG.SG_AC_ID      = SRC.SG_AC_ID
          , TRG.SG_ADMIN_CD   = SRC.SG_ADMIN_CD
          , TRG.SG_RT_ID      = SRC.SG_RT_ID
          , TRG.SG_CT_ID      = SRC.SG_CT_ID
          , TRG.SG_AT_ID      = SRC.SG_AT_ID
          , TRG.SG_VT_ID      = SRC.SG_VT_ID
          , TRG.SG_SAT_ID     = SRC.SG_SAT_ID
          , TRG.SG_SO_ID      = SRC.SG_SO_ID
          , TRG.SG_SO_TITLE   = SRC.SG_SO_TITLE
          , TRG.SG_SO_ORG     = SRC.SG_SO_ORG
          , TRG.SG_XO_ID      = SRC.SG_XO_ID
          , TRG.SG_XO_TITLE   = SRC.SG_XO_TITLE
          , TRG.SG_XO_ORG     = SRC.SG_XO_ORG
          , TRG.SG_HRL_ID     = SRC.SG_HRL_ID
          , TRG.SG_HRL_TITLE  = SRC.SG_HRL_TITLE
          , TRG.SG_HRL_ORG    = SRC.SG_HRL_ORG
          , TRG.SG_SS_ID      = SRC.SG_SS_ID
          , TRG.SG_CS_ID      = SRC.SG_CS_ID
          , TRG.SG_SO_AGREE   = SRC.SG_SO_AGREE
          , TRG.SG_OTHER_CERT = SRC.SG_OTHER_CERT
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.SG_REQ_ID
            , TRG.SG_PROCID
            , TRG.SG_AC_ID
            , TRG.SG_ADMIN_CD
            , TRG.SG_RT_ID
            , TRG.SG_CT_ID
            , TRG.SG_AT_ID
            , TRG.SG_VT_ID
            , TRG.SG_SAT_ID
            , TRG.SG_SO_ID
            , TRG.SG_SO_TITLE
            , TRG.SG_SO_ORG
            , TRG.SG_XO_ID
            , TRG.SG_XO_TITLE
            , TRG.SG_XO_ORG
            , TRG.SG_HRL_ID
            , TRG.SG_HRL_TITLE
            , TRG.SG_HRL_ORG
            , TRG.SG_SS_ID
            , TRG.SG_CS_ID
            , TRG.SG_SO_AGREE
            , TRG.SG_OTHER_CERT
          )
        VALUES
        (
          SRC.SG_REQ_ID
          , SRC.SG_PROCID
          , SRC.SG_AC_ID
          , SRC.SG_ADMIN_CD
          , SRC.SG_RT_ID
          , SRC.SG_CT_ID
          , SRC.SG_AT_ID
          , SRC.SG_VT_ID
          , SRC.SG_SAT_ID
          , SRC.SG_SO_ID
          , SRC.SG_SO_TITLE
          , SRC.SG_SO_ORG
          , SRC.SG_XO_ID
          , SRC.SG_XO_TITLE
          , SRC.SG_XO_ORG
          , SRC.SG_HRL_ID
          , SRC.SG_HRL_TITLE
          , SRC.SG_HRL_ORG
          , SRC.SG_SS_ID
          , SRC.SG_CS_ID
          , SRC.SG_SO_AGREE
          , SRC.SG_OTHER_CERT
        )
        ;


        --------------------------------
        -- POSITION table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    POSITION table');
        MERGE INTO POSITION TRG
        USING
          (
            SELECT
                V_JOB_REQ_ID AS POS_REQ_ID
              , X.POS_CNDT_LAST_NM
              , X.POS_CNDT_FIRST_NM
              , X.POS_CNDT_MIDDLE_NM
              , X.POS_BGT_APR_OFM
              , X.POS_SPNSR_ORG_NM
              , X.POS_SPNSR_ORG_FUND_PC
              , X.POS_TITLE
              , (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = X.POS_PAY_PLAN_ID AND ROWNUM = 1) AS POS_PAY_PLAN_ID
              , X.POS_SERIES
              , X.POS_STD_PD_TYPE
              , X.POS_DESC_NUMBER_1
              , X.POS_CLASSIFICATION_DT_1
              --, X.POS_GRADE_1
              , CASE WHEN LENGTH(X.POS_GRADE_1) = 1 THEN '0' || X.POS_GRADE_1 ELSE X.POS_GRADE_1 END AS POS_GRADE_1
              , X.POS_DESC_NUMBER_2
              , X.POS_CLASSIFICATION_DT_2
              --, X.POS_GRADE_2
              , CASE WHEN LENGTH(X.POS_GRADE_2) = 1 THEN '0' || X.POS_GRADE_2 ELSE X.POS_GRADE_2 END AS POS_GRADE_2
              , X.POS_DESC_NUMBER_3
              , X.POS_CLASSIFICATION_DT_3
              --, X.POS_GRADE_3
              , CASE WHEN LENGTH(X.POS_GRADE_3) = 1 THEN '0' || X.POS_GRADE_3 ELSE X.POS_GRADE_3 END AS POS_GRADE_3
              , X.POS_DESC_NUMBER_4
              , X.POS_CLASSIFICATION_DT_4
              --, X.POS_GRADE_4
              , CASE WHEN LENGTH(X.POS_GRADE_4) = 1 THEN '0' || X.POS_GRADE_4 ELSE X.POS_GRADE_4 END AS POS_GRADE_4
              , X.POS_DESC_NUMBER_5
              , X.POS_CLASSIFICATION_DT_5
              --, X.POS_GRADE_5
              , CASE WHEN LENGTH(X.POS_GRADE_5) = 1 THEN '0' || X.POS_GRADE_5 ELSE X.POS_GRADE_5 END AS POS_GRADE_5
              , X.POS_MED_OFFICERS_ID
              --, X.POS_PERFORMANCE_LEVEL
              , CASE WHEN LENGTH(X.POS_PERFORMANCE_LEVEL) = 1 THEN '0' || X.POS_PERFORMANCE_LEVEL ELSE X.POS_PERFORMANCE_LEVEL END AS POS_PERFORMANCE_LEVEL
              , X.POS_SUPERVISORY
              , X.POS_SKILL
              , X.POS_LOCATION
              , X.POS_VACANCIES
              , X.POS_REPORT_SUPERVISOR
              , X.POS_CAN
              , X.POS_VICE
              , X.POS_VICE_NAME
              , X.POS_DAYS_ADVERTISED
              , X.POS_AT_ID
              , X.POS_NTE
              , X.POS_WORK_SCHED_ID
              , X.POS_HOURS_PER_WEEK
              , X.POS_DUAL_EMPLMT
              , X.POS_SEC_ID
              , X.POS_CE_FINANCIAL_DISC
              , X.POS_CE_FINANCIAL_TYPE_ID
              , X.POS_CE_PE_PHYSICAL
              , X.POS_CE_DRUG_TEST
              , X.POS_CE_IMMUN
              , X.POS_CE_TRAVEL
              , X.POS_CE_TRAVEL_PER
              , X.POS_CE_LIC
              , X.POS_CE_LIC_INFO
              , X.POS_REMARKS
              , X.POS_PROC_REQ_TYPE
              , X.POS_RECRUIT_OFFICE_ID
              , X.POS_REQ_CREATE_NOTIFY_DT
              , X.POS_SO_ID
              , X.POS_ASSOC_DESCR_NUMBERS
              , X.POS_PROMOTE_POTENTIAL
              , X.POS_VICE_EMPL_ID
              , X.POS_SR_ID
              , X.POS_GR_ID
              , X.POS_AC_ID
              , X.POS_GA_1
              , X.POS_GA_2
              , X.POS_GA_3
              , X.POS_GA_4
              , X.POS_GA_5
              , X.POS_GA_6
              , X.POS_GA_7
              , X.POS_GA_8
              , X.POS_GA_9
              , X.POS_GA_10
              , X.POS_GA_11
              , X.POS_GA_12
              , X.POS_GA_13
              , X.POS_GA_14
              , X.POS_GA_15
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/POSITION'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         POS_CNDT_LAST_NM                    NVARCHAR2(50)   PATH 'POS_CNDT_LAST_NM'
              , POS_CNDT_FIRST_NM                 NVARCHAR2(50)   PATH 'POS_CNDT_FIRST_NM'
              , POS_CNDT_MIDDLE_NM                NVARCHAR2(50)   PATH 'POS_CNDT_MIDDLE_NM'
              , POS_BGT_APR_OFM                   CHAR(1)         PATH 'POS_BGT_APR_OFM'
              , POS_SPNSR_ORG_NM                  NVARCHAR2(140)  PATH 'POS_SPNSR_ORG_NM'
              , POS_SPNSR_ORG_FUND_PC             NUMBER(3,0)     PATH 'POS_SPNSR_ORG_FUND_PC'
              , POS_TITLE                         NVARCHAR2(140)  PATH 'POS_TITLE'
              , POS_PAY_PLAN_ID                   VARCHAR2(140)   PATH 'POS_PAY_PLAN_ID'
              , POS_SERIES                        VARCHAR2(140)   PATH 'POS_SERIES'
              , POS_STD_PD_TYPE                   VARCHAR2(200)   PATH 'POS_STD_PD_TYPE'
              , POS_DESC_NUMBER_1                 VARCHAR2(140)   PATH 'POS_DESC_NUMBER_1'
              , POS_CLASSIFICATION_DT_1           DATE            PATH 'POS_CLASSIFICATION_DT_1'
                         --, POS_GRADE_1                       NUMBER(2)       PATH 'POS_GRADE_1'
              , POS_GRADE_1                       VARCHAR2(2)     PATH 'POS_GRADE_1'
              , POS_DESC_NUMBER_2                 VARCHAR2(140)   PATH 'POS_DESC_NUMBER_2'
              , POS_CLASSIFICATION_DT_2           DATE            PATH 'POS_CLASSIFICATION_DT_2'
                         --, POS_GRADE_2                       NUMBER(2)       PATH 'POS_GRADE_2'
              , POS_GRADE_2                       VARCHAR2(2)     PATH 'POS_GRADE_2'
              , POS_DESC_NUMBER_3                 VARCHAR2(140)   PATH 'POS_DESC_NUMBER_3'
              , POS_CLASSIFICATION_DT_3           DATE            PATH 'POS_CLASSIFICATION_DT_3'
                         --, POS_GRADE_3                       NUMBER(2)       PATH 'POS_GRADE_3'
              , POS_GRADE_3                       VARCHAR2(2)     PATH 'POS_GRADE_3'
              , POS_DESC_NUMBER_4                 VARCHAR2(140)   PATH 'POS_DESC_NUMBER_4'
              , POS_CLASSIFICATION_DT_4           DATE            PATH 'POS_CLASSIFICATION_DT_4'
                         --, POS_GRADE_4                       NUMBER(2)       PATH 'POS_GRADE_4'
              , POS_GRADE_4                       VARCHAR2(2)     PATH 'POS_GRADE_4'
              , POS_DESC_NUMBER_5                 VARCHAR2(140)   PATH 'POS_DESC_NUMBER_5'
              , POS_CLASSIFICATION_DT_5           DATE            PATH 'POS_CLASSIFICATION_DT_5'
                         --, POS_GRADE_5                       NUMBER(2)       PATH 'POS_GRADE_5'
              , POS_GRADE_5                       VARCHAR2(2)     PATH 'POS_GRADE_5'
              , POS_MED_OFFICERS_ID               NUMBER(20)      PATH 'POS_MED_OFFICERS_ID'
                         --, POS_PERFORMANCE_LEVEL             NVARCHAR2(50)   PATH 'POS_PERFORMANCE_LEVEL'
              , POS_PERFORMANCE_LEVEL             NVARCHAR2(2)    PATH 'POS_PERFORMANCE_LEVEL'
                         --TODO: actual value for POS_SUPERVISORY is numeric ID to lookup table.  Need to change data type to NUMBER(20)
              , POS_SUPERVISORY                   NVARCHAR2(50)   PATH 'POS_SUPERVISORY'
              , POS_SKILL                         NVARCHAR2(200)  PATH 'POS_SKILL'
              , POS_LOCATION                      NVARCHAR2(2000) PATH 'POS_LOCATION'
              , POS_VACANCIES                     NUMBER(9)       PATH 'POS_VACANCIES'
              , POS_REPORT_SUPERVISOR             NVARCHAR2(10)   PATH 'POS_REPORT_SUPERVISOR'
              , POS_CAN                           NVARCHAR2(8)    PATH 'POS_CAN'
              , POS_VICE                          CHAR(1)         PATH 'POS_VICE'
              , POS_VICE_NAME                     NVARCHAR2(50)   PATH 'POS_VICE_NAME'
              , POS_DAYS_ADVERTISED               NVARCHAR2(50)   PATH 'POS_DAYS_ADVERTISED'
              , POS_AT_ID                         NUMBER(20)      PATH 'POS_AT_ID'
              , POS_NTE                           NVARCHAR2(140)  PATH 'POS_NTE'
              , POS_WORK_SCHED_ID                 NUMBER(20)      PATH 'POS_WORK_SCHED_ID'
              , POS_HOURS_PER_WEEK                NVARCHAR2(50)   PATH 'POS_HOURS_PER_WEEK'
              , POS_DUAL_EMPLMT                   NVARCHAR2(10)   PATH 'POS_DUAL_EMPLMT'
              , POS_SEC_ID                        NUMBER(20)      PATH 'POS_SEC_ID'
              , POS_CE_FINANCIAL_DISC             CHAR(1)         PATH 'if (POS_CE_FINANCIAL_DISC/text() = "true") then 1 else 0'
              , POS_CE_FINANCIAL_TYPE_ID          NUMBER(20)      PATH 'POS_CE_FINANCIAL_TYPE_ID'
              , POS_CE_PE_PHYSICAL                CHAR(1)         PATH 'if (POS_CE_PE_PHYSICAL/text() = "true") then 1 else 0'
              , POS_CE_DRUG_TEST                  CHAR(1)         PATH 'if (POS_CE_DRUG_TEST/text() = "true") then 1 else 0'
              , POS_CE_IMMUN                      CHAR(1)         PATH 'if (POS_CE_IMMUN/text() = "true") then 1 else 0'
              , POS_CE_TRAVEL                     CHAR(1)         PATH 'if (POS_CE_TRAVEL/text() = "true") then 1 else 0'
              , POS_CE_TRAVEL_PER                 NVARCHAR2(3)    PATH 'POS_CE_TRAVEL_PER'
              , POS_CE_LIC                        CHAR(1)         PATH 'if (POS_CE_LIC/text() = "true") then 1 else 0'
              , POS_CE_LIC_INFO                   NVARCHAR2(140)  PATH 'POS_CE_LIC_INFO'
              , POS_REMARKS                       NVARCHAR2(500)  PATH 'POS_REMARKS'
              , POS_PROC_REQ_TYPE                 NUMBER(20)      PATH 'POS_PROC_REQ_TYPE'
              , POS_RECRUIT_OFFICE_ID             NUMBER(20)      PATH 'POS_RECRUIT_OFFICE_ID'
              , POS_REQ_CREATE_NOTIFY_DT          DATE            PATH 'POS_REQ_CREATE_NOTIFY_DT'
              , POS_SO_ID                         NUMBER(9)       PATH 'POS_SO_ID'
              , POS_ASSOC_DESCR_NUMBERS           NVARCHAR2(100)  PATH 'POS_ASSOC_DESCR_NUMBERS'
              , POS_PROMOTE_POTENTIAL             NUMBER(2)       PATH 'POS_PROMOTE_POTENTIAL'
              , POS_VICE_EMPL_ID                  NVARCHAR2(25)   PATH 'POS_VICE_EMPL_ID'
              , POS_SR_ID                         NUMBER(20)      PATH 'POS_SR_ID'
              , POS_GR_ID                         NUMBER(20)      PATH 'POS_GR_ID'
              , POS_AC_ID                         NUMBER(20)      PATH 'POS_AC_ID'
              , POS_GA_1                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_1/text() = "true") then 1 else 0'
              , POS_GA_2                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_2/text() = "true") then 1 else 0'
              , POS_GA_3                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_3/text() = "true") then 1 else 0'
              , POS_GA_4                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_4/text() = "true") then 1 else 0'
              , POS_GA_5                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_5/text() = "true") then 1 else 0'
              , POS_GA_6                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_6/text() = "true") then 1 else 0'
              , POS_GA_7                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_7/text() = "true") then 1 else 0'
              , POS_GA_8                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_8/text() = "true") then 1 else 0'
              , POS_GA_9                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_9/text() = "true") then 1 else 0'
              , POS_GA_10                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_10/text() = "true") then 1 else 0'
              , POS_GA_11                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_11/text() = "true") then 1 else 0'
              , POS_GA_12                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_12/text() = "true") then 1 else 0'
              , POS_GA_13                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_13/text() = "true") then 1 else 0'
              , POS_GA_14                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_14/text() = "true") then 1 else 0'
              , POS_GA_15                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_15/text() = "true") then 1 else 0'
                ) X
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.POS_REQ_ID = TRG.POS_REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.POS_CNDT_LAST_NM            = SRC.POS_CNDT_LAST_NM
          , TRG.POS_CNDT_FIRST_NM         = SRC.POS_CNDT_FIRST_NM
          , TRG.POS_CNDT_MIDDLE_NM        = SRC.POS_CNDT_MIDDLE_NM
          , TRG.POS_BGT_APR_OFM           = SRC.POS_BGT_APR_OFM
          , TRG.POS_SPNSR_ORG_NM          = SRC.POS_SPNSR_ORG_NM
          , TRG.POS_SPNSR_ORG_FUND_PC     = SRC.POS_SPNSR_ORG_FUND_PC
          , TRG.POS_TITLE                 = SRC.POS_TITLE
          , TRG.POS_PAY_PLAN_ID           = SRC.POS_PAY_PLAN_ID
          , TRG.POS_SERIES                = SRC.POS_SERIES
          , TRG.POS_STD_PD_TYPE           = SRC.POS_STD_PD_TYPE
          , TRG.POS_DESC_NUMBER_1         = SRC.POS_DESC_NUMBER_1
          , TRG.POS_CLASSIFICATION_DT_1   = SRC.POS_CLASSIFICATION_DT_1
          , TRG.POS_GRADE_1               = SRC.POS_GRADE_1
          , TRG.POS_DESC_NUMBER_2         = SRC.POS_DESC_NUMBER_2
          , TRG.POS_CLASSIFICATION_DT_2   = SRC.POS_CLASSIFICATION_DT_2
          , TRG.POS_GRADE_2               = SRC.POS_GRADE_2
          , TRG.POS_DESC_NUMBER_3         = SRC.POS_DESC_NUMBER_3
          , TRG.POS_CLASSIFICATION_DT_3   = SRC.POS_CLASSIFICATION_DT_3
          , TRG.POS_GRADE_3               = SRC.POS_GRADE_3
          , TRG.POS_DESC_NUMBER_4         = SRC.POS_DESC_NUMBER_4
          , TRG.POS_CLASSIFICATION_DT_4   = SRC.POS_CLASSIFICATION_DT_4
          , TRG.POS_GRADE_4               = SRC.POS_GRADE_4
          , TRG.POS_DESC_NUMBER_5         = SRC.POS_DESC_NUMBER_5
          , TRG.POS_CLASSIFICATION_DT_5   = SRC.POS_CLASSIFICATION_DT_5
          , TRG.POS_GRADE_5               = SRC.POS_GRADE_5
          , TRG.POS_MED_OFFICERS_ID       = SRC.POS_MED_OFFICERS_ID
          , TRG.POS_PERFORMANCE_LEVEL     = SRC.POS_PERFORMANCE_LEVEL
          , TRG.POS_SUPERVISORY           = SRC.POS_SUPERVISORY
          , TRG.POS_SKILL                 = SRC.POS_SKILL
          , TRG.POS_LOCATION              = SRC.POS_LOCATION
          , TRG.POS_VACANCIES             = SRC.POS_VACANCIES
          , TRG.POS_REPORT_SUPERVISOR     = SRC.POS_REPORT_SUPERVISOR
          , TRG.POS_CAN                   = SRC.POS_CAN
          , TRG.POS_VICE                  = SRC.POS_VICE
          , TRG.POS_VICE_NAME             = SRC.POS_VICE_NAME
          , TRG.POS_DAYS_ADVERTISED       = SRC.POS_DAYS_ADVERTISED
          , TRG.POS_AT_ID                 = SRC.POS_AT_ID
          , TRG.POS_NTE                   = SRC.POS_NTE
          , TRG.POS_WORK_SCHED_ID         = SRC.POS_WORK_SCHED_ID
          , TRG.POS_HOURS_PER_WEEK        = SRC.POS_HOURS_PER_WEEK
          , TRG.POS_DUAL_EMPLMT           = SRC.POS_DUAL_EMPLMT
          , TRG.POS_SEC_ID                = SRC.POS_SEC_ID
          , TRG.POS_CE_FINANCIAL_DISC     = SRC.POS_CE_FINANCIAL_DISC
          , TRG.POS_CE_FINANCIAL_TYPE_ID  = SRC.POS_CE_FINANCIAL_TYPE_ID
          , TRG.POS_CE_PE_PHYSICAL        = SRC.POS_CE_PE_PHYSICAL
          , TRG.POS_CE_DRUG_TEST          = SRC.POS_CE_DRUG_TEST
          , TRG.POS_CE_IMMUN              = SRC.POS_CE_IMMUN
          , TRG.POS_CE_TRAVEL             = SRC.POS_CE_TRAVEL
          , TRG.POS_CE_TRAVEL_PER         = SRC.POS_CE_TRAVEL_PER
          , TRG.POS_CE_LIC                = SRC.POS_CE_LIC
          , TRG.POS_CE_LIC_INFO           = SRC.POS_CE_LIC_INFO
          , TRG.POS_REMARKS               = SRC.POS_REMARKS
          , TRG.POS_PROC_REQ_TYPE         = SRC.POS_PROC_REQ_TYPE
          , TRG.POS_RECRUIT_OFFICE_ID     = SRC.POS_RECRUIT_OFFICE_ID
          , TRG.POS_REQ_CREATE_NOTIFY_DT  = SRC.POS_REQ_CREATE_NOTIFY_DT
          , TRG.POS_SO_ID                 = SRC.POS_SO_ID
          , TRG.POS_ASSOC_DESCR_NUMBERS   = SRC.POS_ASSOC_DESCR_NUMBERS
          , TRG.POS_PROMOTE_POTENTIAL     = SRC.POS_PROMOTE_POTENTIAL
          , TRG.POS_VICE_EMPL_ID          = SRC.POS_VICE_EMPL_ID
          , TRG.POS_SR_ID                 = SRC.POS_SR_ID
          , TRG.POS_GR_ID                 = SRC.POS_GR_ID
          , TRG.POS_AC_ID                 = SRC.POS_AC_ID
          , TRG.POS_GA_1                  = SRC.POS_GA_1
          , TRG.POS_GA_2                  = SRC.POS_GA_2
          , TRG.POS_GA_3                  = SRC.POS_GA_3
          , TRG.POS_GA_4                  = SRC.POS_GA_4
          , TRG.POS_GA_5                  = SRC.POS_GA_5
          , TRG.POS_GA_6                  = SRC.POS_GA_6
          , TRG.POS_GA_7                  = SRC.POS_GA_7
          , TRG.POS_GA_8                  = SRC.POS_GA_8
          , TRG.POS_GA_9                  = SRC.POS_GA_9
          , TRG.POS_GA_10                 = SRC.POS_GA_10
          , TRG.POS_GA_11                 = SRC.POS_GA_11
          , TRG.POS_GA_12                 = SRC.POS_GA_12
          , TRG.POS_GA_13                 = SRC.POS_GA_13
          , TRG.POS_GA_14                 = SRC.POS_GA_14
          , TRG.POS_GA_15                 = SRC.POS_GA_15
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.POS_REQ_ID
            , TRG.POS_CNDT_LAST_NM
            , TRG.POS_CNDT_FIRST_NM
            , TRG.POS_CNDT_MIDDLE_NM
            , TRG.POS_BGT_APR_OFM
            , TRG.POS_SPNSR_ORG_NM
            , TRG.POS_SPNSR_ORG_FUND_PC
            , TRG.POS_TITLE
            , TRG.POS_PAY_PLAN_ID
            , TRG.POS_SERIES
            , TRG.POS_STD_PD_TYPE
            , TRG.POS_DESC_NUMBER_1
            , TRG.POS_CLASSIFICATION_DT_1
            , TRG.POS_GRADE_1
            , TRG.POS_DESC_NUMBER_2
            , TRG.POS_CLASSIFICATION_DT_2
            , TRG.POS_GRADE_2
            , TRG.POS_DESC_NUMBER_3
            , TRG.POS_CLASSIFICATION_DT_3
            , TRG.POS_GRADE_3
            , TRG.POS_DESC_NUMBER_4
            , TRG.POS_CLASSIFICATION_DT_4
            , TRG.POS_GRADE_4
            , TRG.POS_DESC_NUMBER_5
            , TRG.POS_CLASSIFICATION_DT_5
            , TRG.POS_GRADE_5
            , TRG.POS_MED_OFFICERS_ID
            , TRG.POS_PERFORMANCE_LEVEL
            , TRG.POS_SUPERVISORY
            , TRG.POS_SKILL
            , TRG.POS_LOCATION
            , TRG.POS_VACANCIES
            , TRG.POS_REPORT_SUPERVISOR
            , TRG.POS_CAN
            , TRG.POS_VICE
            , TRG.POS_VICE_NAME
            , TRG.POS_DAYS_ADVERTISED
            , TRG.POS_AT_ID
            , TRG.POS_NTE
            , TRG.POS_WORK_SCHED_ID
            , TRG.POS_HOURS_PER_WEEK
            , TRG.POS_DUAL_EMPLMT
            , TRG.POS_SEC_ID
            , TRG.POS_CE_FINANCIAL_DISC
            , TRG.POS_CE_FINANCIAL_TYPE_ID
            , TRG.POS_CE_PE_PHYSICAL
            , TRG.POS_CE_DRUG_TEST
            , TRG.POS_CE_IMMUN
            , TRG.POS_CE_TRAVEL
            , TRG.POS_CE_TRAVEL_PER
            , TRG.POS_CE_LIC
            , TRG.POS_CE_LIC_INFO
            , TRG.POS_REMARKS
            , TRG.POS_PROC_REQ_TYPE
            , TRG.POS_RECRUIT_OFFICE_ID
            , TRG.POS_REQ_CREATE_NOTIFY_DT
            , TRG.POS_SO_ID
            , TRG.POS_ASSOC_DESCR_NUMBERS
            , TRG.POS_PROMOTE_POTENTIAL
            , TRG.POS_VICE_EMPL_ID
            , TRG.POS_SR_ID
            , TRG.POS_GR_ID
            , TRG.POS_AC_ID
            , TRG.POS_GA_1
            , TRG.POS_GA_2
            , TRG.POS_GA_3
            , TRG.POS_GA_4
            , TRG.POS_GA_5
            , TRG.POS_GA_6
            , TRG.POS_GA_7
            , TRG.POS_GA_8
            , TRG.POS_GA_9
            , TRG.POS_GA_10
            , TRG.POS_GA_11
            , TRG.POS_GA_12
            , TRG.POS_GA_13
            , TRG.POS_GA_14
            , TRG.POS_GA_15
          )
        VALUES
        (
          SRC.POS_REQ_ID
          , SRC.POS_CNDT_LAST_NM
          , SRC.POS_CNDT_FIRST_NM
          , SRC.POS_CNDT_MIDDLE_NM
          , SRC.POS_BGT_APR_OFM
          , SRC.POS_SPNSR_ORG_NM
          , SRC.POS_SPNSR_ORG_FUND_PC
          , SRC.POS_TITLE
          , SRC.POS_PAY_PLAN_ID
          , SRC.POS_SERIES
          , SRC.POS_STD_PD_TYPE
          , SRC.POS_DESC_NUMBER_1
          , SRC.POS_CLASSIFICATION_DT_1
          , SRC.POS_GRADE_1
          , SRC.POS_DESC_NUMBER_2
          , SRC.POS_CLASSIFICATION_DT_2
          , SRC.POS_GRADE_2
          , SRC.POS_DESC_NUMBER_3
          , SRC.POS_CLASSIFICATION_DT_3
          , SRC.POS_GRADE_3
          , SRC.POS_DESC_NUMBER_4
          , SRC.POS_CLASSIFICATION_DT_4
          , SRC.POS_GRADE_4
          , SRC.POS_DESC_NUMBER_5
          , SRC.POS_CLASSIFICATION_DT_5
          , SRC.POS_GRADE_5
          , SRC.POS_MED_OFFICERS_ID
          , SRC.POS_PERFORMANCE_LEVEL
          , SRC.POS_SUPERVISORY
          , SRC.POS_SKILL
          , SRC.POS_LOCATION
          , SRC.POS_VACANCIES
          , SRC.POS_REPORT_SUPERVISOR
          , SRC.POS_CAN
          , SRC.POS_VICE
          , SRC.POS_VICE_NAME
          , SRC.POS_DAYS_ADVERTISED
          , SRC.POS_AT_ID
          , SRC.POS_NTE
          , SRC.POS_WORK_SCHED_ID
          , SRC.POS_HOURS_PER_WEEK
          , SRC.POS_DUAL_EMPLMT
          , SRC.POS_SEC_ID
          , SRC.POS_CE_FINANCIAL_DISC
          , SRC.POS_CE_FINANCIAL_TYPE_ID
          , SRC.POS_CE_PE_PHYSICAL
          , SRC.POS_CE_DRUG_TEST
          , SRC.POS_CE_IMMUN
          , SRC.POS_CE_TRAVEL
          , SRC.POS_CE_TRAVEL_PER
          , SRC.POS_CE_LIC
          , SRC.POS_CE_LIC_INFO
          , SRC.POS_REMARKS
          , SRC.POS_PROC_REQ_TYPE
          , SRC.POS_RECRUIT_OFFICE_ID
          , SRC.POS_REQ_CREATE_NOTIFY_DT
          , SRC.POS_SO_ID
          , SRC.POS_ASSOC_DESCR_NUMBERS
          , SRC.POS_PROMOTE_POTENTIAL
          , SRC.POS_VICE_EMPL_ID
          , SRC.POS_SR_ID
          , SRC.POS_GR_ID
          , SRC.POS_AC_ID
          , SRC.POS_GA_1
          , SRC.POS_GA_2
          , SRC.POS_GA_3
          , SRC.POS_GA_4
          , SRC.POS_GA_5
          , SRC.POS_GA_6
          , SRC.POS_GA_7
          , SRC.POS_GA_8
          , SRC.POS_GA_9
          , SRC.POS_GA_10
          , SRC.POS_GA_11
          , SRC.POS_GA_12
          , SRC.POS_GA_13
          , SRC.POS_GA_14
          , SRC.POS_GA_15
        )
        ;


        --------------------------------
        -- AREAS_OF_CONS table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    AREAS_OF_CONS table');
        MERGE INTO AREAS_OF_CONS TRG
        USING
          (
            SELECT
              V_JOB_REQ_ID AS AOC_REQ_ID
              , X.AOC_30PCT_DISABLED_VETS
              , X.AOC_EXPERT_CONS
              , X.AOC_IPA
              , X.AOC_OPER_WARFIGHTER
              , X.AOC_DISABILITIES
              , X.AOC_STUDENT_VOL
              , X.AOC_VETS_RECRUIT_APPT
              , X.AOC_VOC_REHAB_EMPL
              , X.AOC_WORKFORCE_RECRUIT
              , X.AOC_NON_COMP_APPL
              , X.AOC_MIL_SPOUSES
              , X.AOC_DIRECT_HIRE
              , X.AOC_RE_EMPLOYMENT
              , X.AOC_PATHWAYS
              , X.AOC_PEACE_CORPS_VOL
              , X.AOC_REINSTATEMENT
              , X.AOC_SHARED_CERT
              , X.AOC_DELEGATE_EXAM
              , X.AOC_DH_US_CITIZENS
              , X.AOC_MP_GOV_WIDE
              , X.AOC_MP_HHS_ONLY
              , X.AOC_MP_CMS_ONLY
              , X.AOC_MP_COMP_CONS_ONLY
              , X.AOC_MP_I_CTAP_VEGA
              , X.AOC_NON_BARGAIN_DOC_RATIONALE
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/AREA_OF_CONSIDERATION'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         AOC_30PCT_DISABLED_VETS             CHAR(1)         PATH 'if (AOC_30PCT_DISABLED_VETS/text() = "true") then 1 else 0'
              , AOC_EXPERT_CONS                   CHAR(1)         PATH 'if (AOC_EXPERT_CONS/text() = "true") then 1 else 0'
              , AOC_IPA                           CHAR(1)         PATH 'if (AOC_IPA/text() = "true") then 1 else 0'
              , AOC_OPER_WARFIGHTER               CHAR(1)         PATH 'if (AOC_OPER_WARFIGHTER/text() = "true") then 1 else 0'
              , AOC_DISABILITIES                  CHAR(1)         PATH 'if (AOC_DISABILITIES/text() = "true") then 1 else 0'
              , AOC_STUDENT_VOL                   CHAR(1)         PATH 'if (AOC_STUDENT_VOL/text() = "true") then 1 else 0'
              , AOC_VETS_RECRUIT_APPT             CHAR(1)         PATH 'if (AOC_VETS_RECRUIT_APPT/text() = "true") then 1 else 0'
              , AOC_VOC_REHAB_EMPL                CHAR(1)         PATH 'if (AOC_VOC_REHAB_EMPL/text() = "true") then 1 else 0'
              , AOC_WORKFORCE_RECRUIT             CHAR(1)         PATH 'if (AOC_WORKFORCE_RECRUIT/text() = "true") then 1 else 0'
              , AOC_NON_COMP_APPL                 NVARCHAR2(140)  PATH 'AOC_NON_COMP_APPL'
              , AOC_MIL_SPOUSES                   CHAR(1)         PATH 'if (AOC_MIL_SPOUSES/text() = "true") then 1 else 0'
              , AOC_DIRECT_HIRE                   CHAR(1)         PATH 'if (AOC_DIRECT_HIRE/text() = "true") then 1 else 0'
              , AOC_RE_EMPLOYMENT                 CHAR(1)         PATH 'if (AOC_RE_EMPLOYMENT/text() = "true") then 1 else 0'
              , AOC_PATHWAYS                      CHAR(1)         PATH 'if (AOC_PATHWAYS/text() = "true") then 1 else 0'
              , AOC_PEACE_CORPS_VOL               CHAR(1)         PATH 'if (AOC_PEACE_CORPS_VOL/text() = "true") then 1 else 0'
              , AOC_REINSTATEMENT                 CHAR(1)         PATH 'if (AOC_REINSTATEMENT/text() = "true") then 1 else 0'
              , AOC_SHARED_CERT                   CHAR(1)         PATH 'if (AOC_SHARED_CERT/text() = "true") then 1 else 0'
              , AOC_DELEGATE_EXAM                 CHAR(1)         PATH 'if (AOC_DELEGATE_EXAM/text() = "true") then 1 else 0'
              , AOC_DH_US_CITIZENS                CHAR(1)         PATH 'if (AOC_DH_US_CITIZENS/text() = "true") then 1 else 0'
              , AOC_MP_GOV_WIDE                   CHAR(1)         PATH 'if (AOC_MP_GOV_WIDE/text() = "true") then 1 else 0'
              , AOC_MP_HHS_ONLY                   CHAR(1)         PATH 'if (AOC_MP_HHS_ONLY/text() = "true") then 1 else 0'
              , AOC_MP_CMS_ONLY                   CHAR(1)         PATH 'if (AOC_MP_CMS_ONLY/text() = "true") then 1 else 0'
              , AOC_MP_COMP_CONS_ONLY             CHAR(1)         PATH 'if (AOC_MP_COMP_CONS_ONLY/text() = "true") then 1 else 0'
              , AOC_MP_I_CTAP_VEGA                CHAR(1)         PATH 'if (AOC_MP_I_CTAP_VEGA/text() = "true") then 1 else 0'
              , AOC_NON_BARGAIN_DOC_RATIONALE     NVARCHAR2(500)  PATH 'AOC_NON_BARGAIN_DOC_RATIONALE'
                ) X
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.AOC_REQ_ID = TRG.AOC_REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.AOC_30PCT_DISABLED_VETS          = SRC.AOC_30PCT_DISABLED_VETS
          , TRG.AOC_EXPERT_CONS                = SRC.AOC_EXPERT_CONS
          , TRG.AOC_IPA                        = SRC.AOC_IPA
          , TRG.AOC_OPER_WARFIGHTER            = SRC.AOC_OPER_WARFIGHTER
          , TRG.AOC_DISABILITIES               = SRC.AOC_DISABILITIES
          , TRG.AOC_STUDENT_VOL                = SRC.AOC_STUDENT_VOL
          , TRG.AOC_VETS_RECRUIT_APPT          = SRC.AOC_VETS_RECRUIT_APPT
          , TRG.AOC_VOC_REHAB_EMPL             = SRC.AOC_VOC_REHAB_EMPL
          , TRG.AOC_WORKFORCE_RECRUIT          = SRC.AOC_WORKFORCE_RECRUIT
          , TRG.AOC_NON_COMP_APPL              = SRC.AOC_NON_COMP_APPL
          , TRG.AOC_MIL_SPOUSES                = SRC.AOC_MIL_SPOUSES
          , TRG.AOC_DIRECT_HIRE                = SRC.AOC_DIRECT_HIRE
          , TRG.AOC_RE_EMPLOYMENT              = SRC.AOC_RE_EMPLOYMENT
          , TRG.AOC_PATHWAYS                   = SRC.AOC_PATHWAYS
          , TRG.AOC_PEACE_CORPS_VOL            = SRC.AOC_PEACE_CORPS_VOL
          , TRG.AOC_REINSTATEMENT              = SRC.AOC_REINSTATEMENT
          , TRG.AOC_SHARED_CERT                = SRC.AOC_SHARED_CERT
          , TRG.AOC_DELEGATE_EXAM              = SRC.AOC_DELEGATE_EXAM
          , TRG.AOC_DH_US_CITIZENS             = SRC.AOC_DH_US_CITIZENS
          , TRG.AOC_MP_GOV_WIDE                = SRC.AOC_MP_GOV_WIDE
          , TRG.AOC_MP_HHS_ONLY                = SRC.AOC_MP_HHS_ONLY
          , TRG.AOC_MP_CMS_ONLY                = SRC.AOC_MP_CMS_ONLY
          , TRG.AOC_MP_COMP_CONS_ONLY          = SRC.AOC_MP_COMP_CONS_ONLY
          , TRG.AOC_MP_I_CTAP_VEGA             = SRC.AOC_MP_I_CTAP_VEGA
          , TRG.AOC_NON_BARGAIN_DOC_RATIONALE  = SRC.AOC_NON_BARGAIN_DOC_RATIONALE
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.AOC_REQ_ID
            , TRG.AOC_30PCT_DISABLED_VETS
            , TRG.AOC_EXPERT_CONS
            , TRG.AOC_IPA
            , TRG.AOC_OPER_WARFIGHTER
            , TRG.AOC_DISABILITIES
            , TRG.AOC_STUDENT_VOL
            , TRG.AOC_VETS_RECRUIT_APPT
            , TRG.AOC_VOC_REHAB_EMPL
            , TRG.AOC_WORKFORCE_RECRUIT
            , TRG.AOC_NON_COMP_APPL
            , TRG.AOC_MIL_SPOUSES
            , TRG.AOC_DIRECT_HIRE
            , TRG.AOC_RE_EMPLOYMENT
            , TRG.AOC_PATHWAYS
            , TRG.AOC_PEACE_CORPS_VOL
            , TRG.AOC_REINSTATEMENT
            , TRG.AOC_SHARED_CERT
            , TRG.AOC_DELEGATE_EXAM
            , TRG.AOC_DH_US_CITIZENS
            , TRG.AOC_MP_GOV_WIDE
            , TRG.AOC_MP_HHS_ONLY
            , TRG.AOC_MP_CMS_ONLY
            , TRG.AOC_MP_COMP_CONS_ONLY
            , TRG.AOC_MP_I_CTAP_VEGA
            , TRG.AOC_NON_BARGAIN_DOC_RATIONALE
          )
        VALUES
        (
          SRC.AOC_REQ_ID
          , SRC.AOC_30PCT_DISABLED_VETS
          , SRC.AOC_EXPERT_CONS
          , SRC.AOC_IPA
          , SRC.AOC_OPER_WARFIGHTER
          , SRC.AOC_DISABILITIES
          , SRC.AOC_STUDENT_VOL
          , SRC.AOC_VETS_RECRUIT_APPT
          , SRC.AOC_VOC_REHAB_EMPL
          , SRC.AOC_WORKFORCE_RECRUIT
          , SRC.AOC_NON_COMP_APPL
          , SRC.AOC_MIL_SPOUSES
          , SRC.AOC_DIRECT_HIRE
          , SRC.AOC_RE_EMPLOYMENT
          , SRC.AOC_PATHWAYS
          , SRC.AOC_PEACE_CORPS_VOL
          , SRC.AOC_REINSTATEMENT
          , SRC.AOC_SHARED_CERT
          , SRC.AOC_DELEGATE_EXAM
          , SRC.AOC_DH_US_CITIZENS
          , SRC.AOC_MP_GOV_WIDE
          , SRC.AOC_MP_HHS_ONLY
          , SRC.AOC_MP_CMS_ONLY
          , SRC.AOC_MP_COMP_CONS_ONLY
          , SRC.AOC_MP_I_CTAP_VEGA
          , SRC.AOC_NON_BARGAIN_DOC_RATIONALE
        )
        ;


        --------------------------------
        -- SME_INFO table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    SME_INFO table');
        MERGE INTO SME_INFO TRG
        USING
          (
            SELECT
              V_JOB_REQ_ID AS SME_REQ_ID
              , X.SME_FOR_JOB_ANALYSIS
              , X.SME_NAME_JA
              , X.SME_EMAIL_JA
              , X.SME_FOR_QUALIFICATION
              , X.SME_NAME_QUAL_1
              , X.SME_EMAIL_QUAL_1
              , X.SME_NAME_QUAL_2
              , X.SME_EMAIL_QUAL_2
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/SUBJECT_MATTER_EXPERT'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         SME_FOR_JOB_ANALYSIS                CHAR(1)         PATH 'if (SME_FOR_JOB_ANALYSIS/text() = "true") then 1 else 0'
              , SME_NAME_JA                       NVARCHAR2(100)  PATH 'SME_NAME_JA'
              , SME_EMAIL_JA                      NVARCHAR2(100)  PATH 'SME_EMAIL_JA'
              , SME_FOR_QUALIFICATION             CHAR(1)         PATH 'if (SME_FOR_QUALIFICATION/text() = "true") then 1 else 0'
              , SME_NAME_QUAL_1                   NVARCHAR2(100)  PATH 'SME_NAME_QUAL_1'
              , SME_EMAIL_QUAL_1                  NVARCHAR2(100)  PATH 'SME_EMAIL_QUAL_1'
              , SME_NAME_QUAL_2                   NVARCHAR2(100)  PATH 'SME_NAME_QUAL_2'
              , SME_EMAIL_QUAL_2                  NVARCHAR2(100)  PATH 'SME_EMAIL_QUAL_2'
                ) X
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.SME_REQ_ID = TRG.SME_REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.SME_FOR_JOB_ANALYSIS     = SRC.SME_FOR_JOB_ANALYSIS
          , TRG.SME_NAME_JA            = SRC.SME_NAME_JA
          , TRG.SME_EMAIL_JA           = SRC.SME_EMAIL_JA
          , TRG.SME_FOR_QUALIFICATION  = SRC.SME_FOR_QUALIFICATION
          , TRG.SME_NAME_QUAL_1        = SRC.SME_NAME_QUAL_1
          , TRG.SME_EMAIL_QUAL_1       = SRC.SME_EMAIL_QUAL_1
          , TRG.SME_NAME_QUAL_2        = SRC.SME_NAME_QUAL_2
          , TRG.SME_EMAIL_QUAL_2       = SRC.SME_EMAIL_QUAL_2
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.SME_REQ_ID
            , TRG.SME_FOR_JOB_ANALYSIS
            , TRG.SME_NAME_JA
            , TRG.SME_EMAIL_JA
            , TRG.SME_FOR_QUALIFICATION
            , TRG.SME_NAME_QUAL_1
            , TRG.SME_EMAIL_QUAL_1
            , TRG.SME_NAME_QUAL_2
            , TRG.SME_EMAIL_QUAL_2
          )
        VALUES
        (
          SRC.SME_REQ_ID
          , SRC.SME_FOR_JOB_ANALYSIS
          , SRC.SME_NAME_JA
          , SRC.SME_EMAIL_JA
          , SRC.SME_FOR_QUALIFICATION
          , SRC.SME_NAME_QUAL_1
          , SRC.SME_EMAIL_QUAL_1
          , SRC.SME_NAME_QUAL_2
          , SRC.SME_EMAIL_QUAL_2
        )
        ;


        --------------------------------
        -- JOB_ANALYSIS table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    JOB_ANALYSIS table');
        MERGE INTO JOB_ANALYSIS TRG
        USING
          (
            SELECT
              V_JOB_REQ_ID AS JA_REQ_ID
              , X.JA_SEL_FACTOR_REQ
              , X.JA_SEL_FACTOR_JUST
              , X.JA_QUAL_RANK_REQ
              , X.JA_QUAL_RANK_JUST
              , X.JA_RESPONSES_REQ
              , X.JA_TYPE_YES_NO
              , X.JA_TYPE_REQ_DEFAULT
              , X.JA_TYPE_KNOWL_SCALE
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/JOB_ANALYSIS'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         JA_SEL_FACTOR_REQ                   CHAR(1)         PATH 'if (JA_SEL_FACTOR_REQ/text() = "true") then 1 else 0'
              , JA_SEL_FACTOR_JUST                NVARCHAR2(100)  PATH 'JA_SEL_FACTOR_JUST'
              , JA_QUAL_RANK_REQ                  CHAR(1)         PATH 'if (JA_QUAL_RANK_REQ/text() = "true") then 1 else 0'
              , JA_QUAL_RANK_JUST                 NVARCHAR2(100)  PATH 'JA_QUAL_RANK_JUST'
              , JA_RESPONSES_REQ                  CHAR(1)         PATH 'if (JA_RESPONSES_REQ/text() = "true") then 1 else 0'
              , JA_TYPE_YES_NO                    CHAR(1)         PATH 'if (JA_TYPE_YES_NO/text() = "true") then 1 else 0'
              , JA_TYPE_REQ_DEFAULT               CHAR(1)         PATH 'if (JA_TYPE_REQ_DEFAULT/text() = "true") then 1 else 0'
              , JA_TYPE_KNOWL_SCALE               CHAR(1)         PATH 'if (JA_TYPE_KNOWL_SCALE/text() = "true") then 1 else 0'
                ) X
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.JA_REQ_ID = TRG.JA_REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.JA_SEL_FACTOR_REQ = SRC.JA_SEL_FACTOR_REQ
          , TRG.JA_SEL_FACTOR_JUST   = SRC.JA_SEL_FACTOR_JUST
          , TRG.JA_QUAL_RANK_REQ     = SRC.JA_QUAL_RANK_REQ
          , TRG.JA_QUAL_RANK_JUST    = SRC.JA_QUAL_RANK_JUST
          , TRG.JA_RESPONSES_REQ     = SRC.JA_RESPONSES_REQ
          , TRG.JA_TYPE_YES_NO       = SRC.JA_TYPE_YES_NO
          , TRG.JA_TYPE_REQ_DEFAULT  = SRC.JA_TYPE_REQ_DEFAULT
          , TRG.JA_TYPE_KNOWL_SCALE  = SRC.JA_TYPE_KNOWL_SCALE
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.JA_REQ_ID
            , TRG.JA_SEL_FACTOR_REQ
            , TRG.JA_SEL_FACTOR_JUST
            , TRG.JA_QUAL_RANK_REQ
            , TRG.JA_QUAL_RANK_JUST
            , TRG.JA_RESPONSES_REQ
            , TRG.JA_TYPE_YES_NO
            , TRG.JA_TYPE_REQ_DEFAULT
            , TRG.JA_TYPE_KNOWL_SCALE
          )
        VALUES
        (
          SRC.JA_REQ_ID
          , SRC.JA_SEL_FACTOR_REQ
          , SRC.JA_SEL_FACTOR_JUST
          , SRC.JA_QUAL_RANK_REQ
          , SRC.JA_QUAL_RANK_JUST
          , SRC.JA_RESPONSES_REQ
          , SRC.JA_TYPE_YES_NO
          , SRC.JA_TYPE_REQ_DEFAULT
          , SRC.JA_TYPE_KNOWL_SCALE
        )
        ;


        --------------------------------
        -- RECRUIT_INCENTIVES table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    RECRUIT_INCENTIVES table');
        MERGE INTO RECRUIT_INCENTIVES TRG
        USING
          (
            SELECT
              V_JOB_REQ_ID AS RI_REQ_ID
              , X.RI_OA_APRV_ITEM
              , X.RI_MOVING_EXP_AUTH
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/RECRUITMENT_INCENTIVE'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         RI_RECRUITMENT_AUTH                 CHAR(1)         PATH 'if (RI_OA_APRV_ITEM/text() = "C") then 1 else 0'
              , RI_RELOCATION_AUTH                CHAR(1)         PATH 'if (RI_OA_APRV_ITEM/text() = "L") then 1 else 0'
              , RI_OA_APRV_ITEM                   VARCHAR2(20)    PATH 'RI_OA_APRV_ITEM'
              , RI_MOVING_EXP_AUTH                CHAR(1)         PATH 'if (RI_MOVING_EXP_AUTH/text() = "true") then 1 else 0'
                ) X
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.RI_REQ_ID = TRG.RI_REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.RI_OA_APRV_ITEM       = SRC.RI_OA_APRV_ITEM
          , TRG.RI_MOVING_EXP_AUTH  = SRC.RI_MOVING_EXP_AUTH
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.RI_REQ_ID
            , TRG.RI_OA_APRV_ITEM
            , TRG.RI_MOVING_EXP_AUTH
          )
        VALUES
        (
          SRC.RI_REQ_ID
          , SRC.RI_OA_APRV_ITEM
          , SRC.RI_MOVING_EXP_AUTH
        )
        ;


        --------------------------------
        -- TARGET_RECRUIT table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    TARGET_RECRUIT table');
        MERGE INTO TARGET_RECRUIT TRG
        USING
          (
            SELECT
              V_JOB_REQ_ID AS TR_REQ_ID
              , X.TR_PAID_AD
              , X.TR_PAID_AD_SPEC
              , X.TR_PAID_AD_SPEC_OTHR
              , X.TR_SCHL_PSTG
              , X.TR_SCHL_PSTG_SPEC
              , X.TR_SCHL_PSTG_SPEC_OTHR
              , X.TR_SOCIAL_MEDIA
              , X.TR_SOCIAL_MEDIA_SPEC
              , X.TR_SOCIAL_MEDIA_SPEC_OTHR
              , X.TR_OTHER
              , X.TR_OTHER_SPEC
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/TARGET_RECRUITMENT'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         TR_PAID_AD                          CHAR(1)         PATH 'if (TR_PAID_AD/text() = "true") then 1 else 0'
              , TR_PAID_AD_SPEC                   NVARCHAR2(1000) PATH 'string-join(TR_PAID_AD_SPEC/text(), ",")'
              , TR_PAID_AD_SPEC_OTHR              NVARCHAR2(140)  PATH 'TR_PAID_AD_SPEC_OTHR'
              , TR_SCHL_PSTG                      CHAR(1)         PATH 'if (TR_SCHL_PSTG/text() = "true") then 1 else 0'
              , TR_SCHL_PSTG_SPEC                 NVARCHAR2(1000) PATH 'string-join(TR_SCHL_PSTG_SPEC/text(), ",")'
              , TR_SCHL_PSTG_SPEC_OTHR            NVARCHAR2(140)  PATH 'TR_SCHL_PSTG_SPEC_OTHR'
              , TR_SOCIAL_MEDIA                   CHAR(1)         PATH 'if (TR_SOCIAL_MEDIA/text() = "true") then 1 else 0'
              , TR_SOCIAL_MEDIA_SPEC              NVARCHAR2(1000) PATH 'string-join(TR_SOCIAL_MEDIA_SPEC/text(), ",")'
              , TR_SOCIAL_MEDIA_SPEC_OTHR         NVARCHAR2(140)  PATH 'TR_SOCIAL_MEDIA_SPEC_OTHR'
              , TR_OTHER                          CHAR(1)         PATH 'if (TR_OTHER/text() = "true") then 1 else 0'
              , TR_OTHER_SPEC                     NVARCHAR2(500)  PATH 'TR_OTHER_SPEC'

                ) X
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.TR_REQ_ID = TRG.TR_REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.TR_PAID_AD                   = SRC.TR_PAID_AD
          , TRG.TR_PAID_AD_SPEC            = SRC.TR_PAID_AD_SPEC
          , TRG.TR_PAID_AD_SPEC_OTHR       = SRC.TR_PAID_AD_SPEC_OTHR
          , TRG.TR_SCHL_PSTG               = SRC.TR_SCHL_PSTG
          , TRG.TR_SCHL_PSTG_SPEC          = SRC.TR_SCHL_PSTG_SPEC
          , TRG.TR_SCHL_PSTG_SPEC_OTHR     = SRC.TR_SCHL_PSTG_SPEC_OTHR
          , TRG.TR_SOCIAL_MEDIA            = SRC.TR_SOCIAL_MEDIA
          , TRG.TR_SOCIAL_MEDIA_SPEC       = SRC.TR_SOCIAL_MEDIA_SPEC
          , TRG.TR_SOCIAL_MEDIA_SPEC_OTHR  = SRC.TR_SOCIAL_MEDIA_SPEC_OTHR
          , TRG.TR_OTHER                   = SRC.TR_OTHER
          , TRG.TR_OTHER_SPEC              = SRC.TR_OTHER_SPEC
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.TR_REQ_ID
            , TRG.TR_PAID_AD
            , TRG.TR_PAID_AD_SPEC
            , TRG.TR_PAID_AD_SPEC_OTHR
            , TRG.TR_SCHL_PSTG
            , TRG.TR_SCHL_PSTG_SPEC
            , TRG.TR_SCHL_PSTG_SPEC_OTHR
            , TRG.TR_SOCIAL_MEDIA
            , TRG.TR_SOCIAL_MEDIA_SPEC
            , TRG.TR_SOCIAL_MEDIA_SPEC_OTHR
            , TRG.TR_OTHER
            , TRG.TR_OTHER_SPEC
          )
        VALUES
        (
          SRC.TR_REQ_ID
          , SRC.TR_PAID_AD
          , SRC.TR_PAID_AD_SPEC
          , SRC.TR_PAID_AD_SPEC_OTHR
          , SRC.TR_SCHL_PSTG
          , SRC.TR_SCHL_PSTG_SPEC
          , SRC.TR_SCHL_PSTG_SPEC_OTHR
          , SRC.TR_SOCIAL_MEDIA
          , SRC.TR_SOCIAL_MEDIA_SPEC
          , SRC.TR_SOCIAL_MEDIA_SPEC_OTHR
          , SRC.TR_OTHER
          , SRC.TR_OTHER_SPEC
        )
        ;


        --------------------------------
        -- APPROVALS table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    APPROVALS table');
        MERGE INTO APPROVALS TRG
        USING
          (
            SELECT
              V_JOB_REQ_ID AS SCA_REQ_ID
              , X.SCA_SO_SIG
              , X.SCA_SO_SIG_DT
              , X.SCA_CLASS_SPEC_SIG
              , X.SCA_CLASS_SPEC_SIG_DT
              , X.SCA_STAFF_SIG
              , X.SCA_STAFF_SIG_DT
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/APPROVAL'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         SCA_SO_SIG                          NVARCHAR2(100)  PATH 'SCA_SO_SIG'
              , SCA_SO_SIG_DT                     DATE            PATH 'SCA_SO_SIG_DT'
              , SCA_CLASS_SPEC_SIG                NVARCHAR2(100)  PATH 'SCA_CLASS_SPEC_SIG'
              , SCA_CLASS_SPEC_SIG_DT             DATE            PATH 'SCA_CLASS_SPEC_SIG_DT'
              , SCA_STAFF_SIG                     NVARCHAR2(100)  PATH 'SCA_STAFF_SIG'
              , SCA_STAFF_SIG_DT                  DATE            PATH 'SCA_STAFF_SIG_DT'

                ) X
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.SCA_REQ_ID = TRG.SCA_REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.SCA_SO_SIG               = SRC.SCA_SO_SIG
          , TRG.SCA_SO_SIG_DT          = SRC.SCA_SO_SIG_DT
          , TRG.SCA_CLASS_SPEC_SIG     = SRC.SCA_CLASS_SPEC_SIG
          , TRG.SCA_CLASS_SPEC_SIG_DT  = SRC.SCA_CLASS_SPEC_SIG_DT
          , TRG.SCA_STAFF_SIG          = SRC.SCA_STAFF_SIG
          , TRG.SCA_STAFF_SIG_DT       = SRC.SCA_STAFF_SIG_DT
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.SCA_REQ_ID
            , TRG.SCA_SO_SIG
            , TRG.SCA_SO_SIG_DT
            , TRG.SCA_CLASS_SPEC_SIG
            , TRG.SCA_CLASS_SPEC_SIG_DT
            , TRG.SCA_STAFF_SIG
            , TRG.SCA_STAFF_SIG_DT
          )
        VALUES
        (
          SRC.SCA_REQ_ID
          , SRC.SCA_SO_SIG
          , SRC.SCA_SO_SIG_DT
          , SRC.SCA_CLASS_SPEC_SIG
          , SRC.SCA_CLASS_SPEC_SIG_DT
          , SRC.SCA_STAFF_SIG
          , SRC.SCA_STAFF_SIG_DT
        )
        ;


        --------------------------------
        -- Child table update and sync
        --------------------------------
        SP_UPDATE_STRATCONHIST_TABLE(I_PROCID, V_JOB_REQ_ID);


        EXCEPTION
        WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20905, 'SP_UPDATE_STRATCON_TABLE: Invalid STRATCON data.  I_PROCID = '
                                        || TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
      END;

      --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_STRATCON_TABLE - END ==========================');

    END IF;

    EXCEPTION
    WHEN E_INVALID_PROCID THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCON_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
    WHEN E_INVALID_JOB_REQ_ID THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCON_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
    WHEN E_INVALID_STRATCON_DATA THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCON_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    V_ERRCODE := SQLCODE;
    V_ERRMSG := SQLERRM;
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCON_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
    --DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
  END;