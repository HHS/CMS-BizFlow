-- CMS_77_HR_FN_INIT_CLASSIFICATION.sql
-- CMS_93_HR_FN_PARSENAME.sql
-- CMS_100_HR_FN_INIT_ELIGQUAL.sql
-- CMS_123_HR_FN_GET_HIRINGTL_SLA_DAYS.sql
-- CMS_133_HR_FN_GET_HIRINGTL_SLA_DAYS.sql
-- CMS_148_HR_FN_GET_TIMEZONE_OFFSET.sql
-- CMS_148_HR_FN_GET_NEW_TIMEZONE.sql

SET DEFINE OFF;

create or replace FUNCTION FN_INIT_CLASSIFICATION
  (
    I_PROCID                    IN NUMBER
  )
  RETURN XMLTYPE
IS
  V_PARENTPROCID              NUMBER(10);
  V_FIELD_DATA_SRC            XMLTYPE;
  V_FIELD_DATA_TRG            XMLTYPE;
  V_ERRCODE                   NUMBER(10);
  V_ERRMSG                    VARCHAR2(512);
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('------- START: FN_INIT_CLASSIFICATION -------');

    -- get parent procid for Strategic Consultation process to pull data
    SELECT PARENTPROCID INTO V_PARENTPROCID
    FROM BIZFLOW.PROCS
    WHERE PROCID = I_PROCID;

    -- get form data xml
    --SELECT FIELD_DATA INTO V_FIELD_DATA_SRC
    --FROM TBL_FORM_DTL
    --WHERE PROCID = V_PARENTPROCID;


    -- construct initial Classification form data xml from the originating Strategic Consultation data
    --IF V_FIELD_DATA_SRC IS NOT NULL THEN
    --	--DBMS_OUTPUT.PUT_LINE('    V_FIELD_DATA_SRC = ' || V_FIELD_DATA_SRC.GETCLOBVAL());

    SELECT
      XMLQUERY(
          '
            <DOCUMENT>
              <MAIN>
                <SG_CT_ID>{data($sc/DOCUMENT/GENERAL/SG_CT_ID)}</SG_CT_ID>
              </MAIN>
              <GENERAL>
                <CS_TITLE>{data($sc/DOCUMENT/POSITION/POS_TITLE)}</CS_TITLE>
                <CS_PAY_PLAN_ID>{data($sc/DOCUMENT/POSITION/POS_PAY_PLAN_ID)}</CS_PAY_PLAN_ID>
                <CS_SR_ID>{data($sc/DOCUMENT/POSITION/POS_SERIES)}</CS_SR_ID>
                <CS_PD_NUMBER_JOBCD_1>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_1)}</CS_PD_NUMBER_JOBCD_1>
                <CS_CLASSIFICATION_DT_1>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_1)}</CS_CLASSIFICATION_DT_1>
                <CS_GR_ID_1>{data($sc/DOCUMENT/POSITION/POS_GRADE_1)}</CS_GR_ID_1>
                <CS_PD_NUMBER_JOBCD_2>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_2)}</CS_PD_NUMBER_JOBCD_2>
                <CS_CLASSIFICATION_DT_2>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_2)}</CS_CLASSIFICATION_DT_2>
                <CS_GR_ID_2>{data($sc/DOCUMENT/POSITION/POS_GRADE_2)}</CS_GR_ID_2>
                <CS_PD_NUMBER_JOBCD_3>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_3)}</CS_PD_NUMBER_JOBCD_3>
                <CS_CLASSIFICATION_DT_3>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_3)}</CS_CLASSIFICATION_DT_3>
                <CS_GR_ID_3>{data($sc/DOCUMENT/POSITION/POS_GRADE_3)}</CS_GR_ID_3>
                <CS_PD_NUMBER_JOBCD_4>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_4)}</CS_PD_NUMBER_JOBCD_4>
                <CS_CLASSIFICATION_DT_4>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_4)}</CS_CLASSIFICATION_DT_4>
                <CS_GR_ID_4>{data($sc/DOCUMENT/POSITION/POS_GRADE_4)}</CS_GR_ID_4>
                <CS_PD_NUMBER_JOBCD_5>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_5)}</CS_PD_NUMBER_JOBCD_5>
                <CS_CLASSIFICATION_DT_5>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_5)}</CS_CLASSIFICATION_DT_5>
                <CS_GR_ID_5>{data($sc/DOCUMENT/POSITION/POS_GRADE_5)}</CS_GR_ID_5>
                <CS_PERFORMANCE_LEVEL>{data($sc/DOCUMENT/POSITION/POS_PERFORMANCE_LEVEL)}</CS_PERFORMANCE_LEVEL>
                <CS_SUPERVISORY>{data($sc/DOCUMENT/POSITION/POS_SUPERVISORY)}</CS_SUPERVISORY>
                <CS_AC_ID>{data($sc/DOCUMENT/GENERAL/SG_AC_ID)}</CS_AC_ID>
                <CS_ADMIN_CD>{data($sc/DOCUMENT/GENERAL/SG_ADMIN_CD)}</CS_ADMIN_CD>
                <SO_ID>{data($sc/DOCUMENT/GENERAL/SG_SO_ID)}</SO_ID>
                <SO_TITLE>{data($sc/DOCUMENT/GENERAL/SG_SO_TITLE)}</SO_TITLE>
                <SO_ORG>{data($sc/DOCUMENT/GENERAL/SG_SO_ORG)}</SO_ORG>
                <XO_ID>{data($sc/DOCUMENT/GENERAL/SG_XO_ID)}</XO_ID>
                <XO_TITLE>{data($sc/DOCUMENT/GENERAL/SG_XO_TITLE)}</XO_TITLE>
                <XO_ORG>{data($sc/DOCUMENT/GENERAL/SG_XO_ORG)}</XO_ORG>
                <HRL_ID>{data($sc/DOCUMENT/GENERAL/SG_HRL_ID)}</HRL_ID>
                <HRL_TITLE>{data($sc/DOCUMENT/GENERAL/SG_HRL_TITLE)}</HRL_TITLE>
                <HRL_ORG>{data($sc/DOCUMENT/GENERAL/SG_HRL_ORG)}</HRL_ORG>
                <SS_ID>{data($sc/DOCUMENT/GENERAL/SG_SS_ID)}</SS_ID>
                <CS_ID>{data($sc/DOCUMENT/GENERAL/SG_CS_ID)}</CS_ID>
                <STD_PD_TYPE>{data($sc/DOCUMENT/POSITION/POS_STD_PD_TYPE)}</STD_PD_TYPE>
                <POS_INFORMATION>
                  <PD_PCA>{if (contains($molabel, "(PCA)")) then "true" else "false"}</PD_PCA>
                  <PD_PDP>{if (contains($molabel, "(PDP)")) then "true" else "false"}</PD_PDP>
                </POS_INFORMATION>
              </GENERAL>
              <CLASSIFICATION_CODE>
                <CS_FIN_STMT_REQ_ID>{data($sc/DOCUMENT/POSITION/POS_CE_FINANCIAL_TYPE_ID)}</CS_FIN_STMT_REQ_ID>
                <CS_SEC_ID>{data($sc/DOCUMENT/POSITION/POS_SEC_ID)}</CS_SEC_ID>
              </CLASSIFICATION_CODE>
              <APPROVAL></APPROVAL>
            </DOCUMENT>
          '
          -- WARNING: Oracle 12c causes problem ($molabel variable empty)
          -- with passing XMLTYPE variable (V_FIELD_DATA_SRC) for some reason.
          -- So, use table join and pass the XMLTYPE column (FD.FIELD_DATA), instead.
          --PASSING V_FIELD_DATA_SRC AS "sc", LUMO.TBL_LABEL AS "molabel"
          PASSING FD.FIELD_DATA AS "sc", LUMO.TBL_LABEL AS "molabel"
          RETURNING CONTENT
      ) INTO V_FIELD_DATA_TRG
    FROM
      TBL_FORM_DTL FD
      , XMLTABLE('/DOCUMENT/POSITION' PASSING FD.FIELD_DATA
                 COLUMNS
                 POS_JOB_REQ_NUMBER     NVARCHAR2(10)  PATH 'POS_JOB_REQ_NUMBER'
    , POS_MED_OFFICERS_ID  NUMBER(20)     PATH 'POS_MED_OFFICERS_ID'
        ) MO
      LEFT OUTER JOIN TBL_LOOKUP LUMO ON LUMO.TBL_ID = MO.POS_MED_OFFICERS_ID
    WHERE
      1=1
      AND FD.PROCID = V_PARENTPROCID
      AND XMLEXISTS('data($sc/DOCUMENT/POSITION)' PASSING FD.FIELD_DATA AS "sc")
    ;
    --END IF;

    --DBMS_OUTPUT.PUT_LINE('    V_FIELD_DATA_TRG = ' || V_FIELD_DATA_TRG.GETCLOBVAL());
    --DBMS_OUTPUT.PUT_LINE('------- END: FN_INIT_CLASSIFICATION -------');
    RETURN V_FIELD_DATA_TRG;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    V_ERRCODE := SQLCODE;
    V_ERRMSG := SQLERRM;
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing classification initialization -------------------');
    --DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
    --DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
    RETURN NULL;
  END;
