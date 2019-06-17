-- CMS_03_HR_SP_UPDATE_INCENTIVS_COM_TABLE.sql
-- CMS_04_HR_SP_UPDATE_INCENTIVES_PDP_TABLE.sql
-- CMS_05_HR_SP_UPDATE_INCENTIVES_TABLE.sql
-- CMS_12_HR_SP_UPDATE_ERLR_TABLE.sql
-- CMS_13_HR_SP_INIT_ERLR.sql
-- CMS_14_HR_SP_UPDATE_PV_ERLR.sql
-- CMS_15_HR_SP_UPDATE_ERLR_FORM_DATA.sql
-- CMS_19_HR_SP_UPDATE_ERLR_TABLE.sql
-- CMS_23_HR_SP_UPDATE_PV_Stratcon.sql
-- CMS_24_HR_SP_UPDATE_PV_CLSF.sql
-- CMS_25_HR_SP_UPDATE_PV_ELIGQUAL.sql
-- CMS_27_HR_SP_UPDATE_STRATCON_TABLE.sql
-- CMS_28_HR_SP_UPDATE_CLSF_TABLE.sql
-- CMS_29_HR_SP_UPDATE_ELIGQUAL_TABLE.sql
-- CMS_35_HR_SP_FINALIZE_ERLR.sql
-- CMS_38_SP_UPDATE_INCENTIVES_PDP_TABLE.sql
-- CMS_39_HR_SP_ERLR_MNG_FINAL_ACTION.sql
-- CMS_41_HR_SP_ERLR_MNG_FINAL_ACTION.sql
-- CMS_44_HR_INCENTIVE_CREATE_TABLE_SP.sql
-- CMS_49_HR_SP_UPDATE_INCENTIVES_SAM_TABLE.sql
-- CMS_56_HR_SP_UPDATE_INCENTIVES_LE_TABLE.sql
-- CMS_57_HR_SP_ERLR_MNG_FINAL_ACTION.sql
-- CMS_57_HR_SP_UPDATE_PV_INCENTIVES.sql
-- CMS_59_HR_SP_UPDATE_ERLR_TABLE.sql
-- CMS_62_HR_SP_UPDATE_INCENTIVES_PCA_TABLE.sql
-- CMS_67_HR_SP_UPDATE_INCENTIVES_COM_TABLE.sql
-- CMS_69_HR_SP_UPDATE_INCENTIVES_PDP_TABLE.sql
-- CMS_71_HR_SP_UPDATE_INCENTIVES_PDP_TABLE.sql
-- CMS_73_HR_SP_UPDATE_ERLR_TABLE.sql
-- CMS_83_HR_SP_UPDATE_STRATCON_TABLE.sql
-- CMS_85_HR_SP_UPDATE_CLSF_TABLE.sql
-- CMS_89_HR_SP_UPDATE_PV_INCENTIVES.sql
-- CMS_97_HR_SP_UPDATE_PV_INCENTIVES.sql
-- CMS_102_HR_SP_UPDATE_INCENTIVES_COM_TABLE.sql
-- CMS_103_HR_SP_UPDATE_INCENTIVES_PDP_TABLE.sql
-- CMS_106_HR_SP_UPDATE_ERLR_TABLE.sql
-- CMS_113_HR_SP_UPDATE_PV_INCENTIVES.sql
-- CMS_113_HR_SP_UPDATE_PV_STRATCON.sql
-- CMS_114_HR_SP_UPDATE_PV_CLSF.sql
-- CMS_118_HR_SP_INIT_INCENTIVES.sql
-- CMS_119_HR_SP_ERLR_UPDATE_FINAL_RATING.sql
-- CMS_131_HR_SP_UPDATE_INCENTIVES.sql
-- CMS_154_HR_SP_UPDATE_PV_STRATCON.sql
-- CMS_155_HR_SP_UPDATE_INIT_ELIGQUAL.sql
-- CMS_157_HR_SP_UPDATE_INIT_ELIGQUAL.sql
-- CMS_159_HR_INCENTIVE_CREATE_TABLE_SP.sql
-- CMS_160_HR_UPDATE_ERLR_TABLE.sql
-- CMS_162_HR_ERLR_MNG_FINAL_ACTION.sql
-- CMS_164_SP_UPDATE_INCENTIVES_PDP_TABLE.sql

SET DEFINE OFF;

create or replace PROCEDURE SP_UPDATE_INCENTIVES_COM_TABLE
  (
    I_PROCID            IN      NUMBER
  )
IS
    V_XMLREC_CNT                                    INTEGER := 0;
    V_XMLDOC                                        XMLTYPE;
    V_SERIES                                        VARCHAR2(140);
    V_TYPE_OF_APPOINTMENT_SELECT                    VARCHAR2(20);
BEGIN

    --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_INCENTIVES_SAM_TBL2');
    --DBMS_OUTPUT.PUT_LINE('I_PROCID=' || TO_CHAR(I_PROCID));
	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN

        SELECT COUNT(*)
          INTO V_XMLREC_CNT
          FROM TBL_FORM_DTL
         WHERE PROCID = I_PROCID;

        IF V_XMLREC_CNT > 0 THEN
			--DBMS_OUTPUT.PUT_LINE('RECORD FOUND PROCID=' || TO_CHAR(I_PROCID));

			MERGE INTO INCENTIVES_COM TRG
			USING
			(
                SELECT FD.PROCID AS PROC_ID
                        , X.INCEN_TYPE
                        , X.REQ_NUM
                        , X.REQ_TYPE
                        , TO_DATE(regexp_replace(X."REQ_DATE", '[^0-9|/]', ''), 'yyyy/mm/dd hh24:mi:ss') as REQ_DATE
                        , X.ADMIN_CODE
                        , X.ORG_NAME
                        , X.CANDI_NAME
                        , X.CANDI_FIRST
                        , X.CANDI_MIDDLE
                        , X.CANDI_LAST
                        , X.SO_NAME
                        , X.SO_EMAIL
                        , X.SO_ID
                        , X.XO1_NAME
                        , X.XO1_EMAIL
                        , X.XO1_ID
                        , X.XO2_NAME
                        , X.XO2_EMAIL
                        , X.XO2_ID
                        , X.XO3_NAME
                        , X.XO3_EMAIL
                        , X.XO3_ID
                        , X.HRL1_NAME
                        , X.HRL1_EMAIL
                        , X.HRL1_ID
                        , X.HRL2_NAME
                        , X.HRL2_EMAIL
                        , X.HRL2_ID
                        , X.HRL3_NAME
                        , X.HRL3_EMAIL
                        , X.HRL3_ID
                        , X.HRS1_NAME
                        , X.HRS1_EMAIL
                        , X.HRS1_ID
                        , X.HRS2_NAME
                        , X.HRS2_EMAIL
                        , X.HRS2_ID
                        , X.DGHO_NAME
                        , X.DGHO_EMAIL
                        , X.DGHO_ID
                        , X.TABG_NAME
                        , X.TABG_EMAIL
                        , X.TABG_ID
                        , X.POS_TITLE
                        , X.PAY_PLAN
                        , X.SERIES
                        , X.GRADE
                        , X.POS_DESC_NUM
                        , X.TYPE_OF_APPT
                        , X.NOT_TO_EXCEED_DT --
                        , X.DS_STATE
                        , X.DS_CITY
                        , X.CANCEL_RESAON
                        , X.CANCEL_USER_NAME
                        , X.CANCEL_USER_ID
                        , X.SO_TITLE
                        , X.SS_NAME
                        , X.SS_EMAIL
                        , X.SS_ID
                        , X.VACANCY_NUMBER
                    FROM TBL_FORM_DTL FD,
                         XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
                         INCEN_TYPE VARCHAR2(10) PATH './item[id="incentiveType"]/value'
                         , REQ_NUM VARCHAR2(15) PATH './item[id="requestNumber"]/value'
                         , REQ_TYPE VARCHAR2(20) PATH './item[id="requestType"]/value'
                         , REQ_DATE VARCHAR2(10) PATH './item[id="requestDate"]/value'
                         , ADMIN_CODE VARCHAR2(10) PATH './item[id="administrativeCode"]/value'
                         , ORG_NAME VARCHAR2(100) PATH './item[id="organizationName"]/value'
                         -- candidate
                         , CANDI_NAME VARCHAR2(150) PATH './item[id="candidateName"]/value'
                         , CANDI_FIRST VARCHAR2(50) PATH './item[id="candiFirstName"]/value'
                         , CANDI_MIDDLE VARCHAR2(50) PATH './item[id="candiMiddleName"]/value'
                         , CANDI_LAST VARCHAR2(50) PATH './item[id="candiLastName"]/value'
                         -- selectingOfficial
                         , SO_NAME VARCHAR2(100) PATH './item[id="selectingOfficial"]/value/name'
                         , SO_EMAIL VARCHAR2(100) PATH './item[id="selectingOfficial"]/value/email'
                         , SO_ID VARCHAR2(10) PATH './item[id="selectingOfficial"]/value/id'
                         , SO_TITLE VARCHAR2(100) PATH './item[id="selectingOfficial"]/value/title'
                         -- executiveOfficers
                         , XO1_NAME VARCHAR2(100) PATH './item[id="executiveOfficers"]/value[1]/name'
                         , XO1_EMAIL VARCHAR2(100) PATH './item[id="executiveOfficers"]/value[1]/email'
                         , XO1_ID VARCHAR2(10) PATH './item[id="executiveOfficers"]/value[1]/id'
                         , XO2_NAME VARCHAR2(100) PATH './item[id="executiveOfficers"]/value[2]/name'
                         , XO2_EMAIL VARCHAR2(100) PATH './item[id="executiveOfficers"]/value[2]/email'
                         , XO2_ID VARCHAR2(10) PATH './item[id="executiveOfficers"]/value[2]/id'
                         , XO3_NAME VARCHAR2(100) PATH './item[id="executiveOfficers"]/value[3]/name'
                         , XO3_EMAIL VARCHAR2(100) PATH './item[id="executiveOfficers"]/value[3]/email'
                         , XO3_ID VARCHAR2(10) PATH './item[id="executiveOfficers"]/value[3]/id'
                         -- hrLiaisons
                         , HRL1_NAME VARCHAR2(100) PATH './item[id="hrLiaisons"]/value[1]/name'
                         , HRL1_EMAIL VARCHAR2(100) PATH './item[id="hrLiaisons"]/value[1]/email'
                         , HRL1_ID VARCHAR2(10) PATH './item[id="hrLiaisons"]/value[1]/id'
                         , HRL2_NAME VARCHAR2(100) PATH './item[id="hrLiaisons"]/value[2]/name'
                         , HRL2_EMAIL VARCHAR2(100) PATH './item[id="hrLiaisons"]/value[2]/email'
                         , HRL2_ID VARCHAR2(10) PATH './item[id="hrLiaisons"]/value[2]/id'
                         , HRL3_NAME VARCHAR2(100) PATH './item[id="hrLiaisons"]/value[3]/name'
                         , HRL3_EMAIL VARCHAR2(100) PATH './item[id="hrLiaisons"]/value[3]/email'
                         , HRL3_ID VARCHAR2(10) PATH './item[id="hrLiaisons"]/value[3]/id'
                         -- hrSpecialist
                         , HRS1_NAME VARCHAR2(100) PATH './item[id="hrSpecialist"]/value/name'
                         , HRS1_EMAIL VARCHAR2(100) PATH './item[id="hrSpecialist"]/value/email'
                         , HRS1_ID VARCHAR2(10) PATH './item[id="hrSpecialist"]/value/id'
                         -- hrSpecialist2
                         , HRS2_NAME VARCHAR2(100) PATH './item[id="hrSpecialist2"]/value/name'
                         , HRS2_EMAIL VARCHAR2(100) PATH './item[id="hrSpecialist2"]/value/email'
                         , HRS2_ID VARCHAR2(10) PATH './item[id="hrSpecialist2"]/value/id'
                         -- TABG Division Director
                         , DGHO_NAME VARCHAR2(100) PATH './item[id="dghoDirector"]/value/name'
                         , DGHO_EMAIL VARCHAR2(100) PATH './item[id="dghoDirector"]/value/email'
                         , DGHO_ID VARCHAR2(10) PATH './item[id="dghoDirector"]/value/id'
                         -- TABG Director
                         , TABG_NAME VARCHAR2(100) PATH './item[id="tabgDirector"]/value/name'
                         , TABG_EMAIL VARCHAR2(100) PATH './item[id="tabgDirector"]/value/email'
                         , TABG_ID VARCHAR2(10) PATH './item[id="tabgDirector"]/value/id'
                         --	 STAFFING SPECIALIST	
                         , SS_NAME VARCHAR2(100) PATH './item[id="staffingSpecialist"]/value/name'
                         , SS_EMAIL VARCHAR2(100) PATH './item[id="staffingSpecialist"]/value/email'
                         , SS_ID VARCHAR2(10) PATH './item[id="staffingSpecialist"]/value/id'
                         -- position
                         , POS_TITLE VARCHAR2(140) PATH './item[id="positionTitle"]/value'
                         , PAY_PLAN VARCHAR2(5) PATH './item[id="payPlan"]/value'
                         , SERIES VARCHAR2(140) PATH './item[id="series"]/value'  --!!!
                         , GRADE VARCHAR2(5) PATH './item[id="grade"]/value'
                         , POS_DESC_NUM VARCHAR2(20) PATH './item[id="posDescNumber"]/value'
                         , TYPE_OF_APPT VARCHAR2(20) PATH './item[id="typeOfAppointment"]/value' --!!!
                         , NOT_TO_EXCEED_DT VARCHAR2(100) PATH './item[id="notToExceedDate"]/value' --!!!
                         -- dutyStation
                         , DS_STATE VARCHAR2(2) PATH './item[id="dutyStation"]/value[1]/state'
                         , DS_CITY VARCHAR2(50) PATH './item[id="dutyStation"]/value[1]/city'
                         -- cancellation
                         , CANCEL_RESAON VARCHAR2(25) PATH './item[id="cancellationReason"]/value'
                         , CANCEL_USER_NAME VARCHAR2(100) PATH './item[id="cancellationUser"]/value/name'
                         , CANCEL_USER_ID VARCHAR2(10) PATH './item[id="cancellationUser"]/value/id'
                         --vacancy number
                         , VACANCY_NUMBER  NUMBER(10) PATH './item[id="vacancyNumber"]/value'
                        ) X
                    WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.PROC_ID = TRG.PROC_ID)
            WHEN MATCHED THEN UPDATE SET
                        TRG.INCEN_TYPE = SRC.INCEN_TYPE
                        ,TRG.REQ_NUM = SRC.REQ_NUM
                        ,TRG.REQ_TYPE = SRC.REQ_TYPE
                        ,TRG.REQ_DATE = SRC.REQ_DATE
                        ,TRG.ADMIN_CODE = SRC.ADMIN_CODE
                        ,TRG.ORG_NAME = SRC.ORG_NAME
                        ,TRG.CANDI_NAME = SRC.CANDI_NAME
                        ,TRG.CANDI_NAME2 = NVL(SRC.CANDI_LAST, '') || ', ' || NVL(SRC.CANDI_FIRST, '')
                        ,TRG.CANDI_FIRST = SRC.CANDI_FIRST
                        ,TRG.CANDI_MIDDLE = SRC.CANDI_MIDDLE
                        ,TRG.CANDI_LAST = SRC.CANDI_LAST
                        ,TRG.SO_NAME = SRC.SO_NAME
                        ,TRG.SO_EMAIL = SRC.SO_EMAIL
                        ,TRG.SO_ID = SRC.SO_ID
                        ,TRG.XO1_NAME = SRC.XO1_NAME
                        ,TRG.XO1_EMAIL = SRC.XO1_EMAIL
                        ,TRG.XO1_ID = SRC.XO1_ID
                        ,TRG.XO2_NAME = SRC.XO2_NAME
                        ,TRG.XO2_EMAIL = SRC.XO2_EMAIL
                        ,TRG.XO2_ID = SRC.XO2_ID
                        ,TRG.XO3_NAME = SRC.XO3_NAME
                        ,TRG.XO3_EMAIL = SRC.XO3_EMAIL
                        ,TRG.XO3_ID = SRC.XO3_ID
                        ,TRG.HRL1_NAME = SRC.HRL1_NAME
                        ,TRG.HRL1_EMAIL = SRC.HRL1_EMAIL
                        ,TRG.HRL1_ID = SRC.HRL1_ID
                        ,TRG.HRL2_NAME = SRC.HRL2_NAME
                        ,TRG.HRL2_EMAIL = SRC.HRL2_EMAIL
                        ,TRG.HRL2_ID = SRC.HRL2_ID
                        ,TRG.HRL3_NAME = SRC.HRL3_NAME
                        ,TRG.HRL3_EMAIL = SRC.HRL3_EMAIL
                        ,TRG.HRL3_ID = SRC.HRL3_ID
                        ,TRG.HRS1_NAME = SRC.HRS1_NAME
                        ,TRG.HRS1_EMAIL = SRC.HRS1_EMAIL
                        ,TRG.HRS1_ID = SRC.HRS1_ID
                        ,TRG.HRS2_NAME = SRC.HRS2_NAME
                        ,TRG.HRS2_EMAIL = SRC.HRS2_EMAIL
                        ,TRG.HRS2_ID = SRC.HRS2_ID
                        ,TRG.DGHO_NAME = SRC.DGHO_NAME
                        ,TRG.DGHO_EMAIL = SRC.DGHO_EMAIL
                        ,TRG.DGHO_ID = SRC.DGHO_ID
                        ,TRG.TABG_NAME = SRC.TABG_NAME
                        ,TRG.TABG_EMAIL = SRC.TABG_EMAIL
                        ,TRG.TABG_ID = SRC.TABG_ID
                        ,TRG.POS_TITLE = SRC.POS_TITLE
                        ,TRG.PAY_PLAN = SRC.PAY_PLAN
                        ,TRG.SERIES = SRC.SERIES
                        ,TRG.GRADE = SRC.GRADE
                        ,TRG.POS_DESC_NUM = SRC.POS_DESC_NUM
                        ,TRG.TYPE_OF_APPT = SRC.TYPE_OF_APPT
                        ,TRG.NOT_TO_EXCEED_DT = SRC.NOT_TO_EXCEED_DT
                        ,TRG.DS_STATE = SRC.DS_STATE
                        ,TRG.DS_CITY = SRC.DS_CITY
                        ,TRG.CANCEL_RESAON = SRC.CANCEL_RESAON
                        ,TRG.CANCEL_USER_NAME = SRC.CANCEL_USER_NAME
                        ,TRG.CANCEL_USER_ID = SRC.CANCEL_USER_ID
                        ,TRG.SO_TITLE = SRC.SO_TITLE
                        ,TRG.SS_NAME = SRC.SS_NAME
                        ,TRG.SS_EMAIL = SRC.SS_EMAIL
                        ,TRG.SS_ID = SRC.SS_ID
                        ,TRG.VACANCY_NUMBER = SRC.VACANCY_NUMBER
            WHEN NOT MATCHED THEN INSERT (
                        TRG.PROC_ID
                        ,TRG.INCEN_TYPE
                        ,TRG.REQ_NUM
                        ,TRG.REQ_TYPE
                        ,TRG.REQ_DATE
                        ,TRG.ADMIN_CODE
                        ,TRG.ORG_NAME
                        ,TRG.CANDI_NAME
                        ,TRG.CANDI_NAME2
                        ,TRG.CANDI_FIRST
                        ,TRG.CANDI_MIDDLE
                        ,TRG.CANDI_LAST
                        ,TRG.SO_NAME
                        ,TRG.SO_EMAIL
                        ,TRG.SO_ID
                        ,TRG.XO1_NAME
                        ,TRG.XO1_EMAIL
                        ,TRG.XO1_ID
                        ,TRG.XO2_NAME
                        ,TRG.XO2_EMAIL
                        ,TRG.XO2_ID
                        ,TRG.XO3_NAME
                        ,TRG.XO3_EMAIL
                        ,TRG.XO3_ID
                        ,TRG.HRL1_NAME
                        ,TRG.HRL1_EMAIL
                        ,TRG.HRL1_ID
                        ,TRG.HRL2_NAME
                        ,TRG.HRL2_EMAIL
                        ,TRG.HRL2_ID
                        ,TRG.HRL3_NAME
                        ,TRG.HRL3_EMAIL
                        ,TRG.HRL3_ID
                        ,TRG.HRS1_NAME
                        ,TRG.HRS1_EMAIL
                        ,TRG.HRS1_ID
                        ,TRG.HRS2_NAME
                        ,TRG.HRS2_EMAIL
                        ,TRG.HRS2_ID
                        ,TRG.DGHO_NAME
                        ,TRG.DGHO_EMAIL
                        ,TRG.DGHO_ID
                        ,TRG.TABG_NAME
                        ,TRG.TABG_EMAIL
                        ,TRG.TABG_ID
                        ,TRG.POS_TITLE
                        ,TRG.PAY_PLAN
                        ,TRG.SERIES
                        ,TRG.GRADE
                        ,TRG.POS_DESC_NUM
                        ,TRG.TYPE_OF_APPT
                        ,TRG.NOT_TO_EXCEED_DT
                        ,TRG.DS_STATE
                        ,TRG.DS_CITY
                        ,TRG.CANCEL_RESAON
                        ,TRG.CANCEL_USER_NAME
                        ,TRG.CANCEL_USER_ID
                        ,TRG.SO_TITLE
                        ,TRG.SS_NAME
                        ,TRG.SS_EMAIL
                        ,TRG.SS_ID
                        ,TRG.VACANCY_NUMBER
                    ) VALUES (
                        SRC.PROC_ID
                        ,SRC.INCEN_TYPE
                        ,SRC.REQ_NUM
                        ,SRC.REQ_TYPE
                        ,SRC.REQ_DATE
                        ,SRC.ADMIN_CODE
                        ,SRC.ORG_NAME
                        ,SRC.CANDI_NAME --Last, First Middle
                        ,NVL(SRC.CANDI_LAST, '') || ', ' || NVL(SRC.CANDI_FIRST, '') -- Last, First (Performance Tunning when to join HHS_HR.DSS_TIME_TO_OFFER.NEW_HIRE_NAME
                        ,SRC.CANDI_FIRST
                        ,SRC.CANDI_MIDDLE
                        ,SRC.CANDI_LAST
                        ,SRC.SO_NAME
                        ,SRC.SO_EMAIL
                        ,SRC.SO_ID
                        ,SRC.XO1_NAME
                        ,SRC.XO1_EMAIL
                        ,SRC.XO1_ID
                        ,SRC.XO2_NAME
                        ,SRC.XO2_EMAIL
                        ,SRC.XO2_ID
                        ,SRC.XO3_NAME
                        ,SRC.XO3_EMAIL
                        ,SRC.XO3_ID
                        ,SRC.HRL1_NAME
                        ,SRC.HRL1_EMAIL
                        ,SRC.HRL1_ID
                        ,SRC.HRL2_NAME
                        ,SRC.HRL2_EMAIL
                        ,SRC.HRL2_ID
                        ,SRC.HRL3_NAME
                        ,SRC.HRL3_EMAIL
                        ,SRC.HRL3_ID
                        ,SRC.HRS1_NAME
                        ,SRC.HRS1_EMAIL
                        ,SRC.HRS1_ID
                        ,SRC.HRS2_NAME
                        ,SRC.HRS2_EMAIL
                        ,SRC.HRS2_ID
                        ,SRC.DGHO_NAME
                        ,SRC.DGHO_EMAIL
                        ,SRC.DGHO_ID
                        ,SRC.TABG_NAME
                        ,SRC.TABG_EMAIL
                        ,SRC.TABG_ID
                        ,SRC.POS_TITLE
                        ,SRC.PAY_PLAN
                        ,SRC.SERIES
                        ,SRC.GRADE
                        ,SRC.POS_DESC_NUM
                        ,SRC.TYPE_OF_APPT
                        ,SRC.NOT_TO_EXCEED_DT
                        ,SRC.DS_STATE
                        ,SRC.DS_CITY
                        ,SRC.CANCEL_RESAON
                        ,SRC.CANCEL_USER_NAME
                        ,SRC.CANCEL_USER_ID
                        ,SRC.SO_TITLE
                        ,SRC.SS_NAME
                        ,SRC.SS_EMAIL
                        ,SRC.SS_ID
                        ,SRC.VACANCY_NUMBER
                    );

                /*
                
                -- GET XML VALUE;
                SELECT FIELD_DATA
                  INTO V_XMLDOC
                  FROM TBL_FORM_DTL
                 WHERE PROCID = I_PROCID;         

                SELECT -- FN_EXTRACT_STR(V_XMLDOC, 'series') AS SERIES
                       --, FN_EXTRACT_STR(V_XMLDOC, 'typeOfAppointment') AS TYPE_OF_APPOINTMENT
                       FN_EXTRACT_STR(V_XMLDOC, 'seriesSelect ') AS SERIES_SELECT
                       ,FN_EXTRACT_STR(V_XMLDOC, 'typeOfAppointmentSelect') AS TYPE_OF_APPOINTMENT_SELECT 
                  INTO V_SERIES
                        ,V_TYPE_OF_APPOINTMENT_SELECT
                FROM DUAL;

                IF V_SERIES IS NOT NULL AND TRIM(V_SERIES) != '' THEN
                    UPDATE INCENTIVES_COM
                       SET SERIES = SUBSTR(V_SERIES, 1, 140)
                     WHERE PROC_ID = I_PROCID;
                END IF;
                
                IF V_TYPE_OF_APPOINTMENT_SELECT IS NOT NULL AND TRIM(V_TYPE_OF_APPOINTMENT_SELECT) != '' THEN
                    UPDATE INCENTIVES_COM
                       SET TYPE_OF_APPT = SUBSTR(V_TYPE_OF_APPOINTMENT_SELECT, 1, 20)
                     WHERE PROC_ID = I_PROCID;
                END IF;
               
               */
        END IF;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION=' || SUBSTR(SQLERRM, 1, 200));
          --err_code := SQLCODE;
          --err_msg := SUBSTR(SQLERRM, 1, 200);    
    SP_ERROR_LOG();
  END;
/
-- End of SP_UPDATE_INCENTIVES_COM_TABLE

GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_COM_TABLE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_COM_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_COM_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_COM_TABLE TO BF_DEV_ROLE;

/

create or replace PROCEDURE SP_UPDATE_INCENTIVES_PDP_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
    V_XMLDOC                            XMLTYPE;
    V_CLINICAL_SPCLTY_BOARD_CERT        VARCHAR2(2000);
    V_INCENTIVES_APPRVD_BY_TABG         VARCHAR2(2000);
BEGIN
    --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_INCENTIVES_PDP_TBL2');
    --DBMS_OUTPUT.PUT_LINE('I_PROCID=' || TO_CHAR(I_PROCID));

	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN

        SELECT FIELD_DATA
          INTO V_XMLDOC
          FROM TBL_FORM_DTL
         WHERE PROCID = I_PROCID;

        --DBMS_OUTPUT.PUT_LINE('DELETE INCENTIVES_PDP');
		DELETE INCENTIVES_PDP WHERE PROC_ID = I_PROCID;

        --DBMS_OUTPUT.PUT_LINE('INSERT INTO INCENTIVES_PDP');
		INSERT INTO INCENTIVES_PDP (
                            PROC_ID
                            ,PDP_TYPE
                            ,PDP_TYPE_OTHER
                            ,EXISTINGREQUEST
                            ,WORK_SCHEDULE
                            ,HOURS_PER_WEEK
                            ,BD_CERT_REQ
                            ,LIC_INFO
                            ,MARKET_PAY_RATE
                            ,CURRENT_FED_EMPLOYEE
                            ,LEVEL_RESPONSIBILITY
                            ,EXEC_RESP_AMT_REQUESTED
                            ,EXEC_RESP_JUSTIF_DETERMIN_AMT
                            ,EXPT_QF_Q1_AMT_REQUESTED
                            ,EXPT_QF_Q1_JUSTIF_DETERMIN_AMT
                            ,EXPT_QF_Q2_AMT_REQUESTED
                            ,EXPT_QF_Q2_JUSTIF_DETERMIN_AMT
                            ,EXPT_QF_Q3_AMT_REQUESTED
                            ,EXPT_QF_Q3_JUSTIF_DETERMIN_AMT
                            ,EXPT_QF_Q4_AMT_REQUESTED
                            ,EXPT_QF_Q4_JUSTIF_DETERMIN_AMT
                            ,EXPT_QF_Q5_AMT_REQUESTED
                            ,EXPT_QF_Q5_JUSTIF_DETERMIN_AMT
                            ,TOTAL_AMT_EXPT_QUALIFICATIONS
                            ,CURRENT_PAY_GRADE
                            ,CURRENT_PAY_STEP
                            ,CURRENT_PAY_POSITION_TITLE
                            ,CURRENT_PAY_TABLE
                            ,CURRENT_PAY_TIER
                            --,CLINICAL_SPECIALTY_BOARD_CERT --converted multiple value type
                          ,OTHER_SPECIALTY
                            ,CURRENT_PAY_RECRUITMENT
                            ,CURRENT_PAY_RELOCATION
                            ,CURRENT_PAY_RETENTION
                            ,CURRENT_PAY_3R_TOTAL
                            ,CURRENT_PAY_BASE
                            ,CURRENT_PAY_LOCALITY_MARKET
                            ,CURRENT_PAY_TOTAL_ANNUAL_PAY
                            ,CURRENT_PAY_TOTAL_COMPENSATION
                           ,CURRENT_PAY_NOTES
                           ,PROPOSED_PAY_STEP
                            ,PROPOSED_PAY_TABLE
                            ,PROPOSED_PAY_TIER
                            ,PROPOSED_PAY_RECRUITMENT
                            ,PROPOSED_PAY_RELOCATION
                            ,PROPOSED_PAY_RETENTION
                            ,PROPOSED_PAY_TOTAL_3R
                            ,PROPOSED_GS_BASE_PAY,PROPOSED_MARKET_PAY
                            ,PROPOSED_TOTAL_ANNUAL_PAY
                            ,PROPOSED_TOTAL_ANNUAL_COMPENS
                            --,INCENTIVES_APPROVED_BY_TABG --converted multiple value type
                            ,PROPOSED_PAY_NOTES
                            --Panel Tab
                             ,DATE_OF_MEETING
                            ,DATE_OF_RECOMMENDATION --added
                            ,QUORUM_REACHED
                            ,PANEL_CURRENT_SALARY
                            ,PANEL_PDP_AMOUNT
                            ,PANEL_RECOMM_ANNUAL_SALARY

                            ,SELECTING_OFFICIAL_REVIEWER
                            ,SELECTING_OFFICIAL_REVIEW_DT
                            ,TABG_DIVISION_DIR_REVIEW_DT
                            ,CMS_CHIEF_PHYSICIAN_REVIEW_DT
                            ,OFM_REVIEW_DATE
                            ,TABG_REVIEW_DATE
                            ,OHC_REVIEW_DATE
                            ,ADMINISTRATOR_APPROVAL_DATE 
                            )
                    SELECT FD.PROCID AS PROC_ID
                            ,X."PDP_TYPE"
                            ,X."PDP_TYPE_OTHER"
                            ,X."EXISTINGREQUEST"
                            ,X."WORK_SCHEDULE"
                            ,X."HOURS_PER_WEEK"
                            ,X."BD_CERT_REQ"
                            ,X."LIC_INFO"
                            ,X."MARKET_PAY_RATE"
                            ,X."CURRENT_FED_EMPLOYEE"
                            ,X."LEVEL_RESPONSIBILITY"
                            ,regexp_replace(X."EXEC_RESP_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXEC_RESP_JUSTIF_DETERMIN_AMT"
                            ,regexp_replace(X."EXPT_QF_Q1_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXPT_QF_Q1_JUSTIF_DETERMIN_AMT"
                            ,regexp_replace(X."EXPT_QF_Q2_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXPT_QF_Q2_JUSTIF_DETERMIN_AMT"
                            ,regexp_replace(X."EXPT_QF_Q3_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXPT_QF_Q3_JUSTIF_DETERMIN_AMT"
                            ,regexp_replace(X."EXPT_QF_Q4_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXPT_QF_Q4_JUSTIF_DETERMIN_AMT"
                            ,regexp_replace(X."EXPT_QF_Q5_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXPT_QF_Q5_JUSTIF_DETERMIN_AMT"
                           ,regexp_replace(X."TOTAL_AMT_EXPT_QUALIFICATIONS", '[^0-9|.]', '')
                            ,X."CURRENT_PAY_GRADE"
                            ,X."CURRENT_PAY_STEP"
                            ,X."CURRENT_PAY_POSITION_TITLE"
                            ,X."CURRENT_PAY_TABLE"
                            ,X."CURRENT_PAY_TIER"
                            --,X."CLINICAL_SPECIALTY_BOARD_CERT" --converted multiple value type
                            ,X."OTHER_SPECIALTY"
                            ,regexp_replace(X."CURRENT_PAY_RECRUITMENT", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_RELOCATION", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_RETENTION", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_3R_TOTAL", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_BASE", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_LOCALITY_MARKET", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_TOTAL_ANNUAL_PAY", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_TOTAL_COMPENSATION", '[^0-9|.]', '')
                            ,X."CURRENT_PAY_NOTES"
                            ,X."PROPOSED_PAY_STEP"
                            ,X."PROPOSED_PAY_TABLE"
                            ,X."PROPOSED_PAY_TIER"
                            ,regexp_replace(X."PROPOSED_PAY_RECRUITMENT", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_PAY_RELOCATION", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_PAY_RETENTION", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_PAY_TOTAL_3R", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_GS_BASE_PAY", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_MARKET_PAY", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_TOTAL_ANNUAL_PAY", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_TOTAL_ANNUAL_COMPENS", '[^0-9|.]', '')
                            --,X."INCENTIVES_APPROVED_BY_TABG" --converted multiple value type
                            ,X."PROPOSED_PAY_NOTES"
                            --Panel tab
                             ,TO_DATE(regexp_replace(X."DATE_OF_MEETING", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."DATE_OF_RECOMMENDATION", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,X."QUORUM_REACHED"
                            ,regexp_replace(X."PANEL_CURRENT_SALARY", '[^0-9|.]', '')
                            ,regexp_replace(X."PANEL_PDP_AMOUNT", '[^0-9|.]', '')
                            ,regexp_replace(X."PANEL_RECOMM_ANNUAL_SALARY", '[^0-9|.]', '') 
                            ,X."SELECTING_OFFICIAL_REVIEWER"
                            ,TO_DATE(regexp_replace(X."SELECTING_OFFICIAL_REVIEW_DT", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."TABG_DIVISION_DIR_REVIEW_DT", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."CMS_CHIEF_PHYSICIAN_REVIEW_DT", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."OFM_REVIEW_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."TABG_REVIEW_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."OHC_REVIEW_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."ADMINISTRATOR_APPROVAL_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') 
                FROM TBL_FORM_DTL FD,
                     XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
                    PDP_TYPE VARCHAR2(18) PATH './item[id="pdpType"]/value'
                    ,PDP_TYPE_OTHER	VARCHAR2(150)PATH './item[id="pdpTypeOther"]/value'
                    ,EXISTINGREQUEST	VARCHAR2(1)PATH './item[id="associatedRequest"]/value'
                    -- Position
                    ,WORK_SCHEDULE        VARCHAR2(15) PATH './item[id="workSchedule"]/value'
                    ,HOURS_PER_WEEK       VARCHAR2(5) PATH './item[id="hoursPerWeek"]/value'
                    ,BD_CERT_REQ          VARCHAR2(5) PATH './item[id="requireBoardCert"]/value'
                    ,LIC_INFO             VARCHAR2(140) PATH './item[id="licenseInfo"]/value'
                    --Details
                    ,MARKET_PAY_RATE VARCHAR2(9) PATH './item[id="marketPayRate"]/value' 
                    ,CURRENT_FED_EMPLOYEE  VARCHAR2(1) PATH './item[id="currentFederalEmployee"]/value' 
                    ,LEVEL_RESPONSIBILITY VARCHAR2(50) PATH './item[id="execRespLevelOfResponsability"]/value'
                    ,EXEC_RESP_AMT_REQUESTED VARCHAR2(50) PATH './item[id="execRespAmountRequested"]/value' 
                    ,EXEC_RESP_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="execRespJustification"]/value' 
                    ,EXPT_QF_Q1_AMT_REQUESTED VARCHAR2(50) PATH './item[id="excepQualAmountRequested_1"]/value' 
                    ,EXPT_QF_Q1_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_1"]/value' 
                    ,EXPT_QF_Q2_AMT_REQUESTED VARCHAR2(50) PATH './item[id="excepQualAmountRequested_2"]/value' 
                    ,EXPT_QF_Q2_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_2"]/value' 
                    ,EXPT_QF_Q3_AMT_REQUESTED VARCHAR2(50) PATH './item[id="excepQualAmountRequested_3"]/value' 
                    ,EXPT_QF_Q3_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_3"]/value' 
                    ,EXPT_QF_Q4_AMT_REQUESTED VARCHAR2(50) PATH './item[id="excepQualAmountRequested_4"]/value' 
                    ,EXPT_QF_Q4_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_4"]/value' 
                    ,EXPT_QF_Q5_AMT_REQUESTED VARCHAR2(50) PATH './item[id="excepQualAmountRequested_5"]/value' 
                    ,EXPT_QF_Q5_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_5"]/value' 
                    ,TOTAL_AMT_EXPT_QUALIFICATIONS VARCHAR2(50) PATH './item[id="excepQualTotalAmount"]/value'
                    ,CURRENT_PAY_GRADE VARCHAR2(20) PATH './item[id="currentPayInfoGrade"]/value' 
                    ,CURRENT_PAY_STEP VARCHAR2(20) PATH './item[id="currentPayInfoStep"]/value' 
                    ,CURRENT_PAY_POSITION_TITLE VARCHAR2(70) PATH './item[id="currentPayInfoPositionTitle"]/value' 
                    ,CURRENT_PAY_TABLE VARCHAR2(20) PATH './item[id="currentPayInfoTable"]/value' 
                    ,CURRENT_PAY_TIER VARCHAR2(20) PATH './item[id="currentPayInfoTier"]/value' 
                    --,CLINICAL_SPECIALTY_BOARD_CERT VARCHAR2(200) PATH './item[id="currentPayInfoSpecialtyCertification"]/value' --converted multiple value type
                     ,OTHER_SPECIALTY VARCHAR2(140) PATH './item[id="currentPayOtherSpecialty"]/value'
                     ,CURRENT_PAY_RECRUITMENT VARCHAR2(50) PATH './item[id="currentPayInfoRecruitment"]/value' 
                    ,CURRENT_PAY_RELOCATION VARCHAR2(50) PATH './item[id="currentPayInfoRelocation"]/value' 
                    ,CURRENT_PAY_RETENTION VARCHAR2(50) PATH './item[id="currentPayInfoRetention"]/value' 
                    ,CURRENT_PAY_3R_TOTAL VARCHAR2(50) PATH './item[id="currentPayInfoTotal3R"]/value' 
                    ,CURRENT_PAY_BASE VARCHAR2(50) PATH './item[id="currentPayInfoBasePay"]/value' 
                    ,CURRENT_PAY_LOCALITY_MARKET VARCHAR2(50) PATH './item[id="currentPayInfoLocality"]/value' 
                    ,CURRENT_PAY_TOTAL_ANNUAL_PAY VARCHAR2(50) PATH './item[id="currentPayInfoTotalAnnualPay"]/value' 
                    ,CURRENT_PAY_TOTAL_COMPENSATION VARCHAR2(50) PATH './item[id="currentPayInfoTotalAnnualComp"]/value' 
                    ,CURRENT_PAY_NOTES VARCHAR2(500) PATH './item[id="currentPayInfoNotes"]/value' 
                   ,PROPOSED_PAY_STEP VARCHAR2(20) PATH './item[id="proposedPayInfoStep"]/value' 
                    ,PROPOSED_PAY_TABLE VARCHAR2(20) PATH './item[id="proposedPayInfoTable"]/value' 
                    ,PROPOSED_PAY_TIER VARCHAR2(20) PATH './item[id="proposedPayInfoTier"]/value' 
                    ,PROPOSED_PAY_RECRUITMENT VARCHAR2(50) PATH './item[id="proposedPayInfoRecruitment"]/value' 
                    ,PROPOSED_PAY_RELOCATION VARCHAR2(50) PATH './item[id="proposedPayInfoRelocation"]/value' 
                    ,PROPOSED_PAY_RETENTION VARCHAR2(50) PATH './item[id="proposedPayInfoRetention"]/value' 
                    ,PROPOSED_PAY_TOTAL_3R VARCHAR2(50) PATH './item[id="proposedPayInfoTotal3R"]/value' 
                    ,PROPOSED_GS_BASE_PAY VARCHAR2(50) PATH './item[id="proposedPayInfoGSBasePay"]/value' 
                    ,PROPOSED_MARKET_PAY VARCHAR2(50) PATH './item[id="proposedPayInfoMarketPay"]/value' 
                    ,PROPOSED_TOTAL_ANNUAL_PAY VARCHAR2(50) PATH './item[id="proposedPayInfoTotalAnnualPay"]/value'  
                    ,PROPOSED_TOTAL_ANNUAL_COMPENS VARCHAR2(50) PATH './item[id="proposedPayInfoTotalAnnualComp"]/value' 
                    --,INCENTIVES_APPROVED_BY_TABG VARCHAR2(3) PATH './item[id="proposedPayInfoIncentivesApprTABG"]/value' --converted multiple value type
                    ,PROPOSED_PAY_NOTES VARCHAR2(500) PATH './item[id="proposedPayInfoNotes"]/value' 
                    --Panel
                    ,DATE_OF_MEETING VARCHAR2(10) PATH './item[id="panelDateOfMeeting"]/value' 
                    ,DATE_OF_RECOMMENDATION VARCHAR2(10) PATH './item[id="panelDateOfRecommendation"]/value' 
                    ,QUORUM_REACHED VARCHAR2(1) PATH './item[id="selectPanelQuorumReached"]/value' 
                    ,PANEL_CURRENT_SALARY VARCHAR2(20) PATH './item[id="panelCurrentSalaryGP"]/value' 
                    ,PANEL_PDP_AMOUNT VARCHAR2(20) PATH './item[id="panelPDPAmount"]/value' 
                    ,PANEL_RECOMM_ANNUAL_SALARY VARCHAR2(20) PATH './item[id="panelRecommendedAnnualSalary"]/value' 
                    --Approval and Review
                    ,SELECTING_OFFICIAL_REVIEWER VARCHAR2(100) PATH './item[id="pdp_reviewSO"]/value' 
                    ,SELECTING_OFFICIAL_REVIEW_DT VARCHAR2(10) PATH './item[id="pdp_reviewSODate"]/value' 
                    ,TABG_DIVISION_DIR_REVIEW_DT VARCHAR2(10) PATH './item[id="pdp_reviewDGODate"]/value' 
                    ,CMS_CHIEF_PHYSICIAN_REVIEW_DT VARCHAR2(10) PATH './item[id="pdp_reviewCPDate"]/value' 
                    ,OFM_REVIEW_DATE VARCHAR2(10) PATH './item[id="pdp_reviewOFMDate"]/value' 
                    ,TABG_REVIEW_DATE VARCHAR2(10) PATH './item[id="pdp_reviewTABGDate"]/value' 
                    ,OHC_REVIEW_DATE VARCHAR2(10) PATH './item[id="pdp_reviewOHCDate"]/value' 
                    ,ADMINISTRATOR_APPROVAL_DATE VARCHAR2(10) PATH './item[id="pdp_adminApprovalDate"]/value'
                    ) X
            WHERE FD.PROCID = I_PROCID;

        --------------------
        -- Details Tab / Muti value (used same methods in other workstream implementation).    
        SELECT XMLQUERY('for $i in /formData/items/item[id="currentPayInfoSpecialtyCertification"]/value[string-length(value/text()) > 0] return concat($i/value/text(), ", ")'
               PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_CLINICAL_SPCLTY_BOARD_CERT FROM DUAL;
        V_CLINICAL_SPCLTY_BOARD_CERT := SUBSTR(V_CLINICAL_SPCLTY_BOARD_CERT, 0, LENGTH(V_CLINICAL_SPCLTY_BOARD_CERT)-2);
        --DBMS_OUTPUT.PUT_LINE('V_CLINICAL_SPCLTY_BOARD_CERT=[' || V_CLINICAL_SPCLTY_BOARD_CERT || ']');

        SELECT XMLQUERY('for $i in /formData/items/item[id="proposedPayInfoIncentivesApprTABG"]/value[string-length(value/text()) > 0] return concat($i/value/text(), ", ")'
               PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_INCENTIVES_APPRVD_BY_TABG FROM DUAL;
        V_INCENTIVES_APPRVD_BY_TABG := SUBSTR(V_INCENTIVES_APPRVD_BY_TABG, 0, LENGTH(V_INCENTIVES_APPRVD_BY_TABG)-2);
        --DBMS_OUTPUT.PUT_LINE('V_INCENTIVES_APPRVD_BY_TABG=[' || V_INCENTIVES_APPRVD_BY_TABG || ']');

        UPDATE INCENTIVES_PDP
           SET CLINICAL_SPECIALTY_BOARD_CERT = V_CLINICAL_SPCLTY_BOARD_CERT
               , INCENTIVES_APPROVED_BY_TABG = V_INCENTIVES_APPRVD_BY_TABG
         WHERE PROC_ID = I_PROCID;

        --------------------
        --Panel Tab
        --DBMS_OUTPUT.PUT_LINE('PANEL TAB');
        --DBMS_OUTPUT.PUT_LINE('PANEL TAB-DELETE');
        DELETE FROM HHS_CMS_HR.INCENTIVES_PDP_PANEL
        WHERE PROC_ID = I_PROCID;

        --DBMS_OUTPUT.PUT_LINE('PANEL TAB-INSERT');
        INSERT INTO INCENTIVES_PDP_PANEL
                                (
                                PROC_ID
                                ,SEQ_NUM
                                ,FULL_NAME
                                ,COMPONENT_NAME
                                ,EMAIL
                                ,HHSID
                                ,ADMIN_CODE
                                ,PANEL_ROLE
                                ,VOTING_STATUS
                                ,PANEL_REC_COMP
                                )
                    SELECT FD.PROCID
                           ,ROWNUM
                           ,x.FULL_NAME
                           ,x.COMPONENT_NAME
                           ,x.EMAIL
                           ,x.HHSID
                           ,x.ADMIN_CODE
                           ,x.PANEL_ROLE
                           ,x.VOTING_STATUS
                           ,x.PANEL_REC_COMP        
                    FROM TBL_FORM_DTL FD,
                         XMLTABLE('/formData/items/item[id="panelItems"]/value' PASSING FD.FIELD_DATA COLUMNS
                            FULL_NAME			VARCHAR2(200) PATH './name'
                            ,COMPONENT_NAME		VARCHAR2(200) PATH './component'
                            ,EMAIL		        VARCHAR2(100) PATH './email'
                            ,HHSID		        VARCHAR2(20) PATH './HHSID'
                            ,ADMIN_CODE		    VARCHAR2(20) PATH './adminCode'
                            ,PANEL_ROLE		    VARCHAR2(20) PATH './role'
                            ,VOTING_STATUS		VARCHAR2(50) PATH './votingStatus'
                            ,PANEL_REC_COMP	    VARCHAR2(50) PATH './recCompensation'
                        ) X
                    WHERE FD.PROCID = I_PROCID;

	END IF;

	EXCEPTION
	WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION=' || SUBSTR(SQLERRM, 1, 200));
          --err_code := SQLCODE;
          --err_msg := SUBSTR(SQLERRM, 1, 200);
		SP_ERROR_LOG();
END;
/
-- End of SP_UPDATE_INCENTIVES_PDP_TABLE

GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_PDP_TABLE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_PDP_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_PDP_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_PDP_TABLE TO BF_DEV_ROLE;
/

CREATE OR REPLACE PROCEDURE SP_UPDATE_INCENTIVES_TABLE
(
	I_PROCID            IN      NUMBER
	, I_FIELD_DATA      IN      XMLTYPE
)
IS
	V_XMLVALUE             XMLTYPE;
	V_INCENTIVE_TYPE     NVARCHAR2(50);

BEGIN
	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="incentiveType"]/value/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_INCENTIVE_TYPE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_INCENTIVE_TYPE := NULL;
		END IF;

		SP_UPDATE_INCENTIVES_COM_TABLE(I_PROCID);

		IF 'PCA' = V_INCENTIVE_TYPE THEN
			SP_UPDATE_INCENTIVES_PCA_TABLE(I_PROCID);
		ELSIF 'PDP' = V_INCENTIVE_TYPE THEN
			SP_UPDATE_INCENTIVES_PDP_TABLE(I_PROCID);
		ELSIF 'SAM' = V_INCENTIVE_TYPE THEN
			SP_UPDATE_INCENTIVES_SAM_TABLE(I_PROCID);
		ELSIF 'LE' = V_INCENTIVE_TYPE THEN
			SP_UPDATE_INCENTIVES_LE_TABLE(I_PROCID);
		END IF;
	END IF;

	EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_TABLE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_TABLE TO BF_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_ERLR_TABLE
(
    I_PROCID            IN      NUMBER
)
IS
    V_CASE_NUMBER               NUMBER(20);
    V_CASE_TYPE                 NUMBER;
    V_JOB_REQ_NUM               NVARCHAR2(50);
    V_CASE_CREATION_DT          DATE;    
    V_VALUE                     NVARCHAR2(4000);
    V_XMLDOC                    XMLTYPE;
    V_APPEAL_TYPE               VARCHAR2(50);
BEGIN
	IF I_PROCID IS NULL OR I_PROCID = 0 THEN
		RETURN;
	END IF;

	------------------------------------------------------
	-- Transfer XML data into operational table
	--
	-- 1. Get Case number and Job Request Number
	-- 1.1 Select it from data xml from TBL_FORM_DTL table.
	-- 1.2 If not found, select it from BIZFLOW.RLVNTDATA table.
	-- 2. If Case number /Job Request Number not found, issue error.
	-- 3. For each target table,
	-- 3.1. If record found for the CASE_NUMBER, update record.
	-- 3.2. If record not found for the CASE_NUMBER, insert record.
	------------------------------------------------------

	--------------------------------
	-- get Case number
	--------------------------------
	BEGIN
	    SELECT VALUE
	      INTO V_CASE_NUMBER
	      FROM BIZFLOW.RLVNTDATA
	     WHERE RLVNTDATANAME = 'caseNumber' 
           AND PROCID = I_PROCID;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN V_CASE_NUMBER := NULL;
	END;

	IF V_CASE_NUMBER IS NULL THEN
	    RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ERLR_TABLE: Case Number is invalid.  I_PROCID = '
		|| TO_CHAR(I_PROCID) || ' V_CASE_NUMBER = ' || V_CASE_NUMBER || '  V_CASE_NUMBER = ' || TO_CHAR(V_CASE_NUMBER));
	END IF;

	--------------------------------
	-- get Request number 
	--------------------------------
	BEGIN
	    SELECT VALUE
	      INTO V_JOB_REQ_NUM
	      FROM BIZFLOW.RLVNTDATA
	     WHERE RLVNTDATANAME = 'requestNum'
           AND PROCID = I_PROCID;
           
	    IF V_JOB_REQ_NUM IS NULL THEN
		  GET_REQUEST_NUM (V_JOB_REQ_NUM);
		  UPDATE BIZFLOW.RLVNTDATA 
		     SET VALUE = V_JOB_REQ_NUM
		   WHERE RLVNTDATANAME = 'requestNum' 
		     AND PROCID = I_PROCID;
	    END IF;
           
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN V_JOB_REQ_NUM := NULL;
	END;

	--------------------------------
	-- get Case Creation Date
	--------------------------------
	BEGIN
	    SELECT CREATIONDTIME
	      INTO V_CASE_CREATION_DT
	      FROM BIZFLOW.PROCS
	     WHERE PROCID = I_PROCID;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN V_CASE_CREATION_DT := NULL;
	END;

	SELECT FIELD_DATA
	  INTO V_XMLDOC
	  FROM TBL_FORM_DTL
	 WHERE PROCID = I_PROCID;

	--------------------------------
	-- ERLR_CASE table
	--------------------------------
	DELETE ERLR_CASE WHERE PROCID = I_PROCID;
	INSERT INTO ERLR_CASE (
		  ERLR_CASE_NUMBER
		  ,ERLR_JOB_REQ_NUMBER
		  ,PROCID 
		  ,ERLR_CASE_STATUS_ID
		  ,ERLR_CASE_CREATE_DT
		)VALUES(
		  V_CASE_NUMBER
		  ,V_JOB_REQ_NUM
		  ,I_PROCID
		  ,FN_EXTRACT_STR (V_XMLDOC, 'GEN_CASE_STATUS')
		  ,V_CASE_CREATION_DT
		);

	--------------------------------
	-- ERLR_GEN table
	--------------------------------
	DELETE ERLR_GEN WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
	DECLARE V_FINAL_ACTIONS VARCHAR2(2000);
	        V_CATEGORY_NAMES VARCHAR2(1000);
	        V_CATEGORY_IDS VARCHAR2(200);
            V_CLASS VARCHAR2(10);
            V_THRD_PRTY_APPEAL_TYPE VARCHAR2(100);
            V_PRIMARY_SP_ID VARCHAR2(20);
            V_SECOND_SP_ID VARCHAR2(20);
            V_PRIMARY_SP_NAME VARCHAR2(150);
            V_SECOND_SP_NAME VARCHAR2(150);
	BEGIN
		SELECT XMLQUERY('for $i in /formData/items/item[id="CC_FINAL_ACTION_SEL"]/value return concat($i/value/text(), ", ")'
		       PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_FINAL_ACTIONS FROM DUAL;
		V_FINAL_ACTIONS := SUBSTR(V_FINAL_ACTIONS, 0, LENGTH(V_FINAL_ACTIONS)-2);

		SELECT XMLQUERY('for $i in /formData/items/item[id="GEN_CASE_CATEGORY_SEL"]/value return concat($i/text/text(), ", ")'
		       PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_CATEGORY_NAMES FROM DUAL;
		V_CATEGORY_NAMES := SUBSTR(V_CATEGORY_NAMES, 0, LENGTH(V_CATEGORY_NAMES)-2);

		SELECT XMLQUERY('for $i in /formData/items/item[id="GEN_CASE_CATEGORY_SEL"]/value return concat($i/value/text(), ",")'
		       PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_CATEGORY_IDS FROM DUAL;
		V_CATEGORY_IDS := SUBSTR(V_CATEGORY_IDS, 0, LENGTH(V_CATEGORY_IDS)-1);
        
        V_CASE_TYPE := TO_NUMBER(FN_EXTRACT_STR (V_XMLDOC, 'GEN_CASE_TYPE'));
        
        IF V_CASE_TYPE IN (743, 744, 746, 750, 751, 809) THEN -- 'Conduct Issue', 'Investigation', 'Medical Documentation', 'Performance Issue', 'Probationary Period Action', 'Within Grade Increase Denial/Reconsideration'            
            V_CLASS := 'ER';
        ELSIF V_CASE_TYPE IN (748, 745, 747, 754) THEN -- 'Labor Negotiation', 'Grievance', 'Information Request', 'Unfair Labor Practice'            
            V_CLASS := 'LR';
        ELSIF V_CASE_TYPE IN (753) THEN -- 'Third Party Hearing'   
            V_THRD_PRTY_APPEAL_TYPE := FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_APPEAL_TYPE');
            IF V_THRD_PRTY_APPEAL_TYPE = 'MSPB' THEN
                V_CLASS := 'ER';
            ELSIF V_THRD_PRTY_APPEAL_TYPE IN ('Arbitration', 'FLRA', 'FSIP', 'Grievance') THEN
                V_CLASS := 'LR';
            END IF;
        END IF;
        
        V_PRIMARY_SP_ID := SUBSTR(FN_EXTRACT_STR (V_XMLDOC, 'GEN_PRIMARY_SPECIALIST'), 4, 10);
        IF V_PRIMARY_SP_ID IS NOT NULL THEN
            SELECT NAME
              INTO V_PRIMARY_SP_NAME
              FROM BIZFLOW.MEMBER
             WHERE MEMBERID = V_PRIMARY_SP_ID;
        END IF;
        
        V_SECOND_SP_ID := SUBSTR(FN_EXTRACT_STR (V_XMLDOC, 'GEN_SECONDARY_SPECIALIST'), 4, 10);
        IF V_SECOND_SP_ID IS NOT NULL THEN
            SELECT NAME
              INTO V_SECOND_SP_NAME
              FROM BIZFLOW.MEMBER
             WHERE MEMBERID = V_PRIMARY_SP_ID;
        END IF;
        
		INSERT INTO ERLR_GEN (
                PROCID,
                ERLR_CASE_NUMBER,
                GEN_PRIMARY_SPECIALIST,
                GEN_SECONDARY_SPECIALIST,
                GEN_CUSTOMER_NAME,
                GEN_CUSTOMER_PHONE,
                GEN_CUSTOMER_ADMIN_CD,
                GEN_CUSTOMER_ADMIN_CD_DESC,
                GEN_EMPLOYEE_NAME,                    
                GEN_EMPLOYEE_ID,
                GEN_EMPLOYEE_PHONE,
                GEN_EMPLOYEE_ADMIN_CD,
                GEN_EMPLOYEE_ADMIN_CD_DESC,
                GEN_CASE_DESC,
                GEN_CASE_STATUS,
                GEN_CUST_INIT_CONTACT_DT,
                GEN_PRIMARY_REP_AFFILIATION,
                GEN_CMS_PRIMARY_REP_ID,
                GEN_CMS_PRIMARY_REP_PHONE,
                GEN_NON_CMS_PRIMARY_FNAME,
                GEN_NON_CMS_PRIMARY_MNAME,
                GEN_NON_CMS_PRIMARY_LNAME,
                GEN_NON_CMS_PRIMARY_EMAIL,
                GEN_NON_CMS_PRIMARY_PHONE,
                GEN_NON_CMS_PRIMARY_ORG,
                GEN_NON_CMS_PRIMARY_ADDR,
                GEN_CASE_TYPE,
                GEN_CASE_CATEGORY,
                GEN_INVESTIGATION,
                GEN_INVESTIGATE_START_DT,
                GEN_INVESTIGATE_END_DT,
                GEN_STD_CONDUCT,
                GEN_STD_CONDUCT_TYPE,
                CC_FINAL_ACTION,
                CC_FINAL_ACTION_OTHER,
                CC_CASE_COMPLETE_DT,
                GEN_CASE_CATEGORY_NAME,
                GEN_CASE_TYPE_NAME,
                GEN_CLASS,
                GEN_PRIMARY_SPECIALIST_NAME,
                GEN_SECONDARY_SPECIALIST_NAME,
                GEN_EMPLOYEE_2ND_SUB_ORG,
                CANCEL_REASON
		       ) VALUES (
                I_PROCID,
                V_CASE_NUMBER,
                V_PRIMARY_SP_ID,
                V_SECOND_SP_ID,
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_CUSTOMER_NAME'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_CUSTOMER_PHONE'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_CUSTOMER_ADMIN_CD'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_CUSTOMER_ADMIN_CD_DESC'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_EMPLOYEE_NAME'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_EMPLOYEE_ID'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_EMPLOYEE_PHONE'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_EMPLOYEE_ADMIN_CD'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_EMPLOYEE_ADMIN_CD_DESC'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_CASE_DESC'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_CASE_STATUS'),
                FN_EXTRACT_DATE(V_XMLDOC, 'GEN_CUST_INIT_CONTACT_DT'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_PRIMARY_REP'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_CMS_PRIMARY_REP', 'value/name'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_CMS_PRIMARY_REP_PHONE'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_NON_CMS_PRIMARY_FNAME'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_NON_CMS_PRIMARY_MNAME'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_NON_CMS_PRIMARY_LNAME'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_NON_CMS_PRIMARY_EMAIL'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_NON_CMS_PRIMARY_PHONE'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_NON_CMS_PRIMARY_ORG'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_NON_CMS_PRIMARY_ADDR'),
                V_CASE_TYPE,
                V_CATEGORY_IDS,
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_INVESTIGATION'),
                FN_EXTRACT_DATE(V_XMLDOC, 'GEN_INVESTIGATE_START_DT'),
                FN_EXTRACT_DATE(V_XMLDOC, 'GEN_INVESTIGATE_END_DT'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_STD_CONDUCT'),
                FN_EXTRACT_STR (V_XMLDOC, 'GEN_STD_CONDUCT_TYPE'),
                V_FINAL_ACTIONS,
                FN_EXTRACT_STR (V_XMLDOC, 'CC_FINAL_ACTION_OTHER'),
                FN_EXTRACT_DATE(V_XMLDOC, 'CC_CASE_COMPLETE_DT'),
                V_CATEGORY_NAMES,
                (SELECT TBL_LABEL FROM TBL_LOOKUP WHERE TBL_ID = V_CASE_TYPE),
                V_CLASS,
                V_PRIMARY_SP_NAME,
                V_SECOND_SP_NAME,
                FN_GET_2ND_SUB_ORG(FN_EXTRACT_STR (V_XMLDOC, 'GEN_EMPLOYEE_ADMIN_CD')),
                FN_EXTRACT_STR (V_XMLDOC, 'cancelReason')
		       );
	END;

	--------------------------------
	-- ERLR_APPEAL table
	--------------------------------	
	DELETE ERLR_APPEAL WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    V_APPEAL_TYPE := FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_APPEAL_TYPE');
    IF V_APPEAL_TYPE IS NOT NULL AND 0<LENGTH(V_APPEAL_TYPE) THEN
        INSERT INTO ERLR_APPEAL(
            ERLR_CASE_NUMBER
            , AP_ERLR_APPEAL_TYPE
            , AP_ERLR_APPEAL_FILE_DT
            , AP_ERLR_APPEAL_TIMING
            , AP_APPEAL_HEARING_REQUESTED
            , AP_ARBITRATOR_LAST_NAME
            , AP_ARBITRATOR_FIRST_NAME
            , AP_ARBITRATOR_MIDDLE_NAME
            , AP_ARBITRATOR_EMAIL
            , AP_ARBITRATOR_PHONE_NUM
            , AP_ARBITRATOR_ORG_AFFIL
            , AP_ARBITRATOR_MAILING_ADDR
            , AP_ERLR_PREHEARING_DT
            , AP_ERLR_HEARING_DT    
            , AP_POSTHEARING_BRIEF_DUE
            , AP_FINAL_ARBITRATOR_DCSN_DT
            , AP_ERLR_EXCEPTION_FILED
            , AP_ERLR_EXCEPTION_FILE_DT
            , AP_RESPON_TO_EXCEPT_DUE
            , AP_FINAL_FLRA_DECISION_DT
            , AP_ERLR_STEP_DECISION_DT
            , AP_ERLR_ARBITRATION_INVOKED
            , AP_ARBITRATOR_LAST_NAME_3
            , AP_ARBITRATOR_FIRST_NAME_3
            , AP_ARBITRATOR_MIDDLE_NAME_3
            , AP_ARBITRATOR_EMAIL_3
            , AP_ARBITRATOR_PHONE_NUM_3
            , AP_ARBITRATOR_ORG_AFFIL_3
            , AP_ARBITRATION_MAILING_ADDR_3
            , AP_ERLR_PREHEARING_DT_2
            , AP_ERLR_HEARING_DT_2
            , AP_POSTHEARING_BRIEF_DUE_2
            , AP_FINAL_ARBITRATOR_DCSN_DT_2
            , AP_ERLR_EXCEPTION_FILED_2
            , AP_ERLR_EXCEPTION_FILE_DT_2
            , AP_RESPON_TO_EXCEPT_DUE_2
            , AP_FINAL_FLRA_DECISION_DT_2
            , AP_ARBITRATOR_LAST_NAME_2
            , AP_ARBITRATOR_FIRST_NAME_2
            , AP_ARBITRATOR_MIDDLE_NAME_2
            , AP_ARBITRATOR_EMAIL_2
            , AP_ARBITRATOR_PHONE_NUM_2
            , AP_ARBITRATOR_ORG_AFFIL_2
            , AP_ARBITRATION_MAILING_ADDR_2
            , AP_ERLR_PREHEARING_DT_SC
            , AP_ERLR_HEARING_DT_SC
            , AP_ARBITRATOR_LAST_NAME_4
            , AP_ARBITRATOR_FIRST_NAME_4
            , AP_ARBITRATOR_MIDDLE_NAME_4
            , AP_ARBITRATOR_EMAIL_4
            , AP_ARBITRATOR_PHONE_NUM_4
            , AP_ARBITRATOR_ORG_AFFIL_4
            , AP_ARBITRATOR_MAILING_ADDR_4
            , AP_DT_SETTLEMENT_DISCUSSION
            , AP_DT_PREHEARING_DISCLOSURE
            , AP_DT_AGNCY_FILE_RESPON_DUE
            , AP_ERLR_PREHEARING_DT_MSPB
            , AP_WAS_DISCOVERY_INITIATED
            , AP_ERLR_DT_DISCOVERY_DUE
            , AP_ERLR_HEARING_DT_MSPB
            , AP_PETITION_FILE_DT_MSPB
            , AP_WAS_PETITION_FILED_MSPB
            , AP_INITIAL_DECISION_DT_MSPB
            , AP_FINAL_BOARD_DCSN_DT_MSPB
            , AP_DT_SETTLEMENT_DISCUSSION_2
            , AP_DT_PREHEARING_DISCLOSURE_2
            , AP_DT_AGNCY_FILE_RESPON_DUE_2
            , AP_ERLR_PREHEARING_DT_FLRA
            , AP_ERLR_HEARING_DT_FLRA
            , AP_INITIAL_DECISION_DT_FLRA
            , AP_WAS_PETITION_FILED_FLRA
            , AP_PETITION_FILE_DT_FLRA
            , AP_FINAL_BOARD_DCSN_DT_FLRA
            )VALUES(
            V_CASE_NUMBER
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_APPEAL_TYPE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_APPEAL_FILE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_APPEAL_TIMING')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_APPEAL_HEARING_REQUESTED')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_LAST_NAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_FIRST_NAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_MIDDLE_NAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_EMAIL')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_PHONE_NUMBER')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATION_MAILING_ADDR')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_PREHEARING_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_HEARING_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_POSTHEARING_BRIEF_DUE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_FINAL_ARBITRATOR_DECISION_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_EXCEPTION_FILED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_EXCEPTION_FILE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_RESPONSE_TO_EXCEPTIONS_DUE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_FINAL_FLRA_DECISION_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_STEP_DECISION_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATION_INVOKED')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_LAST_NAME_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_FIRST_NAME_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_MIDDLE_NAME_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_EMAIL_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_PHONE_NUMBER_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATION_MAILING_ADDR_3')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_PREHEARING_DT_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_HEARING_DT_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_POSTHEARING_BRIEF_DUE_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_FINAL_ARBITRATOR_DECISION_DT_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_EXCEPTION_FILED_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_EXCEPTION_FILE_DT_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_RESPONSE_TO_EXCEPTIONS_DUE_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_FINAL_FLRA_DECISION_DT_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_LAST_NAME_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_FIRST_NAME_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_MIDDLE_NAME_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_EMAIL_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_PHONE_NUMBER_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATION_MAILING_ADDR_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_PREHEARING_DT_SC')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_HEARING_DT_SC')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_LAST_NAME_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_FIRST_NAME_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_MIDDLE_NAME_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_EMAIL_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_PHONE_NUMBER_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_ARBITRATION_MAILING_ADDR')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_DT_SETTLEMENT_DISCUSSION')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_DT_PREHEARING_DISCLOSURE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_DT_AGENCY_FILE_RESPONSE_DUE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_PREHEARING_DT_MSPB')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_WAS_DISCOVERY_INITIATED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_DT_DISCOVERY_DUE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_HEARING_DT_MSPB')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_PETITION_4REVIEW_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_WAS_PETITION_4REVIEW_MSPB')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_initial_decision_MSPB_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_FINAL_DECISION_MSPB_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_DT_SETTLEMENT_DISCUSSION_FLRA')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_DT_PREHEARING_DISCLOSURE_FLRA')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_DT_AGENCY_FILE_RESPONSE_DUE_FLRA')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_PREHEARING_DT_FLRA')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_HEARING_DT_FLRA')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_DECISION_DT_FLRA')
            , FN_EXTRACT_STR (V_XMLDOC, 'AP_ERLR_WAS_DECISION_APPEALED_FLRA')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_APPEAL_FILE_DT_FLRA')
            , FN_EXTRACT_DATE(V_XMLDOC, 'AP_ERLR_FINAL_DECISION_FLRA_DT')
            );
    END IF;    

	--------------------------------
	-- ERLR_CNDT_ISSUE table
	--------------------------------
	DELETE ERLR_CNDT_ISSUE WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 743 THEN
        INSERT INTO ERLR_CNDT_ISSUE(
            ERLR_CASE_NUMBER
            , CI_ACTION_TYPE
            , CI_ADMIN_INVESTIGATORY_LEAVE
            , CI_ADMIN_NOTICE_LEAVE            
            , CI_LEAVE_START_DT
            , CI_LEAVE_END_DT
            , CI_APPROVAL_NAME
            , CI_LEAVE_START_DT_2
            , CI_LEAVE_END_DT_2
            , CI_APPROVAL_NAME_2
            , CI_PROP_ACTION_ISSUED_DT
            , CI_ORAL_PREZ_REQUESTED
            , CI_ORAL_PREZ_DT
            , CI_ORAL_RESPONSE_SUBMITTED
            , CI_RESPONSE_DUE_DT
            , CI_WRITTEN_RESPONSE_SBMT_DT
            , CI_POS_TITLE
            , CI_PPLAN
            , CI_SERIES
            , CI_CURRENT_INFO_GRADE
            , CI_CURRENT_INFO_STEP
            , CI_PROPOSED_POS_TITLE
            , CI_PROPOSED_PPLAN
            , CI_PROPOSED_SERIES
            , CI_PROPOSED_INFO_GRADE
            , CI_PROPOSED_INFO_STEP
            , CI_FINAL_POS_TITLE
            , CI_FINAL_PPLAN
            , CI_FINAL_SERIES
            , CI_FINAL_INFO_GRADE
            , CI_FINAL_INFO_STEP
            , CI_DEMO_FINAL_AGNCY_DCSN
            , CI_DECIDING_OFFCL
            , CI_DECISION_ISSUED_DT
            , CI_DEMO_FINAL_AGENCY_EFF_DT
            , CI_NUMB_DAYS
            , CI_COUNSEL_TYPE
            , CI_COUNSEL_ISSUED_DT
            , CI_SICK_LEAVE_ISSUED_DT
            , CI_RESTRICTION_ISSED_DT
            , CI_SL_REVIEWED_DT_LIST
            , CI_SL_WARNING_DISCUSS_DT_LIST
            , CI_SL_WARN_ISSUE
            , CI_NOTICE_ISSUED_DT
            , CI_EFFECTIVE_DT
            , CI_CURRENT_ADMIN_CODE
            , CI_RE_ASSIGNMENT_CURR_ORG
            , CI_FINAL_ADMIN_CODE
            , CI_RE_ASSIGNMENT_FINAL_ORG
            , CI_REMOVAL_PROP_ACTION_DT
            , CI_EMP_NOTICE_LEAVE_PLACED
            , CI_REMOVAL_NOTICE_START_DT
            , CI_REMOVAL_NOTICE_END_DT
            , CI_RMVL_ORAL_PREZ_RQSTED
            , CI_REMOVAL_ORAL_PREZ_DT
            , CI_RMVL_WRTN_RESPONSE
            , CI_WRITTEN_RESPONSE_DUE_DT
            , CI_WRITTEN_SUBMITTED_DT
            , CI_RMVL_FINAL_AGNCY_DCSN
            , CI_DECIDING_OFFCL_NAME
            , CI_RMVL_DATE_DCSN_ISSUED
            , CI_REMOVAL_EFFECTIVE_DT
            , CI_RMVL_NUMB_DAYS
            , CI_SUSPENTION_TYPE
            , CI_SUSP_PROP_ACTION_DT
            , CI_SUSP_ORAL_PREZ_REQUESTED
            , CI_SUSP_ORAL_PREZ_DT
            , CI_SUSP_WRITTEN_RESP
            , CI_SUSP_WRITTEN_RESP_DUE_DT
            , CI_SUSP_WRITTEN_RESP_DT
            , CI_SUSP_FINAL_AGNCY_DCSN
            , CI_SUSP_DECIDING_OFFCL_NAME
            , CI_SUSP_DECISION_ISSUED_DT
            , CI_SUSP_EFFECTIVE_DECISION_DT
            , CI_SUS_NUMB_DAYS
            , CI_REPRIMAND_ISSUE_DT
            , CI_EMP_APPEAL_DECISION               
            )
            VALUES
            (
            V_CASE_NUMBER
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_ACTION_TYPE')
            ,CASE WHEN FN_EXTRACT_STR (V_XMLDOC, 'CI_ADMIN_INVESTIGATORY_LEAVE') = 'true'  THEN '1' ELSE '0' END
            ,CASE WHEN FN_EXTRACT_STR (V_XMLDOC, 'CI_ADMIN_NOTICE_LEAVE') = 'true'  THEN '1' ELSE '0' END
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_LEAVE_START_DT')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_LEAVE_END_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_APPROVAL_NAME', 'value/name')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_LEAVE_START_DT_2')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_LEAVE_END_DT_2')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_APPROVAL_NAME_2', 'value/name')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_PROP_ACTION_ISSUED_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_ORAL_PREZ_REQUESTED')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_ORAL_PREZ_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_ORAL_RESPONSE_SUBMITTED')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_RESPONSE_DUE_DT')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_WRITTEN_RESPONSE_SUBMITTED_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_POS_TITLE')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_PPLAN')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_SERIES')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_CURRENT_INFO_GRADE')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_CURRENT_INFO_STEP')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_PROPOSED_POS_TITLE')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_PROPOSED_PPLAN')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_PROPOSED_SERIES')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_PROPOSED_INFO_GRADE')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_PROPOSED_INFO_STEP')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_FINAL_POS_TITLE')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_FINAL_PPLAN')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_FINAL_SERIES')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_FINAL_INFO_GRADE')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_FINAL_INFO_STEP')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_DEMO_FINAL_AGENCY_DECISION')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_DECIDING_OFFCL', 'value/name')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_DECISION_ISSUED_DT')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_DEMO_FINAL_AGENCY_EFF_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_NUMB_DAYS')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_COUNSEL_TYPE')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_COUNSEL_ISSUED_DT')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_SICK_LEAVE_ISSUED_DT')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_RESTRICTION_ISSED_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_SICK_LEAVE_REVIEWED_DT_LIST')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_SL_WARNING_DISCUSSION_DT_LIST')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_SL_WARN_ISSUE')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_NOTICE_ISSUED_DT')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_EFFECTIVE_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_CURRENT_ADMIN_CODE')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_RE_ASSIGNMENT_CURR_ORG')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_FINAL_ADMIN_CODE')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_RE_ASSIGNMENT_FINAL_ORG')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_REMOVAL_PROP_ACTION_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_EMP_NOTICE_LEAVE_PLACED')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_REMOVAL_NOTICE_START_DT')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_REMOVAL_NOTICE_END_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_REMOVAL_ORAL_PREZ_REQUESTED')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_REMOVAL_ORAL_PREZ_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_REMOVAL_WRITTEN_RESPONSE')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_WRITTEN_RESPONSE_DUE_DT')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_WRITTEN_SUBMITTED_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_RMVL_FINAL_AGENCY_DECISION')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_DECIDING_OFFCL_NAME', 'value/name')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_REMOVAL_DATE_DECISION_ISSUED')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_REMOVAL_EFFECTIVE_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_RMVL_NUMB_DAYS')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_SUSPENTION_TYPE')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_SUSP_PROP_ACTION_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_SUSP_ORAL_PREZ_REQUESTED')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_SUSP_ORAL_PREZ_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_SUSP_WRITTEN_RESP')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_SUSP_WRITTEN_RESP_DUE_DT')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_SUSP_WRITTEN_RESP_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_SUSP_FINAL_AGENCY_DECISION')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_SUSP_DECIDING_OFFCL_NAME', 'value/name')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_SUSP_DECISION_ISSUED_DT')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_SUSP_EFFECTIVE_DECISION_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_SUS_NUMB_DAYS')
            ,FN_EXTRACT_DATE(V_XMLDOC, 'CI_REPRIMAND_ISSUE_DT')
            ,FN_EXTRACT_STR (V_XMLDOC, 'CI_EMP_APPEAL_DECISION')
            );
    END IF;
    
	--------------------------------
	-- ERLR_PERF_ISSUE table
	--------------------------------
	DELETE ERLR_PERF_ISSUE WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 750 THEN
        INSERT INTO ERLR_PERF_ISSUE(
            ERLR_CASE_NUMBER
            , PI_ACTION_TYPE
            , PI_NEXT_WGI_DUE_DT    
            , PI_PERF_COUNSEL_ISSUE_DT    
            , PI_CNSL_GRV_DECISION
            , PI_DMTN_PRPS_ACTN_ISSUE_DT    
            , PI_DMTN_ORAL_PRSNT_REQ
            , PI_DMTN_ORAL_PRSNT_DT    
            , PI_DMTN_WRTN_RESP_SBMT
            , PI_DMTN_WRTN_RESP_DUE_DT    
            , PI_DMTN_WRTN_RESP_SBMT_DT    
            , PI_DMTN_CUR_POS_TITLE
            , PI_DMTN_CUR_PAY_PLAN
            , PI_DMTN_CUR_JOB_SERIES
            , PI_DMTN_CUR_GRADE
            , PI_DMTN_CUR_STEP
            , PI_DMTN_PRPS_POS_TITLE
            , PI_DMTN_PRPS_PAY_PLAN
            , PI_DMTN_PRPS_JOB_SERIES
            , PI_DMTN_PRPS_GRADE
            , PI_DMTN_PRP_STEP
            , PI_DMTN_FIN_POS_TITLE
            , PI_DMTN_FIN_PAY_PLAN
            , PI_DMTN_FIN_JOB_SERIES
            , PI_DMTN_FIN_GRADE
            , PI_DMTN_FIN_STEP
            , PI_DMTN_FIN_AGCY_DECISION
            , PI_DMTN_FIN_DECIDING_OFC
            , PI_DMTN_FIN_DECISION_ISSUE_DT    
            , PI_DMTN_DECISION_EFF_DT    
            , PI_DMTN_APPEAL_DECISION
            , PI_PIP_RSNBL_ACMDTN
            , PI_PIP_EMPL_SBMT_MEDDOC
            , PI_PIP_DOC_SBMT_FOH_RVW
            , PI_PIP_WGI_WTHLD
            , PI_PIP_WGI_RVW_DT    
            , PI_PIP_MEDDOC_RVW_OUTCOME
            , PI_PIP_START_DT    
            , PI_PIP_END_DT    
            , PI_PIP_EXT_END_DT    
            , PI_PIP_EXT_END_REASON
            , PI_PIP_EXT_END_NOTIFY_DT    
            , PI_PIP_EXT_DT_LIST    
            , PI_PIP_ACTUAL_DT    
            , PI_PIP_END_PRIOR_TO_PLAN
            , PI_PIP_END_PRIOR_TO_PLAN_RSN
            , PI_PIP_SUCCESS_CMPLT
            , PI_PIP_PMAP_RTNG_SIGN_DT    
            , PI_PIP_PMAP_RVW_SIGN_DT    
            , PI_PIP_PRPS_ACTN    
            , PI_PIP_PRPS_ISSUE_DT    
            , PI_PIP_ORAL_PRSNT_REQ    
            , PI_PIP_ORAL_PRSNT_DT    
            , PI_PIP_WRTN_RESP_SBMT    
            , PI_PIP_WRTN_RESP_DUE_DT    
            , PI_PIP_WRTN_SBMT_DT    
            , PI_PIP_FIN_AGCY_DECISION
            , PI_PIP_DECIDING_OFFICAL
            , PI_PIP_FIN_AGCY_DECISION_DT    
            , PI_PIP_DECISION_ISSUE_DT    
            , PI_PIP_EFF_ACTN_DT    
            , PI_PIP_EMPL_GRIEVANCE    
            , PI_PIP_APPEAL_DECISION
            , PI_REASGN_NOTICE_DT    
            , PI_REASGN_EFF_DT    
            , PI_REASGN_CUR_ADMIN_CD
            , PI_REASGN_CUR_ORG_NM    
            , PI_REASGN_FIN_ADMIN_CD
            , PI_REASGN_FIN_ORG_NM    
            , PI_RMV_PRPS_ACTN_ISSUE_DT    
            , PI_RMV_EMPL_NOTC_LEV    
            , PI_RMV_NOTC_LEV_START_DT    
            , PI_RMV_NOTC_LEV_END_DT    
            , PI_RMV_ORAL_PRSNT_REQ    
            , PI_RMV_ORAL_PRSNT_DT    
            , PI_RMV_WRTN_RESP_DUE_DT    
            , PI_RMV_WRTN_RESP_SBMT_DT    
            , PI_RMV_FIN_AGCY_DECISION    
            , PI_RMV_FIN_DECIDING_OFC    
            , PI_RMV_DECISION_ISSUE_DT    
            , PI_RMV_EFF_DT    
            , PI_RMV_NUM_DAYS    
            , PI_RMV_APPEAL_DECISION    
            , PI_WRTN_NRTV_RVW_TYPE    
            , PI_WNR_SPCLST_RVW_CMPLT_DT    
            , PI_WNR_MGR_RVW_RTNG_DT    
            , PI_WNR_CRITICAL_ELM    
            , PI_WNR_FIN_RATING
            , PI_WNR_RVW_OFC_CONCUR_DT    
            , PI_WNR_WGI_WTHLD
            , PI_WNR_WGI_RVW_DT
            , PI_CLPD_ENTRANCE_DUTY_DT
            , PI_CLPD_NEXT_CLP_DUE_DT
            , PI_CLPD_PRE_WITHHELD
            , PI_CLPD_FIRST_WNI_DT
            , PI_CLPD_NEXT_REVIEW_DUE_DT
            , PI_CLPD_DAPI_DT
            , PI_CLPD_FIRST_WITHHELD_DT
            , PI_CLPD_PLANNED_REVIEW_DT
            , PI_CLPD_DETER_FAV
            , PI_CLPD_SECOND_WNI_DT
            , PI_CLPD_DECISION_ISSUED_DT
            , PI_CLPD_DECIDING_OFFCL
            , PI_CLPD_EMP_GRIEVANCE
            , PI_CLPD_EMP_APPEAL_DECISION            
            )VALUES(
            V_CASE_NUMBER
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_ACTION_TYPE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_NEXT_WGI_DUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PERF_COUNSEL_ISSUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_CNSL_GRV_DECISION')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_DMTN_PRPS_ACTN_ISSUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_ORAL_PRSNT_REQ')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_DMTN_ORAL_PRSNT_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_WRTN_RESP_SBMT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_DMTN_WRTN_RESP_DUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_DMTN_WRTN_RESP_SBMT_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_CUR_POS_TITLE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_CUR_PAY_PLAN')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_CUR_JOB_SERIES')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_CUR_GRADE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_CUR_STEP')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_PRPS_POS_TITLE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_PRPS_PAY_PLAN')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_PRPS_JOB_SERIES')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_PRPS_GRADE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_PRP_STEP')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_FIN_POS_TITLE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_FIN_PAY_PLAN')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_FIN_JOB_SERIES')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_FIN_GRADE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_FIN_STEP')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_FIN_AGCY_DECISION')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_FIN_DECIDING_OFC_NM', 'value/name')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_DMTN_FIN_DECISION_ISSUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_DMTN_DECISION_EFF_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_DMTN_APPEAL_DECISION')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_RSNBL_ACMDTN')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_EMPL_SBMT_MEDDOC')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_DOC_SBMT_FOH_RVW')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_WGI_WTHLD')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_WGI_RVW_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_MEDDOC_RVW_OUTCOME')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_START_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_END_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_EXT_END_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_EXT_END_REASON')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_EXT_END_NOTIFY_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_EXT_DT_LIST')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_ACTUAL_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_END_PRIOR_TO_PLAN')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_END_PRIOR_TO_PLAN_RSN')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_SUCCESS_CMPLT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_PMAP_RTNG_SIGN_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_PMAP_RVW_SIGN_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_PRPS_ACTN')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_PRPS_ISSUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_ORAL_PRSNT_REQ')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_ORAL_PRSNT_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_WRTN_RESP_SBMT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_WRTN_RESP_DUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_WRTN_SBMT_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_FIN_AGCY_DECISION')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_DECIDING_OFFICAL_NM', 'value/name')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_FIN_AGCY_DECISION_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_DECISION_ISSUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_PIP_EFF_ACTN_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_EMPL_GRIEVANCE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_PIP_APPEAL_DECISION')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_REASGN_NOTICE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_REASGN_EFF_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_REASGN_CUR_ADMIN_CD')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_REASGN_CUR_ORG_NM')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_REASGN_FIN_ADMIN_CD')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_REASGN_FIN_ORG_NM')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_RMV_PRPS_ACTN_ISSUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_RMV_EMPL_NOTC_LEV')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_RMV_NOTC_LEV_START_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_RMV_NOTC_LEV_END_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_RMV_ORAL_PRSNT_REQ')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_RMV_ORAL_PRSNT_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_RMV_WRTN_RESP_DUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_RMV_WRTN_RESP_SBMT_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_RMV_FIN_AGCY_DECISION')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_RMV_FIN_DECIDING_OFC_NM', 'value/name')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_RMV_DECISION_ISSUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_RMV_EFF_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_RMV_NUM_DAYS')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_RMV_APPEAL_DECISION')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_WRTN_NRTV_RVW_TYPE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_WNR_SPCLST_RVW_CMPLT_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_WNR_MGR_RVW_RTNG_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_WNR_CRITICAL_ELM')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_WNR_FIN_RATING')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_WNR_RVW_OFC_CONCUR_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_WNR_WGI_WTHLD')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_WNR_WGI_RVW_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_CLPD_ENTRANCE_DUTY_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_CLPD_NEXT_CLP_DUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_CLPD_PRE_WITHHELD')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_CLPD_FIRST_WNI_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_CLPD_NEXT_REVIEW_DUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_CLPD_DAPI_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_CLPD_FIRST_WITHHELD_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_CLPD_PLANNED_REVIEW_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_CLPD_DETER_FAV')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_CLPD_SECOND_WNI_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PI_CLPD_DECISION_ISSUED_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_CLPD_DECIDING_OFFCL', 'value/name')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_CLPD_EMP_GRIEVANCE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PI_CLPD_EMP_APPEAL_DECISION')            
            );
    END IF;
    
	--------------------------------
	-- ERLR_GRIEVANCE table
	--------------------------------
	DELETE ERLR_GRIEVANCE WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 745 THEN
        INSERT INTO ERLR_GRIEVANCE(
            ERLR_CASE_NUMBER
            , GI_TYPE                
            , GI_NEGOTIATED_GRIEVANCE_TYPE                
            , GI_TIMELY_FILING_2
            , GI_IND_MANAGER
            , GI_FILING_DT_2
            , GI_TIMELY_FILING
            , GI_FILING_DT
            , GI_IND_MEETING_DT
            , GI_IND_STEP_1_DECISION_DT
            , GI_IND_DECISION_ISSUE_DT
            , GI_IND_STEP_1_DEADLINE
            , GI_IND_STEP_1_EXT_DUE_DT
            , GI_IND_STEP_1_EXT_DUE_REASON
            , GI_STEP_2_REQUEST
            , GI_IND_STEP_2_MTG_DT
            , GI_IND_STEP_2_DECISION_DUE_DT
            , GI_IND_STEP_2_DCSN_ISSUE_DT    
            , GI_IND_STEP_2_DEADLINE
            , GI_IND_EXT_2_EXT_DUE_DT
            , GI_IND_STEP_2_EXT_DUE_REASON
            , GI_IND_THIRD_PARTY_APPEAL_DT
            , GI_IND_THIRD_APPEAL_REQUEST
            , GI_UM_GRIEVABILITY
            , GI_MEETING_DT
            , GI_GRIEVANCE_STATUS
            , GI_ARBITRATION_DEADLINE_DT
            , GI_ARBITRATION_REQUEST
            , GI_ADMIN_OFFCL_1
            , GI_ADMIN_STG_1_DECISION_DT
            , GI_ADMIN_STG_1_ISSUE_DT    
            , GI_ADMIN_STG_2_RESP
            , GI_ADMIN_OFFCL_2
            , GI_ADMIN_STG_2_DECISION_DT
            , GI_ADMIN_STG_2_ISSUE_DT
            , GI_GRIEVANCE_RELATED_2_PMAP
            , GI_GRIEVANCE_RELATED_2_PMAP_2
            ) VALUES (
            V_CASE_NUMBER
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_TYPE')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_NEGOTIATED_GRIEVANCE_TYPE')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_TIMELY_FILING_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_IND_MANAGER', 'value/name')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_FILING_DT_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_TIMELY_FILING')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_FILING_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_IND_MEETING_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_IND_STEP_1_DECISION_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_IND_DECISION_ISSUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_IND_STEP_1_DEADLINE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_IND_STEP_1_EXT_DUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_IND_STEP_1_EXT_DUE_REASON')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_STEP_2_REQUEST')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_IND_STEP_2_MTG_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_IND_STEP_2_DECISION_DUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_IND_STEP_2_DECISION_ISSUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_IND_STEP_2_DEADLINE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_IND_EXT_2_EXT_DUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_IND_STEP_2_EXT_DUE_REASON')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_IND_THIRD_PARTY_APPEAL_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_IND_THIRD_APPEAL_REQUEST')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_UM_GRIEVABILITY')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_MEETING_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_GRIEVANCE_STATUS')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_ARBITRATION_DEADLINE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_ARBITRATION_REQUEST')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_ADMIN_OFFCL_1', 'value/name')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_ADMIN_STG_1_DECISION_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_ADMIN_STG_1_ISSUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_ADMIN_STG_2_RESP')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_ADMIN_OFFCL_2', 'value/name')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_ADMIN_STG_2_DECISION_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'GI_ADMIN_STG_2_ISSUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_GRIEVANCE_RELATED_2_PMAP')
            , FN_EXTRACT_STR (V_XMLDOC, 'GI_GRIEVANCE_RELATED_2_PMAP_2')            
            );
    END IF;
    
	--------------------------------
	-- ERLR_INVESTIGATION table
	--------------------------------
	DELETE ERLR_INVESTIGATION WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 744 THEN
        INSERT INTO ERLR_INVESTIGATION(
            ERLR_CASE_NUMBER
            , INVESTIGATION_TYPE
            , I_MISCONDUCT_FOUND 
            ) VALUES (
            V_CASE_NUMBER
            , FN_EXTRACT_STR (V_XMLDOC, 'INVESTIGATION_TYPE')
            , FN_EXTRACT_STR (V_XMLDOC, 'I_MISCONDUCT_FOUND')
            );
    END IF;
    
	--------------------------------
	-- ERLR_WGI_DNL table
	--------------------------------
	DELETE ERLR_WGI_DNL WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 809 THEN
        INSERT INTO ERLR_WGI_DNL(
            ERLR_CASE_NUMBER
            , WGI_DTR_DENIAL_ISSUED_DT
            , WGI_DTR_EMP_REQ_RECON
            , WGI_DTR_RECON_REQ_DT
            , WGI_DTR_RECON_ISSUE_DT
            , WGI_DTR_DENIED
            , WGI_DTR_DENIAL_ISSUE_TO_EMP_DT
            , WGI_RVW_REDTR_NOTI_ISSUED_DT
            , WGI_REVIEW_DTR_FAVORABLE
            , WGI_REVIEW_EMP_REQ_RECON
            , WGI_REVIEW_RECON_REQ_DT
            , WGI_REVIEW_RECON_ISSUE_DT
            , WGI_REVIEW_DENIED
            , WGI_EMP_APPEAL_DECISION
            )VALUES(
            V_CASE_NUMBER
            , FN_EXTRACT_DATE(V_XMLDOC, 'WGI_DTR_DENIAL_ISSUED_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'WGI_DTR_EMP_REQ_RECON')
            , FN_EXTRACT_DATE(V_XMLDOC, 'WGI_DTR_RECON_REQ_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'WGI_DTR_RECON_ISSUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'WGI_DTR_DENIED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'WGI_DTR_DENIAL_ISSUE_TO_EMP_DT'                            )
            , FN_EXTRACT_DATE(V_XMLDOC, 'WGI_REVIEW_DTR_NOTICE_ISSUED_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'WGI_REVIEW_DTR_FAVORABLE')
            , FN_EXTRACT_STR (V_XMLDOC, 'WGI_REVIEW_EMP_REQ_RECON')
            , FN_EXTRACT_DATE(V_XMLDOC, 'WGI_REVIEW_RECON_REQ_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'WGI_REVIEW_RECON_ISSUE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'WGI_REVIEW_DENIED')
            , FN_EXTRACT_STR (V_XMLDOC, 'WGI_EMP_APPEAL_DECISION')
            );
    END IF;
    
	--------------------------------
	-- ERLR_MEDDOC table
	--------------------------------
	DELETE ERLR_MEDDOC WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 746 THEN
        INSERT INTO ERLR_MEDDOC(
            ERLR_CASE_NUMBER
            , MD_REQUEST_REASON
            , MD_MED_DOC_SBMT_DEADLINE_DT
            , MD_FMLA_DOC_SBMT_DT
            , MD_FMLA_BEGIN_DT
            , MD_FMLA_APROVED
            , MD_FMLA_DISAPRV_REASON
            , MD_FMLA_GRIEVANCE
            , MD_MEDEXAM_EXTENDED
            , MD_MEDEXAM_ACCEPTED
            , MD_MEDEXAM_RECEIVED_DT
            , MD_DOC_SUBMITTED
            , MD_DOC_SBMT_DT
            , MD_DOC_SBMT_FOH
            , MD_DOC_REVIEW_OUTCOME
            , MD_DOC_ADMTV_ACCEPTABLE
            , MD_DOC_ADMTV_REJECT_REASON
            , MD_FMLA_EXHAUSTED_WITHIN_12M
            , MD_FMLA_LENGTH_OF_LEAVE
        )VALUES(
            V_CASE_NUMBER
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_REQUEST_REASON')
            , FN_EXTRACT_DATE(V_XMLDOC, 'MD_MED_DOC_SBMT_DEADLINE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'MD_FMLA_DOC_SBMT_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'MD_FMLA_BEGIN_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_FMLA_APROVED')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_FMLA_DISAPRV_REASON')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_FMLA_GRIEVANCE')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_MEDEXAM_EXTENDED')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_MEDEXAM_ACCEPTED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'MD_MEDEXAM_RECEIVED_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_DOC_SUBMITTED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'MD_DOC_SBMT_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_DOC_SBMT_FOH')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_DOC_REVIEW_OUTCOME')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_DOC_ADMTV_ACCEPTABLE')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_DOC_ADMTV_REJECT_REASON')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_FMLA_EXHAUSTED_WITHIN_12M')
            , FN_EXTRACT_STR (V_XMLDOC, 'MD_FMLA_LENGTH_OF_LEAVE')
        );
    END IF;
    
	--------------------------------
	-- ERLR_INFO_REQUEST table
	--------------------------------
	DELETE ERLR_INFO_REQUEST WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 747 THEN
        INSERT INTO ERLR_INFO_REQUEST(
            ERLR_CASE_NUMBER
            , IR_REQUESTER    
            , IR_CMS_REQUESTER_NAME    
            , IR_CMS_REQUESTER_PHONE    
            , IR_NCMS_REQUESTER_LAST_NAME    
            , IR_NCMS_REQUESTER_FIRST_NAME
            , IR_NCMS_REQUESTER_MN    
            , IR_NON_CMS_REQUESTER_PHONE    
            , IR_NON_CMS_REQUESTER_EMAIL    
            , IR_NCMS_REQUESTER_ORG_AFFIL    
            , IR_SUBMIT_DT
            , IR_MEET_PTCLRIZED_NEED_STND
            , IR_RSNABLY_AVAIL_N_NECESSARY
            , IR_PRTCT_DISCLOSURE_BY_LAW
            , IR_MAINTAINED_BY_AGENCY
            , IR_COLLECTIVE_BARGAINING_UNIT
            , IR_APPROVE
            , IR_PROVIDE_DT
            , IR_DENIAL_NOTICE_DT_LIST
            , IR_APPEAL_DENIAL
        )VALUES(
            V_CASE_NUMBER
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_REQUESTER')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_CMS_REQUESTER_NAME', 'value/value')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_CMS_REQUESTER_PHONE')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_NON_CMS_REQUESTER_LAST_NAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_NON_CMS_REQUESTER_FIRST_NAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_NON_CMS_REQUESTER_MIDDLE_NAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_NON_CMS_REQUESTER_PHONE')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_NON_CMS_REQUESTER_EMAIL')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_NON_CMS_REQUESTER_ORGANIZATION_AFFILIATION')
            , FN_EXTRACT_DATE(V_XMLDOC, 'IR_SUBMIT_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_MEET_PARTICULARIZED_NEED_STANDARD')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_REASONABLY_AVAILABLE_AND_NECESSARY')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_PROTECTED_FROM_DISCLOSURE_BY_LAW')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_MAINTAINED_BY_AGENCY')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_COLLECTIVE_BARGAINING_UNIT')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_APPROVE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'IR_PROVIDE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_PROVIDE_DT_LIST')
            , FN_EXTRACT_STR (V_XMLDOC, 'IR_APPEAL_DENIAL')
        );
    END IF;
    
	--------------------------------
	-- ERLR_3RDPARTY_HEAR table
	--------------------------------
	DELETE ERLR_3RDPARTY_HEAR WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 753 THEN
        INSERT INTO ERLR_3RDPARTY_HEAR(
              ERLR_CASE_NUMBER
            , THRD_PRTY_APPEAL_TYPE
            , THRD_PRTY_APPEAL_FILE_DT
            , THRD_PRTY_ASSISTANCE_REQ_DT
            , THRD_PRTY_HEARING_TIMING
            , THRD_PRTY_HEARING_REQUESTED
            , THRD_PRTY_STEP_DECISION_DT
            , THRD_PRTY_ARBITRATION_INVOKED
            , THRD_PRTY_ARBIT_LNM_3
            , THRD_PRTY_ARBIT_FNM_3
            , THRD_PRTY_ARBIT_MNM_3
            , THRD_PRTY_ARBIT_EMAIL_3
            , THRD_ERLR_ARBIT_PHONE_NUM_3
            , THRD_PRTY_ARBIT_ORG_AFFIL_3
            , THRD_PRTY_ARBIT_MAILING_ADDR_3
            , THRD_PRTY_PREHEARING_DT_2
            , THRD_PRTY_HEARING_DT_2
            , THRD_PRTY_POSTHEAR_BRIEF_DUE_2
            , THRD_PRTY_FNL_ARBIT_DCSN_DT_2
            , THRD_PRTY_EXCEPTION_FILED_2
            , THRD_PRTY_EXCEPTION_FILE_DT_2
            , THRD_PRTY_RSPS_TO_EXCPT_DUE_2
            , THRD_PRTY_FNL_FLRA_DCSN_DT_2
            , THRD_PRTY_ARBIT_LNM
            , THRD_PRTY_ARBIT_FNM
            , THRD_PRTY_ARBIT_MNM
            , THRD_PRTY_ARBIT_EMAIL
            , THRD_ERLR_ARBIT_PHONE_NUM
            , THRD_PRTY_ARBIT_ORG_AFFIL
            , THRD_PRTY_ARBIT_MAILING_ADDR
            , THRD_PRTY_PREHEARING_DT
            , THRD_PRTY_HEARING_DT
            , THRD_PRTY_POSTHEAR_BRIEF_DUE
            , THRD_PRTY_FNL_ARBIT_DCSN_DT
            , THRD_PRTY_EXCEPTION_FILED
            , THRD_PRTY_EXCEPTION_FILE_DT
            , THRD_PRTY_RSPS_TO_EXCPT_DUE
            , THRD_PRTY_FNL_FLRA_DCSN_DT
            , THRD_PRTY_ARBIT_LNM_4
            , THRD_PRTY_ARBIT_FNM_4
            , THRD_PRTY_ARBIT_MNM_4
            , THRD_PRTY_ARBIT_EMAIL_4
            , THRD_ERLR_ARBIT_PHONE_NUM_4
            , THRD_PRTY_ARBIT_ORG_AFFIL_4
            , THRD_PRTY_ARBIT_MAILING_ADDR_4
            , THRD_PRTY_DT_STLMNT_DSCUSN
            , THRD_PRTY_DT_PREHEAR_DSCLS
            , THRD_PRTY_DT_AGNCY_RSP_DUE
            , THRD_PRTY_PREHEARING_DT_MSPB
            , THRD_PRTY_WAS_DSCVRY_INIT
            , THRD_PRTY_DT_DISCOVERY_DUE
            , THRD_PRTY_HEARING_DT_MSPB
            , THRD_PRTY_INIT_DCSN_DT_MSPB
            , THRD_PRTY_WAS_PETI_FILED_MSPB
            , THRD_PRTY_PETITION_RV_DT
            , THRD_PRTY_FNL_BRD_DCSN_DT_MSPB
            , THRD_PRTY_DT_STLMNT_DSCUSN_2
            , THRD_PRTY_DT_PREHEAR_DSCLS_2
            , THRD_PRTY_PREHEARING_CONF
            , THRD_PRTY_HEARING_DT_FLRA
            , THRD_PRTY_DECISION_DT_FLRA
            , THRD_PRTY_TIMELY_REQ
            , THRD_PRTY_PROC_ORDER
            , THRD_PRTY_PANEL_MEMBER_LNAME
            , THRD_PRTY_PANEL_MEMBER_FNAME
            , THRD_PRTY_PANEL_MEMBER_MNAME
            , THRD_PRTY_PANEL_MEMBER_EMAIL
            , THRD_PRTY_PANEL_MEMBER_PHONE
            , THRD_PRTY_PANEL_MEMBER_ORG
            , THRD_PRTY_PANEL_MEMBER_MAILING
            , THRD_PRTY_PANEL_DESCR         
            )VALUES(
            V_CASE_NUMBER
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_APPEAL_TYPE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_APPEAL_FILE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_ASSISTANCE_REQ_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_HEARING_TIMING')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_HEARING_REQUESTED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_STEP_DECISION_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATION_INVOKED')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_LAST_NAME_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_FIRST_NAME_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_MIDDLE_NAME_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_EMAIL_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_ERLR_ARBITRATOR_PHONE_NUMBER_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATION_ORGANIZATION_AFFILIATION_3')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATION_MAILING_ADDR_3')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_PREHEARING_DT_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_HEARING_DT_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_POSTHEARING_BRIEF_DUE_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_FINAL_ARBITRATOR_DECISION_DT_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_EXCEPTION_FILED_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_EXCEPTION_FILE_DT_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_RESPONSE_TO_EXCEPTIONS_DUE_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_FINAL_FLRA_DECISION_DT_2')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_LAST_NAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_FIRST_NAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_MIDDLE_NAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_EMAIL')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_ERLR_ARBITRATOR_PHONE_NUMBER')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATION_ORGANIZATION_AFFILIATION')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATION_MAILING_ADDR')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_PREHEARING_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_HEARING_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_POSTHEARING_BRIEF_DUE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_FINAL_ARBITRATOR_DECISION_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_EXCEPTION_FILED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_EXCEPTION_FILE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_RESPONSE_TO_EXCEPTIONS_DUE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_FINAL_FLRA_DECISION_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_LAST_NAME_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_FIRST_NAME_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_MIDDLE_NAME_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATOR_EMAIL_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_ERLR_ARBITRATOR_PHONE_NUMBER_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATION_ORGANIZATION_AFFILIATION_4')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_ARBITRATION_MAILING_ADDR_4')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_DT_SETTLEMENT_DISCUSSION')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_DT_PREHEARING_DISCLOSURE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_DT_AGENCY_FILE_RESPONSE_DUE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_PREHEARING_DT_MSPB')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_WAS_DISCOVERY_INITIATED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_DT_DISCOVERY_DUE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_HEARING_DT_MSPB')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_INITIAL_DECISION_DT_MSPB')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_WAS_PETITION_FILED_MSPB')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_PETITION_RV_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_FINAL_BOARD_DECISION_DT_MSPB')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_DT_SETTLEMENT_DISCUSSION_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_DT_PREHEARING_DISCLOSURE_2')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_PREHEARING_CONF')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_HEARING_DT_FLRA')
            , FN_EXTRACT_DATE(V_XMLDOC, 'THRD_PRTY_DECISION_DT_FLRA')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_TIMELY_REQ')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_PROC_ORDER')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_PANEL_MEMBER_LNAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_PANEL_MEMBER_FNAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_PANEL_MEMBER_MNAME')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_PANEL_MEMBER_EMAIL')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_PANEL_MEMBER_PHONE')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_PANEL_MEMBER_ORG')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_PANEL_MEMBER_MAILING')
            , FN_EXTRACT_STR (V_XMLDOC, 'THRD_PRTY_PANEL_DESCR')
            );
    END IF;
    
	--------------------------------
	-- ERLE_PROB_ACTION table
	--------------------------------
	DELETE ERLR_PROB_ACTION WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 751 THEN
        INSERT INTO ERLR_PROB_ACTION(
            ERLR_CASE_NUMBER
            , PPA_ACTION_TYPE
            , PPA_TERMINATION_TYPE
            , PPA_TERM_PROP_ACTION_DT
            , PPA_TERM_ORAL_PREZ_REQUESTED
            , PPA_TERM_ORAL_PREZ_DT    
            , PPA_TERM_WRITTEN_RESP
            , PPA_TERM_WRITTEN_RESP_DUE_DT    
            , PPA_TERM_WRITTEN_RESP_DT    
            , PPA_TERM_AGENCY_DECISION
            , PPA_TERM_DECIDING_OFFCL_NAME
            , PPA_TERM_DECISION_ISSUED_DT    
            , PPA_TERM_EFFECTIVE_DECISION_DT    
            , PPA_PROB_TERM_DCSN_ISSUED_DT    
            , PPA_PROBATION_CONDUCT
            , PPA_PROBATION_PERFORMANCE
            , PPA_APPEAL_GRIEVANCE_DEADLINE    
            , PPA_EMP_APPEAL_DECISION
            , PPA_PROP_ACTION_ISSUED_DT    
            , PPA_ORAL_PREZ_REQUESTED
            , PPA_ORAL_PREZ_DT    
            , PPA_ORAL_RESPONSE_SUBMITTED
            , PPA_RESPONSE_DUE_DT    
            , PPA_WRITTEN_RESPONSE_SBMT_DT    
            , PPA_POS_TITLE
            , PPA_PPLAN
            , PPA_SERIES
            , PPA_CURRENT_INFO_GRADE
            , PPA_CURRENT_INFO_STEP
            , PPA_PROPOSED_POS_TITLE
            , PPA_PROPOSED_PPLAN
            , PPA_PROPOSED_SERIES
            , PPA_PROPOSED_INFO_GRADE
            , PPA_PROPOSED_INFO_STEP
            , PPA_FINAL_POS_TITLE
            , PPA_FINAL_PPLAN
            , PPA_FINAL_SERIES
            , PPA_FINAL_INFO_GRADE
            , PPA_FINAL_INFO_STEP
            , PPA_NOTICE_ISSUED_DT    
            , PPA_DEMO_FINAL_AGENCY_DECISION
            , PPA_DECIDING_OFFCL
            , PPA_DECISION_ISSUED_DT    
            , PPA_DEMO_FINAL_AGENCY_EFF_DT    
            , PPA_NUMB_DAYS
            , PPA_EFFECTIVE_DT    
            , PPA_CURRENT_ADMIN_CODE
            , PPA_RE_ASSIGNMENT_CURR_ORG
            , PPA_FINAL_ADMIN_CODE
            , PPA_FINAL_ADMIN_CODE_FINAL_ORG
        )VALUES(
            V_CASE_NUMBER
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_ACTION_TYPE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_TERMINATION_TYPE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_TERM_PROP_ACTION_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_TERM_ORAL_PREZ_REQUESTED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_TERM_ORAL_PREZ_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_TERM_WRITTEN_RESP')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_TERM_WRITTEN_RESP_DUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_TERM_WRITTEN_RESP_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_TERM_AGENCY_DECISION')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_TERM_DECIDING_OFFCL_NAME', 'value/name')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_TERM_DECISION_ISSUED_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_TERM_EFFECTIVE_DECISION_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_PROBATION_TERMINATION_DECISION_ISSUED_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_PROBATION_CONDUCT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_PROBATION_PERFORMANCE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_APPEAL_GRIEVANCE_DEADLINE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_EMP_APPEAL_DECISION')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_PROP_ACTION_ISSUED_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_ORAL_PREZ_REQUESTED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_ORAL_PREZ_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_ORAL_RESPONSE_SUBMITTED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_RESPONSE_DUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_WRITTEN_RESPONSE_SUBMITTED_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_POS_TITLE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_PPLAN')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_SERIES')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_CURRENT_INFO_GRADE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_CURRENT_INFO_STEP')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_PROPOSED_POS_TITLE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_PROPOSED_PPLAN')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_PROPOSED_SERIES')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_PROPOSED_INFO_GRADE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_PROPOSED_INFO_STEP')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_FINAL_POS_TITLE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_FINAL_PPLAN')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_FINAL_SERIES')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_FINAL_INFO_GRADE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_FINAL_INFO_STEP')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_NOTICE_ISSUED_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_DEMO_FINAL_AGENCY_DECISION')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_DECIDING_OFFCL', 'value/name')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_DECISION_ISSUED_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_DEMO_FINAL_AGENCY_EFF_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_NUMB_DAYS')
            , FN_EXTRACT_DATE(V_XMLDOC, 'PPA_EFFECTIVE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_CURRENT_ADMIN_CODE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_RE_ASSIGNMENT_CURR_ORG')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_FINAL_ADMIN_CODE')
            , FN_EXTRACT_STR (V_XMLDOC, 'PPA_FINAL_ADMIN_CODE_FINAL_ORG')
        );
    END IF;
    
	--------------------------------
	-- ERLR_ULP table
	--------------------------------
	DELETE ERLR_ULP WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 754 THEN
        INSERT INTO ERLR_ULP(
            ERLR_CASE_NUMBER
            , ULP_RECEIPT_CHARGE_DT
            , ULP_CHARGE_FILED_TIMELY
            , ULP_AGENCY_RESPONSE_DT
            , ULP_FLRA_DOCUMENT_REUQESTED
            , ULP_DOC_SUBMISSION_FLRA_DT
            , ULP_DOCUMENT_DESCRIPTION
            , ULP_DISPOSITION_DT
            , ULP_DISPOSITION_TYPE
            , ULP_COMPLAINT_DT
            , ULP_AGENCY_ANSWER_DT
            , ULP_AGENCY_ANSWER_FILED_DT
            , ULP_SETTLEMENT_DISCUSSION_DT
            , ULP_PREHEARING_DISCLOSURE_DUE
            , ULP_PREHEARING_DISCLOSUE_DT
            , ULP_PREHEARING_CONFERENCE_DT
            , ULP_HEARING_DT
            , ULP_DECISION_DT
            , ULP_EXCEPTION_FILED
            , ULP_EXCEPTION_FILED_DT
        )VALUES(
            V_CASE_NUMBER
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_RECEIPT_CHARGE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'ULP_CHARGE_FILED_TIMELY')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_AGENCY_RESPONSE_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'ULP_FLRA_DOCUMENT_REUQESTED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_DOCUMENT_SUBMISSION_FLRA_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'ULP_DOCUMENT_DESCRIPTION')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_DISPOSITION_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'ULP_DISPOSITION_TYPE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_COMPLAINT_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_AGENCY_ANSWER_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_AGENCY_ANSWER_FILED_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_SETTLEMENT_DISCUSSION_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_PREHEARING_DISCLOSURE_DUE')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_PREHEARING_DISCLOSUE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_PREHEARING_CONFERENCE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_HEARING_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_DECISION_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'ULP_EXCEPTION_FILED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'ULP_EXCEPTION_FILED_DT')
        );
    END IF;
    
	--------------------------------
	-- ERLR_LABOR_NEGO table
	--------------------------------
	DELETE ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = V_CASE_NUMBER;
    IF V_CASE_TYPE = 748 THEN
        INSERT INTO ERLR_LABOR_NEGO(
            ERLR_CASE_NUMBER
            , LN_NEGOTIATION_TYPE
            , LN_INITIATOR
            , LN_DEMAND2BARGAIN_DT
            , LN_BRIEFING_REQUEST
            , LN_BRIEFING_DT
            , LN_PROPOSAL_SUBMISSION_DT
            , LN_PROPOSAL_SUBMISSION
            , LN_PROPOSAL_NEGOTIABLE
            , LN_NON_NEGOTIABLE_LETTER
            , LN_FILE_ULP
            , LN_PROPOSAL_INFO_GROUND_RULES
            , LN_PRPSAL_INFO_NEG_COMMENCE_DT
            , LN_LETTER_PROVIDED
            , LN_LETTER_PROVIDED_DT
            , LN_NEGOTIABLE_PROPOSAL
            , LN_BARGAINING_BEGAN_DT
            , LN_IMPASSE_DT
            , LN_FSIP_DECISION_DT
            , LN_BARGAINING_END_DT
            , LN_AGREEMENT_DT
            , LN_SUMMARY_OF_ISSUE
            , LN_SECON_LETTER_REQUEST
            , LN_2ND_LETTER_PROVIDED
            , LN_NEGOTIABL_ISSUE_SUMMARY
            , LN_2ND_PROVIDED_DT
            , LN_MNGMNT_ARTICLE4_NTC_DT
            , LN_MNGMNT_NOTICE_RESPONSE
            , LN_MNGMNT_BRIEFING_REQUEST
            , LN_BRIEFING_REQUESTED2_DT
            , LN_MNGMNT_BARGAIN_SBMSSION_DT
            , LN_MNGMNT_PROPOSAL_SBMSSION
            )VALUES(
            V_CASE_NUMBER
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_NEGOTIATION_TYPE')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_INITIATOR')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_DEMAND2BARGAIN_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_BRIEFING_REQUEST')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_BRIEFING_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_PROPOSAL_SUBMISSION_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_PROPOSAL_SUBMISSION')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_PROPOSAL_NEGOTIABLE')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_NON_NEGOTIABLE_LETTER')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_FILE_ULP')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_PROPOSAL_INFO_GROUND_RULES')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_PROPOSAL_INFO_NEG_COMMENCED_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_LETTER_PROVIDED')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_LETTER_PROVIDED_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_NEGOTIABLE_PROPOSAL')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_BARGAINING_BEGAN_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_IMPASSE_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_FSIP_DECISION_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_BARGAINING_END_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_AGREEMENT_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_SUMMARY_OF_ISSUE')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_SECON_LETTER_REQUEST')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_2ND_LETTER_PROVIDED')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_NEGOTIABL_ISSUE_SUMMARY')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_2ND_PROVIDED_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_MNGMNT_ARTICLE4_NTC_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_MNGMNT_NOTICE_RESPONSE')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_MNGMNT_BRIEFING_REQUEST')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_BRIEFING_REQUESTED2_DT')
            , FN_EXTRACT_DATE(V_XMLDOC, 'LN_MNGMNT_BARGAIN_SUBMISSION_DT')
            , FN_EXTRACT_STR (V_XMLDOC, 'LN_MNGMNT_PROPOSAL_SUBMISSION')
            );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
/
-- END OF SP_UPDATE_ERLR_TABLE

GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ERLR_TABLE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ERLR_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ERLR_TABLE TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_INIT_ERLR
(
	I_PROCID               IN  NUMBER
)
IS
    V_CNT                   INT;    
    V_FROM_PROCID           NUMBER(10);
    V_XMLDOC                XMLTYPE;    
    V_ORG_CASE_NUMBER       NUMBER(10);
    V_CASE_NUMBER           NUMBER(10);    
    V_GEN_EMP_HHSID         VARCHAR2(64);
    V_NEW_CASE_TYPE_ID	    NUMBER(38);
    V_NEW_CASE_TYPE_NAME    VARCHAR2(100);
BEGIN
    SELECT COUNT(1) INTO V_CNT
      FROM TBL_FORM_DTL
     WHERE PROCID = I_PROCID;

    IF V_CNT = 0 THEN
        V_CASE_NUMBER :=  ERLR_CASE_NUMBER_SEQ.NEXTVAL;
        UPDATE BIZFLOW.RLVNTDATA 
           SET VALUE = V_CASE_NUMBER
         WHERE RLVNTDATANAME = 'caseNumber' 
           AND PROCID = I_PROCID;

        -- CHECK: TRIGGERED FROM OTHER CASE
        BEGIN
            SELECT TO_NUMBER(VALUE)
              INTO V_FROM_PROCID
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'fromProcID' 
               AND PROCID = I_PROCID;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            V_FROM_PROCID := NULL;
        END;

        IF V_FROM_PROCID IS NOT NULL THEN
            SELECT FIELD_DATA
              INTO V_XMLDOC
              FROM TBL_FORM_DTL
             WHERE PROCID = V_FROM_PROCID;

            SELECT TO_NUMBER(VALUE)
              INTO V_NEW_CASE_TYPE_ID
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'caseTypeID' 
               AND PROCID = I_PROCID;

            SELECT TO_NUMBER(VALUE)
              INTO V_ORG_CASE_NUMBER
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'caseNumber' 
               AND PROCID = V_FROM_PROCID;

            BEGIN
              SELECT TBL_LABEL
                INTO V_NEW_CASE_TYPE_NAME
                FROM TBL_LOOKUP
               WHERE TBL_ID = V_NEW_CASE_TYPE_ID;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              V_NEW_CASE_TYPE_NAME := TO_CHAR(V_NEW_CASE_TYPE_ID);
              WHEN OTHERS THEN
              V_NEW_CASE_TYPE_NAME := TO_CHAR(V_NEW_CASE_TYPE_ID);
            END;

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='employeeName' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='employeeName';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='contactName' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='contactName';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='initialContactDate' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='initialContactDate';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='organization' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='organization';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='primaryDWCSpecialist' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='primaryDWCSpecialist';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='secondaryDWCSpecialist' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='secondaryDWCSpecialist';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = V_NEW_CASE_TYPE_NAME
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='caseType';

            SELECT XMLQUERY('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()' PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_GEN_EMP_HHSID FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item/id[not(contains(text(),"GEN_"))]/..') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_CATEGORY_SEL"]') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_DESC"]') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_STATUS"]') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CUST_INIT_CONTACT_DT"]') INTO V_XMLDOC FROM DUAL;

            IF V_NEW_CASE_TYPE_ID IS NOT NULL AND V_NEW_CASE_TYPE_NAME IS NOT NULL THEN
                SELECT UPDATEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_TYPE"]/value/text()', V_NEW_CASE_TYPE_ID) INTO V_XMLDOC FROM DUAL;
                SELECT UPDATEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_TYPE"]/text/text()',  V_NEW_CASE_TYPE_NAME) INTO V_XMLDOC FROM DUAL;                
            END IF;
        END IF;        

        IF V_XMLDOC IS NULL THEN
            V_XMLDOC := XMLTYPE('<formData xmlns=""><items><item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item></items><history><item /></history></formData>');
        ELSE
            INSERT INTO ERLR_CASE(ERLR_CASE_NUMBER, PROCID) VALUES(V_CASE_NUMBER, I_PROCID);
            SP_ERLR_ADD_RELATED_CASE(V_CASE_NUMBER, V_ORG_CASE_NUMBER, 'T', NULL);            
            SELECT APPENDCHILDXML(V_XMLDOC, '/formData/items', XMLTYPE('<item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item>')) INTO V_XMLDOC FROM DUAL;
            IF V_GEN_EMP_HHSID IS NOT NULL AND 1<LENGTH(V_GEN_EMP_HHSID) THEN
                SELECT APPENDCHILDXML(V_XMLDOC, '/formData/items', XMLTYPE('<item><id>_disableDeleteEmployeeInfo</id><etype>variable</etype><value>Yes</value></item>')) INTO V_XMLDOC FROM DUAL;
            END IF;
        END IF;

        INSERT INTO TBL_FORM_DTL (PROCID, ACTSEQ, WITEMSEQ, FORM_TYPE, FIELD_DATA, CRT_DT, CRT_USR)
                          VALUES (I_PROCID, 0, 0, 'CMSERLR', V_XMLDOC, SYSDATE, 'System');
        
        SP_UPDATE_ERLR_TABLE(I_PROCID);
    END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_INIT_ERLR TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_INIT_ERLR TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_INIT_ERLR TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_PV_ERLR
  (
      I_PROCID         IN      NUMBER
    , I_FIELD_DATA     IN      XMLTYPE
  )
IS
  V_REQUEST_NUMBER       VARCHAR2(20);
  ERLR_GEN_REC           ERLR_GEN%ROWTYPE;
BEGIN
    SELECT *
      INTO ERLR_GEN_REC
      FROM ERLR_GEN
    WHERE PROCID = I_PROCID;

    UPDATE BIZFLOW.RLVNTDATA 
       SET VALUE = ERLR_GEN_REC.GEN_CASE_CATEGORY_NAME
     WHERE RLVNTDATANAME = 'caseCategory'
       AND PROCID = I_PROCID;
  
    UPDATE BIZFLOW.RLVNTDATA 
       SET VALUE = ERLR_GEN_REC.GEN_CASE_STATUS
     WHERE RLVNTDATANAME = 'caseStatus'
       AND PROCID = I_PROCID;
    
    UPDATE BIZFLOW.RLVNTDATA 
       SET VALUE = ERLR_GEN_REC.GEN_CASE_TYPE_NAME
     WHERE RLVNTDATANAME = 'caseType'
       AND PROCID = I_PROCID;
  
    IF ERLR_GEN_REC.GEN_CASE_TYPE_NAME IS NOT NULL THEN
      --- set requestNum ------
      SELECT VALUE INTO V_REQUEST_NUMBER 
        FROM BIZFLOW.RLVNTDATA 
       WHERE RLVNTDATANAME = 'requestNum' 
         AND PROCID = I_PROCID;
      IF V_REQUEST_NUMBER IS NULL THEN
          GET_REQUEST_NUM (V_REQUEST_NUMBER);
          UPDATE BIZFLOW.RLVNTDATA 
             SET VALUE = V_REQUEST_NUMBER
           WHERE RLVNTDATANAME = 'requestNum' 
             AND PROCID = I_PROCID;
      END IF;        
    END IF;
  
    UPDATE BIZFLOW.RLVNTDATA 
       SET VALUE = ERLR_GEN_REC.GEN_CUSTOMER_NAME
     WHERE RLVNTDATANAME = 'contactName'
       AND PROCID = I_PROCID;
  
    UPDATE BIZFLOW.RLVNTDATA 
       SET VALUE = ERLR_GEN_REC.GEN_EMPLOYEE_NAME
     WHERE RLVNTDATANAME = 'employeeName'
       AND PROCID = I_PROCID;
  
    UPDATE BIZFLOW.RLVNTDATA 
       SET VALUE = TO_CHAR(SYS_EXTRACT_UTC(CAST(ERLR_GEN_REC.GEN_CUST_INIT_CONTACT_DT AS TIMESTAMP)), 'YYYY/MM/DD HH24:MI:SS')
     WHERE RLVNTDATANAME = 'initialContactDate'
       AND PROCID = I_PROCID;
  
    UPDATE BIZFLOW.RLVNTDATA
       SET VALUE = TO_CHAR((sys_extract_utc(systimestamp)), 'YYYY/MM/DD HH24:MI:SS')
     WHERE RLVNTDATANAME = 'lastModifiedDate'
       AND PROCID = I_PROCID;
  
    UPDATE BIZFLOW.RLVNTDATA 
       SET VALUE = ERLR_GEN_REC.GEN_EMPLOYEE_NAME
     WHERE RLVNTDATANAME = 'employeeName'
       AND PROCID = I_PROCID;
  
    UPDATE BIZFLOW.RLVNTDATA 
       SET VALUE = ERLR_GEN_REC.GEN_EMPLOYEE_ADMIN_CD
     WHERE RLVNTDATANAME = 'organization'
       AND PROCID = I_PROCID;
  
    UPDATE BIZFLOW.RLVNTDATA 
       SET VALUE = CASE WHEN ERLR_GEN_REC.GEN_PRIMARY_SPECIALIST IS NOT NULL THEN '[U]'||ERLR_GEN_REC.GEN_PRIMARY_SPECIALIST ELSE NULL END
     WHERE RLVNTDATANAME = 'primaryDWCSpecialist'
       AND PROCID = I_PROCID;
  
    UPDATE BIZFLOW.RLVNTDATA 
       SET VALUE = CASE WHEN ERLR_GEN_REC.GEN_SECONDARY_SPECIALIST IS NOT NULL THEN '[U]'||ERLR_GEN_REC.GEN_SECONDARY_SPECIALIST ELSE NULL END
     WHERE RLVNTDATANAME = 'secondaryDWCSpecialist'
       AND PROCID = I_PROCID;
     
    IF I_FIELD_DATA IS NOT NULL THEN
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'reassign',               '/formData/items/item[id=''reassign'']/value/text()');      
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestStatusDate',      '/formData/items/item[id=''REQ_STATUS_DT'']/value/text()');
    END IF;
END;
/

GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ERLR TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ERLR TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ERLR TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_ERLR_FORM_DATA 
   (I_WIH_ACTION IN VARCHAR2, -- SAVE, SUBMIT
    I_FIELD_DATA IN CLOB, 
    I_USER       IN VARCHAR2, 
    I_PROCID     IN NUMBER, 
    I_ACTSEQ     IN NUMBER, 
    I_WITEMSEQ   IN NUMBER) 
IS 
  V_XMLDOC               XMLTYPE;
  V_FORM_TYPE            VARCHAR2(20) := 'CMSERLR';
  V_XMLVALUE             XMLTYPE;
  V_CNT                  INT;
  V_PRIMARY_SPECIALIST   VARCHAR2(20);
  CREATE_CASE_ACTIVITY CONSTANT VARCHAR2(50) := 'Create Case';
  COMPLATE_CASE_ACTIVITY CONSTANT VARCHAR2(50) := 'Complete Case';
  DWC_SUPERVISOR         CONSTANT VARCHAR2(50) := 'DWC Supervisor';
BEGIN 
    -- sanity check: ignore and exit if form data xml is null or empty 
    IF I_FIELD_DATA IS NULL OR LENGTH(I_FIELD_DATA) <= 0 OR I_PROCID IS NULL OR I_USER IS NULL OR I_ACTSEQ IS NULL THEN 
      RETURN; 
    END IF;
    
    -- TODO: I_USER should be member of work item checked out
    --
    
    V_XMLDOC := XMLTYPE(I_FIELD_DATA); 

    MERGE INTO TBL_FORM_DTL A
    USING (SELECT * FROM TBL_FORM_DTL WHERE PROCID=I_PROCID) B
       ON (A.PROCID = B.PROCID)
     WHEN MATCHED THEN
          UPDATE 
             SET A.FIELD_DATA = V_XMLDOC, 
                 A.MOD_DT = SYS_EXTRACT_UTC(SYSTIMESTAMP), 
                 A.MOD_USR = I_USER 
     WHEN NOT MATCHED THEN     
          INSERT (A.PROCID, A.ACTSEQ, A.WITEMSEQ, A.FORM_TYPE, A.FIELD_DATA, A.CRT_DT, A.CRT_USR) 
          VALUES (I_PROCID, NVL(I_ACTSEQ, 0), NVL(I_WITEMSEQ, 0), V_FORM_TYPE, V_XMLDOC, SYS_EXTRACT_UTC(SYSTIMESTAMP), I_USER); 

    IF UPPER(I_WIH_ACTION) = 'SAVE' THEN
        -- Set Primary Specialist to Workitem owner at Create Case Activity
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id=''GEN_PRIMARY_SPECIALIST'']/value/text()');
        IF V_XMLVALUE IS NOT NULL THEN
            V_PRIMARY_SPECIALIST := V_XMLVALUE.GETSTRINGVAL();
            V_PRIMARY_SPECIALIST := SUBSTR(V_PRIMARY_SPECIALIST, 4);
            
            UPDATE BIZFLOW.WITEM W
               SET (PRTCPTYPE, PRTCP, PRTCPNAME) = (SELECT TYPE, MEMBERID, NAME FROM BIZFLOW.MEMBER WHERE MEMBERID = V_PRIMARY_SPECIALIST)
             WHERE W.PROCID = I_PROCID
               AND W.ACTSEQ = I_ACTSEQ
               AND W.WITEMSEQ = I_WITEMSEQ
               AND W.PRTCP <> V_PRIMARY_SPECIALIST
               AND EXISTS (SELECT 1 
                             FROM BIZFLOW.ACT
                            WHERE NAME = CREATE_CASE_ACTIVITY 
                              AND PROCID = W.PROCID 
                              AND ACTSEQ = W.ACTSEQ);
        END IF;    
    END IF;

    -- Update process variable and transition xml into individual tables 
    -- for respective process definition 
    SP_UPDATE_ERLR_TABLE(I_PROCID); 
    SP_UPDATE_PV_ERLR(I_PROCID, V_XMLDOC); 

EXCEPTION 
  WHEN OTHERS THEN 
             SP_ERROR_LOG(); 

END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ERLR_FORM_DATA TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ERLR_FORM_DATA TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ERLR_FORM_DATA TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_PV_STRATCON
  (
      I_PROCID            IN      NUMBER
    , I_FIELD_DATA      IN      XMLTYPE
  )
IS
  V_RLVNTDATANAME        VARCHAR2(100);
  V_VALUE                NVARCHAR2(2000);
  V_VALUE_LOOKUP         NVARCHAR2(2000);
  V_CURRENTDATE          DATE;
  V_CURRENTDATESTR       NVARCHAR2(30);
  V_VALUE_DATE           DATE;
  V_VALUE_DATESTR        NVARCHAR2(30);
  V_REC_CNT              NUMBER(10);
  V_XMLDOC               XMLTYPE;
  V_XMLVALUE             XMLTYPE;
  V_VALUE1               NVARCHAR2(2000);
  V_VALUE2               NVARCHAR2(2000);
  V_VALUE3               NVARCHAR2(2000);  
  lcntr                  NUMBER(2);
  
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
    --DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
    --DBMS_OUTPUT.PUT_LINE(' ----------------');
    --V_XMLDOC := XMLTYPE(I_FIELD_DATA);
    V_XMLDOC := I_FIELD_DATA;


    IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
      --DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'adminCode', '/DOCUMENT/GENERAL/SG_ADMIN_CD/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cancelReason', '/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()', null);      
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingAckResponse', '/DOCUMENT/PROCESS_VARIABLE/meetingAckResponse/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingApvResponse', '/DOCUMENT/PROCESS_VARIABLE/meetingApvResponse/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingEmailRecipients', '/DOCUMENT/PROCESS_VARIABLE/meetingEmailRecipients/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingRequired', '/DOCUMENT/PROCESS_VARIABLE/meetingRequired/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingResched',  '/DOCUMENT/PROCESS_VARIABLE/meetingResched/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdClassSpec', '/DOCUMENT/GENERAL/SG_CS_ID/text()', null);      
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdSelectOff', '/DOCUMENT/GENERAL/SG_SO_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdStaffSpec', '/DOCUMENT/GENERAL/SG_SS_ID_PV/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'posLocation', '/DOCUMENT/POSITION/POS_LOCATION/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'posTitle', '/DOCUMENT/POSITION/POS_TITLE/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestNum', '/DOCUMENT/PROCESS_VARIABLE/requestNum/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'selectOfficialReviewReq', '/DOCUMENT/PROCESS_VARIABLE/selectOfficialReviewReq/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'specialProgram', '/DOCUMENT/PROCESS_VARIABLE/specialProgram/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'alertMessage', '/DOCUMENT/PROCESS_VARIABLE/alertMessage/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingReschedReason', '/DOCUMENT/PROCESS_VARIABLE/meetingReschedReason/text()', null);

      V_RLVNTDATANAME := 'appointmentType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_AT_ID/text()');

      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'candidateName';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_CNDT_FIRST_NM/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_CNDT_LAST_NM/text()');
      IF V_VALUE IS NOT NULL AND V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_VALUE || ' ' || V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'classSpecialist';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_CS_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'classificationType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_CT_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'lastActivityCompDate';
      BEGIN
        SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
        EXCEPTION
        WHEN OTHERS THEN V_VALUE := NULL;
      END;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'meetingDate';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/MEETING/SSH_MEETING_SCHED_DT/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- date format and GMT conversion
        -------------------------------------
        V_VALUE := TO_CHAR(SYS_EXTRACT_UTC(TO_DATE(V_VALUE, 'YYYY-MM-DD')), 'YYYY/MM/DD HH24:MI:SS');
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'meetingDateCutOff';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/MEETING/SSH_MEETING_SCHED_DT/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- date format and GMT conversion
        -------------------------------------
        --V_VALUE := TO_CHAR(SYS_EXTRACT_UTC(TO_DATE(V_VALUE || ' 23:59:00', 'YYYY-MM-DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS');
        -- For current date, make the cutoff date past so that wait activity is completed immediately.
        -- For future date, subtract one day and make the time before midnight, i.e. 23:59.
        V_VALUE := TO_CHAR((SYS_EXTRACT_UTC(TO_DATE(V_VALUE || ' 23:59:00', 'YYYY-MM-DD HH24:MI:SS')) - 1), 'YYYY/MM/DD HH24:MI:SS');
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'meetingDateString';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/MEETING/SSH_MEETING_SCHED_DT/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- date format for display
        -------------------------------------
        V_VALUE := TO_CHAR(TO_DATE(V_VALUE, 'YYYY-MM-DD'), 'MM/DD/YYYY');
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'meetingRecorders';
      --V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/meetingRecorders/text()');
      ---------------------------
      -- TODO: currently mapped to only classSpecialist, but it should be able to handle multiple participants
      ---------------------------
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_CS_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
    
      --V_RLVNTDATANAME := 'memIdExecOff';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_XO_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdExecOff';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'execOfficer';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;
        V_RLVNTDATANAME := 'execOfficer2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;
        V_RLVNTDATANAME := 'execOfficer3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL
        WHERE RLVNTDATANAME IN ('memIdExecOff', 'memIdExecOff2', 'memIdExecOff3', 'execOfficer', 'execOfficer2', 'execOfficer3') AND PROCID = I_PROCID;

      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);

    V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_HRL_ID/text()');
    IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdHrLiaison';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdHrLiaison2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdHrLiaison3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL
        WHERE RLVNTDATANAME IN ('memIdHrLiaison', 'memIdHrLiaison2', 'memIdHrLiaison3', 'hrLiaison', 'hrLiaison2', 'hrLiaison3') AND PROCID = I_PROCID;

      END IF;
       
    V_RLVNTDATANAME := 'posNumber';
    V_VALUE := NULL;
    FOR lcntr IN 1 .. 5
    LOOP
        V_VALUE1 := '/DOCUMENT/POSITION/POS_DESC_NUMBER_' || lcntr || '/text()';
        V_XMLVALUE := I_FIELD_DATA.EXTRACT(V_VALUE1);
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE2 := V_XMLVALUE.GETSTRINGVAL();
            IF V_VALUE IS NULL THEN
                V_VALUE := V_VALUE2;
            ELSE    
                V_VALUE := V_VALUE || '; ' || V_VALUE2;
            END IF;
        END IF;
    END LOOP;
    IF V_VALUE IS NULL THEN
        V_VALUE := 'N/A';
    END IF;
    UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
    
      V_RLVNTDATANAME := 'posIs';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SUPERVISORY/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posPayPlan';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_PAY_PLAN_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          --WHERE TBL_ID = TO_NUMBER(V_VALUE);
          WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = V_VALUE;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posSensitivity';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SEC_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posSeries';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SERIES/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          --WHERE TBL_ID = TO_NUMBER(V_VALUE);
          WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = V_VALUE;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posSupervisor';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SUPERVISORY/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'requestStatus';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatus/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'requestStatusDate';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatusDate/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- even though it is date, do not format or perform GMT conversion
        -------------------------------------
        V_VALUE := V_VALUE;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'requestType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_RT_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'returnToSOFromClassSpec';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSOFromClassSpec/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- This pv can be updated from multiple workitem
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'returnToSOFromStaffSpec';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSOFromStaffSpec/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- This pv can be updated from multiple workitem
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'secondSubOrg';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_ADMIN_CD/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with admin code desc lookup value
        ---------------------------------
        BEGIN
          SELECT AC_ADMIN_CD_DESCR INTO V_VALUE_LOOKUP
          FROM ADMIN_CODES
          WHERE AC_ADMIN_CD = SUBSTR(V_VALUE, 1, 3);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'selectOfficial';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_SO_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'smeEmailAddresses';
      V_VALUE := NULL;
      -- check and append SME_EMAIL_JA
      IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_JOB_ANALYSIS/text()') = 1
         AND I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_JOB_ANALYSIS/text()').GETSTRINGVAL() = 'true'
         AND I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_JA/text()') = 1
      THEN
        V_VALUE := V_VALUE || I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_JA/text()').GETSTRINGVAL() || ';';
      END IF;
      -- check and append SME_EMAIL_QUAL 1 and/or 2
      IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_QUALIFICATION/text()') = 1
         AND I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_QUALIFICATION/text()').GETSTRINGVAL() = 'true'
      THEN
        IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_1/text()') = 1
        THEN
          V_VALUE := V_VALUE || I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_1/text()').GETSTRINGVAL() || ';';
        END IF;
        IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_2/text()') = 1
        THEN
          V_VALUE := V_VALUE || I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_2/text()').GETSTRINGVAL() || ';';
        END IF;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'staffSpecialist';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_SS_ID_PV/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        --V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
        -- If the Job Request is for Special Program, SG_SS_ID_PV may point to User Group,
        -- rather than individual user.  Therefore, lookup
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        BEGIN
          SELECT TYPE INTO V_VALUE_LOOKUP FROM BIZFLOW.MEMBER WHERE MEMBERID = V_VALUE;
          EXCEPTION
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;

        IF V_VALUE_LOOKUP IS NOT NULL THEN
          V_VALUE := '[' || V_VALUE_LOOKUP || ']' || V_XMLVALUE.GETSTRINGVAL();
        ELSE
          V_VALUE := NULL;
        END IF;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'worksheetFeedbackClassSpec';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/worksheetFeedbackClassSpec/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- This pv can be updated from multiple workitem
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'worksheetFeedbackSelectOfficial';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/worksheetFeedbackSelectOfficial/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'worksheetFeedbackStaffSpec';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/worksheetFeedbackStaffSpec/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- This pv can be updated from multiple workitem
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      --DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_STRATCON -------------------');
  END;
/
-- End of SP_UPDATE_PV_STRATCON
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_STRATCON TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_STRATCON TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_STRATCON TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_PV_CLSF
  (
      I_PROCID            IN      NUMBER
    , I_FIELD_DATA      IN      XMLTYPE
  )
IS
  V_RLVNTDATANAME VARCHAR2(100);
  V_VALUE NVARCHAR2(2000);
  V_VALUE_LOOKUP NVARCHAR2(2000);
  V_REC_CNT NUMBER(10);
  V_XMLDOC XMLTYPE;
  V_XMLVALUE XMLTYPE;
  V_VALUE1               NVARCHAR2(2000);
  V_VALUE2               NVARCHAR2(2000);
  V_VALUE3               NVARCHAR2(2000);
  lcntr                  NUMBER(2);

  BEGIN
    --DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
    --DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
    --DBMS_OUTPUT.PUT_LINE(' ----------------');
    --V_XMLDOC := XMLTYPE(I_FIELD_DATA);
    V_XMLDOC := I_FIELD_DATA;


    IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
      --DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'adminCode', '/DOCUMENT/GENERAL/CS_ADMIN_CD/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cancelReason', '/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'coversheetApprovedBySO', '/DOCUMENT/PROCESS_VARIABLE/coversheetApprovedBySO/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'finalPackageApprovedSO', '/DOCUMENT/PROCESS_VARIABLE/finalPackageApprovedSO/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'modifyCoversheetFeedback', '/DOCUMENT/PROCESS_VARIABLE/modifyCoversheetFeedback/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'modifyFinalPackageFeedback', '/DOCUMENT/PROCESS_VARIABLE/modifyFinalPackageFeedback/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'returnToSO', '/DOCUMENT/PROCESS_VARIABLE/returnToSO/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'posLocation', '/DOCUMENT/GENERAL/PD_EMPLOYING_OFFICE/text()', null);

      V_RLVNTDATANAME := 'classSpecialist';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      --V_RLVNTDATANAME := 'execOfficer';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdExecOff';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'execOfficer';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;

        V_RLVNTDATANAME := 'execOfficer2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;

        V_RLVNTDATANAME := 'execOfficer3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL
        WHERE RLVNTDATANAME in ('memIdExecOff', 'memIdExecOff2', 'memIdExecOff3', 'execOfficer', 'execOfficer2', 'execOfficer3')
              AND PROCID = I_PROCID;

      END IF;

    V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/HRL_ID/text()');
    IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdHrLiaison';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdHrLiaison2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdHrLiaison3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL
        WHERE RLVNTDATANAME IN ('memIdHrLiaison', 'memIdHrLiaison2', 'memIdHrLiaison3', 'hrLiaison', 'hrLiaison2', 'hrLiaison3') AND PROCID = I_PROCID;

      END IF;

      V_RLVNTDATANAME := 'selectOfficial';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SO_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      

      V_RLVNTDATANAME := 'lastActivityCompDate';
      BEGIN
        SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
        EXCEPTION
        WHEN OTHERS THEN V_VALUE := NULL;
      END;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      --posGrade

    V_RLVNTDATANAME := 'posNumber';
    V_VALUE := NULL;
    FOR lcntr IN 1 .. 5
    LOOP
        V_VALUE1 := '/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_' || lcntr || '/text()';
        V_XMLVALUE := I_FIELD_DATA.EXTRACT(V_VALUE1);
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE2 := V_XMLVALUE.GETSTRINGVAL();
            IF V_VALUE IS NULL THEN
                V_VALUE := V_VALUE2;
            ELSE    
                V_VALUE := V_VALUE || '; ' || V_VALUE2;
            END IF;
        END IF;
    END LOOP;
    IF V_VALUE IS NULL THEN
        V_VALUE := 'N/A';
    END IF;
    UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'posIs';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_SUPERVISORY/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      -------------------
      --TODO: maybe we need this
      V_RLVNTDATANAME := 'posPayPlan';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/CS_PAY_PLAN_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          --WHERE TBL_ID = TO_NUMBER(V_VALUE);
          WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = V_VALUE;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      --posNumber
      V_RLVNTDATANAME := 'posSensitivity';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/CLASSIFICATION_CODE/CS_SEC_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'posSeries';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_SR_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          --WHERE TBL_ID = TO_NUMBER(V_VALUE);
          WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = V_VALUE;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posTitle';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_TITLE/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := REPLACE(V_XMLVALUE.GETSTRINGVAL(), 'null;', '&');
        V_VALUE := REPLACE(V_VALUE, 'null;', '<');
        V_VALUE := REPLACE(V_VALUE, 'null;', '>');
        V_VALUE := REPLACE(V_VALUE, 'null;', '"');
      ELSE
        V_VALUE := NULL;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'requestStatus';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatus/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;

      V_RLVNTDATANAME := 'requestStatusDate';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatusDate/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- even though it is date, do not format or perform GMT conversion
        -------------------------------------
        V_VALUE := V_VALUE;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'staffSpecialist';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SS_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        --V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
        -- If the Job Request is for Special Program, SS_ID may point to User Group,
        -- rather than individual user.  Therefore, lookup
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        BEGIN
          SELECT TYPE INTO V_VALUE_LOOKUP FROM BIZFLOW.MEMBER WHERE MEMBERID = V_VALUE;
          EXCEPTION
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;

        IF V_VALUE_LOOKUP IS NOT NULL THEN
          V_VALUE := '[' || V_VALUE_LOOKUP || ']' || V_XMLVALUE.GETSTRINGVAL();
        ELSE
          V_VALUE := NULL;
        END IF;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      --DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

      COMMIT;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_CLSF -------------------');
  END;
/
-- End of SP_UPDATE_PV_CLSF
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_CLSF TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_CLSF TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_CLSF TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_PV_ELIGQUAL
  (
      I_PROCID            IN      NUMBER
    , I_FIELD_DATA      IN      XMLTYPE
  )
IS
  V_RLVNTDATANAME        VARCHAR2(100);
  V_VALUE                NVARCHAR2(2000);
  V_VALUE_LOOKUP         NVARCHAR2(2000);
  V_CURRENTDATE          DATE;
  V_CURRENTDATESTR       NVARCHAR2(30);
  V_VALUE_DATE           DATE;
  V_VALUE_DATESTR        NVARCHAR2(30);
  V_REC_CNT              NUMBER(10);
  V_XMLDOC               XMLTYPE;
  V_XMLVALUE             XMLTYPE;
  V_VALUE1               NVARCHAR2(2000);
  V_VALUE2               NVARCHAR2(2000);
  V_VALUE3               NVARCHAR2(2000);
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('==== SP_UPDATE_PV_ELIGQUAL ==============================');
    --DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
    --DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
    --DBMS_OUTPUT.PUT_LINE(' ----------------');
    --V_XMLDOC := XMLTYPE(I_FIELD_DATA);
    V_XMLDOC := I_FIELD_DATA;


    IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
      --DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'adminCode', '/DOCUMENT/GENERAL/ADMIN_CD/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cancelReason', '/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'feedbackDCO', '/DOCUMENT/PROCESS_VARIABLE/feedbackDCO/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'feedbackStaffSpec', '/DOCUMENT/PROCESS_VARIABLE/feedbackStaffSpec/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdClassSpec', '/DOCUMENT/GENERAL/CS_ID/text()', null);      
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdSelectOff', '/DOCUMENT/GENERAL/SO_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdStaffSpec', '/DOCUMENT/GENERAL/SS_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'posLocation', '/DOCUMENT/POSITION/LOCATION/text()', null);

      V_RLVNTDATANAME := 'appointmentType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/AT_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'candidateApproved';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/candidateApproved/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'candidateName';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/CNDT_FIRST_NM/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/CNDT_LAST_NM/text()');
      IF V_VALUE IS NOT NULL AND V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_VALUE || ' ' || V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'classSpecialist';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'classificationType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CT_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'disqualReason';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/REVIEW/DISQUAL_REASON/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'eligQualCandidate';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/eligQualCandidate/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;

      V_RLVNTDATANAME := 'ineligReason';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/REVIEW/INELIG_REASON/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'lastActivityCompDate';
      BEGIN
        SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
        EXCEPTION
        WHEN OTHERS THEN V_VALUE := NULL;
      END;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      --V_RLVNTDATANAME := 'memIdExecOff';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdExecOff';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'execOfficer';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;
        V_RLVNTDATANAME := 'execOfficer2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;
        V_RLVNTDATANAME := 'execOfficer3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL
        WHERE RLVNTDATANAME in ('memIdExecOff','memIdExecOff2','memIdExecOff3', 'execOfficer','execOfficer2','execOfficer3')
              AND PROCID = I_PROCID;

      END IF;

    V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/HRL_ID/text()');
    IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdHrLiaison';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdHrLiaison2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdHrLiaison3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL
        WHERE RLVNTDATANAME IN ('memIdHrLiaison', 'memIdHrLiaison2', 'memIdHrLiaison3', 'hrLiaison', 'hrLiaison2', 'hrLiaison3') AND PROCID = I_PROCID;

      END IF;


      V_RLVNTDATANAME := 'posIs';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/SUPERVISORY/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posSensitivity';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/SEC_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posSeries';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/SERIES/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          --WHERE TBL_ID = TO_NUMBER(V_VALUE);
          WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = V_VALUE;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posTitle';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_TITLE/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := REPLACE(V_XMLVALUE.GETSTRINGVAL(), '&amp;', '&');
        V_VALUE := REPLACE(V_VALUE, '&lt;', '<');
        V_VALUE := REPLACE(V_VALUE, '&gt;', '>');
        V_VALUE := REPLACE(V_VALUE, '&quot;', '"');
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'requestStatus';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatus/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'requestStatusDate';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatusDate/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- even though it is date, do not format or perform GMT conversion
        -------------------------------------
        V_VALUE := V_VALUE;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'requestType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/RT_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          FROM TBL_LOOKUP
          WHERE TBL_ID = TO_NUMBER(V_VALUE);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'returnToSO';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSO/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- This pv can be updated from multiple workitem
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'secondSubOrg';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/ADMIN_CD/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with admin code desc lookup value
        ---------------------------------
        BEGIN
          SELECT AC_ADMIN_CD_DESCR INTO V_VALUE_LOOKUP
          FROM ADMIN_CODES
          WHERE AC_ADMIN_CD = SUBSTR(V_VALUE, 1, 3);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_VALUE_LOOKUP := NULL;
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;
        V_VALUE := V_VALUE_LOOKUP;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'selectOfficial';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SO_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'staffSpecialist';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SS_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        --V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
        -- If the Job Request is for Special Program, SS_ID may point to User Group,
        -- rather than individual user.  Therefore, lookup
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        BEGIN
          SELECT TYPE INTO V_VALUE_LOOKUP FROM BIZFLOW.MEMBER WHERE MEMBERID = V_VALUE;
          EXCEPTION
          WHEN OTHERS THEN
          V_VALUE_LOOKUP := NULL;
        END;

        IF V_VALUE_LOOKUP IS NOT NULL THEN
          V_VALUE := '[' || V_VALUE_LOOKUP || ']' || V_XMLVALUE.GETSTRINGVAL();
        ELSE
          V_VALUE := NULL;
        END IF;
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      --DBMS_OUTPUT.PUT_LINE('End PV update SP_UPDATE_PV_ELIGQUAL -------------------');

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_ELIGQUAL -------------------');
  END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ELIGQUAL TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ELIGQUAL TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_ELIGQUAL TO HHS_CMS_HR_DEV_ROLE;
/

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
/ 
-- End of SP_UPDATE_STRATCON_TABLE
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_STRATCON_TABLE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_STRATCON_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_STRATCON_TABLE TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_CLSF_TABLE
  (
    I_PROCID            IN      NUMBER
  )
IS
  V_JOB_REQ_ID                NUMBER(20);
  V_JOB_REQ_NUM               NVARCHAR2(50);
  V_PD_ID                     NUMBER(20);
  V_CLOBVALUE                 CLOB;
  V_VALUE                     NVARCHAR2(4000);
  V_VALUE_LOOKUP              NVARCHAR2(2000);
  V_REC_CNT                   NUMBER(10);
  V_XMLDOC                    XMLTYPE;
  V_XMLVALUE                  XMLTYPE;
  --V_ISMODIFIED                NUMBER(1);
  V_ERRCODE                   NUMBER(10);
  V_ERRMSG                    VARCHAR2(512);
    E_INVALID_PROCID            EXCEPTION;
    E_INVALID_JOB_REQ_ID        EXCEPTION;
PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
    E_INVALID_STRATCON_DATA     EXCEPTION;
PRAGMA EXCEPTION_INIT(E_INVALID_STRATCON_DATA, -20905);
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_CLSF_TABLE - BEGIN ============================');
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
      -- 2. If Job Request Number not found, issue error.
      -- 3. For each target table,
      -- 3.1. If record found for the REQ_ID, update record.
      -- 3.2. If record not found for the REQ_ID, insert record.
      ------------------------------------------------------
      --DBMS_OUTPUT.PUT_LINE('Starting xml data retrieval and table update ----------');

      --------------------------------
      -- get Job Request Number
      --------------------------------
      BEGIN
        SELECT VALUE
        INTO V_JOB_REQ_NUM
        FROM BIZFLOW.RLVNTDATA
        WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'requestNum';
        EXCEPTION
        WHEN NO_DATA_FOUND THEN V_JOB_REQ_NUM := NULL;
      END;

      --DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM);
      IF V_JOB_REQ_NUM IS NULL THEN
        RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_CLSF_TABLE: Job Request Number is invalid.  I_PROCID = '
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

      --DBMS_OUTPUT.PUT_LINE('        V_JOB_REQ_ID = ' || V_JOB_REQ_ID);

      -- Unlike STRATCON, REQUEST record must be available by the time CLSF starts
      IF V_JOB_REQ_ID IS NULL THEN
        RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_CLSF_TABLE: Job Request ID is invalid.  I_PROCID = '
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
        -- CLASSIF_STRATCON table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    CLASSIF_STRATCON table');
        MERGE INTO CLASSIF_STRATCON TRG
        USING
          (
            SELECT
                V_JOB_REQ_ID AS CS_REQ_ID
              , XG.CS_TITLE
              , (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = XG.CS_PAY_PLAN_ID AND ROWNUM = 1) AS CS_PAY_PLAN_ID
              , (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = XG.CS_SR_ID AND ROWNUM = 1) AS CS_SR_ID
              , XG.CS_PD_NUMBER_JOBCD_1
              , XG.CS_CLASSIFICATION_DT_1
              --, XG.CS_GR_ID_1
              , CASE WHEN LENGTH(XG.CS_GR_ID_1) = 1 THEN '0' || XG.CS_GR_ID_1 ELSE XG.CS_GR_ID_1 END AS CS_GR_ID_1
              , (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_1 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_1
              , XG.CS_PD_NUMBER_JOBCD_2
              , XG.CS_CLASSIFICATION_DT_2
              --, XG.CS_GR_ID_2
              , CASE WHEN LENGTH(XG.CS_GR_ID_2) = 1 THEN '0' || XG.CS_GR_ID_2 ELSE XG.CS_GR_ID_2 END AS CS_GR_ID_2
              , (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_2 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_2
              , XG.CS_PD_NUMBER_JOBCD_3
              , XG.CS_CLASSIFICATION_DT_3
              --, XG.CS_GR_ID_3
              , CASE WHEN LENGTH(XG.CS_GR_ID_3) = 1 THEN '0' || XG.CS_GR_ID_3 ELSE XG.CS_GR_ID_3 END AS CS_GR_ID_3
              , (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_3 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_3
              , XG.CS_PD_NUMBER_JOBCD_4
              , XG.CS_CLASSIFICATION_DT_4
              --, XG.CS_GR_ID_4
              , CASE WHEN LENGTH(XG.CS_GR_ID_4) = 1 THEN '0' || XG.CS_GR_ID_4 ELSE XG.CS_GR_ID_4 END AS CS_GR_ID_4
              , (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_4 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_4
              , XG.CS_PD_NUMBER_JOBCD_5
              , XG.CS_CLASSIFICATION_DT_5
              --, XG.CS_GR_ID_5
              , CASE WHEN LENGTH(XG.CS_GR_ID_5) = 1 THEN '0' || XG.CS_GR_ID_5 ELSE XG.CS_GR_ID_5 END AS CS_GR_ID_5
              , (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_5 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_5
              --, XG.CS_PERFORMANCE_LEVEL
              , CASE WHEN LENGTH(XG.CS_PERFORMANCE_LEVEL) = 1 THEN '0' || XG.CS_PERFORMANCE_LEVEL ELSE XG.CS_PERFORMANCE_LEVEL END AS CS_PERFORMANCE_LEVEL
              , XG.CS_SUPERVISORY
              , XG.CS_AC_ID
              , XG.CS_ADMIN_CD
              , XG.SO_ID
              , XG.SO_TITLE
              , XG.SO_ORG
              , XG.XO_ID
              , XG.XO_TITLE
              , XG.XO_ORG
              , XG.HRL_ID
              , XG.HRL_TITLE
              , XG.HRL_ORG
              , XG.SS_ID
              , XG.CS_ID
              , XC.CS_FIN_STMT_REQ_ID
              , XC.CS_SEC_ID
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/GENERAL'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         CS_TITLE                            NVARCHAR2(140)  PATH 'CS_TITLE'
              , CS_PAY_PLAN_ID                    NVARCHAR2(140)  PATH 'CS_PAY_PLAN_ID'
              , CS_SR_ID                          NVARCHAR2(140)  PATH 'CS_SR_ID'
              , CS_PD_NUMBER_JOBCD_1              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_1'
              , CS_CLASSIFICATION_DT_1            DATE            PATH 'CS_CLASSIFICATION_DT_1'
                         --, CS_GR_ID_1                        NUMBER(2)       PATH 'CS_GR_ID_1'
              , CS_GR_ID_1                        NVARCHAR2(2)    PATH 'CS_GR_ID_1'
              , CS_FLSA_DETERM_ID_1               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_1'
              , CS_PD_NUMBER_JOBCD_2              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_2'
              , CS_CLASSIFICATION_DT_2            DATE            PATH 'CS_CLASSIFICATION_DT_2'
                         --, CS_GR_ID_2                        NUMBER(2)       PATH 'CS_GR_ID_2'
              , CS_GR_ID_2                        NVARCHAR2(2)    PATH 'CS_GR_ID_2'
              , CS_FLSA_DETERM_ID_2               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_2'
              , CS_PD_NUMBER_JOBCD_3              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_3'
              , CS_CLASSIFICATION_DT_3            DATE            PATH 'CS_CLASSIFICATION_DT_3'
                         --, CS_GR_ID_3                        NUMBER(2)       PATH 'CS_GR_ID_3'
              , CS_GR_ID_3                        NVARCHAR2(2)    PATH 'CS_GR_ID_3'
              , CS_FLSA_DETERM_ID_3               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_3'
              , CS_PD_NUMBER_JOBCD_4              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_4'
              , CS_CLASSIFICATION_DT_4            DATE            PATH 'CS_CLASSIFICATION_DT_4'
                         --, CS_GR_ID_4                        NUMBER(2)       PATH 'CS_GR_ID_4'
              , CS_GR_ID_4                        NVARCHAR2(2)    PATH 'CS_GR_ID_4'
              , CS_FLSA_DETERM_ID_4               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_4'
              , CS_PD_NUMBER_JOBCD_5              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_5'
              , CS_CLASSIFICATION_DT_5            DATE            PATH 'CS_CLASSIFICATION_DT_5'
                         --, CS_GR_ID_5                        NUMBER(2)       PATH 'CS_GR_ID_5'
              , CS_GR_ID_5                        NVARCHAR2(2)    PATH 'CS_GR_ID_5'
              , CS_FLSA_DETERM_ID_5               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_5'
                         --, CS_PERFORMANCE_LEVEL              NUMBER(9)       PATH 'CS_PERFORMANCE_LEVEL'
              , CS_PERFORMANCE_LEVEL              NVARCHAR2(2)    PATH 'CS_PERFORMANCE_LEVEL'
              , CS_SUPERVISORY                    NUMBER(20)      PATH 'CS_SUPERVISORY'
              , CS_AC_ID                          NUMBER(20)      PATH 'CS_AC_ID'
              , CS_ADMIN_CD                       NVARCHAR2(8)    PATH 'CS_ADMIN_CD'
              , SO_ID                             NVARCHAR2(10)   PATH 'SO_ID'
              , SO_TITLE                          NVARCHAR2(50)   PATH 'SO_TITLE'
              , SO_ORG                            NVARCHAR2(50)   PATH 'SO_ORG'
              , XO_ID                             NVARCHAR2(32)   PATH 'XO_ID'
              , XO_TITLE                          NVARCHAR2(200)   PATH 'XO_TITLE'
              , XO_ORG                            NVARCHAR2(200)   PATH 'XO_ORG'
              , HRL_ID                            NVARCHAR2(32)   PATH 'HRL_ID'
              , HRL_TITLE                         NVARCHAR2(200)   PATH 'HRL_TITLE'
              , HRL_ORG                           NVARCHAR2(200)   PATH 'HRL_ORG'
              , SS_ID                             NVARCHAR2(10)   PATH 'SS_ID'
              , CS_ID                             NVARCHAR2(10)   PATH 'CS_ID'
                ) XG
              , XMLTABLE('/DOCUMENT/CLASSIFICATION_CODE'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         CS_FIN_STMT_REQ_ID                  NUMBER(20)      PATH 'CS_FIN_STMT_REQ_ID'
              , CS_SEC_ID                         NUMBER(20)      PATH 'CS_SEC_ID'
                ) XC
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.CS_REQ_ID = TRG.CS_REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.CS_TITLE                    = SRC.CS_TITLE
          , TRG.CS_PAY_PLAN_ID            = SRC.CS_PAY_PLAN_ID
          , TRG.CS_SR_ID                  = SRC.CS_SR_ID
          , TRG.CS_PD_NUMBER_JOBCD_1      = SRC.CS_PD_NUMBER_JOBCD_1
          , TRG.CS_CLASSIFICATION_DT_1    = SRC.CS_CLASSIFICATION_DT_1
          , TRG.CS_GR_ID_1                = SRC.CS_GR_ID_1
          , TRG.CS_FLSA_DETERM_ID_1       = SRC.CS_FLSA_DETERM_ID_1
          , TRG.CS_PD_NUMBER_JOBCD_2      = SRC.CS_PD_NUMBER_JOBCD_2
          , TRG.CS_CLASSIFICATION_DT_2    = SRC.CS_CLASSIFICATION_DT_2
          , TRG.CS_GR_ID_2                = SRC.CS_GR_ID_2
          , TRG.CS_FLSA_DETERM_ID_2       = SRC.CS_FLSA_DETERM_ID_2
          , TRG.CS_PD_NUMBER_JOBCD_3      = SRC.CS_PD_NUMBER_JOBCD_3
          , TRG.CS_CLASSIFICATION_DT_3    = SRC.CS_CLASSIFICATION_DT_3
          , TRG.CS_GR_ID_3                = SRC.CS_GR_ID_3
          , TRG.CS_FLSA_DETERM_ID_3       = SRC.CS_FLSA_DETERM_ID_3
          , TRG.CS_PD_NUMBER_JOBCD_4      = SRC.CS_PD_NUMBER_JOBCD_4
          , TRG.CS_CLASSIFICATION_DT_4    = SRC.CS_CLASSIFICATION_DT_4
          , TRG.CS_GR_ID_4                = SRC.CS_GR_ID_4
          , TRG.CS_FLSA_DETERM_ID_4       = SRC.CS_FLSA_DETERM_ID_4
          , TRG.CS_PD_NUMBER_JOBCD_5      = SRC.CS_PD_NUMBER_JOBCD_5
          , TRG.CS_CLASSIFICATION_DT_5    = SRC.CS_CLASSIFICATION_DT_5
          , TRG.CS_GR_ID_5                = SRC.CS_GR_ID_5
          , TRG.CS_FLSA_DETERM_ID_5       = SRC.CS_FLSA_DETERM_ID_5
          , TRG.CS_PERFORMANCE_LEVEL      = SRC.CS_PERFORMANCE_LEVEL
          , TRG.CS_SUPERVISORY            = SRC.CS_SUPERVISORY
          , TRG.CS_AC_ID                  = SRC.CS_AC_ID
          , TRG.CS_ADMIN_CD               = SRC.CS_ADMIN_CD
          , TRG.SO_ID                     = SRC.SO_ID
          , TRG.SO_TITLE                  = SRC.SO_TITLE
          , TRG.SO_ORG                    = SRC.SO_ORG
          , TRG.XO_ID                     = SRC.XO_ID
          , TRG.XO_TITLE                  = SRC.XO_TITLE
          , TRG.XO_ORG                    = SRC.XO_ORG
          , TRG.HRL_ID                    = SRC.HRL_ID
          , TRG.HRL_TITLE                 = SRC.HRL_TITLE
          , TRG.HRL_ORG                   = SRC.HRL_ORG
          , TRG.SS_ID                     = SRC.SS_ID
          , TRG.CS_ID                     = SRC.CS_ID
          , TRG.CS_FIN_STMT_REQ_ID        = SRC.CS_FIN_STMT_REQ_ID
          , TRG.CS_SEC_ID                 = SRC.CS_SEC_ID
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.CS_REQ_ID
            , TRG.CS_TITLE
            , TRG.CS_PAY_PLAN_ID
            , TRG.CS_SR_ID
            , TRG.CS_PD_NUMBER_JOBCD_1
            , TRG.CS_CLASSIFICATION_DT_1
            , TRG.CS_GR_ID_1
            , TRG.CS_FLSA_DETERM_ID_1
            , TRG.CS_PD_NUMBER_JOBCD_2
            , TRG.CS_CLASSIFICATION_DT_2
            , TRG.CS_GR_ID_2
            , TRG.CS_FLSA_DETERM_ID_2
            , TRG.CS_PD_NUMBER_JOBCD_3
            , TRG.CS_CLASSIFICATION_DT_3
            , TRG.CS_GR_ID_3
            , TRG.CS_FLSA_DETERM_ID_3
            , TRG.CS_PD_NUMBER_JOBCD_4
            , TRG.CS_CLASSIFICATION_DT_4
            , TRG.CS_GR_ID_4
            , TRG.CS_FLSA_DETERM_ID_4
            , TRG.CS_PD_NUMBER_JOBCD_5
            , TRG.CS_CLASSIFICATION_DT_5
            , TRG.CS_GR_ID_5
            , TRG.CS_FLSA_DETERM_ID_5
            , TRG.CS_PERFORMANCE_LEVEL
            , TRG.CS_SUPERVISORY
            , TRG.CS_AC_ID
            , TRG.CS_ADMIN_CD
            , TRG.SO_ID
            , TRG.SO_TITLE
            , TRG.SO_ORG
            , TRG.XO_ID
            , TRG.XO_TITLE
            , TRG.XO_ORG
            , TRG.HRL_ID
            , TRG.HRL_TITLE
            , TRG.HRL_ORG
            , TRG.SS_ID
            , TRG.CS_ID
            , TRG.CS_FIN_STMT_REQ_ID
            , TRG.CS_SEC_ID
          )
        VALUES
        (
          SRC.CS_REQ_ID
          , SRC.CS_TITLE
          , SRC.CS_PAY_PLAN_ID
          , SRC.CS_SR_ID
          , SRC.CS_PD_NUMBER_JOBCD_1
          , SRC.CS_CLASSIFICATION_DT_1
          , SRC.CS_GR_ID_1
          , SRC.CS_FLSA_DETERM_ID_1
          , SRC.CS_PD_NUMBER_JOBCD_2
          , SRC.CS_CLASSIFICATION_DT_2
          , SRC.CS_GR_ID_2
          , SRC.CS_FLSA_DETERM_ID_2
          , SRC.CS_PD_NUMBER_JOBCD_3
          , SRC.CS_CLASSIFICATION_DT_3
          , SRC.CS_GR_ID_3
          , SRC.CS_FLSA_DETERM_ID_3
          , SRC.CS_PD_NUMBER_JOBCD_4
          , SRC.CS_CLASSIFICATION_DT_4
          , SRC.CS_GR_ID_4
          , SRC.CS_FLSA_DETERM_ID_4
          , SRC.CS_PD_NUMBER_JOBCD_5
          , SRC.CS_CLASSIFICATION_DT_5
          , SRC.CS_GR_ID_5
          , SRC.CS_FLSA_DETERM_ID_5
          , SRC.CS_PERFORMANCE_LEVEL
          , SRC.CS_SUPERVISORY
          , SRC.CS_AC_ID
          , SRC.CS_ADMIN_CD
          , SRC.SO_ID
          , SRC.SO_TITLE
          , SRC.SO_ORG
          , SRC.XO_ID
          , SRC.XO_TITLE
          , SRC.XO_ORG
          , SRC.HRL_ID
          , SRC.HRL_TITLE
          , SRC.HRL_ORG
          , SRC.SS_ID
          , SRC.CS_ID
          , SRC.CS_FIN_STMT_REQ_ID
          , SRC.CS_SEC_ID
        )
        ;


        --------------------------------
        -- PD_COVERSHEET table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    PD_COVERSHEET table');
        MERGE INTO PD_COVERSHEET TRG
        USING
          (
            SELECT
                V_JOB_REQ_ID AS PD_REQ_ID
              , I_PROCID AS PD_PROCID
              , XG.PD_ORG_POS_TITLE
              , XG.PD_EMPLOYING_OFFICE
              , XG.PD_SUBJECT_IA
              , XG.PD_ORGANIZATION
              , XG.PD_SUB_ORG_1
              , XG.PD_SUB_ORG_2
              , XG.PD_SUB_ORG_3
              , XG.PD_SUB_ORG_4
              , XG.PD_SUB_ORG_5
              , XG.PD_SCOPE
              , XG.STD_PD_TYPE
              , XG.PD_PCA
              , XG.PD_PDP
              , XG.PD_FTT
              , XG.PD_OUTSTATION
              , XG.PD_INCUMBENCY
              , XG.PD_REMARKS
              , XC.PD_CLS_STANDARDS
              , XC.PD_ACQ_CODE
              , XC.PD_CYB_SEC_CD
              , XC.PD_COMPET_LVL_CD
              , XC.PD_BUS_CD
              , XC.BYPASS_DWC_FL
              , XA.PD_SUPV_CERT
              , XA.PD_SUPV_NAME
              , XA.PD_SUPV_TITLE
              , XA.PD_SUPV_SIG
              , XA.PD_SUPV_SIG_DT
              , XA.PD_CLS_SPEC_CERT
              , XA.PD_CLS_SPEC_NAME
              , XA.PD_CLS_SPEC_TITLE
              , XA.PD_CLS_SPEC_SIG
              , XA.PD_CLS_SPEC_DT
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/GENERAL'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         PD_ORG_POS_TITLE                    NVARCHAR2(140)  PATH 'PD_ORG_POS_TITLE'
              , PD_EMPLOYING_OFFICE               NUMBER(20)      PATH 'PD_EMPLOYING_OFFICE'
              , PD_SUBJECT_IA                     CHAR(1)         PATH 'PD_SUBJECT_IA'
              , PD_ORGANIZATION                   NVARCHAR2(10)   PATH 'PD_ORGANIZATION'
              , PD_SUB_ORG_1                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_1'
              , PD_SUB_ORG_2                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_2'
              , PD_SUB_ORG_3                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_3'
              , PD_SUB_ORG_4                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_4'
              , PD_SUB_ORG_5                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_5'
              , PD_SCOPE                          NVARCHAR2(10)   PATH 'PD_SCOPE'
              , STD_PD_TYPE                       NVARCHAR2(200)  PATH 'STD_PD_TYPE'
              , PD_PCA                            CHAR(1)         PATH 'if (POS_INFORMATION/PD_PCA/text() = "true") then 1 else 0'
              , PD_PDP                            CHAR(1)         PATH 'if (POS_INFORMATION/PD_PDP/text() = "true") then 1 else 0'
              , PD_FTT                            CHAR(1)         PATH 'if (POS_INFORMATION/PD_FTT/text() = "true") then 1 else 0'
              , PD_OUTSTATION                     CHAR(1)         PATH 'if (POS_INFORMATION/PD_OUTSTATION/text() = "true") then 1 else 0'
              , PD_INCUMBENCY                     CHAR(1)         PATH 'if (POS_INFORMATION/PD_INCUMBENCY/text() = "true") then 1 else 0'
              , PD_REMARKS                        NVARCHAR2(500)  PATH 'PD_REMARKS'
                ) XG
              , XMLTABLE('/DOCUMENT/CLASSIFICATION_CODE'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         PD_CLS_STANDARDS                    NVARCHAR2(100)  PATH 'string-join(PD_CLS_STANDARDS/text(), ",")'
              , PD_ACQ_CODE                       NUMBER(20)      PATH 'PD_ACQ_CODE'
              , PD_CYB_SEC_CD                     NVARCHAR2(100)  PATH 'string-join(PD_CYB_SEC_CD/text(), ",")'
              , PD_COMPET_LVL_CD                  NVARCHAR2(10)   PATH 'PD_COMPET_LVL_CD'
              , PD_BUS_CD                         NUMBER(20)      PATH 'PD_BUS_CD'
              , BYPASS_DWC_FL                     NVARCHAR2(10)   PATH 'BYPASS_DWC_FL'
                ) XC
              , XMLTABLE('/DOCUMENT/APPROVAL'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         PD_SUPV_CERT                        CHAR(1)         PATH 'if (PD_SUPV_CERT/text() = "true") then 1 else 0'
              , PD_SUPV_NAME                      NVARCHAR2(100)  PATH 'PD_SUPV_NAME'
              , PD_SUPV_TITLE                     NVARCHAR2(140)  PATH 'PD_SUPV_TITLE'
              , PD_SUPV_SIG                       NVARCHAR2(10)   PATH 'PD_SUPV_SIG'
              , PD_SUPV_SIG_DT                    DATE            PATH 'PD_SUPV_SIG_DT'
              , PD_CLS_SPEC_CERT                  CHAR(1)         PATH 'if (PD_CLS_SPEC_CERT/text() = "true") then 1 else 0'
              , PD_CLS_SPEC_NAME                  NVARCHAR2(100)  PATH 'PD_CLS_SPEC_NAME'
              , PD_CLS_SPEC_TITLE                 NVARCHAR2(140)  PATH 'PD_CLS_SPEC_TITLE'
              , PD_CLS_SPEC_SIG                   NVARCHAR2(10)   PATH 'PD_CLS_SPEC_SIG'
              , PD_CLS_SPEC_DT                    DATE            PATH 'PD_CLS_SPEC_DT'
                ) XA
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.PD_REQ_ID = TRG.PD_REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.PD_PROCID               = SRC.PD_PROCID
          , TRG.PD_ORG_POS_TITLE      = SRC.PD_ORG_POS_TITLE
          , TRG.PD_EMPLOYING_OFFICE   = SRC.PD_EMPLOYING_OFFICE
          , TRG.PD_SUBJECT_IA    	    = SRC.PD_SUBJECT_IA
          , TRG.PD_ORGANIZATION       = SRC.PD_ORGANIZATION
          , TRG.PD_SUB_ORG_1          = SRC.PD_SUB_ORG_1
          , TRG.PD_SUB_ORG_2          = SRC.PD_SUB_ORG_2
          , TRG.PD_SUB_ORG_3          = SRC.PD_SUB_ORG_3
          , TRG.PD_SUB_ORG_4          = SRC.PD_SUB_ORG_4
          , TRG.PD_SUB_ORG_5          = SRC.PD_SUB_ORG_5
          , TRG.PD_SCOPE              = SRC.PD_SCOPE
          , TRG.STD_PD_TYPE           = SRC.STD_PD_TYPE
          , TRG.PD_PCA                = SRC.PD_PCA
          , TRG.PD_PDP                = SRC.PD_PDP
          , TRG.PD_FTT                = SRC.PD_FTT
          , TRG.PD_OUTSTATION         = SRC.PD_OUTSTATION
          , TRG.PD_INCUMBENCY         = SRC.PD_INCUMBENCY
          , TRG.PD_REMARKS            = SRC.PD_REMARKS
          , TRG.PD_CLS_STANDARDS      = SRC.PD_CLS_STANDARDS
          , TRG.PD_ACQ_CODE           = SRC.PD_ACQ_CODE
          , TRG.PD_CYB_SEC_CD         = SRC.PD_CYB_SEC_CD
          , TRG.PD_COMPET_LVL_CD      = SRC.PD_COMPET_LVL_CD
          , TRG.PD_BUS_CD             = SRC.PD_BUS_CD
          , TRG.BYPASS_DWC_FL         = SRC.BYPASS_DWC_FL
          , TRG.PD_SUPV_CERT          = SRC.PD_SUPV_CERT
          , TRG.PD_SUPV_NAME          = SRC.PD_SUPV_NAME
          , TRG.PD_SUPV_TITLE         = SRC.PD_SUPV_TITLE
          , TRG.PD_SUPV_SIG           = SRC.PD_SUPV_SIG
          , TRG.PD_SUPV_SIG_DT        = SRC.PD_SUPV_SIG_DT
          , TRG.PD_CLS_SPEC_CERT      = SRC.PD_CLS_SPEC_CERT
          , TRG.PD_CLS_SPEC_NAME      = SRC.PD_CLS_SPEC_NAME
          , TRG.PD_CLS_SPEC_TITLE     = SRC.PD_CLS_SPEC_TITLE
          , TRG.PD_CLS_SPEC_SIG       = SRC.PD_CLS_SPEC_SIG
          , TRG.PD_CLS_SPEC_DT        = SRC.PD_CLS_SPEC_DT
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.PD_REQ_ID
            , TRG.PD_PROCID
            , TRG.PD_ORG_POS_TITLE
            , TRG.PD_EMPLOYING_OFFICE
            , TRG.PD_SUBJECT_IA
            , TRG.PD_ORGANIZATION
            , TRG.PD_SUB_ORG_1
            , TRG.PD_SUB_ORG_2
            , TRG.PD_SUB_ORG_3
            , TRG.PD_SUB_ORG_4
            , TRG.PD_SUB_ORG_5
            , TRG.PD_SCOPE
            , TRG.STD_PD_TYPE
            , TRG.PD_PCA
            , TRG.PD_PDP
            , TRG.PD_FTT
            , TRG.PD_OUTSTATION
            , TRG.PD_INCUMBENCY
            , TRG.PD_REMARKS
            , TRG.PD_CLS_STANDARDS
            , TRG.PD_ACQ_CODE
            , TRG.PD_CYB_SEC_CD
            , TRG.PD_COMPET_LVL_CD
            , TRG.PD_BUS_CD
            , TRG.BYPASS_DWC_FL
            , TRG.PD_SUPV_CERT
            , TRG.PD_SUPV_NAME
            , TRG.PD_SUPV_TITLE
            , TRG.PD_SUPV_SIG
            , TRG.PD_SUPV_SIG_DT
            , TRG.PD_CLS_SPEC_CERT
            , TRG.PD_CLS_SPEC_NAME
            , TRG.PD_CLS_SPEC_TITLE
            , TRG.PD_CLS_SPEC_SIG
            , TRG.PD_CLS_SPEC_DT
          )
        VALUES
        (
          SRC.PD_REQ_ID
          , SRC.PD_PROCID
          , SRC.PD_ORG_POS_TITLE
          , SRC.PD_EMPLOYING_OFFICE
          , SRC.PD_SUBJECT_IA
          , SRC.PD_ORGANIZATION
          , SRC.PD_SUB_ORG_1
          , SRC.PD_SUB_ORG_2
          , SRC.PD_SUB_ORG_3
          , SRC.PD_SUB_ORG_4
          , SRC.PD_SUB_ORG_5
          , SRC.PD_SCOPE
          , SRC.STD_PD_TYPE
          , SRC.PD_PCA
          , SRC.PD_PDP
          , SRC.PD_FTT
          , SRC.PD_OUTSTATION
          , SRC.PD_INCUMBENCY
          , SRC.PD_REMARKS
          , SRC.PD_CLS_STANDARDS
          , SRC.PD_ACQ_CODE
          , SRC.PD_CYB_SEC_CD
          , SRC.PD_COMPET_LVL_CD
          , SRC.PD_BUS_CD
          , SRC.BYPASS_DWC_FL
          , SRC.PD_SUPV_CERT
          , SRC.PD_SUPV_NAME
          , SRC.PD_SUPV_TITLE
          , SRC.PD_SUPV_SIG
          , SRC.PD_SUPV_SIG_DT
          , SRC.PD_CLS_SPEC_CERT
          , SRC.PD_CLS_SPEC_NAME
          , SRC.PD_CLS_SPEC_TITLE
          , SRC.PD_CLS_SPEC_SIG
          , SRC.PD_CLS_SPEC_DT
        )
        ;


        --------------------------------
        -- Get V_PD_ID for FLSA table
        --------------------------------
        BEGIN
          SELECT PD_ID INTO V_PD_ID
          FROM PD_COVERSHEET
          WHERE PD_REQ_ID = V_JOB_REQ_ID;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN V_JOB_REQ_ID := NULL;
        END;

        --------------------------------
        -- FLSA table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    FLSA table');
        MERGE INTO FLSA TRG
        USING
          (
            SELECT
              V_PD_ID AS FLSA_PD_ID
              , XE.FLSA_EX_EXEC
              , XE.FLSA_EX_ADMIN
              , XE.FLSA_EX_PROF_LEARNED
              , XE.FLSA_EX_PROF_CREATIVE
              , XE.FLSA_EX_PROF_COMPUTER
              , XE.FLSA_EX_LAW_ENFORC
              , XE.FLSA_EX_FOREIGN
              , XE.FLSA_EX_REMARKS
              , XN.FLSA_NONEX_SALARY
              , XN.FLSA_NONEX_EQUIP_OPER
              , XN.FLSA_NONEX_TECHN
              , XN.FLSA_NONEX_FED_WAGE_SYS
              , XN.FLSA_NONEX_REMARKS
            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT/FLSA_EX'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         FLSA_EX_EXEC                        CHAR(1)         PATH 'if (FLSA_EX_EXEC/text() = "true") then 1 else 0'
              , FLSA_EX_ADMIN                     CHAR(1)         PATH 'if (FLSA_EX_ADMIN/text() = "true") then 1 else 0'
              , FLSA_EX_PROF_LEARNED              CHAR(1)         PATH 'if (FLSA_EX_PROF_LEARNED/text() = "true") then 1 else 0'
              , FLSA_EX_PROF_CREATIVE             CHAR(1)         PATH 'if (FLSA_EX_PROF_CREATIVE/text() = "true") then 1 else 0'
              , FLSA_EX_PROF_COMPUTER             CHAR(1)         PATH 'if (FLSA_EX_PROF_COMPUTER/text() = "true") then 1 else 0'
              , FLSA_EX_LAW_ENFORC                CHAR(1)         PATH 'if (FLSA_EX_LAW_ENFORC/text() = "true") then 1 else 0'
              , FLSA_EX_FOREIGN                   CHAR(1)         PATH 'if (FLSA_EX_FOREIGN/text() = "true") then 1 else 0'
              , FLSA_EX_REMARKS                   NVARCHAR2(140)  PATH 'FLSA_REMARKS'
                ) XE
              , XMLTABLE('/DOCUMENT/FLSA_NONEX'
                         PASSING FD.FIELD_DATA
                         COLUMNS
                         FLSA_NONEX_SALARY                   CHAR(1)         PATH 'if (FLSA_NONEX_SALARY/text() = "true") then 1 else 0'
              , FLSA_NONEX_EQUIP_OPER             CHAR(1)         PATH 'if (FLSA_NONEX_EQUIP_OPER/text() = "true") then 1 else 0'
              , FLSA_NONEX_TECHN                  CHAR(1)         PATH 'if (FLSA_NONEX_TECHN/text() = "true") then 1 else 0'
              , FLSA_NONEX_FED_WAGE_SYS           CHAR(1)         PATH 'if (FLSA_NONEX_FED_WAGE_SYS/text() = "true") then 1 else 0'
              , FLSA_NONEX_REMARKS                NVARCHAR2(140)  PATH 'FLSA_REMARKS'
                ) XN
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.FLSA_PD_ID = TRG.FLSA_PD_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.FLSA_EX_EXEC               = SRC.FLSA_EX_EXEC
          , TRG.FLSA_EX_ADMIN            = SRC.FLSA_EX_ADMIN
          , TRG.FLSA_EX_PROF_LEARNED     = SRC.FLSA_EX_PROF_LEARNED
          , TRG.FLSA_EX_PROF_CREATIVE    = SRC.FLSA_EX_PROF_CREATIVE
          , TRG.FLSA_EX_PROF_COMPUTER    = SRC.FLSA_EX_PROF_COMPUTER
          , TRG.FLSA_EX_LAW_ENFORC       = SRC.FLSA_EX_LAW_ENFORC
          , TRG.FLSA_EX_FOREIGN          = SRC.FLSA_EX_FOREIGN
          , TRG.FLSA_EX_REMARKS          = SRC.FLSA_EX_REMARKS
          , TRG.FLSA_NONEX_SALARY        = SRC.FLSA_NONEX_SALARY
          , TRG.FLSA_NONEX_EQUIP_OPER    = SRC.FLSA_NONEX_EQUIP_OPER
          , TRG.FLSA_NONEX_TECHN         = SRC.FLSA_NONEX_TECHN
          , TRG.FLSA_NONEX_FED_WAGE_SYS  = SRC.FLSA_NONEX_FED_WAGE_SYS
          , TRG.FLSA_NONEX_REMARKS       = SRC.FLSA_NONEX_REMARKS
        WHEN NOT MATCHED THEN INSERT
          (
            TRG.FLSA_PD_ID
            , TRG.FLSA_EX_EXEC
            , TRG.FLSA_EX_ADMIN
            , TRG.FLSA_EX_PROF_LEARNED
            , TRG.FLSA_EX_PROF_CREATIVE
            , TRG.FLSA_EX_PROF_COMPUTER
            , TRG.FLSA_EX_LAW_ENFORC
            , TRG.FLSA_EX_FOREIGN
            , TRG.FLSA_EX_REMARKS
            , TRG.FLSA_NONEX_SALARY
            , TRG.FLSA_NONEX_EQUIP_OPER
            , TRG.FLSA_NONEX_TECHN
            , TRG.FLSA_NONEX_FED_WAGE_SYS
            , TRG.FLSA_NONEX_REMARKS
          )
        VALUES
        (
          SRC.FLSA_PD_ID
          , SRC.FLSA_EX_EXEC
          , SRC.FLSA_EX_ADMIN
          , SRC.FLSA_EX_PROF_LEARNED
          , SRC.FLSA_EX_PROF_CREATIVE
          , SRC.FLSA_EX_PROF_COMPUTER
          , SRC.FLSA_EX_LAW_ENFORC
          , SRC.FLSA_EX_FOREIGN
          , SRC.FLSA_EX_REMARKS
          , SRC.FLSA_NONEX_SALARY
          , SRC.FLSA_NONEX_EQUIP_OPER
          , SRC.FLSA_NONEX_TECHN
          , SRC.FLSA_NONEX_FED_WAGE_SYS
          , SRC.FLSA_NONEX_REMARKS
        )
        ;

        EXCEPTION
        WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20905, 'SP_UPDATE_CLSF_TABLE: Invalid Classification data.  I_PROCID = '
                                        || TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
      END;
      --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_CLSF_TABLE - END ==========================');

    END IF;

    EXCEPTION
    WHEN E_INVALID_PROCID THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
    WHEN E_INVALID_JOB_REQ_ID THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
    WHEN E_INVALID_STRATCON_DATA THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    V_ERRCODE := SQLCODE;
    V_ERRMSG := SQLERRM;
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
    --DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
  END;
/
-- End of SP_UPDATE_CLSF_TABLE
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_CLSF_TABLE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_CLSF_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_CLSF_TABLE TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_ELIGQUAL_TABLE
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
  V_XMLDOC                    XMLTYPE;
  V_XMLVALUE                  XMLTYPE;
  V_ERRCODE                   NUMBER(10);
  V_ERRMSG                    VARCHAR2(512);
    E_INVALID_PROCID            EXCEPTION;
    E_INVALID_JOB_REQ_ID        EXCEPTION;
PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
    E_INVALID_STRATCON_DATA     EXCEPTION;
PRAGMA EXCEPTION_INIT(E_INVALID_STRATCON_DATA, -20905);
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_ELIGQUAL_TABLE - BEGIN ============================');
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
      -- 2. If Job Request Number not found, issue error.
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
          RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request Number is invalid.  I_PROCID = '
                                          || TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
        END;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (after pv check) = ' || V_JOB_REQ_NUM);
      IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
        RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request Number is invalid.  I_PROCID = '
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

      --DBMS_OUTPUT.PUT_LINE('        V_JOB_REQ_ID = ' || V_JOB_REQ_ID);

      -- Unlike STRATCON, REQUEST record must be available by the time ELIGQUAL starts
      IF V_JOB_REQ_ID IS NULL THEN
        RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request ID is invalid.  I_PROCID = '
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
        -- ELIG_QUAL table
        --------------------------------
        --DBMS_OUTPUT.PUT_LINE('    ELIG_QUAL table');
        MERGE INTO ELIG_QUAL TRG
        USING
          (
            SELECT
                V_JOB_REQ_ID AS REQ_ID
              , I_PROCID AS PROCID

              , X.ADMIN_CD
              , X.RT_ID
              , X.AT_ID
              , X.VT_ID
              , X.SAT_ID
              , X.CT_ID
              , X.SO_ID
              , X.SO_TITLE
              , X.SO_ORG
              , X.XO_ID
              , X.XO_TITLE
              , X.XO_ORG
              , X.HRL_ID
              , X.HRL_TITLE
              , X.HRL_ORG
              , X.SS_ID
              , X.CS_ID
              , X.SO_AGREE
              , X.OTHER_CERT

              , X.CNDT_LAST_NM
              , X.CNDT_FIRST_NM
              , X.CNDT_MIDDLE_NM
              , X.BGT_APR_OFM
              , X.SPNSR_ORG_NM
              , X.SPNSR_ORG_FUND_PC
              , X.POS_TITLE
              , (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = X.PAY_PLAN_ID AND ROWNUM = 1) AS PAY_PLAN_ID
              , (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = X.SERIES AND ROWNUM = 1) AS SERIES
              , X.POS_DESC_NUMBER_1
              , X.CLASSIFICATION_DT_1
              , CASE WHEN LENGTH(X.GRADE_1) = 1 THEN '0' || X.GRADE_1 ELSE X.GRADE_1 END AS GRADE_1
              , X.POS_DESC_NUMBER_2
              , X.CLASSIFICATION_DT_2
              , CASE WHEN LENGTH(X.GRADE_2) = 1 THEN '0' || X.GRADE_2 ELSE X.GRADE_2 END AS GRADE_2
              , X.POS_DESC_NUMBER_3
              , X.CLASSIFICATION_DT_3
              , CASE WHEN LENGTH(X.GRADE_3) = 1 THEN '0' || X.GRADE_3 ELSE X.GRADE_3 END AS GRADE_3
              , X.POS_DESC_NUMBER_4
              , X.CLASSIFICATION_DT_4
              , CASE WHEN LENGTH(X.GRADE_4) = 1 THEN '0' || X.GRADE_4 ELSE X.GRADE_4 END AS GRADE_4
              , X.POS_DESC_NUMBER_5
              , X.CLASSIFICATION_DT_5
              , CASE WHEN LENGTH(X.GRADE_5) = 1 THEN '0' || X.GRADE_5 ELSE X.GRADE_5 END AS GRADE_5
              , X.MED_OFFICERS_ID
              , CASE WHEN LENGTH(X.PERFORMANCE_LEVEL) = 1 THEN '0' || X.PERFORMANCE_LEVEL ELSE X.PERFORMANCE_LEVEL END AS PERFORMANCE_LEVEL
              , X.SUPERVISORY
              , X.SKILL
              , X.LOCATION
              , X.VACANCIES
              , X.REPORT_SUPERVISOR
              , X.CAN
              , X.VICE
              , X.VICE_NAME
              , X.DAYS_ADVERTISED
              , X.TA_ID
              , X.NTE
              , X.WORK_SCHED_ID
              , X.HOURS_PER_WEEK
              , X.DUAL_EMPLMT
              , X.SEC_ID
              , X.CE_FINANCIAL_DISC
              , X.CE_FINANCIAL_TYPE_ID
              , X.CE_PE_PHYSICAL
              , X.CE_DRUG_TEST
              , X.CE_IMMUN
              , X.CE_TRAVEL
              , X.CE_TRAVEL_PER
              , X.CE_LIC
              , X.CE_LIC_INFO
              , X.REMARKS
              , X.PROC_REQ_TYPE
              , X.RECRUIT_OFFICE_ID
              , X.REQ_CREATE_NOTIFY_DT
              , X.ASSOC_DESCR_NUMBERS
              , X.PROMOTE_POTENTIAL
              , X.VICE_EMPL_ID
              , X.SR_ID
              , X.GR_ID
              , X.GA_1
              , X.GA_2
              , X.GA_3
              , X.GA_4
              , X.GA_5
              , X.GA_6
              , X.GA_7
              , X.GA_8
              , X.GA_9
              , X.GA_10
              , X.GA_11
              , X.GA_12
              , X.GA_13
              , X.GA_14
              , X.GA_15

              , X.CNDT_ELIGIBLE
              , X.INELIG_REASON
              , X.CNDT_QUALIFIED
              , X.DISQUAL_REASON

              , X.SEL_DETERM

              , X.DCO_CERT
              , X.DCO_NAME
              , X.DCO_SIG
              , X.DCO_SIG_DT

            FROM TBL_FORM_DTL FD
              , XMLTABLE('/DOCUMENT'
                         PASSING FD.FIELD_DATA
                         COLUMNS

                         ADMIN_CD                        NVARCHAR2(8)    PATH 'GENERAL/ADMIN_CD'
              , RT_ID                         NUMBER(20)      PATH 'GENERAL/RT_ID'
              , AT_ID                         NUMBER(20)      PATH 'GENERAL/AT_ID'
              , VT_ID                         NUMBER(20)      PATH 'GENERAL/VT_ID'
              , SAT_ID                        NUMBER(20)      PATH 'GENERAL/SAT_ID'
              , CT_ID                         NUMBER(20)      PATH 'GENERAL/CT_ID'
              , SO_ID                         NVARCHAR2(10)   PATH 'GENERAL/SO_ID'
              , SO_TITLE                      NVARCHAR2(50)   PATH 'GENERAL/SO_TITLE'
              , SO_ORG                        NVARCHAR2(50)   PATH 'GENERAL/SO_ORG'
              , XO_ID                         NVARCHAR2(32)   PATH 'GENERAL/XO_ID'
              , XO_TITLE                      NVARCHAR2(200)   PATH 'GENERAL/XO_TITLE'
              , XO_ORG                        NVARCHAR2(200)   PATH 'GENERAL/XO_ORG'
              , HRL_ID                        NVARCHAR2(32)   PATH 'GENERAL/HRL_ID'
              , HRL_TITLE                     NVARCHAR2(200)   PATH 'GENERAL/HRL_TITLE'
              , HRL_ORG                       NVARCHAR2(200)   PATH 'GENERAL/HRL_ORG'
              , SS_ID                         NVARCHAR2(10)   PATH 'GENERAL/SS_ID'
              , CS_ID                         NVARCHAR2(10)   PATH 'GENERAL/CS_ID'
              , SO_AGREE                      CHAR(1)         PATH 'if (GENERAL/SO_AGREE/text() = "true") then 1 else 0'
              , OTHER_CERT                    NVARCHAR2(200)  PATH 'GENERAL/OTHER_CERT'

              , CNDT_LAST_NM                  NVARCHAR2(50)   PATH 'POSITION/CNDT_LAST_NM'
              , CNDT_FIRST_NM                 NVARCHAR2(50)   PATH 'POSITION/CNDT_FIRST_NM'
              , CNDT_MIDDLE_NM                NVARCHAR2(50)   PATH 'POSITION/CNDT_MIDDLE_NM'
              , BGT_APR_OFM                   CHAR(1)         PATH 'POSITION/BGT_APR_OFM'
              , SPNSR_ORG_NM                  NVARCHAR2(140)  PATH 'POSITION/SPNSR_ORG_NM'
              , SPNSR_ORG_FUND_PC             NUMBER(3,0)     PATH 'POSITION/SPNSR_ORG_FUND_PC'
              , POS_TITLE                     NVARCHAR2(140)  PATH 'POSITION/POS_TITLE'
              , PAY_PLAN_ID                   VARCHAR2(140)   PATH 'POSITION/PAY_PLAN_ID'
              , SERIES                        VARCHAR2(140)   PATH 'POSITION/SERIES'
              , POS_DESC_NUMBER_1             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_1'
              , CLASSIFICATION_DT_1           DATE            PATH 'POSITION/CLASSIFICATION_DT_1'
              , GRADE_1                       VARCHAR2(2)     PATH 'POSITION/GRADE_1'
              , POS_DESC_NUMBER_2             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_2'
              , CLASSIFICATION_DT_2           DATE            PATH 'POSITION/CLASSIFICATION_DT_2'
              , GRADE_2                       VARCHAR2(2)     PATH 'POSITION/GRADE_2'
              , POS_DESC_NUMBER_3             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_3'
              , CLASSIFICATION_DT_3           DATE            PATH 'POSITION/CLASSIFICATION_DT_3'
              , GRADE_3                       VARCHAR2(2)     PATH 'POSITION/GRADE_3'
              , POS_DESC_NUMBER_4             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_4'
              , CLASSIFICATION_DT_4           DATE            PATH 'POSITION/CLASSIFICATION_DT_4'
              , GRADE_4                       VARCHAR2(2)     PATH 'POSITION/GRADE_4'
              , POS_DESC_NUMBER_5             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_5'
              , CLASSIFICATION_DT_5           DATE            PATH 'POSITION/CLASSIFICATION_DT_5'
              , GRADE_5                       VARCHAR2(2)     PATH 'POSITION/GRADE_5'
              , MED_OFFICERS_ID               NUMBER(20)      PATH 'POSITION/MED_OFFICERS_ID'
              , PERFORMANCE_LEVEL             NVARCHAR2(2)    PATH 'POSITION/PERFORMANCE_LEVEL'
              , SUPERVISORY                   NUMBER(20)      PATH 'POSITION/SUPERVISORY'
              , SKILL                         NVARCHAR2(200)  PATH 'POSITION/SKILL'
              , LOCATION                      NVARCHAR2(2000) PATH 'POSITION/LOCATION'
              , VACANCIES                     NUMBER(9)       PATH 'POSITION/VACANCIES'
              , REPORT_SUPERVISOR             NVARCHAR2(10)   PATH 'POSITION/REPORT_SUPERVISOR'
              , CAN                           NVARCHAR2(8)    PATH 'POSITION/CAN'
              , VICE                          CHAR(1)         PATH 'POSITION/VICE'
              , VICE_NAME                     NVARCHAR2(50)   PATH 'POSITION/VICE_NAME'
              , DAYS_ADVERTISED               NVARCHAR2(50)   PATH 'POSITION/DAYS_ADVERTISED'
              , TA_ID                         NUMBER(20)      PATH 'POSITION/TA_ID'
              , NTE                           NVARCHAR2(140)  PATH 'POSITION/NTE'
              , WORK_SCHED_ID                 NUMBER(20)      PATH 'POSITION/WORK_SCHED_ID'
              , HOURS_PER_WEEK                NVARCHAR2(50)   PATH 'POSITION/HOURS_PER_WEEK'
              , DUAL_EMPLMT                   NVARCHAR2(10)   PATH 'POSITION/DUAL_EMPLMT'
              , SEC_ID                        NUMBER(20)      PATH 'POSITION/SEC_ID'
              , CE_FINANCIAL_DISC             CHAR(1)         PATH 'if (POSITION/CE_FINANCIAL_DISC/text() = "true") then 1 else 0'
              , CE_FINANCIAL_TYPE_ID          NUMBER(20)      PATH 'POSITION/CE_FINANCIAL_TYPE_ID'
              , CE_PE_PHYSICAL                CHAR(1)         PATH 'if (POSITION/CE_PE_PHYSICAL/text() = "true") then 1 else 0'
              , CE_DRUG_TEST                  CHAR(1)         PATH 'if (POSITION/CE_DRUG_TEST/text() = "true") then 1 else 0'
              , CE_IMMUN                      CHAR(1)         PATH 'if (POSITION/CE_IMMUN/text() = "true") then 1 else 0'
              , CE_TRAVEL                     CHAR(1)         PATH 'if (POSITION/CE_TRAVEL/text() = "true") then 1 else 0'
              , CE_TRAVEL_PER                 NVARCHAR2(3)    PATH 'POSITION/CE_TRAVEL_PER'
              , CE_LIC                        CHAR(1)         PATH 'if (POSITION/CE_LIC/text() = "true") then 1 else 0'
              , CE_LIC_INFO                   NVARCHAR2(140)  PATH 'POSITION/CE_LIC_INFO'
              , REMARKS                       NVARCHAR2(500)  PATH 'POSITION/REMARKS'
              , PROC_REQ_TYPE                 NUMBER(20)      PATH 'POSITION/PROC_REQ_TYPE'
              , RECRUIT_OFFICE_ID             NUMBER(20)      PATH 'POSITION/RECRUIT_OFFICE_ID'
              , REQ_CREATE_NOTIFY_DT          DATE            PATH 'POSITION/REQ_CREATE_NOTIFY_DT'
              , ASSOC_DESCR_NUMBERS           NVARCHAR2(100)  PATH 'POSITION/ASSOC_DESCR_NUMBERS'
              , PROMOTE_POTENTIAL             NUMBER(2)       PATH 'POSITION/PROMOTE_POTENTIAL'
              , VICE_EMPL_ID                  NVARCHAR2(25)   PATH 'POSITION/VICE_EMPL_ID'
              , SR_ID                         NUMBER(20)      PATH 'POSITION/SR_ID'
              , GR_ID                         NUMBER(20)      PATH 'POSITION/GR_ID'
              , GA_1                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_1/text() = "true") then 1 else 0'
              , GA_2                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_2/text() = "true") then 1 else 0'
              , GA_3                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_3/text() = "true") then 1 else 0'
              , GA_4                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_4/text() = "true") then 1 else 0'
              , GA_5                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_5/text() = "true") then 1 else 0'
              , GA_6                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_6/text() = "true") then 1 else 0'
              , GA_7                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_7/text() = "true") then 1 else 0'
              , GA_8                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_8/text() = "true") then 1 else 0'
              , GA_9                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_9/text() = "true") then 1 else 0'
              , GA_10                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_10/text() = "true") then 1 else 0'
              , GA_11                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_11/text() = "true") then 1 else 0'
              , GA_12                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_12/text() = "true") then 1 else 0'
              , GA_13                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_13/text() = "true") then 1 else 0'
              , GA_14                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_14/text() = "true") then 1 else 0'
              , GA_15                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_15/text() = "true") then 1 else 0'

              , CNDT_ELIGIBLE                 NVARCHAR2(10)   PATH 'REVIEW/CNDT_ELIGIBLE'
              , INELIG_REASON                 NUMBER(20,0)    PATH 'REVIEW/INELIG_REASON'
              , CNDT_QUALIFIED                NVARCHAR2(10)   PATH 'REVIEW/CNDT_QUALIFIED'
              , DISQUAL_REASON                NUMBER(20,0)    PATH 'REVIEW/DISQUAL_REASON'

              , SEL_DETERM                    NUMBER(20,0)    PATH 'SELECTION/SEL_DETERM'

              , DCO_CERT                      NVARCHAR2(10)   PATH 'APPROVAL/DCO_CERT'
              , DCO_NAME                      NVARCHAR2(100)  PATH 'APPROVAL/DCO_NAME'
              , DCO_SIG                       NVARCHAR2(100)  PATH 'APPROVAL/DCO_SIG'
              , DCO_SIG_DT                    DATE            PATH 'APPROVAL/DCO_SIG_DT'
                ) X
            WHERE FD.PROCID = I_PROCID
          ) SRC ON (SRC.REQ_ID = TRG.REQ_ID)
        WHEN MATCHED THEN UPDATE SET
          TRG.PROCID       = SRC.PROCID

          , TRG.ADMIN_CD   = SRC.ADMIN_CD
          , TRG.RT_ID      = SRC.RT_ID
          , TRG.CT_ID      = SRC.CT_ID
          , TRG.AT_ID      = SRC.AT_ID
          , TRG.VT_ID      = SRC.VT_ID
          , TRG.SAT_ID     = SRC.SAT_ID
          , TRG.SO_ID      = SRC.SO_ID
          , TRG.SO_TITLE   = SRC.SO_TITLE
          , TRG.SO_ORG     = SRC.SO_ORG
          , TRG.XO_ID      = SRC.XO_ID
          , TRG.XO_TITLE   = SRC.XO_TITLE
          , TRG.XO_ORG     = SRC.XO_ORG
          , TRG.HRL_ID     = SRC.HRL_ID
          , TRG.HRL_TITLE  = SRC.HRL_TITLE
          , TRG.HRL_ORG    = SRC.HRL_ORG
          , TRG.SS_ID      = SRC.SS_ID
          , TRG.CS_ID      = SRC.CS_ID
          , TRG.SO_AGREE   = SRC.SO_AGREE
          , TRG.OTHER_CERT = SRC.OTHER_CERT

          , TRG.CNDT_LAST_NM          = SRC.CNDT_LAST_NM
          , TRG.CNDT_FIRST_NM         = SRC.CNDT_FIRST_NM
          , TRG.CNDT_MIDDLE_NM        = SRC.CNDT_MIDDLE_NM
          , TRG.BGT_APR_OFM           = SRC.BGT_APR_OFM
          , TRG.SPNSR_ORG_NM          = SRC.SPNSR_ORG_NM
          , TRG.SPNSR_ORG_FUND_PC     = SRC.SPNSR_ORG_FUND_PC
          , TRG.POS_TITLE             = SRC.POS_TITLE
          , TRG.PAY_PLAN_ID           = SRC.PAY_PLAN_ID
          , TRG.SERIES                = SRC.SERIES
          , TRG.POS_DESC_NUMBER_1     = SRC.POS_DESC_NUMBER_1
          , TRG.CLASSIFICATION_DT_1   = SRC.CLASSIFICATION_DT_1
          , TRG.GRADE_1               = SRC.GRADE_1
          , TRG.POS_DESC_NUMBER_2     = SRC.POS_DESC_NUMBER_2
          , TRG.CLASSIFICATION_DT_2   = SRC.CLASSIFICATION_DT_2
          , TRG.GRADE_2               = SRC.GRADE_2
          , TRG.POS_DESC_NUMBER_3     = SRC.POS_DESC_NUMBER_3
          , TRG.CLASSIFICATION_DT_3   = SRC.CLASSIFICATION_DT_3
          , TRG.GRADE_3               = SRC.GRADE_3
          , TRG.POS_DESC_NUMBER_4     = SRC.POS_DESC_NUMBER_4
          , TRG.CLASSIFICATION_DT_4   = SRC.CLASSIFICATION_DT_4
          , TRG.GRADE_4               = SRC.GRADE_4
          , TRG.POS_DESC_NUMBER_5     = SRC.POS_DESC_NUMBER_5
          , TRG.CLASSIFICATION_DT_5   = SRC.CLASSIFICATION_DT_5
          , TRG.GRADE_5               = SRC.GRADE_5
          , TRG.MED_OFFICERS_ID       = SRC.MED_OFFICERS_ID
          , TRG.PERFORMANCE_LEVEL     = SRC.PERFORMANCE_LEVEL
          , TRG.SUPERVISORY           = SRC.SUPERVISORY
          , TRG.SKILL                 = SRC.SKILL
          , TRG.LOCATION              = SRC.LOCATION
          , TRG.VACANCIES             = SRC.VACANCIES
          , TRG.REPORT_SUPERVISOR     = SRC.REPORT_SUPERVISOR
          , TRG.CAN                   = SRC.CAN
          , TRG.VICE                  = SRC.VICE
          , TRG.VICE_NAME             = SRC.VICE_NAME
          , TRG.DAYS_ADVERTISED       = SRC.DAYS_ADVERTISED
          , TRG.TA_ID                 = SRC.TA_ID
          , TRG.NTE                   = SRC.NTE
          , TRG.WORK_SCHED_ID         = SRC.WORK_SCHED_ID
          , TRG.HOURS_PER_WEEK        = SRC.HOURS_PER_WEEK
          , TRG.DUAL_EMPLMT           = SRC.DUAL_EMPLMT
          , TRG.SEC_ID                = SRC.SEC_ID
          , TRG.CE_FINANCIAL_DISC     = SRC.CE_FINANCIAL_DISC
          , TRG.CE_FINANCIAL_TYPE_ID  = SRC.CE_FINANCIAL_TYPE_ID
          , TRG.CE_PE_PHYSICAL        = SRC.CE_PE_PHYSICAL
          , TRG.CE_DRUG_TEST          = SRC.CE_DRUG_TEST
          , TRG.CE_IMMUN              = SRC.CE_IMMUN
          , TRG.CE_TRAVEL             = SRC.CE_TRAVEL
          , TRG.CE_TRAVEL_PER         = SRC.CE_TRAVEL_PER
          , TRG.CE_LIC                = SRC.CE_LIC
          , TRG.CE_LIC_INFO           = SRC.CE_LIC_INFO
          , TRG.REMARKS               = SRC.REMARKS
          , TRG.PROC_REQ_TYPE         = SRC.PROC_REQ_TYPE
          , TRG.RECRUIT_OFFICE_ID     = SRC.RECRUIT_OFFICE_ID
          , TRG.REQ_CREATE_NOTIFY_DT  = SRC.REQ_CREATE_NOTIFY_DT
          , TRG.ASSOC_DESCR_NUMBERS   = SRC.ASSOC_DESCR_NUMBERS
          , TRG.PROMOTE_POTENTIAL     = SRC.PROMOTE_POTENTIAL
          , TRG.VICE_EMPL_ID          = SRC.VICE_EMPL_ID
          , TRG.SR_ID                 = SRC.SR_ID
          , TRG.GR_ID                 = SRC.GR_ID
          , TRG.GA_1                  = SRC.GA_1
          , TRG.GA_2                  = SRC.GA_2
          , TRG.GA_3                  = SRC.GA_3
          , TRG.GA_4                  = SRC.GA_4
          , TRG.GA_5                  = SRC.GA_5
          , TRG.GA_6                  = SRC.GA_6
          , TRG.GA_7                  = SRC.GA_7
          , TRG.GA_8                  = SRC.GA_8
          , TRG.GA_9                  = SRC.GA_9
          , TRG.GA_10                 = SRC.GA_10
          , TRG.GA_11                 = SRC.GA_11
          , TRG.GA_12                 = SRC.GA_12
          , TRG.GA_13                 = SRC.GA_13
          , TRG.GA_14                 = SRC.GA_14
          , TRG.GA_15                 = SRC.GA_15

          , TRG.CNDT_ELIGIBLE         = SRC.CNDT_ELIGIBLE
          , TRG.INELIG_REASON         = SRC.INELIG_REASON
          , TRG.CNDT_QUALIFIED        = SRC.CNDT_QUALIFIED
          , TRG.DISQUAL_REASON        = SRC.DISQUAL_REASON

          , TRG.SEL_DETERM            = SRC.SEL_DETERM

          , TRG.DCO_CERT              = SRC.DCO_CERT
          , TRG.DCO_NAME              = SRC.DCO_NAME
          , TRG.DCO_SIG               = SRC.DCO_SIG
          , TRG.DCO_SIG_DT            = SRC.DCO_SIG_DT

        WHEN NOT MATCHED THEN INSERT
          (
            TRG.REQ_ID
            , TRG.PROCID

            , TRG.ADMIN_CD
            , TRG.RT_ID
            , TRG.CT_ID
            , TRG.AT_ID
            , TRG.VT_ID
            , TRG.SAT_ID
            , TRG.SO_ID
            , TRG.SO_TITLE
            , TRG.SO_ORG
            , TRG.XO_ID
            , TRG.XO_TITLE
            , TRG.XO_ORG
            , TRG.HRL_ID
            , TRG.HRL_TITLE
            , TRG.HRL_ORG
            , TRG.SS_ID
            , TRG.CS_ID
            , TRG.SO_AGREE
            , TRG.OTHER_CERT

            , TRG.CNDT_LAST_NM
            , TRG.CNDT_FIRST_NM
            , TRG.CNDT_MIDDLE_NM
            , TRG.BGT_APR_OFM
            , TRG.SPNSR_ORG_NM
            , TRG.SPNSR_ORG_FUND_PC
            , TRG.POS_TITLE
            , TRG.PAY_PLAN_ID
            , TRG.SERIES
            , TRG.POS_DESC_NUMBER_1
            , TRG.CLASSIFICATION_DT_1
            , TRG.GRADE_1
            , TRG.POS_DESC_NUMBER_2
            , TRG.CLASSIFICATION_DT_2
            , TRG.GRADE_2
            , TRG.POS_DESC_NUMBER_3
            , TRG.CLASSIFICATION_DT_3
            , TRG.GRADE_3
            , TRG.POS_DESC_NUMBER_4
            , TRG.CLASSIFICATION_DT_4
            , TRG.GRADE_4
            , TRG.POS_DESC_NUMBER_5
            , TRG.CLASSIFICATION_DT_5
            , TRG.GRADE_5
            , TRG.MED_OFFICERS_ID
            , TRG.PERFORMANCE_LEVEL
            , TRG.SUPERVISORY
            , TRG.SKILL
            , TRG.LOCATION
            , TRG.VACANCIES
            , TRG.REPORT_SUPERVISOR
            , TRG.CAN
            , TRG.VICE
            , TRG.VICE_NAME
            , TRG.DAYS_ADVERTISED
            , TRG.TA_ID
            , TRG.NTE
            , TRG.WORK_SCHED_ID
            , TRG.HOURS_PER_WEEK
            , TRG.DUAL_EMPLMT
            , TRG.SEC_ID
            , TRG.CE_FINANCIAL_DISC
            , TRG.CE_FINANCIAL_TYPE_ID
            , TRG.CE_PE_PHYSICAL
            , TRG.CE_DRUG_TEST
            , TRG.CE_IMMUN
            , TRG.CE_TRAVEL
            , TRG.CE_TRAVEL_PER
            , TRG.CE_LIC
            , TRG.CE_LIC_INFO
            , TRG.REMARKS
            , TRG.PROC_REQ_TYPE
            , TRG.RECRUIT_OFFICE_ID
            , TRG.REQ_CREATE_NOTIFY_DT
            , TRG.ASSOC_DESCR_NUMBERS
            , TRG.PROMOTE_POTENTIAL
            , TRG.VICE_EMPL_ID
            , TRG.SR_ID
            , TRG.GR_ID
            , TRG.GA_1
            , TRG.GA_2
            , TRG.GA_3
            , TRG.GA_4
            , TRG.GA_5
            , TRG.GA_6
            , TRG.GA_7
            , TRG.GA_8
            , TRG.GA_9
            , TRG.GA_10
            , TRG.GA_11
            , TRG.GA_12
            , TRG.GA_13
            , TRG.GA_14
            , TRG.GA_15

            , TRG.CNDT_ELIGIBLE
            , TRG.INELIG_REASON
            , TRG.CNDT_QUALIFIED
            , TRG.DISQUAL_REASON

            , TRG.SEL_DETERM

            , TRG.DCO_CERT
            , TRG.DCO_NAME
            , TRG.DCO_SIG
            , TRG.DCO_SIG_DT
          )
        VALUES
        (
          SRC.REQ_ID
          , SRC.PROCID

          , SRC.ADMIN_CD
          , SRC.RT_ID
          , SRC.CT_ID
          , SRC.AT_ID
          , SRC.VT_ID
          , SRC.SAT_ID
          , SRC.SO_ID
          , SRC.SO_TITLE
          , SRC.SO_ORG
          , SRC.XO_ID
          , SRC.XO_TITLE
          , SRC.XO_ORG
          , SRC.HRL_ID
          , SRC.HRL_TITLE
          , SRC.HRL_ORG
          , SRC.SS_ID
          , SRC.CS_ID
          , SRC.SO_AGREE
          , SRC.OTHER_CERT

          , SRC.CNDT_LAST_NM
          , SRC.CNDT_FIRST_NM
          , SRC.CNDT_MIDDLE_NM
          , SRC.BGT_APR_OFM
          , SRC.SPNSR_ORG_NM
          , SRC.SPNSR_ORG_FUND_PC
          , SRC.POS_TITLE
          , SRC.PAY_PLAN_ID
          , SRC.SERIES
          , SRC.POS_DESC_NUMBER_1
          , SRC.CLASSIFICATION_DT_1
          , SRC.GRADE_1
          , SRC.POS_DESC_NUMBER_2
          , SRC.CLASSIFICATION_DT_2
          , SRC.GRADE_2
          , SRC.POS_DESC_NUMBER_3
          , SRC.CLASSIFICATION_DT_3
          , SRC.GRADE_3
          , SRC.POS_DESC_NUMBER_4
          , SRC.CLASSIFICATION_DT_4
          , SRC.GRADE_4
          , SRC.POS_DESC_NUMBER_5
          , SRC.CLASSIFICATION_DT_5
          , SRC.GRADE_5
          , SRC.MED_OFFICERS_ID
          , SRC.PERFORMANCE_LEVEL
          , SRC.SUPERVISORY
          , SRC.SKILL
          , SRC.LOCATION
          , SRC.VACANCIES
          , SRC.REPORT_SUPERVISOR
          , SRC.CAN
          , SRC.VICE
          , SRC.VICE_NAME
          , SRC.DAYS_ADVERTISED
          , SRC.TA_ID
          , SRC.NTE
          , SRC.WORK_SCHED_ID
          , SRC.HOURS_PER_WEEK
          , SRC.DUAL_EMPLMT
          , SRC.SEC_ID
          , SRC.CE_FINANCIAL_DISC
          , SRC.CE_FINANCIAL_TYPE_ID
          , SRC.CE_PE_PHYSICAL
          , SRC.CE_DRUG_TEST
          , SRC.CE_IMMUN
          , SRC.CE_TRAVEL
          , SRC.CE_TRAVEL_PER
          , SRC.CE_LIC
          , SRC.CE_LIC_INFO
          , SRC.REMARKS
          , SRC.PROC_REQ_TYPE
          , SRC.RECRUIT_OFFICE_ID
          , SRC.REQ_CREATE_NOTIFY_DT
          , SRC.ASSOC_DESCR_NUMBERS
          , SRC.PROMOTE_POTENTIAL
          , SRC.VICE_EMPL_ID
          , SRC.SR_ID
          , SRC.GR_ID
          , SRC.GA_1
          , SRC.GA_2
          , SRC.GA_3
          , SRC.GA_4
          , SRC.GA_5
          , SRC.GA_6
          , SRC.GA_7
          , SRC.GA_8
          , SRC.GA_9
          , SRC.GA_10
          , SRC.GA_11
          , SRC.GA_12
          , SRC.GA_13
          , SRC.GA_14
          , SRC.GA_15

          , SRC.CNDT_ELIGIBLE
          , SRC.INELIG_REASON
          , SRC.CNDT_QUALIFIED
          , SRC.DISQUAL_REASON

          , SRC.SEL_DETERM

          , SRC.DCO_CERT
          , SRC.DCO_NAME
          , SRC.DCO_SIG
          , SRC.DCO_SIG_DT
        )
        ;

        EXCEPTION
        WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20905, 'SP_UPDATE_ELIGQUAL_TABLE: Invalid ELIGQUAL data.  I_PROCID = '
                                        || TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
      END;

      --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_ELIGQUAL_TABLE - END ==========================');

    END IF;

    EXCEPTION
    WHEN E_INVALID_PROCID THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
    WHEN E_INVALID_JOB_REQ_ID THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
    WHEN E_INVALID_STRATCON_DATA THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    V_ERRCODE := SQLCODE;
    V_ERRMSG := SQLERRM;
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
    --DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
    --DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
  END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ELIGQUAL_TABLE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ELIGQUAL_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ELIGQUAL_TABLE TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_FINALIZE_ERLR
(
	I_PROCID               IN  NUMBER
)
IS
    V_CNT                   INT;
    V_XMLDOC                XMLTYPE;
    V_XMLVALUE              XMLTYPE;
    V_CASE_TYPE_ID          VARCHAR2(10);
    V_VALUE                 VARCHAR2(100);
    V_NEW_CASE_TYPE_ID      VARCHAR2(10);
    V_NEW_CASE_TYPE_NAME    VARCHAR2(100);
    V_GEN_EMP_ID            VARCHAR2(64);
    V_CASE_NUMBER           NUMBER(10);
    V_TRIGGER_NEW_CASE      BOOLEAN := FALSE;
    V_CASE_STATUS           VARCHAR2(100);
    YES                     CONSTANT VARCHAR2(3) := 'Yes';
    
    CONDUCT_ISSUE_ID		CONSTANT VARCHAR2(10) :='743';
    CONDUCT_ISSUE			CONSTANT VARCHAR2(50) :='Conduct Issue';
    GRIEVANCE_ID			CONSTANT VARCHAR2(10) :='745';
    GRIEVANCE			    CONSTANT VARCHAR2(50) :='Grievance';
    INVESTIGATION_ID		CONSTANT VARCHAR2(10) :='744';
    INVESTIGATION			CONSTANT VARCHAR2(50) :='Investigation';
    LABOR_NEGOTIATION_ID	CONSTANT VARCHAR2(10) :='748';
    LABOR_NEGOTIATION		CONSTANT VARCHAR2(50) :='Labor Negotiation';
    MEDICAL_DOCUMENTATION_ID CONSTANT VARCHAR2(10) :='746';
    MEDICAL_DOCUMENTATION	CONSTANT VARCHAR2(50) :='Medical Documentation/Exam';
    PERFORMANCE_ISSUE_ID	CONSTANT VARCHAR2(10) :='750';
    PERFORMANCE_ISSUE		CONSTANT VARCHAR2(50) :='Performance Issue';
    PROBATIONARY_PERIOD_ID	CONSTANT VARCHAR2(10) :='751';
    PROBATIONARY_PERIOD		CONSTANT VARCHAR2(50) :='Probationary Period Action';
    UNFAIR_LABOR_PRACTICES_ID	CONSTANT VARCHAR2(10) :='754';
    UNFAIR_LABOR_PRACTICES	CONSTANT VARCHAR2(50) :='Unfair Labor Practices';
    WGI_DENIAL_ID			CONSTANT VARCHAR2(10) :='809';
    WGI_DENIAL			    CONSTANT VARCHAR2(50) :='Within Grade Increase Denial/Reconsideration';    
    INFORMATION_REQUEST_ID  CONSTANT VARCHAR2(10) := '747';    
    THIRD_PARTY_HEARING_ID  CONSTANT VARCHAR2(10) := '753';    
    THIRD_PARTY_HEARING     CONSTANT VARCHAR2(50) := 'Third Party Hearing';
    ACTION_TYPE_COUNSELING_ID CONSTANT VARCHAR2(10) := '785';
    ACTION_TYPE_PIP_ID      CONSTANT VARCHAR2(10) := '787';
    ACTION_TYPE_WNR_ID      CONSTANT VARCHAR2(10) := '790';    
    REASON_FMLA_ID          CONSTANT VARCHAR2(10) := '1650';
    ACTION_TYPE_CLPD        CONSTANT VARCHAR2(10) := '1794';    
BEGIN
    SELECT MAX(VALUE)
      INTO V_CASE_STATUS
      FROM BIZFLOW.RLVNTDATA
     WHERE RLVNTDATANAME = 'caseStatus'
       AND PROCID = I_PROCID;
    
    IF UPPER(V_CASE_STATUS) = 'CLOSED' THEN
        RETURN;
    END IF;

    SELECT FIELD_DATA
      INTO V_XMLDOC
      FROM TBL_FORM_DTL
     WHERE PROCID = I_PROCID;

    V_CASE_TYPE_ID := V_XMLDOC.EXTRACT('/formData/items/item[id="GEN_CASE_TYPE"]/value/text()').getStringVal();        
    V_CASE_NUMBER  := TO_NUMBER(V_XMLDOC.EXTRACT('/formData/items/item[id="CASE_NUMBER"]/value/text()').getStringVal());    
    V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()');
    IF V_XMLVALUE IS NOT NULL THEN
        V_GEN_EMP_ID := V_XMLVALUE.GETSTRINGVAL();
    END IF;
    
    IF V_CASE_TYPE_ID = INFORMATION_REQUEST_ID THEN -- Information Request
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="IR_APPEAL_DENIAL"]/value/text()'); -- Did Requester Appeal Denial?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN
            V_NEW_CASE_TYPE_ID   := THIRD_PARTY_HEARING_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;
    ELSIF V_CASE_TYPE_ID = INVESTIGATION_ID THEN -- Investigation
        -- Triggering Conduct Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="I_MISCONDUCT_FOUND"]/value/text()'); --Was Misconduct Found?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN
            V_NEW_CASE_TYPE_ID   := CONDUCT_ISSUE_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;
    ELSIF V_CASE_TYPE_ID = MEDICAL_DOCUMENTATION_ID THEN -- Medical Documentation/Exam
        -- Triggering Grievance Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="MD_REQUEST_REASON"]/value/text()'); -- Reason for Request
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = REASON_FMLA_ID THEN  -- FMLA      
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="MD_FMLA_GRIEVANCE"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
        END IF;
    ELSIF V_CASE_TYPE_ID = LABOR_NEGOTIATION_ID THEN -- Labor Negotiation
        -- Triggering Unfair Labor Practices Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="LN_FILE_ULP"]/value/text()');--Did Union File ULP?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN        
            V_NEW_CASE_TYPE_ID   := UNFAIR_LABOR_PRACTICES_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;        
    ELSIF V_CASE_TYPE_ID = PERFORMANCE_ISSUE_ID THEN -- Performance Issue
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_ACTION_TYPE"]/value/text()');
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = ACTION_TYPE_COUNSELING_ID THEN -- Action Type: Counseling
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_CNSL_GRV_DECISION"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
        ELSIF V_VALUE = ACTION_TYPE_PIP_ID THEN -- Action Type: PIP
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_PIP_EMPL_GRIEVANCE"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
            
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_PIP_WGI_WTHLD"]/value/text()'); --Was WGI Withheld?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := WGI_DENIAL_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID2' AND PROCID = I_PROCID;
            END IF;
        ELSIF V_VALUE = ACTION_TYPE_WNR_ID THEN -- Action Type: Written Narrative Review
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_WNR_WGI_WTHLD"]/value/text()'); -- Was WGI Withheld?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := WGI_DENIAL_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;        
        ELSIF V_VALUE = ACTION_TYPE_CLPD THEN -- Action Type: Career Ladder Promotion Denial
            -- Triggering Grievance Case
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_CLPD_EMP_GRIEVANCE"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;            
        END IF;
    END IF;
    
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_FINALIZE_ERLR TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_FINALIZE_ERLR TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_FINALIZE_ERLR TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_ERLR_MNG_FINAL_ACTION
( 
    I_ACTION IN VARCHAR2,
    I_CASE_TYPE_ID IN VARCHAR2,
    I_LABEL IN VARCHAR2,
    I_UPDATED_LABEL IN VARCHAR2 DEFAULT ''
)
IS
/* This utility program is for ER/LR final action item deletion */

    V_DEL_LABEL VARCHAR2(100);
    V_XPATH VARCHAR2(200);
    V_XPATH_DEL VARCHAR2(200);
BEGIN
    IF I_ACTION = 'DELETE' THEN
        V_XPATH := '/formData/items/item[id="CC_FINAL_ACTION_SEL"]/value/value[.="'||I_LABEL||'"]/text()';
        V_XPATH_DEL := '/formData/items/item[id="CC_FINAL_ACTION_SEL"]/value/value[.="'||I_LABEL||'"]/..';
        FOR FORM_REC IN (
            SELECT P.PROCID, P.STATE, FIELD_DATA, XMLQUERY(V_XPATH PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as FINAL_ACTION,
                   XMLQUERY('/formData/items/item[id="GEN_CASE_TYPE"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as CASE_TYPE_ID
            FROM TBL_FORM_DTL F JOIN BIZFLOW.PROCS P ON F.PROCID = P.PROCID WHERE FORM_TYPE = 'CMSERLR' AND P.STATE != 'C'
        ) 
        LOOP
            IF FORM_REC.FINAL_ACTION IS NOT NULL AND FORM_REC.CASE_TYPE_ID = I_CASE_TYPE_ID THEN
                SELECT DELETEXML(FORM_REC.FIELD_DATA, V_XPATH_DEL) INTO FORM_REC.FIELD_DATA FROM DUAL;
    
                UPDATE TBL_FORM_DTL
                   SET FIELD_DATA = FORM_REC.FIELD_DATA
                 WHERE PROCID = FORM_REC.PROCID;
    
                SP_UPDATE_ERLR_TABLE(FORM_REC.PROCID);
            END IF;
        END LOOP;

       UPDATE TBL_LOOKUP
       SET TBL_ACTIVE = '0', 
           TBL_EXPIRATION_DT = TO_DATE('05/01/2019', 'MM/DD/YYYY')
       WHERE TBL_CATEGORY = 'ERLR'
         AND TBL_LABEL = I_LABEL
         AND TBL_LTYPE='ERLRCasesCompletedFinalAction'
         AND TBL_PARENT_ID = I_CASE_TYPE_ID; 
    ELSIF I_ACTION = 'UPDATE' THEN
        V_XPATH := '/formData/items/item[id="CC_FINAL_ACTION_SEL"]/value/value[.="'||I_LABEL||'"]/text()';
        FOR FORM_REC IN (
            SELECT P.PROCID, P.STATE, FIELD_DATA, XMLQUERY(V_XPATH PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as FINAL_ACTION,
                   XMLQUERY('/formData/items/item[id="GEN_CASE_TYPE"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as CASE_TYPE_ID
            FROM TBL_FORM_DTL F JOIN BIZFLOW.PROCS P ON F.PROCID = P.PROCID WHERE FORM_TYPE = 'CMSERLR'
        ) 
        LOOP
            IF FORM_REC.FINAL_ACTION IS NOT NULL AND FORM_REC.CASE_TYPE_ID = I_CASE_TYPE_ID THEN
                V_XPATH := '/formData/items/item[id="CC_FINAL_ACTION_SEL"]/value/value[.="'||I_LABEL||'"]/text()';
                SELECT UPDATEXML(FORM_REC.FIELD_DATA, V_XPATH, I_UPDATED_LABEL) INTO FORM_REC.FIELD_DATA FROM DUAL;
                V_XPATH := '/formData/items/item[id="CC_FINAL_ACTION_SEL"]/value/text[.="'||I_LABEL||'"]/text()';
                SELECT UPDATEXML(FORM_REC.FIELD_DATA, V_XPATH, I_UPDATED_LABEL) INTO FORM_REC.FIELD_DATA FROM DUAL;
    
                UPDATE TBL_FORM_DTL
                   SET FIELD_DATA = FORM_REC.FIELD_DATA
                 WHERE PROCID = FORM_REC.PROCID;
    
                SP_UPDATE_ERLR_TABLE(FORM_REC.PROCID);
            END IF;
        END LOOP;
        
        UPDATE TBL_LOOKUP
           SET TBL_NAME = I_UPDATED_LABEL,
               TBL_LABEL = I_UPDATED_LABEL
         WHERE TBL_CATEGORY = 'ERLR'
           AND TBL_LABEL = I_LABEL
           AND TBL_LTYPE='ERLRCasesCompletedFinalAction'
           AND TBL_PARENT_ID = I_CASE_TYPE_ID
           AND TBL_ACTIVE = 1;
    END IF;

END;
/
-- End of SP_ERLR_MNG_FINAL_ACTION
GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_MNG_FINAL_ACTION TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_MNG_FINAL_ACTION TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_MNG_FINAL_ACTION TO HHS_CMS_HR_DEV_ROLE;
/


create or replace PROCEDURE GET_INCENTIVES_REQUEST_NUM (P_REQUEST_NUM OUT VARCHAR2)
AS
               V_DATE DATE;
               V_SEQ NUMBER;
               V_NUM_OUT VARCHAR2(200);
BEGIN
               BEGIN
                              SELECT RC_DATE, RC_SEQ INTO V_DATE, V_SEQ FROM INCENTIVES_REQUEST_CONTROL;
               EXCEPTION
                              WHEN OTHERS THEN P_REQUEST_NUM := NULL;
                              RETURN;
               END;
               
               IF TO_CHAR(V_DATE, 'YYYYMMDD') <> TO_CHAR(SYSDATE, 'YYYYMMDD') THEN
                              BEGIN
                                             UPDATE INCENTIVES_REQUEST_CONTROL
                                             SET RC_DATE = SYSDATE
                                                            , RC_SEQ = 1001
                                                            , RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-1001';
                              END;
               ELSE
                              BEGIN
                                             UPDATE INCENTIVES_REQUEST_CONTROL
                                             SET RC_SEQ = (V_SEQ + 1)
                                                            , RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' ||
                                                                           TO_CHAR((V_SEQ + 1), 'FM0000');
                              END;
               END IF;

               BEGIN
                              SELECT RC_REQUEST_NUM INTO V_NUM_OUT FROM INCENTIVES_REQUEST_CONTROL;
               END;
               P_REQUEST_NUM := V_NUM_OUT;
EXCEPTION
               WHEN OTHERS THEN P_REQUEST_NUM := NULL;
               RETURN;
END GET_INCENTIVES_REQUEST_NUM;
/
GRANT EXECUTE ON HHS_CMS_HR.GET_INCENTIVES_REQUEST_NUM TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.GET_INCENTIVES_REQUEST_NUM TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.GET_INCENTIVES_REQUEST_NUM TO HHS_CMS_HR_DEV_ROLE;
/


create or replace PROCEDURE SP_UPDATE_INCENTIVES_SAM_TABLE
  (
    I_PROCID            IN      NUMBER
  )
IS
    V_XMLREC_CNT                INTEGER := 0;
    V_XMLDOC                    XMLTYPE;
BEGIN

    --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_INCENTIVES_SAM_TBL2');
    --DBMS_OUTPUT.PUT_LINE('I_PROCID=' || TO_CHAR(I_PROCID));
	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN

        SELECT FIELD_DATA
          INTO V_XMLDOC
          FROM TBL_FORM_DTL
         WHERE PROCID = I_PROCID;

        SELECT COUNT(*)
          INTO V_XMLREC_CNT
          FROM TBL_FORM_DTL
         WHERE PROCID = I_PROCID;

        IF V_XMLREC_CNT > 0 THEN
			--DBMS_OUTPUT.PUT_LINE('RECORD FOUND PROCID=' || TO_CHAR(I_PROCID));

			MERGE INTO INCENTIVES_SAM TRG
			USING
			(
                SELECT FD.PROCID AS PROC_ID
                        ,X.INIT_SALARY_GRADE
                        ,X.INIT_SALARY_STEP
                        ,X.INIT_SALARY_SALARY_PER_ANNUM
                        ,regexp_replace(X."INIT_SALARY_SALARY_PER_ANNUM", '[^0-9|.]', '') as INIT_SALARY_SALARY_PER_ANNUM_N
                        ,X.INIT_SALARY_LOCALITY_PAY_SCALE
                        ,X.SUPPORT_SAM
                        ,X.RCMD_SALARY_GRADE
                        ,X.RCMD_SALARY_STEP
                        ,X.RCMD_SALARY_SALARY_PER_ANNUM
                        ,regexp_replace(X."RCMD_SALARY_SALARY_PER_ANNUM", '[^0-9|.]', '') as RCMD_SALARY_SALARY_PER_ANNUM_N
                        ,X.RCMD_SALARY_LOCALITY_PAY_SCALE
                        ,X.SELECTEE_SALARY_PER_ANNUM
                        ,regexp_replace(X."SELECTEE_SALARY_PER_ANNUM", '[^0-9|.]', '') as SELECTEE_SALARY_PER_ANNUM_N
                        ,X.SELECTEE_SALARY_TYPE
                        ,X.SELECTEE_BONUS
                        ,regexp_replace(X."SELECTEE_BONUS", '[^0-9|.]', '') as SELECTEE_BONUS_N
                        ,X.SELECTEE_BENEFITS
                        ,X.SELECTEE_TOTAL_COMPENSATION
                        ,regexp_replace(X."SELECTEE_TOTAL_COMPENSATION", '[^0-9|.]', '') as SELECTEE_TOTAL_COMPENSATION_N
                        ,X.SUP_DOC_REQ_DATE
                        ,TO_DATE(regexp_replace(X."SUP_DOC_REQ_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as SUP_DOC_REQ_DATE_D
                        ,X.SUP_DOC_RCV_DATE
                        ,TO_DATE(regexp_replace(X."SUP_DOC_RCV_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as SUP_DOC_RCV_DATE_D
                        ,X.JUSTIFICATION_SUPER_QUAL_DESC
                        ,X.JUSTIFICATION_QUAL_COMP_DESC
                        ,X.JUSTIFICATION_PAY_EQUITY_DESC
                        ,X.JUSTIFICATION_EXIST_PKG_DESC
                        ,X.JUSTIFICATION_EXPLAIN_CONSID
                        ,X.SELECT_MEET_ELIGIBILITY
                        ,X.SELECT_MEET_CRITERIA
                        ,X.SUPERIOR_QUAL_REASON
                        ,X.OTHER_FACTORS
                        ,X.SPL_AGENCY_NEED_RSN
                        ,X.SPL_AGENCY_NEED_RSN_ESS
                        ,X.QUAL_REAPPT
                        ,X.OTHER_EXCEPTS
                        ,X.BASIC_PAY_RATE_FACTOR1
                        ,X.BASIC_PAY_RATE_FACTOR2
                        ,X.BASIC_PAY_RATE_FACTOR3
                        ,X.BASIC_PAY_RATE_FACTOR4
                        ,X.BASIC_PAY_RATE_FACTOR5
                        ,X.BASIC_PAY_RATE_FACTOR6
                        ,X.BASIC_PAY_RATE_FACTOR7
                        ,X.BASIC_PAY_RATE_FACTOR8
                        ,X.BASIC_PAY_RATE_FACTOR9
                        ,X.BASIC_PAY_RATE_FACTOR10
                        ,X.OTHER_RLVNT_FACTOR
                        ,X.OTHER_REQ_JUST_APVD
                        ,X.OTHER_REQ_SUFF_INFO_PRVD
                        ,X.OTHER_REQ_INCEN_REQD
                        ,X.OTHER_REQ_DOC_PRVD
                        ,X.HRS_RVW_CERT
                        ,X.HRS_NOT_SPT_RSN
                        ,X.RVW_HRS
                        ,X.HRS_RVW_DATE
                        ,TO_DATE(regexp_replace(X."HRS_RVW_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as HRS_RVW_DATE_D
                        ,X.RCMD_GRADE
                        ,X.RCMD_STEP
                        ,X.RCMD_SALARY_PER_ANNUM
                        ,regexp_replace(X."RCMD_SALARY_PER_ANNUM", '[^0-9|.]', '') as RCMD_SALARY_PER_ANNUM_N
                        ,X.RCMD_LOCALITY_PAY_SCALE
                        ,X.RCMD_INC_DEC_AMOUNT
                        ,regexp_replace(X."RCMD_INC_DEC_AMOUNT", '[^0-9|.]', '') as RCMD_INC_DEC_AMOUNT_N
                        ,X.RCMD_PERC_DIFF
                        ,X.OHC_APPRO_REQ
                        ,X.RCMD_APPRO_OHC_NAME
                        ,X.RCMD_APPRO_OHC_EMAIL
                        ,X.RCMD_APPRO_OHC_ID
                        ,X.RVW_REMARKS
                        ,X.APPROVAL_SO_VALUE
                        ,X.APPROVAL_SO
                        ,X.APPROVAL_SO_RESP_DATE
                        ,TO_DATE(regexp_replace(X."APPROVAL_SO_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_SO_RESP_DATE_D
                        ,X.APPROVAL_DGHO_VALUE
                        ,X.APPROVAL_DGHO
                        ,X.APPROVAL_DGHO_RESP_DATE
                        ,TO_DATE(regexp_replace(X."APPROVAL_DGHO_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_DGHO_RESP_DATE_D
                        ,X.APPROVAL_TABG_VALUE
                        ,X.APPROVAL_TABG
                        ,X.APPROVAL_TABG_RESP_DATE
                        ,TO_DATE(regexp_replace(X."APPROVAL_TABG_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_TABG_RESP_DATE_D
                        ,X.APPROVAL_OHC_VALUE
                        ,X.APPROVAL_OHC
                        ,X.APPROVAL_OHC_RESP_DATE
                        ,TO_DATE(regexp_replace(X."APPROVAL_OHC_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_OHC_RESP_DATE_D
                        ,X.APPROVER_NOTES
                        ,X.COC_NAME
                        ,X.COC_EMAIL
                        ,X.COC_ID
                        ,X.COC_TITLE
                        ,X.APPROVAL_COC_VALUE
                        ,X.APPROVAL_COC_ACTING
                        ,X.APPROVAL_COC
                        ,X.APPROVAL_COC_RESP_DATE
                        ,TO_DATE(regexp_replace(X."APPROVAL_COC_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_COC_RESP_DATE_D
                        ,X.APPROVAL_SO_ACTING
                        ,X.APPROVAL_DGHO_ACTING
                        ,X.APPROVAL_TABG_ACTING
                        ,X.APPROVAL_OHC_ACTING
                        ,X.JUSTIFICATION_MOD_REASON
                        ,X.JUSTIFICATION_MOD_SUMMARY
                        ,X.JUSTIFICATION_MODIFIER_NAME
                        ,X.JUSTIFICATION_MODIFIER_ID
                        ,X.JUSTIFICATION_MODIFIED_DATE
                        ,TO_DATE(regexp_replace(X."JUSTIFICATION_MODIFIED_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy hh24:mi:ss') as JUSTIFICATION_MODIFIED_DATE_D
                        --,X.JUSTIFICATION_VER
                        --,X.JUSTIFICATION_CRT_NAME
                        --,X.JUSTIFICATION_CRT_ID
                        --,X.JUSTIFICATION_CRT_DATE
                        --,X.JUSTIFICATION_CRT_DATE_D
                        ,X.JUSTIFICATION_LASTMOD_NAME
                        ,X.JUSTIFICATION_LASTMOD_ID
                        --,X.JUSTIFICATION_LASTMOD_DATE
                        --,X.JUSTIFICATION_LASTMOD_DATE_D        
			,X.DISAPPROVAL_REASON 
			,X.DISAPPROVAL_USER_NAME 
			,X.DISAPPROVAL_USER_ID
		
                    FROM TBL_FORM_DTL FD,
                         XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
                                INIT_SALARY_GRADE VARCHAR2(5) PATH './item[id="hrInitialSalaryGrade"]/value'
                                , INIT_SALARY_STEP VARCHAR2(5) PATH './item[id="hrInitialSalaryStep"]/value'
                                , INIT_SALARY_SALARY_PER_ANNUM VARCHAR2(20) PATH './item[id="hrInitialSalarySalaryPerAnnum"]/value'
                                , INIT_SALARY_LOCALITY_PAY_SCALE VARCHAR2(200) PATH './item[id="hrInitialSalaryLocalityPayScale"]/value'
                                , SUPPORT_SAM VARCHAR2(5) PATH './item[id="supportSAM"]/value'
                                , RCMD_SALARY_GRADE VARCHAR2(5) PATH './item[id="componentRcmdGrade"]/value'
                                , RCMD_SALARY_STEP VARCHAR2(5) PATH './item[id="componentRcmdStep"]/value'
                                , RCMD_SALARY_SALARY_PER_ANNUM VARCHAR2(20) PATH './item[id="componentRcmdSalaryPerAnnum"]/value'
                                , RCMD_SALARY_LOCALITY_PAY_SCALE VARCHAR2(200) PATH './item[id="componentRcmdLocalityPayScale"]/value'
                                , SELECTEE_SALARY_PER_ANNUM VARCHAR2(20) PATH './item[id="selecteeSalaryPerAnnum"]/value'
                                , SELECTEE_SALARY_TYPE VARCHAR2(25) PATH './item[id="selecteeSalaryType"]/value'
                                , SELECTEE_BONUS VARCHAR2(20) PATH './item[id="selecteeBonus"]/value'
                                , SELECTEE_BENEFITS VARCHAR2(500) PATH './item[id="selecteeBenefits"]/value'
                                , SELECTEE_TOTAL_COMPENSATION VARCHAR2(20) PATH './item[id="selecteeTotalCompensation"]/value'
                                , SUP_DOC_REQ_DATE VARCHAR2(10) PATH './item[id="dateSupDocRequested"]/value'
                                , SUP_DOC_RCV_DATE VARCHAR2(10) PATH './item[id="dateSupDocReceived"]/value'
                                -- Justification
                                , JUSTIFICATION_SUPER_QUAL_DESC VARCHAR2(4000) PATH './item[id="justificationSuperQualificationDesc"]/value'
                                , JUSTIFICATION_QUAL_COMP_DESC VARCHAR2(4000) PATH './item[id="justificationQualificationComparedDesc"]/value'
                                , JUSTIFICATION_PAY_EQUITY_DESC VARCHAR2(4000) PATH './item[id="justificationPayEquityDesc"]/value'
                                , JUSTIFICATION_EXIST_PKG_DESC VARCHAR2(4000) PATH './item[id="justificationExistingCompensationPkgDesc"]/value'
                                , JUSTIFICATION_EXPLAIN_CONSID VARCHAR2(4000) PATH './item[id="justificationExplainIncentiveConsideration"]/value'
                                -- Review
                                , SELECT_MEET_ELIGIBILITY VARCHAR2(100) PATH './item[id="selecteeMeetEligibility"]/value'
                                , SELECT_MEET_CRITERIA VARCHAR2(100) PATH './item[id="selecteeMeetCriteria"]/value'
                                , SUPERIOR_QUAL_REASON VARCHAR2(100) PATH './item[id="superiorQualificationReason"]/value'
                                , OTHER_FACTORS VARCHAR2(140) PATH './item[id="otherFactorsAsExplained"]/value'
                                , SPL_AGENCY_NEED_RSN VARCHAR2(140) PATH './item[id="specialAgencyNeedReason"]/value'
                                , SPL_AGENCY_NEED_RSN_ESS VARCHAR2(140) PATH './item[id="specialAgencyNeedReasonEssential"]/value'
                                , QUAL_REAPPT VARCHAR2(50) PATH './item[id="qualifyingReappointment"]/value'
                                , OTHER_EXCEPTS VARCHAR2(140) PATH './item[id="otherExceptions"]/value'
                                , BASIC_PAY_RATE_FACTOR1 VARCHAR2(140) PATH './item[id="basicPayRateFactor"]/value[1]/text'
                                , BASIC_PAY_RATE_FACTOR2 VARCHAR2(140) PATH './item[id="basicPayRateFactor"]/value[2]/text'
                                , BASIC_PAY_RATE_FACTOR3 VARCHAR2(140) PATH './item[id="basicPayRateFactor"]/value[3]/text'
                                , BASIC_PAY_RATE_FACTOR4 VARCHAR2(140) PATH './item[id="basicPayRateFactor"]/value[4]/text'
                                , BASIC_PAY_RATE_FACTOR5 VARCHAR2(140) PATH './item[id="basicPayRateFactor"]/value[5]/text'
                                , BASIC_PAY_RATE_FACTOR6 VARCHAR2(140) PATH './item[id="basicPayRateFactor"]/value[6]/text'
                                , BASIC_PAY_RATE_FACTOR7 VARCHAR2(140) PATH './item[id="basicPayRateFactor"]/value[7]/text'
                                , BASIC_PAY_RATE_FACTOR8 VARCHAR2(140) PATH './item[id="basicPayRateFactor"]/value[8]/text'
                                , BASIC_PAY_RATE_FACTOR9 VARCHAR2(140) PATH './item[id="basicPayRateFactor"]/value[9]/text'
                                , BASIC_PAY_RATE_FACTOR10 VARCHAR2(140) PATH './item[id="basicPayRateFactor"]/value[10]/text'
                                , OTHER_RLVNT_FACTOR VARCHAR2(140) PATH './item[id="otherRelevantFactors"]/value'
                                , OTHER_REQ_JUST_APVD VARCHAR2(5) PATH './item[id="otherReqJustificationApproved"]/value'
                                , OTHER_REQ_SUFF_INFO_PRVD VARCHAR2(5) PATH './item[id="otherReqSufficientInformationProvided"]/value'
                                , OTHER_REQ_INCEN_REQD VARCHAR2(5) PATH './item[id="otherReqIncentiveRequired"]/value'
                                , OTHER_REQ_DOC_PRVD VARCHAR2(5) PATH './item[id="otherReqDocumentationProvided"]/value'
                                , HRS_RVW_CERT VARCHAR2(100) PATH './item[id="hrSpecialistReviewCertification"]/value'
                                , HRS_NOT_SPT_RSN VARCHAR2(100) PATH './item[id="hrSpecialistNotSupportReason"]/value'
                                , RVW_HRS VARCHAR2(100) PATH './item[id="reviewHRSpecialist"]/value'
                                , HRS_RVW_DATE VARCHAR2(10) PATH './item[id="hrSpecialistReviewDate"]/value'
                                , RCMD_GRADE VARCHAR2(5) PATH './item[id="reviewRcmdGrade"]/value'
                                , RCMD_STEP VARCHAR2(5) PATH './item[id="reviewRcmdStep"]/value'
                                , RCMD_SALARY_PER_ANNUM VARCHAR2(20) PATH './item[id="reviewRcmdSalaryPerAnnum"]/value'
                                , RCMD_LOCALITY_PAY_SCALE VARCHAR2(200) PATH './item[id="reviewRcmdLocalityPayScale"]/value'
                                , RCMD_INC_DEC_AMOUNT VARCHAR2(20) PATH './item[id="reviewRcmdIncDecAmount"]/value'
                                , RCMD_PERC_DIFF VARCHAR2(10) PATH './item[id="reviewRcmdPercentageDifference"]/value'
                                , OHC_APPRO_REQ VARCHAR2(5) PATH './item[id="requireOHCApproval"]/value'
                                -- OHC Director
                                , RCMD_APPRO_OHC_NAME VARCHAR2(100) PATH './item[id="reviewRcmdApprovalOHCDirector"]/value/name'
                                , RCMD_APPRO_OHC_EMAIL VARCHAR2(100) PATH './item[id="reviewRcmdApprovalOHCDirector"]/value/email'
                                , RCMD_APPRO_OHC_ID VARCHAR2(10) PATH './item[id="reviewRcmdApprovalOHCDirector"]/value/id'
                                , RVW_REMARKS VARCHAR2(500) PATH './item[id="samReviewRemarks"]/value'
                                , APPROVAL_SO_VALUE VARCHAR2(10) PATH './item[id="approvalSOValue"]/value'
                                , APPROVAL_SO VARCHAR2(100) PATH './item[id="approvalSO"]/value'
                                , APPROVAL_SO_RESP_DATE VARCHAR2(10) PATH './item[id="approvalSOResponseDate"]/value'
                                , APPROVAL_DGHO_VALUE VARCHAR2(10) PATH './item[id="approvalDGHOValue"]/value'
                                , APPROVAL_DGHO VARCHAR2(100) PATH './item[id="approvalDGHO"]/value'
                                , APPROVAL_DGHO_RESP_DATE VARCHAR2(10) PATH './item[id="approvalDGHOResponseDate"]/value'
                                , APPROVAL_TABG_VALUE VARCHAR2(10) PATH './item[id="approvalTABGValue"]/value'
                                , APPROVAL_TABG VARCHAR2(100) PATH './item[id="approvalTABG"]/value'
                                , APPROVAL_TABG_RESP_DATE VARCHAR2(10) PATH './item[id="approvalTABGResponseDate"]/value'
                                , APPROVAL_OHC_VALUE VARCHAR2(10) PATH './item[id="approvalOHCValue"]/value'
                                , APPROVAL_OHC VARCHAR2(100) PATH './item[id="approvalOHC"]/value'
                                , APPROVAL_OHC_RESP_DATE VARCHAR2(10) PATH './item[id="approvalOHCResponseDate"]/value'
                                , APPROVER_NOTES VARCHAR2(500) PATH './item[id="approverNotes"]/value'
                                , COC_NAME VARCHAR2(100) PATH './item[id="cocDirector"]/value/name'
                                , COC_EMAIL VARCHAR2(100) PATH './item[id="cocDirector"]/value/email'
                                , COC_ID VARCHAR2(10) PATH './item[id="cocDirector"]/value/id'
                                , COC_TITLE VARCHAR2(100) PATH './item[id="cocDirector"]/value/title'
                                , APPROVAL_COC_VALUE VARCHAR2(10) PATH './item[id="approvalCOCValue"]/value'
                                , APPROVAL_COC_ACTING VARCHAR2(10) PATH './item[id="approvalCOCActing"]/value'
                                , APPROVAL_COC VARCHAR2(100) PATH './item[id="approvalCOC"]/value'
                                , APPROVAL_COC_RESP_DATE VARCHAR2(10) PATH './item[id="approvalCOCResponseDate"]/value'
                                , APPROVAL_SO_ACTING VARCHAR2(10) PATH './item[id="approvalSOActing"]/value'
                                , APPROVAL_DGHO_ACTING VARCHAR2(10) PATH './item[id="approvalDGHOActing"]/value'
                                , APPROVAL_TABG_ACTING VARCHAR2(10) PATH './item[id="approvalTABGActing"]/value'
                                , APPROVAL_OHC_Acting VARCHAR2(10) PATH './item[id="approvalOHCActing"]/value'
                                , JUSTIFICATION_MOD_REASON VARCHAR2(200) PATH './item[id="justificationModificationReason"]/value'
                                , JUSTIFICATION_MOD_SUMMARY VARCHAR2(500) PATH './item[id="justificationModificationSummary"]/value'
                                , JUSTIFICATION_MODIFIER_NAME VARCHAR2(100) PATH './item[id="justificationModifier"]/value'
                                , JUSTIFICATION_MODIFIER_ID VARCHAR2(10) PATH './item[id="justificationModifierId"]/value'
                                , JUSTIFICATION_MODIFIED_DATE VARCHAR2(20) PATH './item[id="justificationModified"]/value'	
                                --,JUSTIFICATION_VER	NUMBER(10,0)
                                --,JUSTIFICATION_CRT_NAME	VARCHAR2(100)
                                --,JUSTIFICATION_CRT_ID	VARCHAR2(10)
                                --,JUSTIFICATION_CRT_DATE	VARCHAR2(20)
                                --,JUSTIFICATION_CRT_DATE_D	DATE
                                , JUSTIFICATION_LASTMOD_NAME VARCHAR2(100) PATH './item[id="currentUser"]/value'
                                , JUSTIFICATION_LASTMOD_ID VARCHAR2(10) PATH './item[id="currentUserId"]/value'
                                --,JUSTIFICATION_LASTMOD_DATE	VARCHAR2(20)
                                --,JUSTIFICATION_LASTMOD_DATE_D	DATE
				-- disapproval
				, DISAPPROVAL_REASON VARCHAR2(100) PATH './item[id="disapprovalReason"]/value'
				, DISAPPROVAL_USER_NAME VARCHAR2(100) PATH './item[id="disapprovalUser"]/value/name'
				, DISAPPROVAL_USER_ID VARCHAR2(10) PATH './item[id="disapprovalUser"]/value/id'

                        ) X
                    WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.PROC_ID = TRG.PROC_ID)
            WHEN MATCHED THEN UPDATE SET
                            TRG.INIT_SALARY_GRADE = SRC.INIT_SALARY_GRADE
                            , TRG.INIT_SALARY_STEP = SRC.INIT_SALARY_STEP
                            , TRG.INIT_SALARY_SALARY_PER_ANNUM = SRC.INIT_SALARY_SALARY_PER_ANNUM
                            , TRG.INIT_SALARY_SALARY_PER_ANNUM_N = SRC.INIT_SALARY_SALARY_PER_ANNUM_N
                            , TRG.INIT_SALARY_LOCALITY_PAY_SCALE = SRC.INIT_SALARY_LOCALITY_PAY_SCALE
                            , TRG.SUPPORT_SAM = SRC.SUPPORT_SAM
                            , TRG.RCMD_SALARY_GRADE = SRC.RCMD_SALARY_GRADE
                            , TRG.RCMD_SALARY_STEP = SRC.RCMD_SALARY_STEP
                            , TRG.RCMD_SALARY_SALARY_PER_ANNUM = SRC.RCMD_SALARY_SALARY_PER_ANNUM
                            , TRG.RCMD_SALARY_SALARY_PER_ANNUM_N = SRC.RCMD_SALARY_SALARY_PER_ANNUM_N
                            , TRG.RCMD_SALARY_LOCALITY_PAY_SCALE = SRC.RCMD_SALARY_LOCALITY_PAY_SCALE
                            , TRG.SELECTEE_SALARY_PER_ANNUM = SRC.SELECTEE_SALARY_PER_ANNUM
                            , TRG.SELECTEE_SALARY_PER_ANNUM_N = SRC.SELECTEE_SALARY_PER_ANNUM_N
                            , TRG.SELECTEE_SALARY_TYPE = SRC.SELECTEE_SALARY_TYPE
                            , TRG.SELECTEE_BONUS = SRC.SELECTEE_BONUS
                            , TRG.SELECTEE_BONUS_N = SRC.SELECTEE_BONUS_N
                            , TRG.SELECTEE_BENEFITS = SRC.SELECTEE_BENEFITS
                            , TRG.SELECTEE_TOTAL_COMPENSATION = SRC.SELECTEE_TOTAL_COMPENSATION
                            , TRG.SELECTEE_TOTAL_COMPENSATION_N = SRC.SELECTEE_TOTAL_COMPENSATION_N
                            , TRG.SUP_DOC_REQ_DATE = SRC.SUP_DOC_REQ_DATE
                            , TRG.SUP_DOC_REQ_DATE_D = SRC.SUP_DOC_REQ_DATE_D
                            , TRG.SUP_DOC_RCV_DATE = SRC.SUP_DOC_RCV_DATE
                            , TRG.SUP_DOC_RCV_DATE_D = SRC.SUP_DOC_RCV_DATE_D
                            , TRG.JUSTIFICATION_SUPER_QUAL_DESC = SRC.JUSTIFICATION_SUPER_QUAL_DESC
                            , TRG.JUSTIFICATION_QUAL_COMP_DESC = SRC.JUSTIFICATION_QUAL_COMP_DESC
                            , TRG.JUSTIFICATION_PAY_EQUITY_DESC = SRC.JUSTIFICATION_PAY_EQUITY_DESC
                            , TRG.JUSTIFICATION_EXIST_PKG_DESC = SRC.JUSTIFICATION_EXIST_PKG_DESC
                            , TRG.JUSTIFICATION_EXPLAIN_CONSID = SRC.JUSTIFICATION_EXPLAIN_CONSID
                            , TRG.SELECT_MEET_ELIGIBILITY = SRC.SELECT_MEET_ELIGIBILITY
                            , TRG.SELECT_MEET_CRITERIA = SRC.SELECT_MEET_CRITERIA
                            , TRG.SUPERIOR_QUAL_REASON = SRC.SUPERIOR_QUAL_REASON
                            , TRG.OTHER_FACTORS = SRC.OTHER_FACTORS
                            , TRG.SPL_AGENCY_NEED_RSN = SRC.SPL_AGENCY_NEED_RSN
                            , TRG.SPL_AGENCY_NEED_RSN_ESS = SRC.SPL_AGENCY_NEED_RSN_ESS
                            , TRG.QUAL_REAPPT = SRC.QUAL_REAPPT
                            , TRG.OTHER_EXCEPTS = SRC.OTHER_EXCEPTS
                            , TRG.BASIC_PAY_RATE_FACTOR1 = SRC.BASIC_PAY_RATE_FACTOR1
                            , TRG.BASIC_PAY_RATE_FACTOR2 = SRC.BASIC_PAY_RATE_FACTOR2
                            , TRG.BASIC_PAY_RATE_FACTOR3 = SRC.BASIC_PAY_RATE_FACTOR3
                            , TRG.BASIC_PAY_RATE_FACTOR4 = SRC.BASIC_PAY_RATE_FACTOR4
                            , TRG.BASIC_PAY_RATE_FACTOR5 = SRC.BASIC_PAY_RATE_FACTOR5
                            , TRG.BASIC_PAY_RATE_FACTOR6 = SRC.BASIC_PAY_RATE_FACTOR6
                            , TRG.BASIC_PAY_RATE_FACTOR7 = SRC.BASIC_PAY_RATE_FACTOR7
                            , TRG.BASIC_PAY_RATE_FACTOR8 = SRC.BASIC_PAY_RATE_FACTOR8
                            , TRG.BASIC_PAY_RATE_FACTOR9 = SRC.BASIC_PAY_RATE_FACTOR9
                            , TRG.BASIC_PAY_RATE_FACTOR10 = SRC.BASIC_PAY_RATE_FACTOR10
                            , TRG.OTHER_RLVNT_FACTOR = SRC.OTHER_RLVNT_FACTOR
                            , TRG.OTHER_REQ_JUST_APVD = SRC.OTHER_REQ_JUST_APVD
                            , TRG.OTHER_REQ_SUFF_INFO_PRVD = SRC.OTHER_REQ_SUFF_INFO_PRVD
                            , TRG.OTHER_REQ_INCEN_REQD = SRC.OTHER_REQ_INCEN_REQD
                            , TRG.OTHER_REQ_DOC_PRVD = SRC.OTHER_REQ_DOC_PRVD
                            , TRG.HRS_RVW_CERT = SRC.HRS_RVW_CERT
                            , TRG.HRS_NOT_SPT_RSN = SRC.HRS_NOT_SPT_RSN
                            , TRG.RVW_HRS = SRC.RVW_HRS
                            , TRG.HRS_RVW_DATE = SRC.HRS_RVW_DATE
                            , TRG.HRS_RVW_DATE_D = SRC.HRS_RVW_DATE_D
                            , TRG.RCMD_GRADE = SRC.RCMD_GRADE
                            , TRG.RCMD_STEP = SRC.RCMD_STEP
                            , TRG.RCMD_SALARY_PER_ANNUM = SRC.RCMD_SALARY_PER_ANNUM
                            , TRG.RCMD_SALARY_PER_ANNUM_N = SRC.RCMD_SALARY_PER_ANNUM_N
                            , TRG.RCMD_LOCALITY_PAY_SCALE = SRC.RCMD_LOCALITY_PAY_SCALE
                            , TRG.RCMD_INC_DEC_AMOUNT_N = SRC.RCMD_INC_DEC_AMOUNT_N
                            , TRG.RCMD_INC_DEC_AMOUNT = SRC.RCMD_INC_DEC_AMOUNT
                            , TRG.RCMD_PERC_DIFF = SRC.RCMD_PERC_DIFF
                            , TRG.OHC_APPRO_REQ = SRC.OHC_APPRO_REQ
                            , TRG.RCMD_APPRO_OHC_NAME = SRC.RCMD_APPRO_OHC_NAME
                            , TRG.RCMD_APPRO_OHC_EMAIL = SRC.RCMD_APPRO_OHC_EMAIL
                            , TRG.RCMD_APPRO_OHC_ID = SRC.RCMD_APPRO_OHC_ID
                            , TRG.RVW_REMARKS = SRC.RVW_REMARKS
                            , TRG.APPROVAL_SO_VALUE = SRC.APPROVAL_SO_VALUE
                            , TRG.APPROVAL_SO = SRC.APPROVAL_SO
                            , TRG.APPROVAL_SO_RESP_DATE = SRC.APPROVAL_SO_RESP_DATE
                            , TRG.APPROVAL_SO_RESP_DATE_D = SRC.APPROVAL_SO_RESP_DATE_D
                            , TRG.APPROVAL_DGHO_VALUE = SRC.APPROVAL_DGHO_VALUE
                            , TRG.APPROVAL_DGHO = SRC.APPROVAL_DGHO
                            , TRG.APPROVAL_DGHO_RESP_DATE = SRC.APPROVAL_DGHO_RESP_DATE
                            , TRG.APPROVAL_DGHO_RESP_DATE_D = SRC.APPROVAL_DGHO_RESP_DATE_D
                            , TRG.APPROVAL_TABG_VALUE = SRC.APPROVAL_TABG_VALUE
                            , TRG.APPROVAL_TABG = SRC.APPROVAL_TABG
                            , TRG.APPROVAL_TABG_RESP_DATE = SRC.APPROVAL_TABG_RESP_DATE
                            , TRG.APPROVAL_TABG_RESP_DATE_D = SRC.APPROVAL_TABG_RESP_DATE_D
                            , TRG.APPROVAL_OHC_VALUE = SRC.APPROVAL_OHC_VALUE
                            , TRG.APPROVAL_OHC = SRC.APPROVAL_OHC
                            , TRG.APPROVAL_OHC_RESP_DATE = SRC.APPROVAL_OHC_RESP_DATE
                            , TRG.APPROVAL_OHC_RESP_DATE_D = SRC.APPROVAL_OHC_RESP_DATE_D
                            , TRG.APPROVER_NOTES = SRC.APPROVER_NOTES
                            , TRG.COC_NAME = SRC.COC_NAME
                            , TRG.COC_EMAIL = SRC.COC_EMAIL
                            , TRG.COC_ID = SRC.COC_ID
                            , TRG.COC_TITLE = SRC.COC_TITLE
                            , TRG.APPROVAL_COC_VALUE = SRC.APPROVAL_COC_VALUE
                            , TRG.APPROVAL_COC_ACTING = SRC.APPROVAL_COC_ACTING
                            , TRG.APPROVAL_COC = SRC.APPROVAL_COC
                            , TRG.APPROVAL_COC_RESP_DATE = SRC.APPROVAL_COC_RESP_DATE
                            , TRG.APPROVAL_COC_RESP_DATE_D = SRC.APPROVAL_COC_RESP_DATE_D
                            , TRG.APPROVAL_SO_ACTING = SRC.APPROVAL_SO_ACTING
                            , TRG.APPROVAL_DGHO_ACTING = SRC.APPROVAL_DGHO_ACTING
                            , TRG.APPROVAL_TABG_ACTING = SRC.APPROVAL_TABG_ACTING
                            , TRG.APPROVAL_OHC_ACTING = SRC.APPROVAL_OHC_ACTING
                            , TRG.JUSTIFICATION_MOD_REASON = SRC.JUSTIFICATION_MOD_REASON
                            , TRG.JUSTIFICATION_MOD_SUMMARY = SRC.JUSTIFICATION_MOD_SUMMARY
                            , TRG.JUSTIFICATION_MODIFIER_NAME = SRC.JUSTIFICATION_MODIFIER_NAME
                            , TRG.JUSTIFICATION_MODIFIER_ID = SRC.JUSTIFICATION_MODIFIER_ID
                            , TRG.JUSTIFICATION_MODIFIED_DATE = SRC.JUSTIFICATION_MODIFIED_DATE
                            , TRG.JUSTIFICATION_MODIFIED_DATE_D = SRC.JUSTIFICATION_MODIFIED_DATE_D
                            --, TRG.JUSTIFICATION_VER = SRC.JUSTIFICATION_VER
                            --, TRG.JUSTIFICATION_CRT_NAME = SRC.JUSTIFICATION_CRT_NAME
                            --, TRG.JUSTIFICATION_CRT_ID = SRC.JUSTIFICATION_CRT_ID
                            --, TRG.JUSTIFICATION_CRT_DATE = SRC.JUSTIFICATION_CRT_DATE
                            --, TRG.JUSTIFICATION_CRT_DATE_D = SRC.JUSTIFICATION_CRT_DATE_D
                            , TRG.JUSTIFICATION_LASTMOD_NAME = SRC.JUSTIFICATION_LASTMOD_NAME
                            , TRG.JUSTIFICATION_LASTMOD_ID = SRC.JUSTIFICATION_LASTMOD_ID
                            --, TRG.JUSTIFICATION_LASTMOD_DATE = SRC.JUSTIFICATION_LASTMOD_DATE
                            --, TRG.JUSTIFICATION_LASTMOD_DATE_D = SRC.JUSTIFICATION_LASTMOD_DATE_D 
			    --, TRG.JUSTIFICATION_LASTMOD_DATE_D = SRC.JUSTIFICATION_LASTMOD_DATE_D 
			   ,TRG.DISAPPROVAL_REASON  = SRC.DISAPPROVAL_REASON
			   ,TRG.DISAPPROVAL_USER_NAME = SRC.DISAPPROVAL_USER_NAME
			   ,TRG.DISAPPROVAL_USER_ID = SRC.DISAPPROVAL_USER_ID

            WHEN NOT MATCHED THEN INSERT (
                            TRG.PROC_ID
                            , TRG.INIT_SALARY_GRADE
                            , TRG.INIT_SALARY_STEP
                            , TRG.INIT_SALARY_SALARY_PER_ANNUM
                            , TRG.INIT_SALARY_SALARY_PER_ANNUM_N
                            , TRG.INIT_SALARY_LOCALITY_PAY_SCALE
                            , TRG.SUPPORT_SAM
                            , TRG.RCMD_SALARY_GRADE
                            , TRG.RCMD_SALARY_STEP
                            , TRG.RCMD_SALARY_SALARY_PER_ANNUM
                            , TRG.RCMD_SALARY_SALARY_PER_ANNUM_N
                            , TRG.RCMD_SALARY_LOCALITY_PAY_SCALE
                            , TRG.SELECTEE_SALARY_PER_ANNUM
                            , TRG.SELECTEE_SALARY_PER_ANNUM_N
                            , TRG.SELECTEE_SALARY_TYPE
                            , TRG.SELECTEE_BONUS
                            , TRG.SELECTEE_BONUS_N
                            , TRG.SELECTEE_BENEFITS
                            , TRG.SELECTEE_TOTAL_COMPENSATION
                            , TRG.SELECTEE_TOTAL_COMPENSATION_N
                            , TRG.SUP_DOC_REQ_DATE
                            , TRG.SUP_DOC_REQ_DATE_D
                            , TRG.SUP_DOC_RCV_DATE
                            , TRG.SUP_DOC_RCV_DATE_D
                            , TRG.JUSTIFICATION_SUPER_QUAL_DESC
                            , TRG.JUSTIFICATION_QUAL_COMP_DESC
                            , TRG.JUSTIFICATION_PAY_EQUITY_DESC
                            , TRG.JUSTIFICATION_EXIST_PKG_DESC
                            , TRG.JUSTIFICATION_EXPLAIN_CONSID
                            , TRG.SELECT_MEET_ELIGIBILITY
                            , TRG.SELECT_MEET_CRITERIA
                            , TRG.SUPERIOR_QUAL_REASON
                            , TRG.OTHER_FACTORS
                            , TRG.SPL_AGENCY_NEED_RSN
                            , TRG.SPL_AGENCY_NEED_RSN_ESS
                            , TRG.QUAL_REAPPT
                            , TRG.OTHER_EXCEPTS
                            , TRG.BASIC_PAY_RATE_FACTOR1
                            , TRG.BASIC_PAY_RATE_FACTOR2
                            , TRG.BASIC_PAY_RATE_FACTOR3
                            , TRG.BASIC_PAY_RATE_FACTOR4
                            , TRG.BASIC_PAY_RATE_FACTOR5
                            , TRG.BASIC_PAY_RATE_FACTOR6
                            , TRG.BASIC_PAY_RATE_FACTOR7
                            , TRG.BASIC_PAY_RATE_FACTOR8
                            , TRG.BASIC_PAY_RATE_FACTOR9
                            , TRG.BASIC_PAY_RATE_FACTOR10
                            , TRG.OTHER_RLVNT_FACTOR
                            , TRG.OTHER_REQ_JUST_APVD
                            , TRG.OTHER_REQ_SUFF_INFO_PRVD
                            , TRG.OTHER_REQ_INCEN_REQD
                            , TRG.OTHER_REQ_DOC_PRVD
                            , TRG.HRS_RVW_CERT
                            , TRG.HRS_NOT_SPT_RSN
                            , TRG.RVW_HRS
                            , TRG.HRS_RVW_DATE
                            , TRG.HRS_RVW_DATE_D
                            , TRG.RCMD_GRADE
                            , TRG.RCMD_STEP
                            , TRG.RCMD_SALARY_PER_ANNUM
                            , TRG.RCMD_SALARY_PER_ANNUM_N
                            , TRG.RCMD_LOCALITY_PAY_SCALE
                            , TRG.RCMD_INC_DEC_AMOUNT_N
                            , TRG.RCMD_INC_DEC_AMOUNT
                            , TRG.RCMD_PERC_DIFF
                            , TRG.OHC_APPRO_REQ
                            , TRG.RCMD_APPRO_OHC_NAME
                            , TRG.RCMD_APPRO_OHC_EMAIL
                            , TRG.RCMD_APPRO_OHC_ID
                            , TRG.RVW_REMARKS
                            , TRG.APPROVAL_SO_VALUE
                            , TRG.APPROVAL_SO
                            , TRG.APPROVAL_SO_RESP_DATE
                            , TRG.APPROVAL_SO_RESP_DATE_D
                            , TRG.APPROVAL_DGHO_VALUE
                            , TRG.APPROVAL_DGHO
                            , TRG.APPROVAL_DGHO_RESP_DATE
                            , TRG.APPROVAL_DGHO_RESP_DATE_D
                            , TRG.APPROVAL_TABG_VALUE
                            , TRG.APPROVAL_TABG
                            , TRG.APPROVAL_TABG_RESP_DATE
                            , TRG.APPROVAL_TABG_RESP_DATE_D
                            , TRG.APPROVAL_OHC_VALUE
                            , TRG.APPROVAL_OHC
                            , TRG.APPROVAL_OHC_RESP_DATE
                            , TRG.APPROVAL_OHC_RESP_DATE_D
                            , TRG.APPROVER_NOTES
                            , TRG.COC_NAME
                            , TRG.COC_EMAIL
                            , TRG.COC_ID
                            , TRG.COC_TITLE
                            , TRG.APPROVAL_COC_VALUE
                            , TRG.APPROVAL_COC_ACTING
                            , TRG.APPROVAL_COC
                            , TRG.APPROVAL_COC_RESP_DATE
                            , TRG.APPROVAL_COC_RESP_DATE_D
                            , TRG.APPROVAL_SO_ACTING
                            , TRG.APPROVAL_DGHO_ACTING
                            , TRG.APPROVAL_TABG_ACTING
                            , TRG.APPROVAL_OHC_ACTING
                            , TRG.JUSTIFICATION_MOD_REASON
                            , TRG.JUSTIFICATION_MOD_SUMMARY
                            , TRG.JUSTIFICATION_MODIFIER_NAME
                            , TRG.JUSTIFICATION_MODIFIER_ID
                            , TRG.JUSTIFICATION_MODIFIED_DATE
                            , TRG.JUSTIFICATION_MODIFIED_DATE_D
                            --, TRG.JUSTIFICATION_VER
                            --, TRG.JUSTIFICATION_CRT_NAME
                            --, TRG.JUSTIFICATION_CRT_ID
                            --, TRG.JUSTIFICATION_CRT_DATE
                            --, TRG.JUSTIFICATION_CRT_DATE_D
                            , TRG.JUSTIFICATION_LASTMOD_NAME
                            , TRG.JUSTIFICATION_LASTMOD_ID
                            --, TRG.JUSTIFICATION_LASTMOD_DATE
                            --, TRG.JUSTIFICATION_LASTMOD_DATE_D 
    			    ,TRG.DISAPPROVAL_REASON
			    ,TRG.DISAPPROVAL_USER_NAME
			    ,TRG.DISAPPROVAL_USER_ID
                        ) VALUES (
                            SRC.PROC_ID
                            , SRC.INIT_SALARY_GRADE
                            , SRC.INIT_SALARY_STEP
                            , SRC.INIT_SALARY_SALARY_PER_ANNUM
                            , SRC.INIT_SALARY_SALARY_PER_ANNUM_N
                            , SRC.INIT_SALARY_LOCALITY_PAY_SCALE
                            , SRC.SUPPORT_SAM
                            , SRC.RCMD_SALARY_GRADE
                            , SRC.RCMD_SALARY_STEP
                            , SRC.RCMD_SALARY_SALARY_PER_ANNUM
                            , SRC.RCMD_SALARY_SALARY_PER_ANNUM_N
                            , SRC.RCMD_SALARY_LOCALITY_PAY_SCALE
                            , SRC.SELECTEE_SALARY_PER_ANNUM
                            , SRC.SELECTEE_SALARY_PER_ANNUM_N
                            , SRC.SELECTEE_SALARY_TYPE
                            , SRC.SELECTEE_BONUS
                            , SRC.SELECTEE_BONUS_N
                            , SRC.SELECTEE_BENEFITS
                            , SRC.SELECTEE_TOTAL_COMPENSATION
                            , SRC.SELECTEE_TOTAL_COMPENSATION_N
                            , SRC.SUP_DOC_REQ_DATE
                            , SRC.SUP_DOC_REQ_DATE_D
                            , SRC.SUP_DOC_RCV_DATE
                            , SRC.SUP_DOC_RCV_DATE_D
                            , SRC.JUSTIFICATION_SUPER_QUAL_DESC
                            , SRC.JUSTIFICATION_QUAL_COMP_DESC
                            , SRC.JUSTIFICATION_PAY_EQUITY_DESC
                            , SRC.JUSTIFICATION_EXIST_PKG_DESC
                            , SRC.JUSTIFICATION_EXPLAIN_CONSID
                            , SRC.SELECT_MEET_ELIGIBILITY
                            , SRC.SELECT_MEET_CRITERIA
                            , SRC.SUPERIOR_QUAL_REASON
                            , SRC.OTHER_FACTORS
                            , SRC.SPL_AGENCY_NEED_RSN
                            , SRC.SPL_AGENCY_NEED_RSN_ESS
                            , SRC.QUAL_REAPPT
                            , SRC.OTHER_EXCEPTS
                            , SRC.BASIC_PAY_RATE_FACTOR1
                            , SRC.BASIC_PAY_RATE_FACTOR2
                            , SRC.BASIC_PAY_RATE_FACTOR3
                            , SRC.BASIC_PAY_RATE_FACTOR4
                            , SRC.BASIC_PAY_RATE_FACTOR5
                            , SRC.BASIC_PAY_RATE_FACTOR6
                            , SRC.BASIC_PAY_RATE_FACTOR7
                            , SRC.BASIC_PAY_RATE_FACTOR8
                            , SRC.BASIC_PAY_RATE_FACTOR9
                            , SRC.BASIC_PAY_RATE_FACTOR10
                            , SRC.OTHER_RLVNT_FACTOR
                            , SRC.OTHER_REQ_JUST_APVD
                            , SRC.OTHER_REQ_SUFF_INFO_PRVD
                            , SRC.OTHER_REQ_INCEN_REQD
                            , SRC.OTHER_REQ_DOC_PRVD
                            , SRC.HRS_RVW_CERT
                            , SRC.HRS_NOT_SPT_RSN
                            , SRC.RVW_HRS
                            , SRC.HRS_RVW_DATE
                            , SRC.HRS_RVW_DATE_D
                            , SRC.RCMD_GRADE
                            , SRC.RCMD_STEP
                            , SRC.RCMD_SALARY_PER_ANNUM
                            , SRC.RCMD_SALARY_PER_ANNUM_N
                            , SRC.RCMD_LOCALITY_PAY_SCALE
                            , SRC.RCMD_INC_DEC_AMOUNT_N
                            , SRC.RCMD_INC_DEC_AMOUNT
                            , SRC.RCMD_PERC_DIFF
                            , SRC.OHC_APPRO_REQ
                            , SRC.RCMD_APPRO_OHC_NAME
                            , SRC.RCMD_APPRO_OHC_EMAIL
                            , SRC.RCMD_APPRO_OHC_ID
                            , SRC.RVW_REMARKS
                            , SRC.APPROVAL_SO_VALUE
                            , SRC.APPROVAL_SO
                            , SRC.APPROVAL_SO_RESP_DATE
                            , SRC.APPROVAL_SO_RESP_DATE_D
                            , SRC.APPROVAL_DGHO_VALUE
                            , SRC.APPROVAL_DGHO
                            , SRC.APPROVAL_DGHO_RESP_DATE
                            , SRC.APPROVAL_DGHO_RESP_DATE_D
                            , SRC.APPROVAL_TABG_VALUE
                            , SRC.APPROVAL_TABG
                            , SRC.APPROVAL_TABG_RESP_DATE
                            , SRC.APPROVAL_TABG_RESP_DATE_D
                            , SRC.APPROVAL_OHC_VALUE
                            , SRC.APPROVAL_OHC
                            , SRC.APPROVAL_OHC_RESP_DATE
                            , SRC.APPROVAL_OHC_RESP_DATE_D
                            , SRC.APPROVER_NOTES
                            , SRC.COC_NAME
                            , SRC.COC_EMAIL
                            , SRC.COC_ID
                            , SRC.COC_TITLE
                            , SRC.APPROVAL_COC_VALUE
                            , SRC.APPROVAL_COC_ACTING
                            , SRC.APPROVAL_COC
                            , SRC.APPROVAL_COC_RESP_DATE
                            , SRC.APPROVAL_COC_RESP_DATE_D
                            , SRC.APPROVAL_SO_ACTING
                            , SRC.APPROVAL_DGHO_ACTING
                            , SRC.APPROVAL_TABG_ACTING
                            , SRC.APPROVAL_OHC_ACTING
                            , SRC.JUSTIFICATION_MOD_REASON
                            , SRC.JUSTIFICATION_MOD_SUMMARY
                            , SRC.JUSTIFICATION_MODIFIER_NAME
                            , SRC.JUSTIFICATION_MODIFIER_ID
                            , SRC.JUSTIFICATION_MODIFIED_DATE
                            , SRC.JUSTIFICATION_MODIFIED_DATE_D
                            --, SRC.JUSTIFICATION_VER
                            --, SRC.JUSTIFICATION_CRT_NAME
                            --, SRC.JUSTIFICATION_CRT_ID
                            --, SRC.JUSTIFICATION_CRT_DATE
                            --, SRC.JUSTIFICATION_CRT_DATE_D
                            , SRC.JUSTIFICATION_LASTMOD_NAME
                            , SRC.JUSTIFICATION_LASTMOD_ID
                            --, SRC.JUSTIFICATION_LASTMOD_DATE
                            --, SRC.JUSTIFICATION_LASTMOD_DATE_D 
   			    ,SRC.DISAPPROVAL_REASON
			   ,SRC.DISAPPROVAL_USER_NAME
			   ,SRC.DISAPPROVAL_USER_ID
                        );

        END IF;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION=' || SUBSTR(SQLERRM, 1, 200));
          --err_code := SQLCODE;
          --err_msg := SUBSTR(SQLERRM, 1, 200);    
    SP_ERROR_LOG();
  END;
/

GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_SAM_TABLE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_SAM_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_SAM_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_SAM_TABLE TO BF_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_INCENTIVES_LE_TABLE
  (
    I_PROCID            IN      NUMBER
  )
IS
    V_XMLREC_CNT                INTEGER := 0;
BEGIN

    DBMS_OUTPUT.PUT_LINE('SP_UPDATE_INCENTIVES_LE_TBL2');
    DBMS_OUTPUT.PUT_LINE('I_PROCID=' || TO_CHAR(I_PROCID));
	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN

        SELECT COUNT(*)
          INTO V_XMLREC_CNT
          FROM TBL_FORM_DTL
         WHERE PROCID = I_PROCID;


        IF V_XMLREC_CNT > 0 THEN
			DBMS_OUTPUT.PUT_LINE('RECORD FOUND PROCID=' || TO_CHAR(I_PROCID));

			MERGE INTO INCENTIVES_LE TRG
			USING
			(
                     SELECT FD.PROCID AS PROC_ID
                            , X.INIT_ANN_LA_RATE
                            , X.SUPPORT_LE
                            , X.PROPS_ANN_LA_RATE
                            , X.JUSTIFICATION_SKILL_EXP
                            , X.JUSTIFICATION_AGENCY_GOAL
                            , X.SELECTEE_ELIGIBILITY
                            , X.HRS_RVW_CERT
                            , X.HRS_NOT_SPT_RSN
                            , X.RVW_HRS
                            , X.HRS_RVW_DATE
                            , X.RCMD_LA_RATE
                            , X.APPROVAL_SO_VALUE
                            , X.APPROVAL_SO
                            , X.APPROVAL_SO_RESP_DATE
                            , X.APPROVAL_DGHO_VALUE
                            , X.APPROVAL_DGHO
                            , X.APPROVAL_DGHO_RESP_DATE
                            , X.APPROVAL_TABG_VALUE
                            , X.APPROVAL_TABG
                            , X.APPROVAL_TABG_RESP_DATE
                            , X.COC_NAME
                            , X.COC_EMAIL
                            , X.COC_ID
                            , X.COC_TITLE
                            , X.APPROVAL_COC_VALUE
                            , X.APPROVAL_COC_ACTING
                            , X.APPROVAL_COC
                            , X.APPROVAL_COC_RESP_DATE
                            , X.APPROVAL_SO_ACTING
                            , X.APPROVAL_DGHO_ACTING
                            , X.APPROVAL_TABG_ACTING
                            --, X.JUSTIFICATION_VER
                            --, X.JUSTIFICATION_CRT_NAME
                            --, X.JUSTIFICATION_CRT_ID
                            --, X.JUSTIFICATION_CRT_DATE
                            , X.JUSTIFICATION_LASTMOD_NAME
                            , X.JUSTIFICATION_LASTMOD_ID
                            --, X.JUSTIFICATION_LASTMOD_DATE
                            , X.JUSTIFICATION_MOD_REASON
                            , X.JUSTIFICATION_MOD_SUMMARY
                            , X.JUSTIFICATION_MODIFIER_NAME
                            , X.JUSTIFICATION_MODIFIER_ID
                            , X.JUSTIFICATION_MODIFIED_DATE
                            , X.TOTAL_CREDITABLE_YEARS
                            , X.TOTAL_CREDITABLE_MONTHS
                            , X.APPROVER_NOTES
                            ,TO_DATE(regexp_replace(X."HRS_RVW_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as HRS_RVW_DATE_D
                            ,TO_DATE(regexp_replace(X."APPROVAL_SO_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_SO_RESP_DATE_D
                            ,TO_DATE(regexp_replace(X."APPROVAL_DGHO_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_DGHO_RESP_DATE_D
                            ,TO_DATE(regexp_replace(X."APPROVAL_TABG_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_TABG_RESP_DATE_D
                            ,TO_DATE(regexp_replace(X."APPROVAL_COC_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_COC_RESP_DATE_D
                            --,TO_DATE(regexp_replace(X."JUSTIFICATION_CRT_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as JUSTIFICATION_CRT_DATE_D
                            --,TO_DATE(regexp_replace(X."JUSTIFICATION_LASTMOD_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as JUSTIFICATION_LASTMOD_DATE_D
                            ,TO_DATE(regexp_replace(X."JUSTIFICATION_MODIFIED_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as JUSTIFICATION_MODIFIED_DATE_D
			    ,X.DISAPPROVAL_REASON 
			    ,X.DISAPPROVAL_USER_NAME 
			    ,X.DISAPPROVAL_USER_ID

                    FROM TBL_FORM_DTL FD,
                         XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
                            COC_NAME VARCHAR2(100) PATH './item[id="lecocDirector"]/value/name'
                            , COC_EMAIL VARCHAR2(100) PATH './item[id="lecocDirector"]/value/email'
                            , COC_ID VARCHAR2(10) PATH './item[id="lecocDirector"]/value/id'
                            , COC_TITLE VARCHAR2(100) PATH './item[id="lecocDirector"]/value/title'
                            , INIT_ANN_LA_RATE VARCHAR2(10) PATH './item[id="initialOfferedAnnualLeaveAccrualRate"]/value'
                            , SUPPORT_LE VARCHAR2(5) PATH './item[id="supportLE"]/value'
                            , PROPS_ANN_LA_RATE VARCHAR2(10) PATH './item[id="proposedAnnualLeaveAccrualRate"]/value'
                            , TOTAL_CREDITABLE_YEARS NUMBER(10) PATH './item[id="totalCreditableServiceYears"]/value'
                            , TOTAL_CREDITABLE_MONTHS NUMBER(10) PATH './item[id="totalCreditableServiceMonths"]/value'
                            -- Justification
                            , JUSTIFICATION_LASTMOD_NAME VARCHAR2(100) PATH './item[id="currentUser"]/value'
                            , JUSTIFICATION_LASTMOD_ID VARCHAR2(10) PATH './item[id="currentUserId"]/value'
                            , JUSTIFICATION_MOD_REASON VARCHAR2(200) PATH './item[id="leJustificationModificationReason"]/value'
                            , JUSTIFICATION_MOD_SUMMARY VARCHAR2(500) PATH './item[id="leJustificationModificationSummary"]/value'
                            , JUSTIFICATION_MODIFIER_NAME VARCHAR2(100) PATH './item[id="leJustificationModifier"]/value'
                            , JUSTIFICATION_MODIFIER_ID VARCHAR2(10) PATH './item[id="leJustificationModifierId"]/value'
                            , JUSTIFICATION_MODIFIED_DATE VARCHAR2(20) PATH './item[id="leJustificationModified"]/value'
                            , JUSTIFICATION_SKILL_EXP VARCHAR2(4000) PATH './item[id="justificationSkillAndExperience"]/value'
                            , JUSTIFICATION_AGENCY_GOAL VARCHAR2(4000) PATH './item[id="justificationAgencyMissionOrPerformanceGoal"]/value'
                            -- Review
                            , SELECTEE_ELIGIBILITY VARCHAR2(100) PATH './item[id="leSelecteeEligibility"]/value'
                            , HRS_RVW_CERT VARCHAR2(100) PATH './item[id="hrSpecialistLEReviewCertification"]/value'
                            , HRS_NOT_SPT_RSN VARCHAR2(100) PATH './item[id="hrSpecialistLENotSupportReason"]/value'
                            , RVW_HRS VARCHAR2(100) PATH './item[id="leReviewHRSpecialist"]/value'
                            , HRS_RVW_DATE VARCHAR2(10) PATH './item[id="hrSpecialistLEReviewDate"]/value'
                            , RCMD_LA_RATE VARCHAR2(10) PATH './item[id="rcmdAnnualLeaveAccrualRate"]/value'
                            -- Approvals
                            , APPROVAL_SO_VALUE VARCHAR2(10) PATH './item[id="leApprovalSOValue"]/value'
                            , APPROVAL_SO_ACTING VARCHAR2(10) PATH './item[id="leApprovalSOActing"]/value'
                            , APPROVAL_SO VARCHAR2(100) PATH './item[id="leApprovalSO"]/value'
                            , APPROVAL_SO_RESP_DATE VARCHAR2(10) PATH './item[id="leApprovalSOResponseDate"]/value'
                            , APPROVAL_COC_VALUE VARCHAR2(10) PATH './item[id="leApprovalCOCValue"]/value'
                            , APPROVAL_COC_ACTING VARCHAR2(10) PATH './item[id="leApprovalCOCActing"]/value'
                            , APPROVAL_COC VARCHAR2(100) PATH './item[id="leApprovalCOC"]/value'
                            , APPROVAL_COC_RESP_DATE VARCHAR2(10) PATH './item[id="leApprovalCOCResponseDate"]/value'
                            , APPROVAL_DGHO_VALUE VARCHAR2(10) PATH './item[id="leApprovalDGHOValue"]/value'
                            , APPROVAL_DGHO_ACTING VARCHAR2(10) PATH './item[id="leApprovalDGHOActing"]/value'
                            , APPROVAL_DGHO VARCHAR2(100) PATH './item[id="leApprovalDGHO"]/value'
                            , APPROVAL_DGHO_RESP_DATE VARCHAR2(10) PATH './item[id="leApprovalDGHOResponseDate"]/value'
                            , APPROVAL_TABG_VALUE VARCHAR2(10) PATH './item[id="leApprovalTABGValue"]/value'
                            , APPROVAL_TABG_ACTING VARCHAR2(10) PATH './item[id="leApprovalTABGActing"]/value'
                            , APPROVAL_TABG VARCHAR2(100) PATH './item[id="leApprovalTABG"]/value'
                            , APPROVAL_TABG_RESP_DATE VARCHAR2(10) PATH './item[id="leApprovalTABGResponseDate"]/value'
                            , APPROVER_NOTES VARCHAR2(500) PATH './item[id="leApproverNotes"]/value'
			    -- disapproval
			    , DISAPPROVAL_REASON VARCHAR2(100) PATH './item[id="disapprovalReason"]/value'
			    , DISAPPROVAL_USER_NAME VARCHAR2(100) PATH './item[id="disapprovalUser"]/value/name'
			    , DISAPPROVAL_USER_ID VARCHAR2(10) PATH './item[id="disapprovalUser"]/value/id'
                        ) X
                    WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.PROC_ID = TRG.PROC_ID)
            WHEN MATCHED THEN UPDATE SET
                            TRG.INIT_ANN_LA_RATE = SRC.INIT_ANN_LA_RATE
                            , TRG.SUPPORT_LE = SRC.SUPPORT_LE
                            , TRG.PROPS_ANN_LA_RATE = SRC.PROPS_ANN_LA_RATE
                            , TRG.JUSTIFICATION_SKILL_EXP = SRC.JUSTIFICATION_SKILL_EXP
                            , TRG.JUSTIFICATION_AGENCY_GOAL = SRC.JUSTIFICATION_AGENCY_GOAL
                            , TRG.SELECTEE_ELIGIBILITY = SRC.SELECTEE_ELIGIBILITY
                            , TRG.HRS_RVW_CERT = SRC.HRS_RVW_CERT
                            , TRG.HRS_NOT_SPT_RSN = SRC.HRS_NOT_SPT_RSN
                            , TRG.RVW_HRS = SRC.RVW_HRS
                            , TRG.HRS_RVW_DATE = SRC.HRS_RVW_DATE
                            , TRG.RCMD_LA_RATE = SRC.RCMD_LA_RATE
                            , TRG.APPROVAL_SO_VALUE = SRC.APPROVAL_SO_VALUE
                            , TRG.APPROVAL_SO = SRC.APPROVAL_SO
                            , TRG.APPROVAL_SO_RESP_DATE = SRC.APPROVAL_SO_RESP_DATE
                            , TRG.APPROVAL_DGHO_VALUE = SRC.APPROVAL_DGHO_VALUE
                            , TRG.APPROVAL_DGHO = SRC.APPROVAL_DGHO
                            , TRG.APPROVAL_DGHO_RESP_DATE = SRC.APPROVAL_DGHO_RESP_DATE
                            , TRG.APPROVAL_TABG_VALUE = SRC.APPROVAL_TABG_VALUE
                            , TRG.APPROVAL_TABG = SRC.APPROVAL_TABG
                            , TRG.APPROVAL_TABG_RESP_DATE = SRC.APPROVAL_TABG_RESP_DATE
                            , TRG.COC_NAME = SRC.COC_NAME
                            , TRG.COC_EMAIL = SRC.COC_EMAIL
                            , TRG.COC_ID = SRC.COC_ID
                            , TRG.COC_TITLE = SRC.COC_TITLE
                            , TRG.APPROVAL_COC_VALUE = SRC.APPROVAL_COC_VALUE
                            , TRG.APPROVAL_COC_ACTING = SRC.APPROVAL_COC_ACTING
                            , TRG.APPROVAL_COC = SRC.APPROVAL_COC
                            , TRG.APPROVAL_COC_RESP_DATE = SRC.APPROVAL_COC_RESP_DATE
                            , TRG.APPROVAL_SO_ACTING = SRC.APPROVAL_SO_ACTING
                            , TRG.APPROVAL_DGHO_ACTING = SRC.APPROVAL_DGHO_ACTING
                            , TRG.APPROVAL_TABG_ACTING = SRC.APPROVAL_TABG_ACTING
                            --, TRG.JUSTIFICATION_VER = SRC.JUSTIFICATION_VER
                            --, TRG.JUSTIFICATION_CRT_NAME = SRC.JUSTIFICATION_CRT_NAME
                            --, TRG.JUSTIFICATION_CRT_ID = SRC.JUSTIFICATION_CRT_ID
                            --, TRG.JUSTIFICATION_CRT_DATE = SRC.JUSTIFICATION_CRT_DATE
                            , TRG.JUSTIFICATION_LASTMOD_NAME = SRC.JUSTIFICATION_LASTMOD_NAME
                            , TRG.JUSTIFICATION_LASTMOD_ID = SRC.JUSTIFICATION_LASTMOD_ID
                            --, TRG.JUSTIFICATION_LASTMOD_DATE = SRC.JUSTIFICATION_LASTMOD_DATE
                            , TRG.JUSTIFICATION_MOD_REASON = SRC.JUSTIFICATION_MOD_REASON
                            , TRG.JUSTIFICATION_MOD_SUMMARY = SRC.JUSTIFICATION_MOD_SUMMARY
                            , TRG.JUSTIFICATION_MODIFIER_NAME = SRC.JUSTIFICATION_MODIFIER_NAME
                            , TRG.JUSTIFICATION_MODIFIER_ID = SRC.JUSTIFICATION_MODIFIER_ID
                            , TRG.JUSTIFICATION_MODIFIED_DATE = SRC.JUSTIFICATION_MODIFIED_DATE
                            , TRG.TOTAL_CREDITABLE_YEARS = SRC.TOTAL_CREDITABLE_YEARS
                            , TRG.TOTAL_CREDITABLE_MONTHS = SRC.TOTAL_CREDITABLE_MONTHS
                            , TRG.APPROVER_NOTES = SRC.APPROVER_NOTES
                            , TRG.HRS_RVW_DATE_D = SRC.HRS_RVW_DATE_D
                            , TRG.APPROVAL_SO_RESP_DATE_D = SRC.APPROVAL_SO_RESP_DATE_D
                            , TRG.APPROVAL_DGHO_RESP_DATE_D = SRC.APPROVAL_DGHO_RESP_DATE_D
                            , TRG.APPROVAL_TABG_RESP_DATE_D = SRC.APPROVAL_TABG_RESP_DATE_D
                            , TRG.APPROVAL_COC_RESP_DATE_D = SRC.APPROVAL_COC_RESP_DATE_D
                            --, TRG.JUSTIFICATION_CRT_DATE_D = SRC.JUSTIFICATION_CRT_DATE_D
                            --, TRG.JUSTIFICATION_LASTMOD_DATE_D = SRC.JUSTIFICATION_LASTMOD_DATE_D
                            , TRG.JUSTIFICATION_MODIFIED_DATE_D = SRC.JUSTIFICATION_MODIFIED_DATE_D 
    			   ,TRG.DISAPPROVAL_REASON  = SRC.DISAPPROVAL_REASON
			   ,TRG.DISAPPROVAL_USER_NAME = SRC.DISAPPROVAL_USER_NAME
			   ,TRG.DISAPPROVAL_USER_ID = SRC.DISAPPROVAL_USER_ID

            WHEN NOT MATCHED THEN INSERT (
                            TRG.PROC_ID
                            , TRG.INIT_ANN_LA_RATE
                            , TRG.SUPPORT_LE
                            , TRG.PROPS_ANN_LA_RATE
                            , TRG.JUSTIFICATION_SKILL_EXP
                            , TRG.JUSTIFICATION_AGENCY_GOAL
                            , TRG.SELECTEE_ELIGIBILITY
                            , TRG.HRS_RVW_CERT
                            , TRG.HRS_NOT_SPT_RSN
                            , TRG.RVW_HRS
                            , TRG.HRS_RVW_DATE
                            , TRG.RCMD_LA_RATE
                            , TRG.APPROVAL_SO_VALUE
                            , TRG.APPROVAL_SO
                            , TRG.APPROVAL_SO_RESP_DATE
                            , TRG.APPROVAL_DGHO_VALUE
                            , TRG.APPROVAL_DGHO
                            , TRG.APPROVAL_DGHO_RESP_DATE
                            , TRG.APPROVAL_TABG_VALUE
                            , TRG.APPROVAL_TABG
                            , TRG.APPROVAL_TABG_RESP_DATE
                            , TRG.COC_NAME
                            , TRG.COC_EMAIL
                            , TRG.COC_ID
                            , TRG.COC_TITLE
                            , TRG.APPROVAL_COC_VALUE
                            , TRG.APPROVAL_COC_ACTING
                            , TRG.APPROVAL_COC
                            , TRG.APPROVAL_COC_RESP_DATE
                            , TRG.APPROVAL_SO_ACTING
                            , TRG.APPROVAL_DGHO_ACTING
                            , TRG.APPROVAL_TABG_ACTING
                            --, TRG.JUSTIFICATION_VER
                            --, TRG.JUSTIFICATION_CRT_NAME
                            --, TRG.JUSTIFICATION_CRT_ID
                            --, TRG.JUSTIFICATION_CRT_DATE
                            , TRG.JUSTIFICATION_LASTMOD_NAME
                            , TRG.JUSTIFICATION_LASTMOD_ID
                            --, TRG.JUSTIFICATION_LASTMOD_DATE
                            , TRG.JUSTIFICATION_MOD_REASON
                            , TRG.JUSTIFICATION_MOD_SUMMARY
                            , TRG.JUSTIFICATION_MODIFIER_NAME
                            , TRG.JUSTIFICATION_MODIFIER_ID
                            , TRG.JUSTIFICATION_MODIFIED_DATE
                            , TRG.TOTAL_CREDITABLE_YEARS
                            , TRG.TOTAL_CREDITABLE_MONTHS
                            , TRG.APPROVER_NOTES
                            , TRG.HRS_RVW_DATE_D
                            , TRG.APPROVAL_SO_RESP_DATE_D
                            , TRG.APPROVAL_DGHO_RESP_DATE_D
                            , TRG.APPROVAL_TABG_RESP_DATE_D
                            , TRG.APPROVAL_COC_RESP_DATE_D
                            --, TRG.JUSTIFICATION_CRT_DATE_D
                            --, TRG.JUSTIFICATION_LASTMOD_DATE_D
                            , TRG.JUSTIFICATION_MODIFIED_DATE_D
    			    ,TRG.DISAPPROVAL_REASON
			    ,TRG.DISAPPROVAL_USER_NAME
			    ,TRG.DISAPPROVAL_USER_ID

                        ) VALUES (
                            SRC.PROC_ID
                            , SRC.INIT_ANN_LA_RATE
                            , SRC.SUPPORT_LE
                            , SRC.PROPS_ANN_LA_RATE
                            , SRC.JUSTIFICATION_SKILL_EXP
                            , SRC.JUSTIFICATION_AGENCY_GOAL
                            , SRC.SELECTEE_ELIGIBILITY
                            , SRC.HRS_RVW_CERT
                            , SRC.HRS_NOT_SPT_RSN
                            , SRC.RVW_HRS
                            , SRC.HRS_RVW_DATE
                            , SRC.RCMD_LA_RATE
                            , SRC.APPROVAL_SO_VALUE
                            , SRC.APPROVAL_SO
                            , SRC.APPROVAL_SO_RESP_DATE
                            , SRC.APPROVAL_DGHO_VALUE
                            , SRC.APPROVAL_DGHO
                            , SRC.APPROVAL_DGHO_RESP_DATE
                            , SRC.APPROVAL_TABG_VALUE
                            , SRC.APPROVAL_TABG
                            , SRC.APPROVAL_TABG_RESP_DATE
                            , SRC.COC_NAME
                            , SRC.COC_EMAIL
                            , SRC.COC_ID
                            , SRC.COC_TITLE
                            , SRC.APPROVAL_COC_VALUE
                            , SRC.APPROVAL_COC_ACTING
                            , SRC.APPROVAL_COC
                            , SRC.APPROVAL_COC_RESP_DATE
                            , SRC.APPROVAL_SO_ACTING
                            , SRC.APPROVAL_DGHO_ACTING
                            , SRC.APPROVAL_TABG_ACTING
                            --, SRC.JUSTIFICATION_VER
                            --, SRC.JUSTIFICATION_CRT_NAME
                            --, SRC.JUSTIFICATION_CRT_ID
                            --, SRC.JUSTIFICATION_CRT_DATE
                            , SRC.JUSTIFICATION_LASTMOD_NAME
                            , SRC.JUSTIFICATION_LASTMOD_ID
                            --, SRC.JUSTIFICATION_LASTMOD_DATE
                            , SRC.JUSTIFICATION_MOD_REASON
                            , SRC.JUSTIFICATION_MOD_SUMMARY
                            , SRC.JUSTIFICATION_MODIFIER_NAME
                            , SRC.JUSTIFICATION_MODIFIER_ID
                            , SRC.JUSTIFICATION_MODIFIED_DATE
                            , SRC.TOTAL_CREDITABLE_YEARS
                            , SRC.TOTAL_CREDITABLE_MONTHS
                            , SRC.APPROVER_NOTES
                            , SRC.HRS_RVW_DATE_D
                            , SRC.APPROVAL_SO_RESP_DATE_D
                            , SRC.APPROVAL_DGHO_RESP_DATE_D
                            , SRC.APPROVAL_TABG_RESP_DATE_D
                            , SRC.APPROVAL_COC_RESP_DATE_D
                            --, SRC.JUSTIFICATION_CRT_DATE_D
                            --, SRC.JUSTIFICATION_LASTMOD_DATE_D
                            , SRC.JUSTIFICATION_MODIFIED_DATE_D
			    ,SRC.DISAPPROVAL_REASON
			   ,SRC.DISAPPROVAL_USER_NAME
			   ,SRC.DISAPPROVAL_USER_ID

                        );

			DELETE INCENTIVES_LE_CRED WHERE PROC_ID = I_PROCID;
			INSERT INTO INCENTIVES_LE_CRED(
                    PROC_ID
                    , SEQ_NUM
                    , START_DATE
                    , END_DATE
                    , WORK_SCHEDULE
                    , POS_TITLE
                    , CALCULATED_YEARS
                    , CALCULATED_MONTHS
                    , CREDITABLE_YEARS
                    , CREDITABLE_MONTHS)
            SELECT FD.PROCID
                    , x.SEQ_NUM
                    , x.START_DATE
                    , x.END_DATE
                    , x.WORK_SCHEDULE
                    , x.POS_TITLE
                    , NVL(x.CALCULATED_YEARS,0) AS CALCULATED_YEARS
                    , NVL(x.CALCULATED_MONTHS,0) AS CALCULATED_MONTHS
                    , NVL(x.CREDITABLE_YEARS,0) AS CREDITABLE_YEARS
                    , NVL(x.CREDITABLE_MONTHS,0) AS CREDITABLE_MONTHS
            FROM TBL_FORM_DTL FD,
             XMLTABLE('/formData/items/item[id="creditableNonFederalServices"]/value' PASSING FD.FIELD_DATA COLUMNS
                    SEQ_NUM FOR ORDINALITY,
                    START_DATE			VARCHAR2(10) PATH './startDate',
                    END_DATE			VARCHAR2(10) PATH './endDate',
                    WORK_SCHEDULE		VARCHAR2(15) PATH './workSchedule',
                    POS_TITLE			VARCHAR2(140) PATH './positionTitle',
                    CALCULATED_YEARS	NUMBER(10) PATH './calculatedTime/years',
                    CALCULATED_MONTHS	NUMBER(10) PATH './calculatedTime/months',
                    CREDITABLE_YEARS	NUMBER(10) PATH './creditableTime/years',
                    CREDITABLE_MONTHS	NUMBER(10) PATH './creditableTime/months'
            ) X
			WHERE FD.PROCID = I_PROCID;

        END IF;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION=' || SUBSTR(SQLERRM, 1, 200));
          --err_code := SQLCODE;
          --err_msg := SUBSTR(SQLERRM, 1, 200);    
    SP_ERROR_LOG();
  END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_LE_TABLE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_LE_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_LE_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_LE_TABLE TO BF_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_PV_INCENTIVES
	(
		  I_PROCID            IN      NUMBER
		, I_FIELD_DATA      IN      XMLTYPE
	)
IS
	V_XMLVALUE             XMLTYPE;
	V_INCENTIVE_TYPE     NVARCHAR2(50);

	V_DISAPPROVAL_CNT    NUMBER;
	V_APPROVAL_VALUE     NVARCHAR2(10);

	BEGIN
		--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
		--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
		--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
		--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
		--DBMS_OUTPUT.PUT_LINE(' ----------------');

		IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
			--DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

			--SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestNumber', '/formData/items/item[id="associatedNEILRequest"]/value/requestNumber/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestNumber', '/formData/items/item[id="requestNumber"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestDate', '/formData/items/item[id="requestDate"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'administrativeCode', '/formData/items/item[id="administrativeCode"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'associatedIncentives', '/formData/items/item[id="associatedIncentives"]/value/requestNumber/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'candidateName', '/formData/items/item[id="candidateName"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrSpecialist', '/formData/items/item[id="hrSpecialist"]/value/participantId/text()', '/formData/items/item[id="hrSpecialist"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'incentiveType', '/formData/items/item[id="incentiveType"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'payPlanSeriesGrade', '/formData/items/item[id="payPlanSeriesGrade"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'positionTitle', '/formData/items/item[id="positionTitle"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'componentUserIds', '/formData/items/item[id="componentUserIds"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'relatedUserIds', '/formData/items/item[id="relatedUserIds"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'selectingOfficial', '/formData/items/item[id="selectingOfficial"]/value/participantId/text()', '/formData/items/item[id="selectingOfficial"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'pcaType', '/formData/items/item[id="pcaType"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'candidateAccept', '/formData/items/item[id="candiAgreeRenewal"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requesterRole', '/formData/items/item[id="requesterRole"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'secondaryHrSpecialist', '/formData/items/item[id="hrSpecialist2"]/value/participantId/text()', '/formData/items/item[id="hrSpecialist2"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'staffingSpecialist', '/formData/items/item[id="staffingSpecialist"]/value/participantId/text()', '/formData/items/item[id="staffingSpecialist"]/value/name/text()');

			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'execOfficer', '/formData/items/item[id="executiveOfficers"]/value[1]/participantId/text()', '/formData/items/item[id="executiveOfficers"]/value[1]/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'execOfficer2', '/formData/items/item[id="executiveOfficers"]/value[2]/participantId/text()', '/formData/items/item[id="executiveOfficers"]/value[2]/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'execOfficer3', '/formData/items/item[id="executiveOfficers"]/value[3]/participantId/text()', '/formData/items/item[id="executiveOfficers"]/value[3]/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrLiaison', '/formData/items/item[id="hrLiaisons"]/value[1]/participantId/text()', '/formData/items/item[id="hrLiaisons"]/value[1]/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrLiaison2', '/formData/items/item[id="hrLiaisons"]/value[2]/participantId/text()', '/formData/items/item[id="hrLiaisons"]/value[2]/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrLiaison3', '/formData/items/item[id="hrLiaisons"]/value[3]/participantId/text()', '/formData/items/item[id="hrLiaisons"]/value[3]/name/text()');

			V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="incentiveType"]/value/text()');
			IF V_XMLVALUE IS NOT NULL THEN
				V_INCENTIVE_TYPE := V_XMLVALUE.GETSTRINGVAL();
			ELSE
				V_INCENTIVE_TYPE := NULL;
			END IF;

			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'oaApprovalReq', '/formData/items/item[id="requireAdminApproval"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcApprovalReq', '/formData/items/item[id="requireOHCApproval"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'dgoDirector', '/formData/items/item[id="dghoDirector"]/value/participantId/text()', '/formData/items/item[id="dghoDirector"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'chiefMedicalOfficer', '/formData/items/item[id="chiefPhysician"]/value/participantId/text()', '/formData/items/item[id="chiefPhysician"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ofmDirector', '/formData/items/item[id="ofmDirector"]/value/participantId/text()', '/formData/items/item[id="ofmDirector"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgDirector', '/formData/items/item[id="tabgDirector"]/value/participantId/text()', '/formData/items/item[id="tabgDirector"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ofcAdmin', '/formData/items/item[id="offAdmin"]/value/participantId/text()', '/formData/items/item[id="offAdmin"]/value/name/text()');

			IF 'PCA' = V_INCENTIVE_TYPE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcDirector', '/formData/items/item[id="ohcDirector"]/value/participantId/text()', '/formData/items/item[id="ohcDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'lengthServiceYear', '/formData/items/item[id="lengthOfService"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'approvedPCAAmount', '/formData/items/item[id="totalPayablePCACalculation"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cancellationReason', '/formData/items/item[id="cancellationReason"]/value/text()');
			ELSIF 'PDP' = V_INCENTIVE_TYPE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cancellationReason', '/formData/items/item[id="cancellationReason"]/value/text()');
                SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'proposedTotalAnnualCompAmount', '/formData/items/item[id="proposedPayInfoTotalAnnualComp"]/value/text()');

			ELSIF 'SAM' = V_INCENTIVE_TYPE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'samSupport', '/formData/items/item[id="supportSAM"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcDirector', '/formData/items/item[id="reviewRcmdApprovalOHCDirector"]/value/participantId/text()', '/formData/items/item[id="reviewRcmdApprovalOHCDirector"]/value/name/text()');
		                SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocApprove', '/formData/items/item[id="approvalCOCValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgdApprove', '/formData/items/item[id="approvalDGHOValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgApprove', '/formData/items/item[id="approvalTABGValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcApprove', '/formData/items/item[id="approvalOHCValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocDirector', '/formData/items/item[id="cocDirector"]/value/participantId/text()', '/formData/items/item[id="cocDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocDirectorName', '/formData/items/item[id="cocDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'selectingOfficialName', '/formData/items/item[id="selectingOfficial"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrSpecialistName', '/formData/items/item[id="hrSpecialist"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcDirectorName', '/formData/items/item[id="reviewRcmdApprovalOHCDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'rcmdGrade', '/formData/items/item[id="reviewRcmdGrade"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'rcmdStep', '/formData/items/item[id="reviewRcmdStep"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cancellationReason', '/formData/items/item[id="cancellationReason"]/value/text()');
		                SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapprovalReason', '/formData/items/item[id="disapprovalReason"]/value/text()');

				V_DISAPPROVAL_CNT := 0;
				IF V_DISAPPROVAL_CNT = 0 THEN
					V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="approvalSOValue"]/value/text()');
					IF V_XMLVALUE IS NOT NULL THEN
						V_APPROVAL_VALUE := V_XMLVALUE.GETSTRINGVAL();
						IF 'Disapprove' = V_APPROVAL_VALUE THEN
							SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '/formData/items/item[id="approvalSO"]/value/text()');
							V_DISAPPROVAL_CNT := 1;
						END IF;
					END IF;
				END IF;
				IF V_DISAPPROVAL_CNT = 0 THEN
					V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="approvalCOCValue"]/value/text()');
					IF V_XMLVALUE IS NOT NULL THEN
						V_APPROVAL_VALUE := V_XMLVALUE.GETSTRINGVAL();
						IF 'Disapprove' = V_APPROVAL_VALUE THEN
							SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '/formData/items/item[id="approvalCOC"]/value/text()');
							V_DISAPPROVAL_CNT := 1;
						END IF;
					END IF;
				END IF;
				IF V_DISAPPROVAL_CNT = 0 THEN
					V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="approvalDGHOValue"]/value/text()');
					IF V_XMLVALUE IS NOT NULL THEN
						V_APPROVAL_VALUE := V_XMLVALUE.GETSTRINGVAL();
						IF 'Disapprove' = V_APPROVAL_VALUE THEN
							SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '/formData/items/item[id="approvalDGHO"]/value/text()');
							V_DISAPPROVAL_CNT := 1;
						END IF;
					END IF;
				END IF;
				IF V_DISAPPROVAL_CNT = 0 THEN
					V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="approvalTABGValue"]/value/text()');
					IF V_XMLVALUE IS NOT NULL THEN
						V_APPROVAL_VALUE := V_XMLVALUE.GETSTRINGVAL();
						IF 'Disapprove' = V_APPROVAL_VALUE THEN
							SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '/formData/items/item[id="approvalTABG"]/value/text()');
							V_DISAPPROVAL_CNT := 1;
						END IF;
					END IF;
				END IF;
				IF V_DISAPPROVAL_CNT = 0 THEN
					V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="approvalOHCValue"]/value/text()');
					IF V_XMLVALUE IS NOT NULL THEN
						V_APPROVAL_VALUE := V_XMLVALUE.GETSTRINGVAL();
						IF 'Disapprove' = V_APPROVAL_VALUE THEN
							SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '/formData/items/item[id="approvalOHC"]/value/text()');
							V_DISAPPROVAL_CNT := 1;
						END IF;
					END IF;
				END IF;
				IF V_DISAPPROVAL_CNT = 0 THEN
					SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '');
				END IF;
			ELSIF 'LE' = V_INCENTIVE_TYPE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'leSupport', '/formData/items/item[id="supportLE"]/value/text()');
		                SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocApprove', '/formData/items/item[id="leApprovalCOCValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgdApprove', '/formData/items/item[id="leApprovalDGHOValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgApprove', '/formData/items/item[id="leApprovalTABGValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocDirector', '/formData/items/item[id="lecocDirector"]/value/participantId/text()', '/formData/items/item[id="lecocDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocDirectorName', '/formData/items/item[id="lecocDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'selectingOfficialName', '/formData/items/item[id="selectingOfficial"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrSpecialistName', '/formData/items/item[id="hrSpecialist"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'annualLeaveAccrualRate', '/formData/items/item[id="rcmdAnnualLeaveAccrualRate"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cancellationReason', '/formData/items/item[id="cancellationReason"]/value/text()');
		                SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapprovalReason', '/formData/items/item[id="disapprovalReason"]/value/text()');

				V_DISAPPROVAL_CNT := 0;
				IF V_DISAPPROVAL_CNT = 0 THEN
					V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="leApprovalSOValue"]/value/text()');
					IF V_XMLVALUE IS NOT NULL THEN
						V_APPROVAL_VALUE := V_XMLVALUE.GETSTRINGVAL();
						IF 'Disapprove' = V_APPROVAL_VALUE THEN
							SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '/formData/items/item[id="leApprovalSO"]/value/text()');
							V_DISAPPROVAL_CNT := 1;
						END IF;
					END IF;
				END IF;
				IF V_DISAPPROVAL_CNT = 0 THEN
					V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="leApprovalCOCValue"]/value/text()');
					IF V_XMLVALUE IS NOT NULL THEN
						V_APPROVAL_VALUE := V_XMLVALUE.GETSTRINGVAL();
						IF 'Disapprove' = V_APPROVAL_VALUE THEN
							SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '/formData/items/item[id="leApprovalCOC"]/value/text()');
							V_DISAPPROVAL_CNT := 1;
						END IF;
					END IF;
				END IF;
				IF V_DISAPPROVAL_CNT = 0 THEN
					V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="leApprovalDGHOValue"]/value/text()');
					IF V_XMLVALUE IS NOT NULL THEN
						V_APPROVAL_VALUE := V_XMLVALUE.GETSTRINGVAL();
						IF 'Disapprove' = V_APPROVAL_VALUE THEN
							SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '/formData/items/item[id="leApprovalDGHO"]/value/text()');
							V_DISAPPROVAL_CNT := 1;
						END IF;
					END IF;
				END IF;
				IF V_DISAPPROVAL_CNT = 0 THEN
					V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="leApprovalTABGValue"]/value/text()');
					IF V_XMLVALUE IS NOT NULL THEN
						V_APPROVAL_VALUE := V_XMLVALUE.GETSTRINGVAL();
						IF 'Disapprove' = V_APPROVAL_VALUE THEN
							SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '/formData/items/item[id="leApprovalTABG"]/value/text()');
							V_DISAPPROVAL_CNT := 1;
						END IF;
					END IF;
				END IF;
				IF V_DISAPPROVAL_CNT = 0 THEN
					SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'disapproverName', '');
				END IF;
			END IF;

		--DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

		END IF;

		EXCEPTION
		WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_INCENTIVES -------------------');
	END;
/
-- End of SP_UPDATE_PV_INCENTIVES
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_INCENTIVES TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_INCENTIVES TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_PV_INCENTIVES TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_INCENTIVES_PCA_TABLE
  (
    I_PROCID            IN      NUMBER
  )
IS
    V_XMLREC_CNT                INTEGER := 0;
BEGIN

    --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_INCENTIVES_LE_TBL2');
    --DBMS_OUTPUT.PUT_LINE('I_PROCID=' || TO_CHAR(I_PROCID));
	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN

        SELECT COUNT(*)
          INTO V_XMLREC_CNT
          FROM TBL_FORM_DTL
         WHERE PROCID = I_PROCID;
        
        IF V_XMLREC_CNT > 0 THEN
			--DBMS_OUTPUT.PUT_LINE('RECORD FOUND PROCID=' || TO_CHAR(I_PROCID));
            
			MERGE INTO INCENTIVES_PCA TRG
			USING
			(
                     SELECT FD.PROCID AS PROC_ID
                            , X.PCA_TYPE
                            , X.CANDI_AGREE
                            , X.CP_NAME
                            , X.CP_EMAIL
                            , X.CP_ID
                            , X.OFM_NAME
                            , X.OFM_EMAIL
                            , X.OFM_ID
                            , X.ADMIN_APPROVAL_REQ
                            , X.OHC_NAME
                            , X.OHC_EMAIL
                            , X.OHC_ID
                            , X.OADMIN_NAME
                            , X.OADMIN_EMAIL
                            , X.OADMIN_ID
                            , X.WORK_SCHEDULE
                            , X.HOURS_PER_WEEK
                            , X.BD_CERT_REQ
                            , X.LIC_INFO
                            , X.LIC_STATE1_STATE
                            , X.LIC_STATE1_NAME
                            , X.LIC_STATE1_EXP_DATE
                            , X.LIC_STATE2_STATE
                            , X.LIC_STATE2_NAME
                            , X.LIC_STATE2_EXP_DATE
                            , X.BD_CERT_SPEC1
                            , X.BD_CERT_SPEC2
                            , X.BD_CERT_SPEC3
                            , X.BD_CERT_SPEC4
                            , X.BD_CERT_SPEC5
                            , X.BD_CERT_SPEC6
                            , X.BD_CERT_SPEC7
                            , X.BD_CERT_SPEC8
                            , X.BD_CERT_SPEC9
                            , X.BD_CERT_SPEC_OTHER
                            , X.LEN_SERVED
                            , X.LEN_SERVICE
                            , X.ALW_CATEGORY
                            , X.ALW_BD_CERT
                            , X.ALW_MULTI_YEAR_AGMT
                            , X.ALW_MISSION_SC
                            , X.ALW_TOTAL
                            , X.ALW_TOTAL_PAYABLE
                            , X.DETAIL_REMARKS
                            , X.RVW_SO_NAME
                            , X.RVW_SO_ID
                            , X.RVW_SO_DATE
                            , X.RVW_DGHO_NAME
                            , X.RVW_DGHO_ID
                            , X.RVW_DGHO_DATE
                            , X.RVW_CP_NAME
                            , X.RVW_CP_ID
                            , X.RVW_CP_DATE
                            , X.RVW_OFM_NAME
                            , X.RVW_OFM_ID
                            , X.RVW_OFM_DATE
                            , X.RVW_TABG_NAME
                            , X.RVW_TABG_ID
                            , X.RVW_TABG_DATE
                            , X.RVW_OHC_NAME
                            , X.RVW_OHC_ID
                            , X.RVW_OHC_DATE
                            , X.APPROVAL_TABG_NAME
                            , X.APPROVAL_TABG_ID
                            , X.APPROVAL_TABG_DATE
                            , X.APPROVAL_OADMIN_NAME
                            , X.APPROVAL_OADMIN_ID
                            , X.APPROVAL_OADMIN_DATE
                            -- new columsn for data type fixes
                            , TO_DATE(regexp_replace(X."LIC_STATE1_EXP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as LIC_STATE1_EXP_DATE_D
                            , TO_DATE(regexp_replace(X."LIC_STATE2_EXP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as LIC_STATE2_EXP_DATE_D
                            , regexp_replace(X."ALW_CATEGORY", '[^0-9|.]', '') as ALW_CATEGORY_N
                            , regexp_replace(X."ALW_BD_CERT", '[^0-9|.]', '') as ALW_BD_CERT_N
                            , regexp_replace(X."ALW_MULTI_YEAR_AGMT", '[^0-9|.]', '') as ALW_MULTI_YEAR_AGMT_N
                            , regexp_replace(X."ALW_MISSION_SC", '[^0-9|.]', '') as ALW_MISSION_SC_N
                            , regexp_replace(X."ALW_TOTAL", '[^0-9|.]', '') as ALW_TOTAL_N
                            , regexp_replace(X."ALW_TOTAL_PAYABLE", '[^0-9|.]', '') as ALW_TOTAL_PAYABLE_N
                            , TO_DATE(regexp_replace(X."RVW_SO_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_SO_DATE_D
                            , TO_DATE(regexp_replace(X."RVW_DGHO_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_DGHO_DATE_D
                            , TO_DATE(regexp_replace(X."RVW_CP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_CP_DATE_D
                            , TO_DATE(regexp_replace(X."RVW_OFM_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_OFM_DATE_D
                            , TO_DATE(regexp_replace(X."RVW_TABG_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_TABG_DATE_D
                            , TO_DATE(regexp_replace(X."RVW_OHC_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_OHC_DATE_D
                            , TO_DATE(regexp_replace(X."APPROVAL_TABG_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_TABG_DATE_D
                            , TO_DATE(regexp_replace(X."APPROVAL_OADMIN_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_OADMIN_DATE_D
                            
                    FROM TBL_FORM_DTL FD,
                         XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
                        PCA_TYPE VARCHAR2(10) PATH './item[id="pcaType"]/value'
                        , CANDI_AGREE VARCHAR2(5) PATH './item[id="candiAgreeRenewal"]/value'
                        -- Chief Physician
                        , CP_NAME VARCHAR2(100) PATH './item[id="chiefPhysician"]/value/name'
                        , CP_EMAIL VARCHAR2(100) PATH './item[id="chiefPhysician"]/value/email'
                        , CP_ID VARCHAR2(10) PATH './item[id="chiefPhysician"]/value/id'
                        -- OFM Director
                        , OFM_NAME VARCHAR2(100) PATH './item[id="ofmDirector"]/value/name'
                        , OFM_EMAIL VARCHAR2(100) PATH './item[id="ofmDirector"]/value/email'
                        , OFM_ID VARCHAR2(10) PATH './item[id="ofmDirector"]/value/id'
                        -- Does the PCA require the Office of the Administrator approval?
                        , ADMIN_APPROVAL_REQ VARCHAR2(5) PATH './item[id="requireAdminApproval"]/value'
                        -- OHC Director
                        , OHC_NAME VARCHAR2(100) PATH './item[id="ohcDirector"]/value/name'
                        , OHC_EMAIL VARCHAR2(100) PATH './item[id="ohcDirector"]/value/email'
                        , OHC_ID VARCHAR2(10) PATH './item[id="ohcDirector"]/value/id'
                        -- Administrator
                        , OADMIN_NAME VARCHAR2(100) PATH './item[id="offAdmin"]/value/name'
                        , OADMIN_EMAIL VARCHAR2(100) PATH './item[id="offAdmin"]/value/email'
                        , OADMIN_ID VARCHAR2(10) PATH './item[id="offAdmin"]/value/id'
                        -- Position
                        , WORK_SCHEDULE VARCHAR2(15) PATH './item[id="workSchedule"]/value'
                        , HOURS_PER_WEEK VARCHAR2(5) PATH './item[id="hoursPerWeek"]/value'
                        , BD_CERT_REQ VARCHAR2(5) PATH './item[id="requireBoardCert"]/value'
                        , LIC_INFO VARCHAR2(140) PATH './item[id="licenseInfo"]/value'
                        -- licenseState
                        , LIC_STATE1_STATE VARCHAR2(2) PATH './item[id="licenseState"]/value[1]/state'
                        , LIC_STATE1_NAME VARCHAR2(50) PATH './item[id="licenseState"]/value[1]/name'
                        , LIC_STATE1_EXP_DATE VARCHAR2(10) PATH './item[id="licenseState"]/value[1]/expDate'
                        , LIC_STATE2_STATE VARCHAR2(2) PATH './item[id="licenseState"]/value[2]/state'
                        , LIC_STATE2_NAME VARCHAR2(50) PATH './item[id="licenseState"]/value[2]/name'
                        , LIC_STATE2_EXP_DATE VARCHAR2(10) PATH './item[id="licenseState"]/value[2]/expDate'
                        -- boardCertSpecialty
                        , BD_CERT_SPEC1 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[1]/text'
                        , BD_CERT_SPEC2 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[2]/text'
                        , BD_CERT_SPEC3 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[3]/text'
                        , BD_CERT_SPEC4 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[4]/text'
                        , BD_CERT_SPEC5 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[5]/text'
                        , BD_CERT_SPEC6 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[6]/text'
                        , BD_CERT_SPEC7 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[7]/text'
                        , BD_CERT_SPEC8 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[8]/text'
                        , BD_CERT_SPEC9 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[9]/text'
                        , BD_CERT_SPEC_OTHER VARCHAR2(140) PATH './item[id="otherSpeciality"]/value'
                        -- allowance
                        , LEN_SERVED VARCHAR2(25) PATH './item[id="lengthOfServed"]/value'
                        , LEN_SERVICE VARCHAR2(2) PATH './item[id="lengthOfService"]/value'
                        , ALW_CATEGORY VARCHAR2(15) PATH './item[id="allowanceCategory"]/value'
                        , ALW_BD_CERT VARCHAR2(15) PATH './item[id="allowanceBoardCertification"]/value'
                        , ALW_MULTI_YEAR_AGMT VARCHAR2(15) PATH './item[id="allowanceMultiYearAgreement"]/value'
                        , ALW_MISSION_SC VARCHAR2(15) PATH './item[id="allowanceMissionSpecificCriteria"]/value'
                        , ALW_TOTAL VARCHAR2(15) PATH './item[id="allowanceTotal"]/value'
                        , ALW_TOTAL_PAYABLE VARCHAR2(15) PATH './item[id="totalPayablePCACalculation"]/value'
                        -- remarks
                        , DETAIL_REMARKS VARCHAR2(500) PATH './item[id="detailRemarks"]/value'
                        -- Review
                        , RVW_SO_NAME VARCHAR2(100) PATH './item[id="reviewSO"]/value'
                        , RVW_SO_ID VARCHAR2(10) PATH './item[id="reviewSOId"]/value'
                        , RVW_SO_DATE VARCHAR2(10) PATH './item[id="reviewSODate"]/value'
                        , RVW_DGHO_NAME VARCHAR2(100) PATH './item[id="reviewDGHO"]/value'
                        , RVW_DGHO_ID VARCHAR2(10) PATH './item[id="reviewDGHOId"]/value'
                        , RVW_DGHO_DATE VARCHAR2(10) PATH './item[id="reviewDGHODate"]/value'
                        , RVW_CP_NAME VARCHAR2(100) PATH './item[id="reviewCP"]/value'
                        , RVW_CP_ID VARCHAR2(10) PATH './item[id="reviewCPId"]/value'
                        , RVW_CP_DATE VARCHAR2(10) PATH './item[id="reviewCPDate"]/value'
                        , RVW_OFM_NAME VARCHAR2(100) PATH './item[id="reviewOFM"]/value'
                        , RVW_OFM_ID VARCHAR2(10) PATH './item[id="reviewOFMId"]/value'
                        , RVW_OFM_DATE VARCHAR2(10) PATH './item[id="reviewOFMDate"]/value'
                        , RVW_TABG_NAME VARCHAR2(100) PATH './item[id="reviewTABG"]/value'
                        , RVW_TABG_ID VARCHAR2(10) PATH './item[id="reviewTABGId"]/value'
                        , RVW_TABG_DATE VARCHAR2(10) PATH './item[id="reviewTABGDate"]/value'
                        , RVW_OHC_NAME VARCHAR2(100) PATH './item[id="reviewOHC"]/value'
                        , RVW_OHC_ID VARCHAR2(10) PATH './item[id="reviewOHCId"]/value'
                        , RVW_OHC_DATE VARCHAR2(10) PATH './item[id="reviewOHCDate"]/value'
                        -- Approvals
                        , APPROVAL_TABG_NAME VARCHAR2(100) PATH './item[id="pcaApproveTABG"]/value'
                        , APPROVAL_TABG_ID VARCHAR2(10) PATH './item[id="pcaApproveTABGId"]/value'
                        , APPROVAL_TABG_DATE VARCHAR2(10) PATH './item[id="pcaApproveTABGDate"]/value'
                        , APPROVAL_OADMIN_NAME VARCHAR2(100) PATH './item[id="pcaApproveADM"]/value'
                        , APPROVAL_OADMIN_ID VARCHAR2(10) PATH './item[id="pcaApproveADMId"]/value'
                        , APPROVAL_OADMIN_DATE VARCHAR2(10) PATH './item[id="pcaApproveADMDate"]/value'
                        ) X
                    WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.PROC_ID = TRG.PROC_ID)
            WHEN MATCHED THEN UPDATE SET
                        TRG.PCA_TYPE = SRC.PCA_TYPE
                        ,TRG.CANDI_AGREE = SRC.CANDI_AGREE
                        ,TRG.CP_NAME = SRC.CP_NAME
                        ,TRG.CP_EMAIL = SRC.CP_EMAIL
                        ,TRG.CP_ID = SRC.CP_ID
                        ,TRG.OFM_NAME = SRC.OFM_NAME
                        ,TRG.OFM_EMAIL = SRC.OFM_EMAIL
                        ,TRG.OFM_ID = SRC.OFM_ID
                        ,TRG.ADMIN_APPROVAL_REQ = SRC.ADMIN_APPROVAL_REQ
                        ,TRG.OHC_NAME = SRC.OHC_NAME
                        ,TRG.OHC_EMAIL = SRC.OHC_EMAIL
                        ,TRG.OHC_ID = SRC.OHC_ID
                        ,TRG.OADMIN_NAME = SRC.OADMIN_NAME
                        ,TRG.OADMIN_EMAIL = SRC.OADMIN_EMAIL
                        ,TRG.OADMIN_ID = SRC.OADMIN_ID
                        ,TRG.WORK_SCHEDULE = SRC.WORK_SCHEDULE
                        ,TRG.HOURS_PER_WEEK = SRC.HOURS_PER_WEEK
                        ,TRG.BD_CERT_REQ = SRC.BD_CERT_REQ
                        ,TRG.LIC_INFO = SRC.LIC_INFO
                        ,TRG.LIC_STATE1_STATE = SRC.LIC_STATE1_STATE
                        ,TRG.LIC_STATE1_NAME = SRC.LIC_STATE1_NAME
                        ,TRG.LIC_STATE1_EXP_DATE = SRC.LIC_STATE1_EXP_DATE
                        ,TRG.LIC_STATE2_STATE = SRC.LIC_STATE2_STATE
                        ,TRG.LIC_STATE2_NAME = SRC.LIC_STATE2_NAME
                        ,TRG.LIC_STATE2_EXP_DATE = SRC.LIC_STATE2_EXP_DATE
                        ,TRG.BD_CERT_SPEC1 = SRC.BD_CERT_SPEC1
                        ,TRG.BD_CERT_SPEC2 = SRC.BD_CERT_SPEC2
                        ,TRG.BD_CERT_SPEC3 = SRC.BD_CERT_SPEC3
                        ,TRG.BD_CERT_SPEC4 = SRC.BD_CERT_SPEC4
                        ,TRG.BD_CERT_SPEC5 = SRC.BD_CERT_SPEC5
                        ,TRG.BD_CERT_SPEC6 = SRC.BD_CERT_SPEC6
                        ,TRG.BD_CERT_SPEC7 = SRC.BD_CERT_SPEC7
                        ,TRG.BD_CERT_SPEC8 = SRC.BD_CERT_SPEC8
                        ,TRG.BD_CERT_SPEC9 = SRC.BD_CERT_SPEC9
                        ,TRG.BD_CERT_SPEC_OTHER = SRC.BD_CERT_SPEC_OTHER
                        ,TRG.LEN_SERVED = SRC.LEN_SERVED
                        ,TRG.LEN_SERVICE = SRC.LEN_SERVICE
                        ,TRG.ALW_CATEGORY = SRC.ALW_CATEGORY
                        ,TRG.ALW_BD_CERT = SRC.ALW_BD_CERT
                        ,TRG.ALW_MULTI_YEAR_AGMT = SRC.ALW_MULTI_YEAR_AGMT
                        ,TRG.ALW_MISSION_SC = SRC.ALW_MISSION_SC
                        ,TRG.ALW_TOTAL = SRC.ALW_TOTAL
                        ,TRG.ALW_TOTAL_PAYABLE = SRC.ALW_TOTAL_PAYABLE
                        ,TRG.DETAIL_REMARKS = SRC.DETAIL_REMARKS
                        ,TRG.RVW_SO_NAME = SRC.RVW_SO_NAME
                        ,TRG.RVW_SO_ID = SRC.RVW_SO_ID
                        ,TRG.RVW_SO_DATE = SRC.RVW_SO_DATE
                        ,TRG.RVW_DGHO_NAME = SRC.RVW_DGHO_NAME
                        ,TRG.RVW_DGHO_ID = SRC.RVW_DGHO_ID
                        ,TRG.RVW_DGHO_DATE = SRC.RVW_DGHO_DATE
                        ,TRG.RVW_CP_NAME = SRC.RVW_CP_NAME
                        ,TRG.RVW_CP_ID = SRC.RVW_CP_ID
                        ,TRG.RVW_CP_DATE = SRC.RVW_CP_DATE
                        ,TRG.RVW_OFM_NAME = SRC.RVW_OFM_NAME
                        ,TRG.RVW_OFM_ID = SRC.RVW_OFM_ID
                        ,TRG.RVW_OFM_DATE = SRC.RVW_OFM_DATE
                        ,TRG.RVW_TABG_NAME = SRC.RVW_TABG_NAME
                        ,TRG.RVW_TABG_ID = SRC.RVW_TABG_ID
                        ,TRG.RVW_TABG_DATE = SRC.RVW_TABG_DATE
                        ,TRG.RVW_OHC_NAME = SRC.RVW_OHC_NAME
                        ,TRG.RVW_OHC_ID = SRC.RVW_OHC_ID
                        ,TRG.RVW_OHC_DATE = SRC.RVW_OHC_DATE
                        ,TRG.APPROVAL_TABG_NAME = SRC.APPROVAL_TABG_NAME
                        ,TRG.APPROVAL_TABG_ID = SRC.APPROVAL_TABG_ID
                        ,TRG.APPROVAL_TABG_DATE = SRC.APPROVAL_TABG_DATE
                        ,TRG.APPROVAL_OADMIN_NAME = SRC.APPROVAL_OADMIN_NAME
                        ,TRG.APPROVAL_OADMIN_ID = SRC.APPROVAL_OADMIN_ID
                        ,TRG.APPROVAL_OADMIN_DATE = SRC.APPROVAL_OADMIN_DATE
                        ------------
                        ,TRG.LIC_STATE1_EXP_DATE_D = SRC.LIC_STATE1_EXP_DATE_D
                        ,TRG.LIC_STATE2_EXP_DATE_D = SRC.LIC_STATE2_EXP_DATE_D
                        ,TRG.ALW_CATEGORY_N = SRC.ALW_CATEGORY_N
                        ,TRG.ALW_BD_CERT_N = SRC.ALW_BD_CERT_N
                        ,TRG.ALW_MULTI_YEAR_AGMT_N = SRC.ALW_MULTI_YEAR_AGMT_N
                        ,TRG.ALW_MISSION_SC_N = SRC.ALW_MISSION_SC_N
                        ,TRG.ALW_TOTAL_N = SRC.ALW_TOTAL_N
                        ,TRG.ALW_TOTAL_PAYABLE_N = SRC.ALW_TOTAL_PAYABLE_N
                        ,TRG.RVW_SO_DATE_D = SRC.RVW_SO_DATE_D
                        ,TRG.RVW_DGHO_DATE_D = SRC.RVW_DGHO_DATE_D
                        ,TRG.RVW_CP_DATE_D = SRC.RVW_CP_DATE_D
                        ,TRG.RVW_OFM_DATE_D = SRC.RVW_OFM_DATE_D
                        ,TRG.RVW_TABG_DATE_D = SRC.RVW_TABG_DATE_D
                        ,TRG.RVW_OHC_DATE_D = SRC.RVW_OHC_DATE_D
                        ,TRG.APPROVAL_TABG_DATE_D = SRC.APPROVAL_TABG_DATE_D
                        ,TRG.APPROVAL_OADMIN_DATE_D = SRC.APPROVAL_OADMIN_DATE_D                  
            WHEN NOT MATCHED THEN INSERT (
                            TRG.PROC_ID
                            ,TRG.PCA_TYPE
                            ,TRG.CANDI_AGREE
                            ,TRG.CP_NAME
                            ,TRG.CP_EMAIL
                            ,TRG.CP_ID
                            ,TRG.OFM_NAME
                            ,TRG.OFM_EMAIL
                            ,TRG.OFM_ID
                            ,TRG.ADMIN_APPROVAL_REQ
                            ,TRG.OHC_NAME
                            ,TRG.OHC_EMAIL
                            ,TRG.OHC_ID
                            ,TRG.OADMIN_NAME
                            ,TRG.OADMIN_EMAIL
                            ,TRG.OADMIN_ID
                            ,TRG.WORK_SCHEDULE
                            ,TRG.HOURS_PER_WEEK
                            ,TRG.BD_CERT_REQ
                            ,TRG.LIC_INFO
                            ,TRG.LIC_STATE1_STATE
                            ,TRG.LIC_STATE1_NAME
                            ,TRG.LIC_STATE1_EXP_DATE
                            ,TRG.LIC_STATE2_STATE
                            ,TRG.LIC_STATE2_NAME
                            ,TRG.LIC_STATE2_EXP_DATE
                            ,TRG.BD_CERT_SPEC1
                            ,TRG.BD_CERT_SPEC2
                            ,TRG.BD_CERT_SPEC3
                            ,TRG.BD_CERT_SPEC4
                            ,TRG.BD_CERT_SPEC5
                            ,TRG.BD_CERT_SPEC6
                            ,TRG.BD_CERT_SPEC7
                            ,TRG.BD_CERT_SPEC8
                            ,TRG.BD_CERT_SPEC9
                            ,TRG.BD_CERT_SPEC_OTHER
                            ,TRG.LEN_SERVED
                            ,TRG.LEN_SERVICE
                            ,TRG.ALW_CATEGORY
                            ,TRG.ALW_BD_CERT
                            ,TRG.ALW_MULTI_YEAR_AGMT
                            ,TRG.ALW_MISSION_SC
                            ,TRG.ALW_TOTAL
                            ,TRG.ALW_TOTAL_PAYABLE
                            ,TRG.DETAIL_REMARKS
                            ,TRG.RVW_SO_NAME
                            ,TRG.RVW_SO_ID
                            ,TRG.RVW_SO_DATE
                            ,TRG.RVW_DGHO_NAME
                            ,TRG.RVW_DGHO_ID
                            ,TRG.RVW_DGHO_DATE
                            ,TRG.RVW_CP_NAME
                            ,TRG.RVW_CP_ID
                            ,TRG.RVW_CP_DATE
                            ,TRG.RVW_OFM_NAME
                            ,TRG.RVW_OFM_ID
                            ,TRG.RVW_OFM_DATE
                            ,TRG.RVW_TABG_NAME
                            ,TRG.RVW_TABG_ID
                            ,TRG.RVW_TABG_DATE
                            ,TRG.RVW_OHC_NAME
                            ,TRG.RVW_OHC_ID
                            ,TRG.RVW_OHC_DATE
                            ,TRG.APPROVAL_TABG_NAME
                            ,TRG.APPROVAL_TABG_ID
                            ,TRG.APPROVAL_TABG_DATE
                            ,TRG.APPROVAL_OADMIN_NAME
                            ,TRG.APPROVAL_OADMIN_ID
                            ,TRG.APPROVAL_OADMIN_DATE
                            ----------
                            ,TRG.LIC_STATE1_EXP_DATE_D
                            ,TRG.LIC_STATE2_EXP_DATE_D
                            ,TRG.ALW_CATEGORY_N
                            ,TRG.ALW_BD_CERT_N
                            ,TRG.ALW_MULTI_YEAR_AGMT_N
                            ,TRG.ALW_MISSION_SC_N
                            ,TRG.ALW_TOTAL_N
                            ,TRG.ALW_TOTAL_PAYABLE_N
                            ,TRG.RVW_SO_DATE_D
                            ,TRG.RVW_DGHO_DATE_D
                            ,TRG.RVW_CP_DATE_D
                            ,TRG.RVW_OFM_DATE_D
                            ,TRG.RVW_TABG_DATE_D
                            ,TRG.RVW_OHC_DATE_D
                            ,TRG.APPROVAL_TABG_DATE_D
                            ,TRG.APPROVAL_OADMIN_DATE_D                             
                        ) VALUES (
                            SRC.PROC_ID
                            ,SRC.PCA_TYPE
                            ,SRC.CANDI_AGREE
                            ,SRC.CP_NAME
                            ,SRC.CP_EMAIL
                            ,SRC.CP_ID
                            ,SRC.OFM_NAME
                            ,SRC.OFM_EMAIL
                            ,SRC.OFM_ID
                            ,SRC.ADMIN_APPROVAL_REQ
                            ,SRC.OHC_NAME
                            ,SRC.OHC_EMAIL
                            ,SRC.OHC_ID
                            ,SRC.OADMIN_NAME
                            ,SRC.OADMIN_EMAIL
                            ,SRC.OADMIN_ID
                            ,SRC.WORK_SCHEDULE
                            ,SRC.HOURS_PER_WEEK
                            ,SRC.BD_CERT_REQ
                            ,SRC.LIC_INFO
                            ,SRC.LIC_STATE1_STATE
                            ,SRC.LIC_STATE1_NAME
                            ,SRC.LIC_STATE1_EXP_DATE
                            ,SRC.LIC_STATE2_STATE
                            ,SRC.LIC_STATE2_NAME
                            ,SRC.LIC_STATE2_EXP_DATE
                            ,SRC.BD_CERT_SPEC1
                            ,SRC.BD_CERT_SPEC2
                            ,SRC.BD_CERT_SPEC3
                            ,SRC.BD_CERT_SPEC4
                            ,SRC.BD_CERT_SPEC5
                            ,SRC.BD_CERT_SPEC6
                            ,SRC.BD_CERT_SPEC7
                            ,SRC.BD_CERT_SPEC8
                            ,SRC.BD_CERT_SPEC9
                            ,SRC.BD_CERT_SPEC_OTHER
                            ,SRC.LEN_SERVED
                            ,SRC.LEN_SERVICE
                            ,SRC.ALW_CATEGORY
                            ,SRC.ALW_BD_CERT
                            ,SRC.ALW_MULTI_YEAR_AGMT
                            ,SRC.ALW_MISSION_SC
                            ,SRC.ALW_TOTAL
                            ,SRC.ALW_TOTAL_PAYABLE
                            ,SRC.DETAIL_REMARKS
                            ,SRC.RVW_SO_NAME
                            ,SRC.RVW_SO_ID
                            ,SRC.RVW_SO_DATE
                            ,SRC.RVW_DGHO_NAME
                            ,SRC.RVW_DGHO_ID
                            ,SRC.RVW_DGHO_DATE
                            ,SRC.RVW_CP_NAME
                            ,SRC.RVW_CP_ID
                            ,SRC.RVW_CP_DATE
                            ,SRC.RVW_OFM_NAME
                            ,SRC.RVW_OFM_ID
                            ,SRC.RVW_OFM_DATE
                            ,SRC.RVW_TABG_NAME
                            ,SRC.RVW_TABG_ID
                            ,SRC.RVW_TABG_DATE
                            ,SRC.RVW_OHC_NAME
                            ,SRC.RVW_OHC_ID
                            ,SRC.RVW_OHC_DATE
                            ,SRC.APPROVAL_TABG_NAME
                            ,SRC.APPROVAL_TABG_ID
                            ,SRC.APPROVAL_TABG_DATE
                            ,SRC.APPROVAL_OADMIN_NAME
                            ,SRC.APPROVAL_OADMIN_ID
                            ,SRC.APPROVAL_OADMIN_DATE
                            ----------
                            ,SRC.LIC_STATE1_EXP_DATE_D
                            ,SRC.LIC_STATE2_EXP_DATE_D
                            ,SRC.ALW_CATEGORY_N
                            ,SRC.ALW_BD_CERT_N
                            ,SRC.ALW_MULTI_YEAR_AGMT_N
                            ,SRC.ALW_MISSION_SC_N
                            ,SRC.ALW_TOTAL_N
                            ,SRC.ALW_TOTAL_PAYABLE_N
                            ,SRC.RVW_SO_DATE_D
                            ,SRC.RVW_DGHO_DATE_D
                            ,SRC.RVW_CP_DATE_D
                            ,SRC.RVW_OFM_DATE_D
                            ,SRC.RVW_TABG_DATE_D
                            ,SRC.RVW_OHC_DATE_D
                            ,SRC.APPROVAL_TABG_DATE_D
                            ,SRC.APPROVAL_OADMIN_DATE_D                       
                        );
        END IF;

    END IF;
        
    EXCEPTION
    WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION=' || SUBSTR(SQLERRM, 1, 200));
          --err_code := SQLCODE;
          --err_msg := SUBSTR(SQLERRM, 1, 200);    
    SP_ERROR_LOG();
  END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_PCA_TABLE TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_PCA_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_PCA_TABLE TO HHS_CMS_HR_DEV_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_PCA_TABLE TO BF_DEV_ROLE;
/

create or replace PROCEDURE SP_INIT_INCENTIVES
(
    I_INCENTIVE_TYPE       IN VARCHAR2, -- SAM, LE, PCA, PDP
    I_PROCID               IN NUMBER
)
IS
    V_PARENT_PROCID        NUMBER(10);
    V_XMLDOC               XMLTYPE;
    V_CNT                  INT;
BEGIN

    BEGIN
        SELECT TO_NUMBER(VALUE)
          INTO V_PARENT_PROCID
          FROM BIZFLOW.RLVNTDATA
         WHERE PROCID = I_PROCID
           AND RLVNTDATANAME = 'parentProcId';
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        V_PARENT_PROCID := NULL;
    END;
    
    SELECT COUNT(*)
      INTO V_CNT
      FROM TBL_FORM_DTL
     WHERE PROCID = I_PROCID;
    
    IF V_PARENT_PROCID IS NOT NULL AND V_CNT = 0 THEN
        INSERT INTO TBL_FORM_DTL (PROCID, ACTSEQ, WITEMSEQ, FORM_TYPE, FIELD_DATA, CRT_DT, CRT_USR, MOD_DT, MOD_USR)
        SELECT I_PROCID, ACTSEQ, WITEMSEQ, FORM_TYPE, FIELD_DATA, CRT_DT, CRT_USR, MOD_DT, MOD_USR 
          FROM TBL_FORM_DTL
         WHERE PROCID=V_PARENT_PROCID;
    
        SELECT FIELD_DATA
          INTO V_XMLDOC
          FROM TBL_FORM_DTL
         WHERE PROCID = I_PROCID;
    
        SP_UPDATE_INCENTIVES_TABLE(I_PROCID, V_XMLDOC);
    END IF;        
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_INIT_INCENTIVES TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_INIT_INCENTIVES TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_INIT_INCENTIVES TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_ERLR_UPDATE_FINAL_RATING
(     
    I_LABEL IN VARCHAR2,
    I_UPDATED_LABEL IN VARCHAR2 DEFAULT ''
)
IS
/* THIS IS TEMPORARY PROCEDURE */

    V_DEL_LABEL VARCHAR2(100);
    V_XPATH VARCHAR2(200);
    V_XPATH_DEL VARCHAR2(200);
BEGIN
    V_XPATH := '/formData/items/item[id="PI_WNR_FIN_RATING"]/value[.="'||I_LABEL||'"]/text()';
    FOR FORM_REC IN (
        SELECT P.PROCID, P.STATE, FIELD_DATA, XMLQUERY(V_XPATH PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as FINAL_RATING
        FROM TBL_FORM_DTL F JOIN BIZFLOW.PROCS P ON F.PROCID = P.PROCID WHERE FORM_TYPE = 'CMSERLR'
    ) 
    LOOP
        IF FORM_REC.FINAL_RATING IS NOT NULL THEN
            V_XPATH := '/formData/items/item[id="PI_WNR_FIN_RATING"]/value[.="'||I_LABEL||'"]/text()';
            SELECT UPDATEXML(FORM_REC.FIELD_DATA, V_XPATH, I_UPDATED_LABEL) INTO FORM_REC.FIELD_DATA FROM DUAL;
            V_XPATH := '/formData/items/item[id="PI_WNR_FIN_RATING"]//text[.="'||I_LABEL||'"]/text()';
            SELECT UPDATEXML(FORM_REC.FIELD_DATA, V_XPATH, I_UPDATED_LABEL) INTO FORM_REC.FIELD_DATA FROM DUAL;

            UPDATE TBL_FORM_DTL
               SET FIELD_DATA = FORM_REC.FIELD_DATA
             WHERE PROCID = FORM_REC.PROCID;

            SP_UPDATE_ERLR_TABLE(FORM_REC.PROCID);
        END IF;
    END LOOP;
    
    UPDATE TBL_LOOKUP
       SET TBL_NAME = I_UPDATED_LABEL,
           TBL_LABEL = I_UPDATED_LABEL
     WHERE TBL_CATEGORY = 'ERLR'
       AND TBL_LABEL = I_LABEL
       AND TBL_LTYPE='ERLRPipFinalRating';
END;
/

GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_UPDATE_FINAL_RATING TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_UPDATE_FINAL_RATING TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_UPDATE_FINAL_RATING TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_UPDATE_INIT_ELIGQUAL
(
	I_PROCID               IN  NUMBER
)
IS
	V_ID                       NUMBER(20);
	V_XMLCLOB                  CLOB;
	V_RLVNTDATANAME            VARCHAR2(100);
	V_VALUE                    NVARCHAR2(2000);
	V_VALUE_LOOKUP             NVARCHAR2(2000);
	V_XMLDOC                   XMLTYPE;
	V_XMLVALUE                 XMLTYPE;
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: SP_UPDATE_INIT_ELIGQUAL -------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID = ' || TO_CHAR(I_PROCID));

	SELECT FN_INIT_ELIGQUAL(I_PROCID) INTO V_XMLDOC FROM DUAL;
	--SELECT V_XMLDOC.GETCLOBVAL() INTO V_XMLCLOB FROM DUAL;
	--DBMS_OUTPUT.PUT_LINE('    V_XMLCLOB = ' || V_XMLCLOB);

	-- set PV that should be initialized and stays the same until proc completion
	V_XMLVALUE := V_XMLDOC.EXTRACT('/DOCUMENT/GENERAL/AT_ID/text()');
	IF V_XMLVALUE IS NOT NULL THEN
		V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE(AT_ID) = ' || V_VALUE);

		---------------------------------
		-- replace with lookup value
		---------------------------------
		BEGIN
			SELECT TBL_LABEL INTO V_VALUE_LOOKUP
			FROM TBL_LOOKUP
			WHERE TBL_ID = TO_NUMBER(V_VALUE);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_VALUE_LOOKUP := NULL;
			WHEN OTHERS THEN
				V_VALUE_LOOKUP := NULL;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE_LOOKUP(AT_ID) = ' || V_VALUE_LOOKUP);

		IF V_VALUE_LOOKUP IN ('Expert/Consultant', '30% or more disabled veterans', 'Veteran Recruitment Appointment (VRA)') THEN
			V_VALUE := 'Yes';  -- set final PV value
		ELSIF V_VALUE_LOOKUP = 'Schedule A' THEN
			V_XMLVALUE := V_XMLDOC.EXTRACT('/DOCUMENT/GENERAL/SAT_ID/text()');
			IF V_XMLVALUE IS NOT NULL THEN
				V_VALUE := V_XMLVALUE.GETSTRINGVAL();
				--DBMS_OUTPUT.PUT_LINE('    V_VALUE(SAT_ID) = ' || V_VALUE);

				---------------------------------
				-- replace with lookup value
				---------------------------------
				BEGIN
					SELECT TBL_LABEL INTO V_VALUE_LOOKUP
					FROM TBL_LOOKUP
					WHERE TBL_ID = TO_NUMBER(V_VALUE);
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						V_VALUE_LOOKUP := NULL;
					WHEN OTHERS THEN
						V_VALUE_LOOKUP := NULL;
				END;
				--DBMS_OUTPUT.PUT_LINE('    V_VALUE_LOOKUP(SAT_ID) = ' || V_VALUE_LOOKUP);

				IF V_VALUE_LOOKUP = 'Disability (U)' THEN
					V_VALUE := 'Yes';  -- set final PV value
				END IF;
			END IF;
		END IF;

		IF V_VALUE IS NULL OR V_VALUE <> 'Yes' THEN
			V_VALUE := 'No';  -- set final PV value
		END IF;
		V_RLVNTDATANAME := 'selectionRequired';
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
	END IF;
      
	SP_UPDATE_FORM_DATA(V_ID, 'CMSELIGQUAL'
		, V_XMLDOC.GETCLOBVAL()
		, 'SYSTEM'
		, I_PROCID, 0, 0
	);

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_INIT_ELIGQUAL -------------------');
END;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INIT_ELIGQUAL TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INIT_ELIGQUAL TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INIT_ELIGQUAL TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_GET_REQUEST_NUM (P_REQUEST_NUM OUT VARCHAR2)
AS
	V_DATE DATE;
	V_SEQ NUMBER;
	V_NUM_OUT VARCHAR2(200);
BEGIN
	BEGIN
		SELECT RC_DATE, RC_SEQ INTO V_DATE, V_SEQ FROM REQUEST_CONTROL;
	EXCEPTION
		WHEN OTHERS THEN P_REQUEST_NUM := NULL;
		RETURN;
	END;
	IF TO_CHAR(V_DATE, 'YYYYMMDD') <> TO_CHAR(SYSDATE, 'YYYYMMDD') THEN
		BEGIN
			UPDATE REQUEST_CONTROL
			SET RC_DATE = SYSDATE
				, RC_SEQ = 1
				, RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-0001';
		END;
	ELSE
		BEGIN
			UPDATE REQUEST_CONTROL
			SET RC_SEQ = (V_SEQ + 1)
				, RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' ||
					TO_CHAR((V_SEQ + 1), 'FM0000');
		END;
	END IF;

	BEGIN
		SELECT RC_REQUEST_NUM INTO V_NUM_OUT FROM REQUEST_CONTROL;
	END;
	P_REQUEST_NUM := V_NUM_OUT;
EXCEPTION
	WHEN OTHERS THEN P_REQUEST_NUM := NULL;
	RETURN;
END SP_GET_REQUEST_NUM;
/
GRANT EXECUTE ON HHS_CMS_HR.SP_GET_REQUEST_NUM TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_GET_REQUEST_NUM TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_GET_REQUEST_NUM TO HHS_CMS_HR_DEV_ROLE;
/

create or replace PROCEDURE SP_GET_INCENTIVES_REQUEST_NUM (P_REQUEST_NUM OUT VARCHAR2)
AS
  V_DATE DATE;
  V_SEQ NUMBER;
  V_NUM_OUT VARCHAR2(200);
BEGIN
  BEGIN
    SELECT RC_DATE, RC_SEQ INTO V_DATE, V_SEQ FROM INCENTIVES_REQUEST_CONTROL;
  EXCEPTION
    WHEN OTHERS THEN P_REQUEST_NUM := NULL;
    RETURN;
  END;
  
  IF TO_CHAR(V_DATE, 'YYYYMMDD') <> TO_CHAR(SYSDATE, 'YYYYMMDD') THEN
    BEGIN
      UPDATE INCENTIVES_REQUEST_CONTROL
      SET RC_DATE = SYSDATE
        , RC_SEQ = 1001
        , RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-1001';
    END;
  ELSE
    BEGIN
      UPDATE INCENTIVES_REQUEST_CONTROL
      SET RC_SEQ = (V_SEQ + 1)
        , RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' ||
                        TO_CHAR((V_SEQ + 1), 'FM0000');
    END;
  END IF;

  BEGIN
    SELECT RC_REQUEST_NUM INTO V_NUM_OUT FROM INCENTIVES_REQUEST_CONTROL;
  END;
  P_REQUEST_NUM := V_NUM_OUT;
EXCEPTION
  WHEN OTHERS THEN P_REQUEST_NUM := NULL;
  RETURN;
END SP_GET_INCENTIVES_REQUEST_NUM;
/

GRANT EXECUTE ON HHS_CMS_HR.SP_GET_INCENTIVES_REQUEST_NUM TO BIZFLOW WITH GRANT OPTION;
GRANT EXECUTE ON HHS_CMS_HR.SP_GET_INCENTIVES_REQUEST_NUM TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_GET_INCENTIVES_REQUEST_NUM TO HHS_CMS_HR_DEV_ROLE;
/

COMMIT;
/
