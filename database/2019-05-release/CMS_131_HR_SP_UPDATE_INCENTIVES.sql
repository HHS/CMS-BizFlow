SET DEFINE OFF;

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