/

GRANT EXECUTE ON HHS_CMS_HR.FN_INIT_CLASSIFICATION TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.FN_INIT_CLASSIFICATION TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_INIT_CLASSIFICATION TO HHS_CMS_HR_DEV_ROLE;


CREATE OR REPLACE FUNCTION HHS_CMS_HR.FN_PARSENAME 
(
  I_FULLNAME IN VARCHAR2 
, I_NAMEFORMAT IN VARCHAR2 
) RETURN VARCHAR2 AS

    FORMATTED_NAME VARCHAR2(1000);
    FULL_NAME VARCHAR2(1000);
    FIRST_NAME VARCHAR2(200);
    MIDDLE_NAME VARCHAR2(200);
    LAST_NAME VARCHAR2(200);
    LAST_NAME2 VARCHAR2(200);
    LAST_NAME_INITIAL VARCHAR2(10);
    SUFFIX_NAME VARCHAR2(200);
    IDX_COMMA INTEGER;
    IDX_SPACE INTEGER;

BEGIN

    IF I_FULLNAME IS NOT NULL THEN
        BEGIN    

            SELECT REPLACE(I_FULLNAME, '  ', '')
              INTO FULL_NAME
              FROM DUAL;

            SELECT INSTR(FULL_NAME, ',')
              INTO IDX_COMMA
              FROM DUAL;

            SELECT INSTR(FULL_NAME, ' ')
              INTO IDX_SPACE
              FROM DUAL;

            IF (IDX_COMMA > 0) THEN
                --FORMATTED_NAME := 'COMMA';

                SELECT REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,1),
                      REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,2),
                      REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,3),
                      TRANSLATE(REGEXP_SUBSTR(FULL_NAME,'( |\.|,)(JR|MR|MS|SR)(\.|,|$)',1,1),'A ,.','A')
                  INTO
                        LAST_NAME
                        ,FIRST_NAME
                        ,MIDDLE_NAME
                        ,SUFFIX_NAME
                  FROM DUAL;

            ELSE

                IF (IDX_SPACE > 0) THEN
                    SELECT REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,1),
                          REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,2),
                          REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,3),
                          TRANSLATE(REGEXP_SUBSTR(FULL_NAME,'( |\.|,)(JR|MR|MS|SR)(\.|,|$)',1,1),'A ,.','A')
                      INTO
                            FIRST_NAME
                            ,MIDDLE_NAME
                            ,LAST_NAME
                            ,SUFFIX_NAME
                      FROM DUAL;
                ELSE
                    LAST_NAME := FULL_NAME;
                    FIRST_NAME := '';
                    MIDDLE_NAME := '';
                    SUFFIX_NAME := '';

                END IF;

            END IF;

            --Exception Cases
            IF LAST_NAME IS NULL AND MIDDLE_NAME IS NOT NULL THEN
                LAST_NAME := MIDDLE_NAME;
                MIDDLE_NAME := '';
            END IF;

            IF MIDDLE_NAME = SUFFIX_NAME THEN
                MIDDLE_NAME := '';
            END IF;            

            IF LAST_NAME = SUFFIX_NAME THEN
                LAST_NAME := MIDDLE_NAME;
                MIDDLE_NAME := '';
            END IF;

            IF LAST_NAME = SUFFIX_NAME THEN
                LAST_NAME := MIDDLE_NAME;
                MIDDLE_NAME := '';
            END IF;

        END;    
    ELSE
        FORMATTED_NAME := '';
    END IF;

    SUFFIX_NAME := TRIM(NVL(SUFFIX_NAME, ''));
    
    IF INSTR(LAST_NAME, '-') > 0 THEN
        LAST_NAME2 := SUBSTR(LAST_NAME, INSTR(LAST_NAME, '-'));
        LAST_NAME_INITIAL := UPPER(SUBSTR(LAST_NAME, 1,1)) || UPPER(SUBSTR(LAST_NAME2, 2,1));
    ELSE
        LAST_NAME_INITIAL := UPPER(SUBSTR(LAST_NAME, 1,1));
    END IF;
    
    IF (I_NAMEFORMAT = 'FULL') THEN

        IF (SUFFIX_NAME IS NOT NULL) THEN
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME || '.' || SUFFIX_NAME;
        ELSE
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME;
        END IF;

    ELSIF (I_NAMEFORMAT = 'INITIAL') THEN
        
        FORMATTED_NAME := UPPER(SUBSTR(FIRST_NAME,1,1)) || LAST_NAME_INITIAL;
        
    ELSIF (I_NAMEFORMAT = 'FULL+INITIAL') THEN
        IF (SUFFIX_NAME IS NOT NULL) THEN
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME || '.' || SUFFIX_NAME || ' [' || LAST_NAME_INITIAL || ']';
        ELSE
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME || ' [' || LAST_NAME_INITIAL || ']';
        END IF;
    ELSE
        IF (SUFFIX_NAME IS NOT NULL) THEN
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME || '.' || SUFFIX_NAME;
        ELSE
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME;
        END IF;

    END IF;

    RETURN FORMATTED_NAME;

