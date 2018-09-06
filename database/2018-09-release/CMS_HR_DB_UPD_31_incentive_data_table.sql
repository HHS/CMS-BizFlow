--------------------------------------------------------
--  DDL for VW_INCENTIVES_DATA
--------------------------------------------------------
CREATE OR REPLACE VIEW VW_INCENTIVES_DATA
    AS
            SELECT FD.PROCID, X.requestNumber, to_timestamp(X.requestDate, 'yyyy/mm/dd hh24:mi:ss') requestDate
                , X.requestStatus , X.incentiveType , X.pcaType , X.organizationName
                -- candidate
                , X.candidateName , X.candiFirstName , X.candiMiddleName , X.candiLastName , X.administrativeCode , X.requestType
                -- selectingOfficial
                , X.selectingOfficialName , X.selectingOfficialEmail , X.selectingOfficialID
                -- executiveOfficers
                , X.executiveOfficers1Name , X.executiveOfficers1Email , X.executiveOfficers1ID
                , X.executiveOfficers2Name , X.executiveOfficers2Email , X.executiveOfficers2ID
                , X.executiveOfficers3Name , X.executiveOfficers3Email , X.executiveOfficers3ID
                -- hrLiaisons
                , X.hrLiaisons1Name , X.hrLiaisons1Email , X.hrLiaisons1ID
                , X.hrLiaisons2Name , X.hrLiaisons2Email , X.hrLiaisons2ID
                , X.hrLiaisons3Name , X.hrLiaisons3Email , X.hrLiaisons3ID
                -- hrSpecialist
                , X.hrSpecialistName , X.hrSpecialistEmail , X.hrSpecialistID
                -- hrSpecialist2
                , X.hrSpecialist2Name , X.hrSpecialist2Email , X.hrSpecialist2ID
                -- position
                , X.positionTitle , X.payPlan , X.series , X.grade , X.posDescNumber
                -- dutyStation
                , X.dutyStation1State , X.dutyStation1City
                , X.dutyStation2State , X.dutyStation2City
                -- PCA Details
                , X.typeOfAppointment , X.notToExceedDate , X.workSchedule , X.hoursPerWeek , X.requireBoardCert , X.licenseInfo , X.requireAdminApproval
                -- licenseState
                , X.licenseState1State , to_date(X.licenseState1ExpDate, 'mm/dd/yyyy') licenseState1ExpDate
                , X.licenseState2State , to_date(X.licenseState2ExpDate, 'mm/dd/yyyy') licenseState2ExpDate
                -- boardCertSpecialty
                , X.boardCertSpecialty1 , X.boardCertSpecialty2 , X.boardCertSpecialty3 , X.boardCertSpecialty4
                , X.boardCertSpecialty5 , X.boardCertSpecialty6 , X.boardCertSpecialty7 , X.boardCertSpecialty8
                , X.boardCertSpecialty9 , X.otherSpeciality
                -- allowance
                , X.lengthOfServed , X.lengthOfService
                , X.allowanceCategory , X.allowanceBoardCertification , X.allowanceMultiYearAgreement , X.allowanceMissionSpecCriteria
                , X.allowanceTotal , X.totalPayablePCACalculation
            FROM TBL_FORM_DTL FD, XMLTABLE('/formData/items'
                       PASSING FD.FIELD_DATA
                       COLUMNS
                           requestNumber  NVARCHAR2(15)   PATH './item[id="requestNumber"]/value'
                           ,   requestDate  NVARCHAR2(20)   PATH './item[id="requestDate"]/value'
                           ,   requestStatus  NVARCHAR2(20)   PATH './item[id="requestStatus"]/value'
                           ,   incentiveType  NVARCHAR2(10)   PATH './item[id="incentiveType"]/value'
                           ,   pcaType NVARCHAR2(10)   PATH './item[id="pcaType"]/value'
                           ,   organizationName NVARCHAR2(100)   PATH './item[id="organizationName"]/value'
                           -- candidate
                           ,   candidateName NVARCHAR2(150)   PATH './item[id="candidateName"]/value'
                           ,   candiFirstName NVARCHAR2(50)   PATH './item[id="candiFirstName"]/value'
                           ,   candiMiddleName NVARCHAR2(50)   PATH './item[id="candiMiddleName"]/value'
                           ,   candiLastName NVARCHAR2(50)   PATH './item[id="candiLastName"]/value'
                           ,   administrativeCode NVARCHAR2(10)   PATH './item[id="administrativeCode"]/value'
                           ,   requestType NVARCHAR2(20)   PATH './item[id="requestType"]/value'
                           -- selectingOfficial
                           ,   selectingOfficialName NVARCHAR2(100)   PATH './item[id="selectingOfficial"]/value/name'
                           ,   selectingOfficialEmail NVARCHAR2(100)   PATH './item[id="selectingOfficial"]/value/email'
                           ,   selectingOfficialID NVARCHAR2(10)   PATH './item[id="selectingOfficial"]/value/id'
                           -- executiveOfficers
                           ,   executiveOfficers1Name NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[1]/name'
                           ,   executiveOfficers1Email NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[1]/email'
                           ,   executiveOfficers1ID NVARCHAR2(10)   PATH './item[id="executiveOfficers"]/value[1]/id'
                           ,   executiveOfficers2Name NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[2]/name'
                           ,   executiveOfficers2Email NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[2]/email'
                           ,   executiveOfficers2ID NVARCHAR2(10)   PATH './item[id="executiveOfficers"]/value[2]/id'
                           ,   executiveOfficers3Name NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[3]/name'
                           ,   executiveOfficers3Email NVARCHAR2(100)   PATH './item[id="executiveOfficers"]/value[3]/email'
                           ,   executiveOfficers3ID NVARCHAR2(10)   PATH './item[id="executiveOfficers"]/value[3]/id'
                           -- hrLiaisons
                           ,   hrLiaisons1Name NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[1]/name'
                           ,   hrLiaisons1Email NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[1]/email'
                           ,   hrLiaisons1ID NVARCHAR2(10)   PATH './item[id="hrLiaisons"]/value[1]/id'
                           ,   hrLiaisons2Name NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[2]/name'
                           ,   hrLiaisons2Email NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[2]/email'
                           ,   hrLiaisons2ID NVARCHAR2(10)   PATH './item[id="hrLiaisons"]/value[2]/id'
                           ,   hrLiaisons3Name NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[3]/name'
                           ,   hrLiaisons3Email NVARCHAR2(100)   PATH './item[id="hrLiaisons"]/value[3]/email'
                           ,   hrLiaisons3ID NVARCHAR2(10)   PATH './item[id="hrLiaisons"]/value[3]/id'
                           -- hrSpecialist
                           ,   hrSpecialistName NVARCHAR2(100)   PATH './item[id="hrSpecialist"]/value/name'
                           ,   hrSpecialistEmail NVARCHAR2(100)   PATH './item[id="hrSpecialist"]/value/email'
                           ,   hrSpecialistID NVARCHAR2(10)   PATH './item[id="hrSpecialist"]/value/id'
                           -- hrSpecialist2
                           ,   hrSpecialist2Name NVARCHAR2(100)   PATH './item[id="hrSpecialist2"]/value/name'
                           ,   hrSpecialist2Email NVARCHAR2(100)   PATH './item[id="hrSpecialist2"]/value/email'
                           ,   hrSpecialist2ID NVARCHAR2(10)   PATH './item[id="hrSpecialist2"]/value/id'
                           -- position
                           ,   positionTitle NVARCHAR2(140)   PATH './item[id="positionTitle"]/value'
                           ,   payPlan NVARCHAR2(5)   PATH './item[id="payPlan"]/value'
                           ,   series NVARCHAR2(140)   PATH './item[id="series"]/value'
                           ,   grade NVARCHAR2(5)   PATH './item[id="grade"]/value'
                           ,   posDescNumber NVARCHAR2(20)   PATH './item[id="posDescNumber"]/value'
                           -- dutyStation
                           ,   dutyStation1State NVARCHAR2(2)   PATH './item[id="dutyStation"]/value[1]/state'
                           ,   dutyStation1City NVARCHAR2(50)   PATH './item[id="dutyStation"]/value[1]/city'
                           ,   dutyStation2State NVARCHAR2(2)   PATH './item[id="dutyStation"]/value[2]/state'
                           ,   dutyStation2City NVARCHAR2(50)   PATH './item[id="dutyStation"]/value[2]/city'
                           -- PCA Details
                           ,   typeOfAppointment NVARCHAR2(20)   PATH './item[id="typeOfAppointment"]/value'
                           ,   notToExceedDate NVARCHAR2(50)   PATH './item[id="notToExceedDate"]/value'
                           ,   workSchedule NVARCHAR2(15)   PATH './item[id="workSchedule"]/value'
                           ,   hoursPerWeek NVARCHAR2(5)   PATH './item[id="hoursPerWeek"]/value'
                           ,   requireBoardCert NVARCHAR2(5)   PATH './item[id="requireBoardCert"]/value'
                           ,   licenseInfo NVARCHAR2(140)   PATH './item[id="licenseInfo"]/value'
                           ,   requireAdminApproval NVARCHAR2(5)   PATH './item[id="requireAdminApproval"]/value'
                           -- licenseState
                           ,   licenseState1State NVARCHAR2(2)   PATH './item[id="licenseState"]/value[1]/state'
                           ,   licenseState1ExpDate NVARCHAR2(10)   PATH './item[id="licenseState"]/value[1]/expDate'
                           ,   licenseState2State NVARCHAR2(2)   PATH './item[id="licenseState"]/value[2]/state'
                           ,   licenseState2ExpDate NVARCHAR2(10)   PATH './item[id="licenseState"]/value[2]/expDate'
                           -- boardCertSpecialty
                           ,   boardCertSpecialty1 NVARCHAR2(30)   PATH './item[contains(id, "boardCertSpecialty")][1]/text'
                           ,   boardCertSpecialty2 NVARCHAR2(30)   PATH './item[contains(id, "boardCertSpecialty")][2]/text'
                           ,   boardCertSpecialty3 NVARCHAR2(30)   PATH './item[contains(id, "boardCertSpecialty")][3]/text'
                           ,   boardCertSpecialty4 NVARCHAR2(30)   PATH './item[contains(id, "boardCertSpecialty")][4]/text'
                           ,   boardCertSpecialty5 NVARCHAR2(20)   PATH './item[contains(id, "boardCertSpecialty")][5]/text'
                           ,   boardCertSpecialty6 NVARCHAR2(30)   PATH './item[contains(id, "boardCertSpecialty")][6]/text'
                           ,   boardCertSpecialty7 NVARCHAR2(30)   PATH './item[contains(id, "boardCertSpecialty")][7]/text'
                           ,   boardCertSpecialty8 NVARCHAR2(30)   PATH './item[contains(id, "boardCertSpecialty")][8]/text'
                           ,   boardCertSpecialty9 NVARCHAR2(30)   PATH './item[contains(id, "boardCertSpecialty")][9]/text'
                           ,   otherSpeciality NVARCHAR2(140)   PATH './item[id="otherSpeciality"]/value'
                           -- allowance
                           ,   lengthOfServed NVARCHAR2(25)   PATH './item[id="lengthOfServed"]/value'
                           ,   lengthOfService NVARCHAR2(2)   PATH './item[id="lengthOfService"]/value'
                           ,   allowanceCategory NVARCHAR2(15)   PATH './item[id="allowanceCategory"]/value'
                           ,   allowanceBoardCertification NVARCHAR2(15)   PATH './item[id="allowanceBoardCertification"]/value'
                           ,   allowanceMultiYearAgreement NVARCHAR2(15)   PATH './item[id="allowanceMultiYearAgreement"]/value'
                           ,   allowanceMissionSpecCriteria NVARCHAR2(15)   PATH './item[id="allowanceMissionSpecificCriteria"]/value'
                           ,   allowanceTotal NVARCHAR2(15)   PATH './item[id="allowanceTotal"]/value'
                           ,   totalPayablePCACalculation NVARCHAR2(15)   PATH './item[id="totalPayablePCACalculation"]/value'
                ) X
            WHERE FD.FORM_TYPE='CMSINCENTIVES'
;
/


GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_DATA TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_DATA TO HHS_CMS_HR_DEV_ROLE;
