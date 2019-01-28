/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * the Incentives process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_PV_INCENTIVES
	(
		  I_PROCID            IN      NUMBER
		, I_FIELD_DATA      IN      XMLTYPE
	)
IS
	V_XMLVALUE             XMLTYPE;
	V_INCENTIVE_TYPE     NVARCHAR2(50);

	BEGIN
		--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
		--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
		--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
		--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
		--DBMS_OUTPUT.PUT_LINE(' ----------------');

		IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
			--DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestNumber', '/formData/items/item[id="associatedNEILRequest"]/value/requestNumber/text()');
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
			ELSIF 'SAM' = V_INCENTIVE_TYPE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'samSupport', '/formData/items/item[id="supportSAM"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcDirector', '/formData/items/item[id="reviewRcmdApprovalOHCDirector"]/value/participantId/text()', '/formData/items/item[id="reviewRcmdApprovalOHCDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgdApprove', '/formData/items/item[id="approvalDGHOValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgApprove', '/formData/items/item[id="approvalTABGValue"]/value/text()');
                SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocDirector', '/formData/items/item[id="cocDirector"]/value/participantId/text()', '/formData/items/item[id="cocDirector"]/value/name/text()');
			ELSIF 'LE' = V_INCENTIVE_TYPE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'leSupport', '/formData/items/item[id="supportLE"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgdApprove', '/formData/items/item[id="leApprovalDGHOValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgApprove', '/formData/items/item[id="leApprovalTABGValue"]/value/text()');
                SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocDirector', '/formData/items/item[id="lecocDirector"]/value/participantId/text()', '/formData/items/item[id="lecocDirector"]/value/name/text()');
			END IF;

		--DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

		END IF;

		EXCEPTION
		WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_INCENTIVES -------------------');
	END;

/

ALTER TABLE INCENTIVES_SAM MODIFY JUSTIFICATION_MOD_REASON VARCHAR2(200);
/

ALTER TABLE INCENTIVES_LE MODIFY JUSTIFICATION_MOD_REASON VARCHAR2(200);
/

ALTER TABLE INCENTIVES_SAM_JUST_HISTORY MODIFY JUSTIFICATION_MOD_REASON VARCHAR2(200);
/

ALTER TABLE INCENTIVES_LE_JUST_HISTORY MODIFY JUSTIFICATION_MOD_REASON VARCHAR2(200);
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
WHERE FD.FORM_TYPE = 'CMSINCENTIVES'
;
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
WHERE FD.FORM_TYPE = 'CMSINCENTIVES'
;
/

CREATE OR REPLACE TRIGGER INCENTIVES_SAM_BIUR
BEFORE INSERT OR UPDATE OF JUSTIFICATION_SUPER_QUAL_DESC, JUSTIFICATION_QUAL_COMP_DESC, JUSTIFICATION_PAY_EQUITY_DESC, JUSTIFICATION_MOD_REASON, JUSTIFICATION_MOD_SUMMARY, JUSTIFICATION_MODIFIER_ID
ON INCENTIVES_SAM
FOR EACH ROW
DECLARE
	L_JUSTIFICATION_CRT_ID   VARCHAR2(10);
	L_JUSTIFICATION_CRT_NAME VARCHAR2(100);
	L_JUSTIFICATION_CRT_DATE VARCHAR2(20);
	L_JUSTIFICATION_VER NUMBER(10);
