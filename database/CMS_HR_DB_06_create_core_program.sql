
SET DEFINE OFF;

--=============================================================================
-- Create STORED PROCEDURE for CMS project
-------------------------------------------------------------------------------



--------------------------------------------------------
--  DDL for Procedure SP_ERROR_LOG
--------------------------------------------------------

/**
 * Stores database errors to ERROR_LOG table to help troubleshooting.
 *
 */
CREATE OR REPLACE PROCEDURE SP_ERROR_LOG
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	V_CODE      PLS_INTEGER := SQLCODE;
	V_MSG       VARCHAR2(32767) := SQLERRM;
BEGIN
	INSERT INTO ERROR_LOG
	(
		ERROR_CD
		, ERROR_MSG
		, BACKTRACE
		, CALLSTACK
		, CRT_DT
		, CRT_USR
	)
	VALUES (
		V_CODE
		, V_MSG
		, SYS.DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
		, SYS.DBMS_UTILITY.FORMAT_CALL_STACK
		, SYSDATE
		, USER
	);

	COMMIT;
END;
/





--------------------------------------------------------
--  DDL for Procedure GET_REQUEST_NUM
--------------------------------------------------------
CREATE OR REPLACE PROCEDURE GET_REQUEST_NUM (P_REQUEST_NUM OUT VARCHAR2)
AS
	V_DATE DATE;
	V_SEQ NUMBER;
	V_NUM_OUT VARCHAR2(200);
BEGIN
	BEGIN
		SELECT RC_DATE, RC_SEQ INTO V_DATE, V_SEQ FROM REQUEST_CONTROL;
	EXCEPTION
		WHEN OTHERS THEN P_REQUEST_NUM := NULL;
		RETURN;
	END;
	IF TO_CHAR(V_DATE, 'YYYYMMDD') <> TO_CHAR(SYSDATE, 'YYYYMMDD') THEN
		BEGIN
			UPDATE REQUEST_CONTROL
			SET RC_DATE = SYSDATE
				, RC_SEQ = 1
				, RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-0001';
		END;
	ELSE
		BEGIN
			UPDATE REQUEST_CONTROL
			SET RC_SEQ = (V_SEQ + 1)
				, RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' ||
					TO_CHAR((V_SEQ + 1), 'FM0000');
		END;
	END IF;

	BEGIN
		SELECT RC_REQUEST_NUM INTO V_NUM_OUT FROM REQUEST_CONTROL;
	END;
	P_REQUEST_NUM := V_NUM_OUT;
EXCEPTION
	WHEN OTHERS THEN P_REQUEST_NUM := NULL;
	RETURN;
END GET_REQUEST_NUM;

/


--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_BY_XPATH
--------------------------------------------------------

/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * the Strategic Consultation process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 * @param I_RLVNTDATANAME - the name of a process variable to be updated
 * @param I_XPATH - the xpath of the value of a process variable
 * @param I_DISPXPATH - (optional) the xpath of the display value of a process variable
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_PV_BY_XPATH
(
	I_PROCID            IN      NUMBER
	, I_FIELD_DATA      IN      XMLTYPE
	, I_RLVNTDATANAME   IN     VARCHAR2
	, I_XPATH        IN VARCHAR2
  , I_DISPXPATH        IN VARCHAR2 DEFAULT NULL
)
IS
	V_XMLVALUE             XMLTYPE;
	V_VALUE                NVARCHAR2(2000);
	V_DISPVALUE                NVARCHAR2(100);
BEGIN

	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN

		V_DISPVALUE := NULL;

		V_XMLVALUE := I_FIELD_DATA.EXTRACT(I_XPATH);
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;

		IF I_DISPXPATH IS NOT NULL THEN
		  V_XMLVALUE := I_FIELD_DATA.EXTRACT(I_DISPXPATH);
			IF V_XMLVALUE IS NOT NULL THEN
				V_DISPVALUE := V_XMLVALUE.GETSTRINGVAL();
			ELSE
				V_DISPVALUE := NULL;
			END IF;

		END IF;

		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE, DISPVALUE = V_DISPVALUE WHERE RLVNTDATANAME = I_RLVNTDATANAME AND PROCID = I_PROCID;

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;

/


--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_INCENTIVES
--------------------------------------------------------

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
	V_VALUE                NVARCHAR2(2000);

	BEGIN
		--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
		--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
		--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
		--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
		--DBMS_OUTPUT.PUT_LINE(' ----------------');

		IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
			--DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'administrativeCode', '/formData/items/item[id="administrativeCode"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'associatedIncentives', '/formData/items/item[id="associatedIncentives"]/value/requestNumber/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'candidateName', '/formData/items/item[id="candidateName"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrSpecialist', '/formData/items/item[id="hrSpecialist"]/value/participantId/text()', '/formData/items/item[id="hrSpecialist"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'incentiveType', '/formData/items/item[id="incentiveType"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'payPlanSeriesGrade', '/formData/items/item[id="payPlanSeriesGrade"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'positionTitle', '/formData/items/item[id="positionTitle"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'relatedUserIds', '/formData/items/item[id="relatedUserIds"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'selectingOfficial', '/formData/items/item[id="selectingOfficial"]/value/participantId/text()', '/formData/items/item[id="selectingOfficial"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'pcaType', '/formData/items/item[id="pcaType"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'candidateAccept', '/formData/items/item[id="candiAgreeRenewal"]/value/text()');

			V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="processName"]/value/text()');
			IF V_XMLVALUE IS NOT NULL THEN
				V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			ELSE
				V_VALUE := NULL;
			END IF;

			IF 'PCA Incentives' = V_VALUE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'oaApprovalReq', '/formData/items/item[id="requireAdminApproval"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'dgoDirector', '/formData/items/item[id="dghoDirector"]/value/participantId/text()', '/formData/items/item[id="dghoDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'chiefMedicalOfficer', '/formData/items/item[id="chiefPhysician"]/value/participantId/text()', '/formData/items/item[id="chiefPhysician"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ofmDirector', '/formData/items/item[id="ofmDirector"]/value/participantId/text()', '/formData/items/item[id="ofmDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgDirector', '/formData/items/item[id="tabgDirector"]/value/participantId/text()', '/formData/items/item[id="tabgDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcDirector', '/formData/items/item[id="ohcDirector"]/value/participantId/text()', '/formData/items/item[id="ohcDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ofcAdmin', '/formData/items/item[id="offAdmin"]/value/participantId/text()', '/formData/items/item[id="offAdmin"]/value/name/text()');
			END IF;

		--DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

		END IF;

		EXCEPTION
		WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_INCENTIVES -------------------');
	END;

/

--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_ERLR
--------------------------------------------------------

/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * the ER/LR process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_PV_ERLR
(
	I_PROCID            IN      NUMBER
	, I_FIELD_DATA      IN      XMLTYPE
)
IS
	V_RLVNTDATANAME        VARCHAR2(100);
	V_VALUE                NVARCHAR2(2000);
	V_VALUE_LOOKUP         NVARCHAR2(2000);
	V_CURRENTDATE          DATE;
	V_CURRENTDATESTR       NVARCHAR2(30);
	V_VALUE_DATE           DATE;
	V_VALUE_DATESTR        NVARCHAR2(30);
	V_XMLVALUE             XMLTYPE;
BEGIN
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
	--DBMS_OUTPUT.PUT_LINE(' ----------------');

	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		--DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

		--SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseCategory', '/formData/items/item[id=''CASE_CATEGORY'']/value/text()');
		V_RLVNTDATANAME := 'caseCategory';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_CATEGORY'']/value/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseNumber', '/formData/items/item[id=''CASE_NUMBER'']/value/text()');
		
		
		--SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseStatus', '/formData/items/item[id=''CASE_STATUS'']/value/text()');
		V_RLVNTDATANAME := 'caseStatus';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_STATUS'']/value/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		--SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseType', '/formData/items/item[id=''CASE_TYPE'']/value/text()');
		V_RLVNTDATANAME := 'caseType';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_TYPE'']/value/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'contactName', '/formData/items/item[id=''GEN_CUSTCONTACT'']/value/text()');
		SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'employeeName', '/formData/items/item[id=''GEN_EMPCONTACT'']/value/text()');
		

		--SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'initialContactDate', '/formData/items/item[id=''CUSTOMER_CONTACT_DT'']/value/text()');
		V_RLVNTDATANAME := 'initialContactDate';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CUST_INIT_CONTACT_DT'']/value/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			-------------------------------------
			-- date format and GMT conversion
			-------------------------------------
			V_VALUE := TO_CHAR(SYS_EXTRACT_UTC(TO_DATE(V_VALUE, 'MM/DD/YYYY')), 'YYYY/MM/DD HH24:MI:SS');
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		--SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'lastModifiedDate', '/formData/items/item[id=''LAST_MOD_DT'']/value/text()');
		V_RLVNTDATANAME := 'lastModifiedDate';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''LAST_MOD_DT'']/value/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			-------------------------------------
			-- date format and GMT conversion
			-------------------------------------
			V_VALUE := TO_CHAR(SYS_EXTRACT_UTC(TO_DATE(V_VALUE, 'YYYY-MM-DD')), 'YYYY/MM/DD HH24:MI:SS');
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'organization',           '/formData/items/item[id=''EMP_ORG'']/value/text()');
		SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'primaryDWCSpecialist',   '/formData/items/item[id=''GEN_PRIMARY_SPECIALIST'']/value/text()');
		SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestNum',             '/formData/items/item[id=''REQ_NUMBER'']/value/text()');
		SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestStatusDate',      '/formData/items/item[id=''REQ_STATUS_DT'']/value/text()');
		SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'secondaryDWCSpecialist', '/formData/items/item[id=''GEN_SECONDARY_SPECIALIST'']/value/text()');

		--DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_ERLR -------------------');
END;

/




--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_STRATCON
--------------------------------------------------------

