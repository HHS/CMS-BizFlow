--------------------------------------------------------
--  DDL for VW_INCENTIVES_DATA
--------------------------------------------------------
CREATE OR REPLACE VIEW VW_INCENTIVES_DATA
    AS
        SELECT FD.PROCID PROC_ID, X.REQ_NUM, to_timestamp(X.REQ_DATE, 'yyyy/mm/dd hh24:mi:ss') REQ_DATE
            , X.REQ_STATUS, X.INCEN_TYPE , X.PCA_TYPE
            -- associatedNEILRequest
            , X.NEIL_REQ_NUM,  X.NEIL_REQ_TYPE, X.ADMIN_CODE, X.ORG_NAME
            -- candidate
            , X.CANDI_NAME, X.CANDI_FIRST, X.CANDI_MIDDLE, X.CANDI_LAST
            -- selectingOfficial
            , X.SO_NAME, X.SO_EMAIL, X.SO_ID
            -- executiveOfficers
            , X.XO1_NAME, X.XO1_EMAIL, X.XO1_ID
            , X.XO2_NAME, X.XO2_EMAIL, X.XO2_ID
            , X.XO3_NAME, X.XO3_EMAIL, X.XO3_ID
            -- hrLiaisons
            , X.HRL1_NAME, X.HRL1_EMAIL, X.HRL1_ID
            , X.HRL2_NAME, X.HRL2_EMAIL, X.HRL2_ID
            , X.HRL3_NAME, X.HRL3_EMAIL, X.HRL3_ID
            -- hrSpecialist
            , X.HRS1_NAME, X.HRS1_EMAIL, X.HRS1_ID
            -- hrSpecialist2
            , X.HRS2_NAME, X.HRS2_EMAIL, X.HRS2_ID
            -- position
            , X.POS_TITLE, X.PAY_PLAN, X.SERIES, X.GRADE, X.POS_DESC_NUM
            -- dutyStation
            , X.DS1_STATE, X.DS1_CITY
            , X.DS2_STATE, X.DS2_CITY
            -- PCA Details
            , X.TYPE_OF_APPT, X.NOT_TO_EXDATE, X.WORK_SCHEDULE , X.HOURS_PER_WEEK , X.BD_CERT_REQ , X.LIC_INFO , X.REQ_ADMIN_APPROVAL
            -- licenseState
            , X.LIC_STATE1_STATE, X.LIC_STATE1_NAME, to_date(X.LIC_STATE1_EXP_DATE, 'mm/dd/yyyy') LIC_STATE1_EXP_DATE
            , X.LIC_STATE2_STATE, X.LIC_STATE2_NAME, to_date(X.LIC_STATE2_EXP_DATE, 'mm/dd/yyyy') LIC_STATE2_EXP_DATE
            -- boardCertSpecialty
            , X.BD_CERT_SPEC1, X.BD_CERT_SPEC2, X.BD_CERT_SPEC3, X.BD_CERT_SPEC4
            , X.BD_CERT_SPEC5, X.BD_CERT_SPEC6, X.BD_CERT_SPEC7, X.BD_CERT_SPEC8
            , X.BD_CERT_SPEC9, X.BD_CERT_SPEC_OTHER
            -- allowance
            , X.LEN_SERVED, X.LEN_SERVICE
            , X.ALW_CATEGORY, TO_NUMBER(SUBSTR(X.ALW_CATEGORY, 2), '999999999.99') ALW_CATEGORY_NUM
            , X.ALW_BD_CERT, TO_NUMBER(SUBSTR(X.ALW_BD_CERT, 2), '999999999.99') ALW_BD_CERT_NUM
            , X.ALW_MULTI_YEAR_AGMT, TO_NUMBER(SUBSTR(X.ALW_MULTI_YEAR_AGMT, 2), '999999999.99') ALW_MULTI_YEAR_AGMT_NUM
            , X.ALW_MISSION_SC, TO_NUMBER(SUBSTR(X.ALW_MISSION_SC, 2), '999999999.99') ALW_MISSION_SC_NUM
            , X.ALW_TOTAL, TO_NUMBER(SUBSTR(X.ALW_TOTAL, 2 ), '999999999.99') ALW_TOTAL_NUM
            , X.TOTAL_PAYABLE, TO_NUMBER(SUBSTR(X.TOTAL_PAYABLE, 2), '999999999.99') TOTAL_PAYABLE_NUM
        FROM TBL_FORM_DTL FD, XMLTABLE('/formData/items'
                                       PASSING FD.FIELD_DATA
                                       COLUMNS
                                           REQ_NUM  NVARCHAR2(15)   PATH './item[id="requestNumber"]/value'
                                           ,   REQ_DATE  NVARCHAR2(20)   PATH './item[id="requestDate"]/value'
                                           ,   REQ_STATUS  NVARCHAR2(20)   PATH './item[id="requestStatus"]/value'
                                           ,   INCEN_TYPE  NVARCHAR2(10)   PATH './item[id="incentiveType"]/value'
                                           ,   PCA_TYPE NVARCHAR2(10)   PATH './item[id="pcaType"]/value'
                                           -- associatedNEILRequest
                                           ,   NEIL_REQ_NUM NVARCHAR2(20)   PATH './item[id="associatedNEILRequest"]/value/requestNumber'
                                           ,   NEIL_REQ_TYPE NVARCHAR2(20)   PATH './item[id="requestType"]/value'
                                           ,   ADMIN_CODE NVARCHAR2(10)   PATH './item[id="administrativeCode"]/value'
                                           ,   ORG_NAME NVARCHAR2(100)   PATH './item[id="organizationName"]/value'
                                           -- associatedIncentives
                                           ,   ASSOC_INCEN_REQ_NUM NVARCHAR2(20)   PATH './item[id="associatedIncentives"]/value/requestNumber'
                                           ,   ASSOC_INCEN_TYPE NVARCHAR2(20)   PATH './item[id="associatedIncentives"]/value/incentiveType'
                                           -- candidate
                                           ,   CANDI_NAME NVARCHAR2(150)   PATH './item[id="candidateName"]/value'
                                           ,   CANDI_FIRST NVARCHAR2(50)   PATH './item[id="candiFirstName"]/value'
                                           ,   CANDI_MIDDLE NVARCHAR2(50)   PATH './item[id="candiMiddleName"]/value'
                                           ,   CANDI_LAST NVARCHAR2(50)   PATH './item[id="candiLastName"]/value'
                                           -- selectingOfficial
                                           ,   SO_NAME NVARCHAR2(100)   PATH './item[id="selectingOfficial"]/value/name'
                                           ,   SO_EMAIL NVARCHAR2(100)   PATH './item[id="selectingOfficial"]/value/email'
                                           ,   SO_ID NVARCHAR2(10)   PATH './item[id="selectingOfficial"]/value/id'
                                           -- executiveOfficers
                                           ,   XO1_NAME NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[1]/name'
                                           ,   XO1_EMAIL NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[1]/email'
                                           ,   XO1_ID NVARCHAR2(10)   PATH './item[id="executiveOfficers"]/value[1]/id'
                                           ,   XO2_NAME NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[2]/name'
                                           ,   XO2_EMAIL NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[2]/email'
                                           ,   XO2_ID NVARCHAR2(10)   PATH './item[id="executiveOfficers"]/value[2]/id'
                                           ,   XO3_NAME NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[3]/name'
                                           ,   XO3_EMAIL NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[3]/email'
                                           ,   XO3_ID NVARCHAR2(10)   PATH './item[id="executiveOfficers"]/value[3]/id'
                                           -- hrLiaisons
                                           ,   HRL1_NAME NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[1]/name'
                                           ,   HRL1_EMAIL NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[1]/email'
                                           ,   HRL1_ID NVARCHAR2(10)   PATH './item[id="hrLiaisons"]/value[1]/id'
                                           ,   HRL2_NAME NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[2]/name'
                                           ,   HRL2_EMAIL NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[2]/email'
                                           ,   HRL2_ID NVARCHAR2(10)   PATH './item[id="hrLiaisons"]/value[2]/id'
                                           ,   HRL3_NAME NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[3]/name'
                                           ,   HRL3_EMAIL NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[3]/email'
                                           ,   HRL3_ID NVARCHAR2(10)   PATH './item[id="hrLiaisons"]/value[3]/id'
                                           -- hrSpecialist
                                           ,   HRS1_NAME NVARCHAR2(100)   PATH './item[id="hrSpecialist"]/value/name'
                                           ,   HRS1_EMAIL NVARCHAR2(100)   PATH './item[id="hrSpecialist"]/value/email'
                                           ,   HRS1_ID NVARCHAR2(10)   PATH './item[id="hrSpecialist"]/value/id'
                                           -- hrSpecialist2
                                           ,   HRS2_NAME NVARCHAR2(100)   PATH './item[id="hrSpecialist2"]/value/name'
                                           ,   HRS2_EMAIL NVARCHAR2(100)   PATH './item[id="hrSpecialist2"]/value/email'
                                           ,   HRS2_ID NVARCHAR2(10)   PATH './item[id="hrSpecialist2"]/value/id'
                                           -- position
                                           ,   POS_TITLE NVARCHAR2(140)   PATH './item[id="positionTitle"]/value'
                                           ,   PAY_PLAN NVARCHAR2(5)   PATH './item[id="payPlan"]/value'
                                           ,   SERIES NVARCHAR2(140)   PATH './item[id="series"]/value'
                                           ,   GRADE NVARCHAR2(5)   PATH './item[id="grade"]/value'
                                           ,   POS_DESC_NUM NVARCHAR2(20)   PATH './item[id="posDescNumber"]/value'
                                           -- dutyStation
                                           ,   DS1_STATE NVARCHAR2(2)   PATH './item[id="dutyStation"]/value[1]/state'
                                           ,   DS1_CITY NVARCHAR2(50)   PATH './item[id="dutyStation"]/value[1]/city'
                                           ,   DS2_STATE NVARCHAR2(2)   PATH './item[id="dutyStation"]/value[2]/state'
                                           ,   DS2_CITY NVARCHAR2(50)   PATH './item[id="dutyStation"]/value[2]/city'
                                           -- PCA Details
                                           ,   TYPE_OF_APPT NVARCHAR2(20)   PATH './item[id="typeOfAppointment"]/value'
                                           ,   NOT_TO_EXDATE NVARCHAR2(50)   PATH './item[id="notToExceedDate"]/value'
                                           ,   WORK_SCHEDULE NVARCHAR2(15)   PATH './item[id="workSchedule"]/value'
                                           ,   HOURS_PER_WEEK NVARCHAR2(5)   PATH './item[id="hoursPerWeek"]/value'
                                           ,   BD_CERT_REQ NVARCHAR2(5)   PATH './item[id="requireBoardCert"]/value'
                                           ,   LIC_INFO NVARCHAR2(140)   PATH './item[id="licenseInfo"]/value'
                                           ,   REQ_ADMIN_APPROVAL NVARCHAR2(5)   PATH './item[id="requireAdminApproval"]/value'
                                           -- licenseState
                                           ,   LIC_STATE1_STATE NVARCHAR2(2)   PATH './item[id="licenseState"]/value[1]/state'
                                           ,   LIC_STATE1_NAME NVARCHAR2(50)   PATH './item[id="licenseState"]/value[1]/name'
                                           ,   LIC_STATE1_EXP_DATE NVARCHAR2(10)   PATH './item[id="licenseState"]/value[1]/expDate'
                                           ,   LIC_STATE2_STATE NVARCHAR2(2)   PATH './item[id="licenseState"]/value[2]/state'
                                           ,   LIC_STATE2_NAME NVARCHAR2(50)   PATH './item[id="licenseState"]/value[2]/name'
                                           ,   LIC_STATE2_EXP_DATE NVARCHAR2(10)   PATH './item[id="licenseState"]/value[2]/expDate'
                                           -- boardCertSpecialty
                                           ,   BD_CERT_SPEC1 NVARCHAR2(30)   PATH './item[id="boardCertSpecialty"]/value[1]/text'
                                           ,   BD_CERT_SPEC2 NVARCHAR2(30)   PATH './item[id="boardCertSpecialty"]/value[2]/text'
                                           ,   BD_CERT_SPEC3 NVARCHAR2(30)   PATH './item[id="boardCertSpecialty"]/value[3]/text'
                                           ,   BD_CERT_SPEC4 NVARCHAR2(30)   PATH './item[id="boardCertSpecialty"]/value[4]/text'
                                           ,   BD_CERT_SPEC5 NVARCHAR2(20)   PATH './item[id="boardCertSpecialty"]/value[5]/text'
                                           ,   BD_CERT_SPEC6 NVARCHAR2(30)   PATH './item[id="boardCertSpecialty"]/value[6]/text'
                                           ,   BD_CERT_SPEC7 NVARCHAR2(30)   PATH './item[id="boardCertSpecialty"]/value[7]/text'
                                           ,   BD_CERT_SPEC8 NVARCHAR2(30)   PATH './item[id="boardCertSpecialty"]/value[8]/text'
                                           ,   BD_CERT_SPEC9 NVARCHAR2(30)   PATH './item[id="boardCertSpecialty"]/value[9]/text'
                                           ,   BD_CERT_SPEC_OTHER NVARCHAR2(140)   PATH './item[id="otherSpeciality"]/value'
                                           -- allowance
                                           ,   LEN_SERVED NVARCHAR2(25)   PATH './item[id="lengthOfServed"]/value'
                                           ,   LEN_SERVICE NVARCHAR2(2)   PATH './item[id="lengthOfService"]/value'
                                           ,   ALW_CATEGORY NVARCHAR2(15)   PATH './item[id="allowanceCategory"]/value'
                                           ,   ALW_BD_CERT NVARCHAR2(15)   PATH './item[id="allowanceBoardCertification"]/value'
                                           ,   ALW_MULTI_YEAR_AGMT NVARCHAR2(15)   PATH './item[id="allowanceMultiYearAgreement"]/value'
                                           ,   ALW_MISSION_SC NVARCHAR2(15)   PATH './item[id="allowanceMissionSpecificCriteria"]/value'
                                           ,   ALW_TOTAL NVARCHAR2(15)   PATH './item[id="allowanceTotal"]/value'
                                           ,   TOTAL_PAYABLE NVARCHAR2(15)   PATH './item[id="totalPayablePCACalculation"]/value'
            ) X
        WHERE FD.FORM_TYPE='CMSINCENTIVES'
;
/