END FN_PARSENAME;
/

GRANT EXECUTE ON HHS_CMS_HR.FN_PARSENAME TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.FN_PARSENAME TO HHS_CMS_HR_RW_ROLE ;
GRANT EXECUTE ON HHS_CMS_HR.FN_PARSENAME TO HHS_CMS_HR_DEV_ROLE ;
/

create or replace FUNCTION FN_INIT_ELIGQUAL
  (
    I_PROCID                    IN NUMBER
  )
  RETURN XMLTYPE
IS
  V_PARENTPROCID              NUMBER(10);
  V_PARENTPROCNAME            VARCHAR2(100);
  V_PARENT_STRATCON_PROCID    NUMBER(10);
  V_PARENT_CLSF_PROCID        NUMBER(10);
  V_FIELD_DATA_SRC            XMLTYPE;
  V_FIELD_DATA_TRG            XMLTYPE;
  V_ERRCODE                   NUMBER(10);
  V_ERRMSG                    VARCHAR2(512);
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('------- START: FN_INIT_ELIGQUAL -------');

    -- get parent procid to pull data from
    BEGIN
      SELECT PARENTPROCID INTO V_PARENTPROCID
      FROM BIZFLOW.PROCS
      WHERE PROCID = I_PROCID;
      EXCEPTION
      WHEN OTHERS THEN
      SP_ERROR_LOG();
      V_PARENTPROCID := NULL;
    END;

    -- if no parent to inherit data from, just return
    IF V_PARENTPROCID IS NULL THEN
      RETURN NULL;
    END IF;

    -- check whether the immediate parent is STRATCON or CLSF
    BEGIN
      SELECT PD.NAME INTO V_PARENTPROCNAME
      FROM BIZFLOW.PROCDEF PD INNER JOIN BIZFLOW.PROCS P ON P.ORGPROCDEFID = PD.ORGPROCDEFID
      WHERE PD.ISFINAL = 'T' AND PD.ENVTYPE = 'O' AND P.PROCID = V_PARENTPROCID;
      EXCEPTION
      WHEN OTHERS THEN
      SP_ERROR_LOG();
      V_PARENTPROCNAME := NULL;
    END;

    -- construct initial Eligiblity and Qualification form data xml
    -- from the originating parent process instance data
    IF V_PARENTPROCNAME = 'Strategic Consultation' THEN
      -- construct ELIGQUAL xml from parent STRATCON
      SELECT
        XMLQUERY(
            '
            <DOCUMENT>
              <GENERAL>
                <ADMIN_CD>{             data($sc/DOCUMENT/GENERAL/SG_ADMIN_CD)}</ADMIN_CD>
                <RT_ID>{                data($sc/DOCUMENT/GENERAL/SG_RT_ID)}</RT_ID>
                <AT_ID>{                data($sc/DOCUMENT/GENERAL/SG_AT_ID)}</AT_ID>
                <VT_ID>{                data($sc/DOCUMENT/GENERAL/SG_VT_ID)}</VT_ID>
                <SAT_ID>{               data($sc/DOCUMENT/GENERAL/SG_SAT_ID)}</SAT_ID>
                <CT_ID>{                data($sc/DOCUMENT/GENERAL/SG_CT_ID)}</CT_ID>
                <SO_ID>{                data($sc/DOCUMENT/GENERAL/SG_SO_ID)}</SO_ID>
                <XO_ID>{                data($sc/DOCUMENT/GENERAL/SG_XO_ID)}</XO_ID>
                <HRL_ID>{               data($sc/DOCUMENT/GENERAL/SG_HRL_ID)}</HRL_ID>
                <SS_ID>{                data($sc/DOCUMENT/GENERAL/SG_SS_ID)}</SS_ID>
                <CS_ID>{                data($sc/DOCUMENT/GENERAL/SG_CS_ID)}</CS_ID>
                <SO_AGREE>{             data($sc/DOCUMENT/GENERAL/SG_SO_AGREE)}</SO_AGREE>
                <OTHER_CERT>{           data($sc/DOCUMENT/GENERAL/SG_OTHER_CERT)}</OTHER_CERT>
              </GENERAL>
              <POSITION>
                <POS_ID>{               data($sc/DOCUMENT/POSITION/POS_ID)}</POS_ID>
                <CNDT_LAST_NM>{         data($sc/DOCUMENT/POSITION/POS_CNDT_LAST_NM)}</CNDT_LAST_NM>
                <CNDT_FIRST_NM>{        data($sc/DOCUMENT/POSITION/POS_CNDT_FIRST_NM)}</CNDT_FIRST_NM>
                <CNDT_MIDDLE_NM>{       data($sc/DOCUMENT/POSITION/POS_CNDT_MIDDLE_NM)}</CNDT_MIDDLE_NM>
                <BGT_APR_OFM>{          data($sc/DOCUMENT/POSITION/POS_BGT_APR_OFM)}</BGT_APR_OFM>
                <SPNSR_ORG_NM>{         data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_NM)}</SPNSR_ORG_NM>
                <SPNSR_ORG_FUND_PC>{    data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_FUND_PC)}</SPNSR_ORG_FUND_PC>
                <JOB_REQ_NUMBER>{       data($sc/DOCUMENT/POSITION/POS_JOB_REQ_NUMBER)}</JOB_REQ_NUMBER>
                <JOB_REQ_CREATE_DT>{    data($sc/DOCUMENT/POSITION/POS_JOB_REQ_CREATE_DT)}</JOB_REQ_CREATE_DT>
                <POS_TITLE>{            data($sc/DOCUMENT/POSITION/POS_TITLE)}</POS_TITLE>
                <PAY_PLAN_ID>{          data($sc/DOCUMENT/POSITION/POS_PAY_PLAN_ID)}</PAY_PLAN_ID>
                <SERIES>{               data($sc/DOCUMENT/POSITION/POS_SERIES)}</SERIES>
                <POS_DESC_NUMBER_1>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_1)}</POS_DESC_NUMBER_1>
                <CLASSIFICATION_DT_1>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_1)}</CLASSIFICATION_DT_1>
                <GRADE_1>{              data($sc/DOCUMENT/POSITION/POS_GRADE_1)}</GRADE_1>
                <POS_DESC_NUMBER_2>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_2)}</POS_DESC_NUMBER_2>
                <CLASSIFICATION_DT_2>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_2)}</CLASSIFICATION_DT_2>
                <GRADE_2>{              data($sc/DOCUMENT/POSITION/POS_GRADE_2)}</GRADE_2>
                <POS_DESC_NUMBER_3>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_3)}</POS_DESC_NUMBER_3>
                <CLASSIFICATION_DT_3>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_3)}</CLASSIFICATION_DT_3>
                <GRADE_3>{              data($sc/DOCUMENT/POSITION/POS_GRADE_3)}</GRADE_3>
                <POS_DESC_NUMBER_4>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_4)}</POS_DESC_NUMBER_4>
                <CLASSIFICATION_DT_4>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_4)}</CLASSIFICATION_DT_4>
                <GRADE_4>{              data($sc/DOCUMENT/POSITION/POS_GRADE_4)}</GRADE_4>
                <POS_DESC_NUMBER_5>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_5)}</POS_DESC_NUMBER_5>
                <CLASSIFICATION_DT_5>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_5)}</CLASSIFICATION_DT_5>
                <GRADE_5>{              data($sc/DOCUMENT/POSITION/POS_GRADE_5)}</GRADE_5>
                <PERFORMANCE_LEVEL>{    data($sc/DOCUMENT/POSITION/POS_PERFORMANCE_LEVEL)}</PERFORMANCE_LEVEL>
                <SUPERVISORY>{          data($sc/DOCUMENT/POSITION/POS_SUPERVISORY)}</SUPERVISORY>
                <MED_OFFICERS_ID>{      data($sc/DOCUMENT/POSITION/POS_MED_OFFICERS_ID)}</MED_OFFICERS_ID>
                <SKILL>{                data($sc/DOCUMENT/POSITION/POS_SKILL)}</SKILL>
                <GRADES_ADVERTISED>{    data($sc/DOCUMENT/POSITION/POS_GRADES_ADVERTISED)}</GRADES_ADVERTISED>
                <LOCATION>{             data($sc/DOCUMENT/POSITION/POS_LOCATION)}</LOCATION>
                            <POS_LOCATION_DSCR>{    data($sc/DOCUMENT/POSITION/POS_LOCATION_DSCR)}</POS_LOCATION_DSCR>
                <VACANCIES>{            data($sc/DOCUMENT/POSITION/POS_VACANCIES)}</VACANCIES>
                <REPORT_SUPERVISOR>{    data($sc/DOCUMENT/POSITION/POS_REPORT_SUPERVISOR)}</REPORT_SUPERVISOR>
                <CAN>{                  data($sc/DOCUMENT/POSITION/POS_CAN)}</CAN>
                <VICE>{                 data($sc/DOCUMENT/POSITION/POS_VICE)}</VICE>
                <VICE_NAME>{            data($sc/DOCUMENT/POSITION/POS_VICE_NAME)}</VICE_NAME>
                <DAYS_ADVERTISED>{      data($sc/DOCUMENT/POSITION/POS_DAYS_ADVERTISED)}</DAYS_ADVERTISED>
                <TA_ID>{                data($sc/DOCUMENT/POSITION/POS_AT_ID)}</TA_ID>
                <NTE>{                  data($sc/DOCUMENT/POSITION/POS_NTE)}</NTE>
                <WORK_SCHED_ID>{        data($sc/DOCUMENT/POSITION/POS_WORK_SCHED_ID)}</WORK_SCHED_ID>
                <HOURS_PER_WEEK>{       data($sc/DOCUMENT/POSITION/POS_HOURS_PER_WEEK)}</HOURS_PER_WEEK>
                <DUAL_EMPLMT>{          data($sc/DOCUMENT/POSITION/POS_DUAL_EMPLMT)}</DUAL_EMPLMT>
                <SEC_ID>{               data($sc/DOCUMENT/POSITION/POS_SEC_ID)}</SEC_ID>
                <CE_FINANCIAL_DISC>{    data($sc/DOCUMENT/POSITION/POS_CE_FINANCIAL_DISC)}</CE_FINANCIAL_DISC>
                <CE_FINANCIAL_TYPE_ID>{ data($sc/DOCUMENT/POSITION/POS_CE_FINANCIAL_TYPE_ID)}</CE_FINANCIAL_TYPE_ID>
                <CE_PE_PHYSICAL>{       data($sc/DOCUMENT/POSITION/POS_CE_PE_PHYSICAL)}</CE_PE_PHYSICAL>
                <CE_DRUG_TEST>{         data($sc/DOCUMENT/POSITION/POS_CE_DRUG_TEST)}</CE_DRUG_TEST>
                <CE_IMMUN>{             data($sc/DOCUMENT/POSITION/POS_CE_IMMUN)}</CE_IMMUN>
                <CE_TRAVEL>{            data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL)}</CE_TRAVEL>
                <CE_TRAVEL_PER>{        data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL_PER)}</CE_TRAVEL_PER>
                <CE_LIC>{               data($sc/DOCUMENT/POSITION/POS_CE_LIC)}</CE_LIC>
                <CE_LIC_INFO>{          data($sc/DOCUMENT/POSITION/POS_CE_LIC_INFO)}</CE_LIC_INFO>
                <REMARKS>{              data($sc/DOCUMENT/POSITION/POS_REMARKS)}</REMARKS>
                <PROC_REQ_TYPE>{        data($sc/DOCUMENT/POSITION/POS_PROC_REQ_TYPE)}</PROC_REQ_TYPE>
                <RECRUIT_OFFICE_ID>{    data($sc/DOCUMENT/POSITION/POS_RECRUIT_OFFICE_ID)}</RECRUIT_OFFICE_ID>
                <REQ_ID>{               data($sc/DOCUMENT/POSITION/POS_REQ_ID)}</REQ_ID>
                <REQ_CREATE_NOTIFY_DT>{ data($sc/DOCUMENT/POSITION/POS_REQ_CREATE_NOTIFY_DT)}</REQ_CREATE_NOTIFY_DT>
                <ASSOC_DESCR_NUMBERS>{  data($sc/DOCUMENT/POSITION/POS_ASSOC_DESCR_NUMBERS)}</ASSOC_DESCR_NUMBERS>
                <PROMOTE_POTENTIAL>{    data($sc/DOCUMENT/POSITION/POS_PROMOTE_POTENTIAL)}</PROMOTE_POTENTIAL>
                <VICE_EMPL_ID>{         data($sc/DOCUMENT/POSITION/POS_VICE_EMPL_ID)}</VICE_EMPL_ID>
                <SR_ID>{                data($sc/DOCUMENT/POSITION/POS_SR_ID)}</SR_ID>
                <GR_ID>{                data($sc/DOCUMENT/POSITION/POS_GR_ID)}</GR_ID>
                <STATUS_ID>{            data($sc/DOCUMENT/POSITION/POS_STATUS_ID)}</STATUS_ID>
                <SC_REQUESTED>{         data($sc/DOCUMENT/POSITION/POS_SC_REQUESTED)}</SC_REQUESTED>
                <SG_ID>{                data($sc/DOCUMENT/POSITION/POS_SG_ID)}</SG_ID>
                <PD_ID>{                data($sc/DOCUMENT/POSITION/POS_PD_ID)}</PD_ID>
                <GRADE_ADVERTISED>
                  <GA_1>{ data($sc/DOCUMENT/POSITION/POS_GA_1)}</GA_1>
                  <GA_2>{ data($sc/DOCUMENT/POSITION/POS_GA_2)}</GA_2>
                  <GA_3>{ data($sc/DOCUMENT/POSITION/POS_GA_3)}</GA_3>
                  <GA_4>{ data($sc/DOCUMENT/POSITION/POS_GA_4)}</GA_4>
                  <GA_5>{ data($sc/DOCUMENT/POSITION/POS_GA_5)}</GA_5>
                  <GA_6>{ data($sc/DOCUMENT/POSITION/POS_GA_6)}</GA_6>
                  <GA_7>{ data($sc/DOCUMENT/POSITION/POS_GA_7)}</GA_7>
                  <GA_8>{ data($sc/DOCUMENT/POSITION/POS_GA_8)}</GA_8>
                  <GA_9>{ data($sc/DOCUMENT/POSITION/POS_GA_9)}</GA_9>
                  <GA_10>{data($sc/DOCUMENT/POSITION/POS_GA_10)}</GA_10>
                  <GA_11>{data($sc/DOCUMENT/POSITION/POS_GA_11)}</GA_11>
                  <GA_12>{data($sc/DOCUMENT/POSITION/POS_GA_12)}</GA_12>
                  <GA_13>{data($sc/DOCUMENT/POSITION/POS_GA_13)}</GA_13>
                  <GA_14>{data($sc/DOCUMENT/POSITION/POS_GA_14)}</GA_14>
                  <GA_15>{data($sc/DOCUMENT/POSITION/POS_GA_15)}</GA_15>
                </GRADE_ADVERTISED>
              </POSITION>
            </DOCUMENT>
            '
            PASSING FD.FIELD_DATA AS "sc"
            RETURNING CONTENT
        ) INTO V_FIELD_DATA_TRG
      FROM
        TBL_FORM_DTL FD
      WHERE
        1=1
        AND FD.PROCID = V_PARENTPROCID
        AND XMLEXISTS('data($sc/DOCUMENT/POSITION)' PASSING FD.FIELD_DATA AS "sc")
      ;
    ELSIF V_PARENTPROCNAME = 'Classification' THEN
      V_PARENT_CLSF_PROCID := V_PARENTPROCID;
      -- get procid for Strategic Consultation process which is parent of
      -- Classification process to pull data from
      BEGIN
        SELECT PARENTPROCID INTO V_PARENT_STRATCON_PROCID
        FROM BIZFLOW.PROCS
        WHERE PROCID = V_PARENT_CLSF_PROCID;
        EXCEPTION
        WHEN OTHERS THEN
        SP_ERROR_LOG();
        V_PARENT_STRATCON_PROCID := NULL;
      END;

      -- construct ELIGQUAL xml from grandparent STRATCON and parent CLSF
      SELECT
        XMLQUERY(
            '
              <DOCUMENT>
                <GENERAL>
                  <ADMIN_CD>{             data($cl/DOCUMENT/GENERAL/CS_ADMIN_CD)}</ADMIN_CD>
                  <RT_ID>{                data($sc/DOCUMENT/GENERAL/SG_RT_ID)}</RT_ID>
                  <AT_ID>{                data($sc/DOCUMENT/GENERAL/SG_AT_ID)}</AT_ID>
                  <VT_ID>{                data($sc/DOCUMENT/GENERAL/SG_VT_ID)}</VT_ID>
                  <SAT_ID>{               data($sc/DOCUMENT/GENERAL/SG_SAT_ID)}</SAT_ID>
                  <CT_ID>{                data($sc/DOCUMENT/GENERAL/SG_CT_ID)}</CT_ID>
                  <SO_ID>{                data($sc/DOCUMENT/GENERAL/SG_SO_ID)}</SO_ID>
                  <XO_ID>{                data($sc/DOCUMENT/GENERAL/SG_XO_ID)}</XO_ID>
                  <HRL_ID>{               data($sc/DOCUMENT/GENERAL/SG_HRL_ID)}</HRL_ID>
                  <SS_ID>{                data($cl/DOCUMENT/GENERAL/SS_ID)}</SS_ID>
                  <CS_ID>{                data($sc/DOCUMENT/GENERAL/SG_CS_ID)}</CS_ID>
                  <SO_AGREE>{             data($sc/DOCUMENT/GENERAL/SG_SO_AGREE)}</SO_AGREE>
                  <OTHER_CERT>{           data($sc/DOCUMENT/GENERAL/SG_OTHER_CERT)}</OTHER_CERT>
                </GENERAL>
                <POSITION>
                  <POS_ID>{               data($sc/DOCUMENT/POSITION/POS_ID)}</POS_ID>
                  <CNDT_LAST_NM>{         data($sc/DOCUMENT/POSITION/POS_CNDT_LAST_NM)}</CNDT_LAST_NM>
                  <CNDT_FIRST_NM>{        data($sc/DOCUMENT/POSITION/POS_CNDT_FIRST_NM)}</CNDT_FIRST_NM>
                  <CNDT_MIDDLE_NM>{       data($sc/DOCUMENT/POSITION/POS_CNDT_MIDDLE_NM)}</CNDT_MIDDLE_NM>
                  <BGT_APR_OFM>{          data($sc/DOCUMENT/POSITION/POS_BGT_APR_OFM)}</BGT_APR_OFM>
                  <SPNSR_ORG_NM>{         data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_NM)}</SPNSR_ORG_NM>
                  <SPNSR_ORG_FUND_PC>{    data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_FUND_PC)}</SPNSR_ORG_FUND_PC>
                  <JOB_REQ_NUMBER>{       data($sc/DOCUMENT/POSITION/POS_JOB_REQ_NUMBER)}</JOB_REQ_NUMBER>
                  <JOB_REQ_CREATE_DT>{    data($sc/DOCUMENT/POSITION/POS_JOB_REQ_CREATE_DT)}</JOB_REQ_CREATE_DT>

                  <POS_TITLE>{            data($cl/DOCUMENT/GENERAL/CS_TITLE)}</POS_TITLE>
                  <PAY_PLAN_ID>{          data($cl/DOCUMENT/GENERAL/CS_PAY_PLAN_ID)}</PAY_PLAN_ID>
                  <SERIES>{               data($cl/DOCUMENT/GENERAL/CS_SR_ID)}</SERIES>
                  <POS_DESC_NUMBER_1>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_1)}</POS_DESC_NUMBER_1>
                  <CLASSIFICATION_DT_1>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_1)}</CLASSIFICATION_DT_1>
                  <GRADE_1>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_1)}</GRADE_1>
                  <POS_DESC_NUMBER_2>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_2)}</POS_DESC_NUMBER_2>
                  <CLASSIFICATION_DT_2>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_2)}</CLASSIFICATION_DT_2>
                  <GRADE_2>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_2)}</GRADE_2>
                  <POS_DESC_NUMBER_3>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_3)}</POS_DESC_NUMBER_3>
                  <CLASSIFICATION_DT_3>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_3)}</CLASSIFICATION_DT_3>
                  <GRADE_3>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_3)}</GRADE_3>
                  <POS_DESC_NUMBER_4>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_4)}</POS_DESC_NUMBER_4>
                  <CLASSIFICATION_DT_4>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_4)}</CLASSIFICATION_DT_4>
                  <GRADE_4>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_4)}</GRADE_4>
                  <POS_DESC_NUMBER_5>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_5)}</POS_DESC_NUMBER_5>
                  <CLASSIFICATION_DT_5>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_5)}</CLASSIFICATION_DT_5>
                  <GRADE_5>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_5)}</GRADE_5>
                  <PERFORMANCE_LEVEL>{    data($cl/DOCUMENT/GENERAL/CS_PERFORMANCE_LEVEL)}</PERFORMANCE_LEVEL>
                  <SUPERVISORY>{          data($cl/DOCUMENT/GENERAL/CS_SUPERVISORY)}</SUPERVISORY>

                  <MED_OFFICERS_ID>{      $moid }</MED_OFFICERS_ID>

                  <SKILL>{                data($sc/DOCUMENT/POSITION/POS_SKILL)}</SKILL>
                  <GRADES_ADVERTISED>{    data($sc/DOCUMENT/POSITION/POS_GRADES_ADVERTISED)}</GRADES_ADVERTISED>
                  <LOCATION>{             data($sc/DOCUMENT/POSITION/POS_LOCATION)}</LOCATION>
                                <POS_LOCATION_DSCR>{    data($sc/DOCUMENT/POSITION/POS_LOCATION_DSCR)}</POS_LOCATION_DSCR>
                  <VACANCIES>{            data($sc/DOCUMENT/POSITION/POS_VACANCIES)}</VACANCIES>
                  <REPORT_SUPERVISOR>{    data($sc/DOCUMENT/POSITION/POS_REPORT_SUPERVISOR)}</REPORT_SUPERVISOR>
                  <CAN>{                  data($sc/DOCUMENT/POSITION/POS_CAN)}</CAN>
                  <VICE>{                 data($sc/DOCUMENT/POSITION/POS_VICE)}</VICE>
                  <VICE_NAME>{            data($sc/DOCUMENT/POSITION/POS_VICE_NAME)}</VICE_NAME>
                  <DAYS_ADVERTISED>{      data($sc/DOCUMENT/POSITION/POS_DAYS_ADVERTISED)}</DAYS_ADVERTISED>
                  <TA_ID>{                data($sc/DOCUMENT/POSITION/POS_AT_ID)}</TA_ID>
                  <NTE>{                  data($sc/DOCUMENT/POSITION/POS_NTE)}</NTE>
                  <WORK_SCHED_ID>{        data($sc/DOCUMENT/POSITION/POS_WORK_SCHED_ID)}</WORK_SCHED_ID>
                  <HOURS_PER_WEEK>{       data($sc/DOCUMENT/POSITION/POS_HOURS_PER_WEEK)}</HOURS_PER_WEEK>
                  <DUAL_EMPLMT>{          data($sc/DOCUMENT/POSITION/POS_DUAL_EMPLMT)}</DUAL_EMPLMT>

                  <SEC_ID>{               data($cl/DOCUMENT/CLASSIFICATION_CODE/CS_SEC_ID)}</SEC_ID>
                  <CE_FINANCIAL_DISC>{    if (not(data($cl/DOCUMENT/CLASSIFICATION_CODE/CS_FIN_STMT_REQ_ID) = "")) then "true" else "false" }</CE_FINANCIAL_DISC>
                  <CE_FINANCIAL_TYPE_ID>{ data($cl/DOCUMENT/CLASSIFICATION_CODE/CS_FIN_STMT_REQ_ID)}</CE_FINANCIAL_TYPE_ID>

                  <CE_PE_PHYSICAL>{       data($sc/DOCUMENT/POSITION/POS_CE_PE_PHYSICAL)}</CE_PE_PHYSICAL>
                  <CE_DRUG_TEST>{         data($sc/DOCUMENT/POSITION/POS_CE_DRUG_TEST)}</CE_DRUG_TEST>
                  <CE_IMMUN>{             data($sc/DOCUMENT/POSITION/POS_CE_IMMUN)}</CE_IMMUN>
                  <CE_TRAVEL>{            data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL)}</CE_TRAVEL>
                  <CE_TRAVEL_PER>{        data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL_PER)}</CE_TRAVEL_PER>
                  <CE_LIC>{               data($sc/DOCUMENT/POSITION/POS_CE_LIC)}</CE_LIC>
                  <CE_LIC_INFO>{          data($sc/DOCUMENT/POSITION/POS_CE_LIC_INFO)}</CE_LIC_INFO>
                  <REMARKS>{              data($sc/DOCUMENT/POSITION/POS_REMARKS)}</REMARKS>
                  <PROC_REQ_TYPE>{        data($sc/DOCUMENT/POSITION/POS_PROC_REQ_TYPE)}</PROC_REQ_TYPE>
                  <RECRUIT_OFFICE_ID>{    data($sc/DOCUMENT/POSITION/POS_RECRUIT_OFFICE_ID)}</RECRUIT_OFFICE_ID>
                  <REQ_ID>{               data($sc/DOCUMENT/POSITION/POS_REQ_ID)}</REQ_ID>
                  <REQ_CREATE_NOTIFY_DT>{ data($sc/DOCUMENT/POSITION/POS_REQ_CREATE_NOTIFY_DT)}</REQ_CREATE_NOTIFY_DT>
                  <ASSOC_DESCR_NUMBERS>{  data($sc/DOCUMENT/POSITION/POS_ASSOC_DESCR_NUMBERS)}</ASSOC_DESCR_NUMBERS>
                  <PROMOTE_POTENTIAL>{    data($sc/DOCUMENT/POSITION/POS_PROMOTE_POTENTIAL)}</PROMOTE_POTENTIAL>
                  <VICE_EMPL_ID>{         data($sc/DOCUMENT/POSITION/POS_VICE_EMPL_ID)}</VICE_EMPL_ID>
                  <SR_ID>{                data($sc/DOCUMENT/POSITION/POS_SR_ID)}</SR_ID>
                  <GR_ID>{                data($sc/DOCUMENT/POSITION/POS_GR_ID)}</GR_ID>
                  <STATUS_ID>{            data($sc/DOCUMENT/POSITION/POS_STATUS_ID)}</STATUS_ID>
                  <SC_REQUESTED>{         data($sc/DOCUMENT/POSITION/POS_SC_REQUESTED)}</SC_REQUESTED>
                  <SG_ID>{                data($sc/DOCUMENT/POSITION/POS_SG_ID)}</SG_ID>
                  <PD_ID>{                data($sc/DOCUMENT/POSITION/POS_PD_ID)}</PD_ID>
                  <GRADE_ADVERTISED>
                    <GA_1>{ data($sc/DOCUMENT/POSITION/POS_GA_1)}</GA_1>
                    <GA_2>{ data($sc/DOCUMENT/POSITION/POS_GA_2)}</GA_2>
                    <GA_3>{ data($sc/DOCUMENT/POSITION/POS_GA_3)}</GA_3>
                    <GA_4>{ data($sc/DOCUMENT/POSITION/POS_GA_4)}</GA_4>
                    <GA_5>{ data($sc/DOCUMENT/POSITION/POS_GA_5)}</GA_5>
                    <GA_6>{ data($sc/DOCUMENT/POSITION/POS_GA_6)}</GA_6>
                    <GA_7>{ data($sc/DOCUMENT/POSITION/POS_GA_7)}</GA_7>
                    <GA_8>{ data($sc/DOCUMENT/POSITION/POS_GA_8)}</GA_8>
                    <GA_9>{ data($sc/DOCUMENT/POSITION/POS_GA_9)}</GA_9>
                    <GA_10>{data($sc/DOCUMENT/POSITION/POS_GA_10)}</GA_10>
                    <GA_11>{data($sc/DOCUMENT/POSITION/POS_GA_11)}</GA_11>
                    <GA_12>{data($sc/DOCUMENT/POSITION/POS_GA_12)}</GA_12>
                    <GA_13>{data($sc/DOCUMENT/POSITION/POS_GA_13)}</GA_13>
                    <GA_14>{data($sc/DOCUMENT/POSITION/POS_GA_14)}</GA_14>
                    <GA_15>{data($sc/DOCUMENT/POSITION/POS_GA_15)}</GA_15>
                  </GRADE_ADVERTISED>
                </POSITION>
              </DOCUMENT>
            '
            PASSING FDSC.FIELD_DATA AS "sc", FDCL.FIELD_DATA AS "cl", LUMO.MED_OFFICERS_ID AS "moid"
            RETURNING CONTENT
        ) INTO V_FIELD_DATA_TRG
      FROM
        TBL_FORM_DTL FDSC
        , TBL_FORM_DTL FDCL
        , XMLTABLE('/DOCUMENT/GENERAL/POS_INFORMATION' PASSING FDCL.FIELD_DATA
                   COLUMNS
                   PD_PCA                 VARCHAR2(10)   PATH 'PD_PCA'
      , PD_PDP               VARCHAR2(10)   PATH 'PD_PDP'
          ) MO
        LEFT OUTER JOIN (
                          SELECT
                              TBL_ID AS MED_OFFICERS_ID
                            , TBL_LABEL AS MED_OFFICERS_DSCR
                            , CASE WHEN TBL_LABEL LIKE '%(PCA)%' THEN 'true' ELSE 'false' END AS PD_PCA
                            , CASE WHEN TBL_LABEL LIKE '%(PDP)%' THEN 'true' ELSE 'false' END AS PD_PDP
                          FROM TBL_LOOKUP
                          WHERE TBL_LTYPE = 'MedicalOfficer'
                        ) LUMO ON LUMO.PD_PCA = MO.PD_PCA AND LUMO.PD_PDP = MO.PD_PDP
      WHERE
        1=1
        AND FDSC.FORM_TYPE = 'CMSSTRATCON'
        AND FDSC.PROCID = V_PARENT_STRATCON_PROCID
        AND FDCL.FORM_TYPE = 'CMSCLSF'
        AND FDCL.PROCID = V_PARENT_CLSF_PROCID
      ;
    ELSE
      RETURN NULL;  -- no parent name --> something went wrong
    END IF;


    --DBMS_OUTPUT.PUT_LINE('    V_FIELD_DATA_TRG = ' || V_FIELD_DATA_TRG.GETCLOBVAL());
    --DBMS_OUTPUT.PUT_LINE('------- END: FN_INIT_ELIGQUAL -------');
    RETURN V_FIELD_DATA_TRG;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    V_ERRCODE := SQLCODE;
    V_ERRMSG := SQLERRM;
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing Eligiblity and Qualification initialization -------------------');
    --DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
    --DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
    RETURN NULL;
  END;
  /