BEGIN
		L_JUSTIFICATION_CRT_ID   := :new.JUSTIFICATION_CRT_ID;
		L_JUSTIFICATION_CRT_NAME := :new.JUSTIFICATION_CRT_NAME;
		L_JUSTIFICATION_CRT_DATE := :new.JUSTIFICATION_CRT_DATE;

    IF ((NVL(:old.JUSTIFICATION_SUPER_QUAL_DESC,' ') <> NVL(:new.JUSTIFICATION_SUPER_QUAL_DESC, ' ')) OR 
		(NVL(:old.JUSTIFICATION_QUAL_COMP_DESC,' ') <> NVL(:new.JUSTIFICATION_QUAL_COMP_DESC, ' ')) OR 
		(NVL(:old.JUSTIFICATION_PAY_EQUITY_DESC,' ') <> NVL(:new.JUSTIFICATION_PAY_EQUITY_DESC, ' ')) OR 
		(NVL(:old.JUSTIFICATION_MOD_REASON,' ') <> NVL(:new.JUSTIFICATION_MOD_REASON, ' ')) OR 
		(NVL(:old.JUSTIFICATION_MOD_SUMMARY,' ') <> NVL(:new.JUSTIFICATION_MOD_SUMMARY, ' ')) ) THEN
      IF (L_JUSTIFICATION_CRT_ID IS NULL) THEN
        L_JUSTIFICATION_CRT_ID   := :new.JUSTIFICATION_LASTMOD_ID;
        L_JUSTIFICATION_CRT_NAME := :new.JUSTIFICATION_LASTMOD_NAME;
        L_JUSTIFICATION_CRT_DATE := TO_CHAR(SYSTIMESTAMP, 'MM/DD/YYYY HH24:MI:SS');
  
        :new.JUSTIFICATION_CRT_ID := L_JUSTIFICATION_CRT_ID;
        :new.JUSTIFICATION_CRT_NAME := L_JUSTIFICATION_CRT_NAME;
        :new.JUSTIFICATION_CRT_DATE := L_JUSTIFICATION_CRT_DATE;
        :new.JUSTIFICATION_LASTMOD_DATE := TO_CHAR(SYSTIMESTAMP, 'MM/DD/YYYY HH24:MI:SS');
      ELSE
        IF (:new.JUSTIFICATION_MODIFIER_ID IS NOT NULL) THEN
          IF(:new.JUSTIFICATION_VER = 0) THEN
            L_JUSTIFICATION_CRT_ID   := :new.JUSTIFICATION_CRT_ID;
            L_JUSTIFICATION_CRT_NAME := :new.JUSTIFICATION_CRT_NAME;
            L_JUSTIFICATION_CRT_DATE := :new.JUSTIFICATION_CRT_DATE;
			L_JUSTIFICATION_VER := 1;
          ELSE
            L_JUSTIFICATION_CRT_ID   := :old.JUSTIFICATION_MODIFIER_ID;
            L_JUSTIFICATION_CRT_NAME := :old.JUSTIFICATION_MODIFIER_NAME;
            L_JUSTIFICATION_CRT_DATE := :old.JUSTIFICATION_MODIFIED_DATE;
			L_JUSTIFICATION_VER := :new.JUSTIFICATION_VER + 1;
          END IF;
          INSERT INTO INCENTIVES_SAM_JUST_HISTORY
          (
            PROC_ID,
            JUSTIFICATION_VER,
            JUSTIFICATION_MOD_REASON,
            JUSTIFICATION_MOD_SUMMARY,
            JUSTIFICATION_MODIFIER_NAME,
            JUSTIFICATION_MODIFIER_ID,
            JUSTIFICATION_MODIFIED_DATE,
            JUSTIFICATION_SUPER_QUAL_DESC,
            JUSTIFICATION_QUAL_COMP_DESC,
            JUSTIFICATION_PAY_EQUITY_DESC
          )
          VALUES
          (
            :new.PROC_ID,
            L_JUSTIFICATION_VER,
            :old.JUSTIFICATION_MOD_REASON,
            :old.JUSTIFICATION_MOD_SUMMARY,
            L_JUSTIFICATION_CRT_NAME,
            L_JUSTIFICATION_CRT_ID,
            L_JUSTIFICATION_CRT_DATE,
            :old.JUSTIFICATION_SUPER_QUAL_DESC,
            :old.JUSTIFICATION_QUAL_COMP_DESC,
            :old.JUSTIFICATION_PAY_EQUITY_DESC
          );
          :new.JUSTIFICATION_VER	:= L_JUSTIFICATION_VER;
          :new.JUSTIFICATION_LASTMOD_DATE := TO_CHAR(SYSTIMESTAMP, 'MM/DD/YYYY HH24:MI:SS');
        END IF;
      END IF;
    END IF;
		
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();

END;
/

CREATE OR REPLACE TRIGGER INCENTIVES_LE_BIUR
BEFORE INSERT OR UPDATE OF JUSTIFICATION_SKILL_EXP, JUSTIFICATION_AGENCY_GOAL, JUSTIFICATION_MOD_REASON, JUSTIFICATION_MOD_SUMMARY, JUSTIFICATION_MODIFIER_ID
ON INCENTIVES_LE
FOR EACH ROW
DECLARE
	L_JUSTIFICATION_CRT_ID   VARCHAR2(10);
	L_JUSTIFICATION_CRT_NAME VARCHAR2(100);
	L_JUSTIFICATION_CRT_DATE VARCHAR2(20);
	L_JUSTIFICATION_VER NUMBER(10);