/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 t* the Strategic Consultation process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 */
create or replace PROCEDURE SP_UPDATE_PV_STRATCON
(
	I_PROCID            IN      NUMBER
	, I_FIELD_DATA      IN      XMLTYPE
)
IS
	V_RLVNTDATANAME        VARCHAR2(100);
	V_VALUE                NVARCHAR2(2000);
	V_VALUE_LOOKUP         NVARCHAR2(2000);
	V_CURRENTDATE          DATE;
	V_CURRENTDATESTR       NVARCHAR2(30);
	V_VALUE_DATE           DATE;
	V_VALUE_DATESTR        NVARCHAR2(30);
	V_REC_CNT              NUMBER(10);
	V_XMLDOC               XMLTYPE;
	V_XMLVALUE             XMLTYPE;
  V_VALUE1               NVARCHAR2(2000);
  V_VALUE2               NVARCHAR2(2000);
  V_VALUE3               NVARCHAR2(2000);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
	--DBMS_OUTPUT.PUT_LINE(' ----------------');
	--V_XMLDOC := XMLTYPE(I_FIELD_DATA);
	V_XMLDOC := I_FIELD_DATA;


	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		--DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

		V_RLVNTDATANAME := 'adminCode';
		--V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_AC_ID/text()');
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_ADMIN_CD/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		--	---------------------------------
		--	-- replace with admin code desc lookup value
		--	---------------------------------
		--	BEGIN
		--		SELECT AC_ADMIN_CD INTO V_VALUE_LOOKUP
		--		FROM ADMIN_CODES
		--		WHERE AC_ID = TO_NUMBER(V_VALUE);
		--	EXCEPTION
		--		WHEN NO_DATA_FOUND THEN
		--			V_VALUE_LOOKUP := NULL;
		--		WHEN OTHERS THEN
		--			V_VALUE_LOOKUP := NULL;
		--	END;
		--	V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'appointmentType';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_AT_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'cancelReason';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'candidateName';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_CNDT_FIRST_NM/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_CNDT_LAST_NM/text()');
		IF V_VALUE IS NOT NULL AND V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_VALUE || ' ' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'classSpecialist';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_CS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'classificationType';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_CT_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'hrLiaison';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_HRL_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'lastActivityCompDate';
		BEGIN
			SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
		EXCEPTION
			WHEN OTHERS THEN V_VALUE := NULL;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'meetingAckResponse';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/meetingAckResponse/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'meetingApvResponse';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/meetingApvResponse/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'meetingDate';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/MEETING/SSH_MEETING_SCHED_DT/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			-------------------------------------
			-- date format and GMT conversion
			-------------------------------------
			V_VALUE := TO_CHAR(SYS_EXTRACT_UTC(TO_DATE(V_VALUE, 'YYYY-MM-DD')), 'YYYY/MM/DD HH24:MI:SS');
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'meetingDateCutOff';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/MEETING/SSH_MEETING_SCHED_DT/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			-------------------------------------
			-- date format and GMT conversion
			-------------------------------------
			--V_VALUE := TO_CHAR(SYS_EXTRACT_UTC(TO_DATE(V_VALUE || ' 23:59:00', 'YYYY-MM-DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS');
			-- For current date, make the cutoff date past so that wait activity is completed immediately.
			-- For future date, subtract one day and make the time before midnight, i.e. 23:59.
			V_VALUE := TO_CHAR((SYS_EXTRACT_UTC(TO_DATE(V_VALUE || ' 23:59:00', 'YYYY-MM-DD HH24:MI:SS')) - 1), 'YYYY/MM/DD HH24:MI:SS');
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'meetingDateString';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/MEETING/SSH_MEETING_SCHED_DT/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			-------------------------------------
			-- date format for display
			-------------------------------------
			V_VALUE := TO_CHAR(TO_DATE(V_VALUE, 'YYYY-MM-DD'), 'MM/DD/YYYY');
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'meetingEmailRecipients';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/meetingEmailRecipients/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'meetingRecorders';
		--V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/meetingRecorders/text()');
---------------------------
-- TODO: currently mapped to only classSpecialist, but it should be able to handle multiple participants
---------------------------
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_CS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'meetingRequired';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/meetingRequired/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'meetingResched';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/meetingResched/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdClassSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_CS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		--V_RLVNTDATANAME := 'memIdExecOff';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_XO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();      
      SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;      
      SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
      SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;
            
      V_RLVNTDATANAME := 'memIdExecOff';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE1 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      
      IF V_VALUE1 IS NOT NULL THEN
        V_VALUE1 := '[U]' || V_VALUE1;
      END IF;  
      V_RLVNTDATANAME := 'execOfficer';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE1 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
    
      V_RLVNTDATANAME := 'memIdExecOff2';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE2 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      
      IF V_VALUE2 IS NOT NULL THEN
        V_VALUE2 := '[U]' || V_VALUE2;
      END IF;  
      V_RLVNTDATANAME := 'execOfficer2';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE2 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
    
      V_RLVNTDATANAME := 'memIdExecOff3';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE3 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      
      IF V_VALUE3 IS NOT NULL THEN
        V_VALUE3 := '[U]' || V_VALUE3;
      END IF;
      V_RLVNTDATANAME := 'execOfficer3';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE3 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      
    ELSE
			V_VALUE := NULL;
      
      V_RLVNTDATANAME := 'memIdExecOff';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
    
      V_RLVNTDATANAME := 'memIdExecOff2';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
    
      V_RLVNTDATANAME := 'memIdExecOff3';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      
      V_RLVNTDATANAME := 'execOfficer';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
    
      V_RLVNTDATANAME := 'execOfficer2';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
    
      V_RLVNTDATANAME := 'execOfficer3';
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;
    
    --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		


		V_RLVNTDATANAME := 'memIdHrLiaison';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_HRL_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdSelectOff';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_SO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdStaffSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_SS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posIs';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SUPERVISORY/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posLocation';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_LOCATION/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posPayPlan';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_PAY_PLAN_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				--WHERE TBL_ID = TO_NUMBER(V_VALUE);
				WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = V_VALUE;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posSensitivity';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SEC_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posSeries';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SERIES/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				--WHERE TBL_ID = TO_NUMBER(V_VALUE);
				WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = V_VALUE;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posSupervisor';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SUPERVISORY/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posTitle';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_TITLE/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'requestNum';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestNum/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'requestStatus';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatus/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'requestStatusDate';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatusDate/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			-------------------------------------
			-- even though it is date, do not format or perform GMT conversion
			-------------------------------------
			V_VALUE := V_VALUE;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'requestType';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_RT_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'returnToSOFromClassSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSOFromClassSpec/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- This pv can be updated from multiple workitem
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'returnToSOFromStaffSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSOFromStaffSpec/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- This pv can be updated from multiple workitem
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'secondSubOrg';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_ADMIN_CD/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with admin code desc lookup value
			---------------------------------
			BEGIN
				SELECT AC_ADMIN_CD_DESCR INTO V_VALUE_LOOKUP
				FROM ADMIN_CODES
				WHERE AC_ADMIN_CD = SUBSTR(V_VALUE, 1, 3);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'selectOfficial';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_SO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'selectOfficialReviewReq';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/selectOfficialReviewReq/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'smeEmailAddresses';
		V_VALUE := NULL;
		-- check and append SME_EMAIL_JA
		IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_JOB_ANALYSIS/text()') = 1
			AND I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_JOB_ANALYSIS/text()').GETSTRINGVAL() = 'true'
			AND I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_JA/text()') = 1
		THEN
			V_VALUE := V_VALUE || I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_JA/text()').GETSTRINGVAL() || ';';
		END IF;
		-- check and append SME_EMAIL_QUAL 1 and/or 2
		IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_QUALIFICATION/text()') = 1
			AND I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_QUALIFICATION/text()').GETSTRINGVAL() = 'true'
		THEN
			IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_1/text()') = 1
			THEN
				V_VALUE := V_VALUE || I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_1/text()').GETSTRINGVAL() || ';';
			END IF;
			IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_2/text()') = 1
			THEN
				V_VALUE := V_VALUE || I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_2/text()').GETSTRINGVAL() || ';';
			END IF;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'specialProgram';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/specialProgram/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'staffSpecialist';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_SS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			--V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
			-- If the Job Request is for Special Program, SG_SS_ID may point to User Group,
			-- rather than individual user.  Therefore, lookup
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			BEGIN
				SELECT TYPE INTO V_VALUE_LOOKUP FROM BIZFLOW.MEMBER WHERE MEMBERID = V_VALUE;
			EXCEPTION
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;

			IF V_VALUE_LOOKUP IS NOT NULL THEN
				V_VALUE := '[' || V_VALUE_LOOKUP || ']' || V_XMLVALUE.GETSTRINGVAL();
			ELSE
				V_VALUE := NULL;
			END IF;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'worksheetFeedbackClassSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/worksheetFeedbackClassSpec/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- This pv can be updated from multiple workitem
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'worksheetFeedbackSelectOfficial';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/worksheetFeedbackSelectOfficial/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'worksheetFeedbackStaffSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/worksheetFeedbackStaffSpec/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- This pv can be updated from multiple workitem
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		--DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_STRATCON -------------------');
END;







--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_STRATCON_DATA
--------------------------------------------------------
/**
 * Modifies the form data XML for Strategic Consultation for business rule.
 * Currently, it inserts a new meeting history record depending on the reschedule flag.
 *
 * @param I_XMLDOC_PREV - Previous form data xml from the existing record.
 * @param IO_XMLDOC - Form data xml as an input and output.
 *
 * @return IO_XMLDOC - Form data xml that is modified in accordance with business rule.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_STRATCON_DATA
(
	I_XMLDOC_PREV      IN     XMLTYPE
	, IO_XMLDOC        IN OUT XMLTYPE
)
IS
	V_IS_RESCHEDULE                 VARCHAR2(50);
	V_SCA_CLASS_SPEC_SIG_PREV       VARCHAR2(50);
	V_SCA_CLASS_SPEC_SIG_DT_PREV    VARCHAR2(50);
	V_SCA_STAFF_SIG_PREV            VARCHAR2(50);
	V_SCA_STAFF_SIG_DT_PREV         VARCHAR2(50);
	V_SCA_CLASS_SPEC_SIG            VARCHAR2(50);
	V_SCA_CLASS_SPEC_SIG_DT         VARCHAR2(50);
	V_SCA_STAFF_SIG                 VARCHAR2(50);
	V_SCA_STAFF_SIG_DT              VARCHAR2(50);
BEGIN
	----------------------------------
	-- MEETING_HISTORY
	----------------------------------
	SELECT LOWER(EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/IS_RESCHEDULE'))
	INTO V_IS_RESCHEDULE
	FROM DUAL;

	IF (V_IS_RESCHEDULE = 'true') THEN
		SELECT APPENDCHILDXML(IO_XMLDOC, 'DOCUMENT/MEETING/MEETING_HISTORY', XMLTYPE
				(
				'<record>' ||
					'<SSH_ID>'                  || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_ID')                  || '</SSH_ID>' ||
					'<SSH_MEETING_SCHED_DT>'    || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_MEETING_SCHED_DT')    || '</SSH_MEETING_SCHED_DT>' ||
					'<SSH_RESCHED_FROM_DT>'     || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_FROM_DT')     || '</SSH_RESCHED_FROM_DT>' ||
					'<SSH_RESCHED_REASON_ID>'   || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_REASON_ID')   || '</SSH_RESCHED_REASON_ID>' ||
					'<SSH_RESCHED_REASON_TEXT>' || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_REASON_TEXT') || '</SSH_RESCHED_REASON_TEXT>' ||
					'<SSH_RESCHED_COMMENTS>'    || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_COMMENTS')    || '</SSH_RESCHED_COMMENTS>' ||
					'<SSH_RESCHED_BY_ID>'       || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_BY_ID')       || '</SSH_RESCHED_BY_ID>' ||
					'<SSH_RESCHED_BY_NAME>'     || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_BY_NAME')     || '</SSH_RESCHED_BY_NAME>' ||
					'<SSH_RESCHED_ON>'          || TO_CHAR(SYS_EXTRACT_UTC(SYSTIMESTAMP), 'YYYY-MM-DD HH24:MI:SS')     || '</SSH_RESCHED_ON>' ||
				'</record>'
				))
		INTO IO_XMLDOC
		FROM DUAL;
	END IF;

	----------------------------------
	-- APPROVAL
	----------------------------------
	-- If there are multiple work items for one approval activity, and they are being approved at the same time,
	-- the signature data of the other will be overwritten (blanked out).  Prevent such overwrite.
	SELECT
		X.SCA_CLASS_SPEC_SIG_PREV
		, X.SCA_CLASS_SPEC_SIG_DT_PREV
		, X.SCA_STAFF_SIG_PREV
		, X.SCA_STAFF_SIG_DT_PREV
		, X.SCA_CLASS_SPEC_SIG
		, X.SCA_CLASS_SPEC_SIG_DT
		, X.SCA_STAFF_SIG
		, X.SCA_STAFF_SIG_DT
	INTO
		V_SCA_CLASS_SPEC_SIG_PREV
		, V_SCA_CLASS_SPEC_SIG_DT_PREV
		, V_SCA_STAFF_SIG_PREV
		, V_SCA_STAFF_SIG_DT_PREV
		, V_SCA_CLASS_SPEC_SIG
		, V_SCA_CLASS_SPEC_SIG_DT
		, V_SCA_STAFF_SIG
		, V_SCA_STAFF_SIG_DT
	FROM
		XMLTABLE('/DOCUMENT/APPROVAL'
			PASSING I_XMLDOC_PREV
			COLUMNS
				SCA_CLASS_SPEC_SIG_PREV             VARCHAR2(50)    PATH 'SCA_CLASS_SPEC_SIG'
				, SCA_CLASS_SPEC_SIG_DT_PREV        VARCHAR2(50)    PATH 'SCA_CLASS_SPEC_SIG_DT'
				, SCA_STAFF_SIG_PREV                VARCHAR2(50)    PATH 'SCA_STAFF_SIG'
				, SCA_STAFF_SIG_DT_PREV             VARCHAR2(50)    PATH 'SCA_STAFF_SIG_DT'
		) X
		, XMLTABLE('/DOCUMENT/APPROVAL'
			PASSING IO_XMLDOC
			COLUMNS
				SCA_CLASS_SPEC_SIG                  VARCHAR2(50)    PATH 'SCA_CLASS_SPEC_SIG'
				, SCA_CLASS_SPEC_SIG_DT             VARCHAR2(50)    PATH 'SCA_CLASS_SPEC_SIG_DT'
				, SCA_STAFF_SIG                     VARCHAR2(50)    PATH 'SCA_STAFF_SIG'
				, SCA_STAFF_SIG_DT                  VARCHAR2(50)    PATH 'SCA_STAFF_SIG_DT'
		) X
	;
	--DBMS_OUTPUT.PUT_LINE('    V_SCA_CLASS_SPEC_SIG_PREV       = ' || V_SCA_CLASS_SPEC_SIG_PREV);
	--DBMS_OUTPUT.PUT_LINE('    V_SCA_CLASS_SPEC_SIG_DT_PREV    = ' || V_SCA_CLASS_SPEC_SIG_DT_PREV);
	--DBMS_OUTPUT.PUT_LINE('    V_SCA_STAFF_SIG_PREV            = ' || V_SCA_STAFF_SIG_PREV);
	--DBMS_OUTPUT.PUT_LINE('    V_SCA_STAFF_SIG_DT_PREV         = ' || V_SCA_STAFF_SIG_DT_PREV);
	--DBMS_OUTPUT.PUT_LINE('    V_SCA_CLASS_SPEC_SIG       = ' || V_SCA_CLASS_SPEC_SIG);
	--DBMS_OUTPUT.PUT_LINE('    V_SCA_CLASS_SPEC_SIG_DT    = ' || V_SCA_CLASS_SPEC_SIG_DT);
	--DBMS_OUTPUT.PUT_LINE('    V_SCA_STAFF_SIG            = ' || V_SCA_STAFF_SIG);
	--DBMS_OUTPUT.PUT_LINE('    V_SCA_STAFF_SIG_DT         = ' || V_SCA_STAFF_SIG_DT);
	--IF V_SCA_CLASS_SPEC_SIG IS NULL THEN
	--	DBMS_OUTPUT.PUT_LINE('V_SCA_CLASS_SPEC_SIG IS DETECTED AS NULL');
	--END IF;
	--IF V_SCA_STAFF_SIG IS NULL THEN
	--	DBMS_OUTPUT.PUT_LINE('V_SCA_STAFF_SIG IS DETECTED AS NULL');
	--END IF;

	IF (V_SCA_CLASS_SPEC_SIG IS NOT NULL AND V_SCA_STAFF_SIG IS NULL AND V_SCA_STAFF_SIG_PREV IS NOT NULL)
		OR (V_SCA_STAFF_SIG IS NOT NULL AND V_SCA_CLASS_SPEC_SIG IS NULL AND V_SCA_CLASS_SPEC_SIG_PREV IS NOT NULL)
	THEN
		--SELECT DELETEXML(IO_XMLDOC, '/DOCUMENT/APPROVAL/SCA_STAFF_SIG') INTO IO_XMLDOC FROM DUAL;
		--SELECT DELETEXML(IO_XMLDOC, '/DOCUMENT/APPROVAL/SCA_STAFF_SIG_DT') INTO IO_XMLDOC FROM DUAL;
		--SELECT APPENDCHILDXML(IO_XMLDOC , '/DOCUMENT/APPROVAL', XMLTYPE(
		--		'<SCA_STAFF_SIG>'    || V_SCA_STAFF_SIG_PREV    || '</SCA_STAFF_SIG>'
		--	))
		--INTO IO_XMLDOC
		--FROM DUAL;
		--SELECT APPENDCHILDXML(IO_XMLDOC , '/DOCUMENT/APPROVAL', XMLTYPE(
		--		'<SCA_STAFF_SIG_DT>' || V_SCA_STAFF_SIG_DT_PREV || '</SCA_STAFF_SIG_DT>'
		--	))
		--INTO IO_XMLDOC
		--FROM DUAL;

		--SELECT DELETEXML(IO_XMLDOC, '/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG') INTO IO_XMLDOC FROM DUAL;
		--SELECT DELETEXML(IO_XMLDOC, '/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG_DT') INTO IO_XMLDOC FROM DUAL;
		--SELECT APPENDCHILDXML(IO_XMLDOC , '/DOCUMENT/APPROVAL', XMLTYPE(
		--		'<SCA_CLASS_SPEC_SIG>'    || V_SCA_CLASS_SPEC_SIG_PREV    || '</SCA_CLASS_SPEC_SIG>'
		--	))
		--INTO IO_XMLDOC
		--FROM DUAL;
		--SELECT APPENDCHILDXML(IO_XMLDOC , '/DOCUMENT/APPROVAL', XMLTYPE(
		--		'<SCA_CLASS_SPEC_SIG_DT>' || V_SCA_CLASS_SPEC_SIG_DT_PREV || '</SCA_CLASS_SPEC_SIG_DT>'
		--	))
		--INTO IO_XMLDOC
		--FROM DUAL;

		SELECT
			XMLQUERY('
				declare function local:retain-sig($elem as element()) {
					if (
						local-name($elem) = "SCA_CLASS_SPEC_SIG" and not($elem/text()) and $xpre/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG/text()
						and
						not (
							($elem/../SCA_STAFF_SIG/text() and $xpre/DOCUMENT/APPROVAL/SCA_STAFF_SIG/text())
							or
							(not($elem/../SCA_STAFF_SIG/text()) and not($xpre/DOCUMENT/APPROVAL/SCA_STAFF_SIG/text()))
						)
					) then
						element {node-name($elem)}
							{
								$xpre/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG/text()
							}
					else if (
						local-name($elem) = "SCA_CLASS_SPEC_SIG_DT" and not($elem/text()) and $xpre/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG_DT/text()
						and
						not (
							($elem/../SCA_STAFF_SIG/text() and $xpre/DOCUMENT/APPROVAL/SCA_STAFF_SIG/text())
							or
							(not($elem/../SCA_STAFF_SIG/text()) and not($xpre/DOCUMENT/APPROVAL/SCA_STAFF_SIG/text()))
						)
					) then
						element {node-name($elem)}
							{
								$xpre/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG_DT/text()
							}
					else if (
						local-name($elem) = "SCA_STAFF_SIG" and not($elem/text()) and $xpre/DOCUMENT/APPROVAL/SCA_STAFF_SIG/text()
						and
						not (
							($elem/../SCA_CLASS_SPEC_SIG/text() and $xpre/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG/text())
							or
							(not($elem/../SCA_CLASS_SPEC_SIG/text()) and not($xpre/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG/text()))
						)
					) then
						element {node-name($elem)}
							{
								$xpre/DOCUMENT/APPROVAL/SCA_STAFF_SIG/text()
							}
					else if (
						local-name($elem) = "SCA_STAFF_SIG_DT" and not($elem/text()) and $xpre/DOCUMENT/APPROVAL/SCA_STAFF_SIG_DT/text()
						and
						not (
							($elem/../SCA_CLASS_SPEC_SIG/text() and $xpre/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG/text())
							or
							(not($elem/../SCA_CLASS_SPEC_SIG/text()) and not($xpre/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG/text()))
						)
					) then
						element {node-name($elem)}
							{
								$xpre/DOCUMENT/APPROVAL/SCA_STAFF_SIG_DT/text()
							}
					else
						element {node-name($elem)}
							{
								for $child in $elem/node()
								return
									if ($child instance of element()) then local:retain-sig($child)
									else $child
							}
				};

				local:retain-sig($xdoc/*)
				'
				PASSING I_XMLDOC_PREV AS "xpre", IO_XMLDOC AS "xdoc" RETURNING CONTENT
			)
		INTO IO_XMLDOC
		FROM DUAL;

	END IF;


EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_STRATCON_DATA -------------------');
END;

/








--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_STRATCONHIST_TABLE
--------------------------------------------------------
/**
 * Parses Strategic Consultation form XML data and stores it
 * into the operational table for Strategic Consultation History.
 *
 * @param I_PROCID - Process ID
 * @param I_JOB_REQ_ID - Job Request ID
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_STRATCONHIST_TABLE
(
	I_PROCID               IN      NUMBER
	, I_JOB_REQ_ID         IN      NUMBER
)
IS
	V_CLOBVALUE                 CLOB;
	V_VALUE                     NVARCHAR2(4000);
	V_VALUE_LOOKUP              NVARCHAR2(2000);
	V_REC_CNT                   NUMBER(10);
	V_XMLREC_CNT                NUMBER(10);
	V_SSH_ID                    NUMBER(10);
	V_XMLDOC                    XMLTYPE;
	V_XMLVALUE                  XMLTYPE;
	V_ISRESCHEDULE              NUMBER(1);
	V_ISMTGFORRESCHED           NUMBER(1);
	V_HISTORYEXISTS             NUMBER(1);
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
	E_INVALID_PROCID            EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_PROCID, -20901);
	E_INVALID_JOB_REQ_ID        EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
	E_INVALID_STRATCONHIST_DATA EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_STRATCONHIST_DATA, -20906);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_STRATCONHIST_TABLE - BEGIN ============================');
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?      = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID               = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    I_JOB_REQ_ID IS NULL?  = ' || (CASE WHEN I_JOB_REQ_ID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_JOB_REQ_ID           = ' || TO_CHAR(I_JOB_REQ_ID));
	--DBMS_OUTPUT.PUT_LINE(' ----------------');

	IF I_PROCID IS NULL OR I_PROCID <= 0 THEN
		RAISE_APPLICATION_ERROR(-20901, 'SP_UPDATE_STRATCONHIST_TABLE: Process ID is invalid.  I_PROCID = '
			|| TO_CHAR(I_PROCID) || '  I_JOB_REQ_ID = ' || TO_CHAR(I_JOB_REQ_ID));
	END IF;

	IF I_JOB_REQ_ID IS NULL OR I_JOB_REQ_ID <= 0 THEN
		RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_STRATCONHIST_TABLE: Job Request ID is invalid.  I_PROCID = '
			|| TO_CHAR(I_PROCID) || '  I_JOB_REQ_ID = ' || TO_CHAR(I_JOB_REQ_ID));
	END IF;


	--------------------------------
	-- STRATCON_SCHED_HIST table
	--------------------------------

	BEGIN
		-- Inspect xml data status
		BEGIN
			SELECT
				FD.FIELD_DATA
				, CASE
					WHEN XMLQUERY('/DOCUMENT/MEETING/IS_RESCHEDULE/text()'
						PASSING FD.FIELD_DATA RETURNING CONTENT).GETSTRINGVAL() = 'true'
					THEN 1
					ELSE 0
				END AS IS_RESCHEDULE
				, CASE
					WHEN XMLEXISTS('data($sc/DOCUMENT/MEETING/MEETING_HISTORY/record)'
						PASSING FD.FIELD_DATA AS "sc")
					THEN 1
					ELSE 0
				END AS HISTORY_EXISTS
				, TO_NUMBER(XMLQUERY('count(/DOCUMENT/MEETING/MEETING_HISTORY/record)'
					PASSING FD.FIELD_DATA RETURNING CONTENT).GETSTRINGVAL())
			INTO V_XMLDOC, V_ISRESCHEDULE, V_HISTORYEXISTS, V_XMLREC_CNT
			FROM TBL_FORM_DTL FD
			WHERE FD.PROCID = I_PROCID;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_XMLDOC := NULL;
				V_ISRESCHEDULE := 0;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_ISRESCHEDULE  = ' || TO_CHAR(V_ISRESCHEDULE));
		--DBMS_OUTPUT.PUT_LINE('    V_HISTORYEXISTS = ' || TO_CHAR(V_HISTORYEXISTS));
		--DBMS_OUTPUT.PUT_LINE('    V_XMLREC_CNT    = ' || TO_CHAR(V_XMLREC_CNT));


		-- Inspect table record status
		BEGIN
			SELECT COUNT(*) INTO V_REC_CNT FROM STRATCON_SCHED_HIST WHERE SSH_REQ_ID = I_JOB_REQ_ID;
			IF V_REC_CNT > 1 THEN
				V_ISRESCHEDULE := 1;
			ELSIF V_REC_CNT = 1 THEN
				SELECT CASE WHEN SSH_RESCHED_ON IS NOT NULL THEN 1 ELSE 0 END AS ISRESCHEDULE
				INTO V_ISRESCHEDULE
				FROM STRATCON_SCHED_HIST
				WHERE SSH_REQ_ID = I_JOB_REQ_ID;
			ELSE
				V_ISRESCHEDULE := 0;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_REC_CNT := 0;
				V_ISRESCHEDULE := 0;
			WHEN OTHERS THEN
				SP_ERROR_LOG();
				V_REC_CNT := NULL;
				V_ISRESCHEDULE := 0;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_REC_CNT              = ' || TO_CHAR(V_REC_CNT));
		--DBMS_OUTPUT.PUT_LINE('    V_ISRESCHEDULE (reset) = ' || TO_CHAR(V_ISRESCHEDULE));


		IF V_XMLREC_CNT IS NOT NULL AND V_XMLREC_CNT > 1 AND V_XMLREC_CNT >= V_REC_CNT THEN
			--DBMS_OUTPUT.PUT_LINE('    Merge multiple historical records xml to table');
			-- Multiple historical records
			MERGE INTO STRATCON_SCHED_HIST TRG
			USING
			(
				SELECT
					I_JOB_REQ_ID AS SSH_REQ_ID
					, X.SSH_ID
					, X.SSH_MEETING_SCHED_DT
					, X.SSH_RESCHED_FROM_DT
					, X.SSH_RESCHED_REASON_ID
					, X.SSH_RESCHED_REASON_TEXT
					, X.SSH_RESCHED_COMMENTS
					, X.SSH_RESCHED_BY_ID
					, X.SSH_RESCHED_BY_NAME
					, TO_DATE(X.SSH_RESCHED_ON_STR, 'YYYY-MM-DD HH24:MI:SS') AS SSH_RESCHED_ON
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/MEETING/MEETING_HISTORY/record'
						PASSING FD.FIELD_DATA
						COLUMNS
							SSH_ID                              NUMBER(20)      PATH 'SSH_ID'
							, SSH_MEETING_SCHED_DT              DATE            PATH 'SSH_MEETING_SCHED_DT'
							, SSH_RESCHED_FROM_DT               DATE            PATH 'SSH_RESCHED_FROM_DT'
							, SSH_RESCHED_REASON_ID             NUMBER(20)      PATH 'SSH_RESCHED_REASON_ID'
							, SSH_RESCHED_REASON_TEXT           NVARCHAR2(140)  PATH 'SSH_RESCHED_REASON_TEXT'
							, SSH_RESCHED_COMMENTS              NVARCHAR2(140)  PATH 'SSH_RESCHED_COMMENTS'
							, SSH_RESCHED_BY_ID                 NVARCHAR2(10)   PATH 'SSH_RESCHED_BY_ID'
							, SSH_RESCHED_BY_NAME               NVARCHAR2(100)  PATH 'SSH_RESCHED_BY_NAME'
							, SSH_RESCHED_ON_STR                NVARCHAR2(50)   PATH 'SSH_RESCHED_ON'
					) X
				WHERE FD.PROCID = I_PROCID
					AND X.SSH_RESCHED_ON_STR IS NOT NULL
				ORDER BY X.SSH_RESCHED_ON_STR, X.SSH_ID
			) SRC ON (SRC.SSH_REQ_ID = TRG.SSH_REQ_ID AND SRC.SSH_RESCHED_ON = TRG.SSH_RESCHED_ON)
			WHEN MATCHED THEN UPDATE SET
				TRG.SSH_MEETING_SCHED_DT       = SRC.SSH_MEETING_SCHED_DT
				, TRG.SSH_RESCHED_FROM_DT      = SRC.SSH_RESCHED_FROM_DT
				, TRG.SSH_RESCHED_REASON_ID    = SRC.SSH_RESCHED_REASON_ID
				, TRG.SSH_RESCHED_REASON_TEXT  = SRC.SSH_RESCHED_REASON_TEXT
				, TRG.SSH_RESCHED_COMMENTS     = SRC.SSH_RESCHED_COMMENTS
				, TRG.SSH_RESCHED_BY_ID        = SRC.SSH_RESCHED_BY_ID
				, TRG.SSH_RESCHED_BY_NAME      = SRC.SSH_RESCHED_BY_NAME
				--, TRG.SSH_RESCHED_ON           = SRC.SSH_RESCHED_ON
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.SSH_REQ_ID
				, TRG.SSH_MEETING_SCHED_DT
				, TRG.SSH_RESCHED_FROM_DT
				, TRG.SSH_RESCHED_REASON_ID
				, TRG.SSH_RESCHED_REASON_TEXT
				, TRG.SSH_RESCHED_COMMENTS
				, TRG.SSH_RESCHED_BY_ID
				, TRG.SSH_RESCHED_BY_NAME
				, TRG.SSH_RESCHED_ON
			)
			VALUES
			(
				SRC.SSH_REQ_ID
				, SRC.SSH_MEETING_SCHED_DT
				, SRC.SSH_RESCHED_FROM_DT
				, SRC.SSH_RESCHED_REASON_ID
				, SRC.SSH_RESCHED_REASON_TEXT
				, SRC.SSH_RESCHED_COMMENTS
				, SRC.SSH_RESCHED_BY_ID
				, SRC.SSH_RESCHED_BY_NAME
				, SRC.SSH_RESCHED_ON
			)
			WHERE V_XMLREC_CNT > V_REC_CNT
			;
		ELSIF V_XMLREC_CNT IS NOT NULL AND V_XMLREC_CNT = 1 THEN
			--DBMS_OUTPUT.PUT_LINE('    Merge one historical record xml to table');
			-- One historical record in xml, it is both current and one prior history record.
			MERGE INTO STRATCON_SCHED_HIST TRG
			USING
			(
				SELECT
					I_JOB_REQ_ID AS SSH_REQ_ID
					, X.SSH_ID
					, X.SSH_MEETING_SCHED_DT
					, X.SSH_RESCHED_FROM_DT
					, X.SSH_RESCHED_REASON_ID
					, X.SSH_RESCHED_REASON_TEXT
					, X.SSH_RESCHED_COMMENTS
					, X.SSH_RESCHED_BY_ID
					, X.SSH_RESCHED_BY_NAME
					, TO_DATE(X.SSH_RESCHED_ON_STR, 'YYYY-MM-DD HH24:MI:SS') AS SSH_RESCHED_ON
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/MEETING/MEETING_HISTORY/record'
						PASSING FD.FIELD_DATA
						COLUMNS
							SSH_ID                              NUMBER(20)      PATH 'SSH_ID'
							, SSH_MEETING_SCHED_DT              DATE            PATH 'SSH_MEETING_SCHED_DT'
							, SSH_RESCHED_FROM_DT               DATE            PATH 'SSH_RESCHED_FROM_DT'
							, SSH_RESCHED_REASON_ID             NUMBER(20)      PATH 'SSH_RESCHED_REASON_ID'
							, SSH_RESCHED_REASON_TEXT           NVARCHAR2(140)  PATH 'SSH_RESCHED_REASON_TEXT'
							, SSH_RESCHED_COMMENTS              NVARCHAR2(140)  PATH 'SSH_RESCHED_COMMENTS'
							, SSH_RESCHED_BY_ID                 NVARCHAR2(10)   PATH 'SSH_RESCHED_BY_ID'
							, SSH_RESCHED_BY_NAME               NVARCHAR2(100)  PATH 'SSH_RESCHED_BY_NAME'
							, SSH_RESCHED_ON_STR                NVARCHAR2(50)   PATH 'SSH_RESCHED_ON'
					) X
				WHERE FD.PROCID = I_PROCID
					AND X.SSH_RESCHED_ON_STR IS NOT NULL
				ORDER BY X.SSH_RESCHED_ON_STR, X.SSH_ID
			) SRC ON (SRC.SSH_REQ_ID = TRG.SSH_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.SSH_MEETING_SCHED_DT       = SRC.SSH_MEETING_SCHED_DT
				, TRG.SSH_RESCHED_FROM_DT      = SRC.SSH_RESCHED_FROM_DT
				, TRG.SSH_RESCHED_REASON_ID    = SRC.SSH_RESCHED_REASON_ID
				, TRG.SSH_RESCHED_REASON_TEXT  = SRC.SSH_RESCHED_REASON_TEXT
				, TRG.SSH_RESCHED_COMMENTS     = SRC.SSH_RESCHED_COMMENTS
				, TRG.SSH_RESCHED_BY_ID        = SRC.SSH_RESCHED_BY_ID
				, TRG.SSH_RESCHED_BY_NAME      = SRC.SSH_RESCHED_BY_NAME
				, TRG.SSH_RESCHED_ON           = SRC.SSH_RESCHED_ON
			WHERE V_REC_CNT = 1
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.SSH_REQ_ID
				, TRG.SSH_MEETING_SCHED_DT
				, TRG.SSH_RESCHED_FROM_DT
				, TRG.SSH_RESCHED_REASON_ID
				, TRG.SSH_RESCHED_REASON_TEXT
				, TRG.SSH_RESCHED_COMMENTS
				, TRG.SSH_RESCHED_BY_ID
				, TRG.SSH_RESCHED_BY_NAME
				, TRG.SSH_RESCHED_ON
			)
			VALUES
			(
				SRC.SSH_REQ_ID
				, SRC.SSH_MEETING_SCHED_DT
				, SRC.SSH_RESCHED_FROM_DT
				, SRC.SSH_RESCHED_REASON_ID
				, SRC.SSH_RESCHED_REASON_TEXT
				, SRC.SSH_RESCHED_COMMENTS
				, SRC.SSH_RESCHED_BY_ID
				, SRC.SSH_RESCHED_BY_NAME
				, SRC.SSH_RESCHED_ON
			)
			WHERE V_REC_CNT = 0;
		ELSE
			--DBMS_OUTPUT.PUT_LINE('    Merge current record xml to table');
			-- No historical record in xml, only current record.
			MERGE INTO STRATCON_SCHED_HIST TRG
			USING
			(
				SELECT
					I_JOB_REQ_ID AS SSH_REQ_ID
					, X.SSH_ID
					, X.SSH_MEETING_SCHED_DT
					, X.SSH_RESCHED_FROM_DT
					, X.SSH_RESCHED_REASON_ID
					, X.SSH_RESCHED_REASON_TEXT
					, X.SSH_RESCHED_COMMENTS
					, X.SSH_RESCHED_BY_ID
					, X.SSH_RESCHED_BY_NAME
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/MEETING'
						PASSING FD.FIELD_DATA
						COLUMNS
							SSH_ID                              NUMBER(20)      PATH 'SSH_ID'
							, SSH_MEETING_SCHED_DT              DATE            PATH 'SSH_MEETING_SCHED_DT'
							, SSH_RESCHED_FROM_DT               DATE            PATH 'SSH_RESCHED_FROM_DT'
							, SSH_RESCHED_REASON_ID             NUMBER(20)      PATH 'SSH_RESCHED_REASON_ID'
							, SSH_RESCHED_REASON_TEXT           NVARCHAR2(140)  PATH 'SSH_RESCHED_REASON_TEXT'
							, SSH_RESCHED_COMMENTS              NVARCHAR2(140)  PATH 'SSH_RESCHED_COMMENTS'
							, SSH_RESCHED_BY_ID                 NVARCHAR2(10)   PATH 'SSH_RESCHED_BY_ID'
							, SSH_RESCHED_BY_NAME               NVARCHAR2(100)  PATH 'SSH_RESCHED_BY_NAME'
					) X
				WHERE FD.PROCID = I_PROCID
			--) SRC ON (SRC.SSH_REQ_ID = TRG.SSH_REQ_ID AND SRC.SSH_MEETING_SCHED_DT = TRG.SSH_MEETING_SCHED_DT)
			) SRC ON (SRC.SSH_REQ_ID = TRG.SSH_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.SSH_MEETING_SCHED_DT       = SRC.SSH_MEETING_SCHED_DT
				, TRG.SSH_RESCHED_FROM_DT      = SRC.SSH_RESCHED_FROM_DT
				, TRG.SSH_RESCHED_REASON_ID    = SRC.SSH_RESCHED_REASON_ID
				, TRG.SSH_RESCHED_REASON_TEXT  = SRC.SSH_RESCHED_REASON_TEXT
				, TRG.SSH_RESCHED_COMMENTS     = SRC.SSH_RESCHED_COMMENTS
				, TRG.SSH_RESCHED_BY_ID        = SRC.SSH_RESCHED_BY_ID
				, TRG.SSH_RESCHED_BY_NAME      = SRC.SSH_RESCHED_BY_NAME
			WHERE V_REC_CNT = 1
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.SSH_REQ_ID
				, TRG.SSH_MEETING_SCHED_DT
				, TRG.SSH_RESCHED_FROM_DT
				, TRG.SSH_RESCHED_REASON_ID
				, TRG.SSH_RESCHED_REASON_TEXT
				, TRG.SSH_RESCHED_COMMENTS
				, TRG.SSH_RESCHED_BY_ID
				, TRG.SSH_RESCHED_BY_NAME
			)
			VALUES
			(
				SRC.SSH_REQ_ID
				, SRC.SSH_MEETING_SCHED_DT
				, SRC.SSH_RESCHED_FROM_DT
				, SRC.SSH_RESCHED_REASON_ID
				, SRC.SSH_RESCHED_REASON_TEXT
				, SRC.SSH_RESCHED_COMMENTS
				, SRC.SSH_RESCHED_BY_ID
				, SRC.SSH_RESCHED_BY_NAME
			)
			WHERE V_REC_CNT = 0;
		END IF;

		------------------------------
		-- Sync table data to xml
		------------------------------
		IF V_XMLREC_CNT IS NOT NULL AND V_XMLREC_CNT > 0 THEN
			--DBMS_OUTPUT.PUT_LINE('    Update meeting history record xml');
			SELECT
				XMLELEMENT("MEETING_HISTORY",
					XMLAGG(
						XMLELEMENT("record",
							XMLELEMENT("SSH_ID",                    SSH_ID)
							, XMLELEMENT("SSH_MEETING_SCHED_DT",    SSH_MEETING_SCHED_DT)
							, XMLELEMENT("SSH_RESCHED_FROM_DT",     SSH_RESCHED_FROM_DT)
							, XMLELEMENT("SSH_RESCHED_REASON_ID",   SSH_RESCHED_REASON_ID)
							, XMLELEMENT("SSH_RESCHED_REASON_TEXT", SSH_RESCHED_REASON_TEXT)
							, XMLELEMENT("SSH_RESCHED_COMMENTS",    SSH_RESCHED_COMMENTS)
							, XMLELEMENT("SSH_RESCHED_BY_ID",       SSH_RESCHED_BY_ID)
							, XMLELEMENT("SSH_RESCHED_BY_NAME",     SSH_RESCHED_BY_NAME)
							, XMLELEMENT("SSH_RESCHED_ON",          TO_CHAR(SSH_RESCHED_ON, 'YYYY-MM-DD HH24:MI:SS'))
						)
					)
				)
				--.GETCLOBVAL()
			INTO V_XMLVALUE
			FROM STRATCON_SCHED_HIST
			WHERE SSH_REQ_ID = I_JOB_REQ_ID
			ORDER BY SSH_RESCHED_ON, SSH_ID
			;
			-- Update form detail meeting history section
			IF V_XMLVALUE IS NOT NULL THEN
				UPDATE TBL_FORM_DTL
				SET FIELD_DATA = UPDATEXML(FIELD_DATA, '/DOCUMENT/MEETING/MEETING_HISTORY', V_XMLVALUE)
				WHERE PROCID = I_PROCID;
			END IF;
		ELSE
			--DBMS_OUTPUT.PUT_LINE('    Update meeting record xml');
			SELECT
				XMLELEMENT("MEETING",
					XMLELEMENT("SSH_ID",                    SSH_ID)
					, XMLELEMENT("SSH_MEETING_SCHED_DT",    SSH_MEETING_SCHED_DT)
					, XMLELEMENT("SSH_RESCHED_FROM_DT",     SSH_RESCHED_FROM_DT)
					, XMLELEMENT("SSH_RESCHED_REASON_ID",   SSH_RESCHED_REASON_ID)
					, XMLELEMENT("SSH_RESCHED_REASON_TEXT", SSH_RESCHED_REASON_TEXT)
					, XMLELEMENT("SSH_RESCHED_COMMENTS",    SSH_RESCHED_COMMENTS)
					, XMLELEMENT("SSH_RESCHED_BY_ID",       SSH_RESCHED_BY_ID)
					, XMLELEMENT("SSH_RESCHED_BY_NAME",     SSH_RESCHED_BY_NAME)
				)
				--.GETCLOBVAL()
			INTO V_XMLVALUE
			FROM STRATCON_SCHED_HIST
			WHERE SSH_REQ_ID = I_JOB_REQ_ID
			;
			-- Update form detail meeting section
			IF V_XMLVALUE IS NOT NULL THEN
				UPDATE TBL_FORM_DTL
				SET FIELD_DATA = UPDATEXML(FIELD_DATA, '/DOCUMENT/MEETING', V_XMLVALUE)
				WHERE PROCID = I_PROCID;
			END IF;
		END IF;


	EXCEPTION
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20906, 'SP_UPDATE_STRATCONHIST_TABLE: Invalid STRATCON HIST data.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || '  I_JOB_REQ_ID = ' || TO_CHAR(I_JOB_REQ_ID));
	END;


EXCEPTION
	WHEN E_INVALID_PROCID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCONHIST_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
	WHEN E_INVALID_JOB_REQ_ID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCONHIST_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
	WHEN E_INVALID_STRATCONHIST_DATA THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCONHIST_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCONHIST_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
END;

/




--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_STRATCON_TABLE
--------------------------------------------------------

/**
 * Parses Strategic Consultation form XML data and stores it
 * into the operational tables for Strategic Consultation.
 *
 * @param I_PROCID - Process ID
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_STRATCON_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
	V_JOB_REQ_ID                NUMBER(20);
	V_JOB_REQ_NUM               NVARCHAR2(50);
	V_CLOBVALUE                 CLOB;
	V_VALUE                     NVARCHAR2(4000);
	V_VALUE_LOOKUP              NVARCHAR2(2000);
	V_REC_CNT                   NUMBER(10);
	--V_SSH_ID                    NUMBER(10);
	V_XMLDOC                    XMLTYPE;
	V_XMLVALUE                  XMLTYPE;
	--V_ISMODIFIED                NUMBER(1);
	--V_ISRESCHEDULED             NUMBER(1);
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
	E_INVALID_PROCID            EXCEPTION;
	E_INVALID_JOB_REQ_ID        EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
	E_INVALID_STRATCON_DATA     EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_STRATCON_DATA, -20905);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_STRATCON_TABLE - BEGIN ============================');
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE(' ----------------');


	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		------------------------------------------------------
		-- Transfer XML data into operational table
		--
		-- 1. Get Job Request Number
		-- 1.1 Select it from data xml from TBL_FORM_DTL table.
		-- 1.2 If not found, select it from BIZFLOW.RLVNTDATA table.
		-- 2. If Job Request Number not found in REQUEST table, insert record and get the ID.
		-- 3. For each target table,
		-- 3.1. If record found for the REQ_ID, update record.
		-- 3.2. If record not found for the REQ_ID, insert record.
		------------------------------------------------------
		--DBMS_OUTPUT.PUT_LINE('Starting xml data retrieval and table update ----------');

		--------------------------------
		-- get Job Request Number
		--------------------------------
		BEGIN
			SELECT XMLQUERY('/DOCUMENT/PROCESS_VARIABLE/requestNum/text()'
				PASSING FD.FIELD_DATA RETURNING CONTENT).GETSTRINGVAL()
				, FD.FIELD_DATA
			INTO V_JOB_REQ_NUM, V_XMLDOC
			FROM TBL_FORM_DTL FD
			WHERE FD.PROCID = I_PROCID;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_NUM := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (from xml) = ' || V_JOB_REQ_NUM);
		IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
			BEGIN
				SELECT VALUE
				INTO V_JOB_REQ_NUM
				FROM BIZFLOW.RLVNTDATA
				WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'requestNum';
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_JOB_REQ_NUM := NULL;
					RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_STRATCON_TABLE: Job Request Number is invalid.  I_PROCID = '
						|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
			END;
		END IF;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (after pv check) = ' || V_JOB_REQ_NUM);
		IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_STRATCON_TABLE: Job Request Number is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END IF;

		--------------------------------
		-- REQUEST table
		--------------------------------
		--DBMS_OUTPUT.PUT_LINE('    REQUEST table');
		BEGIN
			SELECT REQ_ID INTO V_JOB_REQ_ID
			FROM REQUEST
			WHERE REQ_JOB_REQ_NUMBER = V_JOB_REQ_NUM;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_ID := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('        V_JOB_REQ_ID before = ' || V_JOB_REQ_ID);

		IF V_JOB_REQ_ID IS NULL THEN
			INSERT INTO REQUEST	(REQ_JOB_REQ_NUMBER, REQ_JOB_REQ_CREATE_DT)
			VALUES (V_JOB_REQ_NUM, SYSDATE)
			RETURN REQ_ID INTO V_JOB_REQ_ID;
		END IF;

		--DBMS_OUTPUT.PUT_LINE('        V_JOB_REQ_ID after = ' || V_JOB_REQ_ID);
		IF V_JOB_REQ_ID IS NULL THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_STRATCON_TABLE: Job Request ID is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END IF;

		BEGIN
			--------------------------------
			-- REQUEST table update for cancellation
			--------------------------------
			MERGE INTO REQUEST TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS REQ_ID
					, V_JOB_REQ_NUM AS REQ_JOB_REQ_NUMBER
					, X.REQ_CANCEL_DT_STR
					, TO_DATE(X.REQ_CANCEL_DT_STR, 'YYYY/MM/DD HH24:MI:SS') AS REQ_CANCEL_DT
					, X.REQ_CANCEL_REASON
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/PROCESS_VARIABLE'
						PASSING FD.FIELD_DATA
						COLUMNS
							REQ_CANCEL_DT_STR                   NVARCHAR2(30)   PATH 'if (requestStatus/text() = "Request Cancelled") then requestStatusDate else ""'
							, REQ_CANCEL_REASON                 NVARCHAR2(140)  PATH 'cancelReason'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.REQ_ID = TRG.REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.REQ_CANCEL_DT           = SRC.REQ_CANCEL_DT
				, TRG.REQ_CANCEL_REASON     = SRC.REQ_CANCEL_REASON
			;
		END;


		BEGIN

			--------------------------------
			-- STRATCON_GEN table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    STRATCON_GEN table');
			MERGE INTO STRATCON_GEN TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS SG_REQ_ID
					, I_PROCID AS SG_PROCID
					, X.SG_AC_ID
					, X.SG_ADMIN_CD
					, X.SG_RT_ID
					, X.SG_CT_ID
					, X.SG_AT_ID
					, X.SG_VT_ID
					, X.SG_SAT_ID
					, X.SG_SO_ID
					, X.SG_SO_TITLE
					, X.SG_SO_ORG
					, X.SG_XO_ID
					, X.SG_XO_TITLE
					, X.SG_XO_ORG
					, X.SG_HRL_ID
					, X.SG_HRL_TITLE
					, X.SG_HRL_ORG
					, X.SG_SS_ID
					, X.SG_CS_ID
					, X.SG_SO_AGREE
					, X.SG_OTHER_CERT
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/GENERAL'
						PASSING FD.FIELD_DATA
						COLUMNS
							SG_AC_ID                            NUMBER(20)      PATH 'SG_AC_ID'
							, SG_ADMIN_CD                       NVARCHAR2(8)    PATH 'SG_ADMIN_CD'
							, SG_RT_ID                          NUMBER(20)      PATH 'SG_RT_ID'
							, SG_CT_ID                          NUMBER(20)      PATH 'SG_CT_ID'
							, SG_AT_ID                          NUMBER(20)      PATH 'SG_AT_ID'
							, SG_VT_ID                          NUMBER(20)      PATH 'SG_VT_ID'
							, SG_SAT_ID                         NUMBER(20)      PATH 'SG_SAT_ID'
							, SG_SO_ID                          NVARCHAR2(10)   PATH 'SG_SO_ID'
							, SG_SO_TITLE                       NVARCHAR2(50)   PATH 'SG_SO_TITLE'
							, SG_SO_ORG                         NVARCHAR2(50)   PATH 'SG_SO_ORG'
							, SG_XO_ID                          NVARCHAR2(32)   PATH 'SG_XO_ID'
							, SG_XO_TITLE                       NVARCHAR2(200)   PATH 'SG_XO_TITLE'
							, SG_XO_ORG                         NVARCHAR2(200)   PATH 'SG_XO_ORG'
							, SG_HRL_ID                         NVARCHAR2(10)   PATH 'SG_HRL_ID'
							, SG_HRL_TITLE                      NVARCHAR2(50)   PATH 'SG_HRL_TITLE'
							, SG_HRL_ORG                        NVARCHAR2(50)   PATH 'SG_HRL_ORG'
							, SG_SS_ID                          NVARCHAR2(10)   PATH 'SG_SS_ID'
							, SG_CS_ID                          NVARCHAR2(10)   PATH 'SG_CS_ID'
							, SG_SO_AGREE                       CHAR(1)         PATH 'if (SG_SO_AGREE/text() = "true") then 1 else 0'
							, SG_OTHER_CERT                     NVARCHAR2(200)  PATH 'SG_OTHER_CERT'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.SG_REQ_ID = TRG.SG_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.SG_PROCID       = SRC.SG_PROCID
				, TRG.SG_AC_ID      = SRC.SG_AC_ID
				, TRG.SG_ADMIN_CD   = SRC.SG_ADMIN_CD
				, TRG.SG_RT_ID      = SRC.SG_RT_ID
				, TRG.SG_CT_ID      = SRC.SG_CT_ID
				, TRG.SG_AT_ID      = SRC.SG_AT_ID
				, TRG.SG_VT_ID      = SRC.SG_VT_ID
				, TRG.SG_SAT_ID     = SRC.SG_SAT_ID
				, TRG.SG_SO_ID      = SRC.SG_SO_ID
				, TRG.SG_SO_TITLE   = SRC.SG_SO_TITLE
				, TRG.SG_SO_ORG     = SRC.SG_SO_ORG
				, TRG.SG_XO_ID      = SRC.SG_XO_ID
				, TRG.SG_XO_TITLE   = SRC.SG_XO_TITLE
				, TRG.SG_XO_ORG     = SRC.SG_XO_ORG
				, TRG.SG_HRL_ID     = SRC.SG_HRL_ID
				, TRG.SG_HRL_TITLE  = SRC.SG_HRL_TITLE
				, TRG.SG_HRL_ORG    = SRC.SG_HRL_ORG
				, TRG.SG_SS_ID      = SRC.SG_SS_ID
				, TRG.SG_CS_ID      = SRC.SG_CS_ID
				, TRG.SG_SO_AGREE   = SRC.SG_SO_AGREE
				, TRG.SG_OTHER_CERT = SRC.SG_OTHER_CERT
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.SG_REQ_ID
				, TRG.SG_PROCID
				, TRG.SG_AC_ID
				, TRG.SG_ADMIN_CD
				, TRG.SG_RT_ID
				, TRG.SG_CT_ID
				, TRG.SG_AT_ID
				, TRG.SG_VT_ID
				, TRG.SG_SAT_ID
				, TRG.SG_SO_ID
				, TRG.SG_SO_TITLE
				, TRG.SG_SO_ORG
				, TRG.SG_XO_ID
				, TRG.SG_XO_TITLE
				, TRG.SG_XO_ORG
				, TRG.SG_HRL_ID
				, TRG.SG_HRL_TITLE
				, TRG.SG_HRL_ORG
				, TRG.SG_SS_ID
				, TRG.SG_CS_ID
				, TRG.SG_SO_AGREE
				, TRG.SG_OTHER_CERT
			)
			VALUES
			(
				SRC.SG_REQ_ID
				, SRC.SG_PROCID
				, SRC.SG_AC_ID
				, SRC.SG_ADMIN_CD
				, SRC.SG_RT_ID
				, SRC.SG_CT_ID
				, SRC.SG_AT_ID
				, SRC.SG_VT_ID
				, SRC.SG_SAT_ID
				, SRC.SG_SO_ID
				, SRC.SG_SO_TITLE
				, SRC.SG_SO_ORG
				, SRC.SG_XO_ID
				, SRC.SG_XO_TITLE
				, SRC.SG_XO_ORG
				, SRC.SG_HRL_ID
				, SRC.SG_HRL_TITLE
				, SRC.SG_HRL_ORG
				, SRC.SG_SS_ID
				, SRC.SG_CS_ID
				, SRC.SG_SO_AGREE
				, SRC.SG_OTHER_CERT
			)
			;


			--------------------------------
			-- POSITION table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    POSITION table');
			MERGE INTO POSITION TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS POS_REQ_ID
					, X.POS_CNDT_LAST_NM
					, X.POS_CNDT_FIRST_NM
					, X.POS_CNDT_MIDDLE_NM
					, X.POS_BGT_APR_OFM
					, X.POS_SPNSR_ORG_NM
					, X.POS_SPNSR_ORG_FUND_PC
					, X.POS_TITLE
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = X.POS_PAY_PLAN_ID AND ROWNUM = 1) AS POS_PAY_PLAN_ID
					, X.POS_SERIES
					, X.POS_DESC_NUMBER_1
					, X.POS_CLASSIFICATION_DT_1
					--, X.POS_GRADE_1
					, CASE WHEN LENGTH(X.POS_GRADE_1) = 1 THEN '0' || X.POS_GRADE_1 ELSE X.POS_GRADE_1 END AS POS_GRADE_1
					, X.POS_DESC_NUMBER_2
					, X.POS_CLASSIFICATION_DT_2
					--, X.POS_GRADE_2
					, CASE WHEN LENGTH(X.POS_GRADE_2) = 1 THEN '0' || X.POS_GRADE_2 ELSE X.POS_GRADE_2 END AS POS_GRADE_2
					, X.POS_DESC_NUMBER_3
					, X.POS_CLASSIFICATION_DT_3
					--, X.POS_GRADE_3
					, CASE WHEN LENGTH(X.POS_GRADE_3) = 1 THEN '0' || X.POS_GRADE_3 ELSE X.POS_GRADE_3 END AS POS_GRADE_3
					, X.POS_DESC_NUMBER_4
					, X.POS_CLASSIFICATION_DT_4
					--, X.POS_GRADE_4
					, CASE WHEN LENGTH(X.POS_GRADE_4) = 1 THEN '0' || X.POS_GRADE_4 ELSE X.POS_GRADE_4 END AS POS_GRADE_4
					, X.POS_DESC_NUMBER_5
					, X.POS_CLASSIFICATION_DT_5
					--, X.POS_GRADE_5
					, CASE WHEN LENGTH(X.POS_GRADE_5) = 1 THEN '0' || X.POS_GRADE_5 ELSE X.POS_GRADE_5 END AS POS_GRADE_5
					, X.POS_MED_OFFICERS_ID
					--, X.POS_PERFORMANCE_LEVEL
					, CASE WHEN LENGTH(X.POS_PERFORMANCE_LEVEL) = 1 THEN '0' || X.POS_PERFORMANCE_LEVEL ELSE X.POS_PERFORMANCE_LEVEL END AS POS_PERFORMANCE_LEVEL
					, X.POS_SUPERVISORY
					, X.POS_SKILL
					, X.POS_LOCATION
					, X.POS_VACANCIES
					, X.POS_REPORT_SUPERVISOR
					, X.POS_CAN
					, X.POS_VICE
					, X.POS_VICE_NAME
					, X.POS_DAYS_ADVERTISED
					, X.POS_AT_ID
					, X.POS_NTE
					, X.POS_WORK_SCHED_ID
					, X.POS_HOURS_PER_WEEK
					, X.POS_DUAL_EMPLMT
					, X.POS_SEC_ID
					, X.POS_CE_FINANCIAL_DISC
					, X.POS_CE_FINANCIAL_TYPE_ID
					, X.POS_CE_PE_PHYSICAL
					, X.POS_CE_DRUG_TEST
					, X.POS_CE_IMMUN
					, X.POS_CE_TRAVEL
					, X.POS_CE_TRAVEL_PER
					, X.POS_CE_LIC
					, X.POS_CE_LIC_INFO
					, X.POS_REMARKS
					, X.POS_PROC_REQ_TYPE
					, X.POS_RECRUIT_OFFICE_ID
					, X.POS_REQ_CREATE_NOTIFY_DT
					, X.POS_SO_ID
					, X.POS_ASSOC_DESCR_NUMBERS
					, X.POS_PROMOTE_POTENTIAL
					, X.POS_VICE_EMPL_ID
					, X.POS_SR_ID
					, X.POS_GR_ID
					, X.POS_AC_ID
					, X.POS_GA_1
					, X.POS_GA_2
					, X.POS_GA_3
					, X.POS_GA_4
					, X.POS_GA_5
					, X.POS_GA_6
					, X.POS_GA_7
					, X.POS_GA_8
					, X.POS_GA_9
					, X.POS_GA_10
					, X.POS_GA_11
					, X.POS_GA_12
					, X.POS_GA_13
					, X.POS_GA_14
					, X.POS_GA_15
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/POSITION'
						PASSING FD.FIELD_DATA
						COLUMNS
							POS_CNDT_LAST_NM                    NVARCHAR2(50)   PATH 'POS_CNDT_LAST_NM'
							, POS_CNDT_FIRST_NM                 NVARCHAR2(50)   PATH 'POS_CNDT_FIRST_NM'
							, POS_CNDT_MIDDLE_NM                NVARCHAR2(50)   PATH 'POS_CNDT_MIDDLE_NM'
							, POS_BGT_APR_OFM                   CHAR(1)         PATH 'POS_BGT_APR_OFM'
							, POS_SPNSR_ORG_NM                  NVARCHAR2(140)  PATH 'POS_SPNSR_ORG_NM'
							, POS_SPNSR_ORG_FUND_PC             NUMBER(3,0)     PATH 'POS_SPNSR_ORG_FUND_PC'
							, POS_TITLE                         NVARCHAR2(140)  PATH 'POS_TITLE'
							, POS_PAY_PLAN_ID                   VARCHAR2(140)   PATH 'POS_PAY_PLAN_ID'
							, POS_SERIES                        VARCHAR2(140)   PATH 'POS_SERIES'
							, POS_DESC_NUMBER_1                 VARCHAR2(140)   PATH 'POS_DESC_NUMBER_1'
							, POS_CLASSIFICATION_DT_1           DATE            PATH 'POS_CLASSIFICATION_DT_1'
							--, POS_GRADE_1                       NUMBER(2)       PATH 'POS_GRADE_1'
							, POS_GRADE_1                       VARCHAR2(2)     PATH 'POS_GRADE_1'
							, POS_DESC_NUMBER_2                 VARCHAR2(140)   PATH 'POS_DESC_NUMBER_2'
							, POS_CLASSIFICATION_DT_2           DATE            PATH 'POS_CLASSIFICATION_DT_2'
							--, POS_GRADE_2                       NUMBER(2)       PATH 'POS_GRADE_2'
							, POS_GRADE_2                       VARCHAR2(2)     PATH 'POS_GRADE_2'
							, POS_DESC_NUMBER_3                 VARCHAR2(140)   PATH 'POS_DESC_NUMBER_3'
							, POS_CLASSIFICATION_DT_3           DATE            PATH 'POS_CLASSIFICATION_DT_3'
							--, POS_GRADE_3                       NUMBER(2)       PATH 'POS_GRADE_3'
							, POS_GRADE_3                       VARCHAR2(2)     PATH 'POS_GRADE_3'
							, POS_DESC_NUMBER_4                 VARCHAR2(140)   PATH 'POS_DESC_NUMBER_4'
							, POS_CLASSIFICATION_DT_4           DATE            PATH 'POS_CLASSIFICATION_DT_4'
							--, POS_GRADE_4                       NUMBER(2)       PATH 'POS_GRADE_4'
							, POS_GRADE_4                       VARCHAR2(2)     PATH 'POS_GRADE_4'
							, POS_DESC_NUMBER_5                 VARCHAR2(140)   PATH 'POS_DESC_NUMBER_5'
							, POS_CLASSIFICATION_DT_5           DATE            PATH 'POS_CLASSIFICATION_DT_5'
							--, POS_GRADE_5                       NUMBER(2)       PATH 'POS_GRADE_5'
							, POS_GRADE_5                       VARCHAR2(2)     PATH 'POS_GRADE_5'
							, POS_MED_OFFICERS_ID               NUMBER(20)      PATH 'POS_MED_OFFICERS_ID'
							--, POS_PERFORMANCE_LEVEL             NVARCHAR2(50)   PATH 'POS_PERFORMANCE_LEVEL'
							, POS_PERFORMANCE_LEVEL             NVARCHAR2(2)    PATH 'POS_PERFORMANCE_LEVEL'
	--TODO: actual value for POS_SUPERVISORY is numeric ID to lookup table.  Need to change data type to NUMBER(20)
							, POS_SUPERVISORY                   NVARCHAR2(50)   PATH 'POS_SUPERVISORY'
							, POS_SKILL                         NVARCHAR2(200)  PATH 'POS_SKILL'
							, POS_LOCATION                      NVARCHAR2(2000) PATH 'POS_LOCATION'
							, POS_VACANCIES                     NUMBER(9)       PATH 'POS_VACANCIES'
							, POS_REPORT_SUPERVISOR             NVARCHAR2(10)   PATH 'POS_REPORT_SUPERVISOR'
							, POS_CAN                           NVARCHAR2(8)    PATH 'POS_CAN'
							, POS_VICE                          CHAR(1)         PATH 'POS_VICE'
							, POS_VICE_NAME                     NVARCHAR2(50)   PATH 'POS_VICE_NAME'
							, POS_DAYS_ADVERTISED               NVARCHAR2(50)   PATH 'POS_DAYS_ADVERTISED'
							, POS_AT_ID                         NUMBER(20)      PATH 'POS_AT_ID'
							, POS_NTE                           NVARCHAR2(140)  PATH 'POS_NTE'
							, POS_WORK_SCHED_ID                 NUMBER(20)      PATH 'POS_WORK_SCHED_ID'
							, POS_HOURS_PER_WEEK                NVARCHAR2(50)   PATH 'POS_HOURS_PER_WEEK'
							, POS_DUAL_EMPLMT                   NVARCHAR2(10)   PATH 'POS_DUAL_EMPLMT'
							, POS_SEC_ID                        NUMBER(20)      PATH 'POS_SEC_ID'
							, POS_CE_FINANCIAL_DISC             CHAR(1)         PATH 'if (POS_CE_FINANCIAL_DISC/text() = "true") then 1 else 0'
							, POS_CE_FINANCIAL_TYPE_ID          NUMBER(20)      PATH 'POS_CE_FINANCIAL_TYPE_ID'
							, POS_CE_PE_PHYSICAL                CHAR(1)         PATH 'if (POS_CE_PE_PHYSICAL/text() = "true") then 1 else 0'
							, POS_CE_DRUG_TEST                  CHAR(1)         PATH 'if (POS_CE_DRUG_TEST/text() = "true") then 1 else 0'
							, POS_CE_IMMUN                      CHAR(1)         PATH 'if (POS_CE_IMMUN/text() = "true") then 1 else 0'
							, POS_CE_TRAVEL                     CHAR(1)         PATH 'if (POS_CE_TRAVEL/text() = "true") then 1 else 0'
							, POS_CE_TRAVEL_PER                 NVARCHAR2(3)    PATH 'POS_CE_TRAVEL_PER'
							, POS_CE_LIC                        CHAR(1)         PATH 'if (POS_CE_LIC/text() = "true") then 1 else 0'
							, POS_CE_LIC_INFO                   NVARCHAR2(140)  PATH 'POS_CE_LIC_INFO'
							, POS_REMARKS                       NVARCHAR2(500)  PATH 'POS_REMARKS'
							, POS_PROC_REQ_TYPE                 NUMBER(20)      PATH 'POS_PROC_REQ_TYPE'
							, POS_RECRUIT_OFFICE_ID             NUMBER(20)      PATH 'POS_RECRUIT_OFFICE_ID'
							, POS_REQ_CREATE_NOTIFY_DT          DATE            PATH 'POS_REQ_CREATE_NOTIFY_DT'
							, POS_SO_ID                         NUMBER(9)       PATH 'POS_SO_ID'
							, POS_ASSOC_DESCR_NUMBERS           NVARCHAR2(100)  PATH 'POS_ASSOC_DESCR_NUMBERS'
							, POS_PROMOTE_POTENTIAL             NUMBER(2)       PATH 'POS_PROMOTE_POTENTIAL'
							, POS_VICE_EMPL_ID                  NVARCHAR2(25)   PATH 'POS_VICE_EMPL_ID'
							, POS_SR_ID                         NUMBER(20)      PATH 'POS_SR_ID'
							, POS_GR_ID                         NUMBER(20)      PATH 'POS_GR_ID'
							, POS_AC_ID                         NUMBER(20)      PATH 'POS_AC_ID'
							, POS_GA_1                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_1/text() = "true") then 1 else 0'
							, POS_GA_2                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_2/text() = "true") then 1 else 0'
							, POS_GA_3                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_3/text() = "true") then 1 else 0'
							, POS_GA_4                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_4/text() = "true") then 1 else 0'
							, POS_GA_5                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_5/text() = "true") then 1 else 0'
							, POS_GA_6                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_6/text() = "true") then 1 else 0'
							, POS_GA_7                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_7/text() = "true") then 1 else 0'
							, POS_GA_8                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_8/text() = "true") then 1 else 0'
							, POS_GA_9                          CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_9/text() = "true") then 1 else 0'
							, POS_GA_10                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_10/text() = "true") then 1 else 0'
							, POS_GA_11                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_11/text() = "true") then 1 else 0'
							, POS_GA_12                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_12/text() = "true") then 1 else 0'
							, POS_GA_13                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_13/text() = "true") then 1 else 0'
							, POS_GA_14                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_14/text() = "true") then 1 else 0'
							, POS_GA_15                         CHAR(1)         PATH 'if (GRADE_ADVERTISED/POS_GA_15/text() = "true") then 1 else 0'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.POS_REQ_ID = TRG.POS_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.POS_CNDT_LAST_NM            = SRC.POS_CNDT_LAST_NM
				, TRG.POS_CNDT_FIRST_NM         = SRC.POS_CNDT_FIRST_NM
				, TRG.POS_CNDT_MIDDLE_NM        = SRC.POS_CNDT_MIDDLE_NM
				, TRG.POS_BGT_APR_OFM           = SRC.POS_BGT_APR_OFM
				, TRG.POS_SPNSR_ORG_NM          = SRC.POS_SPNSR_ORG_NM
				, TRG.POS_SPNSR_ORG_FUND_PC     = SRC.POS_SPNSR_ORG_FUND_PC
				, TRG.POS_TITLE                 = SRC.POS_TITLE
				, TRG.POS_PAY_PLAN_ID           = SRC.POS_PAY_PLAN_ID
				, TRG.POS_SERIES                = SRC.POS_SERIES
				, TRG.POS_DESC_NUMBER_1         = SRC.POS_DESC_NUMBER_1
				, TRG.POS_CLASSIFICATION_DT_1   = SRC.POS_CLASSIFICATION_DT_1
				, TRG.POS_GRADE_1               = SRC.POS_GRADE_1
				, TRG.POS_DESC_NUMBER_2         = SRC.POS_DESC_NUMBER_2
				, TRG.POS_CLASSIFICATION_DT_2   = SRC.POS_CLASSIFICATION_DT_2
				, TRG.POS_GRADE_2               = SRC.POS_GRADE_2
				, TRG.POS_DESC_NUMBER_3         = SRC.POS_DESC_NUMBER_3
				, TRG.POS_CLASSIFICATION_DT_3   = SRC.POS_CLASSIFICATION_DT_3
				, TRG.POS_GRADE_3               = SRC.POS_GRADE_3
				, TRG.POS_DESC_NUMBER_4         = SRC.POS_DESC_NUMBER_4
				, TRG.POS_CLASSIFICATION_DT_4   = SRC.POS_CLASSIFICATION_DT_4
				, TRG.POS_GRADE_4               = SRC.POS_GRADE_4
				, TRG.POS_DESC_NUMBER_5         = SRC.POS_DESC_NUMBER_5
				, TRG.POS_CLASSIFICATION_DT_5   = SRC.POS_CLASSIFICATION_DT_5
				, TRG.POS_GRADE_5               = SRC.POS_GRADE_5
				, TRG.POS_MED_OFFICERS_ID       = SRC.POS_MED_OFFICERS_ID
				, TRG.POS_PERFORMANCE_LEVEL     = SRC.POS_PERFORMANCE_LEVEL
				, TRG.POS_SUPERVISORY           = SRC.POS_SUPERVISORY
				, TRG.POS_SKILL                 = SRC.POS_SKILL
				, TRG.POS_LOCATION              = SRC.POS_LOCATION
				, TRG.POS_VACANCIES             = SRC.POS_VACANCIES
				, TRG.POS_REPORT_SUPERVISOR     = SRC.POS_REPORT_SUPERVISOR
				, TRG.POS_CAN                   = SRC.POS_CAN
				, TRG.POS_VICE                  = SRC.POS_VICE
				, TRG.POS_VICE_NAME             = SRC.POS_VICE_NAME
				, TRG.POS_DAYS_ADVERTISED       = SRC.POS_DAYS_ADVERTISED
				, TRG.POS_AT_ID                 = SRC.POS_AT_ID
				, TRG.POS_NTE                   = SRC.POS_NTE
				, TRG.POS_WORK_SCHED_ID         = SRC.POS_WORK_SCHED_ID
				, TRG.POS_HOURS_PER_WEEK        = SRC.POS_HOURS_PER_WEEK
				, TRG.POS_DUAL_EMPLMT           = SRC.POS_DUAL_EMPLMT
				, TRG.POS_SEC_ID                = SRC.POS_SEC_ID
				, TRG.POS_CE_FINANCIAL_DISC     = SRC.POS_CE_FINANCIAL_DISC
				, TRG.POS_CE_FINANCIAL_TYPE_ID  = SRC.POS_CE_FINANCIAL_TYPE_ID
				, TRG.POS_CE_PE_PHYSICAL        = SRC.POS_CE_PE_PHYSICAL
				, TRG.POS_CE_DRUG_TEST          = SRC.POS_CE_DRUG_TEST
				, TRG.POS_CE_IMMUN              = SRC.POS_CE_IMMUN
				, TRG.POS_CE_TRAVEL             = SRC.POS_CE_TRAVEL
				, TRG.POS_CE_TRAVEL_PER         = SRC.POS_CE_TRAVEL_PER
				, TRG.POS_CE_LIC                = SRC.POS_CE_LIC
				, TRG.POS_CE_LIC_INFO           = SRC.POS_CE_LIC_INFO
				, TRG.POS_REMARKS               = SRC.POS_REMARKS
				, TRG.POS_PROC_REQ_TYPE         = SRC.POS_PROC_REQ_TYPE
				, TRG.POS_RECRUIT_OFFICE_ID     = SRC.POS_RECRUIT_OFFICE_ID
				, TRG.POS_REQ_CREATE_NOTIFY_DT  = SRC.POS_REQ_CREATE_NOTIFY_DT
				, TRG.POS_SO_ID                 = SRC.POS_SO_ID
				, TRG.POS_ASSOC_DESCR_NUMBERS   = SRC.POS_ASSOC_DESCR_NUMBERS
				, TRG.POS_PROMOTE_POTENTIAL     = SRC.POS_PROMOTE_POTENTIAL
				, TRG.POS_VICE_EMPL_ID          = SRC.POS_VICE_EMPL_ID
				, TRG.POS_SR_ID                 = SRC.POS_SR_ID
				, TRG.POS_GR_ID                 = SRC.POS_GR_ID
				, TRG.POS_AC_ID                 = SRC.POS_AC_ID
				, TRG.POS_GA_1                  = SRC.POS_GA_1
				, TRG.POS_GA_2                  = SRC.POS_GA_2
				, TRG.POS_GA_3                  = SRC.POS_GA_3
				, TRG.POS_GA_4                  = SRC.POS_GA_4
				, TRG.POS_GA_5                  = SRC.POS_GA_5
				, TRG.POS_GA_6                  = SRC.POS_GA_6
				, TRG.POS_GA_7                  = SRC.POS_GA_7
				, TRG.POS_GA_8                  = SRC.POS_GA_8
				, TRG.POS_GA_9                  = SRC.POS_GA_9
				, TRG.POS_GA_10                 = SRC.POS_GA_10
				, TRG.POS_GA_11                 = SRC.POS_GA_11
				, TRG.POS_GA_12                 = SRC.POS_GA_12
				, TRG.POS_GA_13                 = SRC.POS_GA_13
				, TRG.POS_GA_14                 = SRC.POS_GA_14
				, TRG.POS_GA_15                 = SRC.POS_GA_15
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.POS_REQ_ID
				, TRG.POS_CNDT_LAST_NM
				, TRG.POS_CNDT_FIRST_NM
				, TRG.POS_CNDT_MIDDLE_NM
				, TRG.POS_BGT_APR_OFM
				, TRG.POS_SPNSR_ORG_NM
				, TRG.POS_SPNSR_ORG_FUND_PC
				, TRG.POS_TITLE
				, TRG.POS_PAY_PLAN_ID
				, TRG.POS_SERIES
				, TRG.POS_DESC_NUMBER_1
				, TRG.POS_CLASSIFICATION_DT_1
				, TRG.POS_GRADE_1
				, TRG.POS_DESC_NUMBER_2
				, TRG.POS_CLASSIFICATION_DT_2
				, TRG.POS_GRADE_2
				, TRG.POS_DESC_NUMBER_3
				, TRG.POS_CLASSIFICATION_DT_3
				, TRG.POS_GRADE_3
				, TRG.POS_DESC_NUMBER_4
				, TRG.POS_CLASSIFICATION_DT_4
				, TRG.POS_GRADE_4
				, TRG.POS_DESC_NUMBER_5
				, TRG.POS_CLASSIFICATION_DT_5
				, TRG.POS_GRADE_5
				, TRG.POS_MED_OFFICERS_ID
				, TRG.POS_PERFORMANCE_LEVEL
				, TRG.POS_SUPERVISORY
				, TRG.POS_SKILL
				, TRG.POS_LOCATION
				, TRG.POS_VACANCIES
				, TRG.POS_REPORT_SUPERVISOR
				, TRG.POS_CAN
				, TRG.POS_VICE
				, TRG.POS_VICE_NAME
				, TRG.POS_DAYS_ADVERTISED
				, TRG.POS_AT_ID
				, TRG.POS_NTE
				, TRG.POS_WORK_SCHED_ID
				, TRG.POS_HOURS_PER_WEEK
				, TRG.POS_DUAL_EMPLMT
				, TRG.POS_SEC_ID
				, TRG.POS_CE_FINANCIAL_DISC
				, TRG.POS_CE_FINANCIAL_TYPE_ID
				, TRG.POS_CE_PE_PHYSICAL
				, TRG.POS_CE_DRUG_TEST
				, TRG.POS_CE_IMMUN
				, TRG.POS_CE_TRAVEL
				, TRG.POS_CE_TRAVEL_PER
				, TRG.POS_CE_LIC
				, TRG.POS_CE_LIC_INFO
				, TRG.POS_REMARKS
				, TRG.POS_PROC_REQ_TYPE
				, TRG.POS_RECRUIT_OFFICE_ID
				, TRG.POS_REQ_CREATE_NOTIFY_DT
				, TRG.POS_SO_ID
				, TRG.POS_ASSOC_DESCR_NUMBERS
				, TRG.POS_PROMOTE_POTENTIAL
				, TRG.POS_VICE_EMPL_ID
				, TRG.POS_SR_ID
				, TRG.POS_GR_ID
				, TRG.POS_AC_ID
				, TRG.POS_GA_1
				, TRG.POS_GA_2
				, TRG.POS_GA_3
				, TRG.POS_GA_4
				, TRG.POS_GA_5
				, TRG.POS_GA_6
				, TRG.POS_GA_7
				, TRG.POS_GA_8
				, TRG.POS_GA_9
				, TRG.POS_GA_10
				, TRG.POS_GA_11
				, TRG.POS_GA_12
				, TRG.POS_GA_13
				, TRG.POS_GA_14
				, TRG.POS_GA_15
			)
			VALUES
			(
				SRC.POS_REQ_ID
				, SRC.POS_CNDT_LAST_NM
				, SRC.POS_CNDT_FIRST_NM
				, SRC.POS_CNDT_MIDDLE_NM
				, SRC.POS_BGT_APR_OFM
				, SRC.POS_SPNSR_ORG_NM
				, SRC.POS_SPNSR_ORG_FUND_PC
				, SRC.POS_TITLE
				, SRC.POS_PAY_PLAN_ID
				, SRC.POS_SERIES
				, SRC.POS_DESC_NUMBER_1
				, SRC.POS_CLASSIFICATION_DT_1
				, SRC.POS_GRADE_1
				, SRC.POS_DESC_NUMBER_2
				, SRC.POS_CLASSIFICATION_DT_2
				, SRC.POS_GRADE_2
				, SRC.POS_DESC_NUMBER_3
				, SRC.POS_CLASSIFICATION_DT_3
				, SRC.POS_GRADE_3
				, SRC.POS_DESC_NUMBER_4
				, SRC.POS_CLASSIFICATION_DT_4
				, SRC.POS_GRADE_4
				, SRC.POS_DESC_NUMBER_5
				, SRC.POS_CLASSIFICATION_DT_5
				, SRC.POS_GRADE_5
				, SRC.POS_MED_OFFICERS_ID
				, SRC.POS_PERFORMANCE_LEVEL
				, SRC.POS_SUPERVISORY
				, SRC.POS_SKILL
				, SRC.POS_LOCATION
				, SRC.POS_VACANCIES
				, SRC.POS_REPORT_SUPERVISOR
				, SRC.POS_CAN
				, SRC.POS_VICE
				, SRC.POS_VICE_NAME
				, SRC.POS_DAYS_ADVERTISED
				, SRC.POS_AT_ID
				, SRC.POS_NTE
				, SRC.POS_WORK_SCHED_ID
				, SRC.POS_HOURS_PER_WEEK
				, SRC.POS_DUAL_EMPLMT
				, SRC.POS_SEC_ID
				, SRC.POS_CE_FINANCIAL_DISC
				, SRC.POS_CE_FINANCIAL_TYPE_ID
				, SRC.POS_CE_PE_PHYSICAL
				, SRC.POS_CE_DRUG_TEST
				, SRC.POS_CE_IMMUN
				, SRC.POS_CE_TRAVEL
				, SRC.POS_CE_TRAVEL_PER
				, SRC.POS_CE_LIC
				, SRC.POS_CE_LIC_INFO
				, SRC.POS_REMARKS
				, SRC.POS_PROC_REQ_TYPE
				, SRC.POS_RECRUIT_OFFICE_ID
				, SRC.POS_REQ_CREATE_NOTIFY_DT
				, SRC.POS_SO_ID
				, SRC.POS_ASSOC_DESCR_NUMBERS
				, SRC.POS_PROMOTE_POTENTIAL
				, SRC.POS_VICE_EMPL_ID
				, SRC.POS_SR_ID
				, SRC.POS_GR_ID
				, SRC.POS_AC_ID
				, SRC.POS_GA_1
				, SRC.POS_GA_2
				, SRC.POS_GA_3
				, SRC.POS_GA_4
				, SRC.POS_GA_5
				, SRC.POS_GA_6
				, SRC.POS_GA_7
				, SRC.POS_GA_8
				, SRC.POS_GA_9
				, SRC.POS_GA_10
				, SRC.POS_GA_11
				, SRC.POS_GA_12
				, SRC.POS_GA_13
				, SRC.POS_GA_14
				, SRC.POS_GA_15
			)
			;


			--------------------------------
			-- AREAS_OF_CONS table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    AREAS_OF_CONS table');
			MERGE INTO AREAS_OF_CONS TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS AOC_REQ_ID
					, X.AOC_30PCT_DISABLED_VETS
					, X.AOC_EXPERT_CONS
					, X.AOC_IPA
					, X.AOC_OPER_WARFIGHTER
					, X.AOC_DISABILITIES
					, X.AOC_STUDENT_VOL
					, X.AOC_VETS_RECRUIT_APPT
					, X.AOC_VOC_REHAB_EMPL
					, X.AOC_WORKFORCE_RECRUIT
					, X.AOC_NON_COMP_APPL
					, X.AOC_MIL_SPOUSES
					, X.AOC_DIRECT_HIRE
					, X.AOC_RE_EMPLOYMENT
					, X.AOC_PATHWAYS
					, X.AOC_PEACE_CORPS_VOL
					, X.AOC_REINSTATEMENT
					, X.AOC_SHARED_CERT
					, X.AOC_DELEGATE_EXAM
					, X.AOC_DH_US_CITIZENS
					, X.AOC_MP_GOV_WIDE
					, X.AOC_MP_HHS_ONLY
					, X.AOC_MP_CMS_ONLY
					, X.AOC_MP_COMP_CONS_ONLY
					, X.AOC_MP_I_CTAP_VEGA
					, X.AOC_NON_BARGAIN_DOC_RATIONALE
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/AREA_OF_CONSIDERATION'
						PASSING FD.FIELD_DATA
						COLUMNS
							AOC_30PCT_DISABLED_VETS             CHAR(1)         PATH 'if (AOC_30PCT_DISABLED_VETS/text() = "true") then 1 else 0'
							, AOC_EXPERT_CONS                   CHAR(1)         PATH 'if (AOC_EXPERT_CONS/text() = "true") then 1 else 0'
							, AOC_IPA                           CHAR(1)         PATH 'if (AOC_IPA/text() = "true") then 1 else 0'
							, AOC_OPER_WARFIGHTER               CHAR(1)         PATH 'if (AOC_OPER_WARFIGHTER/text() = "true") then 1 else 0'
							, AOC_DISABILITIES                  CHAR(1)         PATH 'if (AOC_DISABILITIES/text() = "true") then 1 else 0'
							, AOC_STUDENT_VOL                   CHAR(1)         PATH 'if (AOC_STUDENT_VOL/text() = "true") then 1 else 0'
							, AOC_VETS_RECRUIT_APPT             CHAR(1)         PATH 'if (AOC_VETS_RECRUIT_APPT/text() = "true") then 1 else 0'
							, AOC_VOC_REHAB_EMPL                CHAR(1)         PATH 'if (AOC_VOC_REHAB_EMPL/text() = "true") then 1 else 0'
							, AOC_WORKFORCE_RECRUIT             CHAR(1)         PATH 'if (AOC_WORKFORCE_RECRUIT/text() = "true") then 1 else 0'
							, AOC_NON_COMP_APPL                 NVARCHAR2(140)  PATH 'AOC_NON_COMP_APPL'
							, AOC_MIL_SPOUSES                   CHAR(1)         PATH 'if (AOC_MIL_SPOUSES/text() = "true") then 1 else 0'
							, AOC_DIRECT_HIRE                   CHAR(1)         PATH 'if (AOC_DIRECT_HIRE/text() = "true") then 1 else 0'
							, AOC_RE_EMPLOYMENT                 CHAR(1)         PATH 'if (AOC_RE_EMPLOYMENT/text() = "true") then 1 else 0'
							, AOC_PATHWAYS                      CHAR(1)         PATH 'if (AOC_PATHWAYS/text() = "true") then 1 else 0'
							, AOC_PEACE_CORPS_VOL               CHAR(1)         PATH 'if (AOC_PEACE_CORPS_VOL/text() = "true") then 1 else 0'
							, AOC_REINSTATEMENT                 CHAR(1)         PATH 'if (AOC_REINSTATEMENT/text() = "true") then 1 else 0'
							, AOC_SHARED_CERT                   CHAR(1)         PATH 'if (AOC_SHARED_CERT/text() = "true") then 1 else 0'
							, AOC_DELEGATE_EXAM                 CHAR(1)         PATH 'if (AOC_DELEGATE_EXAM/text() = "true") then 1 else 0'
							, AOC_DH_US_CITIZENS                CHAR(1)         PATH 'if (AOC_DH_US_CITIZENS/text() = "true") then 1 else 0'
							, AOC_MP_GOV_WIDE                   CHAR(1)         PATH 'if (AOC_MP_GOV_WIDE/text() = "true") then 1 else 0'
							, AOC_MP_HHS_ONLY                   CHAR(1)         PATH 'if (AOC_MP_HHS_ONLY/text() = "true") then 1 else 0'
							, AOC_MP_CMS_ONLY                   CHAR(1)         PATH 'if (AOC_MP_CMS_ONLY/text() = "true") then 1 else 0'
							, AOC_MP_COMP_CONS_ONLY             CHAR(1)         PATH 'if (AOC_MP_COMP_CONS_ONLY/text() = "true") then 1 else 0'
							, AOC_MP_I_CTAP_VEGA                CHAR(1)         PATH 'if (AOC_MP_I_CTAP_VEGA/text() = "true") then 1 else 0'
							, AOC_NON_BARGAIN_DOC_RATIONALE     NVARCHAR2(500)  PATH 'AOC_NON_BARGAIN_DOC_RATIONALE'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.AOC_REQ_ID = TRG.AOC_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.AOC_30PCT_DISABLED_VETS          = SRC.AOC_30PCT_DISABLED_VETS
				, TRG.AOC_EXPERT_CONS                = SRC.AOC_EXPERT_CONS
				, TRG.AOC_IPA                        = SRC.AOC_IPA
				, TRG.AOC_OPER_WARFIGHTER            = SRC.AOC_OPER_WARFIGHTER
				, TRG.AOC_DISABILITIES               = SRC.AOC_DISABILITIES
				, TRG.AOC_STUDENT_VOL                = SRC.AOC_STUDENT_VOL
				, TRG.AOC_VETS_RECRUIT_APPT          = SRC.AOC_VETS_RECRUIT_APPT
				, TRG.AOC_VOC_REHAB_EMPL             = SRC.AOC_VOC_REHAB_EMPL
				, TRG.AOC_WORKFORCE_RECRUIT          = SRC.AOC_WORKFORCE_RECRUIT
				, TRG.AOC_NON_COMP_APPL              = SRC.AOC_NON_COMP_APPL
				, TRG.AOC_MIL_SPOUSES                = SRC.AOC_MIL_SPOUSES
				, TRG.AOC_DIRECT_HIRE                = SRC.AOC_DIRECT_HIRE
				, TRG.AOC_RE_EMPLOYMENT              = SRC.AOC_RE_EMPLOYMENT
				, TRG.AOC_PATHWAYS                   = SRC.AOC_PATHWAYS
				, TRG.AOC_PEACE_CORPS_VOL            = SRC.AOC_PEACE_CORPS_VOL
				, TRG.AOC_REINSTATEMENT              = SRC.AOC_REINSTATEMENT
				, TRG.AOC_SHARED_CERT                = SRC.AOC_SHARED_CERT
				, TRG.AOC_DELEGATE_EXAM              = SRC.AOC_DELEGATE_EXAM
				, TRG.AOC_DH_US_CITIZENS             = SRC.AOC_DH_US_CITIZENS
				, TRG.AOC_MP_GOV_WIDE                = SRC.AOC_MP_GOV_WIDE
				, TRG.AOC_MP_HHS_ONLY                = SRC.AOC_MP_HHS_ONLY
				, TRG.AOC_MP_CMS_ONLY                = SRC.AOC_MP_CMS_ONLY
				, TRG.AOC_MP_COMP_CONS_ONLY          = SRC.AOC_MP_COMP_CONS_ONLY
				, TRG.AOC_MP_I_CTAP_VEGA             = SRC.AOC_MP_I_CTAP_VEGA
				, TRG.AOC_NON_BARGAIN_DOC_RATIONALE  = SRC.AOC_NON_BARGAIN_DOC_RATIONALE
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.AOC_REQ_ID
				, TRG.AOC_30PCT_DISABLED_VETS
				, TRG.AOC_EXPERT_CONS
				, TRG.AOC_IPA
				, TRG.AOC_OPER_WARFIGHTER
				, TRG.AOC_DISABILITIES
				, TRG.AOC_STUDENT_VOL
				, TRG.AOC_VETS_RECRUIT_APPT
				, TRG.AOC_VOC_REHAB_EMPL
				, TRG.AOC_WORKFORCE_RECRUIT
				, TRG.AOC_NON_COMP_APPL
				, TRG.AOC_MIL_SPOUSES
				, TRG.AOC_DIRECT_HIRE
				, TRG.AOC_RE_EMPLOYMENT
				, TRG.AOC_PATHWAYS
				, TRG.AOC_PEACE_CORPS_VOL
				, TRG.AOC_REINSTATEMENT
				, TRG.AOC_SHARED_CERT
				, TRG.AOC_DELEGATE_EXAM
				, TRG.AOC_DH_US_CITIZENS
				, TRG.AOC_MP_GOV_WIDE
				, TRG.AOC_MP_HHS_ONLY
				, TRG.AOC_MP_CMS_ONLY
				, TRG.AOC_MP_COMP_CONS_ONLY
				, TRG.AOC_MP_I_CTAP_VEGA
				, TRG.AOC_NON_BARGAIN_DOC_RATIONALE
			)
			VALUES
			(
				SRC.AOC_REQ_ID
				, SRC.AOC_30PCT_DISABLED_VETS
				, SRC.AOC_EXPERT_CONS
				, SRC.AOC_IPA
				, SRC.AOC_OPER_WARFIGHTER
				, SRC.AOC_DISABILITIES
				, SRC.AOC_STUDENT_VOL
				, SRC.AOC_VETS_RECRUIT_APPT
				, SRC.AOC_VOC_REHAB_EMPL
				, SRC.AOC_WORKFORCE_RECRUIT
				, SRC.AOC_NON_COMP_APPL
				, SRC.AOC_MIL_SPOUSES
				, SRC.AOC_DIRECT_HIRE
				, SRC.AOC_RE_EMPLOYMENT
				, SRC.AOC_PATHWAYS
				, SRC.AOC_PEACE_CORPS_VOL
				, SRC.AOC_REINSTATEMENT
				, SRC.AOC_SHARED_CERT
				, SRC.AOC_DELEGATE_EXAM
				, SRC.AOC_DH_US_CITIZENS
				, SRC.AOC_MP_GOV_WIDE
				, SRC.AOC_MP_HHS_ONLY
				, SRC.AOC_MP_CMS_ONLY
				, SRC.AOC_MP_COMP_CONS_ONLY
				, SRC.AOC_MP_I_CTAP_VEGA
				, SRC.AOC_NON_BARGAIN_DOC_RATIONALE
			)
			;


			--------------------------------
			-- SME_INFO table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    SME_INFO table');
			MERGE INTO SME_INFO TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS SME_REQ_ID
					, X.SME_FOR_JOB_ANALYSIS
					, X.SME_NAME_JA
					, X.SME_EMAIL_JA
					, X.SME_FOR_QUALIFICATION
					, X.SME_NAME_QUAL_1
					, X.SME_EMAIL_QUAL_1
					, X.SME_NAME_QUAL_2
					, X.SME_EMAIL_QUAL_2
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/SUBJECT_MATTER_EXPERT'
						PASSING FD.FIELD_DATA
						COLUMNS
							SME_FOR_JOB_ANALYSIS                CHAR(1)         PATH 'if (SME_FOR_JOB_ANALYSIS/text() = "true") then 1 else 0'
							, SME_NAME_JA                       NVARCHAR2(100)  PATH 'SME_NAME_JA'
							, SME_EMAIL_JA                      NVARCHAR2(100)  PATH 'SME_EMAIL_JA'
							, SME_FOR_QUALIFICATION             CHAR(1)         PATH 'if (SME_FOR_QUALIFICATION/text() = "true") then 1 else 0'
							, SME_NAME_QUAL_1                   NVARCHAR2(100)  PATH 'SME_NAME_QUAL_1'
							, SME_EMAIL_QUAL_1                  NVARCHAR2(100)  PATH 'SME_EMAIL_QUAL_1'
							, SME_NAME_QUAL_2                   NVARCHAR2(100)  PATH 'SME_NAME_QUAL_2'
							, SME_EMAIL_QUAL_2                  NVARCHAR2(100)  PATH 'SME_EMAIL_QUAL_2'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.SME_REQ_ID = TRG.SME_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.SME_FOR_JOB_ANALYSIS     = SRC.SME_FOR_JOB_ANALYSIS
				, TRG.SME_NAME_JA            = SRC.SME_NAME_JA
				, TRG.SME_EMAIL_JA           = SRC.SME_EMAIL_JA
				, TRG.SME_FOR_QUALIFICATION  = SRC.SME_FOR_QUALIFICATION
				, TRG.SME_NAME_QUAL_1        = SRC.SME_NAME_QUAL_1
				, TRG.SME_EMAIL_QUAL_1       = SRC.SME_EMAIL_QUAL_1
				, TRG.SME_NAME_QUAL_2        = SRC.SME_NAME_QUAL_2
				, TRG.SME_EMAIL_QUAL_2       = SRC.SME_EMAIL_QUAL_2
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.SME_REQ_ID
				, TRG.SME_FOR_JOB_ANALYSIS
				, TRG.SME_NAME_JA
				, TRG.SME_EMAIL_JA
				, TRG.SME_FOR_QUALIFICATION
				, TRG.SME_NAME_QUAL_1
				, TRG.SME_EMAIL_QUAL_1
				, TRG.SME_NAME_QUAL_2
				, TRG.SME_EMAIL_QUAL_2
			)
			VALUES
			(
				SRC.SME_REQ_ID
				, SRC.SME_FOR_JOB_ANALYSIS
				, SRC.SME_NAME_JA
				, SRC.SME_EMAIL_JA
				, SRC.SME_FOR_QUALIFICATION
				, SRC.SME_NAME_QUAL_1
				, SRC.SME_EMAIL_QUAL_1
				, SRC.SME_NAME_QUAL_2
				, SRC.SME_EMAIL_QUAL_2
			)
			;


			--------------------------------
			-- JOB_ANALYSIS table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    JOB_ANALYSIS table');
			MERGE INTO JOB_ANALYSIS TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS JA_REQ_ID
					, X.JA_SEL_FACTOR_REQ
					, X.JA_SEL_FACTOR_JUST
					, X.JA_QUAL_RANK_REQ
					, X.JA_QUAL_RANK_JUST
					, X.JA_RESPONSES_REQ
					, X.JA_TYPE_YES_NO
					, X.JA_TYPE_REQ_DEFAULT
					, X.JA_TYPE_KNOWL_SCALE
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/JOB_ANALYSIS'
						PASSING FD.FIELD_DATA
						COLUMNS
							JA_SEL_FACTOR_REQ                   CHAR(1)         PATH 'if (JA_SEL_FACTOR_REQ/text() = "true") then 1 else 0'
							, JA_SEL_FACTOR_JUST                NVARCHAR2(100)  PATH 'JA_SEL_FACTOR_JUST'
							, JA_QUAL_RANK_REQ                  CHAR(1)         PATH 'if (JA_QUAL_RANK_REQ/text() = "true") then 1 else 0'
							, JA_QUAL_RANK_JUST                 NVARCHAR2(100)  PATH 'JA_QUAL_RANK_JUST'
							, JA_RESPONSES_REQ                  CHAR(1)         PATH 'if (JA_RESPONSES_REQ/text() = "true") then 1 else 0'
							, JA_TYPE_YES_NO                    CHAR(1)         PATH 'if (JA_TYPE_YES_NO/text() = "true") then 1 else 0'
							, JA_TYPE_REQ_DEFAULT               CHAR(1)         PATH 'if (JA_TYPE_REQ_DEFAULT/text() = "true") then 1 else 0'
							, JA_TYPE_KNOWL_SCALE               CHAR(1)         PATH 'if (JA_TYPE_KNOWL_SCALE/text() = "true") then 1 else 0'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.JA_REQ_ID = TRG.JA_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.JA_SEL_FACTOR_REQ = SRC.JA_SEL_FACTOR_REQ
				, TRG.JA_SEL_FACTOR_JUST   = SRC.JA_SEL_FACTOR_JUST
				, TRG.JA_QUAL_RANK_REQ     = SRC.JA_QUAL_RANK_REQ
				, TRG.JA_QUAL_RANK_JUST    = SRC.JA_QUAL_RANK_JUST
				, TRG.JA_RESPONSES_REQ     = SRC.JA_RESPONSES_REQ
				, TRG.JA_TYPE_YES_NO       = SRC.JA_TYPE_YES_NO
				, TRG.JA_TYPE_REQ_DEFAULT  = SRC.JA_TYPE_REQ_DEFAULT
				, TRG.JA_TYPE_KNOWL_SCALE  = SRC.JA_TYPE_KNOWL_SCALE
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.JA_REQ_ID
				, TRG.JA_SEL_FACTOR_REQ
				, TRG.JA_SEL_FACTOR_JUST
				, TRG.JA_QUAL_RANK_REQ
				, TRG.JA_QUAL_RANK_JUST
				, TRG.JA_RESPONSES_REQ
				, TRG.JA_TYPE_YES_NO
				, TRG.JA_TYPE_REQ_DEFAULT
				, TRG.JA_TYPE_KNOWL_SCALE
			)
			VALUES
			(
				SRC.JA_REQ_ID
				, SRC.JA_SEL_FACTOR_REQ
				, SRC.JA_SEL_FACTOR_JUST
				, SRC.JA_QUAL_RANK_REQ
				, SRC.JA_QUAL_RANK_JUST
				, SRC.JA_RESPONSES_REQ
				, SRC.JA_TYPE_YES_NO
				, SRC.JA_TYPE_REQ_DEFAULT
				, SRC.JA_TYPE_KNOWL_SCALE
			)
			;


			--------------------------------
			-- RECRUIT_INCENTIVES table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    RECRUIT_INCENTIVES table');
			MERGE INTO RECRUIT_INCENTIVES TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS RI_REQ_ID
					, X.RI_OA_APRV_ITEM
					, X.RI_MOVING_EXP_AUTH
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/RECRUITMENT_INCENTIVE'
						PASSING FD.FIELD_DATA
						COLUMNS
							RI_RECRUITMENT_AUTH                 CHAR(1)         PATH 'if (RI_OA_APRV_ITEM/text() = "C") then 1 else 0'
							, RI_RELOCATION_AUTH                CHAR(1)         PATH 'if (RI_OA_APRV_ITEM/text() = "L") then 1 else 0'
							, RI_OA_APRV_ITEM                   VARCHAR2(20)    PATH 'RI_OA_APRV_ITEM'
							, RI_MOVING_EXP_AUTH                CHAR(1)         PATH 'if (RI_MOVING_EXP_AUTH/text() = "true") then 1 else 0'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.RI_REQ_ID = TRG.RI_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.RI_OA_APRV_ITEM       = SRC.RI_OA_APRV_ITEM
				, TRG.RI_MOVING_EXP_AUTH  = SRC.RI_MOVING_EXP_AUTH
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.RI_REQ_ID
				, TRG.RI_OA_APRV_ITEM
				, TRG.RI_MOVING_EXP_AUTH
			)
			VALUES
			(
				SRC.RI_REQ_ID
				, SRC.RI_OA_APRV_ITEM
				, SRC.RI_MOVING_EXP_AUTH
			)
			;


			--------------------------------
			-- TARGET_RECRUIT table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    TARGET_RECRUIT table');
			MERGE INTO TARGET_RECRUIT TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS TR_REQ_ID
					, X.TR_PAID_AD
					, X.TR_PAID_AD_SPEC
					, X.TR_PAID_AD_SPEC_OTHR
					, X.TR_SCHL_PSTG
					, X.TR_SCHL_PSTG_SPEC
					, X.TR_SCHL_PSTG_SPEC_OTHR
					, X.TR_SOCIAL_MEDIA
					, X.TR_SOCIAL_MEDIA_SPEC
					, X.TR_SOCIAL_MEDIA_SPEC_OTHR
					, X.TR_OTHER
					, X.TR_OTHER_SPEC
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/TARGET_RECRUITMENT'
						PASSING FD.FIELD_DATA
						COLUMNS
							TR_PAID_AD                          CHAR(1)         PATH 'if (TR_PAID_AD/text() = "true") then 1 else 0'
							, TR_PAID_AD_SPEC                   NVARCHAR2(1000) PATH 'string-join(TR_PAID_AD_SPEC/text(), ",")'
							, TR_PAID_AD_SPEC_OTHR              NVARCHAR2(140)  PATH 'TR_PAID_AD_SPEC_OTHR'
							, TR_SCHL_PSTG                      CHAR(1)         PATH 'if (TR_SCHL_PSTG/text() = "true") then 1 else 0'
							, TR_SCHL_PSTG_SPEC                 NVARCHAR2(1000) PATH 'string-join(TR_SCHL_PSTG_SPEC/text(), ",")'
							, TR_SCHL_PSTG_SPEC_OTHR            NVARCHAR2(140)  PATH 'TR_SCHL_PSTG_SPEC_OTHR'
							, TR_SOCIAL_MEDIA                   CHAR(1)         PATH 'if (TR_SOCIAL_MEDIA/text() = "true") then 1 else 0'
							, TR_SOCIAL_MEDIA_SPEC              NVARCHAR2(1000) PATH 'string-join(TR_SOCIAL_MEDIA_SPEC/text(), ",")'
							, TR_SOCIAL_MEDIA_SPEC_OTHR         NVARCHAR2(140)  PATH 'TR_SOCIAL_MEDIA_SPEC_OTHR'
							, TR_OTHER                          CHAR(1)         PATH 'if (TR_OTHER/text() = "true") then 1 else 0'
							, TR_OTHER_SPEC                     NVARCHAR2(500)  PATH 'TR_OTHER_SPEC'

					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.TR_REQ_ID = TRG.TR_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.TR_PAID_AD                   = SRC.TR_PAID_AD
				, TRG.TR_PAID_AD_SPEC            = SRC.TR_PAID_AD_SPEC
				, TRG.TR_PAID_AD_SPEC_OTHR       = SRC.TR_PAID_AD_SPEC_OTHR
				, TRG.TR_SCHL_PSTG               = SRC.TR_SCHL_PSTG
				, TRG.TR_SCHL_PSTG_SPEC          = SRC.TR_SCHL_PSTG_SPEC
				, TRG.TR_SCHL_PSTG_SPEC_OTHR     = SRC.TR_SCHL_PSTG_SPEC_OTHR
				, TRG.TR_SOCIAL_MEDIA            = SRC.TR_SOCIAL_MEDIA
				, TRG.TR_SOCIAL_MEDIA_SPEC       = SRC.TR_SOCIAL_MEDIA_SPEC
				, TRG.TR_SOCIAL_MEDIA_SPEC_OTHR  = SRC.TR_SOCIAL_MEDIA_SPEC_OTHR
				, TRG.TR_OTHER                   = SRC.TR_OTHER
				, TRG.TR_OTHER_SPEC              = SRC.TR_OTHER_SPEC
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.TR_REQ_ID
				, TRG.TR_PAID_AD
				, TRG.TR_PAID_AD_SPEC
				, TRG.TR_PAID_AD_SPEC_OTHR
				, TRG.TR_SCHL_PSTG
				, TRG.TR_SCHL_PSTG_SPEC
				, TRG.TR_SCHL_PSTG_SPEC_OTHR
				, TRG.TR_SOCIAL_MEDIA
				, TRG.TR_SOCIAL_MEDIA_SPEC
				, TRG.TR_SOCIAL_MEDIA_SPEC_OTHR
				, TRG.TR_OTHER
				, TRG.TR_OTHER_SPEC
			)
			VALUES
			(
				SRC.TR_REQ_ID
				, SRC.TR_PAID_AD
				, SRC.TR_PAID_AD_SPEC
				, SRC.TR_PAID_AD_SPEC_OTHR
				, SRC.TR_SCHL_PSTG
				, SRC.TR_SCHL_PSTG_SPEC
				, SRC.TR_SCHL_PSTG_SPEC_OTHR
				, SRC.TR_SOCIAL_MEDIA
				, SRC.TR_SOCIAL_MEDIA_SPEC
				, SRC.TR_SOCIAL_MEDIA_SPEC_OTHR
				, SRC.TR_OTHER
				, SRC.TR_OTHER_SPEC
			)
			;


			--------------------------------
			-- APPROVALS table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    APPROVALS table');
			MERGE INTO APPROVALS TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS SCA_REQ_ID
					, X.SCA_SO_SIG
					, X.SCA_SO_SIG_DT
					, X.SCA_CLASS_SPEC_SIG
					, X.SCA_CLASS_SPEC_SIG_DT
					, X.SCA_STAFF_SIG
					, X.SCA_STAFF_SIG_DT
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/APPROVAL'
						PASSING FD.FIELD_DATA
						COLUMNS
							SCA_SO_SIG                          NVARCHAR2(100)  PATH 'SCA_SO_SIG'
							, SCA_SO_SIG_DT                     DATE            PATH 'SCA_SO_SIG_DT'
							, SCA_CLASS_SPEC_SIG                NVARCHAR2(100)  PATH 'SCA_CLASS_SPEC_SIG'
							, SCA_CLASS_SPEC_SIG_DT             DATE            PATH 'SCA_CLASS_SPEC_SIG_DT'
							, SCA_STAFF_SIG                     NVARCHAR2(100)  PATH 'SCA_STAFF_SIG'
							, SCA_STAFF_SIG_DT                  DATE            PATH 'SCA_STAFF_SIG_DT'

					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.SCA_REQ_ID = TRG.SCA_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.SCA_SO_SIG               = SRC.SCA_SO_SIG
				, TRG.SCA_SO_SIG_DT          = SRC.SCA_SO_SIG_DT
				, TRG.SCA_CLASS_SPEC_SIG     = SRC.SCA_CLASS_SPEC_SIG
				, TRG.SCA_CLASS_SPEC_SIG_DT  = SRC.SCA_CLASS_SPEC_SIG_DT
				, TRG.SCA_STAFF_SIG          = SRC.SCA_STAFF_SIG
				, TRG.SCA_STAFF_SIG_DT       = SRC.SCA_STAFF_SIG_DT
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.SCA_REQ_ID
				, TRG.SCA_SO_SIG
				, TRG.SCA_SO_SIG_DT
				, TRG.SCA_CLASS_SPEC_SIG
				, TRG.SCA_CLASS_SPEC_SIG_DT
				, TRG.SCA_STAFF_SIG
				, TRG.SCA_STAFF_SIG_DT
			)
			VALUES
			(
				SRC.SCA_REQ_ID
				, SRC.SCA_SO_SIG
				, SRC.SCA_SO_SIG_DT
				, SRC.SCA_CLASS_SPEC_SIG
				, SRC.SCA_CLASS_SPEC_SIG_DT
				, SRC.SCA_STAFF_SIG
				, SRC.SCA_STAFF_SIG_DT
			)
			;


			--------------------------------
			-- Child table update and sync
			--------------------------------
			SP_UPDATE_STRATCONHIST_TABLE(I_PROCID, V_JOB_REQ_ID);


		EXCEPTION
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20905, 'SP_UPDATE_STRATCON_TABLE: Invalid STRATCON data.  I_PROCID = '
					|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END;

		--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_STRATCON_TABLE - END ==========================');

	END IF;

EXCEPTION
	WHEN E_INVALID_PROCID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCON_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
	WHEN E_INVALID_JOB_REQ_ID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCON_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
	WHEN E_INVALID_STRATCON_DATA THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCON_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_STRATCON_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
END;

/





--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_CLSF_TABLE
--------------------------------------------------------

/**
 * Parses Classification form XML data and stores it
 * into the operational tables for Classification.
 *
 * @param I_PROCID - Process ID
 */

CREATE OR REPLACE PROCEDURE SP_UPDATE_CLSF_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
	V_JOB_REQ_ID                NUMBER(20);
	V_JOB_REQ_NUM               NVARCHAR2(50);
	V_PD_ID                     NUMBER(20);
	V_CLOBVALUE                 CLOB;
	V_VALUE                     NVARCHAR2(4000);
	V_VALUE_LOOKUP              NVARCHAR2(2000);
	V_REC_CNT                   NUMBER(10);
	V_XMLDOC                    XMLTYPE;
	V_XMLVALUE                  XMLTYPE;
	--V_ISMODIFIED                NUMBER(1);
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
	E_INVALID_PROCID            EXCEPTION;
	E_INVALID_JOB_REQ_ID        EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
	E_INVALID_STRATCON_DATA     EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_STRATCON_DATA, -20905);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_CLSF_TABLE - BEGIN ============================');
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE(' ----------------');



	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		------------------------------------------------------
		-- Transfer XML data into operational table
		--
		-- 1. Get Job Request Number
		-- 1.1 Select it from data xml from TBL_FORM_DTL table.
		-- 1.2 If not found, select it from BIZFLOW.RLVNTDATA table.
		-- 2. If Job Request Number not found, issue error.
		-- 3. For each target table,
		-- 3.1. If record found for the REQ_ID, update record.
		-- 3.2. If record not found for the REQ_ID, insert record.
		------------------------------------------------------
		--DBMS_OUTPUT.PUT_LINE('Starting xml data retrieval and table update ----------');

		--------------------------------
		-- get Job Request Number
		--------------------------------
		BEGIN
			SELECT VALUE
			INTO V_JOB_REQ_NUM
			FROM BIZFLOW.RLVNTDATA
			WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'requestNum';
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_NUM := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM);
		IF V_JOB_REQ_NUM IS NULL THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_CLSF_TABLE: Job Request Number is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END IF;


		--------------------------------
		-- REQUEST table
		--------------------------------
		--DBMS_OUTPUT.PUT_LINE('    REQUEST table');
		BEGIN
			SELECT REQ_ID INTO V_JOB_REQ_ID
			FROM REQUEST
			WHERE REQ_JOB_REQ_NUMBER = V_JOB_REQ_NUM;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_ID := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('        V_JOB_REQ_ID = ' || V_JOB_REQ_ID);

		-- Unlike STRATCON, REQUEST record must be available by the time CLSF starts
		IF V_JOB_REQ_ID IS NULL THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_CLSF_TABLE: Job Request ID is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END IF;

		BEGIN
			--------------------------------
			-- REQUEST table update for cancellation
			--------------------------------
			MERGE INTO REQUEST TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS REQ_ID
					, V_JOB_REQ_NUM AS REQ_JOB_REQ_NUMBER
					, X.REQ_CANCEL_DT_STR
					, TO_DATE(X.REQ_CANCEL_DT_STR, 'YYYY/MM/DD HH24:MI:SS') AS REQ_CANCEL_DT
					, X.REQ_CANCEL_REASON
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/PROCESS_VARIABLE'
						PASSING FD.FIELD_DATA
						COLUMNS
							REQ_CANCEL_DT_STR                   NVARCHAR2(30)   PATH 'if (requestStatus/text() = "Request Cancelled") then requestStatusDate else ""'
							, REQ_CANCEL_REASON                 NVARCHAR2(140)  PATH 'cancelReason'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.REQ_ID = TRG.REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.REQ_CANCEL_DT           = SRC.REQ_CANCEL_DT
				, TRG.REQ_CANCEL_REASON     = SRC.REQ_CANCEL_REASON
			;
		END;


		BEGIN
			--------------------------------
			-- CLASSIF_STRATCON table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    CLASSIF_STRATCON table');
			MERGE INTO CLASSIF_STRATCON TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS CS_REQ_ID
					, XG.CS_TITLE
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = XG.CS_PAY_PLAN_ID AND ROWNUM = 1) AS CS_PAY_PLAN_ID
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = XG.CS_SR_ID AND ROWNUM = 1) AS CS_SR_ID
					, XG.CS_PD_NUMBER_JOBCD_1
					, XG.CS_CLASSIFICATION_DT_1
					--, XG.CS_GR_ID_1
					, CASE WHEN LENGTH(XG.CS_GR_ID_1) = 1 THEN '0' || XG.CS_GR_ID_1 ELSE XG.CS_GR_ID_1 END AS CS_GR_ID_1
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_1 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_1
					, XG.CS_PD_NUMBER_JOBCD_2
					, XG.CS_CLASSIFICATION_DT_2
					--, XG.CS_GR_ID_2
					, CASE WHEN LENGTH(XG.CS_GR_ID_2) = 1 THEN '0' || XG.CS_GR_ID_2 ELSE XG.CS_GR_ID_2 END AS CS_GR_ID_2
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_2 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_2
					, XG.CS_PD_NUMBER_JOBCD_3
					, XG.CS_CLASSIFICATION_DT_3
					--, XG.CS_GR_ID_3
					, CASE WHEN LENGTH(XG.CS_GR_ID_3) = 1 THEN '0' || XG.CS_GR_ID_3 ELSE XG.CS_GR_ID_3 END AS CS_GR_ID_3
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_3 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_3
					, XG.CS_PD_NUMBER_JOBCD_4
					, XG.CS_CLASSIFICATION_DT_4
					--, XG.CS_GR_ID_4
					, CASE WHEN LENGTH(XG.CS_GR_ID_4) = 1 THEN '0' || XG.CS_GR_ID_4 ELSE XG.CS_GR_ID_4 END AS CS_GR_ID_4
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_4 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_4
					, XG.CS_PD_NUMBER_JOBCD_5
					, XG.CS_CLASSIFICATION_DT_5
					--, XG.CS_GR_ID_5
					, CASE WHEN LENGTH(XG.CS_GR_ID_5) = 1 THEN '0' || XG.CS_GR_ID_5 ELSE XG.CS_GR_ID_5 END AS CS_GR_ID_5
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_5 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_5
					--, XG.CS_PERFORMANCE_LEVEL
					, CASE WHEN LENGTH(XG.CS_PERFORMANCE_LEVEL) = 1 THEN '0' || XG.CS_PERFORMANCE_LEVEL ELSE XG.CS_PERFORMANCE_LEVEL END AS CS_PERFORMANCE_LEVEL
					, XG.CS_SUPERVISORY
					, XG.CS_AC_ID
					, XG.CS_ADMIN_CD
					, XG.SO_ID
					, XG.SO_TITLE
					, XG.SO_ORG
					, XG.XO_ID
					, XG.XO_TITLE
					, XG.XO_ORG
					, XG.HRL_ID
					, XG.HRL_TITLE
					, XG.HRL_ORG
					, XG.SS_ID
					, XG.CS_ID
					, XC.CS_FIN_STMT_REQ_ID
					, XC.CS_SEC_ID
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/GENERAL'
						PASSING FD.FIELD_DATA
						COLUMNS
							CS_TITLE                            NVARCHAR2(140)  PATH 'CS_TITLE'
							, CS_PAY_PLAN_ID                    NVARCHAR2(140)  PATH 'CS_PAY_PLAN_ID'
							, CS_SR_ID                          NVARCHAR2(140)  PATH 'CS_SR_ID'
							, CS_PD_NUMBER_JOBCD_1              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_1'
							, CS_CLASSIFICATION_DT_1            DATE            PATH 'CS_CLASSIFICATION_DT_1'
							--, CS_GR_ID_1                        NUMBER(2)       PATH 'CS_GR_ID_1'
							, CS_GR_ID_1                        NVARCHAR2(2)    PATH 'CS_GR_ID_1'
							, CS_FLSA_DETERM_ID_1               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_1'
							, CS_PD_NUMBER_JOBCD_2              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_2'
							, CS_CLASSIFICATION_DT_2            DATE            PATH 'CS_CLASSIFICATION_DT_2'
							--, CS_GR_ID_2                        NUMBER(2)       PATH 'CS_GR_ID_2'
							, CS_GR_ID_2                        NVARCHAR2(2)    PATH 'CS_GR_ID_2'
							, CS_FLSA_DETERM_ID_2               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_2'
							, CS_PD_NUMBER_JOBCD_3              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_3'
							, CS_CLASSIFICATION_DT_3            DATE            PATH 'CS_CLASSIFICATION_DT_3'
							--, CS_GR_ID_3                        NUMBER(2)       PATH 'CS_GR_ID_3'
							, CS_GR_ID_3                        NVARCHAR2(2)    PATH 'CS_GR_ID_3'
							, CS_FLSA_DETERM_ID_3               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_3'
							, CS_PD_NUMBER_JOBCD_4              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_4'
							, CS_CLASSIFICATION_DT_4            DATE            PATH 'CS_CLASSIFICATION_DT_4'
							--, CS_GR_ID_4                        NUMBER(2)       PATH 'CS_GR_ID_4'
							, CS_GR_ID_4                        NVARCHAR2(2)    PATH 'CS_GR_ID_4'
							, CS_FLSA_DETERM_ID_4               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_4'
							, CS_PD_NUMBER_JOBCD_5              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_5'
							, CS_CLASSIFICATION_DT_5            DATE            PATH 'CS_CLASSIFICATION_DT_5'
							--, CS_GR_ID_5                        NUMBER(2)       PATH 'CS_GR_ID_5'
							, CS_GR_ID_5                        NVARCHAR2(2)    PATH 'CS_GR_ID_5'
							, CS_FLSA_DETERM_ID_5               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_5'
							--, CS_PERFORMANCE_LEVEL              NUMBER(9)       PATH 'CS_PERFORMANCE_LEVEL'
							, CS_PERFORMANCE_LEVEL              NVARCHAR2(2)    PATH 'CS_PERFORMANCE_LEVEL'
							, CS_SUPERVISORY                    NUMBER(20)      PATH 'CS_SUPERVISORY'
							, CS_AC_ID                          NUMBER(20)      PATH 'CS_AC_ID'
							, CS_ADMIN_CD                       NVARCHAR2(8)    PATH 'CS_ADMIN_CD'
							, SO_ID                             NVARCHAR2(10)   PATH 'SO_ID'
							, SO_TITLE                          NVARCHAR2(50)   PATH 'SO_TITLE'
							, SO_ORG                            NVARCHAR2(50)   PATH 'SO_ORG'
							, XO_ID                             NVARCHAR2(32)   PATH 'XO_ID'
							, XO_TITLE                          NVARCHAR2(200)   PATH 'XO_TITLE'
							, XO_ORG                            NVARCHAR2(200)   PATH 'XO_ORG'
							, HRL_ID                            NVARCHAR2(10)   PATH 'HRL_ID'
							, HRL_TITLE                         NVARCHAR2(50)   PATH 'HRL_TITLE'
							, HRL_ORG                           NVARCHAR2(50)   PATH 'HRL_ORG'
							, SS_ID                             NVARCHAR2(10)   PATH 'SS_ID'
							, CS_ID                             NVARCHAR2(10)   PATH 'CS_ID'
					) XG
					, XMLTABLE('/DOCUMENT/CLASSIFICATION_CODE'
						PASSING FD.FIELD_DATA
						COLUMNS
							CS_FIN_STMT_REQ_ID                  NUMBER(20)      PATH 'CS_FIN_STMT_REQ_ID'
							, CS_SEC_ID                         NUMBER(20)      PATH 'CS_SEC_ID'
					) XC
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.CS_REQ_ID = TRG.CS_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.CS_TITLE                    = SRC.CS_TITLE
				, TRG.CS_PAY_PLAN_ID            = SRC.CS_PAY_PLAN_ID
				, TRG.CS_SR_ID                  = SRC.CS_SR_ID
				, TRG.CS_PD_NUMBER_JOBCD_1      = SRC.CS_PD_NUMBER_JOBCD_1
				, TRG.CS_CLASSIFICATION_DT_1    = SRC.CS_CLASSIFICATION_DT_1
				, TRG.CS_GR_ID_1                = SRC.CS_GR_ID_1
				, TRG.CS_FLSA_DETERM_ID_1       = SRC.CS_FLSA_DETERM_ID_1
				, TRG.CS_PD_NUMBER_JOBCD_2      = SRC.CS_PD_NUMBER_JOBCD_2
				, TRG.CS_CLASSIFICATION_DT_2    = SRC.CS_CLASSIFICATION_DT_2
				, TRG.CS_GR_ID_2                = SRC.CS_GR_ID_2
				, TRG.CS_FLSA_DETERM_ID_2       = SRC.CS_FLSA_DETERM_ID_2
				, TRG.CS_PD_NUMBER_JOBCD_3      = SRC.CS_PD_NUMBER_JOBCD_3
				, TRG.CS_CLASSIFICATION_DT_3    = SRC.CS_CLASSIFICATION_DT_3
				, TRG.CS_GR_ID_3                = SRC.CS_GR_ID_3
				, TRG.CS_FLSA_DETERM_ID_3       = SRC.CS_FLSA_DETERM_ID_3
				, TRG.CS_PD_NUMBER_JOBCD_4      = SRC.CS_PD_NUMBER_JOBCD_4
				, TRG.CS_CLASSIFICATION_DT_4    = SRC.CS_CLASSIFICATION_DT_4
				, TRG.CS_GR_ID_4                = SRC.CS_GR_ID_4
				, TRG.CS_FLSA_DETERM_ID_4       = SRC.CS_FLSA_DETERM_ID_4
				, TRG.CS_PD_NUMBER_JOBCD_5      = SRC.CS_PD_NUMBER_JOBCD_5
				, TRG.CS_CLASSIFICATION_DT_5    = SRC.CS_CLASSIFICATION_DT_5
				, TRG.CS_GR_ID_5                = SRC.CS_GR_ID_5
				, TRG.CS_FLSA_DETERM_ID_5       = SRC.CS_FLSA_DETERM_ID_5
				, TRG.CS_PERFORMANCE_LEVEL      = SRC.CS_PERFORMANCE_LEVEL
				, TRG.CS_SUPERVISORY            = SRC.CS_SUPERVISORY
				, TRG.CS_AC_ID                  = SRC.CS_AC_ID
				, TRG.CS_ADMIN_CD               = SRC.CS_ADMIN_CD
				, TRG.SO_ID                     = SRC.SO_ID
				, TRG.SO_TITLE                  = SRC.SO_TITLE
				, TRG.SO_ORG                    = SRC.SO_ORG
				, TRG.XO_ID                     = SRC.XO_ID
				, TRG.XO_TITLE                  = SRC.XO_TITLE
				, TRG.XO_ORG                    = SRC.XO_ORG
				, TRG.HRL_ID                    = SRC.HRL_ID
				, TRG.HRL_TITLE                 = SRC.HRL_TITLE
				, TRG.HRL_ORG                   = SRC.HRL_ORG
				, TRG.SS_ID                     = SRC.SS_ID
				, TRG.CS_ID                     = SRC.CS_ID
				, TRG.CS_FIN_STMT_REQ_ID        = SRC.CS_FIN_STMT_REQ_ID
				, TRG.CS_SEC_ID                 = SRC.CS_SEC_ID
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.CS_REQ_ID
				, TRG.CS_TITLE
				, TRG.CS_PAY_PLAN_ID
				, TRG.CS_SR_ID
				, TRG.CS_PD_NUMBER_JOBCD_1
				, TRG.CS_CLASSIFICATION_DT_1
				, TRG.CS_GR_ID_1
				, TRG.CS_FLSA_DETERM_ID_1
				, TRG.CS_PD_NUMBER_JOBCD_2
				, TRG.CS_CLASSIFICATION_DT_2
				, TRG.CS_GR_ID_2
				, TRG.CS_FLSA_DETERM_ID_2
				, TRG.CS_PD_NUMBER_JOBCD_3
				, TRG.CS_CLASSIFICATION_DT_3
				, TRG.CS_GR_ID_3
				, TRG.CS_FLSA_DETERM_ID_3
				, TRG.CS_PD_NUMBER_JOBCD_4
				, TRG.CS_CLASSIFICATION_DT_4
				, TRG.CS_GR_ID_4
				, TRG.CS_FLSA_DETERM_ID_4
				, TRG.CS_PD_NUMBER_JOBCD_5
				, TRG.CS_CLASSIFICATION_DT_5
				, TRG.CS_GR_ID_5
				, TRG.CS_FLSA_DETERM_ID_5
				, TRG.CS_PERFORMANCE_LEVEL
				, TRG.CS_SUPERVISORY
				, TRG.CS_AC_ID
				, TRG.CS_ADMIN_CD
				, TRG.SO_ID
				, TRG.SO_TITLE
				, TRG.SO_ORG
				, TRG.XO_ID
				, TRG.XO_TITLE
				, TRG.XO_ORG
				, TRG.HRL_ID
				, TRG.HRL_TITLE
				, TRG.HRL_ORG
				, TRG.SS_ID
				, TRG.CS_ID
				, TRG.CS_FIN_STMT_REQ_ID
				, TRG.CS_SEC_ID
			)
			VALUES
			(
				SRC.CS_REQ_ID
				, SRC.CS_TITLE
				, SRC.CS_PAY_PLAN_ID
				, SRC.CS_SR_ID
				, SRC.CS_PD_NUMBER_JOBCD_1
				, SRC.CS_CLASSIFICATION_DT_1
				, SRC.CS_GR_ID_1
				, SRC.CS_FLSA_DETERM_ID_1
				, SRC.CS_PD_NUMBER_JOBCD_2
				, SRC.CS_CLASSIFICATION_DT_2
				, SRC.CS_GR_ID_2
				, SRC.CS_FLSA_DETERM_ID_2
				, SRC.CS_PD_NUMBER_JOBCD_3
				, SRC.CS_CLASSIFICATION_DT_3
				, SRC.CS_GR_ID_3
				, SRC.CS_FLSA_DETERM_ID_3
				, SRC.CS_PD_NUMBER_JOBCD_4
				, SRC.CS_CLASSIFICATION_DT_4
				, SRC.CS_GR_ID_4
				, SRC.CS_FLSA_DETERM_ID_4
				, SRC.CS_PD_NUMBER_JOBCD_5
				, SRC.CS_CLASSIFICATION_DT_5
				, SRC.CS_GR_ID_5
				, SRC.CS_FLSA_DETERM_ID_5
				, SRC.CS_PERFORMANCE_LEVEL
				, SRC.CS_SUPERVISORY
				, SRC.CS_AC_ID
				, SRC.CS_ADMIN_CD
				, SRC.SO_ID
				, SRC.SO_TITLE
				, SRC.SO_ORG
				, SRC.XO_ID
				, SRC.XO_TITLE
				, SRC.XO_ORG
				, SRC.HRL_ID
				, SRC.HRL_TITLE
				, SRC.HRL_ORG
				, SRC.SS_ID
				, SRC.CS_ID
				, SRC.CS_FIN_STMT_REQ_ID
				, SRC.CS_SEC_ID
			)
			;


			--------------------------------
			-- PD_COVERSHEET table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    PD_COVERSHEET table');
			MERGE INTO PD_COVERSHEET TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS PD_REQ_ID
					, I_PROCID AS PD_PROCID
					, XG.PD_ORG_POS_TITLE
					, XG.PD_EMPLOYING_OFFICE
					, XG.PD_SUBJECT_IA
					, XG.PD_ORGANIZATION
					, XG.PD_SUB_ORG_1
					, XG.PD_SUB_ORG_2
					, XG.PD_SUB_ORG_3
					, XG.PD_SUB_ORG_4
					, XG.PD_SUB_ORG_5
					, XG.PD_SCOPE
					, XG.PD_PCA
					, XG.PD_PDP
					, XG.PD_FTT
					, XG.PD_OUTSTATION
					, XG.PD_INCUMBENCY
					, XG.PD_REMARKS
					, XC.PD_CLS_STANDARDS
					, XC.PD_ACQ_CODE
					, XC.PD_CYB_SEC_CD
					, XC.PD_COMPET_LVL_CD
					, XC.PD_BUS_CD
					, XC.BYPASS_DWC_FL
					, XA.PD_SUPV_CERT
					, XA.PD_SUPV_NAME
					, XA.PD_SUPV_TITLE
					, XA.PD_SUPV_SIG
					, XA.PD_SUPV_SIG_DT
					, XA.PD_CLS_SPEC_CERT
					, XA.PD_CLS_SPEC_NAME
					, XA.PD_CLS_SPEC_TITLE
					, XA.PD_CLS_SPEC_SIG
					, XA.PD_CLS_SPEC_DT
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/GENERAL'
						PASSING FD.FIELD_DATA
						COLUMNS
							PD_ORG_POS_TITLE                    NVARCHAR2(140)  PATH 'PD_ORG_POS_TITLE'
							, PD_EMPLOYING_OFFICE               NUMBER(20)      PATH 'PD_EMPLOYING_OFFICE'
							, PD_SUBJECT_IA                     CHAR(1)         PATH 'PD_SUBJECT_IA'
							, PD_ORGANIZATION                   NVARCHAR2(10)   PATH 'PD_ORGANIZATION'
							, PD_SUB_ORG_1                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_1'
							, PD_SUB_ORG_2                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_2'
							, PD_SUB_ORG_3                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_3'
							, PD_SUB_ORG_4                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_4'
							, PD_SUB_ORG_5                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_5'
							, PD_SCOPE                          NVARCHAR2(10)   PATH 'PD_SCOPE'
							, PD_PCA                            CHAR(1)         PATH 'if (POS_INFORMATION/PD_PCA/text() = "true") then 1 else 0'
							, PD_PDP                            CHAR(1)         PATH 'if (POS_INFORMATION/PD_PDP/text() = "true") then 1 else 0'
							, PD_FTT                            CHAR(1)         PATH 'if (POS_INFORMATION/PD_FTT/text() = "true") then 1 else 0'
							, PD_OUTSTATION                     CHAR(1)         PATH 'if (POS_INFORMATION/PD_OUTSTATION/text() = "true") then 1 else 0'
							, PD_INCUMBENCY                     CHAR(1)         PATH 'if (POS_INFORMATION/PD_INCUMBENCY/text() = "true") then 1 else 0'
							, PD_REMARKS                        NVARCHAR2(500)  PATH 'PD_REMARKS'
					) XG
					, XMLTABLE('/DOCUMENT/CLASSIFICATION_CODE'
						PASSING FD.FIELD_DATA
						COLUMNS
							PD_CLS_STANDARDS                    NVARCHAR2(100)  PATH 'string-join(PD_CLS_STANDARDS/text(), ",")'
							, PD_ACQ_CODE                       NUMBER(20)      PATH 'PD_ACQ_CODE'
							, PD_CYB_SEC_CD                     NVARCHAR2(100)  PATH 'string-join(PD_CYB_SEC_CD/text(), ",")'
							, PD_COMPET_LVL_CD                  NVARCHAR2(10)   PATH 'PD_COMPET_LVL_CD'
							, PD_BUS_CD                         NUMBER(20)      PATH 'PD_BUS_CD'
							, BYPASS_DWC_FL                     NVARCHAR2(10)   PATH 'BYPASS_DWC_FL'
					) XC
					, XMLTABLE('/DOCUMENT/APPROVAL'
						PASSING FD.FIELD_DATA
						COLUMNS
							PD_SUPV_CERT                        CHAR(1)         PATH 'if (PD_SUPV_CERT/text() = "true") then 1 else 0'
							, PD_SUPV_NAME                      NVARCHAR2(100)  PATH 'PD_SUPV_NAME'
							, PD_SUPV_TITLE                     NVARCHAR2(140)  PATH 'PD_SUPV_TITLE'
							, PD_SUPV_SIG                       NVARCHAR2(10)   PATH 'PD_SUPV_SIG'
							, PD_SUPV_SIG_DT                    DATE            PATH 'PD_SUPV_SIG_DT'
							, PD_CLS_SPEC_CERT                  CHAR(1)         PATH 'if (PD_CLS_SPEC_CERT/text() = "true") then 1 else 0'
							, PD_CLS_SPEC_NAME                  NVARCHAR2(100)  PATH 'PD_CLS_SPEC_NAME'
							, PD_CLS_SPEC_TITLE                 NVARCHAR2(140)  PATH 'PD_CLS_SPEC_TITLE'
							, PD_CLS_SPEC_SIG                   NVARCHAR2(10)   PATH 'PD_CLS_SPEC_SIG'
							, PD_CLS_SPEC_DT                    DATE            PATH 'PD_CLS_SPEC_DT'
					) XA
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.PD_REQ_ID = TRG.PD_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.PD_PROCID               = SRC.PD_PROCID
				, TRG.PD_ORG_POS_TITLE      = SRC.PD_ORG_POS_TITLE
				, TRG.PD_EMPLOYING_OFFICE   = SRC.PD_EMPLOYING_OFFICE
				, TRG.PD_SUBJECT_IA    	    = SRC.PD_SUBJECT_IA
				, TRG.PD_ORGANIZATION       = SRC.PD_ORGANIZATION
				, TRG.PD_SUB_ORG_1          = SRC.PD_SUB_ORG_1
				, TRG.PD_SUB_ORG_2          = SRC.PD_SUB_ORG_2
				, TRG.PD_SUB_ORG_3          = SRC.PD_SUB_ORG_3
				, TRG.PD_SUB_ORG_4          = SRC.PD_SUB_ORG_4
				, TRG.PD_SUB_ORG_5          = SRC.PD_SUB_ORG_5
				, TRG.PD_SCOPE              = SRC.PD_SCOPE
				, TRG.PD_PCA                = SRC.PD_PCA
				, TRG.PD_PDP                = SRC.PD_PDP
				, TRG.PD_FTT                = SRC.PD_FTT
				, TRG.PD_OUTSTATION         = SRC.PD_OUTSTATION
				, TRG.PD_INCUMBENCY         = SRC.PD_INCUMBENCY
				, TRG.PD_REMARKS            = SRC.PD_REMARKS
				, TRG.PD_CLS_STANDARDS      = SRC.PD_CLS_STANDARDS
				, TRG.PD_ACQ_CODE           = SRC.PD_ACQ_CODE
				, TRG.PD_CYB_SEC_CD         = SRC.PD_CYB_SEC_CD
				, TRG.PD_COMPET_LVL_CD      = SRC.PD_COMPET_LVL_CD
				, TRG.PD_BUS_CD             = SRC.PD_BUS_CD
				, TRG.BYPASS_DWC_FL         = SRC.BYPASS_DWC_FL
				, TRG.PD_SUPV_CERT          = SRC.PD_SUPV_CERT
				, TRG.PD_SUPV_NAME          = SRC.PD_SUPV_NAME
				, TRG.PD_SUPV_TITLE         = SRC.PD_SUPV_TITLE
				, TRG.PD_SUPV_SIG           = SRC.PD_SUPV_SIG
				, TRG.PD_SUPV_SIG_DT        = SRC.PD_SUPV_SIG_DT
				, TRG.PD_CLS_SPEC_CERT      = SRC.PD_CLS_SPEC_CERT
				, TRG.PD_CLS_SPEC_NAME      = SRC.PD_CLS_SPEC_NAME
				, TRG.PD_CLS_SPEC_TITLE     = SRC.PD_CLS_SPEC_TITLE
				, TRG.PD_CLS_SPEC_SIG       = SRC.PD_CLS_SPEC_SIG
				, TRG.PD_CLS_SPEC_DT        = SRC.PD_CLS_SPEC_DT
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.PD_REQ_ID
				, TRG.PD_PROCID
				, TRG.PD_ORG_POS_TITLE
				, TRG.PD_EMPLOYING_OFFICE
				, TRG.PD_SUBJECT_IA
				, TRG.PD_ORGANIZATION
				, TRG.PD_SUB_ORG_1
				, TRG.PD_SUB_ORG_2
				, TRG.PD_SUB_ORG_3
				, TRG.PD_SUB_ORG_4
				, TRG.PD_SUB_ORG_5
				, TRG.PD_SCOPE
				, TRG.PD_PCA
				, TRG.PD_PDP
				, TRG.PD_FTT
				, TRG.PD_OUTSTATION
				, TRG.PD_INCUMBENCY
				, TRG.PD_REMARKS
				, TRG.PD_CLS_STANDARDS
				, TRG.PD_ACQ_CODE
				, TRG.PD_CYB_SEC_CD
				, TRG.PD_COMPET_LVL_CD
				, TRG.PD_BUS_CD
				, TRG.BYPASS_DWC_FL
				, TRG.PD_SUPV_CERT
				, TRG.PD_SUPV_NAME
				, TRG.PD_SUPV_TITLE
				, TRG.PD_SUPV_SIG
				, TRG.PD_SUPV_SIG_DT
				, TRG.PD_CLS_SPEC_CERT
				, TRG.PD_CLS_SPEC_NAME
				, TRG.PD_CLS_SPEC_TITLE
				, TRG.PD_CLS_SPEC_SIG
				, TRG.PD_CLS_SPEC_DT
			)
			VALUES
			(
				SRC.PD_REQ_ID
				, SRC.PD_PROCID
				, SRC.PD_ORG_POS_TITLE
				, SRC.PD_EMPLOYING_OFFICE
				, SRC.PD_SUBJECT_IA
				, SRC.PD_ORGANIZATION
				, SRC.PD_SUB_ORG_1
				, SRC.PD_SUB_ORG_2
				, SRC.PD_SUB_ORG_3
				, SRC.PD_SUB_ORG_4
				, SRC.PD_SUB_ORG_5
				, SRC.PD_SCOPE
				, SRC.PD_PCA
				, SRC.PD_PDP
				, SRC.PD_FTT
				, SRC.PD_OUTSTATION
				, SRC.PD_INCUMBENCY
				, SRC.PD_REMARKS
				, SRC.PD_CLS_STANDARDS
				, SRC.PD_ACQ_CODE
				, SRC.PD_CYB_SEC_CD
				, SRC.PD_COMPET_LVL_CD
				, SRC.PD_BUS_CD
				, SRC.BYPASS_DWC_FL
				, SRC.PD_SUPV_CERT
				, SRC.PD_SUPV_NAME
				, SRC.PD_SUPV_TITLE
				, SRC.PD_SUPV_SIG
				, SRC.PD_SUPV_SIG_DT
				, SRC.PD_CLS_SPEC_CERT
				, SRC.PD_CLS_SPEC_NAME
				, SRC.PD_CLS_SPEC_TITLE
				, SRC.PD_CLS_SPEC_SIG
				, SRC.PD_CLS_SPEC_DT
			)
			;


			--------------------------------
			-- Get V_PD_ID for FLSA table
			--------------------------------
			BEGIN
				SELECT PD_ID INTO V_PD_ID
				FROM PD_COVERSHEET
				WHERE PD_REQ_ID = V_JOB_REQ_ID;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN V_JOB_REQ_ID := NULL;
			END;

			--------------------------------
			-- FLSA table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    FLSA table');
			MERGE INTO FLSA TRG
			USING
			(
				SELECT
					V_PD_ID AS FLSA_PD_ID
					, XE.FLSA_EX_EXEC
					, XE.FLSA_EX_ADMIN
					, XE.FLSA_EX_PROF_LEARNED
					, XE.FLSA_EX_PROF_CREATIVE
					, XE.FLSA_EX_PROF_COMPUTER
					, XE.FLSA_EX_LAW_ENFORC
					, XE.FLSA_EX_FOREIGN
					, XE.FLSA_EX_REMARKS
					, XN.FLSA_NONEX_SALARY
					, XN.FLSA_NONEX_EQUIP_OPER
					, XN.FLSA_NONEX_TECHN
					, XN.FLSA_NONEX_FED_WAGE_SYS
					, XN.FLSA_NONEX_REMARKS
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/FLSA_EX'
						PASSING FD.FIELD_DATA
						COLUMNS
							FLSA_EX_EXEC                        CHAR(1)         PATH 'if (FLSA_EX_EXEC/text() = "true") then 1 else 0'
							, FLSA_EX_ADMIN                     CHAR(1)         PATH 'if (FLSA_EX_ADMIN/text() = "true") then 1 else 0'
							, FLSA_EX_PROF_LEARNED              CHAR(1)         PATH 'if (FLSA_EX_PROF_LEARNED/text() = "true") then 1 else 0'
							, FLSA_EX_PROF_CREATIVE             CHAR(1)         PATH 'if (FLSA_EX_PROF_CREATIVE/text() = "true") then 1 else 0'
							, FLSA_EX_PROF_COMPUTER             CHAR(1)         PATH 'if (FLSA_EX_PROF_COMPUTER/text() = "true") then 1 else 0'
							, FLSA_EX_LAW_ENFORC                CHAR(1)         PATH 'if (FLSA_EX_LAW_ENFORC/text() = "true") then 1 else 0'
							, FLSA_EX_FOREIGN                   CHAR(1)         PATH 'if (FLSA_EX_FOREIGN/text() = "true") then 1 else 0'
							, FLSA_EX_REMARKS                   NVARCHAR2(140)  PATH 'FLSA_REMARKS'
					) XE
					, XMLTABLE('/DOCUMENT/FLSA_NONEX'
						PASSING FD.FIELD_DATA
						COLUMNS
							FLSA_NONEX_SALARY                   CHAR(1)         PATH 'if (FLSA_NONEX_SALARY/text() = "true") then 1 else 0'
							, FLSA_NONEX_EQUIP_OPER             CHAR(1)         PATH 'if (FLSA_NONEX_EQUIP_OPER/text() = "true") then 1 else 0'
							, FLSA_NONEX_TECHN                  CHAR(1)         PATH 'if (FLSA_NONEX_TECHN/text() = "true") then 1 else 0'
							, FLSA_NONEX_FED_WAGE_SYS           CHAR(1)         PATH 'if (FLSA_NONEX_FED_WAGE_SYS/text() = "true") then 1 else 0'
							, FLSA_NONEX_REMARKS                NVARCHAR2(140)  PATH 'FLSA_REMARKS'
					) XN
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.FLSA_PD_ID = TRG.FLSA_PD_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.FLSA_EX_EXEC               = SRC.FLSA_EX_EXEC
				, TRG.FLSA_EX_ADMIN            = SRC.FLSA_EX_ADMIN
				, TRG.FLSA_EX_PROF_LEARNED     = SRC.FLSA_EX_PROF_LEARNED
				, TRG.FLSA_EX_PROF_CREATIVE    = SRC.FLSA_EX_PROF_CREATIVE
				, TRG.FLSA_EX_PROF_COMPUTER    = SRC.FLSA_EX_PROF_COMPUTER
				, TRG.FLSA_EX_LAW_ENFORC       = SRC.FLSA_EX_LAW_ENFORC
				, TRG.FLSA_EX_FOREIGN          = SRC.FLSA_EX_FOREIGN
				, TRG.FLSA_EX_REMARKS          = SRC.FLSA_EX_REMARKS
				, TRG.FLSA_NONEX_SALARY        = SRC.FLSA_NONEX_SALARY
				, TRG.FLSA_NONEX_EQUIP_OPER    = SRC.FLSA_NONEX_EQUIP_OPER
				, TRG.FLSA_NONEX_TECHN         = SRC.FLSA_NONEX_TECHN
				, TRG.FLSA_NONEX_FED_WAGE_SYS  = SRC.FLSA_NONEX_FED_WAGE_SYS
				, TRG.FLSA_NONEX_REMARKS       = SRC.FLSA_NONEX_REMARKS
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.FLSA_PD_ID
				, TRG.FLSA_EX_EXEC
				, TRG.FLSA_EX_ADMIN
				, TRG.FLSA_EX_PROF_LEARNED
				, TRG.FLSA_EX_PROF_CREATIVE
				, TRG.FLSA_EX_PROF_COMPUTER
				, TRG.FLSA_EX_LAW_ENFORC
				, TRG.FLSA_EX_FOREIGN
				, TRG.FLSA_EX_REMARKS
				, TRG.FLSA_NONEX_SALARY
				, TRG.FLSA_NONEX_EQUIP_OPER
				, TRG.FLSA_NONEX_TECHN
				, TRG.FLSA_NONEX_FED_WAGE_SYS
				, TRG.FLSA_NONEX_REMARKS
			)
			VALUES
			(
				SRC.FLSA_PD_ID
				, SRC.FLSA_EX_EXEC
				, SRC.FLSA_EX_ADMIN
				, SRC.FLSA_EX_PROF_LEARNED
				, SRC.FLSA_EX_PROF_CREATIVE
				, SRC.FLSA_EX_PROF_COMPUTER
				, SRC.FLSA_EX_LAW_ENFORC
				, SRC.FLSA_EX_FOREIGN
				, SRC.FLSA_EX_REMARKS
				, SRC.FLSA_NONEX_SALARY
				, SRC.FLSA_NONEX_EQUIP_OPER
				, SRC.FLSA_NONEX_TECHN
				, SRC.FLSA_NONEX_FED_WAGE_SYS
				, SRC.FLSA_NONEX_REMARKS
			)
			;

		EXCEPTION
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20905, 'SP_UPDATE_CLSF_TABLE: Invalid Classification data.  I_PROCID = '
					|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END;
		--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_CLSF_TABLE - END ==========================');

	END IF;

