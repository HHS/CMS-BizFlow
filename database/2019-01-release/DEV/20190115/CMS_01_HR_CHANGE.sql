--------------------------------------------------------
--  DDL for VW_ERLR_LABOR_NEGO
--------------------------------------------------------
CREATE OR REPLACE VIEW VW_ERLR_LABOR_NEGO
AS
SELECT
    LN.ERLR_CASE_NUMBER
    , EC.ERLR_JOB_REQ_NUMBER
    , EC.PROCID    
    , EC.ERLR_CASE_CREATE_DT
    , LN_NEGOTIATION_TYPE	
    , LN_INITIATOR
	, LN_DEMAND2BARGAIN_DT
	, LN_BRIEFING_REQUEST
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
	, LN_MNGMNT_ARTICLE4_NTC_DT
	, LN_MNGMNT_NOTICE_RESPONSE
	, LN_MNGMNT_BRIEFING_REQUEST
	, LN_MNGMNT_BARGAIN_SBMSSION_DT
	, LN_MNGMNT_PROPOSAL_SBMSSION
    , LN_BRIEFING_DT
    , LN_2ND_PROVIDED_DT
    , LN_BRIEFING_REQUESTED2_DT
FROM
	ERLR_LABOR_NEGO LN
    LEFT OUTER JOIN ERLR_CASE EC ON LN.ERLR_CASE_NUMBER = EC.ERLR_CASE_NUMBER
;
/

CREATE OR REPLACE VIEW VW_ERLR_GEN
AS
SELECT
    EG.ERLR_CASE_NUMBER
    , EC.ERLR_JOB_REQ_NUMBER
    , EC.PROCID    
    , EC.ERLR_CASE_CREATE_DT
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EG.GEN_PRIMARY_SPECIALIST AND ROWNUM = 1)  AS GEN_PRIMARY_SPECIALIST_NAME	
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EG.GEN_SECONDARY_SPECIALIST AND ROWNUM = 1)  AS GEN_SECONDARY_SPECIALIST_NAME
	, EG.GEN_CUSTOMER_NAME
	, EG.GEN_CUSTOMER_PHONE
	, EG.GEN_CUSTOMER_ADMIN_CD
	, EG.GEN_CUSTOMER_ADMIN_CD_DESC
	, EG.GEN_EMPLOYEE_NAME
	, EG.GEN_EMPLOYEE_PHONE
	, EG.GEN_EMPLOYEE_ADMIN_CD
	, EG.GEN_EMPLOYEE_ADMIN_CD_DESC
	, EG.GEN_CASE_DESC
	, (SELECT L.TBL_LABEL FROM TBL_LOOKUP L WHERE L.TBL_ID = EG.GEN_CASE_STATUS AND ROWNUM = 1) AS GEN_CASE_STATUS
	, EG.GEN_CUST_INIT_CONTACT_DT
	, EG.GEN_PRIMARY_REP_AFFILIATION
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EG.GEN_CMS_PRIMARY_REP_ID AND ROWNUM = 1) AS GEN_CMS_PRIMARY_REP_ID
	, EG.GEN_CMS_PRIMARY_REP_PHONE
	, EG.GEN_NON_CMS_PRIMARY_FNAME
	, EG.GEN_NON_CMS_PRIMARY_MNAME
	, EG.GEN_NON_CMS_PRIMARY_LNAME
	, EG.GEN_NON_CMS_PRIMARY_EMAIL
	, EG.GEN_NON_CMS_PRIMARY_PHONE
	, EG.GEN_NON_CMS_PRIMARY_ORG
	, EG.GEN_NON_CMS_PRIMARY_ADDR
	, (SELECT L.TBL_LABEL FROM TBL_LOOKUP L WHERE L.TBL_ID = EG.GEN_CASE_TYPE AND ROWNUM = 1) AS GEN_CASE_TYPE
	, FN_GET_CASE_CATEGORY(EG.GEN_CASE_CATEGORY) AS GEN_CASE_CATEGORY
	, EG.GEN_INVESTIGATION
	, EG.GEN_INVESTIGATE_START_DT
	, EG.GEN_INVESTIGATE_END_DT
	, EG.GEN_STD_CONDUCT
	, GEN_STD_CONDUCT_TYPE
	, CC_FINAL_ACTION
	, EG.CC_CASE_COMPLETE_DT
	, (SELECT STATE FROM BIZFLOW.PROCS P WHERE P.PROCID = EC.PROCID) AS BF_PROCS_STATE
  , ETPH.THRD_PRTY_APPEAL_TYPE
FROM
	ERLR_GEN EG
    LEFT OUTER JOIN ERLR_CASE EC ON EG.ERLR_CASE_NUMBER = EC.ERLR_CASE_NUMBER
    LEFT OUTER JOIN ERLR_3RDPARTY_HEAR ETPH ON EG.ERLR_CASE_NUMBER = ETPH.ERLR_CASE_NUMBER
;
/

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
                SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocDirector', '/formData/items/item[id="cocDirector"]/value/participantId/text()', '/formData/items/item[id="cocDirector"]/value/name/text()');
			ELSIF 'LE' = V_INCENTIVE_TYPE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'leSupport', '/formData/items/item[id="supportLE"]/value/text()');
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

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (774, 0, 'ERLRClosingReason', 'Case opened in error', 'Case opened in error', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (775, 0, 'ERLRClosingReason', 'Duplicate Case', 'Duplicate Case', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (776, 0, 'ERLRClosingReason', 'EEO Settlement', 'EEO Settlement', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (777, 0, 'ERLRClosingReason', 'Erroneous Information', 'Erroneous Information', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (778, 0, 'ERLRClosingReason', 'Employee Resigned', 'Employee Resigned', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (779, 0, 'ERLRClosingReason', 'Employee Retired', 'Employee Retired', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (780, 0, 'ERLRClosingReason', 'Employee Transferred', 'Employee Transferred', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (781, 0, 'ERLRClosingReason', 'Manager Decided Not to Pursue', 'Manager Decided Not to Pursue', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (782, 0, 'ERLRClosingReason', 'Management Direction', 'Management Direction', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (783, 0, 'ERLRClosingReason', 'Union Did Not Pursue Case', 'Union Did Not Pursue Case', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (784, 0, 'ERLRClosingReason', 'Completed', 'Completed', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
/

delete HHS_CMS_HR.ERLR_EMPLOYEE_CASE where (m_dt is not null or emp_last_name is null);
/