BEGIN
		L_JUSTIFICATION_CRT_ID   := :new.JUSTIFICATION_CRT_ID;
		L_JUSTIFICATION_CRT_NAME := :new.JUSTIFICATION_CRT_NAME;
		L_JUSTIFICATION_CRT_DATE := :new.JUSTIFICATION_CRT_DATE;

    IF ((NVL(:old.JUSTIFICATION_SKILL_EXP, ' ') <> NVL(:new.JUSTIFICATION_SKILL_EXP, ' ')) OR 
		(NVL(:old.JUSTIFICATION_AGENCY_GOAL, ' ') <> NVL(:new.JUSTIFICATION_AGENCY_GOAL, ' ')) OR
		(NVL(:old.JUSTIFICATION_MOD_REASON, ' ') <> NVL(:new.JUSTIFICATION_MOD_REASON, ' ')) OR
		(NVL(:old.JUSTIFICATION_MOD_SUMMARY, ' ') <> NVL(:new.JUSTIFICATION_MOD_SUMMARY, ' ')) ) THEN
      IF (L_JUSTIFICATION_CRT_ID IS NULL) THEN
        L_JUSTIFICATION_CRT_ID   := :new.JUSTIFICATION_LASTMOD_ID;
        L_JUSTIFICATION_CRT_NAME := :new.JUSTIFICATION_LASTMOD_NAME;
        L_JUSTIFICATION_CRT_DATE := TO_CHAR(SYSTIMESTAMP, 'MM/DD/YYYY HH24:MI:SS');
  
        :new.JUSTIFICATION_CRT_ID := L_JUSTIFICATION_CRT_ID;
        :new.JUSTIFICATION_CRT_NAME := L_JUSTIFICATION_CRT_NAME;
        :new.JUSTIFICATION_CRT_DATE := L_JUSTIFICATION_CRT_DATE;
        :new.JUSTIFICATION_LASTMOD_DATE := TO_CHAR(SYSTIMESTAMP, 'MM/DD/YYYY HH24:MI:SS');
      ELSE
        IF (:new.JUSTIFICATION_MODIFIER_ID IS NOT NULL) THEN
          IF(:new.JUSTIFICATION_VER = 0) THEN
            L_JUSTIFICATION_CRT_ID   := :new.JUSTIFICATION_CRT_ID;
            L_JUSTIFICATION_CRT_NAME := :new.JUSTIFICATION_CRT_NAME;
            L_JUSTIFICATION_CRT_DATE := :new.JUSTIFICATION_CRT_DATE;
			L_JUSTIFICATION_VER := 1;
          ELSE
            L_JUSTIFICATION_CRT_ID   := :old.JUSTIFICATION_MODIFIER_ID;
            L_JUSTIFICATION_CRT_NAME := :old.JUSTIFICATION_MODIFIER_NAME;
            L_JUSTIFICATION_CRT_DATE := :old.JUSTIFICATION_MODIFIED_DATE;
			L_JUSTIFICATION_VER := :new.JUSTIFICATION_VER + 1;
          END IF;
          INSERT INTO INCENTIVES_LE_JUST_HISTORY
          (
            PROC_ID,
            JUSTIFICATION_VER,
            JUSTIFICATION_MOD_REASON,
            JUSTIFICATION_MOD_SUMMARY,
            JUSTIFICATION_MODIFIER_NAME,
            JUSTIFICATION_MODIFIER_ID,
            JUSTIFICATION_MODIFIED_DATE,
            JUSTIFICATION_SKILL_EXP,
            JUSTIFICATION_AGENCY_GOAL
          )
          VALUES
          (
            :new.PROC_ID,
            L_JUSTIFICATION_VER,
            :old.JUSTIFICATION_MOD_REASON,
            :old.JUSTIFICATION_MOD_SUMMARY,
            L_JUSTIFICATION_CRT_NAME,
            L_JUSTIFICATION_CRT_ID,
            L_JUSTIFICATION_CRT_DATE,
            :old.JUSTIFICATION_SKILL_EXP,
            :old.JUSTIFICATION_AGENCY_GOAL
          );
          :new.JUSTIFICATION_VER	:= L_JUSTIFICATION_VER;
          :new.JUSTIFICATION_LASTMOD_DATE := TO_CHAR(SYSTIMESTAMP, 'MM/DD/YYYY HH24:MI:SS');
        END IF;
      END IF;
    END IF;
		
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();

END;
/