EXCEPTION
	WHEN E_INVALID_PROCID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
	WHEN E_INVALID_JOB_REQ_ID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
	WHEN E_INVALID_STRATCON_DATA THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
END;

/





--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_CLSF
--------------------------------------------------------

/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * the Classification process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 */
create or replace PROCEDURE SP_UPDATE_PV_CLSF
(
	I_PROCID            IN      NUMBER
	, I_FIELD_DATA      IN      XMLTYPE
)
IS
	V_RLVNTDATANAME VARCHAR2(100);
	V_VALUE NVARCHAR2(2000);
	V_VALUE_LOOKUP NVARCHAR2(2000);
	V_REC_CNT NUMBER(10);
	V_XMLDOC XMLTYPE;
	V_XMLVALUE XMLTYPE;
    V_VALUE1	NVARCHAR2(2000);
    V_VALUE2	NVARCHAR2(2000);
    V_VALUE3	NVARCHAR2(2000);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
	--DBMS_OUTPUT.PUT_LINE(' ----------------');
	--V_XMLDOC := XMLTYPE(I_FIELD_DATA);
	V_XMLDOC := I_FIELD_DATA;


	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		--DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

		V_RLVNTDATANAME := 'adminCode';
		--V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_AC_ID/text()');
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_ADMIN_CD/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		--	---------------------------------
		--	-- replace with admin code desc lookup value
		--	---------------------------------
		--	BEGIN
		--		SELECT AC_ADMIN_CD INTO V_VALUE_LOOKUP
		--		FROM ADMIN_CODES
		--		WHERE AC_ID = TO_NUMBER(V_VALUE);
		--	EXCEPTION
		--		WHEN NO_DATA_FOUND THEN
		--			V_VALUE_LOOKUP := NULL;
		--		WHEN OTHERS THEN
		--			V_VALUE_LOOKUP := NULL;
		--	END;
		--	V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