GRANT EXECUTE ON HHS_CMS_HR.FN_INIT_ELIGQUAL TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.FN_INIT_ELIGQUAL TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_INIT_ELIGQUAL TO HHS_CMS_HR_DEV_ROLE;


create or replace FUNCTION FN_GET_HIRINGTL_SLA_DAYS 
  (
    I_START_DATE IN DATE,
    I_DAYSTYPE IN VARCHAR2, 
    I_REQUESTTYPE IN VARCHAR2,
    I_SLAACTNAME IN VARCHAR2, 
    I_MAJOR_MINOR IN VARCHAR2
  )
RETURN DATE 
IS
V_DAYSTOTARGETCOMPLETION DATE;

  BEGIN

    IF I_MAJOR_MINOR IS NOT NULL THEN 
      IF I_DAYSTYPE = 'Calendar' THEN
          SELECT I_START_DATE + (SELECT TOTAL_CALENDAR_DAY FROM HHS_CMS_HR.SLA_HIRING_TIMELINE SLA 
            INNER JOIN HHS_CMS_HR.TBL_LOOKUP LKUP ON LKUP.TBL_ID = SLA.SG_RT_ID
            WHERE SLA.ACTIVITY_NAME like '%'||I_SLAACTNAME||'%'
            AND LKUP.TBL_LABEL = I_REQUESTTYPE AND SLA.PROCESS_NAME like '%'||I_MAJOR_MINOR||'%') INTO V_DAYSTOTARGETCOMPLETION FROM DUAL;
            
      ELSE 
            SELECT BIZFLOW.HHS_FN_ADD_BUSDAY(I_START_DATE,(SELECT TARGET_BUSINESS_DAY FROM HHS_CMS_HR.SLA_HIRING_TIMELINE SLA 
            INNER JOIN HHS_CMS_HR.TBL_LOOKUP LKUP ON LKUP.TBL_ID = SLA.SG_RT_ID
            WHERE SLA.ACTIVITY_NAME like '%'||I_SLAACTNAME||'%'
            AND LKUP.TBL_LABEL = I_REQUESTTYPE AND SLA.PROCESS_NAME like '%'||I_MAJOR_MINOR||'%')) INTO V_DAYSTOTARGETCOMPLETION FROM DUAL;
      END IF;
    ELSE
          IF I_DAYSTYPE = 'Calendar' THEN
              SELECT I_START_DATE + (SELECT TOTAL_CALENDAR_DAY FROM HHS_CMS_HR.SLA_HIRING_TIMELINE SLA 
            INNER JOIN HHS_CMS_HR.TBL_LOOKUP LKUP ON LKUP.TBL_ID = SLA.SG_RT_ID
                WHERE SLA.ACTIVITY_NAME like '%'||I_SLAACTNAME||'%'
                AND LKUP.TBL_LABEL = I_REQUESTTYPE) INTO V_DAYSTOTARGETCOMPLETION FROM DUAL;
          ELSE
                SELECT BIZFLOW.HHS_FN_ADD_BUSDAY(I_START_DATE,(SELECT TARGET_BUSINESS_DAY FROM HHS_CMS_HR.SLA_HIRING_TIMELINE SLA 
                INNER JOIN HHS_CMS_HR.TBL_LOOKUP LKUP ON LKUP.TBL_ID = SLA.SG_RT_ID WHERE SLA.ACTIVITY_NAME like '%'||I_SLAACTNAME||'%' AND LKUP.TBL_LABEL = I_REQUESTTYPE)) INTO V_DAYSTOTARGETCOMPLETION FROM DUAL;
          END IF;      
    
    END IF;
    RETURN V_DAYSTOTARGETCOMPLETION;
  END;
