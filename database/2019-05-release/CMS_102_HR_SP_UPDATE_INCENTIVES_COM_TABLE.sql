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