--adminEmailAddress


		V_RLVNTDATANAME := 'cancelReason';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'classSpecialist';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'coversheetApprovedBySO';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/coversheetApprovedBySO/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		--V_RLVNTDATANAME := 'execOfficer';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;      
            SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
            SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;
                    
            V_RLVNTDATANAME := 'memIdExecOff';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE1 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            IF V_VALUE1 IS NOT NULL THEN
                V_VALUE1 := '[U]' || V_VALUE1;
            END IF;  
            V_RLVNTDATANAME := 'execOfficer';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE1 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'memIdExecOff2';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE2 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            IF V_VALUE2 IS NOT NULL THEN
                V_VALUE2 := '[U]' || V_VALUE2;
            END IF;  
            V_RLVNTDATANAME := 'execOfficer2';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE2 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'memIdExecOff3';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE3 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            IF V_VALUE3 IS NOT NULL THEN
                V_VALUE3 := '[U]' || V_VALUE3;
            END IF;
            V_RLVNTDATANAME := 'execOfficer3';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE3 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
        ELSE
            V_VALUE := NULL;
            
            V_RLVNTDATANAME := 'memIdExecOff';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'memIdExecOff2';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'memIdExecOff3';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'execOfficer';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'execOfficer2';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'execOfficer3';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
        END IF;

		V_RLVNTDATANAME := 'finalPackageApprovedSO';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/finalPackageApprovedSO/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'hrLiaison';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/HRL_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'lastActivityCompDate';
		BEGIN
			SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
		EXCEPTION
			WHEN OTHERS THEN V_VALUE := NULL;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'modifyCoversheetFeedback';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/modifyCoversheetFeedback/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'modifyFinalPackageFeedback';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/modifyFinalPackageFeedback/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


