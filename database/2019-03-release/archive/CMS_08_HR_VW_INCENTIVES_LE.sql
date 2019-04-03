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
	     ) X
WHERE FD.FORM_TYPE = 'CMSINCENTIVES'
;
/
