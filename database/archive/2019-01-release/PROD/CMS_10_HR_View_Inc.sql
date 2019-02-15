-- CMS_06_HR_VW_INCENTIVES_COM.sql
-- CMS_32_HR_VW_INCENTIVES_DATA.sql
-- CMS_12_HR_VW_INCENTIVES_SAM.sql
-- CMS_13_HR_VW_INCENTIVES_LE.sql


--------------------------------------------------------
--  DDL for Incentives Views
--------------------------------------------------------
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
	     ) X
WHERE FD.FORM_TYPE = 'CMSINCENTIVES';
/



CREATE OR REPLACE VIEW VW_INCENTIVES_SAM AS

SELECT FD.PROCID AS PROC_ID, X.*
FROM TBL_FORM_DTL FD,
     XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
	     ---- Center/Office/Consortium Director
	     COC_NAME VARCHAR2(100) PATH './item[id="cocDirector"]/value/name'
	     , COC_EMAIL VARCHAR2(100) PATH './item[id="cocDirector"]/value/email'
	     , COC_ID VARCHAR2(10) PATH './item[id="cocDirector"]/value/id'
	     , COC_TITLE VARCHAR2(100) PATH './item[id="cocDirector"]/value/title'
	     , INIT_SALARY_GRADE VARCHAR2(5) PATH './item[id="hrInitialSalaryGrade"]/value'
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
		 , JUSTIFICATION_LASTMOD_NAME VARCHAR2(100) PATH './item[id="currentUser"]/value'
		 , JUSTIFICATION_LASTMOD_ID VARCHAR2(10) PATH './item[id="currentUserId"]/value'
		 , JUSTIFICATION_MOD_REASON VARCHAR2(200) PATH './item[id="justificationModificationReason"]/value'
		 , JUSTIFICATION_MOD_SUMMARY VARCHAR2(500) PATH './item[id="justificationModificationSummary"]/value'
		 , JUSTIFICATION_MODIFIER_NAME VARCHAR2(100) PATH './item[id="justificationModifier"]/value'
		 , JUSTIFICATION_MODIFIER_ID VARCHAR2(10) PATH './item[id="justificationModifierId"]/value'
		 , JUSTIFICATION_MODIFIED_DATE VARCHAR2(20) PATH './item[id="justificationModified"]/value'	
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
	     -- Approvals
	     , APPROVAL_SO_VALUE VARCHAR2(10) PATH './item[id="approvalSOValue"]/value'
	     , APPROVAL_SO_ACTING VARCHAR2(10) PATH './item[id="approvalSOActing"]/value'
	     , APPROVAL_SO VARCHAR2(100) PATH './item[id="approvalSO"]/value'
	     , APPROVAL_SO_RESP_DATE VARCHAR2(10) PATH './item[id="approvalSOResponseDate"]/value'
	     , APPROVAL_COC_VALUE VARCHAR2(10) PATH './item[id="approvalCOCValue"]/value'
	     , APPROVAL_COC_ACTING VARCHAR2(10) PATH './item[id="approvalCOCActing"]/value'
	     , APPROVAL_COC VARCHAR2(100) PATH './item[id="approvalCOC"]/value'
	     , APPROVAL_COC_RESP_DATE VARCHAR2(10) PATH './item[id="approvalCOCResponseDate"]/value'
	     , APPROVAL_DGHO_VALUE VARCHAR2(10) PATH './item[id="approvalDGHOValue"]/value'
	     , APPROVAL_DGHO_ACTING VARCHAR2(10) PATH './item[id="approvalDGHOActing"]/value'
	     , APPROVAL_DGHO VARCHAR2(100) PATH './item[id="approvalDGHO"]/value'
	     , APPROVAL_DGHO_RESP_DATE VARCHAR2(10) PATH './item[id="approvalDGHOResponseDate"]/value'
	     , APPROVAL_TABG_VALUE VARCHAR2(10) PATH './item[id="approvalTABGValue"]/value'
	     , APPROVAL_TABG_ACTING VARCHAR2(10) PATH './item[id="approvalTABGActing"]/value'
	     , APPROVAL_TABG VARCHAR2(100) PATH './item[id="approvalTABG"]/value'
	     , APPROVAL_TABG_RESP_DATE VARCHAR2(10) PATH './item[id="approvalTABGResponseDate"]/value'
	     , APPROVAL_OHC_VALUE VARCHAR2(10) PATH './item[id="approvalOHCValue"]/value'
	     , APPROVAL_OHC_Acting VARCHAR2(10) PATH './item[id="approvalOHCActing"]/value'
	     , APPROVAL_OHC VARCHAR2(100) PATH './item[id="approvalOHC"]/value'
	     , APPROVAL_OHC_RESP_DATE VARCHAR2(10) PATH './item[id="approvalOHCResponseDate"]/value'
	     , APPROVER_NOTES VARCHAR2(500) PATH './item[id="approverNotes"]/value'
	     ) X