--posGrade


		V_RLVNTDATANAME := 'posIs';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_SUPERVISORY/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posLocation';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/PD_EMPLOYING_OFFICE/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

-------------------
--TODO: maybe we need this
		V_RLVNTDATANAME := 'posPayPlan';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/CS_PAY_PLAN_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				--WHERE TBL_ID = TO_NUMBER(V_VALUE);
				WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = V_VALUE;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


--posNumber


		V_RLVNTDATANAME := 'posSensitivity';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/CLASSIFICATION_CODE/CS_SEC_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posSeries';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_SR_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				--WHERE TBL_ID = TO_NUMBER(V_VALUE);
				WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = V_VALUE;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posTitle';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_TITLE/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'requestStatus';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatus/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'requestStatusDate';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatusDate/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			-------------------------------------
			-- even though it is date, do not format or perform GMT conversion
			-------------------------------------
			V_VALUE := V_VALUE;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'returnToSO';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSO/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'selectOfficial';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'staffSpecialist';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			--V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
			-- If the Job Request is for Special Program, SS_ID may point to User Group,
			-- rather than individual user.  Therefore, lookup
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			BEGIN
				SELECT TYPE INTO V_VALUE_LOOKUP FROM BIZFLOW.MEMBER WHERE MEMBERID = V_VALUE;
			EXCEPTION
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;

			IF V_VALUE_LOOKUP IS NOT NULL THEN
				V_VALUE := '[' || V_VALUE_LOOKUP || ']' || V_XMLVALUE.GETSTRINGVAL();
			ELSE
				V_VALUE := NULL;
			END IF;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		--DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

		COMMIT;

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_CLSF -------------------');
END;




