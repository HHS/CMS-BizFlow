
SET DEFINE OFF;

CREATE OR REPLACE VIEW VW_INCENTIVES_PDP AS

SELECT FD.PROCID AS PROC_ID, X.*
FROM TBL_FORM_DTL FD,
     XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
	PDP_TYPE VARCHAR2(18) PATH './item[id="pdpType"]/value'
	,PDP_TYPE_OTHER	VARCHAR2(150)PATH './item[id="pdpTypeOther"]/value'
	,EXISTINGREQUEST	CHAR(1)PATH './item[id="associatedRequest"]/value'
	-- Position
	,WORK_SCHEDULE        VARCHAR2(15) PATH './item[id="workSchedule"]/value'
	,HOURS_PER_WEEK       VARCHAR2(5) PATH './item[id="hoursPerWeek"]/value'
	,BD_CERT_REQ          VARCHAR2(5) PATH './item[id="requireBoardCert"]/value'
	,LIC_INFO             VARCHAR2(140) PATH './item[id="licenseInfo"]/value'
	--Details
	,MARKET_PAY_RATE VARCHAR2(9) PATH './item[id="marketPayRate"]/value' 
	,CURRENT_FED_EMPLOYEE  CHAR(1) PATH './item[id="currentFederalEmployee"]/value' 
	,LEVEL_RESPONSIBILITY VARCHAR2(50) PATH './item[id="execRespLevelOfResponsability"]/value'
	,EXEC_RESP_AMT_REQUESTED NUMBER(10) PATH './item[id="execRespAmountRequested"]/value' 
	,EXEC_RESP_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="execRespJustification"]/value' 
	,EXPT_QF_Q1_AMT_REQUESTED NUMBER(10) PATH './item[id="excepQualAmountRequested_1"]/value' 
	,EXPT_QF_Q1_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_1"]/value' 
	,EXPT_QF_Q2_AMT_REQUESTED NUMBER(10) PATH './item[id="excepQualAmountRequested_2"]/value' 
	,EXPT_QF_Q2_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_2"]/value' 
	,EXPT_QF_Q3_AMT_REQUESTED NUMBER(10) PATH './item[id="excepQualAmountRequested_3"]/value' 
	,EXPT_QF_Q3_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_3"]/value' 
	,EXPT_QF_Q4_AMT_REQUESTED NUMBER(10) PATH './item[id="excepQualAmountRequested_4"]/value' 
	,EXPT_QF_Q4_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_4"]/value' 
	,EXPT_QF_Q5_AMT_REQUESTED NUMBER(10) PATH './item[id="excepQualAmountRequested_5"]/value' 
	,EXPT_QF_Q5_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_5"]/value' 
	,TOTAL_AMT_EXPT_QUALIFICATIONS NUMBER(10) PATH './item[id="excepQualTotalAmount"]/value'
	,CURRENT_PAY_GRADE NUMBER(2) PATH './item[id="currentPayInfoGrade"]/value' 
	,CURRENT_PAY_STEP NUMBER(2) PATH './item[id="currentPayInfoStep"]/value' 
	,CURRENT_PAY_POSITION_TITLE VARCHAR2(70) PATH './item[id="currentPayInfoPositionTitle"]/value' 
	,CURRENT_PAY_TABLE NUMBER(2) PATH './item[id="currentPayInfoTable"]/value' 
	,CURRENT_PAY_TIER NUMBER(2) PATH './item[id="currentPayInfoTier"]/value' 
	,CLINICAL_SPECIALTY_BOARD_CERT VARCHAR2(200) PATH './item[id="currentPayInfoSpecialtyCertification"]/value'
	,OTHER_SPECIALTY VARCHAR2(140) PATH './item[id="needvalue"]/value'
	,CURRENT_PAY_RECRUITMENT NUMBER(10) PATH './item[id="currentPayInfoRecruitment"]/value' 
	,CURRENT_PAY_RELOCATION NUMBER(10) PATH './item[id="currentPayInfoRelocation"]/value' 
	,CURRENT_PAY_RETENTION NUMBER(10) PATH './item[id="currentPayInfoRetention"]/value' 
	,CURRENT_PAY_3R_TOTAL NUMBER(10) PATH './item[id="currentPayInfoTotal3R"]/value' 
	,CURRENT_PAY_BASE NUMBER(10) PATH './item[id="currentPayInfoBasePay"]/value' 
	,CURRENT_PAY_LOCALITY_MARKET NUMBER(10) PATH './item[id="currentPayInfoLocality"]/value' 
	,CURRENT_PAY_TOTAL_ANNUAL_PAY NUMBER(10) PATH './item[id="currentPayInfoTotalAnnualPay"]/value' 
	,CURRENT_PAY_TOTAL_COMPENSATION NUMBER(10) PATH './item[id="currentPayInfoTotalAnnualComp"]/value' 
	,CURRENT_PAY_NOTES VARCHAR2(500) PATH './item[id="currentPayInfoNotes"]/value' 
	,PROPOSED_PAY_STEP NUMBER(2) PATH './item[id="proposedPayInfoStep"]/value' 
	,PROPOSED_PAY_TABLE NUMBER(2) PATH './item[id="proposedPayInfoTable"]/value' 
	,PROPOSED_PAY_TIER NUMBER(2) PATH './item[id="proposedPayInfoTier"]/value' 
	,PROPOSED_PAY_RECRUITMENT NUMBER(10) PATH './item[id="proposedPayInfoRecruitment"]/value' 
	,PROPOSED_PAY_RELOCATION NUMBER(10) PATH './item[id="proposedPayInfoRelocation"]/value' 
	,PROPOSED_PAY_RETENTION NUMBER(10) PATH './item[id="proposedPayInfoRetention"]/value' 
	,PROPOSED_PAY_TOTAL_3R NUMBER(10) PATH './item[id="proposedPayInfoTotal3R"]/value' 
	,PROPOSED_GS_BASE_PAY NUMBER(10) PATH './item[id="proposedPayInfoGSBasePay"]/value' 
	,PROPOSED_MARKET_PAY NUMBER(10) PATH './item[id="proposedPayInfoMarketPay"]/value' 
	,PROPOSED_TOTAL_ANNUAL_PAY NUMBER(10) PATH './item[id="currentPayInfoTotalAnnualPay_2"]/value'   
	,PROPOSED_TOTAL_ANNUAL_COMPENS NUMBER(10) PATH './item[id="proposedPayInfoTotalAnnualComp"]/value' 
	,INCENTIVES_APPROVED_BY_TABG VARCHAR2(3) PATH './item[id="proposedPayInfoIncentivesApprTABG"]/value' 
	,PROPOSED_PAY_NOTES VARCHAR2(500) PATH './item[id="proposedPayInfoNotes"]/value' 
	--Panel
	,DATE_OF_MEETING DATE PATH './item[id="panelDateOfMeeting"]/value' 
	,PANEL_MEMBER_NAME VARCHAR2(100) PATH './item[id="panelMemberName"]/value' 
	,PANEL_MEMBER_COMPONENT VARCHAR2(50) PATH './item[id="selectComponent"]/value' 
	,PANEL_ROLE VARCHAR2(9) PATH './item[id="selectPanelRole"]/value' 
	,VOTING_STATUS VARCHAR2(16) PATH './item[id="selectVotingStatus"]/value' 
	,PANEL_RECOMMENDED_COMPENSATION NUMBER(10) PATH './item[id="selectPanelRecommendedCompensation"]/value' 
	,QUORUM_REACHED CHAR(1) PATH './item[id="selectQuorumReached"]/value'
	,PANEL_CURRENT_SALARY NUMBER(10) PATH './item[id="currentSalary"]/value' 
	,PANEL_PDP_AMOUNT NUMBER(10) PATH './item[id="PDPAmount"]/value' 
	,PANEL_RECOMM_ANNUAL_SALARY NUMBER(10) PATH './item[id="panelRecommendedAnnualSalary"]/value' 
	--Approval and Review
	,SELECTING_OFFICIAL_REVIEWER VARCHAR2(100) PATH './item[id="SELECTING_OFFICIAL_REVIEWER"]/value' 
	,SELECTING_OFFICIAL_REVIEW_DT DATE PATH './item[id="SELECTING_OFFICIAL_REVIEW_DT"]/value' 
	,TABG_DIVISION_DIR_REVIEW_DT DATE PATH './item[id="TABG_DIVISION_DIR_REVIEW_DT"]/value' 
	,CMS_CHIEF_PHYSICIAN_REVIEW_DT DATE PATH './item[id="CMS_CHIEF_PHYSICIAN_REVIEW_DT"]/value' 
	,OFM_REVIEW_DATE DATE PATH './item[id="OFM_REVIEW_DATE"]/value' 
	,TABG_REVIEW_DATE DATE PATH './item[id="TABG_REVIEW_DATE"]/value' 
	,OHC_REVIEW_DATE DATE PATH './item[id="OHC_REVIEW_DATE"]/value' 
	,ADMINISTRATOR_APPROVAL_DATE DATE PATH './item[id="ADMINISTRATOR_APPROVAL_DATE"]/value'		
	) X
WHERE FD.FORM_TYPE = 'CMSINCENTIVES'
;
/

GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_PDP TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT ON HHS_CMS_HR.VW_INCENTIVES_PDP TO HHS_CMS_HR_DEV_ROLE;