WHERE FD.FORM_TYPE = 'CMSINCENTIVES';
/



CREATE OR REPLACE VIEW VW_INCENTIVES_LE AS

SELECT FD.PROCID AS PROC_ID, X.*
FROM TBL_FORM_DTL FD,
     XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
	     -- Details
	     ---- Center/Office/Consortium Director
	     COC_NAME VARCHAR2(100) PATH './item[id="lecocDirector"]/value/name'
	     , COC_EMAIL VARCHAR2(100) PATH './item[id="lecocDirector"]/value/email'
	     , COC_ID VARCHAR2(10) PATH './item[id="lecocDirector"]/value/id'
	     , COC_TITLE VARCHAR2(100) PATH './item[id="lecocDirector"]/value/title'
	     , INIT_ANN_LA_RATE VARCHAR2(10) PATH './item[id="initialOfferedAnnualLeaveAccrualRate"]/value'
	     , SUPPORT_LE VARCHAR2(5) PATH './item[id="supportLE"]/value'
	     , PROPS_ANN_LA_RATE VARCHAR2(10) PATH './item[id="proposedAnnualLeaveAccrualRate"]/value'
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
	     ) X
WHERE FD.FORM_TYPE = 'CMSINCENTIVES';
/

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
			, X.SO_NAME, X.SO_EMAIL, X.SO_ID, X.SO_TITLE
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
			-- cancellation
			, X.CANCEL_RESAON
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
			                               ,   SO_TITLE NVARCHAR2(100)   PATH './item[id="selectingOfficial"]/value/title'
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
			                               -- cancellation
			                               ,   CANCEL_RESAON NVARCHAR2(25)   PATH './item[id="cancellationReason"]/value'
			) X
		WHERE FD.FORM_TYPE='CMSINCENTIVES';
/

--------------------------------------------------------
--  DDL for View VW_INCENTIVES_PCA
--------------------------------------------------------

CREATE OR REPLACE VIEW VW_INCENTIVES_PCA  AS 
  SELECT FD.PROCID AS PROC_ID, X."PCA_TYPE",X."CANDI_AGREE",X."CP_NAME",X."CP_EMAIL",X."CP_ID",X."OFM_NAME",X."OFM_EMAIL",X."OFM_ID",X."ADMIN_APPROVAL_REQ",X."OHC_NAME",X."OHC_EMAIL",X."OHC_ID",X."OADMIN_NAME",X."OADMIN_EMAIL",X."OADMIN_ID",X."WORK_SCHEDULE",X."HOURS_PER_WEEK",X."BD_CERT_REQ",X."LIC_INFO",X."LIC_STATE1_STATE",X."LIC_STATE1_NAME",X."LIC_STATE1_EXP_DATE",X."LIC_STATE2_STATE",X."LIC_STATE2_NAME",X."LIC_STATE2_EXP_DATE",X."BD_CERT_SPEC1",X."BD_CERT_SPEC2",X."BD_CERT_SPEC3",X."BD_CERT_SPEC4",X."BD_CERT_SPEC5",X."BD_CERT_SPEC6",X."BD_CERT_SPEC7",X."BD_CERT_SPEC8",X."BD_CERT_SPEC9",X."BD_CERT_SPEC_OTHER",X."LEN_SERVED",X."LEN_SERVICE",X."ALW_CATEGORY",X."ALW_BD_CERT",X."ALW_MULTI_YEAR_AGMT",X."ALW_MISSION_SC",X."ALW_TOTAL",X."ALW_TOTAL_PAYABLE",X."DETAIL_REMARKS",X."RVW_SO_NAME",X."RVW_SO_ID",X."RVW_SO_DATE",X."RVW_DGHO_NAME",X."RVW_DGHO_ID",X."RVW_DGHO_DATE",X."RVW_CP_NAME",X."RVW_CP_ID",X."RVW_CP_DATE",X."RVW_OFM_NAME",X."RVW_OFM_ID",X."RVW_OFM_DATE",X."RVW_TABG_NAME",X."RVW_TABG_ID",X."RVW_TABG_DATE",X."RVW_OHC_NAME",X."RVW_OHC_ID",X."RVW_OHC_DATE",X."APPROVAL_TABG_NAME",X."APPROVAL_TABG_ID",X."APPROVAL_TABG_DATE",X."APPROVAL_OADMIN_NAME",X."APPROVAL_OADMIN_ID",X."APPROVAL_OADMIN_DATE"
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
WHERE FD.FORM_TYPE = 'CMSINCENTIVES';


GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_COM TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_DATA TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_SAM TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_LE TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_PCA TO HHS_CMS_HR_RW_ROLE;

GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_COM TO HHS_CMS_HR_DEV_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_DATA TO HHS_CMS_HR_DEV_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_SAM TO HHS_CMS_HR_DEV_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_LE TO HHS_CMS_HR_DEV_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_PCA TO HHS_CMS_HR_DEV_ROLE;
/


