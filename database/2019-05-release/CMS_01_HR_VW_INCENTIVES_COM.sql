SET DEFINE OFF;

CREATE OR REPLACE VIEW VW_INCENTIVES_COM AS

SELECT FD.PROCID AS PROC_ID, X.*
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
	     , SERIES VARCHAR2(140) PATH './item[id="series"]/value'
	     , GRADE VARCHAR2(5) PATH './item[id="grade"]/value'
	     , POS_DESC_NUM VARCHAR2(20) PATH './item[id="posDescNumber"]/value'
	     , TYPE_OF_APPT VARCHAR2(20) PATH './item[id="typeOfAppointment"]/value'
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
WHERE FD.FORM_TYPE = 'CMSINCENTIVES'
;

/