--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_ELIGQUAL
--------------------------------------------------------

/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * the Eligiblity and Qualification process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 */
create or replace PROCEDURE SP_UPDATE_PV_ELIGQUAL
(
	I_PROCID            IN      NUMBER
	, I_FIELD_DATA      IN      XMLTYPE
)
IS
	V_RLVNTDATANAME        VARCHAR2(100);
	V_VALUE                NVARCHAR2(2000);
	V_VALUE_LOOKUP         NVARCHAR2(2000);
	V_CURRENTDATE          DATE;
	V_CURRENTDATESTR       NVARCHAR2(30);
	V_VALUE_DATE           DATE;
	V_VALUE_DATESTR        NVARCHAR2(30);
	V_REC_CNT              NUMBER(10);
	V_XMLDOC               XMLTYPE;
	V_XMLVALUE             XMLTYPE;
    V_VALUE1               NVARCHAR2(2000);
    V_VALUE2               NVARCHAR2(2000);
    V_VALUE3               NVARCHAR2(2000);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('==== SP_UPDATE_PV_ELIGQUAL ==============================');
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
	--DBMS_OUTPUT.PUT_LINE(' ----------------');
	--V_XMLDOC := XMLTYPE(I_FIELD_DATA);
	V_XMLDOC := I_FIELD_DATA;


	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		--DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

		V_RLVNTDATANAME := 'adminCode';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/ADMIN_CD/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'appointmentType';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/AT_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'cancelReason';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'candidateApproved';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/candidateApproved/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'candidateName';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/CNDT_FIRST_NM/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/CNDT_LAST_NM/text()');
		IF V_VALUE IS NOT NULL AND V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_VALUE || ' ' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'classSpecialist';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'classificationType';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CT_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'disqualReason';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/REVIEW/DISQUAL_REASON/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'eligQualCandidate';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/eligQualCandidate/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'feedbackDCO';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/feedbackDCO/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'feedbackStaffSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/feedbackStaffSpec/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'hrLiaison';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/HRL_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'ineligReason';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/REVIEW/INELIG_REASON/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'lastActivityCompDate';
		BEGIN
			SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
		EXCEPTION
			WHEN OTHERS THEN V_VALUE := NULL;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdClassSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		--V_RLVNTDATANAME := 'memIdExecOff';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;      
            SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
            SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;
                    
            V_RLVNTDATANAME := 'memIdExecOff';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE1 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            IF V_VALUE1 IS NOT NULL THEN
                V_VALUE1 := '[U]' || V_VALUE1;
            END IF;  
            V_RLVNTDATANAME := 'execOfficer';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE1 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'memIdExecOff2';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE2 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            IF V_VALUE2 IS NOT NULL THEN
                V_VALUE2 := '[U]' || V_VALUE2;
            END IF;  
            V_RLVNTDATANAME := 'execOfficer2';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE2 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'memIdExecOff3';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE3 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            IF V_VALUE3 IS NOT NULL THEN
                V_VALUE3 := '[U]' || V_VALUE3;
            END IF;
            V_RLVNTDATANAME := 'execOfficer3';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE3 WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
        ELSE
            V_VALUE := NULL;
            
            V_RLVNTDATANAME := 'memIdExecOff';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'memIdExecOff2';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'memIdExecOff3';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'execOfficer';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'execOfficer2';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
            
            V_RLVNTDATANAME := 'execOfficer3';
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
        END IF;


		V_RLVNTDATANAME := 'memIdHrLiaison';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/HRL_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdSelectOff';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'memIdStaffSpec';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posIs';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/SUPERVISORY/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posLocation';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/LOCATION/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posSensitivity';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/SEC_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posSeries';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/SERIES/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				--WHERE TBL_ID = TO_NUMBER(V_VALUE);
				WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = V_VALUE;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posTitle';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_TITLE/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'requestStatus';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatus/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'requestStatusDate';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatusDate/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			-------------------------------------
			-- even though it is date, do not format or perform GMT conversion
			-------------------------------------
			V_VALUE := V_VALUE;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'requestType';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/RT_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'returnToSO';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSO/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- This pv can be updated from multiple workitem
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'secondSubOrg';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/ADMIN_CD/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with admin code desc lookup value
			---------------------------------
			BEGIN
				SELECT AC_ADMIN_CD_DESCR INTO V_VALUE_LOOKUP
				FROM ADMIN_CODES
				WHERE AC_ADMIN_CD = SUBSTR(V_VALUE, 1, 3);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'selectOfficial';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'staffSpecialist';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			--V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
			-- If the Job Request is for Special Program, SS_ID may point to User Group,
			-- rather than individual user.  Therefore, lookup
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			BEGIN
				SELECT TYPE INTO V_VALUE_LOOKUP FROM BIZFLOW.MEMBER WHERE MEMBERID = V_VALUE;
			EXCEPTION
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;

			IF V_VALUE_LOOKUP IS NOT NULL THEN
				V_VALUE := '[' || V_VALUE_LOOKUP || ']' || V_XMLVALUE.GETSTRINGVAL();
			ELSE
				V_VALUE := NULL;
			END IF;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		--DBMS_OUTPUT.PUT_LINE('End PV update SP_UPDATE_PV_ELIGQUAL -------------------');

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_ELIGQUAL -------------------');
END;



--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_ELIGQUAL_TABLE
--------------------------------------------------------

/**
 * Parses Eligiblity and Qualification form XML data and stores it
 * into the operational tables for Eligiblity and Qualification.
 *
 * @param I_PROCID - Process ID
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_ELIGQUAL_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
	V_JOB_REQ_ID                NUMBER(20);
	V_JOB_REQ_NUM               NVARCHAR2(50);
	V_CLOBVALUE                 CLOB;
	V_VALUE                     NVARCHAR2(4000);
	V_VALUE_LOOKUP              NVARCHAR2(2000);
	V_REC_CNT                   NUMBER(10);
	V_XMLDOC                    XMLTYPE;
	V_XMLVALUE                  XMLTYPE;
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
	E_INVALID_PROCID            EXCEPTION;
	E_INVALID_JOB_REQ_ID        EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
	E_INVALID_STRATCON_DATA     EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_STRATCON_DATA, -20905);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_ELIGQUAL_TABLE - BEGIN ============================');
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE(' ----------------');


	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		------------------------------------------------------
		-- Transfer XML data into operational table
		--
		-- 1. Get Job Request Number
		-- 1.1 Select it from data xml from TBL_FORM_DTL table.
		-- 1.2 If not found, select it from BIZFLOW.RLVNTDATA table.
		-- 2. If Job Request Number not found, issue error.
		-- 3. For each target table,
		-- 3.1. If record found for the REQ_ID, update record.
		-- 3.2. If record not found for the REQ_ID, insert record.
		------------------------------------------------------
		--DBMS_OUTPUT.PUT_LINE('Starting xml data retrieval and table update ----------');

		--------------------------------
		-- get Job Request Number
		--------------------------------
		BEGIN
			SELECT XMLQUERY('/DOCUMENT/PROCESS_VARIABLE/requestNum/text()'
				PASSING FD.FIELD_DATA RETURNING CONTENT).GETSTRINGVAL()
				, FD.FIELD_DATA
			INTO V_JOB_REQ_NUM, V_XMLDOC
			FROM TBL_FORM_DTL FD
			WHERE FD.PROCID = I_PROCID;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_NUM := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (from xml) = ' || V_JOB_REQ_NUM);
		IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
			BEGIN
				SELECT VALUE
				INTO V_JOB_REQ_NUM
				FROM BIZFLOW.RLVNTDATA
				WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'requestNum';
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_JOB_REQ_NUM := NULL;
					RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request Number is invalid.  I_PROCID = '
						|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
			END;
		END IF;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (after pv check) = ' || V_JOB_REQ_NUM);
		IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request Number is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END IF;

		--------------------------------
		-- REQUEST table
		--------------------------------
		--DBMS_OUTPUT.PUT_LINE('    REQUEST table');
		BEGIN
			SELECT REQ_ID INTO V_JOB_REQ_ID
			FROM REQUEST
			WHERE REQ_JOB_REQ_NUMBER = V_JOB_REQ_NUM;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_ID := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('        V_JOB_REQ_ID = ' || V_JOB_REQ_ID);

		-- Unlike STRATCON, REQUEST record must be available by the time ELIGQUAL starts
		IF V_JOB_REQ_ID IS NULL THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request ID is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END IF;

		BEGIN
			--------------------------------
			-- REQUEST table update for cancellation
			--------------------------------
			MERGE INTO REQUEST TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS REQ_ID
					, V_JOB_REQ_NUM AS REQ_JOB_REQ_NUMBER
					, X.REQ_CANCEL_DT_STR
					, TO_DATE(X.REQ_CANCEL_DT_STR, 'YYYY/MM/DD HH24:MI:SS') AS REQ_CANCEL_DT
					, X.REQ_CANCEL_REASON
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/PROCESS_VARIABLE'
						PASSING FD.FIELD_DATA
						COLUMNS
							REQ_CANCEL_DT_STR                   NVARCHAR2(30)   PATH 'if (requestStatus/text() = "Request Cancelled") then requestStatusDate else ""'
							, REQ_CANCEL_REASON                 NVARCHAR2(140)  PATH 'cancelReason'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.REQ_ID = TRG.REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.REQ_CANCEL_DT           = SRC.REQ_CANCEL_DT
				, TRG.REQ_CANCEL_REASON     = SRC.REQ_CANCEL_REASON
			;
		END;


		BEGIN

			--------------------------------
			-- ELIG_QUAL table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    ELIG_QUAL table');
			MERGE INTO ELIG_QUAL TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS REQ_ID
					, I_PROCID AS PROCID

					, X.ADMIN_CD
					, X.RT_ID
					, X.AT_ID
					, X.VT_ID
					, X.SAT_ID
					, X.CT_ID
					, X.SO_ID
					, X.SO_TITLE
					, X.SO_ORG
					, X.XO_ID
					, X.XO_TITLE
					, X.XO_ORG
					, X.HRL_ID
					, X.HRL_TITLE
					, X.HRL_ORG
					, X.SS_ID
					, X.CS_ID
					, X.SO_AGREE
					, X.OTHER_CERT

					, X.CNDT_LAST_NM
					, X.CNDT_FIRST_NM
					, X.CNDT_MIDDLE_NM
					, X.BGT_APR_OFM
					, X.SPNSR_ORG_NM
					, X.SPNSR_ORG_FUND_PC
					, X.POS_TITLE
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = X.PAY_PLAN_ID AND ROWNUM = 1) AS PAY_PLAN_ID
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = X.SERIES AND ROWNUM = 1) AS SERIES
					, X.POS_DESC_NUMBER_1
					, X.CLASSIFICATION_DT_1
					, CASE WHEN LENGTH(X.GRADE_1) = 1 THEN '0' || X.GRADE_1 ELSE X.GRADE_1 END AS GRADE_1
					, X.POS_DESC_NUMBER_2
					, X.CLASSIFICATION_DT_2
					, CASE WHEN LENGTH(X.GRADE_2) = 1 THEN '0' || X.GRADE_2 ELSE X.GRADE_2 END AS GRADE_2
					, X.POS_DESC_NUMBER_3
					, X.CLASSIFICATION_DT_3
					, CASE WHEN LENGTH(X.GRADE_3) = 1 THEN '0' || X.GRADE_3 ELSE X.GRADE_3 END AS GRADE_3
					, X.POS_DESC_NUMBER_4
					, X.CLASSIFICATION_DT_4
					, CASE WHEN LENGTH(X.GRADE_4) = 1 THEN '0' || X.GRADE_4 ELSE X.GRADE_4 END AS GRADE_4
					, X.POS_DESC_NUMBER_5
					, X.CLASSIFICATION_DT_5
					, CASE WHEN LENGTH(X.GRADE_5) = 1 THEN '0' || X.GRADE_5 ELSE X.GRADE_5 END AS GRADE_5
					, X.MED_OFFICERS_ID
					, CASE WHEN LENGTH(X.PERFORMANCE_LEVEL) = 1 THEN '0' || X.PERFORMANCE_LEVEL ELSE X.PERFORMANCE_LEVEL END AS PERFORMANCE_LEVEL
					, X.SUPERVISORY
					, X.SKILL
					, X.LOCATION
					, X.VACANCIES
					, X.REPORT_SUPERVISOR
					, X.CAN
					, X.VICE
					, X.VICE_NAME
					, X.DAYS_ADVERTISED
					, X.TA_ID
					, X.NTE
					, X.WORK_SCHED_ID
					, X.HOURS_PER_WEEK
					, X.DUAL_EMPLMT
					, X.SEC_ID
					, X.CE_FINANCIAL_DISC
					, X.CE_FINANCIAL_TYPE_ID
					, X.CE_PE_PHYSICAL
					, X.CE_DRUG_TEST
					, X.CE_IMMUN
					, X.CE_TRAVEL
					, X.CE_TRAVEL_PER
					, X.CE_LIC
					, X.CE_LIC_INFO
					, X.REMARKS
					, X.PROC_REQ_TYPE
					, X.RECRUIT_OFFICE_ID
					, X.REQ_CREATE_NOTIFY_DT
					, X.ASSOC_DESCR_NUMBERS
					, X.PROMOTE_POTENTIAL
					, X.VICE_EMPL_ID
					, X.SR_ID
					, X.GR_ID
					, X.GA_1
					, X.GA_2
					, X.GA_3
					, X.GA_4
					, X.GA_5
					, X.GA_6
					, X.GA_7
					, X.GA_8
					, X.GA_9
					, X.GA_10
					, X.GA_11
					, X.GA_12
					, X.GA_13
					, X.GA_14
					, X.GA_15

					, X.CNDT_ELIGIBLE
					, X.INELIG_REASON
					, X.CNDT_QUALIFIED
					, X.DISQUAL_REASON

					, X.SEL_DETERM

					, X.DCO_CERT
					, X.DCO_NAME
					, X.DCO_SIG
					, X.DCO_SIG_DT

				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT'
						PASSING FD.FIELD_DATA
						COLUMNS

							ADMIN_CD                        NVARCHAR2(8)    PATH 'GENERAL/ADMIN_CD'
							, RT_ID                         NUMBER(20)      PATH 'GENERAL/RT_ID'
							, AT_ID                         NUMBER(20)      PATH 'GENERAL/AT_ID'
							, VT_ID                         NUMBER(20)      PATH 'GENERAL/VT_ID'
							, SAT_ID                        NUMBER(20)      PATH 'GENERAL/SAT_ID'
							, CT_ID                         NUMBER(20)      PATH 'GENERAL/CT_ID'
							, SO_ID                         NVARCHAR2(10)   PATH 'GENERAL/SO_ID'
							, SO_TITLE                      NVARCHAR2(50)   PATH 'GENERAL/SO_TITLE'
							, SO_ORG                        NVARCHAR2(50)   PATH 'GENERAL/SO_ORG'
							, XO_ID                         NVARCHAR2(32)   PATH 'GENERAL/XO_ID'
							, XO_TITLE                      NVARCHAR2(200)   PATH 'GENERAL/XO_TITLE'
							, XO_ORG                        NVARCHAR2(200)   PATH 'GENERAL/XO_ORG'
							, HRL_ID                        NVARCHAR2(10)   PATH 'GENERAL/HRL_ID'
							, HRL_TITLE                     NVARCHAR2(50)   PATH 'GENERAL/HRL_TITLE'
							, HRL_ORG                       NVARCHAR2(50)   PATH 'GENERAL/HRL_ORG'
							, SS_ID                         NVARCHAR2(10)   PATH 'GENERAL/SS_ID'
							, CS_ID                         NVARCHAR2(10)   PATH 'GENERAL/CS_ID'
							, SO_AGREE                      CHAR(1)         PATH 'if (GENERAL/SO_AGREE/text() = "true") then 1 else 0'
							, OTHER_CERT                    NVARCHAR2(200)  PATH 'GENERAL/OTHER_CERT'

							, CNDT_LAST_NM                  NVARCHAR2(50)   PATH 'POSITION/CNDT_LAST_NM'
							, CNDT_FIRST_NM                 NVARCHAR2(50)   PATH 'POSITION/CNDT_FIRST_NM'
							, CNDT_MIDDLE_NM                NVARCHAR2(50)   PATH 'POSITION/CNDT_MIDDLE_NM'
							, BGT_APR_OFM                   CHAR(1)         PATH 'POSITION/BGT_APR_OFM'
							, SPNSR_ORG_NM                  NVARCHAR2(140)  PATH 'POSITION/SPNSR_ORG_NM'
							, SPNSR_ORG_FUND_PC             NUMBER(3,0)     PATH 'POSITION/SPNSR_ORG_FUND_PC'
							, POS_TITLE                     NVARCHAR2(140)  PATH 'POSITION/POS_TITLE'
							, PAY_PLAN_ID                   VARCHAR2(140)   PATH 'POSITION/PAY_PLAN_ID'
							, SERIES                        VARCHAR2(140)   PATH 'POSITION/SERIES'
							, POS_DESC_NUMBER_1             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_1'
							, CLASSIFICATION_DT_1           DATE            PATH 'POSITION/CLASSIFICATION_DT_1'
							, GRADE_1                       VARCHAR2(2)     PATH 'POSITION/GRADE_1'
							, POS_DESC_NUMBER_2             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_2'
							, CLASSIFICATION_DT_2           DATE            PATH 'POSITION/CLASSIFICATION_DT_2'
							, GRADE_2                       VARCHAR2(2)     PATH 'POSITION/GRADE_2'
							, POS_DESC_NUMBER_3             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_3'
							, CLASSIFICATION_DT_3           DATE            PATH 'POSITION/CLASSIFICATION_DT_3'
							, GRADE_3                       VARCHAR2(2)     PATH 'POSITION/GRADE_3'
							, POS_DESC_NUMBER_4             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_4'
							, CLASSIFICATION_DT_4           DATE            PATH 'POSITION/CLASSIFICATION_DT_4'
							, GRADE_4                       VARCHAR2(2)     PATH 'POSITION/GRADE_4'
							, POS_DESC_NUMBER_5             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_5'
							, CLASSIFICATION_DT_5           DATE            PATH 'POSITION/CLASSIFICATION_DT_5'
							, GRADE_5                       VARCHAR2(2)     PATH 'POSITION/GRADE_5'
							, MED_OFFICERS_ID               NUMBER(20)      PATH 'POSITION/MED_OFFICERS_ID'
							, PERFORMANCE_LEVEL             NVARCHAR2(2)    PATH 'POSITION/PERFORMANCE_LEVEL'
							, SUPERVISORY                   NUMBER(20)      PATH 'POSITION/SUPERVISORY'
							, SKILL                         NVARCHAR2(200)  PATH 'POSITION/SKILL'
							, LOCATION                      NVARCHAR2(2000) PATH 'POSITION/LOCATION'
							, VACANCIES                     NUMBER(9)       PATH 'POSITION/VACANCIES'
							, REPORT_SUPERVISOR             NVARCHAR2(10)   PATH 'POSITION/REPORT_SUPERVISOR'
							, CAN                           NVARCHAR2(8)    PATH 'POSITION/CAN'
							, VICE                          CHAR(1)         PATH 'POSITION/VICE'
							, VICE_NAME                     NVARCHAR2(50)   PATH 'POSITION/VICE_NAME'
							, DAYS_ADVERTISED               NVARCHAR2(50)   PATH 'POSITION/DAYS_ADVERTISED'
							, TA_ID                         NUMBER(20)      PATH 'POSITION/TA_ID'
							, NTE                           NVARCHAR2(140)  PATH 'POSITION/NTE'
							, WORK_SCHED_ID                 NUMBER(20)      PATH 'POSITION/WORK_SCHED_ID'
							, HOURS_PER_WEEK                NVARCHAR2(50)   PATH 'POSITION/HOURS_PER_WEEK'
							, DUAL_EMPLMT                   NVARCHAR2(10)   PATH 'POSITION/DUAL_EMPLMT'
							, SEC_ID                        NUMBER(20)      PATH 'POSITION/SEC_ID'
							, CE_FINANCIAL_DISC             CHAR(1)         PATH 'if (POSITION/CE_FINANCIAL_DISC/text() = "true") then 1 else 0'
							, CE_FINANCIAL_TYPE_ID          NUMBER(20)      PATH 'POSITION/CE_FINANCIAL_TYPE_ID'
							, CE_PE_PHYSICAL                CHAR(1)         PATH 'if (POSITION/CE_PE_PHYSICAL/text() = "true") then 1 else 0'
							, CE_DRUG_TEST                  CHAR(1)         PATH 'if (POSITION/CE_DRUG_TEST/text() = "true") then 1 else 0'
							, CE_IMMUN                      CHAR(1)         PATH 'if (POSITION/CE_IMMUN/text() = "true") then 1 else 0'
							, CE_TRAVEL                     CHAR(1)         PATH 'if (POSITION/CE_TRAVEL/text() = "true") then 1 else 0'
							, CE_TRAVEL_PER                 NVARCHAR2(3)    PATH 'POSITION/CE_TRAVEL_PER'
							, CE_LIC                        CHAR(1)         PATH 'if (POSITION/CE_LIC/text() = "true") then 1 else 0'
							, CE_LIC_INFO                   NVARCHAR2(140)  PATH 'POSITION/CE_LIC_INFO'
							, REMARKS                       NVARCHAR2(500)  PATH 'POSITION/REMARKS'
							, PROC_REQ_TYPE                 NUMBER(20)      PATH 'POSITION/PROC_REQ_TYPE'
							, RECRUIT_OFFICE_ID             NUMBER(20)      PATH 'POSITION/RECRUIT_OFFICE_ID'
							, REQ_CREATE_NOTIFY_DT          DATE            PATH 'POSITION/REQ_CREATE_NOTIFY_DT'
							, ASSOC_DESCR_NUMBERS           NVARCHAR2(100)  PATH 'POSITION/ASSOC_DESCR_NUMBERS'
							, PROMOTE_POTENTIAL             NUMBER(2)       PATH 'POSITION/PROMOTE_POTENTIAL'
							, VICE_EMPL_ID                  NVARCHAR2(25)   PATH 'POSITION/VICE_EMPL_ID'
							, SR_ID                         NUMBER(20)      PATH 'POSITION/SR_ID'
							, GR_ID                         NUMBER(20)      PATH 'POSITION/GR_ID'
							, GA_1                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_1/text() = "true") then 1 else 0'
							, GA_2                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_2/text() = "true") then 1 else 0'
							, GA_3                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_3/text() = "true") then 1 else 0'
							, GA_4                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_4/text() = "true") then 1 else 0'
							, GA_5                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_5/text() = "true") then 1 else 0'
							, GA_6                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_6/text() = "true") then 1 else 0'
							, GA_7                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_7/text() = "true") then 1 else 0'
							, GA_8                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_8/text() = "true") then 1 else 0'
							, GA_9                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_9/text() = "true") then 1 else 0'
							, GA_10                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_10/text() = "true") then 1 else 0'
							, GA_11                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_11/text() = "true") then 1 else 0'
							, GA_12                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_12/text() = "true") then 1 else 0'
							, GA_13                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_13/text() = "true") then 1 else 0'
							, GA_14                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_14/text() = "true") then 1 else 0'
							, GA_15                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_15/text() = "true") then 1 else 0'

							, CNDT_ELIGIBLE                 NVARCHAR2(10)   PATH 'REVIEW/CNDT_ELIGIBLE'
							, INELIG_REASON                 NUMBER(20,0)    PATH 'REVIEW/INELIG_REASON'
							, CNDT_QUALIFIED                NVARCHAR2(10)   PATH 'REVIEW/CNDT_QUALIFIED'
							, DISQUAL_REASON                NUMBER(20,0)    PATH 'REVIEW/DISQUAL_REASON'

							, SEL_DETERM                    NUMBER(20,0)    PATH 'SELECTION/SEL_DETERM'

							, DCO_CERT                      NVARCHAR2(10)   PATH 'APPROVAL/DCO_CERT'
							, DCO_NAME                      NVARCHAR2(100)  PATH 'APPROVAL/DCO_NAME'
							, DCO_SIG                       NVARCHAR2(100)  PATH 'APPROVAL/DCO_SIG'
							, DCO_SIG_DT                    DATE            PATH 'APPROVAL/DCO_SIG_DT'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.REQ_ID = TRG.REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.PROCID       = SRC.PROCID

				, TRG.ADMIN_CD   = SRC.ADMIN_CD
				, TRG.RT_ID      = SRC.RT_ID
				, TRG.CT_ID      = SRC.CT_ID
				, TRG.AT_ID      = SRC.AT_ID
				, TRG.VT_ID      = SRC.VT_ID
				, TRG.SAT_ID     = SRC.SAT_ID
				, TRG.SO_ID      = SRC.SO_ID
				, TRG.SO_TITLE   = SRC.SO_TITLE
				, TRG.SO_ORG     = SRC.SO_ORG
				, TRG.XO_ID      = SRC.XO_ID
				, TRG.XO_TITLE   = SRC.XO_TITLE
				, TRG.XO_ORG     = SRC.XO_ORG
				, TRG.HRL_ID     = SRC.HRL_ID
				, TRG.HRL_TITLE  = SRC.HRL_TITLE
				, TRG.HRL_ORG    = SRC.HRL_ORG
				, TRG.SS_ID      = SRC.SS_ID
				, TRG.CS_ID      = SRC.CS_ID
				, TRG.SO_AGREE   = SRC.SO_AGREE
				, TRG.OTHER_CERT = SRC.OTHER_CERT

				, TRG.CNDT_LAST_NM          = SRC.CNDT_LAST_NM
				, TRG.CNDT_FIRST_NM         = SRC.CNDT_FIRST_NM
				, TRG.CNDT_MIDDLE_NM        = SRC.CNDT_MIDDLE_NM
				, TRG.BGT_APR_OFM           = SRC.BGT_APR_OFM
				, TRG.SPNSR_ORG_NM          = SRC.SPNSR_ORG_NM
				, TRG.SPNSR_ORG_FUND_PC     = SRC.SPNSR_ORG_FUND_PC
				, TRG.POS_TITLE             = SRC.POS_TITLE
				, TRG.PAY_PLAN_ID           = SRC.PAY_PLAN_ID
				, TRG.SERIES                = SRC.SERIES
				, TRG.POS_DESC_NUMBER_1     = SRC.POS_DESC_NUMBER_1
				, TRG.CLASSIFICATION_DT_1   = SRC.CLASSIFICATION_DT_1
				, TRG.GRADE_1               = SRC.GRADE_1
				, TRG.POS_DESC_NUMBER_2     = SRC.POS_DESC_NUMBER_2
				, TRG.CLASSIFICATION_DT_2   = SRC.CLASSIFICATION_DT_2
				, TRG.GRADE_2               = SRC.GRADE_2
				, TRG.POS_DESC_NUMBER_3     = SRC.POS_DESC_NUMBER_3
				, TRG.CLASSIFICATION_DT_3   = SRC.CLASSIFICATION_DT_3
				, TRG.GRADE_3               = SRC.GRADE_3
				, TRG.POS_DESC_NUMBER_4     = SRC.POS_DESC_NUMBER_4
				, TRG.CLASSIFICATION_DT_4   = SRC.CLASSIFICATION_DT_4
				, TRG.GRADE_4               = SRC.GRADE_4
				, TRG.POS_DESC_NUMBER_5     = SRC.POS_DESC_NUMBER_5
				, TRG.CLASSIFICATION_DT_5   = SRC.CLASSIFICATION_DT_5
				, TRG.GRADE_5               = SRC.GRADE_5
				, TRG.MED_OFFICERS_ID       = SRC.MED_OFFICERS_ID
				, TRG.PERFORMANCE_LEVEL     = SRC.PERFORMANCE_LEVEL
				, TRG.SUPERVISORY           = SRC.SUPERVISORY
				, TRG.SKILL                 = SRC.SKILL
				, TRG.LOCATION              = SRC.LOCATION
				, TRG.VACANCIES             = SRC.VACANCIES
				, TRG.REPORT_SUPERVISOR     = SRC.REPORT_SUPERVISOR
				, TRG.CAN                   = SRC.CAN
				, TRG.VICE                  = SRC.VICE
				, TRG.VICE_NAME             = SRC.VICE_NAME
				, TRG.DAYS_ADVERTISED       = SRC.DAYS_ADVERTISED
				, TRG.TA_ID                 = SRC.TA_ID
				, TRG.NTE                   = SRC.NTE
				, TRG.WORK_SCHED_ID         = SRC.WORK_SCHED_ID
				, TRG.HOURS_PER_WEEK        = SRC.HOURS_PER_WEEK
				, TRG.DUAL_EMPLMT           = SRC.DUAL_EMPLMT
				, TRG.SEC_ID                = SRC.SEC_ID
				, TRG.CE_FINANCIAL_DISC     = SRC.CE_FINANCIAL_DISC
				, TRG.CE_FINANCIAL_TYPE_ID  = SRC.CE_FINANCIAL_TYPE_ID
				, TRG.CE_PE_PHYSICAL        = SRC.CE_PE_PHYSICAL
				, TRG.CE_DRUG_TEST          = SRC.CE_DRUG_TEST
				, TRG.CE_IMMUN              = SRC.CE_IMMUN
				, TRG.CE_TRAVEL             = SRC.CE_TRAVEL
				, TRG.CE_TRAVEL_PER         = SRC.CE_TRAVEL_PER
				, TRG.CE_LIC                = SRC.CE_LIC
				, TRG.CE_LIC_INFO           = SRC.CE_LIC_INFO
				, TRG.REMARKS               = SRC.REMARKS
				, TRG.PROC_REQ_TYPE         = SRC.PROC_REQ_TYPE
				, TRG.RECRUIT_OFFICE_ID     = SRC.RECRUIT_OFFICE_ID
				, TRG.REQ_CREATE_NOTIFY_DT  = SRC.REQ_CREATE_NOTIFY_DT
				, TRG.ASSOC_DESCR_NUMBERS   = SRC.ASSOC_DESCR_NUMBERS
				, TRG.PROMOTE_POTENTIAL     = SRC.PROMOTE_POTENTIAL
				, TRG.VICE_EMPL_ID          = SRC.VICE_EMPL_ID
				, TRG.SR_ID                 = SRC.SR_ID
				, TRG.GR_ID                 = SRC.GR_ID
				, TRG.GA_1                  = SRC.GA_1
				, TRG.GA_2                  = SRC.GA_2
				, TRG.GA_3                  = SRC.GA_3
				, TRG.GA_4                  = SRC.GA_4
				, TRG.GA_5                  = SRC.GA_5
				, TRG.GA_6                  = SRC.GA_6
				, TRG.GA_7                  = SRC.GA_7
				, TRG.GA_8                  = SRC.GA_8
				, TRG.GA_9                  = SRC.GA_9
				, TRG.GA_10                 = SRC.GA_10
				, TRG.GA_11                 = SRC.GA_11
				, TRG.GA_12                 = SRC.GA_12
				, TRG.GA_13                 = SRC.GA_13
				, TRG.GA_14                 = SRC.GA_14
				, TRG.GA_15                 = SRC.GA_15

				, TRG.CNDT_ELIGIBLE         = SRC.CNDT_ELIGIBLE
				, TRG.INELIG_REASON         = SRC.INELIG_REASON
				, TRG.CNDT_QUALIFIED        = SRC.CNDT_QUALIFIED
				, TRG.DISQUAL_REASON        = SRC.DISQUAL_REASON

				, TRG.SEL_DETERM            = SRC.SEL_DETERM

				, TRG.DCO_CERT              = SRC.DCO_CERT
				, TRG.DCO_NAME              = SRC.DCO_NAME
				, TRG.DCO_SIG               = SRC.DCO_SIG
				, TRG.DCO_SIG_DT            = SRC.DCO_SIG_DT

			WHEN NOT MATCHED THEN INSERT
			(
				TRG.REQ_ID
				, TRG.PROCID

				, TRG.ADMIN_CD
				, TRG.RT_ID
				, TRG.CT_ID
				, TRG.AT_ID
				, TRG.VT_ID
				, TRG.SAT_ID
				, TRG.SO_ID
				, TRG.SO_TITLE
				, TRG.SO_ORG
				, TRG.XO_ID
				, TRG.XO_TITLE
				, TRG.XO_ORG
				, TRG.HRL_ID
				, TRG.HRL_TITLE
				, TRG.HRL_ORG
				, TRG.SS_ID
				, TRG.CS_ID
				, TRG.SO_AGREE
				, TRG.OTHER_CERT

				, TRG.CNDT_LAST_NM
				, TRG.CNDT_FIRST_NM
				, TRG.CNDT_MIDDLE_NM
				, TRG.BGT_APR_OFM
				, TRG.SPNSR_ORG_NM
				, TRG.SPNSR_ORG_FUND_PC
				, TRG.POS_TITLE
				, TRG.PAY_PLAN_ID
				, TRG.SERIES
				, TRG.POS_DESC_NUMBER_1
				, TRG.CLASSIFICATION_DT_1
				, TRG.GRADE_1
				, TRG.POS_DESC_NUMBER_2
				, TRG.CLASSIFICATION_DT_2
				, TRG.GRADE_2
				, TRG.POS_DESC_NUMBER_3
				, TRG.CLASSIFICATION_DT_3
				, TRG.GRADE_3
				, TRG.POS_DESC_NUMBER_4
				, TRG.CLASSIFICATION_DT_4
				, TRG.GRADE_4
				, TRG.POS_DESC_NUMBER_5
				, TRG.CLASSIFICATION_DT_5
				, TRG.GRADE_5
				, TRG.MED_OFFICERS_ID
				, TRG.PERFORMANCE_LEVEL
				, TRG.SUPERVISORY
				, TRG.SKILL
				, TRG.LOCATION
				, TRG.VACANCIES
				, TRG.REPORT_SUPERVISOR
				, TRG.CAN
				, TRG.VICE
				, TRG.VICE_NAME
				, TRG.DAYS_ADVERTISED
				, TRG.TA_ID
				, TRG.NTE
				, TRG.WORK_SCHED_ID
				, TRG.HOURS_PER_WEEK
				, TRG.DUAL_EMPLMT
				, TRG.SEC_ID
				, TRG.CE_FINANCIAL_DISC
				, TRG.CE_FINANCIAL_TYPE_ID
				, TRG.CE_PE_PHYSICAL
				, TRG.CE_DRUG_TEST
				, TRG.CE_IMMUN
				, TRG.CE_TRAVEL
				, TRG.CE_TRAVEL_PER
				, TRG.CE_LIC
				, TRG.CE_LIC_INFO
				, TRG.REMARKS
				, TRG.PROC_REQ_TYPE
				, TRG.RECRUIT_OFFICE_ID
				, TRG.REQ_CREATE_NOTIFY_DT
				, TRG.ASSOC_DESCR_NUMBERS
				, TRG.PROMOTE_POTENTIAL
				, TRG.VICE_EMPL_ID
				, TRG.SR_ID
				, TRG.GR_ID
				, TRG.GA_1
				, TRG.GA_2
				, TRG.GA_3
				, TRG.GA_4
				, TRG.GA_5
				, TRG.GA_6
				, TRG.GA_7
				, TRG.GA_8
				, TRG.GA_9
				, TRG.GA_10
				, TRG.GA_11
				, TRG.GA_12
				, TRG.GA_13
				, TRG.GA_14
				, TRG.GA_15

				, TRG.CNDT_ELIGIBLE
				, TRG.INELIG_REASON
				, TRG.CNDT_QUALIFIED
				, TRG.DISQUAL_REASON

				, TRG.SEL_DETERM

				, TRG.DCO_CERT
				, TRG.DCO_NAME
				, TRG.DCO_SIG
				, TRG.DCO_SIG_DT
			)
			VALUES
			(
				SRC.REQ_ID
				, SRC.PROCID

				, SRC.ADMIN_CD
				, SRC.RT_ID
				, SRC.CT_ID
				, SRC.AT_ID
				, SRC.VT_ID
				, SRC.SAT_ID
				, SRC.SO_ID
				, SRC.SO_TITLE
				, SRC.SO_ORG
				, SRC.XO_ID
				, SRC.XO_TITLE
				, SRC.XO_ORG
				, SRC.HRL_ID
				, SRC.HRL_TITLE
				, SRC.HRL_ORG
				, SRC.SS_ID
				, SRC.CS_ID
				, SRC.SO_AGREE
				, SRC.OTHER_CERT

				, SRC.CNDT_LAST_NM
				, SRC.CNDT_FIRST_NM
				, SRC.CNDT_MIDDLE_NM
				, SRC.BGT_APR_OFM
				, SRC.SPNSR_ORG_NM
				, SRC.SPNSR_ORG_FUND_PC
				, SRC.POS_TITLE
				, SRC.PAY_PLAN_ID
				, SRC.SERIES
				, SRC.POS_DESC_NUMBER_1
				, SRC.CLASSIFICATION_DT_1
				, SRC.GRADE_1
				, SRC.POS_DESC_NUMBER_2
				, SRC.CLASSIFICATION_DT_2
				, SRC.GRADE_2
				, SRC.POS_DESC_NUMBER_3
				, SRC.CLASSIFICATION_DT_3
				, SRC.GRADE_3
				, SRC.POS_DESC_NUMBER_4
				, SRC.CLASSIFICATION_DT_4
				, SRC.GRADE_4
				, SRC.POS_DESC_NUMBER_5
				, SRC.CLASSIFICATION_DT_5
				, SRC.GRADE_5
				, SRC.MED_OFFICERS_ID
				, SRC.PERFORMANCE_LEVEL
				, SRC.SUPERVISORY
				, SRC.SKILL
				, SRC.LOCATION
				, SRC.VACANCIES
				, SRC.REPORT_SUPERVISOR
				, SRC.CAN
				, SRC.VICE
				, SRC.VICE_NAME
				, SRC.DAYS_ADVERTISED
				, SRC.TA_ID
				, SRC.NTE
				, SRC.WORK_SCHED_ID
				, SRC.HOURS_PER_WEEK
				, SRC.DUAL_EMPLMT
				, SRC.SEC_ID
				, SRC.CE_FINANCIAL_DISC
				, SRC.CE_FINANCIAL_TYPE_ID
				, SRC.CE_PE_PHYSICAL
				, SRC.CE_DRUG_TEST
				, SRC.CE_IMMUN
				, SRC.CE_TRAVEL
				, SRC.CE_TRAVEL_PER
				, SRC.CE_LIC
				, SRC.CE_LIC_INFO
				, SRC.REMARKS
				, SRC.PROC_REQ_TYPE
				, SRC.RECRUIT_OFFICE_ID
				, SRC.REQ_CREATE_NOTIFY_DT
				, SRC.ASSOC_DESCR_NUMBERS
				, SRC.PROMOTE_POTENTIAL
				, SRC.VICE_EMPL_ID
				, SRC.SR_ID
				, SRC.GR_ID
				, SRC.GA_1
				, SRC.GA_2
				, SRC.GA_3
				, SRC.GA_4
				, SRC.GA_5
				, SRC.GA_6
				, SRC.GA_7
				, SRC.GA_8
				, SRC.GA_9
				, SRC.GA_10
				, SRC.GA_11
				, SRC.GA_12
				, SRC.GA_13
				, SRC.GA_14
				, SRC.GA_15

				, SRC.CNDT_ELIGIBLE
				, SRC.INELIG_REASON
				, SRC.CNDT_QUALIFIED
				, SRC.DISQUAL_REASON

				, SRC.SEL_DETERM

				, SRC.DCO_CERT
				, SRC.DCO_NAME
				, SRC.DCO_SIG
				, SRC.DCO_SIG_DT
			)
			;

		EXCEPTION
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20905, 'SP_UPDATE_ELIGQUAL_TABLE: Invalid ELIGQUAL data.  I_PROCID = '
					|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END;

		--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_ELIGQUAL_TABLE - END ==========================');

	END IF;

EXCEPTION
	WHEN E_INVALID_PROCID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
	WHEN E_INVALID_JOB_REQ_ID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
	WHEN E_INVALID_STRATCON_DATA THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
END;

/




--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_FORM_DATA
--------------------------------------------------------

/**
 * Stores the form data XML in the form detail table (TBL_FORM_DTL).
 *
 * @param IO_ID - ID number the row of the TBL_FORM_DTL table to be inserted or updated.  It will be also used as the return object.
 * @param I_FORM_TYPE - Form Type to indicate the source form name, which will be
 * 				used to distinguish the xml structure.
 * @param I_FIELD_DATA - CLOB representation of the form xml data.
 * @param I_USER - Indicates the user who
 * @param I_PROCID - Process ID for the process instance associated with the given form data.
 * @param I_ACTSEQ - Activity Sequence for the process instance associated with the given form data.
 * @param I_WITEMSEQ - Work Item Sequence for the process instance associated with the given form data.
 *
 * @return IO_ID - ID number of the row of the TBL_FORM_DTL table inserted or updated.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_FORM_DATA
(
	IO_ID               IN OUT  NUMBER
	, I_FORM_TYPE       IN      VARCHAR2
	, I_FIELD_DATA      IN      CLOB
	, I_USER            IN      VARCHAR2
	, I_PROCID          IN      NUMBER
	, I_ACTSEQ          IN      NUMBER
	, I_WITEMSEQ        IN      NUMBER
)
IS
	V_ID                    NUMBER(20);
	V_FORM_TYPE             VARCHAR2(50);
	V_USER                  VARCHAR2(50);
	V_PROCID                NUMBER(10);
	V_ACTSEQ                NUMBER(10);
	V_WITEMSEQ              NUMBER(10);
	V_REC_CNT               NUMBER(10);
	V_MAX_ID                NUMBER(20);
	V_XMLDOC                XMLTYPE;
	V_XMLDOC_PREV           XMLTYPE;
	V_REQ_FORM_FIELD_XPATH  VARCHAR2(100);
	V_REQ_FORM_FIELD_PREV	VARCHAR2(500);
	V_REQ_FORM_FIELD        VARCHAR2(500);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    ID IS NULL?  = ' || (CASE WHEN IO_ID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    ID           = ' || TO_CHAR(IO_ID));
	--DBMS_OUTPUT.PUT_LINE('    I_FORM_TYPE  = ' || I_FORM_TYPE);
	--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA = ' || I_FIELD_DATA);
	--DBMS_OUTPUT.PUT_LINE('    I_USER       = ' || I_USER);
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID     = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    I_ACTSEQ     = ' || TO_CHAR(I_ACTSEQ));
	--DBMS_OUTPUT.PUT_LINE('    I_WITEMSEQ   = ' || TO_CHAR(I_WITEMSEQ));
	--DBMS_OUTPUT.PUT_LINE(' ----------------');

	-- sanity check: ignore and exit if form data xml is null or empty
	IF I_FIELD_DATA IS NULL OR LENGTH(I_FIELD_DATA) <= 0 THEN
		RETURN;
	END IF;
	V_XMLDOC := XMLTYPE(I_FIELD_DATA);
	V_FORM_TYPE := I_FORM_TYPE;

	IF IO_ID IS NOT NULL AND IO_ID > 0 THEN
		V_ID := IO_ID;
	ELSE
		--DBMS_OUTPUT.PUT_LINE('Attempt to find record using PROCID: ' || TO_CHAR(I_PROCID));
		-- if existing record is found using procid, use that id
		IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
			BEGIN
				SELECT ID INTO V_ID FROM TBL_FORM_DTL WHERE PROCID = I_PROCID;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_ID := -1;
			END;
		END IF;

		--DBMS_OUTPUT.PUT_LINE('No record found for PROCID: ' || TO_CHAR(I_PROCID));

		IO_ID := V_ID;
	END IF;

	--DBMS_OUTPUT.PUT_LINE('ID to be used is determined: ' || TO_CHAR(V_ID));

	BEGIN
		SELECT COUNT(*) INTO V_REC_CNT FROM TBL_FORM_DTL WHERE ID = V_ID;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			V_REC_CNT := -1;
	END;

	-- Make sure the existing form data xml is not wiped out by erroneous input
	-- Compare the required field value from the previous form data
	-- with the new one.  If the previous one is not empty but the new one
	-- is empty, then, ignore the update and exit.
	IF V_REC_CNT > 0 THEN

		IF V_FORM_TYPE = 'CMSSTRATCON' THEN
			V_REQ_FORM_FIELD_XPATH := '/DOCUMENT/POSITION/POS_TITLE/text()';
		ELSIF V_FORM_TYPE = 'CMSCLSF' THEN
			V_REQ_FORM_FIELD_XPATH := '/DOCUMENT/GENERAL/CS_TITLE/text()';
		ELSIF V_FORM_TYPE = 'CMSELIGQUAL' THEN
			V_REQ_FORM_FIELD_XPATH := '/DOCUMENT/POSITION/POS_TITLE/text()';
		ELSE
			V_REQ_FORM_FIELD_XPATH := '/INVALIDDOC';
		END IF;
		BEGIN
			SELECT
				FIELD_DATA
				, XMLQUERY(V_REQ_FORM_FIELD_XPATH PASSING FIELD_DATA RETURNING CONTENT).GETSTRINGVAL()
				, XMLQUERY(V_REQ_FORM_FIELD_XPATH PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL()
			INTO
				V_XMLDOC_PREV
				, V_REQ_FORM_FIELD_PREV
				, V_REQ_FORM_FIELD
			FROM TBL_FORM_DTL
			WHERE ID = V_ID;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_XMLDOC_PREV := NULL;
				V_REQ_FORM_FIELD_PREV := NULL;
				V_REQ_FORM_FIELD := NULL;
				SP_ERROR_LOG();
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_REQ_FORM_FIELD_PREV  = ' || V_REQ_FORM_FIELD_PREV);
		--DBMS_OUTPUT.PUT_LINE('    V_REQ_FORM_FIELD       = ' || V_REQ_FORM_FIELD);
		IF (V_REQ_FORM_FIELD_PREV IS NOT NULL AND LENGTH(V_REQ_FORM_FIELD_PREV) > 0)
			AND (V_REQ_FORM_FIELD IS NULL OR LENGTH(V_REQ_FORM_FIELD) <= 0)
		THEN
			RETURN;
		END IF;
	END IF;

	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		V_PROCID := I_PROCID;
	ELSE
		V_PROCID := 0;
	END IF;

	IF I_ACTSEQ IS NOT NULL AND I_ACTSEQ > 0 THEN
		V_ACTSEQ := I_ACTSEQ;
	ELSE
		V_ACTSEQ := 0;
	END IF;

	IF I_WITEMSEQ IS NOT NULL AND I_WITEMSEQ > 0 THEN
		V_WITEMSEQ := I_WITEMSEQ;
	ELSE
		V_WITEMSEQ := 0;
	END IF;

	V_USER := I_USER;

	--DBMS_OUTPUT.PUT_LINE('Inspected existence of same record.');
	--DBMS_OUTPUT.PUT_LINE('    V_ID       = ' || TO_CHAR(V_ID));
	--DBMS_OUTPUT.PUT_LINE('    V_PROCID   = ' || TO_CHAR(V_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    V_ACTSEQ   = ' || TO_CHAR(V_ACTSEQ));
	--DBMS_OUTPUT.PUT_LINE('    V_WITEMSEQ = ' || TO_CHAR(V_WITEMSEQ));
	--DBMS_OUTPUT.PUT_LINE('    V_REC_CNT  = ' || TO_CHAR(V_REC_CNT));

	-- Strategic Consultation specific xml data manipulation before insert/update
	IF V_FORM_TYPE = 'CMSSTRATCON' THEN
		SP_UPDATE_STRATCON_DATA( V_XMLDOC_PREV, V_XMLDOC );
	END IF;

	IF V_REC_CNT > 0 THEN
		--DBMS_OUTPUT.PUT_LINE('Record found so that field data will be updated on the same record.');

		UPDATE TBL_FORM_DTL
		SET
			PROCID          = V_PROCID
			, ACTSEQ        = V_ACTSEQ
			, WITEMSEQ      = V_WITEMSEQ
			, FIELD_DATA    = V_XMLDOC
			, MOD_DT        = SYSDATE
			, MOD_USR       = V_USER
		WHERE ID = V_ID
		;

	ELSE
		--DBMS_OUTPUT.PUT_LINE('No record found so that new record will be inserted.');

		INSERT INTO TBL_FORM_DTL
		(
--			ID
--			, PROCID
			PROCID
			, ACTSEQ
			, WITEMSEQ
			, FORM_TYPE
			, FIELD_DATA
			, CRT_DT
			, CRT_USR
		)
		VALUES
		(
--			V_ID
--			, V_PROCID
			V_PROCID
			, V_ACTSEQ
			, V_WITEMSEQ
			, V_FORM_TYPE
			, V_XMLDOC
			, SYSDATE
			, V_USER
		)
		;
	END IF;

	-- Update process variable and transition xml into individual tables
	-- for respective process definition
	IF V_FORM_TYPE = 'CMSSTRATCON' THEN
		SP_UPDATE_PV_STRATCON(V_PROCID, V_XMLDOC);
		SP_UPDATE_STRATCON_TABLE(V_PROCID);
	ELSIF V_FORM_TYPE = 'CMSCLSF' THEN
		SP_UPDATE_PV_CLSF(V_PROCID, V_XMLDOC);
		SP_UPDATE_CLSF_TABLE(V_PROCID);
	ELSIF V_FORM_TYPE = 'CMSELIGQUAL' THEN
		SP_UPDATE_PV_ELIGQUAL(V_PROCID, V_XMLDOC);
		SP_UPDATE_ELIGQUAL_TABLE(V_PROCID);
	ELSIF V_FORM_TYPE = 'CMSINCENTIVES' THEN
		SP_UPDATE_PV_INCENTIVES(V_PROCID, V_XMLDOC);
	ELSIF V_FORM_TYPE = 'CMSERLR' THEN
		SP_UPDATE_PV_ERLR(V_PROCID, V_XMLDOC);
	END IF;

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_FORM_DATA -------------------');
END;

/






/**
 * Looks up Strategic Consultation process instance records,
 * and calls SP_UPDATE_STRATCON_TABLE() to fills STRATCON tables
 * initially.
 */