/

GRANT EXECUTE ON HHS_CMS_HR.FN_GET_HIRINGTL_SLA_DAYS TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_HIRINGTL_SLA_DAYS TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_HIRINGTL_SLA_DAYS TO HHS_CMS_HR_DEV_ROLE;


/

CREATE OR REPLACE FUNCTION FN_GET_TIMEZONE_OFFSET(
    I_TIMEZONE  IN VARCHAR2 DEFAULT 'America/New_York'
)
RETURN FLOAT
IS
   V_TZ_OFFSET     VARCHAR2(10); 
BEGIN   
    V_TZ_OFFSET := TZ_OFFSET(I_TIMEZONE);
    RETURN SIGN(TO_NUMBER(SUBSTR(V_TZ_OFFSET, 1, 3))) * (TO_NUMBER(SUBSTR(V_TZ_OFFSET, 2, 2)) + TO_NUMBER(SUBSTR(V_TZ_OFFSET, 5, 2)) / 60);
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;
/

GRANT EXECUTE ON HHS_CMS_HR.FN_GET_TIMEZONE_OFFSET TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_TIMEZONE_OFFSET TO HHS_CMS_HR_RW_ROLE ;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_TIMEZONE_OFFSET TO HHS_CMS_HR_DEV_ROLE ;
/

create or replace FUNCTION FN_NEW_TIMEZONE(
    I_DATE      IN  DATE,
    I_TIMEZONE  IN  VARCHAR2 DEFAULT 'America/New_York'
)
RETURN DATE
IS  
    V_DT            DATE;
    V_TZ_OFFSET     FLOAT(4);
BEGIN
    IF I_DATE IS NULL THEN
        RETURN NULL;
    END IF;
    
    V_TZ_OFFSET := FN_GET_TIMEZONE_OFFSET(I_TIMEZONE);
    RETURN I_DATE + V_TZ_OFFSET/24;

EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
/

GRANT EXECUTE ON HHS_CMS_HR.FN_NEW_TIMEZONE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.FN_NEW_TIMEZONE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_NEW_TIMEZONE TO HHS_CMS_HR_DEV_ROLE;

/

COMMIT;
/
