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
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcApprove', '/formData/items/item[id="approvalOHCValue"]/value/text()');
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