CREATE OR REPLACE PROCEDURE SP_FILL_STRATCON_TABLE
IS
	V_PROCID                    NUMBER(20);
	V_LOOP_CNT                  NUMBER(10);

	REC_PROCS                   BIZFLOW.PROCS%ROWTYPE;
	TYPE PROCS_TYPE IS REF CURSOR RETURN BIZFLOW.PROCS%ROWTYPE;
	CUR_PROCS                   PROCS_TYPE;
BEGIN

	OPEN CUR_PROCS FOR
		SELECT *
		FROM BIZFLOW.PROCS
		WHERE NAME = 'Strategic Consultation'
		ORDER BY PROCID;
	--DBMS_OUTPUT.PUT_LINE('Opened cursor for PROCS');

	V_LOOP_CNT := 0;
	LOOP
		FETCH CUR_PROCS INTO REC_PROCS;
		EXIT WHEN CUR_PROCS%NOTFOUND;
		V_LOOP_CNT := V_LOOP_CNT + 1;
		V_PROCID := REC_PROCS.PROCID;
		--DBMS_OUTPUT.PUT_LINE('Fetched record, loop count = ' || TO_CHAR(V_LOOP_CNT) || ' PROCID = ' || V_PROCID);
		SP_UPDATE_STRATCON_TABLE(V_PROCID);
	END LOOP;
	CLOSE CUR_PROCS;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR no data found while executing SP_FILL_STRATCON_TABLE -------------------');
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_FILL_STRATCON_TABLE -------------------');
END;
/




/**
 * Looks up Classification process instance records,
 * and calls SP_UPDATE_STRATCON_TABLE() to fill CLSF tables
 * initially.
 */
CREATE OR REPLACE PROCEDURE SP_FILL_CLSF_TABLE
IS
	V_PROCID                    NUMBER(20);
	V_LOOP_CNT                  NUMBER(10);

	REC_PROCS                   BIZFLOW.PROCS%ROWTYPE;
	TYPE PROCS_TYPE IS REF CURSOR RETURN BIZFLOW.PROCS%ROWTYPE;
	CUR_PROCS                   PROCS_TYPE;
BEGIN

	OPEN CUR_PROCS FOR
		SELECT *
		FROM BIZFLOW.PROCS
		WHERE NAME = 'Classification'
		ORDER BY PROCID;
	--DBMS_OUTPUT.PUT_LINE('Opened cursor for PROCS');

	V_LOOP_CNT := 0;
	LOOP
		FETCH CUR_PROCS INTO REC_PROCS;
		EXIT WHEN CUR_PROCS%NOTFOUND;
		V_LOOP_CNT := V_LOOP_CNT + 1;
		V_PROCID := REC_PROCS.PROCID;
		--DBMS_OUTPUT.PUT_LINE('Fetched record, loop count = ' || TO_CHAR(V_LOOP_CNT) || ' PROCID = ' || V_PROCID);
		SP_UPDATE_CLSF_TABLE(V_PROCID);
	END LOOP;
	CLOSE CUR_PROCS;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR no data found while executing SP_FILL_CLSF_TABLE -------------------');
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_FILL_CLSF_TABLE -------------------');
END;
/








--------------------------------------------------------
--  DDL for Function FN_INIT_CLASSIFICATION
--------------------------------------------------------

/**
 * Retrieves the initial form data xml for Classification process
 * from the form data xml for the associated parent Strategic Consultation process instance.
 *
 * @param I_PROCID - Process ID of the Classification process.
 *
 * @return XMLTYPE - Form data xml as the initial Classification data.
 */
CREATE OR REPLACE FUNCTION FN_INIT_CLASSIFICATION
(
	I_PROCID                    IN NUMBER
)
RETURN XMLTYPE
IS
	V_PARENTPROCID              NUMBER(10);
	V_FIELD_DATA_SRC            XMLTYPE;
	V_FIELD_DATA_TRG            XMLTYPE;
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_INIT_CLASSIFICATION -------');

	-- get parent procid for Strategic Consultation process to pull data
	SELECT PARENTPROCID INTO V_PARENTPROCID
	FROM BIZFLOW.PROCS
	WHERE PROCID = I_PROCID;

	-- get form data xml
	--SELECT FIELD_DATA INTO V_FIELD_DATA_SRC
	--FROM TBL_FORM_DTL
	--WHERE PROCID = V_PARENTPROCID;


	-- construct initial Classification form data xml from the originating Strategic Consultation data
	--IF V_FIELD_DATA_SRC IS NOT NULL THEN
	--	--DBMS_OUTPUT.PUT_LINE('    V_FIELD_DATA_SRC = ' || V_FIELD_DATA_SRC.GETCLOBVAL());

		SELECT
			XMLQUERY(
				'
					<DOCUMENT>
						<MAIN>
							<SG_CT_ID>{data($sc/DOCUMENT/GENERAL/SG_CT_ID)}</SG_CT_ID>
						</MAIN>
						<GENERAL>
							<CS_TITLE>{data($sc/DOCUMENT/POSITION/POS_TITLE)}</CS_TITLE>
							<CS_PAY_PLAN_ID>{data($sc/DOCUMENT/POSITION/POS_PAY_PLAN_ID)}</CS_PAY_PLAN_ID>
							<CS_SR_ID>{data($sc/DOCUMENT/POSITION/POS_SERIES)}</CS_SR_ID>
							<CS_PD_NUMBER_JOBCD_1>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_1)}</CS_PD_NUMBER_JOBCD_1>
							<CS_CLASSIFICATION_DT_1>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_1)}</CS_CLASSIFICATION_DT_1>
							<CS_GR_ID_1>{data($sc/DOCUMENT/POSITION/POS_GRADE_1)}</CS_GR_ID_1>
							<CS_PD_NUMBER_JOBCD_2>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_2)}</CS_PD_NUMBER_JOBCD_2>
							<CS_CLASSIFICATION_DT_2>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_2)}</CS_CLASSIFICATION_DT_2>
							<CS_GR_ID_2>{data($sc/DOCUMENT/POSITION/POS_GRADE_2)}</CS_GR_ID_2>
							<CS_PD_NUMBER_JOBCD_3>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_3)}</CS_PD_NUMBER_JOBCD_3>
							<CS_CLASSIFICATION_DT_3>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_3)}</CS_CLASSIFICATION_DT_3>
							<CS_GR_ID_3>{data($sc/DOCUMENT/POSITION/POS_GRADE_3)}</CS_GR_ID_3>
							<CS_PD_NUMBER_JOBCD_4>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_4)}</CS_PD_NUMBER_JOBCD_4>
							<CS_CLASSIFICATION_DT_4>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_4)}</CS_CLASSIFICATION_DT_4>
							<CS_GR_ID_4>{data($sc/DOCUMENT/POSITION/POS_GRADE_4)}</CS_GR_ID_4>
							<CS_PD_NUMBER_JOBCD_5>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_5)}</CS_PD_NUMBER_JOBCD_5>
							<CS_CLASSIFICATION_DT_5>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_5)}</CS_CLASSIFICATION_DT_5>
							<CS_GR_ID_5>{data($sc/DOCUMENT/POSITION/POS_GRADE_5)}</CS_GR_ID_5>
							<CS_PERFORMANCE_LEVEL>{data($sc/DOCUMENT/POSITION/POS_PERFORMANCE_LEVEL)}</CS_PERFORMANCE_LEVEL>
							<CS_SUPERVISORY>{data($sc/DOCUMENT/POSITION/POS_SUPERVISORY)}</CS_SUPERVISORY>
							<CS_AC_ID>{data($sc/DOCUMENT/GENERAL/SG_AC_ID)}</CS_AC_ID>
							<CS_ADMIN_CD>{data($sc/DOCUMENT/GENERAL/SG_ADMIN_CD)}</CS_ADMIN_CD>
							<SO_ID>{data($sc/DOCUMENT/GENERAL/SG_SO_ID)}</SO_ID>
							<SO_TITLE>{data($sc/DOCUMENT/GENERAL/SG_SO_TITLE)}</SO_TITLE>
							<SO_ORG>{data($sc/DOCUMENT/GENERAL/SG_SO_ORG)}</SO_ORG>
							<XO_ID>{data($sc/DOCUMENT/GENERAL/SG_XO_ID)}</XO_ID>
							<XO_TITLE>{data($sc/DOCUMENT/GENERAL/SG_XO_TITLE)}</XO_TITLE>
							<XO_ORG>{data($sc/DOCUMENT/GENERAL/SG_XO_ORG)}</XO_ORG>
							<HRL_ID>{data($sc/DOCUMENT/GENERAL/SG_HRL_ID)}</HRL_ID>
							<HRL_TITLE>{data($sc/DOCUMENT/GENERAL/SG_HRL_TITLE)}</HRL_TITLE>
							<HRL_ORG>{data($sc/DOCUMENT/GENERAL/SG_HRL_ORG)}</HRL_ORG>
							<SS_ID>{data($sc/DOCUMENT/GENERAL/SG_SS_ID)}</SS_ID>
							<CS_ID>{data($sc/DOCUMENT/GENERAL/SG_CS_ID)}</CS_ID>
							<POS_INFORMATION>
								<PD_PCA>{if (contains($molabel, "(PCA)")) then "true" else "false"}</PD_PCA>
								<PD_PDP>{if (contains($molabel, "(PDP)")) then "true" else "false"}</PD_PDP>
							</POS_INFORMATION>
						</GENERAL>
						<CLASSIFICATION_CODE>
							<CS_FIN_STMT_REQ_ID>{data($sc/DOCUMENT/POSITION/POS_CE_FINANCIAL_TYPE_ID)}</CS_FIN_STMT_REQ_ID>
							<CS_SEC_ID>{data($sc/DOCUMENT/POSITION/POS_SEC_ID)}</CS_SEC_ID>
						</CLASSIFICATION_CODE>
					</DOCUMENT>
				'
				-- WARNING: Oracle 12c causes problem ($molabel variable empty)
				-- with passing XMLTYPE variable (V_FIELD_DATA_SRC) for some reason.
				-- So, use table join and pass the XMLTYPE column (FD.FIELD_DATA), instead.
				--PASSING V_FIELD_DATA_SRC AS "sc", LUMO.TBL_LABEL AS "molabel"
				PASSING FD.FIELD_DATA AS "sc", LUMO.TBL_LABEL AS "molabel"
				RETURNING CONTENT
			) INTO V_FIELD_DATA_TRG
		FROM
			TBL_FORM_DTL FD
			, XMLTABLE('/DOCUMENT/POSITION' PASSING FD.FIELD_DATA
				COLUMNS
					POS_JOB_REQ_NUMBER     NVARCHAR2(10)  PATH 'POS_JOB_REQ_NUMBER'
					, POS_MED_OFFICERS_ID  NUMBER(20)     PATH 'POS_MED_OFFICERS_ID'
			) MO
			LEFT OUTER JOIN TBL_LOOKUP LUMO ON LUMO.TBL_ID = MO.POS_MED_OFFICERS_ID
		WHERE
			1=1
			AND FD.PROCID = V_PARENTPROCID
			AND XMLEXISTS('data($sc/DOCUMENT/POSITION)' PASSING FD.FIELD_DATA AS "sc")
		;
	--END IF;

	--DBMS_OUTPUT.PUT_LINE('    V_FIELD_DATA_TRG = ' || V_FIELD_DATA_TRG.GETCLOBVAL());
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_INIT_CLASSIFICATION -------');
	RETURN V_FIELD_DATA_TRG;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing classification initialization -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
		RETURN NULL;
END;

/






/**
 * Updates initial Classification process data.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_INIT_CLSF
(

	I_PROCID               IN  NUMBER
)
IS
	V_ID                       NUMBER(20);
	V_XMLCLOB                  CLOB;
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: SP_UPDATE_INIT_CLSF -------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID = ' || TO_CHAR(I_PROCID));

	SELECT FN_INIT_CLASSIFICATION(I_PROCID).GETCLOBVAL() INTO V_XMLCLOB FROM DUAL;
	--DBMS_OUTPUT.PUT_LINE('    V_XMLCLOB = ' || V_XMLCLOB);

	SP_UPDATE_FORM_DATA(V_ID, 'CMSCLSF'
		, V_XMLCLOB
		, 'SYSTEM'
		, I_PROCID, 0, 0
	);

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_INIT_CLSF -------------------');
END;
/









--------------------------------------------------------
--  DDL for Function FN_INIT_ELIGQUAL
--------------------------------------------------------

/**
 * Retrieves the initial form data xml for Eligiblity and Qualification process
 * from the form data xml for the associated parent Strategic Consultation
 * process instance or Classification process instance.
 *
 * @param I_PROCID - Process ID of the parent process.
 *
 * @return XMLTYPE - Form data xml as the initial Classification data.
 */
CREATE OR REPLACE FUNCTION FN_INIT_ELIGQUAL
(
	I_PROCID                    IN NUMBER
)
RETURN XMLTYPE
IS
	V_PARENTPROCID              NUMBER(10);
	V_PARENTPROCNAME            VARCHAR2(100);
	V_PARENT_STRATCON_PROCID    NUMBER(10);
	V_PARENT_CLSF_PROCID        NUMBER(10);
	V_FIELD_DATA_SRC            XMLTYPE;
	V_FIELD_DATA_TRG            XMLTYPE;
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_INIT_ELIGQUAL -------');

	-- get parent procid to pull data from
	BEGIN
		SELECT PARENTPROCID INTO V_PARENTPROCID
		FROM BIZFLOW.PROCS
		WHERE PROCID = I_PROCID;
	EXCEPTION
		WHEN OTHERS THEN
			SP_ERROR_LOG();
			V_PARENTPROCID := NULL;
	END;

	-- if no parent to inherit data from, just return
	IF V_PARENTPROCID IS NULL THEN
		RETURN NULL;
	END IF;

	-- check whether the immediate parent is STRATCON or CLSF
	BEGIN
		SELECT PD.NAME INTO V_PARENTPROCNAME
		FROM BIZFLOW.PROCDEF PD INNER JOIN BIZFLOW.PROCS P ON P.ORGPROCDEFID = PD.ORGPROCDEFID
		WHERE PD.ISFINAL = 'T' AND PD.ENVTYPE = 'O' AND P.PROCID = V_PARENTPROCID;
	EXCEPTION
		WHEN OTHERS THEN
			SP_ERROR_LOG();
			V_PARENTPROCNAME := NULL;
	END;

	-- construct initial Eligiblity and Qualification form data xml
	-- from the originating parent process instance data
	IF V_PARENTPROCNAME = 'Strategic Consultation' THEN
		-- construct ELIGQUAL xml from parent STRATCON
		SELECT
			XMLQUERY(
				'
				<DOCUMENT>
					<GENERAL>
						<ADMIN_CD>{             data($sc/DOCUMENT/GENERAL/SG_ADMIN_CD)}</ADMIN_CD>
						<RT_ID>{                data($sc/DOCUMENT/GENERAL/SG_RT_ID)}</RT_ID>
						<AT_ID>{                data($sc/DOCUMENT/GENERAL/SG_AT_ID)}</AT_ID>
						<VT_ID>{                data($sc/DOCUMENT/GENERAL/SG_VT_ID)}</VT_ID>
						<SAT_ID>{               data($sc/DOCUMENT/GENERAL/SG_SAT_ID)}</SAT_ID>
						<CT_ID>{                data($sc/DOCUMENT/GENERAL/SG_CT_ID)}</CT_ID>
						<SO_ID>{                data($sc/DOCUMENT/GENERAL/SG_SO_ID)}</SO_ID>
						<XO_ID>{                data($sc/DOCUMENT/GENERAL/SG_XO_ID)}</XO_ID>
						<HRL_ID>{               data($sc/DOCUMENT/GENERAL/SG_HRL_ID)}</HRL_ID>
						<SS_ID>{                data($sc/DOCUMENT/GENERAL/SG_SS_ID)}</SS_ID>
						<CS_ID>{                data($sc/DOCUMENT/GENERAL/SG_CS_ID)}</CS_ID>
						<SO_AGREE>{             data($sc/DOCUMENT/GENERAL/SG_SO_AGREE)}</SO_AGREE>
						<OTHER_CERT>{           data($sc/DOCUMENT/GENERAL/SG_OTHER_CERT)}</OTHER_CERT>
					</GENERAL>
					<POSITION>
						<POS_ID>{               data($sc/DOCUMENT/POSITION/POS_ID)}</POS_ID>
						<CNDT_LAST_NM>{         data($sc/DOCUMENT/POSITION/POS_CNDT_LAST_NM)}</CNDT_LAST_NM>
						<CNDT_FIRST_NM>{        data($sc/DOCUMENT/POSITION/POS_CNDT_FIRST_NM)}</CNDT_FIRST_NM>
						<CNDT_MIDDLE_NM>{       data($sc/DOCUMENT/POSITION/POS_CNDT_MIDDLE_NM)}</CNDT_MIDDLE_NM>
						<BGT_APR_OFM>{          data($sc/DOCUMENT/POSITION/POS_BGT_APR_OFM)}</BGT_APR_OFM>
						<SPNSR_ORG_NM>{         data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_NM)}</SPNSR_ORG_NM>
						<SPNSR_ORG_FUND_PC>{    data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_FUND_PC)}</SPNSR_ORG_FUND_PC>
						<JOB_REQ_NUMBER>{       data($sc/DOCUMENT/POSITION/POS_JOB_REQ_NUMBER)}</JOB_REQ_NUMBER>
						<JOB_REQ_CREATE_DT>{    data($sc/DOCUMENT/POSITION/POS_JOB_REQ_CREATE_DT)}</JOB_REQ_CREATE_DT>
						<POS_TITLE>{            data($sc/DOCUMENT/POSITION/POS_TITLE)}</POS_TITLE>
						<PAY_PLAN_ID>{          data($sc/DOCUMENT/POSITION/POS_PAY_PLAN_ID)}</PAY_PLAN_ID>
						<SERIES>{               data($sc/DOCUMENT/POSITION/POS_SERIES)}</SERIES>
						<POS_DESC_NUMBER_1>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_1)}</POS_DESC_NUMBER_1>
						<CLASSIFICATION_DT_1>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_1)}</CLASSIFICATION_DT_1>
						<GRADE_1>{              data($sc/DOCUMENT/POSITION/POS_GRADE_1)}</GRADE_1>
						<POS_DESC_NUMBER_2>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_2)}</POS_DESC_NUMBER_2>
						<CLASSIFICATION_DT_2>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_2)}</CLASSIFICATION_DT_2>
						<GRADE_2>{              data($sc/DOCUMENT/POSITION/POS_GRADE_2)}</GRADE_2>
						<POS_DESC_NUMBER_3>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_3)}</POS_DESC_NUMBER_3>
						<CLASSIFICATION_DT_3>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_3)}</CLASSIFICATION_DT_3>
						<GRADE_3>{              data($sc/DOCUMENT/POSITION/POS_GRADE_3)}</GRADE_3>
						<POS_DESC_NUMBER_4>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_4)}</POS_DESC_NUMBER_4>
						<CLASSIFICATION_DT_4>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_4)}</CLASSIFICATION_DT_4>
						<GRADE_4>{              data($sc/DOCUMENT/POSITION/POS_GRADE_4)}</GRADE_4>
						<POS_DESC_NUMBER_5>{    data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_5)}</POS_DESC_NUMBER_5>
						<CLASSIFICATION_DT_5>{  data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_5)}</CLASSIFICATION_DT_5>
						<GRADE_5>{              data($sc/DOCUMENT/POSITION/POS_GRADE_5)}</GRADE_5>
						<PERFORMANCE_LEVEL>{    data($sc/DOCUMENT/POSITION/POS_PERFORMANCE_LEVEL)}</PERFORMANCE_LEVEL>
						<SUPERVISORY>{          data($sc/DOCUMENT/POSITION/POS_SUPERVISORY)}</SUPERVISORY>
						<MED_OFFICERS_ID>{      data($sc/DOCUMENT/POSITION/POS_MED_OFFICERS_ID)}</MED_OFFICERS_ID>
						<SKILL>{                data($sc/DOCUMENT/POSITION/POS_SKILL)}</SKILL>
						<GRADES_ADVERTISED>{    data($sc/DOCUMENT/POSITION/POS_GRADES_ADVERTISED)}</GRADES_ADVERTISED>
						<LOCATION>{             data($sc/DOCUMENT/POSITION/POS_LOCATION)}</LOCATION>
						<VACANCIES>{            data($sc/DOCUMENT/POSITION/POS_VACANCIES)}</VACANCIES>
						<REPORT_SUPERVISOR>{    data($sc/DOCUMENT/POSITION/POS_REPORT_SUPERVISOR)}</REPORT_SUPERVISOR>
						<CAN>{                  data($sc/DOCUMENT/POSITION/POS_CAN)}</CAN>
						<VICE>{                 data($sc/DOCUMENT/POSITION/POS_VICE)}</VICE>
						<VICE_NAME>{            data($sc/DOCUMENT/POSITION/POS_VICE_NAME)}</VICE_NAME>
						<DAYS_ADVERTISED>{      data($sc/DOCUMENT/POSITION/POS_DAYS_ADVERTISED)}</DAYS_ADVERTISED>
						<TA_ID>{                data($sc/DOCUMENT/POSITION/POS_AT_ID)}</TA_ID>
						<NTE>{                  data($sc/DOCUMENT/POSITION/POS_NTE)}</NTE>
						<WORK_SCHED_ID>{        data($sc/DOCUMENT/POSITION/POS_WORK_SCHED_ID)}</WORK_SCHED_ID>
						<HOURS_PER_WEEK>{       data($sc/DOCUMENT/POSITION/POS_HOURS_PER_WEEK)}</HOURS_PER_WEEK>
						<DUAL_EMPLMT>{          data($sc/DOCUMENT/POSITION/POS_DUAL_EMPLMT)}</DUAL_EMPLMT>
						<SEC_ID>{               data($sc/DOCUMENT/POSITION/POS_SEC_ID)}</SEC_ID>
						<CE_FINANCIAL_DISC>{    data($sc/DOCUMENT/POSITION/POS_CE_FINANCIAL_DISC)}</CE_FINANCIAL_DISC>
						<CE_FINANCIAL_TYPE_ID>{ data($sc/DOCUMENT/POSITION/POS_CE_FINANCIAL_TYPE_ID)}</CE_FINANCIAL_TYPE_ID>
						<CE_PE_PHYSICAL>{       data($sc/DOCUMENT/POSITION/POS_CE_PE_PHYSICAL)}</CE_PE_PHYSICAL>
						<CE_DRUG_TEST>{         data($sc/DOCUMENT/POSITION/POS_CE_DRUG_TEST)}</CE_DRUG_TEST>
						<CE_IMMUN>{             data($sc/DOCUMENT/POSITION/POS_CE_IMMUN)}</CE_IMMUN>
						<CE_TRAVEL>{            data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL)}</CE_TRAVEL>
						<CE_TRAVEL_PER>{        data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL_PER)}</CE_TRAVEL_PER>
						<CE_LIC>{               data($sc/DOCUMENT/POSITION/POS_CE_LIC)}</CE_LIC>
						<CE_LIC_INFO>{          data($sc/DOCUMENT/POSITION/POS_CE_LIC_INFO)}</CE_LIC_INFO>
						<REMARKS>{              data($sc/DOCUMENT/POSITION/POS_REMARKS)}</REMARKS>
						<PROC_REQ_TYPE>{        data($sc/DOCUMENT/POSITION/POS_PROC_REQ_TYPE)}</PROC_REQ_TYPE>
						<RECRUIT_OFFICE_ID>{    data($sc/DOCUMENT/POSITION/POS_RECRUIT_OFFICE_ID)}</RECRUIT_OFFICE_ID>
						<REQ_ID>{               data($sc/DOCUMENT/POSITION/POS_REQ_ID)}</REQ_ID>
						<REQ_CREATE_NOTIFY_DT>{ data($sc/DOCUMENT/POSITION/POS_REQ_CREATE_NOTIFY_DT)}</REQ_CREATE_NOTIFY_DT>
						<ASSOC_DESCR_NUMBERS>{  data($sc/DOCUMENT/POSITION/POS_ASSOC_DESCR_NUMBERS)}</ASSOC_DESCR_NUMBERS>
						<PROMOTE_POTENTIAL>{    data($sc/DOCUMENT/POSITION/POS_PROMOTE_POTENTIAL)}</PROMOTE_POTENTIAL>
						<VICE_EMPL_ID>{         data($sc/DOCUMENT/POSITION/POS_VICE_EMPL_ID)}</VICE_EMPL_ID>
						<SR_ID>{                data($sc/DOCUMENT/POSITION/POS_SR_ID)}</SR_ID>
						<GR_ID>{                data($sc/DOCUMENT/POSITION/POS_GR_ID)}</GR_ID>
						<STATUS_ID>{            data($sc/DOCUMENT/POSITION/POS_STATUS_ID)}</STATUS_ID>
						<SC_REQUESTED>{         data($sc/DOCUMENT/POSITION/POS_SC_REQUESTED)}</SC_REQUESTED>
						<SG_ID>{                data($sc/DOCUMENT/POSITION/POS_SG_ID)}</SG_ID>
						<PD_ID>{                data($sc/DOCUMENT/POSITION/POS_PD_ID)}</PD_ID>
						<GRADE_ADVERTISED>
							<GA_1>{ data($sc/DOCUMENT/POSITION/POS_GA_1)}</GA_1>
							<GA_2>{ data($sc/DOCUMENT/POSITION/POS_GA_2)}</GA_2>
							<GA_3>{ data($sc/DOCUMENT/POSITION/POS_GA_3)}</GA_3>
							<GA_4>{ data($sc/DOCUMENT/POSITION/POS_GA_4)}</GA_4>
							<GA_5>{ data($sc/DOCUMENT/POSITION/POS_GA_5)}</GA_5>
							<GA_6>{ data($sc/DOCUMENT/POSITION/POS_GA_6)}</GA_6>
							<GA_7>{ data($sc/DOCUMENT/POSITION/POS_GA_7)}</GA_7>
							<GA_8>{ data($sc/DOCUMENT/POSITION/POS_GA_8)}</GA_8>
							<GA_9>{ data($sc/DOCUMENT/POSITION/POS_GA_9)}</GA_9>
							<GA_10>{data($sc/DOCUMENT/POSITION/POS_GA_10)}</GA_10>
							<GA_11>{data($sc/DOCUMENT/POSITION/POS_GA_11)}</GA_11>
							<GA_12>{data($sc/DOCUMENT/POSITION/POS_GA_12)}</GA_12>
							<GA_13>{data($sc/DOCUMENT/POSITION/POS_GA_13)}</GA_13>
							<GA_14>{data($sc/DOCUMENT/POSITION/POS_GA_14)}</GA_14>
							<GA_15>{data($sc/DOCUMENT/POSITION/POS_GA_15)}</GA_15>
						</GRADE_ADVERTISED>
					</POSITION>
				</DOCUMENT>
				'
				PASSING FD.FIELD_DATA AS "sc"
				RETURNING CONTENT
			) INTO V_FIELD_DATA_TRG
		FROM
			TBL_FORM_DTL FD
		WHERE
			1=1
			AND FD.PROCID = V_PARENTPROCID
			AND XMLEXISTS('data($sc/DOCUMENT/POSITION)' PASSING FD.FIELD_DATA AS "sc")
		;
	ELSIF V_PARENTPROCNAME = 'Classification' THEN
		V_PARENT_CLSF_PROCID := V_PARENTPROCID;
		-- get procid for Strategic Consultation process which is parent of
		-- Classification process to pull data from
		BEGIN
			SELECT PARENTPROCID INTO V_PARENT_STRATCON_PROCID
			FROM BIZFLOW.PROCS
			WHERE PROCID = V_PARENT_CLSF_PROCID;
		EXCEPTION
			WHEN OTHERS THEN
				SP_ERROR_LOG();
				V_PARENT_STRATCON_PROCID := NULL;
		END;

		-- construct ELIGQUAL xml from grandparent STRATCON and parent CLSF
		SELECT
			XMLQUERY(
				'
					<DOCUMENT>
						<GENERAL>
							<ADMIN_CD>{             data($cl/DOCUMENT/GENERAL/CS_ADMIN_CD)}</ADMIN_CD>
							<RT_ID>{                data($sc/DOCUMENT/GENERAL/SG_RT_ID)}</RT_ID>
							<AT_ID>{                data($sc/DOCUMENT/GENERAL/SG_AT_ID)}</AT_ID>
							<VT_ID>{                data($sc/DOCUMENT/GENERAL/SG_VT_ID)}</VT_ID>
							<SAT_ID>{               data($sc/DOCUMENT/GENERAL/SG_SAT_ID)}</SAT_ID>
							<CT_ID>{                data($sc/DOCUMENT/GENERAL/SG_CT_ID)}</CT_ID>
							<SO_ID>{                data($sc/DOCUMENT/GENERAL/SG_SO_ID)}</SO_ID>
							<XO_ID>{                data($sc/DOCUMENT/GENERAL/SG_XO_ID)}</XO_ID>
							<HRL_ID>{               data($sc/DOCUMENT/GENERAL/SG_HRL_ID)}</HRL_ID>
							<SS_ID>{                data($sc/DOCUMENT/GENERAL/SG_SS_ID)}</SS_ID>
							<CS_ID>{                data($sc/DOCUMENT/GENERAL/SG_CS_ID)}</CS_ID>
							<SO_AGREE>{             data($sc/DOCUMENT/GENERAL/SG_SO_AGREE)}</SO_AGREE>
							<OTHER_CERT>{           data($sc/DOCUMENT/GENERAL/SG_OTHER_CERT)}</OTHER_CERT>
						</GENERAL>
						<POSITION>
							<POS_ID>{               data($sc/DOCUMENT/POSITION/POS_ID)}</POS_ID>
							<CNDT_LAST_NM>{         data($sc/DOCUMENT/POSITION/POS_CNDT_LAST_NM)}</CNDT_LAST_NM>
							<CNDT_FIRST_NM>{        data($sc/DOCUMENT/POSITION/POS_CNDT_FIRST_NM)}</CNDT_FIRST_NM>
							<CNDT_MIDDLE_NM>{       data($sc/DOCUMENT/POSITION/POS_CNDT_MIDDLE_NM)}</CNDT_MIDDLE_NM>
							<BGT_APR_OFM>{          data($sc/DOCUMENT/POSITION/POS_BGT_APR_OFM)}</BGT_APR_OFM>
							<SPNSR_ORG_NM>{         data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_NM)}</SPNSR_ORG_NM>
							<SPNSR_ORG_FUND_PC>{    data($sc/DOCUMENT/POSITION/POS_SPNSR_ORG_FUND_PC)}</SPNSR_ORG_FUND_PC>
							<JOB_REQ_NUMBER>{       data($sc/DOCUMENT/POSITION/POS_JOB_REQ_NUMBER)}</JOB_REQ_NUMBER>
							<JOB_REQ_CREATE_DT>{    data($sc/DOCUMENT/POSITION/POS_JOB_REQ_CREATE_DT)}</JOB_REQ_CREATE_DT>

							<POS_TITLE>{            data($cl/DOCUMENT/GENERAL/CS_TITLE)}</POS_TITLE>
							<PAY_PLAN_ID>{          data($cl/DOCUMENT/GENERAL/CS_PAY_PLAN_ID)}</PAY_PLAN_ID>
							<SERIES>{               data($cl/DOCUMENT/GENERAL/CS_SR_ID)}</SERIES>
							<POS_DESC_NUMBER_1>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_1)}</POS_DESC_NUMBER_1>
							<CLASSIFICATION_DT_1>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_1)}</CLASSIFICATION_DT_1>
							<GRADE_1>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_1)}</GRADE_1>
							<POS_DESC_NUMBER_2>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_2)}</POS_DESC_NUMBER_2>
							<CLASSIFICATION_DT_2>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_2)}</CLASSIFICATION_DT_2>
							<GRADE_2>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_2)}</GRADE_2>
							<POS_DESC_NUMBER_3>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_3)}</POS_DESC_NUMBER_3>
							<CLASSIFICATION_DT_3>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_3)}</CLASSIFICATION_DT_3>
							<GRADE_3>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_3)}</GRADE_3>
							<POS_DESC_NUMBER_4>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_4)}</POS_DESC_NUMBER_4>
							<CLASSIFICATION_DT_4>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_4)}</CLASSIFICATION_DT_4>
							<GRADE_4>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_4)}</GRADE_4>
							<POS_DESC_NUMBER_5>{    data($cl/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_5)}</POS_DESC_NUMBER_5>
							<CLASSIFICATION_DT_5>{  data($cl/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_5)}</CLASSIFICATION_DT_5>
							<GRADE_5>{              data($cl/DOCUMENT/GENERAL/CS_GR_ID_5)}</GRADE_5>
							<PERFORMANCE_LEVEL>{    data($cl/DOCUMENT/GENERAL/CS_PERFORMANCE_LEVEL)}</PERFORMANCE_LEVEL>
							<SUPERVISORY>{          data($cl/DOCUMENT/GENERAL/CS_SUPERVISORY)}</SUPERVISORY>

							<MED_OFFICERS_ID>{      $moid }</MED_OFFICERS_ID>

							<SKILL>{                data($sc/DOCUMENT/POSITION/POS_SKILL)}</SKILL>
							<GRADES_ADVERTISED>{    data($sc/DOCUMENT/POSITION/POS_GRADES_ADVERTISED)}</GRADES_ADVERTISED>
							<LOCATION>{             data($sc/DOCUMENT/POSITION/POS_LOCATION)}</LOCATION>
							<VACANCIES>{            data($sc/DOCUMENT/POSITION/POS_VACANCIES)}</VACANCIES>
							<REPORT_SUPERVISOR>{    data($sc/DOCUMENT/POSITION/POS_REPORT_SUPERVISOR)}</REPORT_SUPERVISOR>
							<CAN>{                  data($sc/DOCUMENT/POSITION/POS_CAN)}</CAN>
							<VICE>{                 data($sc/DOCUMENT/POSITION/POS_VICE)}</VICE>
							<VICE_NAME>{            data($sc/DOCUMENT/POSITION/POS_VICE_NAME)}</VICE_NAME>
							<DAYS_ADVERTISED>{      data($sc/DOCUMENT/POSITION/POS_DAYS_ADVERTISED)}</DAYS_ADVERTISED>
							<TA_ID>{                data($sc/DOCUMENT/POSITION/POS_AT_ID)}</TA_ID>
							<NTE>{                  data($sc/DOCUMENT/POSITION/POS_NTE)}</NTE>
							<WORK_SCHED_ID>{        data($sc/DOCUMENT/POSITION/POS_WORK_SCHED_ID)}</WORK_SCHED_ID>
							<HOURS_PER_WEEK>{       data($sc/DOCUMENT/POSITION/POS_HOURS_PER_WEEK)}</HOURS_PER_WEEK>
							<DUAL_EMPLMT>{          data($sc/DOCUMENT/POSITION/POS_DUAL_EMPLMT)}</DUAL_EMPLMT>

							<SEC_ID>{               data($cl/DOCUMENT/CLASSIFICATION_CODE/CS_SEC_ID)}</SEC_ID>
							<CE_FINANCIAL_DISC>{    if (not(data($cl/DOCUMENT/CLASSIFICATION_CODE/CS_FIN_STMT_REQ_ID) = "")) then "true" else "false" }</CE_FINANCIAL_DISC>
							<CE_FINANCIAL_TYPE_ID>{ data($cl/DOCUMENT/CLASSIFICATION_CODE/CS_FIN_STMT_REQ_ID)}</CE_FINANCIAL_TYPE_ID>

							<CE_PE_PHYSICAL>{       data($sc/DOCUMENT/POSITION/POS_CE_PE_PHYSICAL)}</CE_PE_PHYSICAL>
							<CE_DRUG_TEST>{         data($sc/DOCUMENT/POSITION/POS_CE_DRUG_TEST)}</CE_DRUG_TEST>
							<CE_IMMUN>{             data($sc/DOCUMENT/POSITION/POS_CE_IMMUN)}</CE_IMMUN>
							<CE_TRAVEL>{            data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL)}</CE_TRAVEL>
							<CE_TRAVEL_PER>{        data($sc/DOCUMENT/POSITION/POS_CE_TRAVEL_PER)}</CE_TRAVEL_PER>
							<CE_LIC>{               data($sc/DOCUMENT/POSITION/POS_CE_LIC)}</CE_LIC>
							<CE_LIC_INFO>{          data($sc/DOCUMENT/POSITION/POS_CE_LIC_INFO)}</CE_LIC_INFO>
							<REMARKS>{              data($sc/DOCUMENT/POSITION/POS_REMARKS)}</REMARKS>
							<PROC_REQ_TYPE>{        data($sc/DOCUMENT/POSITION/POS_PROC_REQ_TYPE)}</PROC_REQ_TYPE>
							<RECRUIT_OFFICE_ID>{    data($sc/DOCUMENT/POSITION/POS_RECRUIT_OFFICE_ID)}</RECRUIT_OFFICE_ID>
							<REQ_ID>{               data($sc/DOCUMENT/POSITION/POS_REQ_ID)}</REQ_ID>
							<REQ_CREATE_NOTIFY_DT>{ data($sc/DOCUMENT/POSITION/POS_REQ_CREATE_NOTIFY_DT)}</REQ_CREATE_NOTIFY_DT>
							<ASSOC_DESCR_NUMBERS>{  data($sc/DOCUMENT/POSITION/POS_ASSOC_DESCR_NUMBERS)}</ASSOC_DESCR_NUMBERS>
							<PROMOTE_POTENTIAL>{    data($sc/DOCUMENT/POSITION/POS_PROMOTE_POTENTIAL)}</PROMOTE_POTENTIAL>
							<VICE_EMPL_ID>{         data($sc/DOCUMENT/POSITION/POS_VICE_EMPL_ID)}</VICE_EMPL_ID>
							<SR_ID>{                data($sc/DOCUMENT/POSITION/POS_SR_ID)}</SR_ID>
							<GR_ID>{                data($sc/DOCUMENT/POSITION/POS_GR_ID)}</GR_ID>
							<STATUS_ID>{            data($sc/DOCUMENT/POSITION/POS_STATUS_ID)}</STATUS_ID>
							<SC_REQUESTED>{         data($sc/DOCUMENT/POSITION/POS_SC_REQUESTED)}</SC_REQUESTED>
							<SG_ID>{                data($sc/DOCUMENT/POSITION/POS_SG_ID)}</SG_ID>
							<PD_ID>{                data($sc/DOCUMENT/POSITION/POS_PD_ID)}</PD_ID>
							<GRADE_ADVERTISED>
								<GA_1>{ data($sc/DOCUMENT/POSITION/POS_GA_1)}</GA_1>
								<GA_2>{ data($sc/DOCUMENT/POSITION/POS_GA_2)}</GA_2>
								<GA_3>{ data($sc/DOCUMENT/POSITION/POS_GA_3)}</GA_3>
								<GA_4>{ data($sc/DOCUMENT/POSITION/POS_GA_4)}</GA_4>
								<GA_5>{ data($sc/DOCUMENT/POSITION/POS_GA_5)}</GA_5>
								<GA_6>{ data($sc/DOCUMENT/POSITION/POS_GA_6)}</GA_6>
								<GA_7>{ data($sc/DOCUMENT/POSITION/POS_GA_7)}</GA_7>
								<GA_8>{ data($sc/DOCUMENT/POSITION/POS_GA_8)}</GA_8>
								<GA_9>{ data($sc/DOCUMENT/POSITION/POS_GA_9)}</GA_9>
								<GA_10>{data($sc/DOCUMENT/POSITION/POS_GA_10)}</GA_10>
								<GA_11>{data($sc/DOCUMENT/POSITION/POS_GA_11)}</GA_11>
								<GA_12>{data($sc/DOCUMENT/POSITION/POS_GA_12)}</GA_12>
								<GA_13>{data($sc/DOCUMENT/POSITION/POS_GA_13)}</GA_13>
								<GA_14>{data($sc/DOCUMENT/POSITION/POS_GA_14)}</GA_14>
								<GA_15>{data($sc/DOCUMENT/POSITION/POS_GA_15)}</GA_15>
							</GRADE_ADVERTISED>
						</POSITION>
					</DOCUMENT>
				'
				PASSING FDSC.FIELD_DATA AS "sc", FDCL.FIELD_DATA AS "cl", LUMO.MED_OFFICERS_ID AS "moid"
				RETURNING CONTENT
			) INTO V_FIELD_DATA_TRG
		FROM
			TBL_FORM_DTL FDSC
			, TBL_FORM_DTL FDCL
			, XMLTABLE('/DOCUMENT/GENERAL/POS_INFORMATION' PASSING FDCL.FIELD_DATA
				COLUMNS
					PD_PCA                 VARCHAR2(10)   PATH 'PD_PCA'
					, PD_PDP               VARCHAR2(10)   PATH 'PD_PDP'
			) MO
			LEFT OUTER JOIN (
				SELECT
					TBL_ID AS MED_OFFICERS_ID
					, TBL_LABEL AS MED_OFFICERS_DSCR
					, CASE WHEN TBL_LABEL LIKE '%(PCA)%' THEN 'true' ELSE 'false' END AS PD_PCA
					, CASE WHEN TBL_LABEL LIKE '%(PDP)%' THEN 'true' ELSE 'false' END AS PD_PDP
				FROM TBL_LOOKUP
				WHERE TBL_LTYPE = 'MedicalOfficer'
			) LUMO ON LUMO.PD_PCA = MO.PD_PCA AND LUMO.PD_PDP = MO.PD_PDP
		WHERE
			1=1
			AND FDSC.FORM_TYPE = 'CMSSTRATCON'
			AND FDSC.PROCID = V_PARENT_STRATCON_PROCID
			AND FDCL.FORM_TYPE = 'CMSCLSF'
			AND FDCL.PROCID = V_PARENT_CLSF_PROCID
		;
	ELSE
		RETURN NULL;  -- no parent name --> something went wrong
	END IF;


	--DBMS_OUTPUT.PUT_LINE('    V_FIELD_DATA_TRG = ' || V_FIELD_DATA_TRG.GETCLOBVAL());
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_INIT_ELIGQUAL -------');
	RETURN V_FIELD_DATA_TRG;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing Eligiblity and Qualification initialization -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
		RETURN NULL;
END;

/




/**
 * Updates initial Eligiblity and Qualification process data.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_INIT_ELIGQUAL
(
	I_PROCID               IN  NUMBER
)
IS
	V_ID                       NUMBER(20);
	V_XMLCLOB                  CLOB;
	V_RLVNTDATANAME            VARCHAR2(100);
	V_VALUE                    NVARCHAR2(2000);
	V_VALUE_LOOKUP             NVARCHAR2(2000);
	V_XMLDOC                   XMLTYPE;
	V_XMLVALUE                 XMLTYPE;
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: SP_UPDATE_INIT_ELIGQUAL -------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID = ' || TO_CHAR(I_PROCID));

	SELECT FN_INIT_ELIGQUAL(I_PROCID) INTO V_XMLDOC FROM DUAL;
	--SELECT V_XMLDOC.GETCLOBVAL() INTO V_XMLCLOB FROM DUAL;
	--DBMS_OUTPUT.PUT_LINE('    V_XMLCLOB = ' || V_XMLCLOB);

	-- set PV that should be initialized and stays the same until proc completion
	V_XMLVALUE := V_XMLDOC.EXTRACT('/DOCUMENT/GENERAL/AT_ID/text()');
	IF V_XMLVALUE IS NOT NULL THEN
		V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE(AT_ID) = ' || V_VALUE);

		---------------------------------
		-- replace with lookup value
		---------------------------------
		BEGIN
			SELECT TBL_LABEL INTO V_VALUE_LOOKUP
			FROM TBL_LOOKUP
			WHERE TBL_ID = TO_NUMBER(V_VALUE);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_VALUE_LOOKUP := NULL;
			WHEN OTHERS THEN
				V_VALUE_LOOKUP := NULL;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE_LOOKUP(AT_ID) = ' || V_VALUE_LOOKUP);

		IF V_VALUE_LOOKUP IN ('Expert/Consultant', '30% or more disabled veterans', 'Veteran Recruitment Appointment (VRA)') THEN
			V_VALUE := 'Yes';  -- set final PV value
		ELSIF V_VALUE_LOOKUP = 'Schedule A' THEN
			V_XMLVALUE := V_XMLDOC.EXTRACT('/DOCUMENT/GENERAL/SAT_ID/text()');
			IF V_XMLVALUE IS NOT NULL THEN
				V_VALUE := V_XMLVALUE.GETSTRINGVAL();
				--DBMS_OUTPUT.PUT_LINE('    V_VALUE(SAT_ID) = ' || V_VALUE);

				---------------------------------
				-- replace with lookup value
				---------------------------------
				BEGIN
					SELECT TBL_LABEL INTO V_VALUE_LOOKUP
					FROM TBL_LOOKUP
					WHERE TBL_ID = TO_NUMBER(V_VALUE);
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						V_VALUE_LOOKUP := NULL;
					WHEN OTHERS THEN
						V_VALUE_LOOKUP := NULL;
				END;
				--DBMS_OUTPUT.PUT_LINE('    V_VALUE_LOOKUP(SAT_ID) = ' || V_VALUE_LOOKUP);

				IF V_VALUE_LOOKUP = 'Disability (U)' THEN
					V_VALUE := 'Yes';  -- set final PV value
				END IF;
			END IF;
		END IF;

		IF V_VALUE IS NULL OR V_VALUE <> 'Yes' THEN
			V_VALUE := 'No';  -- set final PV value
		END IF;
		V_RLVNTDATANAME := 'selectionRequired';
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
	END IF;


	SP_UPDATE_FORM_DATA(V_ID, 'CMSELIGQUAL'
		, V_XMLDOC.GETCLOBVAL()
		, 'SYSTEM'
		, I_PROCID, 0, 0
	);

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_INIT_ELIGQUAL -------------------');
END;
/

/**
 * Gets current user group name
 *
 * @param I_KEY - a user's group key name
 *
 * @return a user group name
 */
CREATE OR REPLACE FUNCTION FN_GET_USER_GROUP_NAME
	(
		I_KEY IN VARCHAR2
	)
	RETURN VARCHAR2
IS
	L_NAME VARCHAR2(100);

	BEGIN

		SELECT NAME INTO L_NAME FROM UG_MAPPING WHERE KEY = I_KEY;

		RETURN L_NAME;
	END;
/

/**
 * Gets current user group key
 *
 * @param I_NAME - a user's group name
 *
 * @return the key of a users group
 */
CREATE OR REPLACE FUNCTION FN_GET_USER_GROUP_KEY
	(
		I_NAME IN VARCHAR2
	)
	RETURN VARCHAR2
IS
	L_KEY VARCHAR2(100);

	BEGIN

		SELECT KEY INTO L_KEY FROM UG_MAPPING WHERE NAME = I_NAME;

		RETURN L_KEY;
	END;
/

