
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
--  DDL for Function FN_GET_LOOKUP_DSCR
--------------------------------------------------------

/**
 * Gets LOOKUP descriptions.
 *
 * @param I_LOOKUP_IDS - Selected item IDs, comma separated.
 *
 * @return NVARCHAR2 - Description of the selected items, comma separated.
 */
CREATE OR REPLACE FUNCTION FN_GET_LOOKUP_DSCR
(
	I_LOOKUP_IDS                IN  VARCHAR2
)
RETURN NVARCHAR2
IS
	V_RETURN_VAL                NVARCHAR2(4000);
	V_SQL                       VARCHAR2(4000);

	V_IDX                       NUMBER(10);
	V_LOOP_CNT                  NUMBER(10);
	TYPE LOOKUP_TYPE IS REF CURSOR;
	CUR_LOOKUP                  LOOKUP_TYPE;
	REC_LOOKUP                  TBL_LOOKUP%ROWTYPE;
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_LOOKUP_DSCR -------');
	--DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
	--DBMS_OUTPUT.PUT_LINE('    I_LOOKUP_IDS = ' || I_LOOKUP_IDS );

	-- input validation
	IF I_LOOKUP_IDS IS NULL OR LENGTH(TRIM(I_LOOKUP_IDS)) <= 0
	THEN
		RETURN NULL;
	END IF;

	V_RETURN_VAL := '';

	V_SQL := 'SELECT * FROM TBL_LOOKUP WHERE TBL_ID IN (' || I_LOOKUP_IDS || ') ';
	--DBMS_OUTPUT.PUT_LINE('    V_SQL = ' || V_SQL );

	-- Loop through to look up description of each
	-- and concatenate descriptions delimitted by comma.
	--DBMS_OUTPUT.PUT_LINE('Before open cursor for TBL_LOOKUP');
	OPEN CUR_LOOKUP FOR V_SQL;
	--DBMS_OUTPUT.PUT_LINE('After open cursor for TBL_LOOKUP');

	V_LOOP_CNT := 0;
	LOOP
		FETCH CUR_LOOKUP INTO REC_LOOKUP;
		EXIT WHEN CUR_LOOKUP%NOTFOUND;
		V_LOOP_CNT := V_LOOP_CNT + 1;
		V_RETURN_VAL := V_RETURN_VAL || REC_LOOKUP.TBL_LABEL || ', ';
		--DBMS_OUTPUT.PUT_LINE('Fetched record, loop count = ' || TO_CHAR(V_LOOP_CNT) || ' V_RETURN_VAL = ' || V_RETURN_VAL);
	END LOOP;
	CLOSE CUR_LOOKUP;

	-- clear trailing comma if exists
	IF V_RETURN_VAL IS NOT NULL AND LENGTH(V_RETURN_VAL) > 0
	THEN
		V_IDX := INSTR(V_RETURN_VAL, ', ', -1);
		IF V_IDX > 0 AND V_IDX = (LENGTH(V_RETURN_VAL) - 1)
		THEN
			V_RETURN_VAL := SUBSTR(V_RETURN_VAL, 0, (LENGTH(V_RETURN_VAL) - 2));
		END IF;
	END IF;

	--DBMS_OUTPUT.PUT_LINE('    V_RETURN_VAL = ' || V_RETURN_VAL);
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_GET_LOOKUP_DSCR -------');
	RETURN V_RETURN_VAL;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_LOOKUP_DSCR -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
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
				V_VALUE := UTL_I18N.UNESCAPE_REFERENCE(V_XMLVALUE.GETSTRINGVAL());
			ELSE
				V_VALUE := NULL;
			END IF;

			IF I_DISPXPATH IS NOT NULL THEN
				V_XMLVALUE := I_FIELD_DATA.EXTRACT(I_DISPXPATH);
				IF V_XMLVALUE IS NOT NULL THEN
					V_DISPVALUE := UTL_I18N.UNESCAPE_REFERENCE(V_XMLVALUE.GETSTRINGVAL());
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
create or replace PROCEDURE SP_UPDATE_PV_ERLR
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
  V_REQUEST_NUMBER       VARCHAR2(20);
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
          -- Case Category is multi-select value, thus multi-value concatenation required
          --SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          --FROM TBL_LOOKUP
          --WHERE TBL_ID = TO_NUMBER(V_VALUE);
          SELECT FN_GET_LOOKUP_DSCR(V_VALUE) INTO V_VALUE_LOOKUP
          FROM DUAL;
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

      --SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseStatus', '/formData/items/item[id=''CASE_STATUS'']/value/text()');
      V_RLVNTDATANAME := 'caseStatus';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_STATUS'']/value/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
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
        
        --- set requestNum ------
        SELECT VALUE INTO V_REQUEST_NUMBER 
          FROM BIZFLOW.RLVNTDATA 
         WHERE RLVNTDATANAME = 'requestNum' 
           AND PROCID = I_PROCID;
        IF V_REQUEST_NUMBER IS NULL THEN
            GET_REQUEST_NUM (V_REQUEST_NUMBER);
            UPDATE BIZFLOW.RLVNTDATA 
               SET VALUE = V_REQUEST_NUMBER
             WHERE RLVNTDATANAME = 'requestNum' 
               AND PROCID = I_PROCID;
        END IF;        
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'contactName', '/formData/items/item[id=''GEN_CUSTOMER_NAME'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'employeeName', '/formData/items/item[id=''GEN_EMPLOYEE_NAME'']/value/text()');


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

      UPDATE BIZFLOW.RLVNTDATA SET VALUE = TO_CHAR((sys_extract_utc(systimestamp)), 'YYYY/MM/DD HH24:MI:SS') WHERE RLVNTDATANAME = 'lastModifiedDate' AND PROCID = I_PROCID;


      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'organization',           '/formData/items/item[id=''GEN_EMPLOYEE_ADMIN_CD'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'primaryDWCSpecialist',   '/formData/items/item[id=''GEN_PRIMARY_SPECIALIST'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'reassign',               '/formData/items/item[id=''reassign'']/value/text()');      
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
-- CMS_HR_DB_UPD_17_UPDATE_PV_STRATCON.sql 
-- CMS_HR_DB_UPD_64_SP_UPDATE_STRATCON.sql

CREATE OR REPLACE PROCEDURE SP_UPDATE_PV_STRATCON
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

      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'adminCode', '/DOCUMENT/GENERAL/SG_ADMIN_CD/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cancelReason', '/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrLiaison', '/DOCUMENT/GENERAL/SG_HRL_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingAckResponse', '/DOCUMENT/PROCESS_VARIABLE/meetingAckResponse/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingApvResponse', '/DOCUMENT/PROCESS_VARIABLE/meetingApvResponse/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingEmailRecipients', '/DOCUMENT/PROCESS_VARIABLE/meetingEmailRecipients/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingRequired', '/DOCUMENT/PROCESS_VARIABLE/meetingRequired/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingResched',  '/DOCUMENT/PROCESS_VARIABLE/meetingResched/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdClassSpec', '/DOCUMENT/GENERAL/SG_CS_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdHrLiaison', '/DOCUMENT/GENERAL/SG_HRL_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdSelectOff', '/DOCUMENT/GENERAL/SG_SO_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdStaffSpec', '/DOCUMENT/GENERAL/SG_SS_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'posLocation', '/DOCUMENT/POSITION/POS_LOCATION/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'posTitle', '/DOCUMENT/POSITION/POS_TITLE/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestNum', '/DOCUMENT/PROCESS_VARIABLE/requestNum/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'selectOfficialReviewReq', '/DOCUMENT/PROCESS_VARIABLE/selectOfficialReviewReq/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'specialProgram', '/DOCUMENT/PROCESS_VARIABLE/specialProgram/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'alertMessage', '/DOCUMENT/PROCESS_VARIABLE/alertMessage/text()', null);

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'execOfficer';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_XO_ID/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'lastActivityCompDate';
      BEGIN
        SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
        EXCEPTION
        WHEN OTHERS THEN V_VALUE := NULL;
      END;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      --V_RLVNTDATANAME := 'memIdExecOff';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_XO_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdExecOff';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'execOfficer';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;
        V_RLVNTDATANAME := 'execOfficer2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;
        V_RLVNTDATANAME := 'execOfficer3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL 
         WHERE RLVNTDATANAME IN ('memIdExecOff', 'memIdExecOff2', 'memIdExecOff3', 'execOfficer', 'execOfficer2', 'execOfficer3') AND PROCID = I_PROCID;

      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      --DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_STRATCON -------------------');
  END;

/









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
CREATE OR REPLACE PROCEDURE SP_UPDATE_PV_CLSF
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

      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'adminCode', '/DOCUMENT/GENERAL/CS_ADMIN_CD/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'adminCode', '/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'coversheetApprovedBySO', '/DOCUMENT/PROCESS_VARIABLE/coversheetApprovedBySO/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'finalPackageApprovedSO', '/DOCUMENT/PROCESS_VARIABLE/finalPackageApprovedSO/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'modifyCoversheetFeedback', '/DOCUMENT/PROCESS_VARIABLE/modifyCoversheetFeedback/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'modifyFinalPackageFeedback', '/DOCUMENT/PROCESS_VARIABLE/modifyFinalPackageFeedback/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'returnToSO', '/DOCUMENT/PROCESS_VARIABLE/returnToSO/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'posLocation', '/DOCUMENT/GENERAL/PD_EMPLOYING_OFFICE/text()', null);

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      --V_RLVNTDATANAME := 'execOfficer';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdExecOff';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'execOfficer';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;

        V_RLVNTDATANAME := 'execOfficer2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;

        V_RLVNTDATANAME := 'execOfficer3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL 
         WHERE RLVNTDATANAME in ('memIdExecOff', 'memIdExecOff2', 'memIdExecOff3', 'execOfficer', 'execOfficer2', 'execOfficer3') 
           AND PROCID = I_PROCID;

      END IF;

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'lastActivityCompDate';
      BEGIN
        SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
        EXCEPTION
        WHEN OTHERS THEN V_VALUE := NULL;
      END;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posTitle';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_TITLE/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := REPLACE(V_XMLVALUE.GETSTRINGVAL(), '&amp;', '&');
        V_VALUE := REPLACE(V_VALUE, '&lt;', '<');
        V_VALUE := REPLACE(V_VALUE, '&gt;', '>');
        V_VALUE := REPLACE(V_VALUE, '&quot;', '"');
      ELSE
        V_VALUE := NULL;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      --DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

      COMMIT;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_CLSF -------------------');
  END;
/


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
CREATE OR REPLACE PROCEDURE SP_UPDATE_PV_ELIGQUAL
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

      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'adminCode', '/DOCUMENT/GENERAL/ADMIN_CD/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cancelReason', '/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'feedbackDCO', '/DOCUMENT/PROCESS_VARIABLE/feedbackDCO/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'feedbackStaffSpec', '/DOCUMENT/PROCESS_VARIABLE/feedbackStaffSpec/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdClassSpec', '/DOCUMENT/GENERAL/CS_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdHrLiaison', '/DOCUMENT/GENERAL/HRL_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdSelectOff', '/DOCUMENT/GENERAL/SO_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdStaffSpec', '/DOCUMENT/GENERAL/SS_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'posLocation', '/DOCUMENT/POSITION/LOCATION/text()', null);

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'lastActivityCompDate';
      BEGIN
        SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
        EXCEPTION
        WHEN OTHERS THEN V_VALUE := NULL;
      END;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      --V_RLVNTDATANAME := 'memIdExecOff';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdExecOff';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'execOfficer';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;
        V_RLVNTDATANAME := 'execOfficer2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;
        V_RLVNTDATANAME := 'execOfficer3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL 
         WHERE RLVNTDATANAME in ('memIdExecOff','memIdExecOff2','memIdExecOff3', 'execOfficer','execOfficer2','execOfficer3')
           AND PROCID = I_PROCID;
      
      END IF;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posTitle';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_TITLE/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := REPLACE(V_XMLVALUE.GETSTRINGVAL(), '&amp;', '&');
        V_VALUE := REPLACE(V_VALUE, '&lt;', '<');
        V_VALUE := REPLACE(V_VALUE, '&gt;', '>');
        V_VALUE := REPLACE(V_VALUE, '&quot;', '"');
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      --DBMS_OUTPUT.PUT_LINE('End PV update SP_UPDATE_PV_ELIGQUAL -------------------');

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_ELIGQUAL -------------------');
  END;
/



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
		SP_UPDATE_INCENTIVES_TABLE(V_PROCID, V_XMLDOC);
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
						<APPROVAL></APPROVAL>
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
						<POS_LOCATION_DSCR>{    data($sc/DOCUMENT/POSITION/POS_LOCATION_DSCR)}</POS_LOCATION_DSCR>
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
							<POS_LOCATION_DSCR>{    data($sc/DOCUMENT/POSITION/POS_LOCATION_DSCR)}</POS_LOCATION_DSCR>
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

create or replace PROCEDURE SP_INIT_ERLR
(
	I_PROCID               IN  NUMBER
)
IS
    V_CNT                   INT;    
    V_FROM_PROCID           NUMBER(10);
    V_XMLDOC                XMLTYPE;    
    V_ORG_CASE_NUMBER       NUMBER(10);
    V_CASE_NUMBER           NUMBER(10);    
    V_GEN_EMP_HHSID         VARCHAR2(64);
    V_NEW_CASE_TYPE_ID	    NUMBER(38);
    V_NEW_CASE_TYPE_NAME    VARCHAR2(100);
BEGIN
    SELECT COUNT(1) INTO V_CNT
      FROM TBL_FORM_DTL
     WHERE PROCID = I_PROCID;

    IF V_CNT = 0 THEN
        V_CASE_NUMBER :=  ERLR_CASE_NUMBER_SEQ.NEXTVAL;
        UPDATE BIZFLOW.RLVNTDATA 
           SET VALUE = V_CASE_NUMBER
         WHERE RLVNTDATANAME = 'caseNumber' 
           AND PROCID = I_PROCID;
        
        -- CHECK: TRIGGERED FROM OTHER CASE
        BEGIN
            SELECT TO_NUMBER(VALUE)
              INTO V_FROM_PROCID
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'fromProcID' 
               AND PROCID = I_PROCID;
        EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            V_FROM_PROCID := NULL;
        END;
        
        IF V_FROM_PROCID IS NOT NULL THEN
            SELECT FIELD_DATA
              INTO V_XMLDOC
              FROM TBL_FORM_DTL
             WHERE PROCID = V_FROM_PROCID;

            SELECT TO_NUMBER(VALUE)
              INTO V_NEW_CASE_TYPE_ID
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'caseTypeID' 
               AND PROCID = I_PROCID;

            SELECT TO_NUMBER(VALUE)
              INTO V_ORG_CASE_NUMBER
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'caseNumber' 
               AND PROCID = V_FROM_PROCID;

            BEGIN
              SELECT TBL_LABEL
                INTO V_NEW_CASE_TYPE_NAME
                FROM TBL_LOOKUP
               WHERE TBL_ID = V_NEW_CASE_TYPE_ID;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              V_NEW_CASE_TYPE_NAME := TO_CHAR(V_NEW_CASE_TYPE_ID);
              WHEN OTHERS THEN
              V_NEW_CASE_TYPE_NAME := TO_CHAR(V_NEW_CASE_TYPE_ID);
            END;

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='employeeName' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='employeeName';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='contactName' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='contactName';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='initialContactDate' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='initialContactDate';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='organization' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='organization';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='primaryDWCSpecialist' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='primaryDWCSpecialist';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='secondaryDWCSpecialist' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='secondaryDWCSpecialist';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = V_NEW_CASE_TYPE_NAME
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='caseType';

            SELECT XMLQUERY('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()' PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_GEN_EMP_HHSID FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item/id[not(contains(text(),"GEN_"))]/..') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_CATEGORY"]') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_DESC"]') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_STATUS"]') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CUST_INIT_CONTACT_DT"]') INTO V_XMLDOC FROM DUAL;
            
            IF V_NEW_CASE_TYPE_ID IS NOT NULL AND V_NEW_CASE_TYPE_NAME IS NOT NULL THEN
                SELECT UPDATEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_TYPE"]/value/text()', V_NEW_CASE_TYPE_ID) INTO V_XMLDOC FROM DUAL;
                SELECT UPDATEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_TYPE"]/text/text()',  V_NEW_CASE_TYPE_NAME) INTO V_XMLDOC FROM DUAL;                
            END IF;
        END IF;        
        
        IF V_XMLDOC IS NULL THEN
            V_XMLDOC := XMLTYPE('<formData xmlns=""><items><item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item></items><history><item /></history></formData>');
        ELSE
            SP_ERLR_EMPLOYEE_CASE_ADD(V_GEN_EMP_HHSID, V_CASE_NUMBER, TO_NUMBER(V_NEW_CASE_TYPE_ID), V_ORG_CASE_NUMBER, NULL);            
            SELECT APPENDCHILDXML(V_XMLDOC, '/formData/items', XMLTYPE('<item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item>')) INTO V_XMLDOC FROM DUAL;            
        END IF;
        
        INSERT INTO TBL_FORM_DTL (PROCID, ACTSEQ, WITEMSEQ, FORM_TYPE, FIELD_DATA, CRT_DT, CRT_USR)
                          VALUES (I_PROCID, 0, 0, 'CMSERLR', V_XMLDOC, SYSDATE, 'System');
    END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
create or replace PROCEDURE SP_FINALIZE_ERLR
(
	I_PROCID               IN  NUMBER
)
IS
    V_CNT                   INT;
    V_XMLDOC                XMLTYPE;
    V_XMLVALUE              XMLTYPE;
    V_CASE_TYPE_ID          VARCHAR2(10);
    V_VALUE                 VARCHAR2(100);
    V_NEW_CASE_TYPE_ID      VARCHAR2(10);
    V_NEW_CASE_TYPE_NAME    VARCHAR2(100);
    V_GEN_EMP_ID            VARCHAR2(64);
    V_CASE_NUMBER           NUMBER(10);
    V_TRIGGER_NEW_CASE      BOOLEAN := FALSE;
    YES                     CONSTANT VARCHAR2(3) := 'Yes';
    CONDUCT_ISSUE_ID		CONSTANT VARCHAR2(10) :='743';
    CONDUCT_ISSUE			CONSTANT VARCHAR2(50) :='Conduct Issue';
    GRIEVANCE_ID			CONSTANT VARCHAR2(10) :='745';
    GRIEVANCE			    CONSTANT VARCHAR2(50) :='Grievance';
    INVESTIGATION_ID		CONSTANT VARCHAR2(10) :='744';
    INVESTIGATION			CONSTANT VARCHAR2(50) :='Investigation';
    LABOR_NEGOTIATION_ID	CONSTANT VARCHAR2(10) :='748';
    LABOR_NEGOTIATION		CONSTANT VARCHAR2(50) :='Labor Negotiation';
    MEDICAL_DOCUMENTATION_ID CONSTANT VARCHAR2(10) :='746';
    MEDICAL_DOCUMENTATION	CONSTANT VARCHAR2(50) :='Medical Documentation';
    PERFORMANCE_ISSUE_ID	CONSTANT VARCHAR2(10) :='750';
    PERFORMANCE_ISSUE		CONSTANT VARCHAR2(50) :='Performance Issue';
    PROBATIONARY_PERIOD_ID	CONSTANT VARCHAR2(10) :='751';
    PROBATIONARY_PERIOD		CONSTANT VARCHAR2(50) :='Probationary Period Action';
    UNFAIR_LABOR_PRACTICES_ID	CONSTANT VARCHAR2(10) :='754';
    UNFAIR_LABOR_PRACTICES	CONSTANT VARCHAR2(50) :='Unfair Labor Practices';
    WGI_DENIAL_ID			CONSTANT VARCHAR2(10) :='809';
    WGI_DENIAL			    CONSTANT VARCHAR2(50) :='Within Grade Increase Denial/Reconsideration';    
    INFORMATION_REQUEST_ID  CONSTANT VARCHAR2(10) := '747';    
    THIRD_PARTY_HEARING_ID  CONSTANT VARCHAR2(10) := '753';    
    THIRD_PARTY_HEARING     CONSTANT VARCHAR2(50) := 'Third Party Hearing';
    ACTION_TYPE_COUNSELING_ID CONSTANT VARCHAR2(10) := '785';
    ACTION_TYPE_PIP_ID      CONSTANT VARCHAR2(10) := '787';
    ACTION_TYPE_WNR_ID      CONSTANT VARCHAR2(10) := '790';    
    REASON_FMLA_ID          CONSTANT VARCHAR2(10) := '1650';
BEGIN
    SELECT FIELD_DATA
      INTO V_XMLDOC
      FROM TBL_FORM_DTL
     WHERE PROCID = I_PROCID;

    V_CASE_TYPE_ID := V_XMLDOC.EXTRACT('/formData/items/item[id="GEN_CASE_TYPE"]/value/text()').getStringVal();    
    V_GEN_EMP_ID   := V_XMLDOC.EXTRACT('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()').getStringVal();    
    V_CASE_NUMBER  := TO_NUMBER(V_XMLDOC.EXTRACT('/formData/items/item[id="CASE_NUMBER"]/value/text()').getStringVal());    
    SP_ERLR_EMPLOYEE_CASE_ADD(V_GEN_EMP_ID, V_CASE_NUMBER, TO_NUMBER(V_CASE_TYPE_ID), NULL, NULL);
    
    IF V_CASE_TYPE_ID = INFORMATION_REQUEST_ID THEN -- Information Request
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="IR_APPEAL_DENIAL"]/value/text()'); -- Did Requester Appeal Denial?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN
            V_NEW_CASE_TYPE_ID   := THIRD_PARTY_HEARING_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;
    ELSIF V_CASE_TYPE_ID = INVESTIGATION_ID THEN -- Investigation
        -- Triggering Conduct Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="I_MISCONDUCT_FOUND"]/value/text()'); --Was Misconduct Found?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN
            V_NEW_CASE_TYPE_ID   := CONDUCT_ISSUE_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;
    ELSIF V_CASE_TYPE_ID = MEDICAL_DOCUMENTATION_ID THEN -- Medical Documentation
        -- Triggering Grievance Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="MD_REQUEST_REASON"]/value/text()'); -- Reason for Request
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = REASON_FMLA_ID THEN  -- FMLA      
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="MD_FMLA_GRIEVANCE"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
        END IF;
    ELSIF V_CASE_TYPE_ID = LABOR_NEGOTIATION_ID THEN -- Labor Negotiation
        -- Triggering Unfair Labor Practices Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="LN_FILE_ULP"]/value/text()');--Did Union File ULP?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN        
            V_NEW_CASE_TYPE_ID   := UNFAIR_LABOR_PRACTICES_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;        
    ELSIF V_CASE_TYPE_ID = PERFORMANCE_ISSUE_ID THEN -- Performance Issue
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_ACTION_TYPE"]/value/text()');
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = ACTION_TYPE_COUNSELING_ID THEN -- Action Type: Counseling
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_CNSL_GRV_DECISION"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
        ELSIF V_VALUE = ACTION_TYPE_PIP_ID THEN -- Action Type: PIP
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_PIP_EMPL_GRIEVANCE"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
            
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_PIP_WGI_WTHLD"]/value/text()'); --Was WGI Withheld?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := WGI_DENIAL_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID2' AND PROCID = I_PROCID;
            END IF;
        ELSIF V_VALUE = ACTION_TYPE_WNR_ID THEN -- Action Type: Written Narrative Review
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_WNR_WGI_WTHLD"]/value/text()'); -- Was WGI Withheld?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := WGI_DENIAL_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;        
        END IF;
    END IF;
    
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
create or replace PROCEDURE SP_ERLR_EMPLOYEE_CASE_ADD
(
	I_HHSID IN VARCHAR2,
	I_CASEID IN NUMBER,
    I_CASE_TYPE_ID IN NUMBER,
	I_FROM_CASEID IN NUMBER,
	I_MEMBER_ID IN VARCHAR2 -- MANUALLY ENTERED CASE IF THIS VALUE IS NOT NULL
)
IS
    V_CNT NUMBER;
    V_CASE_TYPE_NAME VARCHAR2(100);
    V_FIRST_NAME VARCHAR2(50);
    V_LAST_NAME VARCHAR2(50);
BEGIN
    SELECT COUNT(*)
      INTO V_CNT
      FROM ERLR_EMPLOYEE_CASE
     WHERE HHSID = I_HHSID
       AND CASEID = I_CASEID;

    IF 0=V_CNT THEN
        SELECT TBL_LABEL
          INTO V_CASE_TYPE_NAME
          FROM TBL_LOOKUP
         WHERE TBL_ID = I_CASE_TYPE_ID;
         
        SELECT FIRST_NAME, LAST_NAME 
          INTO V_FIRST_NAME, V_LAST_NAME 
        FROM HHS_HR.EMPLOYEE_LOOKUP           
        WHERE HHSID = (SELECT XMLQUERY('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).GETSTRINGVAL() 
          FROM TBL_FORM_DTL F JOIN BIZFLOW.RLVNTDATA P ON F.PROCID = P.PROCID AND P.RLVNTDATANAME='caseNumber'
         WHERE P.VALUE = TO_CHAR(I_CASEID));
    
        IF I_MEMBER_ID IS NULL THEN
            INSERT INTO ERLR_EMPLOYEE_CASE(HHSID, CASEID, FROM_CASEID, CASE_TYPE_ID, CASE_TYPE_NAME, EMP_LAST_NAME, EMP_FIRST_NAME)
                                    VALUES(I_HHSID, I_CASEID, I_FROM_CASEID, I_CASE_TYPE_ID, V_CASE_TYPE_NAME, V_LAST_NAME, V_FIRST_NAME);
        ELSE
            INSERT INTO ERLR_EMPLOYEE_CASE(HHSID, CASEID, FROM_CASEID, CASE_TYPE_ID, CASE_TYPE_NAME, EMP_LAST_NAME, EMP_FIRST_NAME, M_DT, M_MEMBER_ID, M_MEMBER_NAME)
            SELECT I_HHSID, I_CASEID, I_FROM_CASEID, I_CASE_TYPE_ID, V_CASE_TYPE_NAME, V_LAST_NAME, V_FIRST_NAME, CAST(SYS_EXTRACT_UTC(SYSTIMESTAMP) AS DATE), I_MEMBER_ID, M.NAME
              FROM BIZFLOW.MEMBER M
             WHERE M.MEMBERID = I_MEMBER_ID;
        END IF;
    END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
create or replace PROCEDURE SP_ERLR_EMPLOYEE_CASE_DEL
(
	I_HHSID IN VARCHAR2,
	I_CASEID IN NUMBER
)
IS
    V_CNT NUMBER;
BEGIN

    -- DELETE ONLY MANUALLY ENTERED CASE
    DELETE ERLR_EMPLOYEE_CASE
     WHERE HHSID = I_HHSID
       AND CASEID = I_CASEID
       AND M_DT IS NOT NULL; 
    
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
create or replace PROCEDURE SP_UPDATE_ERLR_FORM_DATA 
   (I_WIH_ACTION IN VARCHAR2, -- SAVE, SUBMIT
    I_FIELD_DATA IN CLOB, 
    I_USER       IN VARCHAR2, 
    I_PROCID     IN NUMBER, 
    I_ACTSEQ     IN NUMBER, 
    I_WITEMSEQ   IN NUMBER) 
IS 
  V_XMLDOC               XMLTYPE;
  V_FORM_TYPE            VARCHAR2(20) := 'CMSERLR';
  V_CNT                  INT;
  COMPLATE_CASE_ACTIVITY CONSTANT VARCHAR2(50) := 'Complete Case';
  DWC_SUPERVISOR         CONSTANT VARCHAR2(50) := 'DWC Supervisor';
BEGIN 
    -- sanity check: ignore and exit if form data xml is null or empty 
    IF I_FIELD_DATA IS NULL OR LENGTH(I_FIELD_DATA) <= 0 OR I_PROCID IS NULL OR I_USER IS NULL OR I_ACTSEQ IS NULL THEN 
      RETURN; 
    END IF;
    
    -- TODO: I_USER should be member of work item checked out
    --

    V_XMLDOC := XMLTYPE(I_FIELD_DATA); 

    MERGE INTO TBL_FORM_DTL A
    USING (SELECT * FROM TBL_FORM_DTL WHERE PROCID=I_PROCID) B
       ON (A.PROCID = B.PROCID)
     WHEN MATCHED THEN
          UPDATE 
             SET A.FIELD_DATA = V_XMLDOC, 
                 A.MOD_DT = SYS_EXTRACT_UTC(SYSTIMESTAMP), 
                 A.MOD_USR = I_USER 
     WHEN NOT MATCHED THEN     
          INSERT (A.PROCID, A.ACTSEQ, A.WITEMSEQ, A.FORM_TYPE, A.FIELD_DATA, A.CRT_DT, A.CRT_USR) 
          VALUES (I_PROCID, NVL(I_ACTSEQ, 0), NVL(I_WITEMSEQ, 0), V_FORM_TYPE, V_XMLDOC, SYS_EXTRACT_UTC(SYSTIMESTAMP), I_USER); 

    -- Update process variable and transition xml into individual tables 
    -- for respective process definition 
    SP_UPDATE_PV_ERLR(I_PROCID, V_XMLDOC); 
    SP_UPDATE_ERLR_TABLE(I_PROCID); 
/*************************************************    
    IF UPPER(I_WIH_ACTION) = 'SUBMIT' THEN
        -- CHECK: 'Complate Case' activity
        SELECT COUNT(*)
          INTO V_CNT
          FROM BIZFLOW.ACT
         WHERE PROCID = I_PROCID
           AND ACTSEQ = I_ACTSEQ
           AND NAME = COMPLETE_CASE_ACTIVITY;
        IF 0<V_CNT THEN
            -- CHECK: I_USER is member of 'DWC Supervisor' group
            SELECT COUNT(*)
              INTO V_CNT
              FROM BIZFLOW.USRGRPPRTCP P JOIN BIZFLOW.MEMBER M ON P.USRGRPID = M.MEMBERID
             WHERE M.TYPE='G'
               AND M.NAME = DWC_SUPERVISOR
               AND P.PRTCP = I_USER;
            IF 0<V_CNT THEN
                -- DWC Superviosr complete the 'Complete Case' activity
                UPDATE BIZFLOW.RLVNTDATA
                   SET VALUE = 'Yes'
                 WHERE RLVNTDATANAME = 'completeCaseActivityPostCondition'
                   AND PROCID = I_PROCID;
            ELSE
                
            END IF;
        END IF;
    END IF;
****************************************************/   
EXCEPTION 
  WHEN OTHERS THEN 
             SP_ERROR_LOG(); 
END; 
/


--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_STRATCON
--------------------------------------------------------

/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * ERLR process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 *
*/

create or replace PROCEDURE SP_UPDATE_ERLR_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
	V_CASE_NUMBER                NUMBER(20);
	V_JOB_REQ_NUM               NVARCHAR2(50);
    V_CASE_CREATION_DT          DATE;	
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
	--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_ERLR_TABLE - BEGIN ============================');
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE(' ----------------');



	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		------------------------------------------------------
		-- Transfer XML data into operational table
		--
		-- 1. Get Case number and Job Request Number
		-- 1.1 Select it from data xml from TBL_FORM_DTL table.
		-- 1.2 If not found, select it from BIZFLOW.RLVNTDATA table.
		-- 2. If Case number /Job Request Number not found, issue error.
		-- 3. For each target table,
		-- 3.1. If record found for the CASE_NUMBER, update record.
		-- 3.2. If record not found for the CASE_NUMBER, insert record.
		------------------------------------------------------
		--DBMS_OUTPUT.PUT_LINE('Starting xml data retrieval and table update ----------');

		--------------------------------
		-- get Case number
		--------------------------------
		--DBMS_OUTPUT.PUT_LINE('    REQUEST table');
        BEGIN
			SELECT VALUE
			INTO V_CASE_NUMBER
			FROM BIZFLOW.RLVNTDATA
			WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'caseNumber';
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_CASE_NUMBER := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('    V_CASE_NUMBER = ' || V_CASE_NUMBER);
		IF V_CASE_NUMBER IS NULL THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ERLR_TABLE: Case Number is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_CASE_NUMBER = ' || V_CASE_NUMBER || '  V_CASE_NUMBER = ' || TO_CHAR(V_CASE_NUMBER));
		END IF;

        --------------------------------
		-- get Request number 
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
		--IF V_JOB_REQ_NUM IS NULL THEN
		--	RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ERLR_TABLE: Request Number is invalid.  I_PROCID = '
		--		|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_NUM = ' || TO_CHAR(V_JOB_REQ_NUM));
		--END IF;

        --------------------------------
		-- get Case Creation Date
		--------------------------------
		--DBMS_OUTPUT.PUT_LINE('    Case Creation Date'');
        BEGIN
			SELECT CREATIONDTIME
			INTO V_CASE_CREATION_DT
			FROM BIZFLOW.PROCS
			WHERE PROCID = I_PROCID;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_CASE_CREATION_DT := NULL;
		END;
		--------------------------------
		-- ERLR_CASE table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_CASE TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
                    , V_JOB_REQ_NUM AS ERLR_JOB_REQ_NUMBER
                    , I_PROCID AS PROCID
                    , X.GEN_CASE_STATUS AS ERLR_CASE_STATUS_ID
                    , V_CASE_CREATION_DT AS ERLR_CASE_CREATE_DT
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            GEN_CASE_STATUS NVARCHAR2(200) PATH './item[id="GEN_CASE_STATUS"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
                TRG.ERLR_CASE_STATUS_ID = SRC.ERLR_CASE_STATUS_ID
				,TRG.ERLR_JOB_REQ_NUMBER = SRC.ERLR_JOB_REQ_NUMBER     
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
                , TRG.ERLR_JOB_REQ_NUMBER
	            , TRG.PROCID 
	            , TRG.ERLR_CASE_STATUS_ID
	            , TRG.ERLR_CASE_CREATE_DT
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
                , SRC.ERLR_JOB_REQ_NUMBER
	            , SRC.PROCID 
	            , SRC.ERLR_CASE_STATUS_ID
	            , SRC.ERLR_CASE_CREATE_DT
            );

		END;



		--------------------------------
		-- ERLR_GEN table
		--------------------------------
		BEGIN
			--DBMS_OUTPUT.PUT_LINE('    ERLR_GEN table');
			MERGE INTO ERLR_GEN TRG
			USING
			(
				SELECT
					V_CASE_NUMBER AS ERLR_CASE_NUMBER
					--X.ERLR_CASE_NUMBER
					, SUBSTR(X.GEN_PRIMARY_SPECIALIST, 4, 10) AS GEN_PRIMARY_SPECIALIST
                    , SUBSTR(X.GEN_SECONDARY_SPECIALIST, 4, 10) AS GEN_SECONDARY_SPECIALIST
                    , X.GEN_CUSTOMER_NAME
                    , X.GEN_CUSTOMER_PHONE
                    , X.GEN_CUSTOMER_ADMIN_CD
                    , X.GEN_CUSTOMER_ADMIN_CD_DESC
                    , X.GEN_EMPLOYEE_NAME
                    , X.GEN_EMPLOYEE_PHONE
                    , X.GEN_EMPLOYEE_ADMIN_CD
                    , X.GEN_EMPLOYEE_ADMIN_CD_DESC
                    , X.GEN_CASE_DESC
	                , X.GEN_CASE_STATUS
					, TO_DATE(X.GEN_CUST_INIT_CONTACT_DT,'MM/DD/YYYY HH24:MI:SS') AS GEN_CUST_INIT_CONTACT_DT            
	                , X.GEN_PRIMARY_REP_AFFILIATION
	                , X.GEN_CMS_PRIMARY_REP_ID
	                , X.GEN_CMS_PRIMARY_REP_PHONE
	                , X.GEN_NON_CMS_PRIMARY_FNAME
	                , X.GEN_NON_CMS_PRIMARY_MNAME
	                , X.GEN_NON_CMS_PRIMARY_LNAME
	                , X.GEN_NON_CMS_PRIMARY_EMAIL
	                , X.GEN_NON_CMS_PRIMARY_PHONE
	                , X.GEN_NON_CMS_PRIMARY_ORG
	                , X.GEN_NON_CMS_PRIMARY_ADDR
	                , X.GEN_CASE_TYPE
	                , X.GEN_CASE_CATEGORY
	                , X.GEN_INVESTIGATION
	                , X.GEN_INVESTIGATE_START_DT
	                , X.GEN_INVESTIGATE_END_DT
	                , X.GEN_STD_CONDUCT
	                , X.GEN_STD_CONDUCT_TYPE
	                --, X.CC_FINAL_ACTION
					, FN_GET_FINAL_ACTIONS(I_PROCID) AS CC_FINAL_ACTION
	                , TO_DATE(X.CC_CASE_COMPLETE_DT,'MM/DD/YYYY HH24:MI:SS') AS CC_CASE_COMPLETE_DT          
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/formData/items' PASSING FD.FIELD_DATA
						COLUMNS
							ERLR_CASE_NUMBER	NUMBER(20,0)	PATH './item[id="CASE_NUMBER"]/value'
							, GEN_PRIMARY_SPECIALIST VARCHAR2(13) PATH './item[id="GEN_PRIMARY_SPECIALIST"]/value'
                            , GEN_SECONDARY_SPECIALIST	VARCHAR2(13)   PATH './item[id="GEN_SECONDARY_SPECIALIST"]/value'
	                        , GEN_CUSTOMER_NAME 	NVARCHAR2(150)  PATH './item[id="GEN_CUSTOMER_NAME"]/value'
	                        , GEN_CUSTOMER_PHONE	NVARCHAR2(50)   PATH './item[id="GEN_CUSTOMER_PHONE"]/value'
	                        , GEN_CUSTOMER_ADMIN_CD	NVARCHAR2(8)    PATH './item[id="GEN_CUSTOMER_ADMIN_CD"]/value'
	                        , GEN_CUSTOMER_ADMIN_CD_DESC	NVARCHAR2(50)   PATH './item[id="GEN_CUSTOMER_ADMIN_CD_DESC"]/value'
	                        , GEN_EMPLOYEE_NAME	NVARCHAR2(150)  PATH './item[id="GEN_EMPLOYEE_NAME"]/value'
	                        , GEN_EMPLOYEE_PHONE	NVARCHAR2(50)   PATH './item[id="GEN_EMPLOYEE_PHONE"]/value'
	                        , GEN_EMPLOYEE_ADMIN_CD	NVARCHAR2(8)    PATH './item[id="GEN_EMPLOYEE_ADMIN_CD"]/value'
	                        , GEN_EMPLOYEE_ADMIN_CD_DESC	NVARCHAR2(50)   PATH './item[id="GEN_EMPLOYEE_ADMIN_CD_DESC"]/value'
	                        , GEN_CASE_DESC	NVARCHAR2(500)  PATH './item[id="GEN_CASE_DESC"]/value'
	                        , GEN_CASE_STATUS	 NVARCHAR2(200)   PATH './item[id="GEN_CASE_STATUS"]/value'
	                        , GEN_CUST_INIT_CONTACT_DT	VARCHAR2(10)    PATH './item[id="GEN_CUST_INIT_CONTACT_DT"]/value'
	                        , GEN_PRIMARY_REP_AFFILIATION	 NVARCHAR2(20)  PATH './item[id="GEN_PRIMARY_REP"]/value'
	                        , GEN_CMS_PRIMARY_REP_ID VARCHAR2(255)  PATH './item[id="GEN_CMS_PRIMARY_REP"]/value/name'
	                        , GEN_CMS_PRIMARY_REP_PHONE	NVARCHAR2(50)   PATH './item[id="GEN_CMS_PRIMARY_REP_PHONE"]/value'
	                        , GEN_NON_CMS_PRIMARY_FNAME	NVARCHAR2(50)   PATH './item[id="GEN_NON_CMS_PRIMARY_FNAME"]/value'
	                        , GEN_NON_CMS_PRIMARY_MNAME	NVARCHAR2(50)   PATH './item[id="GEN_NON_CMS_PRIMARY_MNAME"]/value'
	                        , GEN_NON_CMS_PRIMARY_LNAME	NVARCHAR2(50)   PATH './item[id="GEN_NON_CMS_PRIMARY_LNAME"]/value'
	                        , GEN_NON_CMS_PRIMARY_EMAIL	NVARCHAR2(100)  PATH './item[id="GEN_NON_CMS_PRIMARY_EMAIL"]/value'
	                        , GEN_NON_CMS_PRIMARY_PHONE	NVARCHAR2(50)   PATH './item[id="GEN_NON_CMS_PRIMARY_PHONE"]/value'
	                        , GEN_NON_CMS_PRIMARY_ORG	NVARCHAR2(100)  PATH './item[id="GEN_NON_CMS_PRIMARY_ORG"]/value'
	                        , GEN_NON_CMS_PRIMARY_ADDR	NVARCHAR2(250)  PATH './item[id="GEN_NON_CMS_PRIMARY_ADDR"]/value'
	                        , GEN_CASE_TYPE	 NUMBER(20,0)   PATH './item[id="GEN_CASE_TYPE"]/value'
	                        , GEN_CASE_CATEGORY	NVARCHAR2(200)  PATH './item[id="GEN_CASE_CATEGORY"]/value'
	                        , GEN_INVESTIGATION	NVARCHAR2(3)    PATH './item[id="GEN_INVESTIGATION"]/value'
	                        , GEN_INVESTIGATE_START_DT	DATE    PATH './item[id="GEN_INVESTIGATE_START_DT"]/value'
	                        , GEN_INVESTIGATE_END_DT	DATE    PATH './item[id="GEN_INVESTIGATE_END_DT"]/value'
	                        , GEN_STD_CONDUCT	NVARCHAR2(3)    PATH './item[id="GEN_STD_CONDUCT"]/value'
	                        , GEN_STD_CONDUCT_TYPE	 NVARCHAR2(200) PATH './item[id="GEN_STD_CONDUCT_TYPE"]/value'
	                        , CC_FINAL_ACTION	NVARCHAR2(200)  PATH './item[id="CC_FINAL_ACTION"]/value'
	                        , CC_CASE_COMPLETE_DT	VARCHAR2(10)    PATH './item[id="CC_CASE_COMPLETE_DT"]/value'
					) X					
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
			WHEN MATCHED THEN UPDATE SET
				TRG.GEN_PRIMARY_SPECIALIST                    = SRC.GEN_PRIMARY_SPECIALIST
				, TRG.GEN_SECONDARY_SPECIALIST            = SRC.GEN_SECONDARY_SPECIALIST
				, TRG.GEN_CUSTOMER_NAME                  = SRC.GEN_CUSTOMER_NAME
				, TRG.GEN_CUSTOMER_PHONE      = SRC.GEN_CUSTOMER_PHONE
				, TRG.GEN_CUSTOMER_ADMIN_CD    = SRC.GEN_CUSTOMER_ADMIN_CD
				, TRG.GEN_CUSTOMER_ADMIN_CD_DESC                = SRC.GEN_CUSTOMER_ADMIN_CD_DESC
				, TRG.GEN_EMPLOYEE_NAME       = SRC.GEN_EMPLOYEE_NAME
				, TRG.GEN_EMPLOYEE_PHONE      = SRC.GEN_EMPLOYEE_PHONE
				, TRG.GEN_EMPLOYEE_ADMIN_CD    = SRC.GEN_EMPLOYEE_ADMIN_CD
				, TRG.GEN_EMPLOYEE_ADMIN_CD_DESC                = SRC.GEN_EMPLOYEE_ADMIN_CD_DESC
				, TRG.GEN_CASE_DESC       = SRC.GEN_CASE_DESC
				, TRG.GEN_CASE_STATUS      = SRC.GEN_CASE_STATUS
				, TRG.GEN_CUST_INIT_CONTACT_DT    = SRC.GEN_CUST_INIT_CONTACT_DT
				, TRG.GEN_PRIMARY_REP_AFFILIATION                = SRC.GEN_PRIMARY_REP_AFFILIATION
				, TRG.GEN_CMS_PRIMARY_REP_ID       = SRC.GEN_CMS_PRIMARY_REP_ID
				, TRG.GEN_CMS_PRIMARY_REP_PHONE      = SRC.GEN_CMS_PRIMARY_REP_PHONE
				, TRG.GEN_NON_CMS_PRIMARY_FNAME    = SRC.GEN_NON_CMS_PRIMARY_FNAME
				, TRG.GEN_NON_CMS_PRIMARY_MNAME                = SRC.GEN_NON_CMS_PRIMARY_MNAME
				, TRG.GEN_NON_CMS_PRIMARY_LNAME       = SRC.GEN_NON_CMS_PRIMARY_LNAME
				, TRG.GEN_NON_CMS_PRIMARY_EMAIL      = SRC.GEN_NON_CMS_PRIMARY_EMAIL
				, TRG.GEN_NON_CMS_PRIMARY_PHONE    = SRC.GEN_NON_CMS_PRIMARY_PHONE
				, TRG.GEN_NON_CMS_PRIMARY_ORG                = SRC.GEN_NON_CMS_PRIMARY_ORG
				, TRG.GEN_NON_CMS_PRIMARY_ADDR       = SRC.GEN_NON_CMS_PRIMARY_ADDR
				, TRG.GEN_CASE_TYPE      = SRC.GEN_CASE_TYPE
				, TRG.GEN_CASE_CATEGORY            = SRC.GEN_CASE_CATEGORY
				, TRG.GEN_INVESTIGATION                  = SRC.GEN_INVESTIGATION
				, TRG.GEN_INVESTIGATE_START_DT               = SRC.GEN_INVESTIGATE_START_DT
				, TRG.GEN_INVESTIGATE_END_DT                     = SRC.GEN_INVESTIGATE_END_DT
				, TRG.GEN_STD_CONDUCT                  = SRC.GEN_STD_CONDUCT
				, TRG.GEN_STD_CONDUCT_TYPE                    = SRC.GEN_STD_CONDUCT_TYPE
				, TRG.CC_FINAL_ACTION                     = SRC.CC_FINAL_ACTION
				, TRG.CC_CASE_COMPLETE_DT                  = SRC.CC_CASE_COMPLETE_DT				
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.ERLR_CASE_NUMBER
				, TRG.GEN_PRIMARY_SPECIALIST
				, TRG.GEN_SECONDARY_SPECIALIST
				, TRG.GEN_CUSTOMER_NAME     
				, TRG.GEN_CUSTOMER_PHONE  
				, TRG.GEN_CUSTOMER_ADMIN_CD
				, TRG.GEN_CUSTOMER_ADMIN_CD_DESC
				, TRG.GEN_EMPLOYEE_NAME
				, TRG.GEN_EMPLOYEE_PHONE
				, TRG.GEN_EMPLOYEE_ADMIN_CD
				, TRG.GEN_EMPLOYEE_ADMIN_CD_DESC
				, TRG.GEN_CASE_DESC
				, TRG.GEN_CASE_STATUS
				, TRG.GEN_CUST_INIT_CONTACT_DT
				, TRG.GEN_PRIMARY_REP_AFFILIATION
				, TRG.GEN_CMS_PRIMARY_REP_ID
				, TRG.GEN_CMS_PRIMARY_REP_PHONE
				, TRG.GEN_NON_CMS_PRIMARY_FNAME
				, TRG.GEN_NON_CMS_PRIMARY_MNAME
				, TRG.GEN_NON_CMS_PRIMARY_LNAME
				, TRG.GEN_NON_CMS_PRIMARY_EMAIL
				, TRG.GEN_NON_CMS_PRIMARY_PHONE
				, TRG.GEN_NON_CMS_PRIMARY_ORG
				, TRG.GEN_NON_CMS_PRIMARY_ADDR
				, TRG.GEN_CASE_TYPE
				, TRG.GEN_CASE_CATEGORY
				, TRG.GEN_INVESTIGATION
				, TRG.GEN_INVESTIGATE_START_DT
				, TRG.GEN_INVESTIGATE_END_DT
				, TRG.GEN_STD_CONDUCT
				, TRG.GEN_STD_CONDUCT_TYPE
				, TRG.CC_FINAL_ACTION
				, TRG.CC_CASE_COMPLETE_DT
			)
			VALUES
			(
				SRC.ERLR_CASE_NUMBER
				, SRC.GEN_PRIMARY_SPECIALIST
				, SRC.GEN_SECONDARY_SPECIALIST
				, SRC.GEN_CUSTOMER_NAME     
				, SRC.GEN_CUSTOMER_PHONE  
				, SRC.GEN_CUSTOMER_ADMIN_CD
				, SRC.GEN_CUSTOMER_ADMIN_CD_DESC
				, SRC.GEN_EMPLOYEE_NAME
				, SRC.GEN_EMPLOYEE_PHONE
				, SRC.GEN_EMPLOYEE_ADMIN_CD
				, SRC.GEN_EMPLOYEE_ADMIN_CD_DESC
				, SRC.GEN_CASE_DESC
				, SRC.GEN_CASE_STATUS
				, SRC.GEN_CUST_INIT_CONTACT_DT
				, SRC.GEN_PRIMARY_REP_AFFILIATION
				, SRC.GEN_CMS_PRIMARY_REP_ID
				, SRC.GEN_CMS_PRIMARY_REP_PHONE
				, SRC.GEN_NON_CMS_PRIMARY_FNAME
				, SRC.GEN_NON_CMS_PRIMARY_MNAME
				, SRC.GEN_NON_CMS_PRIMARY_LNAME
				, SRC.GEN_NON_CMS_PRIMARY_EMAIL
				, SRC.GEN_NON_CMS_PRIMARY_PHONE
				, SRC.GEN_NON_CMS_PRIMARY_ORG
				, SRC.GEN_NON_CMS_PRIMARY_ADDR
				, SRC.GEN_CASE_TYPE
				, SRC.GEN_CASE_CATEGORY
				, SRC.GEN_INVESTIGATION
				, SRC.GEN_INVESTIGATE_START_DT
				, SRC.GEN_INVESTIGATE_END_DT
				, SRC.GEN_STD_CONDUCT
				, SRC.GEN_STD_CONDUCT_TYPE
				, SRC.CC_FINAL_ACTION
				, SRC.CC_CASE_COMPLETE_DT
			)
			;
		END;

		--------------------------------
		-- ERLR_CNDT_ISSUE table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_CNDT_ISSUE TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.CI_ACTION_TYPE
					, CASE WHEN X.CI_ADMIN_INVESTIGATORY_LEAVE = 'true'  THEN '1' ELSE '0' END AS CI_ADMIN_INVESTIGATORY_LEAVE
					, CASE WHEN X.CI_ADMIN_NOTICE_LEAVE = 'true'  THEN '1' ELSE '0' END AS CI_ADMIN_NOTICE_LEAVE
					, TO_DATE(X.CI_LEAVE_START_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_LEAVE_START_DT
					, TO_DATE(X.CI_LEAVE_END_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_LEAVE_END_DT
					, X.CI_APPROVAL_NAME
					, TO_DATE(X.CI_LEAVE_START_DT_2,'MM/DD/YYYY HH24:MI:SS') AS CI_LEAVE_START_DT_2
					, TO_DATE(X.CI_LEAVE_END_DT_2,'MM/DD/YYYY HH24:MI:SS') AS CI_LEAVE_END_DT_2
					, X.CI_APPROVAL_NAME_2
					, TO_DATE(X.CI_PROP_ACTION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_PROP_ACTION_ISSUED_DT
					, X.CI_ORAL_PREZ_REQUESTED
					, TO_DATE(X.CI_ORAL_PREZ_DT,'MM/DD/YYYY HH24:MI:SS') AS  CI_ORAL_PREZ_DT
					, X.CI_ORAL_RESPONSE_SUBMITTED
					, TO_DATE(X.CI_RESPONSE_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_RESPONSE_DUE_DT
					, TO_DATE(X.CI_WRITTEN_RESPONSE_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_WRITTEN_RESPONSE_SBMT_DT
					, X.CI_POS_TITLE
					, X.CI_PPLAN
					, X.CI_SERIES
					, X.CI_CURRENT_INFO_GRADE
					, X.CI_CURRENT_INFO_STEP
					, X.CI_PROPOSED_POS_TITLE
					, X.CI_PROPOSED_PPLAN
					, X.CI_PROPOSED_SERIES
					, X.CI_PROPOSED_INFO_GRADE
					, X.CI_PROPOSED_INFO_STEP
					, X.CI_FINAL_POS_TITLE
					, X.CI_FINAL_PPLAN
					, X.CI_FINAL_SERIES
					, X.CI_FINAL_INFO_GRADE
					, X.CI_FINAL_INFO_STEP
					, X.CI_DEMO_FINAL_AGNCY_DCSN
					, X.CI_DECIDING_OFFCL
					, TO_DATE(X.CI_DECISION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_DECISION_ISSUED_DT
					, TO_DATE(X.CI_DEMO_FINAL_AGENCY_EFF_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_DEMO_FINAL_AGENCY_EFF_DT
					, X.CI_NUMB_DAYS
					, X.CI_COUNSEL_TYPE
					, TO_DATE(X.CI_COUNSEL_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_COUNSEL_ISSUED_DT
					, TO_DATE(X.CI_SICK_LEAVE_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SICK_LEAVE_ISSUED_DT
					, TO_DATE(X.CI_RESTRICTION_ISSED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_RESTRICTION_ISSED_DT
					, X.CI_SL_REVIEWED_DT_LIST
					, X.CI_SL_WARNING_DISCUSS_DT_LIST
					, TO_DATE(X.CI_SL_WARN_ISSUE,'MM/DD/YYYY HH24:MI:SS') AS CI_SL_WARN_ISSUE
					, TO_DATE(X.CI_NOTICE_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_NOTICE_ISSUED_DT
					, TO_DATE(X.CI_EFFECTIVE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_EFFECTIVE_DT
					, X.CI_CURRENT_ADMIN_CODE
					, X.CI_RE_ASSIGNMENT_CURR_ORG
					, X.CI_FINAL_ADMIN_CODE
					, X.CI_RE_ASSIGNMENT_FINAL_ORG
					, TO_DATE(X.CI_REMOVAL_PROP_ACTION_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REMOVAL_PROP_ACTION_DT
					, X.CI_EMP_NOTICE_LEAVE_PLACED
					, TO_DATE(X.CI_REMOVAL_NOTICE_START_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REMOVAL_NOTICE_START_DT
					, TO_DATE(X.CI_REMOVAL_NOTICE_END_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REMOVAL_NOTICE_END_DT
					, X.CI_RMVL_ORAL_PREZ_RQSTED
					, TO_DATE(X.CI_REMOVAL_ORAL_PREZ_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REMOVAL_ORAL_PREZ_DT
					, X.CI_RMVL_WRTN_RESPONSE
					, TO_DATE(X.CI_WRITTEN_RESPONSE_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_WRITTEN_RESPONSE_DUE_DT
					, TO_DATE(X.CI_WRITTEN_SUBMITTED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_WRITTEN_SUBMITTED_DT
					, X.CI_RMVL_FINAL_AGNCY_DCSN
					, X.CI_DECIDING_OFFCL_NAME
					, TO_DATE(X.CI_RMVL_DATE_DCSN_ISSUED,'MM/DD/YYYY HH24:MI:SS') AS CI_RMVL_DATE_DCSN_ISSUED
					, TO_DATE(X.CI_REMOVAL_EFFECTIVE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REMOVAL_EFFECTIVE_DT
					, X.CI_RMVL_NUMB_DAYS
					, X.CI_SUSPENTION_TYPE
					, TO_DATE(X.CI_SUSP_PROP_ACTION_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_PROP_ACTION_DT
					, X.CI_SUSP_ORAL_PREZ_REQUESTED
					, TO_DATE(X.CI_SUSP_ORAL_PREZ_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_ORAL_PREZ_DT
					, X.CI_SUSP_WRITTEN_RESP
					, TO_DATE(X.CI_SUSP_WRITTEN_RESP_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_WRITTEN_RESP_DUE_DT
					, TO_DATE(X.CI_SUSP_WRITTEN_RESP_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_WRITTEN_RESP_DT
					, X.CI_SUSP_FINAL_AGNCY_DCSN
					, X.CI_SUSP_DECIDING_OFFCL_NAME
					, TO_DATE(X.CI_SUSP_DECISION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_DECISION_ISSUED_DT
					, TO_DATE(X.CI_SUSP_EFFECTIVE_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_SUSP_EFFECTIVE_DECISION_DT
					, X.CI_SUS_NUMB_DAYS
					, TO_DATE(X.CI_REPRIMAND_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS CI_REPRIMAND_ISSUE_DT
					, X.CI_EMP_APPEAL_DECISION                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            CI_ACTION_TYPE	NVARCHAR2(200)	PATH './item[id="CI_ACTION_TYPE"]/value'
							, CI_ADMIN_INVESTIGATORY_LEAVE	NVARCHAR2(5)	PATH './item[id="CI_ADMIN_INVESTIGATORY_LEAVE"]/value'
							, CI_ADMIN_NOTICE_LEAVE	NVARCHAR2(5)	PATH './item[id="CI_ADMIN_NOTICE_LEAVE"]/value'
							, CI_LEAVE_START_DT	NVARCHAR2(10)	PATH './item[id="CI_LEAVE_START_DT"]/value'
							, CI_LEAVE_END_DT	NVARCHAR2(10)	PATH './item[id="CI_LEAVE_END_DT"]/value'
							, CI_APPROVAL_NAME	NVARCHAR2(255)	PATH './item[id="CI_APPROVAL_NAME"]/value/name'
							, CI_LEAVE_START_DT_2	NVARCHAR2(10)	PATH './item[id="CI_LEAVE_START_DT_2"]/value'
							, CI_LEAVE_END_DT_2	NVARCHAR2(10)	PATH './item[id="CI_LEAVE_END_DT_2"]/value'
							, CI_APPROVAL_NAME_2	NVARCHAR2(255)	PATH './item[id="CI_APPROVAL_NAME_2"]/value/name'
							, CI_PROP_ACTION_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_PROP_ACTION_ISSUED_DT"]/value'
							, CI_ORAL_PREZ_REQUESTED	NVARCHAR2(3)	PATH './item[id="CI_ORAL_PREZ_REQUESTED"]/value'
							, CI_ORAL_PREZ_DT	NVARCHAR2(10)	PATH './item[id="CI_ORAL_PREZ_DT"]/value'
							, CI_ORAL_RESPONSE_SUBMITTED	NVARCHAR2(3)	PATH './item[id="CI_ORAL_RESPONSE_SUBMITTED"]/value'
							, CI_RESPONSE_DUE_DT	NVARCHAR2(10)	PATH './item[id="CI_RESPONSE_DUE_DT"]/value'
							, CI_WRITTEN_RESPONSE_SBMT_DT	NVARCHAR2(10)	PATH './item[id="CI_WRITTEN_RESPONSE_SUBMITTED_DT"]/value'
							, CI_POS_TITLE	NVARCHAR2(50)	PATH './item[id="CI_POS_TITLE"]/value'
							, CI_PPLAN	NVARCHAR2(50)	PATH './item[id="CI_PPLAN"]/value'
							, CI_SERIES	NVARCHAR2(50)	PATH './item[id="CI_SERIES"]/value'
							, CI_CURRENT_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="CI_CURRENT_INFO_GRADE"]/value'
							, CI_CURRENT_INFO_STEP	NVARCHAR2(50)	PATH './item[id="CI_CURRENT_INFO_STEP"]/value'
							, CI_PROPOSED_POS_TITLE	NVARCHAR2(50)	PATH './item[id="CI_PROPOSED_POS_TITLE"]/value'
							, CI_PROPOSED_PPLAN	NVARCHAR2(50)	PATH './item[id="CI_PROPOSED_PPLAN"]/value'
							, CI_PROPOSED_SERIES	NVARCHAR2(50)	PATH './item[id="CI_PROPOSED_SERIES"]/value'
							, CI_PROPOSED_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="CI_PROPOSED_INFO_GRADE"]/value'
							, CI_PROPOSED_INFO_STEP	NVARCHAR2(50)	PATH './item[id="CI_PROPOSED_INFO_STEP"]/value'
							, CI_FINAL_POS_TITLE	NVARCHAR2(50)	PATH './item[id="CI_FINAL_POS_TITLE"]/value'
							, CI_FINAL_PPLAN	NVARCHAR2(50)	PATH './item[id="CI_FINAL_PPLAN"]/value'
							, CI_FINAL_SERIES	NVARCHAR2(50)	PATH './item[id="CI_FINAL_SERIES"]/value'
							, CI_FINAL_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="CI_FINAL_INFO_GRADE"]/value'
							, CI_FINAL_INFO_STEP	NVARCHAR2(50)	PATH './item[id="CI_FINAL_INFO_STEP"]/value'
							, CI_DEMO_FINAL_AGNCY_DCSN	NVARCHAR2(200)	PATH './item[id="CI_DEMO_FINAL_AGENCY_DECISION"]/value'
							, CI_DECIDING_OFFCL	NVARCHAR2(255)	PATH './item[id="CI_DECIDING_OFFCL"]/value/name'
							, CI_DECISION_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_DECISION_ISSUED_DT"]/value'
							, CI_DEMO_FINAL_AGENCY_EFF_DT	NVARCHAR2(10)	PATH './item[id="CI_DEMO_FINAL_AGENCY_EFF_DT"]/value'
							, CI_NUMB_DAYS	NUMBER(20,0)	PATH './item[id="CI_NUMB_DAYS"]/value'
							, CI_COUNSEL_TYPE	NVARCHAR2(200)	PATH './item[id="CI_COUNSEL_TYPE"]/value'
							, CI_COUNSEL_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_COUNSEL_ISSUED_DT"]/value'
							, CI_SICK_LEAVE_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_SICK_LEAVE_ISSUED_DT"]/value'
							, CI_RESTRICTION_ISSED_DT	NVARCHAR2(10)	PATH './item[id="CI_RESTRICTION_ISSED_DT"]/value'
							, CI_SL_REVIEWED_DT_LIST	VARCHAR2(4000)	PATH './item[id="CI_SICK_LEAVE_REVIEWED_DT_LIST"]/value'
							, CI_SL_WARNING_DISCUSS_DT_LIST	VARCHAR2(4000)	PATH './item[id="CI_SL_WARNING_DISCUSSION_DT_LIST"]/value'
							, CI_SL_WARN_ISSUE	NVARCHAR2(10)	PATH './item[id="CI_SL_WARN_ISSUE"]/value'
							, CI_NOTICE_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_NOTICE_ISSUED_DT"]/value'
							, CI_EFFECTIVE_DT	NVARCHAR2(10)	PATH './item[id="CI_EFFECTIVE_DT"]/value'
							, CI_CURRENT_ADMIN_CODE	NVARCHAR2(8)	PATH './item[id="CI_CURRENT_ADMIN_CODE"]/value'
							, CI_RE_ASSIGNMENT_CURR_ORG	NVARCHAR2(50)	PATH './item[id="CI_RE_ASSIGNMENT_CURR_ORG"]/value'
							, CI_FINAL_ADMIN_CODE	NVARCHAR2(8)	PATH './item[id="CI_FINAL_ADMIN_CODE"]/value'
							, CI_RE_ASSIGNMENT_FINAL_ORG	NVARCHAR2(50)	PATH './item[id="CI_RE_ASSIGNMENT_FINAL_ORG"]/value'
							, CI_REMOVAL_PROP_ACTION_DT	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_PROP_ACTION_DT"]/value'
							, CI_EMP_NOTICE_LEAVE_PLACED	NVARCHAR2(3)	PATH './item[id="CI_EMP_NOTICE_LEAVE_PLACED"]/value'
							, CI_REMOVAL_NOTICE_START_DT	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_NOTICE_START_DT"]/value'
							, CI_REMOVAL_NOTICE_END_DT	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_NOTICE_END_DT"]/value'
							, CI_RMVL_ORAL_PREZ_RQSTED	NVARCHAR2(3)	PATH './item[id="CI_REMOVAL_ORAL_PREZ_REQUESTED"]/value'
							, CI_REMOVAL_ORAL_PREZ_DT	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_ORAL_PREZ_DT"]/value'
							, CI_RMVL_WRTN_RESPONSE	NVARCHAR2(3)	PATH './item[id="CI_REMOVAL_WRITTEN_RESPONSE"]/value'
							, CI_WRITTEN_RESPONSE_DUE_DT	NVARCHAR2(10)	PATH './item[id="CI_WRITTEN_RESPONSE_DUE_DT"]/value'
							, CI_WRITTEN_SUBMITTED_DT	NVARCHAR2(10)	PATH './item[id="CI_WRITTEN_SUBMITTED_DT"]/value'
							, CI_RMVL_FINAL_AGNCY_DCSN	NVARCHAR2(200)	PATH './item[id="CI_RMVL_FINAL_AGENCY_DECISION"]/value'
							, CI_DECIDING_OFFCL_NAME	NVARCHAR2(255)	PATH './item[id="CI_DECIDING_OFFCL_NAME"]/value/name'
							, CI_RMVL_DATE_DCSN_ISSUED	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_DATE_DECISION_ISSUED"]/value'
							, CI_REMOVAL_EFFECTIVE_DT	NVARCHAR2(10)	PATH './item[id="CI_REMOVAL_EFFECTIVE_DT"]/value'
							, CI_RMVL_NUMB_DAYS	NUMBER(20,0)	PATH './item[id="CI_RMVL_NUMB_DAYS"]/value'
							, CI_SUSPENTION_TYPE	NUMBER(20,0)	PATH './item[id="CI_SUSPENTION_TYPE"]/value'
							, CI_SUSP_PROP_ACTION_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_PROP_ACTION_DT"]/value'
							, CI_SUSP_ORAL_PREZ_REQUESTED	NVARCHAR2(3)	PATH './item[id="CI_SUSP_ORAL_PREZ_REQUESTED"]/value'
							, CI_SUSP_ORAL_PREZ_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_ORAL_PREZ_DT"]/value'
							, CI_SUSP_WRITTEN_RESP	NVARCHAR2(3)	PATH './item[id="CI_SUSP_WRITTEN_RESP"]/value'
							, CI_SUSP_WRITTEN_RESP_DUE_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_WRITTEN_RESP_DUE_DT"]/value'
							, CI_SUSP_WRITTEN_RESP_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_WRITTEN_RESP_DT"]/value'
							, CI_SUSP_FINAL_AGNCY_DCSN	NVARCHAR2(200)	PATH './item[id="CI_SUSP_FINAL_AGENCY_DECISION"]/value'
							, CI_SUSP_DECIDING_OFFCL_NAME	NVARCHAR2(255)	PATH './item[id="CI_SUSP_DECIDING_OFFCL_NAME"]/value/name'
							, CI_SUSP_DECISION_ISSUED_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_DECISION_ISSUED_DT"]/value'
							, CI_SUSP_EFFECTIVE_DECISION_DT	NVARCHAR2(10)	PATH './item[id="CI_SUSP_EFFECTIVE_DECISION_DT"]/value'
							, CI_SUS_NUMB_DAYS	NUMBER(20,0)	PATH './item[id="CI_SUS_NUMB_DAYS"]/value'
							, CI_REPRIMAND_ISSUE_DT	NVARCHAR2(10)	PATH './item[id="CI_REPRIMAND_ISSUE_DT"]/value'
							, CI_EMP_APPEAL_DECISION	NVARCHAR2(3)	PATH './item[id="CI_EMP_APPEAL_DECISION"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
				--TRG.ERLR_CASE_NUMBER = SRC.ERLR_CASE_NUMBER
				TRG.CI_ACTION_TYPE = SRC.CI_ACTION_TYPE
                , TRG.CI_ADMIN_INVESTIGATORY_LEAVE = SRC.CI_ADMIN_INVESTIGATORY_LEAVE
                , TRG.CI_ADMIN_NOTICE_LEAVE = SRC.CI_ADMIN_NOTICE_LEAVE				
				, TRG.CI_LEAVE_START_DT = SRC.CI_LEAVE_START_DT
				, TRG.CI_LEAVE_END_DT = SRC.CI_LEAVE_END_DT
				, TRG.CI_APPROVAL_NAME = SRC.CI_APPROVAL_NAME
				, TRG.CI_LEAVE_START_DT_2 = SRC.CI_LEAVE_START_DT_2
				, TRG.CI_LEAVE_END_DT_2 = SRC.CI_LEAVE_END_DT_2
				, TRG.CI_APPROVAL_NAME_2 = SRC.CI_APPROVAL_NAME_2
				, TRG.CI_PROP_ACTION_ISSUED_DT = SRC.CI_PROP_ACTION_ISSUED_DT
				, TRG.CI_ORAL_PREZ_REQUESTED = SRC.CI_ORAL_PREZ_REQUESTED
				, TRG.CI_ORAL_PREZ_DT = SRC.CI_ORAL_PREZ_DT
				, TRG.CI_ORAL_RESPONSE_SUBMITTED = SRC.CI_ORAL_RESPONSE_SUBMITTED
				, TRG.CI_RESPONSE_DUE_DT = SRC.CI_RESPONSE_DUE_DT
				, TRG.CI_WRITTEN_RESPONSE_SBMT_DT = SRC.CI_WRITTEN_RESPONSE_SBMT_DT
				, TRG.CI_POS_TITLE = SRC.CI_POS_TITLE
				, TRG.CI_PPLAN = SRC.CI_PPLAN
				, TRG.CI_SERIES = SRC.CI_SERIES
				, TRG.CI_CURRENT_INFO_GRADE = SRC.CI_CURRENT_INFO_GRADE
				, TRG.CI_CURRENT_INFO_STEP = SRC.CI_CURRENT_INFO_STEP
				, TRG.CI_PROPOSED_POS_TITLE = SRC.CI_PROPOSED_POS_TITLE
				, TRG.CI_PROPOSED_PPLAN = SRC.CI_PROPOSED_PPLAN
				, TRG.CI_PROPOSED_SERIES = SRC.CI_PROPOSED_SERIES
				, TRG.CI_PROPOSED_INFO_GRADE = SRC.CI_PROPOSED_INFO_GRADE
				, TRG.CI_PROPOSED_INFO_STEP = SRC.CI_PROPOSED_INFO_STEP
				, TRG.CI_FINAL_POS_TITLE = SRC.CI_FINAL_POS_TITLE
				, TRG.CI_FINAL_PPLAN = SRC.CI_FINAL_PPLAN
				, TRG.CI_FINAL_SERIES = SRC.CI_FINAL_SERIES
				, TRG.CI_FINAL_INFO_GRADE = SRC.CI_FINAL_INFO_GRADE
				, TRG.CI_FINAL_INFO_STEP = SRC.CI_FINAL_INFO_STEP
				, TRG.CI_DEMO_FINAL_AGNCY_DCSN = SRC.CI_DEMO_FINAL_AGNCY_DCSN
				, TRG.CI_DECIDING_OFFCL = SRC.CI_DECIDING_OFFCL
				, TRG.CI_DECISION_ISSUED_DT = SRC.CI_DECISION_ISSUED_DT
				, TRG.CI_DEMO_FINAL_AGENCY_EFF_DT = SRC.CI_DEMO_FINAL_AGENCY_EFF_DT
				, TRG.CI_NUMB_DAYS = SRC.CI_NUMB_DAYS
				, TRG.CI_COUNSEL_TYPE = SRC.CI_COUNSEL_TYPE
				, TRG.CI_COUNSEL_ISSUED_DT = SRC.CI_COUNSEL_ISSUED_DT
				, TRG.CI_SICK_LEAVE_ISSUED_DT = SRC.CI_SICK_LEAVE_ISSUED_DT
				, TRG.CI_RESTRICTION_ISSED_DT = SRC.CI_RESTRICTION_ISSED_DT
				, TRG.CI_SL_REVIEWED_DT_LIST = SRC.CI_SL_REVIEWED_DT_LIST
				, TRG.CI_SL_WARNING_DISCUSS_DT_LIST = SRC.CI_SL_WARNING_DISCUSS_DT_LIST
				, TRG.CI_SL_WARN_ISSUE = SRC.CI_SL_WARN_ISSUE
				, TRG.CI_NOTICE_ISSUED_DT = SRC.CI_NOTICE_ISSUED_DT
				, TRG.CI_EFFECTIVE_DT = SRC.CI_EFFECTIVE_DT
				, TRG.CI_CURRENT_ADMIN_CODE = SRC.CI_CURRENT_ADMIN_CODE
				, TRG.CI_RE_ASSIGNMENT_CURR_ORG = SRC.CI_RE_ASSIGNMENT_CURR_ORG
				, TRG.CI_FINAL_ADMIN_CODE = SRC.CI_FINAL_ADMIN_CODE
				, TRG.CI_RE_ASSIGNMENT_FINAL_ORG = SRC.CI_RE_ASSIGNMENT_FINAL_ORG
				, TRG.CI_REMOVAL_PROP_ACTION_DT = SRC.CI_REMOVAL_PROP_ACTION_DT
				, TRG.CI_EMP_NOTICE_LEAVE_PLACED = SRC.CI_EMP_NOTICE_LEAVE_PLACED
				, TRG.CI_REMOVAL_NOTICE_START_DT = SRC.CI_REMOVAL_NOTICE_START_DT
				, TRG.CI_REMOVAL_NOTICE_END_DT = SRC.CI_REMOVAL_NOTICE_END_DT
				, TRG.CI_RMVL_ORAL_PREZ_RQSTED = SRC.CI_RMVL_ORAL_PREZ_RQSTED
				, TRG.CI_REMOVAL_ORAL_PREZ_DT = SRC.CI_REMOVAL_ORAL_PREZ_DT
				, TRG.CI_RMVL_WRTN_RESPONSE = SRC.CI_RMVL_WRTN_RESPONSE
				, TRG.CI_WRITTEN_RESPONSE_DUE_DT = SRC.CI_WRITTEN_RESPONSE_DUE_DT
				, TRG.CI_WRITTEN_SUBMITTED_DT = SRC.CI_WRITTEN_SUBMITTED_DT
				, TRG.CI_RMVL_FINAL_AGNCY_DCSN = SRC.CI_RMVL_FINAL_AGNCY_DCSN
				, TRG.CI_DECIDING_OFFCL_NAME = SRC.CI_DECIDING_OFFCL_NAME
				, TRG.CI_RMVL_DATE_DCSN_ISSUED = SRC.CI_RMVL_DATE_DCSN_ISSUED
				, TRG.CI_REMOVAL_EFFECTIVE_DT = SRC.CI_REMOVAL_EFFECTIVE_DT
				, TRG.CI_RMVL_NUMB_DAYS = SRC.CI_RMVL_NUMB_DAYS
				, TRG.CI_SUSPENTION_TYPE = SRC.CI_SUSPENTION_TYPE
				, TRG.CI_SUSP_PROP_ACTION_DT = SRC.CI_SUSP_PROP_ACTION_DT
				, TRG.CI_SUSP_ORAL_PREZ_REQUESTED = SRC.CI_SUSP_ORAL_PREZ_REQUESTED
				, TRG.CI_SUSP_ORAL_PREZ_DT = SRC.CI_SUSP_ORAL_PREZ_DT
				, TRG.CI_SUSP_WRITTEN_RESP = SRC.CI_SUSP_WRITTEN_RESP
				, TRG.CI_SUSP_WRITTEN_RESP_DUE_DT = SRC.CI_SUSP_WRITTEN_RESP_DUE_DT
				, TRG.CI_SUSP_WRITTEN_RESP_DT = SRC.CI_SUSP_WRITTEN_RESP_DT
				, TRG.CI_SUSP_FINAL_AGNCY_DCSN = SRC.CI_SUSP_FINAL_AGNCY_DCSN
				, TRG.CI_SUSP_DECIDING_OFFCL_NAME = SRC.CI_SUSP_DECIDING_OFFCL_NAME
				, TRG.CI_SUSP_DECISION_ISSUED_DT = SRC.CI_SUSP_DECISION_ISSUED_DT
				, TRG.CI_SUSP_EFFECTIVE_DECISION_DT = SRC.CI_SUSP_EFFECTIVE_DECISION_DT
				, TRG.CI_SUS_NUMB_DAYS = SRC.CI_SUS_NUMB_DAYS
				, TRG.CI_REPRIMAND_ISSUE_DT = SRC.CI_REPRIMAND_ISSUE_DT
				, TRG.CI_EMP_APPEAL_DECISION = SRC.CI_EMP_APPEAL_DECISION                    
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.CI_ACTION_TYPE
                , TRG.CI_ADMIN_INVESTIGATORY_LEAVE
                , TRG.CI_ADMIN_NOTICE_LEAVE			
				, TRG.CI_LEAVE_START_DT
				, TRG.CI_LEAVE_END_DT
				, TRG.CI_APPROVAL_NAME
				, TRG.CI_LEAVE_START_DT_2
				, TRG.CI_LEAVE_END_DT_2
				, TRG.CI_APPROVAL_NAME_2
				, TRG.CI_PROP_ACTION_ISSUED_DT
				, TRG.CI_ORAL_PREZ_REQUESTED
				, TRG.CI_ORAL_PREZ_DT
				, TRG.CI_ORAL_RESPONSE_SUBMITTED
				, TRG.CI_RESPONSE_DUE_DT
				, TRG.CI_WRITTEN_RESPONSE_SBMT_DT
				, TRG.CI_POS_TITLE
				, TRG.CI_PPLAN
				, TRG.CI_SERIES
				, TRG.CI_CURRENT_INFO_GRADE
				, TRG.CI_CURRENT_INFO_STEP
				, TRG.CI_PROPOSED_POS_TITLE
				, TRG.CI_PROPOSED_PPLAN
				, TRG.CI_PROPOSED_SERIES
				, TRG.CI_PROPOSED_INFO_GRADE
				, TRG.CI_PROPOSED_INFO_STEP
				, TRG.CI_FINAL_POS_TITLE
				, TRG.CI_FINAL_PPLAN
				, TRG.CI_FINAL_SERIES
				, TRG.CI_FINAL_INFO_GRADE
				, TRG.CI_FINAL_INFO_STEP
				, TRG.CI_DEMO_FINAL_AGNCY_DCSN
				, TRG.CI_DECIDING_OFFCL
				, TRG.CI_DECISION_ISSUED_DT
				, TRG.CI_DEMO_FINAL_AGENCY_EFF_DT
				, TRG.CI_NUMB_DAYS
				, TRG.CI_COUNSEL_TYPE
				, TRG.CI_COUNSEL_ISSUED_DT
				, TRG.CI_SICK_LEAVE_ISSUED_DT
				, TRG.CI_RESTRICTION_ISSED_DT
				, TRG.CI_SL_REVIEWED_DT_LIST
				, TRG.CI_SL_WARNING_DISCUSS_DT_LIST
				, TRG.CI_SL_WARN_ISSUE
				, TRG.CI_NOTICE_ISSUED_DT
				, TRG.CI_EFFECTIVE_DT
				, TRG.CI_CURRENT_ADMIN_CODE
				, TRG.CI_RE_ASSIGNMENT_CURR_ORG
				, TRG.CI_FINAL_ADMIN_CODE
				, TRG.CI_RE_ASSIGNMENT_FINAL_ORG
				, TRG.CI_REMOVAL_PROP_ACTION_DT
				, TRG.CI_EMP_NOTICE_LEAVE_PLACED
				, TRG.CI_REMOVAL_NOTICE_START_DT
				, TRG.CI_REMOVAL_NOTICE_END_DT
				, TRG.CI_RMVL_ORAL_PREZ_RQSTED
				, TRG.CI_REMOVAL_ORAL_PREZ_DT
				, TRG.CI_RMVL_WRTN_RESPONSE
				, TRG.CI_WRITTEN_RESPONSE_DUE_DT
				, TRG.CI_WRITTEN_SUBMITTED_DT
				, TRG.CI_RMVL_FINAL_AGNCY_DCSN
				, TRG.CI_DECIDING_OFFCL_NAME
				, TRG.CI_RMVL_DATE_DCSN_ISSUED
				, TRG.CI_REMOVAL_EFFECTIVE_DT
				, TRG.CI_RMVL_NUMB_DAYS
				, TRG.CI_SUSPENTION_TYPE
				, TRG.CI_SUSP_PROP_ACTION_DT
				, TRG.CI_SUSP_ORAL_PREZ_REQUESTED
				, TRG.CI_SUSP_ORAL_PREZ_DT
				, TRG.CI_SUSP_WRITTEN_RESP
				, TRG.CI_SUSP_WRITTEN_RESP_DUE_DT
				, TRG.CI_SUSP_WRITTEN_RESP_DT
				, TRG.CI_SUSP_FINAL_AGNCY_DCSN
				, TRG.CI_SUSP_DECIDING_OFFCL_NAME
				, TRG.CI_SUSP_DECISION_ISSUED_DT
				, TRG.CI_SUSP_EFFECTIVE_DECISION_DT
				, TRG.CI_SUS_NUMB_DAYS
				, TRG.CI_REPRIMAND_ISSUE_DT
				, TRG.CI_EMP_APPEAL_DECISION               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.CI_ACTION_TYPE
                , SRC.CI_ADMIN_INVESTIGATORY_LEAVE
                , SRC.CI_ADMIN_NOTICE_LEAVE				
				, SRC.CI_LEAVE_START_DT
				, SRC.CI_LEAVE_END_DT
				, SRC.CI_APPROVAL_NAME
				, SRC.CI_LEAVE_START_DT_2
				, SRC.CI_LEAVE_END_DT_2
				, SRC.CI_APPROVAL_NAME_2
				, SRC.CI_PROP_ACTION_ISSUED_DT
				, SRC.CI_ORAL_PREZ_REQUESTED
				, SRC.CI_ORAL_PREZ_DT
				, SRC.CI_ORAL_RESPONSE_SUBMITTED
				, SRC.CI_RESPONSE_DUE_DT
				, SRC.CI_WRITTEN_RESPONSE_SBMT_DT
				, SRC.CI_POS_TITLE
				, SRC.CI_PPLAN
				, SRC.CI_SERIES
				, SRC.CI_CURRENT_INFO_GRADE
				, SRC.CI_CURRENT_INFO_STEP
				, SRC.CI_PROPOSED_POS_TITLE
				, SRC.CI_PROPOSED_PPLAN
				, SRC.CI_PROPOSED_SERIES
				, SRC.CI_PROPOSED_INFO_GRADE
				, SRC.CI_PROPOSED_INFO_STEP
				, SRC.CI_FINAL_POS_TITLE
				, SRC.CI_FINAL_PPLAN
				, SRC.CI_FINAL_SERIES
				, SRC.CI_FINAL_INFO_GRADE
				, SRC.CI_FINAL_INFO_STEP
				, SRC.CI_DEMO_FINAL_AGNCY_DCSN
				, SRC.CI_DECIDING_OFFCL
				, SRC.CI_DECISION_ISSUED_DT
				, SRC.CI_DEMO_FINAL_AGENCY_EFF_DT
				, SRC.CI_NUMB_DAYS
				, SRC.CI_COUNSEL_TYPE
				, SRC.CI_COUNSEL_ISSUED_DT
				, SRC.CI_SICK_LEAVE_ISSUED_DT
				, SRC.CI_RESTRICTION_ISSED_DT
				, SRC.CI_SL_REVIEWED_DT_LIST
				, SRC.CI_SL_WARNING_DISCUSS_DT_LIST
				, SRC.CI_SL_WARN_ISSUE
				, SRC.CI_NOTICE_ISSUED_DT
				, SRC.CI_EFFECTIVE_DT
				, SRC.CI_CURRENT_ADMIN_CODE
				, SRC.CI_RE_ASSIGNMENT_CURR_ORG
				, SRC.CI_FINAL_ADMIN_CODE
				, SRC.CI_RE_ASSIGNMENT_FINAL_ORG
				, SRC.CI_REMOVAL_PROP_ACTION_DT
				, SRC.CI_EMP_NOTICE_LEAVE_PLACED
				, SRC.CI_REMOVAL_NOTICE_START_DT
				, SRC.CI_REMOVAL_NOTICE_END_DT
				, SRC.CI_RMVL_ORAL_PREZ_RQSTED
				, SRC.CI_REMOVAL_ORAL_PREZ_DT
				, SRC.CI_RMVL_WRTN_RESPONSE
				, SRC.CI_WRITTEN_RESPONSE_DUE_DT
				, SRC.CI_WRITTEN_SUBMITTED_DT
				, SRC.CI_RMVL_FINAL_AGNCY_DCSN
				, SRC.CI_DECIDING_OFFCL_NAME
				, SRC.CI_RMVL_DATE_DCSN_ISSUED
				, SRC.CI_REMOVAL_EFFECTIVE_DT
				, SRC.CI_RMVL_NUMB_DAYS
				, SRC.CI_SUSPENTION_TYPE
				, SRC.CI_SUSP_PROP_ACTION_DT
				, SRC.CI_SUSP_ORAL_PREZ_REQUESTED
				, SRC.CI_SUSP_ORAL_PREZ_DT
				, SRC.CI_SUSP_WRITTEN_RESP
				, SRC.CI_SUSP_WRITTEN_RESP_DUE_DT
				, SRC.CI_SUSP_WRITTEN_RESP_DT
				, SRC.CI_SUSP_FINAL_AGNCY_DCSN
				, SRC.CI_SUSP_DECIDING_OFFCL_NAME
				, SRC.CI_SUSP_DECISION_ISSUED_DT
				, SRC.CI_SUSP_EFFECTIVE_DECISION_DT
				, SRC.CI_SUS_NUMB_DAYS
				, SRC.CI_REPRIMAND_ISSUE_DT
				, SRC.CI_EMP_APPEAL_DECISION               
            );

		END;

        --------------------------------
		-- ERLR_PERF_ISSUE table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_PERF_ISSUE TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
                    , X.PI_ACTION_TYPE
					, TO_DATE(X.PI_NEXT_WGI_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_NEXT_WGI_DUE_DT	
					, TO_DATE(X.PI_PERF_COUNSEL_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PERF_COUNSEL_ISSUE_DT	
					, X.PI_CNSL_GRV_DECISION
					, TO_DATE(X.PI_DMTN_PRPS_ACTN_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_PRPS_ACTN_ISSUE_DT	
					, X.PI_DMTN_ORAL_PRSNT_REQ
					, TO_DATE(X.PI_DMTN_ORAL_PRSNT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_ORAL_PRSNT_DT	
					, X.PI_DMTN_WRTN_RESP_SBMT
					, TO_DATE(X.PI_DMTN_WRTN_RESP_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_WRTN_RESP_DUE_DT	
					, TO_DATE(X.PI_DMTN_WRTN_RESP_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_WRTN_RESP_SBMT_DT	
					, X.PI_DMTN_CUR_POS_TITLE
					, X.PI_DMTN_CUR_PAY_PLAN
					, X.PI_DMTN_CUR_JOB_SERIES
					, X.PI_DMTN_CUR_GRADE
					, X.PI_DMTN_CUR_STEP
					, X.PI_DMTN_PRPS_POS_TITLE
					, X.PI_DMTN_PRPS_PAY_PLAN
					, X.PI_DMTN_PRPS_JOB_SERIES
					, X.PI_DMTN_PRPS_GRADE
					, X.PI_DMTN_PRP_STEP
					, X.PI_DMTN_FIN_POS_TITLE
					, X.PI_DMTN_FIN_PAY_PLAN
					, X.PI_DMTN_FIN_JOB_SERIES
					, X.PI_DMTN_FIN_GRADE
					, X.PI_DMTN_FIN_STEP
					, X.PI_DMTN_FIN_AGCY_DECISION
					, X.PI_DMTN_FIN_DECIDING_OFC
					, TO_DATE(X.PI_DMTN_FIN_DECISION_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_FIN_DECISION_ISSUE_DT	
					, TO_DATE(X.PI_DMTN_DECISION_EFF_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_DMTN_DECISION_EFF_DT	
					, X.PI_DMTN_APPEAL_DECISION
					, X.PI_PIP_RSNBL_ACMDTN
					, X.PI_PIP_EMPL_SBMT_MEDDOC
					, X.PI_PIP_DOC_SBMT_FOH_RVW
					, X.PI_PIP_WGI_WTHLD
					, TO_DATE(X.PI_PIP_WGI_RVW_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_WGI_RVW_DT	
					, X.PI_PIP_MEDDOC_RVW_OUTCOME
					, TO_DATE(X.PI_PIP_START_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_START_DT
					, TO_DATE(X.PI_PIP_END_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_END_DT	
					, TO_DATE(X.PI_PIP_EXT_END_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_EXT_END_DT	
					, X.PI_PIP_EXT_END_REASON
					, TO_DATE(X.PI_PIP_EXT_END_NOTIFY_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_EXT_END_NOTIFY_DT	
					, X.PI_PIP_EXT_DT_LIST	
					, TO_DATE(X.PI_PIP_ACTUAL_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_ACTUAL_DT	
					, X.PI_PIP_END_PRIOR_TO_PLAN
					, X.PI_PIP_END_PRIOR_TO_PLAN_RSN
					, X.PI_PIP_SUCCESS_CMPLT
					, TO_DATE(X.PI_PIP_PMAP_RTNG_SIGN_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_PMAP_RTNG_SIGN_DT	
					, TO_DATE(X.PI_PIP_PMAP_RVW_SIGN_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_PMAP_RVW_SIGN_DT	
					, X.PI_PIP_PRPS_ACTN	
					, TO_DATE(X.PI_PIP_PRPS_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_PRPS_ISSUE_DT	
					, X.PI_PIP_ORAL_PRSNT_REQ	
					, TO_DATE(X.PI_PIP_ORAL_PRSNT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_ORAL_PRSNT_DT	
					, X.PI_PIP_WRTN_RESP_SBMT	
					, TO_DATE(X.PI_PIP_WRTN_RESP_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_WRTN_RESP_DUE_DT	
					, TO_DATE(X.PI_PIP_WRTN_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_WRTN_SBMT_DT	
					, X.PI_PIP_FIN_AGCY_DECISION
					, X.PI_PIP_DECIDING_OFFICAL
					, TO_DATE(X.PI_PIP_FIN_AGCY_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_FIN_AGCY_DECISION_DT	
					, TO_DATE(X.PI_PIP_DECISION_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_DECISION_ISSUE_DT	
					, TO_DATE(X.PI_PIP_EFF_ACTN_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_PIP_EFF_ACTN_DT	
					, X.PI_PIP_EMPL_GRIEVANCE	
					, X.PI_PIP_APPEAL_DECISION
					, TO_DATE(X.PI_REASGN_NOTICE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_REASGN_NOTICE_DT	
					, TO_DATE(X.PI_REASGN_EFF_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_REASGN_EFF_DT	
					, X.PI_REASGN_CUR_ADMIN_CD
					, X.PI_REASGN_CUR_ORG_NM	
					, X.PI_REASGN_FIN_ADMIN_CD
					, X.PI_REASGN_FIN_ORG_NM	
					, TO_DATE(X.PI_RMV_PRPS_ACTN_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_PRPS_ACTN_ISSUE_DT	
					, X.PI_RMV_EMPL_NOTC_LEV	
					, TO_DATE(X.PI_RMV_NOTC_LEV_START_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_NOTC_LEV_START_DT	
					, TO_DATE(X.PI_RMV_NOTC_LEV_END_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_NOTC_LEV_END_DT	
					, X.PI_RMV_ORAL_PRSNT_REQ	
					, TO_DATE(X.PI_RMV_ORAL_PRSNT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_ORAL_PRSNT_DT	
					, TO_DATE(X.PI_RMV_WRTN_RESP_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_WRTN_RESP_DUE_DT	
					, TO_DATE(X.PI_RMV_WRTN_RESP_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_WRTN_RESP_SBMT_DT	
					, X.PI_RMV_FIN_AGCY_DECISION	
					, X.PI_RMV_FIN_DECIDING_OFC	
					, TO_DATE(X.PI_RMV_DECISION_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_DECISION_ISSUE_DT	
					, TO_DATE(X.PI_RMV_EFF_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_RMV_EFF_DT	
					, X.PI_RMV_NUM_DAYS	
					, X.PI_RMV_APPEAL_DECISION	
					, X.PI_WRTN_NRTV_RVW_TYPE	
					, TO_DATE(X.PI_WNR_SPCLST_RVW_CMPLT_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_WNR_SPCLST_RVW_CMPLT_DT	
					, TO_DATE(X.PI_WNR_MGR_RVW_RTNG_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_WNR_MGR_RVW_RTNG_DT	
					, X.PI_WNR_CRITICAL_ELM	
					, X.PI_WNR_FIN_RATING
					, TO_DATE(X.PI_WNR_RVW_OFC_CONCUR_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_WNR_RVW_OFC_CONCUR_DT	
					, X.PI_WNR_WGI_WTHLD
					, TO_DATE(X.PI_WNR_WGI_RVW_DT,'MM/DD/YYYY HH24:MI:SS') AS PI_WNR_WGI_RVW_DT	
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            PI_ACTION_TYPE	NUMBER(20,0)	PATH './item[id="PI_ACTION_TYPE"]/value'
							, PI_NEXT_WGI_DUE_DT	VARCHAR2(10)	PATH './item[id="PI_NEXT_WGI_DUE_DT"]/value'
							, PI_PERF_COUNSEL_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_PERF_COUNSEL_ISSUE_DT"]/value'
							, PI_CNSL_GRV_DECISION	VARCHAR2(3)	PATH './item[id="PI_CNSL_GRV_DECISION"]/value'
							, PI_DMTN_PRPS_ACTN_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_PRPS_ACTN_ISSUE_DT"]/value'
							, PI_DMTN_ORAL_PRSNT_REQ	VARCHAR2(3)	PATH './item[id="PI_DMTN_ORAL_PRSNT_REQ"]/value'
							, PI_DMTN_ORAL_PRSNT_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_ORAL_PRSNT_DT"]/value'
							, PI_DMTN_WRTN_RESP_SBMT	VARCHAR2(3)	PATH './item[id="PI_DMTN_WRTN_RESP_SBMT"]/value'
							, PI_DMTN_WRTN_RESP_DUE_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_WRTN_RESP_DUE_DT"]/value'
							, PI_DMTN_WRTN_RESP_SBMT_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_WRTN_RESP_SBMT_DT"]/value'
							, PI_DMTN_CUR_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_CUR_POS_TITLE"]/value'
							, PI_DMTN_CUR_PAY_PLAN	NVARCHAR2(50)	PATH './item[id="PI_DMTN_CUR_PAY_PLAN"]/value'
							, PI_DMTN_CUR_JOB_SERIES	NVARCHAR2(50)	PATH './item[id="PI_DMTN_CUR_JOB_SERIES"]/value'
							, PI_DMTN_CUR_GRADE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_CUR_GRADE"]/value'
							, PI_DMTN_CUR_STEP	NVARCHAR2(50)	PATH './item[id="PI_DMTN_CUR_STEP"]/value'
							, PI_DMTN_PRPS_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_PRPS_POS_TITLE"]/value'
							, PI_DMTN_PRPS_PAY_PLAN	NVARCHAR2(50)	PATH './item[id="PI_DMTN_PRPS_PAY_PLAN"]/value'
							, PI_DMTN_PRPS_JOB_SERIES	NVARCHAR2(50)	PATH './item[id="PI_DMTN_PRPS_JOB_SERIES"]/value'
							, PI_DMTN_PRPS_GRADE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_PRPS_GRADE"]/value'
							, PI_DMTN_PRP_STEP	NVARCHAR2(50)	PATH './item[id="PI_DMTN_PRP_STEP"]/value'
							, PI_DMTN_FIN_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_FIN_POS_TITLE"]/value'
							, PI_DMTN_FIN_PAY_PLAN	NVARCHAR2(50)	PATH './item[id="PI_DMTN_FIN_PAY_PLAN"]/value'
							, PI_DMTN_FIN_JOB_SERIES	NVARCHAR2(50)	PATH './item[id="PI_DMTN_FIN_JOB_SERIES"]/value'
							, PI_DMTN_FIN_GRADE	NVARCHAR2(50)	PATH './item[id="PI_DMTN_FIN_GRADE"]/value'
							, PI_DMTN_FIN_STEP	NVARCHAR2(50)	PATH './item[id="PI_DMTN_FIN_STEP"]/value'
							, PI_DMTN_FIN_AGCY_DECISION	NUMBER(20,0)	PATH './item[id="PI_DMTN_FIN_AGCY_DECISION"]/value'
							, PI_DMTN_FIN_DECIDING_OFC NVARCHAR2(255)	PATH './item[id="PI_DMTN_FIN_DECIDING_OFC_NM"]/value/name'
							, PI_DMTN_FIN_DECISION_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_FIN_DECISION_ISSUE_DT"]/value'
							, PI_DMTN_DECISION_EFF_DT	VARCHAR2(10)	PATH './item[id="PI_DMTN_DECISION_EFF_DT"]/value'
							, PI_DMTN_APPEAL_DECISION	VARCHAR2(3)	PATH './item[id="PI_DMTN_APPEAL_DECISION"]/value'
							, PI_PIP_RSNBL_ACMDTN	VARCHAR2(3)	PATH './item[id="PI_PIP_RSNBL_ACMDTN"]/value'
							, PI_PIP_EMPL_SBMT_MEDDOC	VARCHAR2(3)	PATH './item[id="PI_PIP_EMPL_SBMT_MEDDOC"]/value'
							, PI_PIP_DOC_SBMT_FOH_RVW	VARCHAR2(3)	PATH './item[id="PI_PIP_DOC_SBMT_FOH_RVW"]/value'
							, PI_PIP_WGI_WTHLD	VARCHAR2(3)	PATH './item[id="PI_PIP_WGI_WTHLD"]/value'
							, PI_PIP_WGI_RVW_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_WGI_RVW_DT"]/value'
							, PI_PIP_MEDDOC_RVW_OUTCOME	NVARCHAR2(140)	PATH './item[id="PI_PIP_MEDDOC_RVW_OUTCOME"]/value'
							, PI_PIP_START_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_START_DT"]/value'
							, PI_PIP_END_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_END_DT"]/value'
							, PI_PIP_EXT_END_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_EXT_END_DT"]/value'
							, PI_PIP_EXT_END_REASON	NVARCHAR2(200)	PATH './item[id="PI_PIP_EXT_END_REASON"]/value'
							, PI_PIP_EXT_END_NOTIFY_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_EXT_END_NOTIFY_DT"]/value'
							, PI_PIP_EXT_DT_LIST	VARCHAR2(4000)	PATH './item[id="PI_PIP_EXT_DT_LIST"]/value'
							, PI_PIP_ACTUAL_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_ACTUAL_DT"]/value'
							, PI_PIP_END_PRIOR_TO_PLAN	VARCHAR2(3)	PATH './item[id="PI_PIP_END_PRIOR_TO_PLAN"]/value'
							, PI_PIP_END_PRIOR_TO_PLAN_RSN	NUMBER(20,0)	PATH './item[id="PI_PIP_END_PRIOR_TO_PLAN_RSN"]/value'
							, PI_PIP_SUCCESS_CMPLT	VARCHAR2(3)	PATH './item[id="PI_PIP_SUCCESS_CMPLT"]/value'
							, PI_PIP_PMAP_RTNG_SIGN_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_PMAP_RTNG_SIGN_DT"]/value'
							, PI_PIP_PMAP_RVW_SIGN_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_PMAP_RVW_SIGN_DT"]/value'
							, PI_PIP_PRPS_ACTN	NUMBER(20,0)	PATH './item[id="PI_PIP_PRPS_ACTN"]/value'
							, PI_PIP_PRPS_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_PRPS_ISSUE_DT"]/value'
							, PI_PIP_ORAL_PRSNT_REQ	VARCHAR2(3)	PATH './item[id="PI_PIP_ORAL_PRSNT_REQ"]/value'
							, PI_PIP_ORAL_PRSNT_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_ORAL_PRSNT_DT"]/value'
							, PI_PIP_WRTN_RESP_SBMT	VARCHAR2(3)	PATH './item[id="PI_PIP_WRTN_RESP_SBMT"]/value'
							, PI_PIP_WRTN_RESP_DUE_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_WRTN_RESP_DUE_DT"]/value'
							, PI_PIP_WRTN_SBMT_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_WRTN_SBMT_DT"]/value'
							, PI_PIP_FIN_AGCY_DECISION	NUMBER(20,0)	PATH './item[id="PI_PIP_FIN_AGCY_DECISION"]/value'
							, PI_PIP_DECIDING_OFFICAL	NVARCHAR2(255)	PATH './item[id="PI_PIP_DECIDING_OFFICAL_NM"]/value/name'
							, PI_PIP_FIN_AGCY_DECISION_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_FIN_AGCY_DECISION_DT"]/value'
							, PI_PIP_DECISION_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_DECISION_ISSUE_DT"]/value'
							, PI_PIP_EFF_ACTN_DT	VARCHAR2(10)	PATH './item[id="PI_PIP_EFF_ACTN_DT"]/value'
							, PI_PIP_EMPL_GRIEVANCE	VARCHAR2(3)	PATH './item[id="PI_PIP_EMPL_GRIEVANCE"]/value'
							, PI_PIP_APPEAL_DECISION	VARCHAR2(3)	PATH './item[id="PI_PIP_APPEAL_DECISION"]/value'
							, PI_REASGN_NOTICE_DT	VARCHAR2(10)	PATH './item[id="PI_REASGN_NOTICE_DT"]/value'
							, PI_REASGN_EFF_DT	VARCHAR2(10)	PATH './item[id="PI_REASGN_EFF_DT"]/value'
							, PI_REASGN_CUR_ADMIN_CD	NVARCHAR2(8)	PATH './item[id="PI_REASGN_CUR_ADMIN_CD"]/value'
							, PI_REASGN_CUR_ORG_NM	NVARCHAR2(50)	PATH './item[id="PI_REASGN_CUR_ORG_NM"]/value'
							, PI_REASGN_FIN_ADMIN_CD	NVARCHAR2(8)	PATH './item[id="PI_REASGN_FIN_ADMIN_CD"]/value'
							, PI_REASGN_FIN_ORG_NM	NVARCHAR2(50)	PATH './item[id="PI_REASGN_FIN_ORG_NM"]/value'
							, PI_RMV_PRPS_ACTN_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_PRPS_ACTN_ISSUE_DT"]/value'
							, PI_RMV_EMPL_NOTC_LEV	VARCHAR2(3)	PATH './item[id="PI_RMV_EMPL_NOTC_LEV"]/value'
							, PI_RMV_NOTC_LEV_START_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_NOTC_LEV_START_DT"]/value'
							, PI_RMV_NOTC_LEV_END_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_NOTC_LEV_END_DT"]/value'
							, PI_RMV_ORAL_PRSNT_REQ	VARCHAR2(3)	PATH './item[id="PI_RMV_ORAL_PRSNT_REQ"]/value'
							, PI_RMV_ORAL_PRSNT_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_ORAL_PRSNT_DT"]/value'
							, PI_RMV_WRTN_RESP_DUE_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_WRTN_RESP_DUE_DT"]/value'
							, PI_RMV_WRTN_RESP_SBMT_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_WRTN_RESP_SBMT_DT"]/value'
							, PI_RMV_FIN_AGCY_DECISION	NUMBER(20,0)	PATH './item[id="PI_RMV_FIN_AGCY_DECISION"]/value'
							, PI_RMV_FIN_DECIDING_OFC	NVARCHAR2(255)	PATH './item[id="PI_RMV_FIN_DECIDING_OFC_NM"]/value/name'
							, PI_RMV_DECISION_ISSUE_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_DECISION_ISSUE_DT"]/value'
							, PI_RMV_EFF_DT	VARCHAR2(10)	PATH './item[id="PI_RMV_EFF_DT"]/value'
							, PI_RMV_NUM_DAYS	NUMBER(20,0)	PATH './item[id="PI_RMV_NUM_DAYS"]/value'
							, PI_RMV_APPEAL_DECISION	VARCHAR2(3)	PATH './item[id="PI_RMV_APPEAL_DECISION"]/value'
							, PI_WRTN_NRTV_RVW_TYPE	NUMBER(20,0)	PATH './item[id="PI_WRTN_NRTV_RVW_TYPE"]/value'
							, PI_WNR_SPCLST_RVW_CMPLT_DT	VARCHAR2(10)	PATH './item[id="PI_WNR_SPCLST_RVW_CMPLT_DT"]/value'
							, PI_WNR_MGR_RVW_RTNG_DT VARCHAR2(10)	PATH './item[id="PI_WNR_MGR_RVW_RTNG_DT"]/value'
							, PI_WNR_CRITICAL_ELM	NVARCHAR2(250)	PATH './item[id="PI_WNR_CRITICAL_ELM"]/value'
							, PI_WNR_FIN_RATING	NVARCHAR2(200)	PATH './item[id="PI_WNR_FIN_RATING"]/value'
							, PI_WNR_RVW_OFC_CONCUR_DT	VARCHAR2(10)	PATH './item[id="PI_WNR_RVW_OFC_CONCUR_DT"]/value'
							, PI_WNR_WGI_WTHLD	VARCHAR2(3)	PATH './item[id="PI_WNR_WGI_WTHLD"]/value'
							, PI_WNR_WGI_RVW_DT	VARCHAR2(10)	PATH './item[id="PI_WNR_WGI_RVW_DT"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
				TRG.PI_ACTION_TYPE = SRC.PI_ACTION_TYPE
				, TRG.PI_NEXT_WGI_DUE_DT = SRC.PI_NEXT_WGI_DUE_DT 	
				, TRG.PI_PERF_COUNSEL_ISSUE_DT	= SRC.PI_PERF_COUNSEL_ISSUE_DT
				, TRG.PI_CNSL_GRV_DECISION = SRC.PI_CNSL_GRV_DECISION
				, TRG.PI_DMTN_PRPS_ACTN_ISSUE_DT = SRC.PI_DMTN_PRPS_ACTN_ISSUE_DT	
				, TRG.PI_DMTN_ORAL_PRSNT_REQ = SRC.PI_DMTN_ORAL_PRSNT_REQ
				, TRG.PI_DMTN_ORAL_PRSNT_DT	= SRC.PI_DMTN_ORAL_PRSNT_DT
				, TRG.PI_DMTN_WRTN_RESP_SBMT = SRC.PI_DMTN_WRTN_RESP_SBMT
				, TRG.PI_DMTN_WRTN_RESP_DUE_DT	= SRC.PI_DMTN_WRTN_RESP_DUE_DT
				, TRG.PI_DMTN_WRTN_RESP_SBMT_DT	= SRC.PI_DMTN_WRTN_RESP_SBMT_DT
				, TRG.PI_DMTN_CUR_POS_TITLE = SRC.PI_DMTN_CUR_POS_TITLE
				, TRG.PI_DMTN_CUR_PAY_PLAN = SRC.PI_DMTN_CUR_PAY_PLAN
				, TRG.PI_DMTN_CUR_JOB_SERIES = SRC.PI_DMTN_CUR_JOB_SERIES
				, TRG.PI_DMTN_CUR_GRADE = SRC.PI_DMTN_CUR_GRADE
				, TRG.PI_DMTN_CUR_STEP = SRC.PI_DMTN_CUR_STEP
				, TRG.PI_DMTN_PRPS_POS_TITLE = SRC.PI_DMTN_PRPS_POS_TITLE
				, TRG.PI_DMTN_PRPS_PAY_PLAN = SRC.PI_DMTN_PRPS_PAY_PLAN
				, TRG.PI_DMTN_PRPS_JOB_SERIES = SRC.PI_DMTN_PRPS_JOB_SERIES
				, TRG.PI_DMTN_PRPS_GRADE = SRC.PI_DMTN_PRPS_GRADE
				, TRG.PI_DMTN_PRP_STEP = SRC.PI_DMTN_PRP_STEP
				, TRG.PI_DMTN_FIN_POS_TITLE = SRC.PI_DMTN_FIN_POS_TITLE
				, TRG.PI_DMTN_FIN_PAY_PLAN = SRC.PI_DMTN_FIN_PAY_PLAN
				, TRG.PI_DMTN_FIN_JOB_SERIES = SRC.PI_DMTN_FIN_JOB_SERIES
				, TRG.PI_DMTN_FIN_GRADE = SRC.PI_DMTN_FIN_GRADE
				, TRG.PI_DMTN_FIN_STEP = SRC.PI_DMTN_FIN_STEP
				, TRG.PI_DMTN_FIN_AGCY_DECISION = SRC.PI_DMTN_FIN_AGCY_DECISION
				, TRG.PI_DMTN_FIN_DECIDING_OFC = SRC.PI_DMTN_FIN_DECIDING_OFC
				, TRG.PI_DMTN_FIN_DECISION_ISSUE_DT = SRC.PI_DMTN_FIN_DECISION_ISSUE_DT		
				, TRG.PI_DMTN_DECISION_EFF_DT = SRC.PI_DMTN_DECISION_EFF_DT	
				, TRG.PI_DMTN_APPEAL_DECISION = SRC.PI_DMTN_APPEAL_DECISION
				, TRG.PI_PIP_RSNBL_ACMDTN = SRC.PI_PIP_RSNBL_ACMDTN
				, TRG.PI_PIP_EMPL_SBMT_MEDDOC = SRC.PI_PIP_EMPL_SBMT_MEDDOC
				, TRG.PI_PIP_DOC_SBMT_FOH_RVW = SRC.PI_PIP_DOC_SBMT_FOH_RVW
				, TRG.PI_PIP_WGI_WTHLD = SRC.PI_PIP_WGI_WTHLD
				, TRG.PI_PIP_WGI_RVW_DT	= SRC.PI_PIP_WGI_RVW_DT
				, TRG.PI_PIP_MEDDOC_RVW_OUTCOME = SRC.PI_PIP_MEDDOC_RVW_OUTCOME
				, TRG.PI_PIP_START_DT = SRC.PI_PIP_START_DT	
				, TRG.PI_PIP_END_DT = SRC.PI_PIP_END_DT	
				, TRG.PI_PIP_EXT_END_DT = SRC.PI_PIP_EXT_END_DT	
				, TRG.PI_PIP_EXT_END_REASON = SRC.PI_PIP_EXT_END_REASON				 
				, TRG.PI_PIP_EXT_END_NOTIFY_DT = SRC.PI_PIP_EXT_END_NOTIFY_DT	
				, TRG.PI_PIP_EXT_DT_LIST = SRC.PI_PIP_EXT_DT_LIST	
				, TRG.PI_PIP_ACTUAL_DT = SRC.PI_PIP_ACTUAL_DT	
				, TRG.PI_PIP_END_PRIOR_TO_PLAN = SRC.PI_PIP_END_PRIOR_TO_PLAN
				, TRG.PI_PIP_END_PRIOR_TO_PLAN_RSN = SRC.PI_PIP_END_PRIOR_TO_PLAN_RSN
				, TRG.PI_PIP_SUCCESS_CMPLT = SRC.PI_PIP_SUCCESS_CMPLT
				, TRG.PI_PIP_PMAP_RTNG_SIGN_DT = SRC.PI_PIP_PMAP_RTNG_SIGN_DT	
				, TRG.PI_PIP_PMAP_RVW_SIGN_DT = SRC.PI_PIP_PMAP_RVW_SIGN_DT	
				, TRG.PI_PIP_PRPS_ACTN = SRC.PI_PIP_PRPS_ACTN	
				, TRG.PI_PIP_PRPS_ISSUE_DT = SRC.PI_PIP_PRPS_ISSUE_DT	
				, TRG.PI_PIP_ORAL_PRSNT_REQ	= SRC.PI_PIP_ORAL_PRSNT_REQ
				, TRG.PI_PIP_ORAL_PRSNT_DT = SRC.PI_PIP_ORAL_PRSNT_DT	
				, TRG.PI_PIP_WRTN_RESP_SBMT = SRC.PI_PIP_WRTN_RESP_SBMT	
				, TRG.PI_PIP_WRTN_RESP_DUE_DT = SRC.PI_PIP_WRTN_RESP_DUE_DT	
				, TRG.PI_PIP_WRTN_SBMT_DT = SRC.PI_PIP_WRTN_SBMT_DT	
				, TRG.PI_PIP_FIN_AGCY_DECISION = SRC.PI_PIP_FIN_AGCY_DECISION
				, TRG.PI_PIP_DECIDING_OFFICAL = SRC.PI_PIP_DECIDING_OFFICAL
				, TRG.PI_PIP_FIN_AGCY_DECISION_DT = SRC.PI_PIP_FIN_AGCY_DECISION_DT	
				, TRG.PI_PIP_DECISION_ISSUE_DT = SRC.PI_PIP_DECISION_ISSUE_DT	
				, TRG.PI_PIP_EFF_ACTN_DT = SRC.PI_PIP_EFF_ACTN_DT	
				, TRG.PI_PIP_EMPL_GRIEVANCE = SRC.PI_PIP_EMPL_GRIEVANCE	
				, TRG.PI_PIP_APPEAL_DECISION = SRC.PI_PIP_APPEAL_DECISION
				, TRG.PI_REASGN_NOTICE_DT = SRC.PI_REASGN_NOTICE_DT	
				, TRG.PI_REASGN_EFF_DT = SRC.PI_REASGN_EFF_DT	
				, TRG.PI_REASGN_CUR_ADMIN_CD = SRC.PI_REASGN_CUR_ADMIN_CD
				, TRG.PI_REASGN_CUR_ORG_NM = SRC.PI_REASGN_CUR_ORG_NM	
				, TRG.PI_REASGN_FIN_ADMIN_CD = SRC.PI_REASGN_FIN_ADMIN_CD
				, TRG.PI_REASGN_FIN_ORG_NM = SRC.PI_REASGN_FIN_ORG_NM	
				, TRG.PI_RMV_PRPS_ACTN_ISSUE_DT	= SRC.PI_RMV_PRPS_ACTN_ISSUE_DT
				, TRG.PI_RMV_EMPL_NOTC_LEV	= SRC.PI_RMV_EMPL_NOTC_LEV
				, TRG.PI_RMV_NOTC_LEV_START_DT = SRC.PI_RMV_NOTC_LEV_START_DT	
				, TRG.PI_RMV_NOTC_LEV_END_DT = SRC.PI_RMV_NOTC_LEV_END_DT	
				, TRG.PI_RMV_ORAL_PRSNT_REQ	= SRC.PI_RMV_ORAL_PRSNT_REQ
				, TRG.PI_RMV_ORAL_PRSNT_DT	= SRC.PI_RMV_ORAL_PRSNT_DT
				, TRG.PI_RMV_WRTN_RESP_DUE_DT	= SRC.PI_RMV_WRTN_RESP_DUE_DT
				, TRG.PI_RMV_WRTN_RESP_SBMT_DT	= SRC.PI_RMV_WRTN_RESP_SBMT_DT
				, TRG.PI_RMV_FIN_AGCY_DECISION	= SRC.PI_RMV_FIN_AGCY_DECISION
				, TRG.PI_RMV_FIN_DECIDING_OFC	= SRC.PI_RMV_FIN_DECIDING_OFC
				, TRG.PI_RMV_DECISION_ISSUE_DT	= SRC.PI_RMV_DECISION_ISSUE_DT
				, TRG.PI_RMV_EFF_DT	= SRC.PI_RMV_EFF_DT
				, TRG.PI_RMV_NUM_DAYS	= SRC.PI_RMV_NUM_DAYS
				, TRG.PI_RMV_APPEAL_DECISION = SRC.PI_RMV_APPEAL_DECISION	
				, TRG.PI_WRTN_NRTV_RVW_TYPE	= SRC.PI_WRTN_NRTV_RVW_TYPE
				, TRG.PI_WNR_SPCLST_RVW_CMPLT_DT = SRC.PI_WNR_SPCLST_RVW_CMPLT_DT	
				, TRG.PI_WNR_MGR_RVW_RTNG_DT	= SRC.PI_WNR_MGR_RVW_RTNG_DT
				, TRG.PI_WNR_CRITICAL_ELM	= SRC.PI_WNR_CRITICAL_ELM
				, TRG.PI_WNR_FIN_RATING = SRC.PI_WNR_FIN_RATING
				, TRG.PI_WNR_RVW_OFC_CONCUR_DT	= SRC.PI_WNR_RVW_OFC_CONCUR_DT
				, TRG.PI_WNR_WGI_WTHLD = SRC.PI_WNR_WGI_WTHLD
				, TRG.PI_WNR_WGI_RVW_DT	= SRC.PI_WNR_WGI_RVW_DT
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.PI_ACTION_TYPE
				, TRG.PI_NEXT_WGI_DUE_DT	
				, TRG.PI_PERF_COUNSEL_ISSUE_DT	
				, TRG.PI_CNSL_GRV_DECISION
				, TRG.PI_DMTN_PRPS_ACTN_ISSUE_DT	
				, TRG.PI_DMTN_ORAL_PRSNT_REQ
				, TRG.PI_DMTN_ORAL_PRSNT_DT	
				, TRG.PI_DMTN_WRTN_RESP_SBMT
				, TRG.PI_DMTN_WRTN_RESP_DUE_DT	
				, TRG.PI_DMTN_WRTN_RESP_SBMT_DT	
				, TRG.PI_DMTN_CUR_POS_TITLE
				, TRG.PI_DMTN_CUR_PAY_PLAN
				, TRG.PI_DMTN_CUR_JOB_SERIES
				, TRG.PI_DMTN_CUR_GRADE
				, TRG.PI_DMTN_CUR_STEP
				, TRG.PI_DMTN_PRPS_POS_TITLE
				, TRG.PI_DMTN_PRPS_PAY_PLAN
				, TRG.PI_DMTN_PRPS_JOB_SERIES
				, TRG.PI_DMTN_PRPS_GRADE
				, TRG.PI_DMTN_PRP_STEP
				, TRG.PI_DMTN_FIN_POS_TITLE
				, TRG.PI_DMTN_FIN_PAY_PLAN
				, TRG.PI_DMTN_FIN_JOB_SERIES
				, TRG.PI_DMTN_FIN_GRADE
				, TRG.PI_DMTN_FIN_STEP
				, TRG.PI_DMTN_FIN_AGCY_DECISION
				, TRG.PI_DMTN_FIN_DECIDING_OFC
				, TRG.PI_DMTN_FIN_DECISION_ISSUE_DT	
				, TRG.PI_DMTN_DECISION_EFF_DT	
				, TRG.PI_DMTN_APPEAL_DECISION
				, TRG.PI_PIP_RSNBL_ACMDTN
				, TRG.PI_PIP_EMPL_SBMT_MEDDOC
				, TRG.PI_PIP_DOC_SBMT_FOH_RVW
				, TRG.PI_PIP_WGI_WTHLD
				, TRG.PI_PIP_WGI_RVW_DT	
				, TRG.PI_PIP_MEDDOC_RVW_OUTCOME
				, TRG.PI_PIP_START_DT	
				, TRG.PI_PIP_END_DT	
				, TRG.PI_PIP_EXT_END_DT	
				, TRG.PI_PIP_EXT_END_REASON
				, TRG.PI_PIP_EXT_END_NOTIFY_DT	
				, TRG.PI_PIP_EXT_DT_LIST	
				, TRG.PI_PIP_ACTUAL_DT	
				, TRG.PI_PIP_END_PRIOR_TO_PLAN
				, TRG.PI_PIP_END_PRIOR_TO_PLAN_RSN
				, TRG.PI_PIP_SUCCESS_CMPLT
				, TRG.PI_PIP_PMAP_RTNG_SIGN_DT	
				, TRG.PI_PIP_PMAP_RVW_SIGN_DT	
				, TRG.PI_PIP_PRPS_ACTN	
				, TRG.PI_PIP_PRPS_ISSUE_DT	
				, TRG.PI_PIP_ORAL_PRSNT_REQ	
				, TRG.PI_PIP_ORAL_PRSNT_DT	
				, TRG.PI_PIP_WRTN_RESP_SBMT	
				, TRG.PI_PIP_WRTN_RESP_DUE_DT	
				, TRG.PI_PIP_WRTN_SBMT_DT	
				, TRG.PI_PIP_FIN_AGCY_DECISION
				, TRG.PI_PIP_DECIDING_OFFICAL
				, TRG.PI_PIP_FIN_AGCY_DECISION_DT	
				, TRG.PI_PIP_DECISION_ISSUE_DT	
				, TRG.PI_PIP_EFF_ACTN_DT	
				, TRG.PI_PIP_EMPL_GRIEVANCE	
				, TRG.PI_PIP_APPEAL_DECISION
				, TRG.PI_REASGN_NOTICE_DT	
				, TRG.PI_REASGN_EFF_DT	
				, TRG.PI_REASGN_CUR_ADMIN_CD
				, TRG.PI_REASGN_CUR_ORG_NM	
				, TRG.PI_REASGN_FIN_ADMIN_CD
				, TRG.PI_REASGN_FIN_ORG_NM	
				, TRG.PI_RMV_PRPS_ACTN_ISSUE_DT	
				, TRG.PI_RMV_EMPL_NOTC_LEV	
				, TRG.PI_RMV_NOTC_LEV_START_DT	
				, TRG.PI_RMV_NOTC_LEV_END_DT	
				, TRG.PI_RMV_ORAL_PRSNT_REQ	
				, TRG.PI_RMV_ORAL_PRSNT_DT	
				, TRG.PI_RMV_WRTN_RESP_DUE_DT	
				, TRG.PI_RMV_WRTN_RESP_SBMT_DT	
				, TRG.PI_RMV_FIN_AGCY_DECISION	
				, TRG.PI_RMV_FIN_DECIDING_OFC	
				, TRG.PI_RMV_DECISION_ISSUE_DT	
				, TRG.PI_RMV_EFF_DT	
				, TRG.PI_RMV_NUM_DAYS	
				, TRG.PI_RMV_APPEAL_DECISION	
				, TRG.PI_WRTN_NRTV_RVW_TYPE	
				, TRG.PI_WNR_SPCLST_RVW_CMPLT_DT	
				, TRG.PI_WNR_MGR_RVW_RTNG_DT	
				, TRG.PI_WNR_CRITICAL_ELM	
				, TRG.PI_WNR_FIN_RATING
				, TRG.PI_WNR_RVW_OFC_CONCUR_DT	
				, TRG.PI_WNR_WGI_WTHLD
				, TRG.PI_WNR_WGI_RVW_DT	               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.PI_ACTION_TYPE
				, SRC.PI_NEXT_WGI_DUE_DT	
				, SRC.PI_PERF_COUNSEL_ISSUE_DT	
				, SRC.PI_CNSL_GRV_DECISION
				, SRC.PI_DMTN_PRPS_ACTN_ISSUE_DT	
				, SRC.PI_DMTN_ORAL_PRSNT_REQ
				, SRC.PI_DMTN_ORAL_PRSNT_DT	
				, SRC.PI_DMTN_WRTN_RESP_SBMT
				, SRC.PI_DMTN_WRTN_RESP_DUE_DT	
				, SRC.PI_DMTN_WRTN_RESP_SBMT_DT	
				, SRC.PI_DMTN_CUR_POS_TITLE
				, SRC.PI_DMTN_CUR_PAY_PLAN
				, SRC.PI_DMTN_CUR_JOB_SERIES
				, SRC.PI_DMTN_CUR_GRADE
				, SRC.PI_DMTN_CUR_STEP
				, SRC.PI_DMTN_PRPS_POS_TITLE
				, SRC.PI_DMTN_PRPS_PAY_PLAN
				, SRC.PI_DMTN_PRPS_JOB_SERIES
				, SRC.PI_DMTN_PRPS_GRADE
				, SRC.PI_DMTN_PRP_STEP
				, SRC.PI_DMTN_FIN_POS_TITLE
				, SRC.PI_DMTN_FIN_PAY_PLAN
				, SRC.PI_DMTN_FIN_JOB_SERIES
				, SRC.PI_DMTN_FIN_GRADE
				, SRC.PI_DMTN_FIN_STEP
				, SRC.PI_DMTN_FIN_AGCY_DECISION
				, SRC.PI_DMTN_FIN_DECIDING_OFC
				, SRC.PI_DMTN_FIN_DECISION_ISSUE_DT	
				, SRC.PI_DMTN_DECISION_EFF_DT	
				, SRC.PI_DMTN_APPEAL_DECISION
				, SRC.PI_PIP_RSNBL_ACMDTN
				, SRC.PI_PIP_EMPL_SBMT_MEDDOC
				, SRC.PI_PIP_DOC_SBMT_FOH_RVW
				, SRC.PI_PIP_WGI_WTHLD
				, SRC.PI_PIP_WGI_RVW_DT	
				, SRC.PI_PIP_MEDDOC_RVW_OUTCOME
				, SRC.PI_PIP_START_DT	
				, SRC.PI_PIP_END_DT	
				, SRC.PI_PIP_EXT_END_DT	
				, SRC.PI_PIP_EXT_END_REASON
				, SRC.PI_PIP_EXT_END_NOTIFY_DT	
				, SRC.PI_PIP_EXT_DT_LIST	
				, SRC.PI_PIP_ACTUAL_DT	
				, SRC.PI_PIP_END_PRIOR_TO_PLAN
				, SRC.PI_PIP_END_PRIOR_TO_PLAN_RSN
				, SRC.PI_PIP_SUCCESS_CMPLT
				, SRC.PI_PIP_PMAP_RTNG_SIGN_DT	
				, SRC.PI_PIP_PMAP_RVW_SIGN_DT	
				, SRC.PI_PIP_PRPS_ACTN	
				, SRC.PI_PIP_PRPS_ISSUE_DT	
				, SRC.PI_PIP_ORAL_PRSNT_REQ	
				, SRC.PI_PIP_ORAL_PRSNT_DT	
				, SRC.PI_PIP_WRTN_RESP_SBMT	
				, SRC.PI_PIP_WRTN_RESP_DUE_DT	
				, SRC.PI_PIP_WRTN_SBMT_DT	
				, SRC.PI_PIP_FIN_AGCY_DECISION
				, SRC.PI_PIP_DECIDING_OFFICAL
				, SRC.PI_PIP_FIN_AGCY_DECISION_DT	
				, SRC.PI_PIP_DECISION_ISSUE_DT	
				, SRC.PI_PIP_EFF_ACTN_DT	
				, SRC.PI_PIP_EMPL_GRIEVANCE	
				, SRC.PI_PIP_APPEAL_DECISION
				, SRC.PI_REASGN_NOTICE_DT	
				, SRC.PI_REASGN_EFF_DT	
				, SRC.PI_REASGN_CUR_ADMIN_CD
				, SRC.PI_REASGN_CUR_ORG_NM	
				, SRC.PI_REASGN_FIN_ADMIN_CD
				, SRC.PI_REASGN_FIN_ORG_NM	
				, SRC.PI_RMV_PRPS_ACTN_ISSUE_DT	
				, SRC.PI_RMV_EMPL_NOTC_LEV	
				, SRC.PI_RMV_NOTC_LEV_START_DT	
				, SRC.PI_RMV_NOTC_LEV_END_DT	
				, SRC.PI_RMV_ORAL_PRSNT_REQ	
				, SRC.PI_RMV_ORAL_PRSNT_DT	
				, SRC.PI_RMV_WRTN_RESP_DUE_DT	
				, SRC.PI_RMV_WRTN_RESP_SBMT_DT	
				, SRC.PI_RMV_FIN_AGCY_DECISION	
				, SRC.PI_RMV_FIN_DECIDING_OFC	
				, SRC.PI_RMV_DECISION_ISSUE_DT	
				, SRC.PI_RMV_EFF_DT	
				, SRC.PI_RMV_NUM_DAYS	
				, SRC.PI_RMV_APPEAL_DECISION	
				, SRC.PI_WRTN_NRTV_RVW_TYPE	
				, SRC.PI_WNR_SPCLST_RVW_CMPLT_DT	
				, SRC.PI_WNR_MGR_RVW_RTNG_DT	
				, SRC.PI_WNR_CRITICAL_ELM	
				, SRC.PI_WNR_FIN_RATING
				, SRC.PI_WNR_RVW_OFC_CONCUR_DT	
				, SRC.PI_WNR_WGI_WTHLD
				, SRC.PI_WNR_WGI_RVW_DT	               
            );

		END;

		--------------------------------
		-- ERLR_GRIEVANCE table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_GRIEVANCE TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.GI_TYPE
					, X.GI_NEGOTIATED_GRIEVANCE_TYPE
					, X.GI_TIMELY_FILING_2
					, X.GI_IND_MANAGER
					, TO_DATE(X.GI_FILING_DT_2,'MM/DD/YYYY HH24:MI:SS') AS GI_FILING_DT_2
					, X.GI_TIMELY_FILING
					, TO_DATE(X.GI_FILING_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_FILING_DT
					, TO_DATE(X.GI_IND_MEETING_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_MEETING_DT
					, TO_DATE(X.GI_IND_STEP_1_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_STEP_1_DECISION_DT
					, TO_DATE(X.GI_IND_DECISION_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_DECISION_ISSUE_DT
					, X.GI_IND_STEP_1_DEADLINE
					, TO_DATE(X.GI_IND_STEP_1_EXT_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_STEP_1_EXT_DUE_DT
					, X.GI_IND_STEP_1_EXT_DUE_REASON
					, X.GI_STEP_2_REQUEST
					, TO_DATE(X.GI_IND_STEP_2_MTG_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_STEP_2_MTG_DT
					, TO_DATE(X.GI_IND_STEP_2_DECISION_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_STEP_2_DECISION_DUE_DT
					, TO_DATE(X.GI_IND_STEP_2_DCSN_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_STEP_2_DCSN_ISSUE_DT
					, X.GI_IND_STEP_2_DEADLINE
					, TO_DATE(X.GI_IND_EXT_2_EXT_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_EXT_2_EXT_DUE_DT
					, X.GI_IND_STEP_2_EXT_DUE_REASON
					, TO_DATE(X.GI_IND_THIRD_PARTY_APPEAL_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_IND_THIRD_PARTY_APPEAL_DT
					, X.GI_IND_THIRD_APPEAL_REQUEST
					, X.GI_UM_GRIEVABILITY
					, TO_DATE(X.GI_MEETING_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_MEETING_DT
					, X.GI_GRIEVANCE_STATUS
					, TO_DATE(X.GI_ARBITRATION_DEADLINE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_ARBITRATION_DEADLINE_DT
					, X.GI_ARBITRATION_REQUEST
					, X.GI_ADMIN_OFFCL_1
					, TO_DATE(X.GI_ADMIN_STG_1_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_ADMIN_STG_1_DECISION_DT
					, TO_DATE(X.GI_ADMIN_STG_1_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_ADMIN_STG_1_ISSUE_DT
					, X.GI_ADMIN_STG_2_RESP
					, X.GI_ADMIN_OFFCL_2
					, TO_DATE(X.GI_ADMIN_STG_2_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_ADMIN_STG_2_DECISION_DT
					, TO_DATE(X.GI_ADMIN_STG_2_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS GI_ADMIN_STG_2_ISSUE_DT
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            GI_TYPE	NVARCHAR2(200) PATH './item[id="GI_TYPE"]/value'
							, GI_NEGOTIATED_GRIEVANCE_TYPE	NVARCHAR2(200) PATH './item[id="GI_NEGOTIATED_GRIEVANCE_TYPE"]/value'
							, GI_TIMELY_FILING_2	VARCHAR2(10) PATH './item[id="GI_TIMELY_FILING_2"]/value'	
							, GI_IND_MANAGER	NVARCHAR2(255) PATH './item[id="GI_IND_MANAGER"]/value/name'
							, GI_FILING_DT_2	VARCHAR2(10) PATH './item[id="GI_FILING_DT_2"]/value'
							, GI_TIMELY_FILING	VARCHAR2(10) PATH './item[id="GI_TIMELY_FILING"]/value'
							, GI_FILING_DT	VARCHAR2(10) PATH './item[id="GI_FILING_DT"]/value'
							, GI_IND_MEETING_DT	VARCHAR2(10) PATH './item[id="GI_IND_MEETING_DT"]/value'
							, GI_IND_STEP_1_DECISION_DT	VARCHAR2(10) PATH './item[id="GI_IND_STEP_1_DECISION_DT"]/value'
							, GI_IND_DECISION_ISSUE_DT	VARCHAR2(10) PATH './item[id="GI_IND_DECISION_ISSUE_DT"]/value'
							, GI_IND_STEP_1_DEADLINE	VARCHAR2(10) PATH './item[id="GI_IND_STEP_1_DEADLINE"]/value'
							, GI_IND_STEP_1_EXT_DUE_DT	VARCHAR2(10) PATH './item[id="GI_IND_STEP_1_EXT_DUE_DT"]/value'
							, GI_IND_STEP_1_EXT_DUE_REASON	NVARCHAR2(500) PATH './item[id="GI_IND_STEP_1_EXT_DUE_REASON"]/value'
							, GI_STEP_2_REQUEST	VARCHAR2(10) PATH './item[id="GI_STEP_2_REQUEST"]/value'
							, GI_IND_STEP_2_MTG_DT	VARCHAR2(10) PATH './item[id="GI_IND_STEP_2_MTG_DT"]/value'
							, GI_IND_STEP_2_DECISION_DUE_DT	VARCHAR2(10) PATH './item[id="GI_IND_STEP_2_DECISION_DUE_DT"]/value'
							, GI_IND_STEP_2_DCSN_ISSUE_DT	VARCHAR2(10) PATH './item[id="GI_IND_STEP_2_DECISION_ISSUE_DT"]/value'
							, GI_IND_STEP_2_DEADLINE	VARCHAR2(10) PATH './item[id="GI_IND_STEP_2_DEADLINE"]/value'
							, GI_IND_EXT_2_EXT_DUE_DT	VARCHAR2(10) PATH './item[id="GI_IND_EXT_2_EXT_DUE_DT"]/value'
							, GI_IND_STEP_2_EXT_DUE_REASON	NVARCHAR2(500) PATH './item[id="GI_IND_STEP_2_EXT_DUE_REASON"]/value'
							, GI_IND_THIRD_PARTY_APPEAL_DT	VARCHAR2(10) PATH './item[id="GI_IND_THIRD_PARTY_APPEAL_DT"]/value'
							, GI_IND_THIRD_APPEAL_REQUEST	VARCHAR2(10) PATH './item[id="GI_IND_THIRD_APPEAL_REQUEST"]/value'
							, GI_UM_GRIEVABILITY	NVARCHAR2(200) PATH './item[id="GI_UM_GRIEVABILITY"]/value'
							, GI_MEETING_DT	VARCHAR2(10) PATH './item[id="GI_MEETING_DT"]/value'
							, GI_GRIEVANCE_STATUS	NVARCHAR2(200) PATH './item[id="GI_GRIEVANCE_STATUS"]/value'
							, GI_ARBITRATION_DEADLINE_DT	VARCHAR2(10) PATH './item[id="GI_ARBITRATION_DEADLINE_DT"]/value'
							, GI_ARBITRATION_REQUEST	VARCHAR2(10) PATH './item[id="GI_ARBITRATION_REQUEST"]/value'
							, GI_ADMIN_OFFCL_1	NVARCHAR2(255) PATH './item[id="GI_ADMIN_OFFCL_1"]/value/name'
							, GI_ADMIN_STG_1_DECISION_DT	VARCHAR2(10) PATH './item[id="GI_ADMIN_STG_1_DECISION_DT"]/value'
							, GI_ADMIN_STG_1_ISSUE_DT	VARCHAR2(10) PATH './item[id="GI_ADMIN_STG_1_ISSUE_DT"]/value'
							, GI_ADMIN_STG_2_RESP	VARCHAR2(10) PATH './item[id="GI_ADMIN_STG_2_RESP"]/value'
							, GI_ADMIN_OFFCL_2	NVARCHAR2(255) PATH './item[id="GI_ADMIN_OFFCL_2"]/value/name'
							, GI_ADMIN_STG_2_DECISION_DT	VARCHAR2(10) PATH './item[id="GI_ADMIN_STG_2_DECISION_DT"]/value'
							, GI_ADMIN_STG_2_ISSUE_DT	VARCHAR2(10) PATH './item[id="GI_ADMIN_STG_2_ISSUE_DT"]/value'
							
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
                TRG.GI_TYPE = SRC.GI_TYPE
				, TRG.GI_NEGOTIATED_GRIEVANCE_TYPE = SRC.GI_NEGOTIATED_GRIEVANCE_TYPE
				, TRG.GI_TIMELY_FILING_2 = SRC.GI_TIMELY_FILING_2
				, TRG.GI_IND_MANAGER = SRC.GI_IND_MANAGER
				, TRG.GI_FILING_DT_2 = SRC.GI_FILING_DT_2
				, TRG.GI_TIMELY_FILING = SRC.GI_TIMELY_FILING
				, TRG.GI_FILING_DT = SRC.GI_FILING_DT
				, TRG.GI_IND_MEETING_DT = SRC.GI_IND_MEETING_DT
				, TRG.GI_IND_STEP_1_DECISION_DT = SRC.GI_IND_STEP_1_DECISION_DT
				, TRG.GI_IND_DECISION_ISSUE_DT = SRC.GI_IND_DECISION_ISSUE_DT
				, TRG.GI_IND_STEP_1_DEADLINE = SRC.GI_IND_STEP_1_DEADLINE
				, TRG.GI_IND_STEP_1_EXT_DUE_DT = SRC.GI_IND_STEP_1_EXT_DUE_DT
				, TRG.GI_IND_STEP_1_EXT_DUE_REASON = SRC.GI_IND_STEP_1_EXT_DUE_REASON
				, TRG.GI_STEP_2_REQUEST = SRC.GI_STEP_2_REQUEST
				, TRG.GI_IND_STEP_2_MTG_DT = SRC.GI_IND_STEP_2_MTG_DT
				, TRG.GI_IND_STEP_2_DECISION_DUE_DT = SRC.GI_IND_STEP_2_DECISION_DUE_DT
				, TRG.GI_IND_STEP_2_DCSN_ISSUE_DT = SRC.GI_IND_STEP_2_DCSN_ISSUE_DT	
				, TRG.GI_IND_STEP_2_DEADLINE = SRC.GI_IND_STEP_2_DEADLINE
				, TRG.GI_IND_EXT_2_EXT_DUE_DT = SRC.GI_IND_EXT_2_EXT_DUE_DT
				, TRG.GI_IND_STEP_2_EXT_DUE_REASON = SRC.GI_IND_STEP_2_EXT_DUE_REASON
				, TRG.GI_IND_THIRD_PARTY_APPEAL_DT = SRC.GI_IND_THIRD_PARTY_APPEAL_DT
				, TRG.GI_IND_THIRD_APPEAL_REQUEST = SRC.GI_IND_THIRD_APPEAL_REQUEST
				, TRG.GI_UM_GRIEVABILITY = SRC.GI_UM_GRIEVABILITY
				, TRG.GI_MEETING_DT = SRC.GI_MEETING_DT
				, TRG.GI_GRIEVANCE_STATUS = SRC.GI_GRIEVANCE_STATUS
				, TRG.GI_ARBITRATION_DEADLINE_DT = SRC.GI_ARBITRATION_DEADLINE_DT
				, TRG.GI_ARBITRATION_REQUEST = SRC.GI_ARBITRATION_REQUEST
				, TRG.GI_ADMIN_OFFCL_1 = SRC.GI_ADMIN_OFFCL_1
				, TRG.GI_ADMIN_STG_1_DECISION_DT = SRC.GI_ADMIN_STG_1_DECISION_DT
				, TRG.GI_ADMIN_STG_1_ISSUE_DT = SRC.GI_ADMIN_STG_1_ISSUE_DT
				, TRG.GI_ADMIN_STG_2_RESP = SRC.GI_ADMIN_STG_2_RESP
				, TRG.GI_ADMIN_OFFCL_2 = SRC.GI_ADMIN_OFFCL_2
				, TRG.GI_ADMIN_STG_2_DECISION_DT = SRC.GI_ADMIN_STG_2_DECISION_DT
				, TRG.GI_ADMIN_STG_2_ISSUE_DT = SRC.GI_ADMIN_STG_2_ISSUE_DT
				
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.GI_TYPE				
				, TRG.GI_NEGOTIATED_GRIEVANCE_TYPE				
				, TRG.GI_TIMELY_FILING_2
				, TRG.GI_IND_MANAGER
				, TRG.GI_FILING_DT_2
				, TRG.GI_TIMELY_FILING
				, TRG.GI_FILING_DT
				, TRG.GI_IND_MEETING_DT
				, TRG.GI_IND_STEP_1_DECISION_DT
				, TRG.GI_IND_DECISION_ISSUE_DT
				, TRG.GI_IND_STEP_1_DEADLINE
				, TRG.GI_IND_STEP_1_EXT_DUE_DT
				, TRG.GI_IND_STEP_1_EXT_DUE_REASON
				, TRG.GI_STEP_2_REQUEST
				, TRG.GI_IND_STEP_2_MTG_DT
				, TRG.GI_IND_STEP_2_DECISION_DUE_DT
				, TRG.GI_IND_STEP_2_DCSN_ISSUE_DT	
				, TRG.GI_IND_STEP_2_DEADLINE
				, TRG.GI_IND_EXT_2_EXT_DUE_DT
				, TRG.GI_IND_STEP_2_EXT_DUE_REASON
				, TRG.GI_IND_THIRD_PARTY_APPEAL_DT
				, TRG.GI_IND_THIRD_APPEAL_REQUEST
				, TRG.GI_UM_GRIEVABILITY
				, TRG.GI_MEETING_DT
				, TRG.GI_GRIEVANCE_STATUS
				, TRG.GI_ARBITRATION_DEADLINE_DT
				, TRG.GI_ARBITRATION_REQUEST
				, TRG.GI_ADMIN_OFFCL_1
				, TRG.GI_ADMIN_STG_1_DECISION_DT
				, TRG.GI_ADMIN_STG_1_ISSUE_DT	
				, TRG.GI_ADMIN_STG_2_RESP
				, TRG.GI_ADMIN_OFFCL_2
				, TRG.GI_ADMIN_STG_2_DECISION_DT
				, TRG.GI_ADMIN_STG_2_ISSUE_DT
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.GI_TYPE				
				, SRC.GI_NEGOTIATED_GRIEVANCE_TYPE				
				, SRC.GI_TIMELY_FILING_2
				, SRC.GI_IND_MANAGER
				, SRC.GI_FILING_DT_2
				, SRC.GI_TIMELY_FILING
				, SRC.GI_FILING_DT
				, SRC.GI_IND_MEETING_DT
				, SRC.GI_IND_STEP_1_DECISION_DT
				, SRC.GI_IND_DECISION_ISSUE_DT
				, SRC.GI_IND_STEP_1_DEADLINE
				, SRC.GI_IND_STEP_1_EXT_DUE_DT
				, SRC.GI_IND_STEP_1_EXT_DUE_REASON
				, SRC.GI_STEP_2_REQUEST
				, SRC.GI_IND_STEP_2_MTG_DT
				, SRC.GI_IND_STEP_2_DECISION_DUE_DT
				, SRC.GI_IND_STEP_2_DCSN_ISSUE_DT	
				, SRC.GI_IND_STEP_2_DEADLINE
				, SRC.GI_IND_EXT_2_EXT_DUE_DT
				, SRC.GI_IND_STEP_2_EXT_DUE_REASON
				, SRC.GI_IND_THIRD_PARTY_APPEAL_DT
				, SRC.GI_IND_THIRD_APPEAL_REQUEST
				, SRC.GI_UM_GRIEVABILITY
				, SRC.GI_MEETING_DT
				, SRC.GI_GRIEVANCE_STATUS
				, SRC.GI_ARBITRATION_DEADLINE_DT
				, SRC.GI_ARBITRATION_REQUEST
				, SRC.GI_ADMIN_OFFCL_1
				, SRC.GI_ADMIN_STG_1_DECISION_DT
				, SRC.GI_ADMIN_STG_1_ISSUE_DT	
				, SRC.GI_ADMIN_STG_2_RESP
				, SRC.GI_ADMIN_OFFCL_2
				, SRC.GI_ADMIN_STG_2_DECISION_DT
				, SRC.GI_ADMIN_STG_2_ISSUE_DT   
				            
            );

		END;

		--------------------------------
		-- ERLR_INVESTIGATION table
		--------------------------------
		BEGIN
            MERGE INTO ERLR_INVESTIGATION TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.INVESTIGATION_TYPE
					, X.I_MISCONDUCT_FOUND                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            INVESTIGATION_TYPE	NVARCHAR2(200)	PATH './item[id="INVESTIGATION_TYPE"]/value'
							, I_MISCONDUCT_FOUND	NVARCHAR2(3)	PATH './item[id="I_MISCONDUCT_FOUND"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET                
				TRG.INVESTIGATION_TYPE = SRC.INVESTIGATION_TYPE
				, TRG.I_MISCONDUCT_FOUND = SRC.I_MISCONDUCT_FOUND
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.INVESTIGATION_TYPE
				, TRG.I_MISCONDUCT_FOUND   
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.INVESTIGATION_TYPE
				, SRC.I_MISCONDUCT_FOUND               
            );

		END;
		
		--------------------------------
		-- ERLR_APPEAL table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_APPEAL TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.AP_ERLR_APPEAL_TYPE
					, TO_DATE(X.AP_ERLR_APPEAL_FILE_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_APPEAL_FILE_DT
					, X.AP_ERLR_APPEAL_TIMING
					, X.AP_APPEAL_HEARING_REQUESTED
					, X.AP_ARBITRATOR_LAST_NAME
					, X.AP_ARBITRATOR_FIRST_NAME
					, X.AP_ARBITRATOR_MIDDLE_NAME
					, X.AP_ARBITRATOR_EMAIL
					, X.AP_ARBITRATOR_PHONE_NUM
					, X.AP_ARBITRATOR_ORG_AFFIL
					, X.AP_ARBITRATOR_MAILING_ADDR
					, TO_DATE(X.AP_ERLR_PREHEARING_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_PREHEARING_DT
					, TO_DATE(X.AP_ERLR_HEARING_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_HEARING_DT	
					, TO_DATE(X.AP_POSTHEARING_BRIEF_DUE,'MM/DD/YYYY HH24:MI:SS') AS AP_POSTHEARING_BRIEF_DUE
					, TO_DATE(X.AP_FINAL_ARBITRATOR_DCSN_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_ARBITRATOR_DCSN_DT
					, X.AP_ERLR_EXCEPTION_FILED
					, TO_DATE(X.AP_ERLR_EXCEPTION_FILE_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_EXCEPTION_FILE_DT
					, TO_DATE(X.AP_RESPON_TO_EXCEPT_DUE,'MM/DD/YYYY HH24:MI:SS') AS AP_RESPON_TO_EXCEPT_DUE
					, TO_DATE(X.AP_FINAL_FLRA_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_FLRA_DECISION_DT
					, TO_DATE(X.AP_ERLR_STEP_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_STEP_DECISION_DT
					, X.AP_ERLR_ARBITRATION_INVOKED
					, X.AP_ARBITRATOR_LAST_NAME_3
					, X.AP_ARBITRATOR_FIRST_NAME_3
					, X.AP_ARBITRATOR_MIDDLE_NAME_3
					, X.AP_ARBITRATOR_EMAIL_3
					, X.AP_ARBITRATOR_PHONE_NUM_3
					, X.AP_ARBITRATOR_ORG_AFFIL_3
					, X.AP_ARBITRATION_MAILING_ADDR_3
					, TO_DATE(X.AP_ERLR_PREHEARING_DT_2,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_PREHEARING_DT_2
					, TO_DATE(X.AP_ERLR_HEARING_DT_2,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_HEARING_DT_2
					, TO_DATE(X.AP_POSTHEARING_BRIEF_DUE_2,'MM/DD/YYYY HH24:MI:SS') AS AP_POSTHEARING_BRIEF_DUE_2
					, TO_DATE(X.AP_FINAL_ARBITRATOR_DCSN_DT_2,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_ARBITRATOR_DCSN_DT_2
					, X.AP_ERLR_EXCEPTION_FILED_2
					, TO_DATE(X.AP_ERLR_EXCEPTION_FILE_DT_2,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_EXCEPTION_FILE_DT_2
					, TO_DATE(X.AP_RESPON_TO_EXCEPT_DUE_2,'MM/DD/YYYY HH24:MI:SS') AS AP_RESPON_TO_EXCEPT_DUE_2
					, TO_DATE(X.AP_FINAL_FLRA_DECISION_DT_2,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_FLRA_DECISION_DT_2
					, X.AP_ARBITRATOR_LAST_NAME_2
					, X.AP_ARBITRATOR_FIRST_NAME_2
					, X.AP_ARBITRATOR_MIDDLE_NAME_2
					, X.AP_ARBITRATOR_EMAIL_2
					, X.AP_ARBITRATOR_PHONE_NUM_2
					, X.AP_ARBITRATOR_ORG_AFFIL_2
					, X.AP_ARBITRATION_MAILING_ADDR_2
					, TO_DATE(X.AP_ERLR_PREHEARING_DT_SC,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_PREHEARING_DT_SC
					, TO_DATE(X.AP_ERLR_HEARING_DT_SC,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_HEARING_DT_SC
					, X.AP_ARBITRATOR_LAST_NAME_4
					, X.AP_ARBITRATOR_FIRST_NAME_4
					, X.AP_ARBITRATOR_MIDDLE_NAME_4
					, X.AP_ARBITRATOR_EMAIL_4
					, X.AP_ARBITRATOR_PHONE_NUM_4
					, X.AP_ARBITRATOR_ORG_AFFIL_4
					, X.AP_ARBITRATOR_MAILING_ADDR_4
					, TO_DATE(X.AP_DT_SETTLEMENT_DISCUSSION,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_SETTLEMENT_DISCUSSION
					, TO_DATE(X.AP_DT_PREHEARING_DISCLOSURE,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_PREHEARING_DISCLOSURE
					, TO_DATE(X.AP_DT_AGNCY_FILE_RESPON_DUE,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_AGNCY_FILE_RESPON_DUE  
					, TO_DATE(X.AP_ERLR_PREHEARING_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_PREHEARING_DT_MSPB   
					, X.AP_WAS_DISCOVERY_INITIATED
					, TO_DATE(X.AP_ERLR_DT_DISCOVERY_DUE,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_DT_DISCOVERY_DUE
					, TO_DATE(X.AP_ERLR_HEARING_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_HEARING_DT_MSPB
					, TO_DATE(X.AP_PETITION_FILE_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS AP_PETITION_FILE_DT_MSPB
					, X.AP_WAS_PETITION_FILED_MSPB
					, TO_DATE(X.AP_INITIAL_DECISION_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS AP_INITIAL_DECISION_DT_MSPB
					, TO_DATE(X.AP_FINAL_BOARD_DCSN_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_BOARD_DCSN_DT_MSPB
					, TO_DATE(X.AP_DT_SETTLEMENT_DISCUSSION_2,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_SETTLEMENT_DISCUSSION_2
					, TO_DATE(X.AP_DT_PREHEARING_DISCLOSURE_2,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_PREHEARING_DISCLOSURE_2
					, TO_DATE(X.AP_DT_AGNCY_FILE_RESPON_DUE_2,'MM/DD/YYYY HH24:MI:SS') AS AP_DT_AGNCY_FILE_RESPON_DUE_2
					, TO_DATE(X.AP_ERLR_PREHEARING_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_PREHEARING_DT_FLRA
					, TO_DATE(X.AP_ERLR_HEARING_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS AP_ERLR_HEARING_DT_FLRA
					, TO_DATE(X.AP_INITIAL_DECISION_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS AP_INITIAL_DECISION_DT_FLRA
					, X.AP_WAS_PETITION_FILED_FLRA
					, TO_DATE(X.AP_PETITION_FILE_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS AP_PETITION_FILE_DT_FLRA
					, TO_DATE(X.AP_FINAL_BOARD_DCSN_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS AP_FINAL_BOARD_DCSN_DT_FLRA

                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS                            
							AP_ERLR_APPEAL_TYPE	NVARCHAR2(200)	PATH './item[id="AP_ERLR_APPEAL_TYPE"]/value'
							, AP_ERLR_APPEAL_FILE_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_APPEAL_FILE_DT"]/value'
							, AP_ERLR_APPEAL_TIMING	NVARCHAR2(3)	PATH './item[id="AP_ERLR_APPEAL_TIMING"]/value'
							, AP_APPEAL_HEARING_REQUESTED	NVARCHAR2(3)	PATH './item[id="AP_ERLR_APPEAL_HEARING_REQUESTED"]/value'
							, AP_ARBITRATOR_LAST_NAME	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_LAST_NAME"]/value'
							, AP_ARBITRATOR_FIRST_NAME	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_FIRST_NAME"]/value'
							, AP_ARBITRATOR_MIDDLE_NAME	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_MIDDLE_NAME"]/value'
							, AP_ARBITRATOR_EMAIL	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_EMAIL"]/value'
							, AP_ARBITRATOR_PHONE_NUM	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_PHONE_NUMBER"]/value'
							, AP_ARBITRATOR_ORG_AFFIL	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION"]/value'
							, AP_ARBITRATOR_MAILING_ADDR	NVARCHAR2(250)	PATH './item[id="AP_ERLR_ARBITRATION_MAILING_ADDR"]/value'
							, AP_ERLR_PREHEARING_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_PREHEARING_DT"]/value'
							, AP_ERLR_HEARING_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_HEARING_DT"]/value'
							, AP_POSTHEARING_BRIEF_DUE	VARCHAR2(10)	PATH './item[id="AP_ERLR_POSTHEARING_BRIEF_DUE"]/value'
							, AP_FINAL_ARBITRATOR_DCSN_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_ARBITRATOR_DECISION_DT"]/value'
							, AP_ERLR_EXCEPTION_FILED	NVARCHAR2(3)	PATH './item[id="AP_ERLR_EXCEPTION_FILED"]/value'
							, AP_ERLR_EXCEPTION_FILE_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_EXCEPTION_FILE_DT"]/value'
							, AP_RESPON_TO_EXCEPT_DUE	VARCHAR2(10)	PATH './item[id="AP_ERLR_RESPONSE_TO_EXCEPTIONS_DUE"]/value'
							, AP_FINAL_FLRA_DECISION_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_FLRA_DECISION_DT"]/value'
							, AP_ERLR_STEP_DECISION_DT	VARCHAR2(10)	PATH './item[id="AP_ERLR_STEP_DECISION_DT"]/value'
							, AP_ERLR_ARBITRATION_INVOKED	NVARCHAR2(3)	PATH './item[id="AP_ERLR_ARBITRATION_INVOKED"]/value'
							, AP_ARBITRATOR_LAST_NAME_3	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_LAST_NAME_3"]/value'
							, AP_ARBITRATOR_FIRST_NAME_3	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_FIRST_NAME_3"]/value'
							, AP_ARBITRATOR_MIDDLE_NAME_3	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_MIDDLE_NAME_3"]/value'
							, AP_ARBITRATOR_EMAIL_3	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_EMAIL_3"]/value'
							, AP_ARBITRATOR_PHONE_NUM_3	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_PHONE_NUMBER_3"]/value'
							, AP_ARBITRATOR_ORG_AFFIL_3	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION_3"]/value'
							, AP_ARBITRATION_MAILING_ADDR_3	NVARCHAR2(250)	PATH './item[id="AP_ERLR_ARBITRATION_MAILING_ADDR_3"]/value'
							, AP_ERLR_PREHEARING_DT_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_PREHEARING_DT_2"]/value'
							, AP_ERLR_HEARING_DT_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_HEARING_DT_2"]/value'
							, AP_POSTHEARING_BRIEF_DUE_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_POSTHEARING_BRIEF_DUE_2"]/value'
							, AP_FINAL_ARBITRATOR_DCSN_DT_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_ARBITRATOR_DECISION_DT_2"]/value'
							, AP_ERLR_EXCEPTION_FILED_2	NVARCHAR2(3)	PATH './item[id="AP_ERLR_EXCEPTION_FILED_2"]/value'
							, AP_ERLR_EXCEPTION_FILE_DT_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_EXCEPTION_FILE_DT_2"]/value'
							, AP_RESPON_TO_EXCEPT_DUE_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_RESPONSE_TO_EXCEPTIONS_DUE_2"]/value'
							, AP_FINAL_FLRA_DECISION_DT_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_FLRA_DECISION_DT_2"]/value'
							, AP_ARBITRATOR_LAST_NAME_2	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_LAST_NAME_2"]/value'
							, AP_ARBITRATOR_FIRST_NAME_2	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_FIRST_NAME_2"]/value'
							, AP_ARBITRATOR_MIDDLE_NAME_2	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_MIDDLE_NAME_2"]/value'
							, AP_ARBITRATOR_EMAIL_2	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_EMAIL_2"]/value'
							, AP_ARBITRATOR_PHONE_NUM_2	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_PHONE_NUMBER_2"]/value'
							, AP_ARBITRATOR_ORG_AFFIL_2	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION_2"]/value'
							, AP_ARBITRATION_MAILING_ADDR_2	NVARCHAR2(250)	PATH './item[id="AP_ERLR_ARBITRATION_MAILING_ADDR_2"]/value'
							, AP_ERLR_PREHEARING_DT_SC	VARCHAR2(10)	PATH './item[id="AP_ERLR_PREHEARING_DT_SC"]/value'
							, AP_ERLR_HEARING_DT_SC	VARCHAR2(10)	PATH './item[id="AP_ERLR_HEARING_DT_SC"]/value'
							, AP_ARBITRATOR_LAST_NAME_4	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_LAST_NAME_4"]/value'
							, AP_ARBITRATOR_FIRST_NAME_4	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_FIRST_NAME_4"]/value'
							, AP_ARBITRATOR_MIDDLE_NAME_4	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_MIDDLE_NAME_4"]/value'
							, AP_ARBITRATOR_EMAIL_4	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_EMAIL_4"]/value'
							, AP_ARBITRATOR_PHONE_NUM_4	NVARCHAR2(50)	PATH './item[id="AP_ERLR_ARBITRATOR_PHONE_NUMBER_4"]/value'
							, AP_ARBITRATOR_ORG_AFFIL_4	NVARCHAR2(100)	PATH './item[id="AP_ERLR_ARBITRATOR_ORGANIZATION_AFFILIATION_4"]/value'
							, AP_ARBITRATOR_MAILING_ADDR_4	NVARCHAR2(250)	PATH './item[id="AP_ERLR_ARBITRATION_MAILING_ADDR"]/value'
							, AP_DT_SETTLEMENT_DISCUSSION	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_SETTLEMENT_DISCUSSION"]/value'
							, AP_DT_PREHEARING_DISCLOSURE	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_PREHEARING_DISCLOSURE"]/value'
							, AP_DT_AGNCY_FILE_RESPON_DUE   VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_AGENCY_FILE_RESPONSE_DUE"]/value'
							, AP_ERLR_PREHEARING_DT_MSPB    VARCHAR2(10)	PATH './item[id="AP_ERLR_PREHEARING_DT_MSPB"]/value'
							, AP_WAS_DISCOVERY_INITIATED	NVARCHAR2(3)	PATH './item[id="AP_ERLR_WAS_DISCOVERY_INITIATED"]/value'
							, AP_ERLR_DT_DISCOVERY_DUE	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_DISCOVERY_DUE"]/value'
							, AP_ERLR_HEARING_DT_MSPB	VARCHAR2(10)	PATH './item[id="AP_ERLR_HEARING_DT_MSPB"]/value'
							, AP_PETITION_FILE_DT_MSPB	VARCHAR2(10)	PATH './item[id="AP_ERLR_PETITION_4REVIEW_DT"]/value'
							, AP_WAS_PETITION_FILED_MSPB	NVARCHAR2(3)	PATH './item[id="AP_ERLR_WAS_PETITION_4REVIEW_MSPB"]/value'
							, AP_INITIAL_DECISION_DT_MSPB	VARCHAR2(10)	PATH './item[id="AP_ERLR_initial_decision_MSPB_DT"]/value'
							, AP_FINAL_BOARD_DCSN_DT_MSPB	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_DECISION_MSPB_DT"]/value'
							, AP_DT_SETTLEMENT_DISCUSSION_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_SETTLEMENT_DISCUSSION_FLRA"]/value'
							, AP_DT_PREHEARING_DISCLOSURE_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_PREHEARING_DISCLOSURE_FLRA"]/value'
							, AP_DT_AGNCY_FILE_RESPON_DUE_2	VARCHAR2(10)	PATH './item[id="AP_ERLR_DT_AGENCY_FILE_RESPONSE_DUE_FLRA"]/value'
							, AP_ERLR_PREHEARING_DT_FLRA	VARCHAR2(10)	PATH './item[id="AP_ERLR_PREHEARING_DT_FLRA"]/value'
							, AP_ERLR_HEARING_DT_FLRA	VARCHAR2(10)	PATH './item[id="AP_ERLR_HEARING_DT_FLRA"]/value'
							, AP_INITIAL_DECISION_DT_FLRA	VARCHAR2(10)	PATH './item[id="AP_ERLR_DECISION_DT_FLRA"]/value'
							, AP_WAS_PETITION_FILED_FLRA	NVARCHAR2(3)	PATH './item[id="AP_ERLR_WAS_DECISION_APPEALED_FLRA"]/value'
							, AP_PETITION_FILE_DT_FLRA	VARCHAR2(10)	PATH './item[id="AP_ERLR_APPEAL_FILE_DT_FLRA"]/value'
							, AP_FINAL_BOARD_DCSN_DT_FLRA	VARCHAR2(10)	PATH './item[id="AP_ERLR_FINAL_DECISION_FLRA_DT"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET				
				TRG.AP_ERLR_APPEAL_TYPE = SRC.AP_ERLR_APPEAL_TYPE
				, TRG.AP_ERLR_APPEAL_FILE_DT = SRC.AP_ERLR_APPEAL_FILE_DT
				, TRG.AP_ERLR_APPEAL_TIMING = SRC.AP_ERLR_APPEAL_TIMING
				, TRG.AP_APPEAL_HEARING_REQUESTED = SRC.AP_APPEAL_HEARING_REQUESTED
				, TRG.AP_ARBITRATOR_LAST_NAME = SRC.AP_ARBITRATOR_LAST_NAME
				, TRG.AP_ARBITRATOR_FIRST_NAME = SRC.AP_ARBITRATOR_FIRST_NAME
				, TRG.AP_ARBITRATOR_MIDDLE_NAME = SRC.AP_ARBITRATOR_MIDDLE_NAME
				, TRG.AP_ARBITRATOR_EMAIL = SRC.AP_ARBITRATOR_EMAIL
				, TRG.AP_ARBITRATOR_PHONE_NUM = SRC.AP_ARBITRATOR_PHONE_NUM
				, TRG.AP_ARBITRATOR_ORG_AFFIL = SRC.AP_ARBITRATOR_ORG_AFFIL
				, TRG.AP_ARBITRATOR_MAILING_ADDR = SRC.AP_ARBITRATOR_MAILING_ADDR
				, TRG.AP_ERLR_PREHEARING_DT = SRC.AP_ERLR_PREHEARING_DT
				, TRG.AP_ERLR_HEARING_DT = SRC.AP_ERLR_HEARING_DT
				, TRG.AP_POSTHEARING_BRIEF_DUE = SRC.AP_POSTHEARING_BRIEF_DUE
				, TRG.AP_FINAL_ARBITRATOR_DCSN_DT = SRC.AP_FINAL_ARBITRATOR_DCSN_DT
				, TRG.AP_ERLR_EXCEPTION_FILED = SRC.AP_ERLR_EXCEPTION_FILED
				, TRG.AP_ERLR_EXCEPTION_FILE_DT = SRC.AP_ERLR_EXCEPTION_FILE_DT
				, TRG.AP_RESPON_TO_EXCEPT_DUE = SRC.AP_RESPON_TO_EXCEPT_DUE
				, TRG.AP_FINAL_FLRA_DECISION_DT = SRC.AP_FINAL_FLRA_DECISION_DT
				, TRG.AP_ERLR_STEP_DECISION_DT = SRC.AP_ERLR_STEP_DECISION_DT
				, TRG.AP_ERLR_ARBITRATION_INVOKED = SRC.AP_ERLR_ARBITRATION_INVOKED
				, TRG.AP_ARBITRATOR_LAST_NAME_3 = SRC.AP_ARBITRATOR_LAST_NAME_3
				, TRG.AP_ARBITRATOR_FIRST_NAME_3 = SRC.AP_ARBITRATOR_FIRST_NAME_3
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_3 = SRC.AP_ARBITRATOR_MIDDLE_NAME_3
				, TRG.AP_ARBITRATOR_EMAIL_3 = SRC.AP_ARBITRATOR_EMAIL_3
				, TRG.AP_ARBITRATOR_PHONE_NUM_3 = SRC.AP_ARBITRATOR_PHONE_NUM_3
				, TRG.AP_ARBITRATOR_ORG_AFFIL_3 = SRC.AP_ARBITRATOR_ORG_AFFIL_3
				, TRG.AP_ARBITRATION_MAILING_ADDR_3 = SRC.AP_ARBITRATION_MAILING_ADDR_3
				, TRG.AP_ERLR_PREHEARING_DT_2 = SRC.AP_ERLR_PREHEARING_DT_2
				, TRG.AP_ERLR_HEARING_DT_2 = SRC.AP_ERLR_HEARING_DT_2
				, TRG.AP_POSTHEARING_BRIEF_DUE_2 = SRC.AP_POSTHEARING_BRIEF_DUE_2
				, TRG.AP_FINAL_ARBITRATOR_DCSN_DT_2 = SRC.AP_FINAL_ARBITRATOR_DCSN_DT_2
				, TRG.AP_ERLR_EXCEPTION_FILED_2 = SRC.AP_ERLR_EXCEPTION_FILED_2
				, TRG.AP_ERLR_EXCEPTION_FILE_DT_2 = SRC.AP_ERLR_EXCEPTION_FILE_DT_2
				, TRG.AP_RESPON_TO_EXCEPT_DUE_2 = SRC.AP_RESPON_TO_EXCEPT_DUE_2
				, TRG.AP_FINAL_FLRA_DECISION_DT_2 = SRC.AP_FINAL_FLRA_DECISION_DT_2
				, TRG.AP_ARBITRATOR_LAST_NAME_2 = SRC.AP_ARBITRATOR_LAST_NAME_2
				, TRG.AP_ARBITRATOR_FIRST_NAME_2 = SRC.AP_ARBITRATOR_FIRST_NAME_2
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_2 = SRC.AP_ARBITRATOR_MIDDLE_NAME_2
				, TRG.AP_ARBITRATOR_EMAIL_2 = SRC.AP_ARBITRATOR_EMAIL_2
				, TRG.AP_ARBITRATOR_PHONE_NUM_2 = SRC.AP_ARBITRATOR_PHONE_NUM_2
				, TRG.AP_ARBITRATOR_ORG_AFFIL_2 = SRC.AP_ARBITRATOR_ORG_AFFIL_2
				, TRG.AP_ARBITRATION_MAILING_ADDR_2 = SRC.AP_ARBITRATION_MAILING_ADDR_2
				, TRG.AP_ERLR_PREHEARING_DT_SC = SRC.AP_ERLR_PREHEARING_DT_SC
				, TRG.AP_ERLR_HEARING_DT_SC = SRC.AP_ERLR_HEARING_DT_SC
				, TRG.AP_ARBITRATOR_LAST_NAME_4 = SRC.AP_ARBITRATOR_LAST_NAME_4
				, TRG.AP_ARBITRATOR_FIRST_NAME_4 = SRC.AP_ARBITRATOR_FIRST_NAME_4
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_4 = SRC.AP_ARBITRATOR_MIDDLE_NAME_4
				, TRG.AP_ARBITRATOR_EMAIL_4 = SRC.AP_ARBITRATOR_EMAIL_4
				, TRG.AP_ARBITRATOR_PHONE_NUM_4 = SRC.AP_ARBITRATOR_PHONE_NUM_4
				, TRG.AP_ARBITRATOR_ORG_AFFIL_4 = SRC.AP_ARBITRATOR_ORG_AFFIL_4
				, TRG.AP_ARBITRATOR_MAILING_ADDR_4 = SRC.AP_ARBITRATOR_MAILING_ADDR_4
				, TRG.AP_DT_SETTLEMENT_DISCUSSION = SRC.AP_DT_SETTLEMENT_DISCUSSION
				, TRG.AP_DT_PREHEARING_DISCLOSURE = SRC.AP_DT_PREHEARING_DISCLOSURE
				, TRG.AP_DT_AGNCY_FILE_RESPON_DUE = SRC.AP_DT_AGNCY_FILE_RESPON_DUE
				, TRG.AP_ERLR_PREHEARING_DT_MSPB = SRC.AP_ERLR_PREHEARING_DT_MSPB
				, TRG.AP_WAS_DISCOVERY_INITIATED = SRC.AP_WAS_DISCOVERY_INITIATED
				, TRG.AP_ERLR_DT_DISCOVERY_DUE = SRC.AP_ERLR_DT_DISCOVERY_DUE
				, TRG.AP_ERLR_HEARING_DT_MSPB = SRC.AP_ERLR_HEARING_DT_MSPB
				, TRG.AP_PETITION_FILE_DT_MSPB = SRC.AP_PETITION_FILE_DT_MSPB
				, TRG.AP_WAS_PETITION_FILED_MSPB = SRC.AP_WAS_PETITION_FILED_MSPB
				, TRG.AP_INITIAL_DECISION_DT_MSPB = SRC.AP_INITIAL_DECISION_DT_MSPB
				, TRG.AP_FINAL_BOARD_DCSN_DT_MSPB = SRC.AP_FINAL_BOARD_DCSN_DT_MSPB
				, TRG.AP_DT_SETTLEMENT_DISCUSSION_2 = SRC.AP_DT_SETTLEMENT_DISCUSSION_2
				, TRG.AP_DT_PREHEARING_DISCLOSURE_2 = SRC.AP_DT_PREHEARING_DISCLOSURE_2
				, TRG.AP_DT_AGNCY_FILE_RESPON_DUE_2 = SRC.AP_DT_AGNCY_FILE_RESPON_DUE_2
				, TRG.AP_ERLR_PREHEARING_DT_FLRA = SRC.AP_ERLR_PREHEARING_DT_FLRA
				, TRG.AP_ERLR_HEARING_DT_FLRA = SRC.AP_ERLR_HEARING_DT_FLRA
				, TRG.AP_INITIAL_DECISION_DT_FLRA = SRC.AP_INITIAL_DECISION_DT_FLRA
				, TRG.AP_WAS_PETITION_FILED_FLRA = SRC.AP_WAS_PETITION_FILED_FLRA
				, TRG.AP_PETITION_FILE_DT_FLRA = SRC.AP_PETITION_FILE_DT_FLRA
				, TRG.AP_FINAL_BOARD_DCSN_DT_FLRA = SRC.AP_FINAL_BOARD_DCSN_DT_FLRA
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.AP_ERLR_APPEAL_TYPE
				, TRG.AP_ERLR_APPEAL_FILE_DT
				, TRG.AP_ERLR_APPEAL_TIMING
				, TRG.AP_APPEAL_HEARING_REQUESTED
				, TRG.AP_ARBITRATOR_LAST_NAME
				, TRG.AP_ARBITRATOR_FIRST_NAME
				, TRG.AP_ARBITRATOR_MIDDLE_NAME
				, TRG.AP_ARBITRATOR_EMAIL
				, TRG.AP_ARBITRATOR_PHONE_NUM
				, TRG.AP_ARBITRATOR_ORG_AFFIL
				, TRG.AP_ARBITRATOR_MAILING_ADDR
				, TRG.AP_ERLR_PREHEARING_DT
				, TRG.AP_ERLR_HEARING_DT	
				, TRG.AP_POSTHEARING_BRIEF_DUE
				, TRG.AP_FINAL_ARBITRATOR_DCSN_DT
				, TRG.AP_ERLR_EXCEPTION_FILED
				, TRG.AP_ERLR_EXCEPTION_FILE_DT
				, TRG.AP_RESPON_TO_EXCEPT_DUE
				, TRG.AP_FINAL_FLRA_DECISION_DT
				, TRG.AP_ERLR_STEP_DECISION_DT
				, TRG.AP_ERLR_ARBITRATION_INVOKED
				, TRG.AP_ARBITRATOR_LAST_NAME_3
				, TRG.AP_ARBITRATOR_FIRST_NAME_3
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_3
				, TRG.AP_ARBITRATOR_EMAIL_3
				, TRG.AP_ARBITRATOR_PHONE_NUM_3
				, TRG.AP_ARBITRATOR_ORG_AFFIL_3
				, TRG.AP_ARBITRATION_MAILING_ADDR_3
				, TRG.AP_ERLR_PREHEARING_DT_2
				, TRG.AP_ERLR_HEARING_DT_2
				, TRG.AP_POSTHEARING_BRIEF_DUE_2
				, TRG.AP_FINAL_ARBITRATOR_DCSN_DT_2
				, TRG.AP_ERLR_EXCEPTION_FILED_2
				, TRG.AP_ERLR_EXCEPTION_FILE_DT_2
				, TRG.AP_RESPON_TO_EXCEPT_DUE_2
				, TRG.AP_FINAL_FLRA_DECISION_DT_2
				, TRG.AP_ARBITRATOR_LAST_NAME_2
				, TRG.AP_ARBITRATOR_FIRST_NAME_2
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_2
				, TRG.AP_ARBITRATOR_EMAIL_2
				, TRG.AP_ARBITRATOR_PHONE_NUM_2
				, TRG.AP_ARBITRATOR_ORG_AFFIL_2
				, TRG.AP_ARBITRATION_MAILING_ADDR_2
				, TRG.AP_ERLR_PREHEARING_DT_SC
				, TRG.AP_ERLR_HEARING_DT_SC
				, TRG.AP_ARBITRATOR_LAST_NAME_4
				, TRG.AP_ARBITRATOR_FIRST_NAME_4
				, TRG.AP_ARBITRATOR_MIDDLE_NAME_4
				, TRG.AP_ARBITRATOR_EMAIL_4
				, TRG.AP_ARBITRATOR_PHONE_NUM_4
				, TRG.AP_ARBITRATOR_ORG_AFFIL_4
				, TRG.AP_ARBITRATOR_MAILING_ADDR_4
				, TRG.AP_DT_SETTLEMENT_DISCUSSION
				, TRG.AP_DT_PREHEARING_DISCLOSURE
				, TRG.AP_DT_AGNCY_FILE_RESPON_DUE
				, TRG.AP_ERLR_PREHEARING_DT_MSPB
				, TRG.AP_WAS_DISCOVERY_INITIATED
				, TRG.AP_ERLR_DT_DISCOVERY_DUE
				, TRG.AP_ERLR_HEARING_DT_MSPB
				, TRG.AP_PETITION_FILE_DT_MSPB
				, TRG.AP_WAS_PETITION_FILED_MSPB
				, TRG.AP_INITIAL_DECISION_DT_MSPB
				, TRG.AP_FINAL_BOARD_DCSN_DT_MSPB
				, TRG.AP_DT_SETTLEMENT_DISCUSSION_2
				, TRG.AP_DT_PREHEARING_DISCLOSURE_2
				, TRG.AP_DT_AGNCY_FILE_RESPON_DUE_2
				, TRG.AP_ERLR_PREHEARING_DT_FLRA
				, TRG.AP_ERLR_HEARING_DT_FLRA
				, TRG.AP_INITIAL_DECISION_DT_FLRA
				, TRG.AP_WAS_PETITION_FILED_FLRA
				, TRG.AP_PETITION_FILE_DT_FLRA
				, TRG.AP_FINAL_BOARD_DCSN_DT_FLRA
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.AP_ERLR_APPEAL_TYPE
				, SRC.AP_ERLR_APPEAL_FILE_DT
				, SRC.AP_ERLR_APPEAL_TIMING
				, SRC.AP_APPEAL_HEARING_REQUESTED
				, SRC.AP_ARBITRATOR_LAST_NAME
				, SRC.AP_ARBITRATOR_FIRST_NAME
				, SRC.AP_ARBITRATOR_MIDDLE_NAME
				, SRC.AP_ARBITRATOR_EMAIL
				, SRC.AP_ARBITRATOR_PHONE_NUM
				, SRC.AP_ARBITRATOR_ORG_AFFIL
				, SRC.AP_ARBITRATOR_MAILING_ADDR
				, SRC.AP_ERLR_PREHEARING_DT
				, SRC.AP_ERLR_HEARING_DT	
				, SRC.AP_POSTHEARING_BRIEF_DUE
				, SRC.AP_FINAL_ARBITRATOR_DCSN_DT
				, SRC.AP_ERLR_EXCEPTION_FILED
				, SRC.AP_ERLR_EXCEPTION_FILE_DT
				, SRC.AP_RESPON_TO_EXCEPT_DUE
				, SRC.AP_FINAL_FLRA_DECISION_DT
				, SRC.AP_ERLR_STEP_DECISION_DT
				, SRC.AP_ERLR_ARBITRATION_INVOKED
				, SRC.AP_ARBITRATOR_LAST_NAME_3
				, SRC.AP_ARBITRATOR_FIRST_NAME_3
				, SRC.AP_ARBITRATOR_MIDDLE_NAME_3
				, SRC.AP_ARBITRATOR_EMAIL_3
				, SRC.AP_ARBITRATOR_PHONE_NUM_3
				, SRC.AP_ARBITRATOR_ORG_AFFIL_3
				, SRC.AP_ARBITRATION_MAILING_ADDR_3
				, SRC.AP_ERLR_PREHEARING_DT_2
				, SRC.AP_ERLR_HEARING_DT_2
				, SRC.AP_POSTHEARING_BRIEF_DUE_2
				, SRC.AP_FINAL_ARBITRATOR_DCSN_DT_2
				, SRC.AP_ERLR_EXCEPTION_FILED_2
				, SRC.AP_ERLR_EXCEPTION_FILE_DT_2
				, SRC.AP_RESPON_TO_EXCEPT_DUE_2
				, SRC.AP_FINAL_FLRA_DECISION_DT_2
				, SRC.AP_ARBITRATOR_LAST_NAME_2
				, SRC.AP_ARBITRATOR_FIRST_NAME_2
				, SRC.AP_ARBITRATOR_MIDDLE_NAME_2
				, SRC.AP_ARBITRATOR_EMAIL_2
				, SRC.AP_ARBITRATOR_PHONE_NUM_2
				, SRC.AP_ARBITRATOR_ORG_AFFIL_2
				, SRC.AP_ARBITRATION_MAILING_ADDR_2
				, SRC.AP_ERLR_PREHEARING_DT_SC
				, SRC.AP_ERLR_HEARING_DT_SC
				, SRC.AP_ARBITRATOR_LAST_NAME_4
				, SRC.AP_ARBITRATOR_FIRST_NAME_4
				, SRC.AP_ARBITRATOR_MIDDLE_NAME_4
				, SRC.AP_ARBITRATOR_EMAIL_4
				, SRC.AP_ARBITRATOR_PHONE_NUM_4
				, SRC.AP_ARBITRATOR_ORG_AFFIL_4
				, SRC.AP_ARBITRATOR_MAILING_ADDR_4
				, SRC.AP_DT_SETTLEMENT_DISCUSSION
				, SRC.AP_DT_PREHEARING_DISCLOSURE
				, SRC.AP_DT_AGNCY_FILE_RESPON_DUE
				, SRC.AP_ERLR_PREHEARING_DT_MSPB
				, SRC.AP_WAS_DISCOVERY_INITIATED
				, SRC.AP_ERLR_DT_DISCOVERY_DUE
				, SRC.AP_ERLR_HEARING_DT_MSPB
				, SRC.AP_PETITION_FILE_DT_MSPB
				, SRC.AP_WAS_PETITION_FILED_MSPB
				, SRC.AP_INITIAL_DECISION_DT_MSPB
				, SRC.AP_FINAL_BOARD_DCSN_DT_MSPB
				, SRC.AP_DT_SETTLEMENT_DISCUSSION_2
				, SRC.AP_DT_PREHEARING_DISCLOSURE_2
				, SRC.AP_DT_AGNCY_FILE_RESPON_DUE_2
				, SRC.AP_ERLR_PREHEARING_DT_FLRA
				, SRC.AP_ERLR_HEARING_DT_FLRA
				, SRC.AP_INITIAL_DECISION_DT_FLRA
				, SRC.AP_WAS_PETITION_FILED_FLRA
				, SRC.AP_PETITION_FILE_DT_FLRA
				, SRC.AP_FINAL_BOARD_DCSN_DT_FLRA
               
            );

		END;

		--------------------------------
		-- ERLR_WGI_DNL table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_WGI_DNL TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, TO_DATE(X.WGI_DTR_DENIAL_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_DTR_DENIAL_ISSUED_DT
					, WGI_DTR_EMP_REQ_RECON
					, TO_DATE(X.WGI_DTR_RECON_REQ_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_DTR_RECON_REQ_DT
					, TO_DATE(X.WGI_DTR_RECON_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_DTR_RECON_ISSUE_DT
					, WGI_DTR_DENIED
					, TO_DATE(X.WGI_DTR_DENIAL_ISSUE_TO_EMP_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_DTR_DENIAL_ISSUE_TO_EMP_DT
					, TO_DATE(X.WGI_RVW_REDTR_NOTI_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_RVW_REDTR_NOTI_ISSUED_DT
					, WGI_REVIEW_DTR_FAVORABLE
					, WGI_REVIEW_EMP_REQ_RECON
					, TO_DATE(X.WGI_REVIEW_RECON_REQ_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_REVIEW_RECON_REQ_DT
					, TO_DATE(X.WGI_REVIEW_RECON_ISSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS WGI_REVIEW_RECON_ISSUE_DT
					, WGI_REVIEW_DENIED
					, WGI_EMP_APPEAL_DECISION
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS                            
							WGI_DTR_DENIAL_ISSUED_DT	VARCHAR2(10) PATH './item[id="WGI_DTR_DENIAL_ISSUED_DT"]/value'
							, WGI_DTR_EMP_REQ_RECON	NVARCHAR2(3) PATH './item[id="WGI_DTR_EMP_REQ_RECON"]/value'
							, WGI_DTR_RECON_REQ_DT	VARCHAR2(10) PATH './item[id="WGI_DTR_RECON_REQ_DT"]/value'
							, WGI_DTR_RECON_ISSUE_DT	VARCHAR2(10) PATH './item[id="WGI_DTR_RECON_ISSUE_DT"]/value'
							, WGI_DTR_DENIED	NVARCHAR2(3) PATH './item[id="WGI_DTR_DENIED"]/value'
							, WGI_DTR_DENIAL_ISSUE_TO_EMP_DT	VARCHAR2(10) PATH './item[id="WGI_DTR_DENIAL_ISSUE_TO_EMP_DT"]/value'							
							, WGI_RVW_REDTR_NOTI_ISSUED_DT	VARCHAR2(10) PATH './item[id="WGI_REVIEW_DTR_NOTICE_ISSUED_DT"]/value'
							, WGI_REVIEW_DTR_FAVORABLE	NVARCHAR2(3) PATH './item[id="WGI_REVIEW_DTR_FAVORABLE"]/value'
							, WGI_REVIEW_EMP_REQ_RECON	NVARCHAR2(3) PATH './item[id="WGI_REVIEW_EMP_REQ_RECON"]/value'
							, WGI_REVIEW_RECON_REQ_DT	VARCHAR2(10) PATH './item[id="WGI_REVIEW_RECON_REQ_DT"]/value'
							, WGI_REVIEW_RECON_ISSUE_DT	VARCHAR2(10) PATH './item[id="WGI_REVIEW_RECON_ISSUE_DT"]/value'
							, WGI_REVIEW_DENIED	NVARCHAR2(3) PATH './item[id="WGI_REVIEW_DENIED"]/value'
							, WGI_EMP_APPEAL_DECISION	NVARCHAR2(3) PATH './item[id="WGI_EMP_APPEAL_DECISION"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
            	TRG.WGI_DTR_DENIAL_ISSUED_DT = SRC.WGI_DTR_DENIAL_ISSUED_DT
				, TRG.WGI_DTR_EMP_REQ_RECON = SRC.WGI_DTR_EMP_REQ_RECON
				, TRG.WGI_DTR_RECON_REQ_DT = SRC.WGI_DTR_RECON_REQ_DT
				, TRG.WGI_DTR_RECON_ISSUE_DT = SRC.WGI_DTR_RECON_ISSUE_DT
				, TRG.WGI_DTR_DENIED = SRC.WGI_DTR_DENIED
				, TRG.WGI_DTR_DENIAL_ISSUE_TO_EMP_DT = SRC.WGI_DTR_DENIAL_ISSUE_TO_EMP_DT
				, TRG.WGI_RVW_REDTR_NOTI_ISSUED_DT = SRC.WGI_RVW_REDTR_NOTI_ISSUED_DT
				, TRG.WGI_REVIEW_DTR_FAVORABLE = SRC.WGI_REVIEW_DTR_FAVORABLE
				, TRG.WGI_REVIEW_EMP_REQ_RECON = SRC.WGI_REVIEW_EMP_REQ_RECON
				, TRG.WGI_REVIEW_RECON_REQ_DT = SRC.WGI_REVIEW_RECON_REQ_DT
				, TRG.WGI_REVIEW_RECON_ISSUE_DT = SRC.WGI_REVIEW_RECON_ISSUE_DT
				, TRG.WGI_REVIEW_DENIED = SRC.WGI_REVIEW_DENIED
				, TRG.WGI_EMP_APPEAL_DECISION = SRC.WGI_EMP_APPEAL_DECISION
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.WGI_DTR_DENIAL_ISSUED_DT
				, TRG.WGI_DTR_EMP_REQ_RECON
				, TRG.WGI_DTR_RECON_REQ_DT
				, TRG.WGI_DTR_RECON_ISSUE_DT
				, TRG.WGI_DTR_DENIED
				, TRG.WGI_DTR_DENIAL_ISSUE_TO_EMP_DT
				, TRG.WGI_RVW_REDTR_NOTI_ISSUED_DT
				, TRG.WGI_REVIEW_DTR_FAVORABLE
				, TRG.WGI_REVIEW_EMP_REQ_RECON
				, TRG.WGI_REVIEW_RECON_REQ_DT
				, TRG.WGI_REVIEW_RECON_ISSUE_DT
				, TRG.WGI_REVIEW_DENIED
				, TRG.WGI_EMP_APPEAL_DECISION
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.WGI_DTR_DENIAL_ISSUED_DT
				, SRC.WGI_DTR_EMP_REQ_RECON
				, SRC.WGI_DTR_RECON_REQ_DT
				, SRC.WGI_DTR_RECON_ISSUE_DT
				, SRC.WGI_DTR_DENIED
				, SRC.WGI_DTR_DENIAL_ISSUE_TO_EMP_DT
				, SRC.WGI_RVW_REDTR_NOTI_ISSUED_DT
				, SRC.WGI_REVIEW_DTR_FAVORABLE
				, SRC.WGI_REVIEW_EMP_REQ_RECON
				, SRC.WGI_REVIEW_RECON_REQ_DT
				, SRC.WGI_REVIEW_RECON_ISSUE_DT
				, SRC.WGI_REVIEW_DENIED
				, SRC.WGI_EMP_APPEAL_DECISION
               
            );

		END;

		--------------------------------
		-- ERLR_MEDDOC table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_MEDDOC TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.MD_REQUEST_REASON
					, TO_DATE(X.MD_MED_DOC_SBMT_DEADLINE_DT,'MM/DD/YYYY HH24:MI:SS') AS MD_MED_DOC_SBMT_DEADLINE_DT
					, TO_DATE(X.MD_FMLA_DOC_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS MD_FMLA_DOC_SBMT_DT
					, TO_DATE(X.MD_FMLA_BEGIN_DT,'MM/DD/YYYY HH24:MI:SS') AS MD_FMLA_BEGIN_DT
					, X.MD_FMLA_APROVED
					, X.MD_FMLA_DISAPRV_REASON
					, X.MD_FMLA_GRIEVANCE
					, X.MD_MEDEXAM_EXTENDED
					, X.MD_MEDEXAM_ACCEPTED
					, TO_DATE(X.MD_MEDEXAM_RECEIVED_DT,'MM/DD/YYYY HH24:MI:SS') AS MD_MEDEXAM_RECEIVED_DT
					, X.MD_DOC_SUBMITTED
					, TO_DATE(X.MD_DOC_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS MD_DOC_SBMT_DT
					, X.MD_DOC_SBMT_FOH
					, X.MD_DOC_REVIEW_OUTCOME
					, X.MD_DOC_ADMTV_ACCEPTABLE
					, X.MD_DOC_ADMTV_REJECT_REASON
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS                            
							MD_REQUEST_REASON	NUMBER(20,0) PATH './item[id="MD_REQUEST_REASON"]/value'
							, MD_MED_DOC_SBMT_DEADLINE_DT	NVARCHAR2(10) PATH './item[id="MD_MED_DOC_SBMT_DEADLINE_DT"]/value'
							, MD_FMLA_DOC_SBMT_DT	NVARCHAR2(10) PATH './item[id="MD_FMLA_DOC_SBMT_DT"]/value'
							, MD_FMLA_BEGIN_DT	NVARCHAR2(10) PATH './item[id="MD_FMLA_BEGIN_DT"]/value'
							, MD_FMLA_APROVED	NVARCHAR2(3) PATH './item[id="MD_FMLA_APROVED"]/value'
							, MD_FMLA_DISAPRV_REASON	NUMBER(20,0) PATH './item[id="MD_FMLA_DISAPRV_REASON"]/value'
							, MD_FMLA_GRIEVANCE	NVARCHAR2(3) PATH './item[id="MD_FMLA_GRIEVANCE"]/value'
							, MD_MEDEXAM_EXTENDED	NVARCHAR2(3) PATH './item[id="MD_MEDEXAM_EXTENDED"]/value'
							, MD_MEDEXAM_ACCEPTED	NVARCHAR2(3) PATH './item[id="MD_MEDEXAM_ACCEPTED"]/value'
							, MD_MEDEXAM_RECEIVED_DT	NVARCHAR2(10) PATH './item[id="MD_MEDEXAM_RECEIVED_DT"]/value'
							, MD_DOC_SUBMITTED	NVARCHAR2(3) PATH './item[id="MD_DOC_SUBMITTED"]/value'
							, MD_DOC_SBMT_DT	NVARCHAR2(10) PATH './item[id="MD_DOC_SBMT_DT"]/value'
							, MD_DOC_SBMT_FOH	NVARCHAR2(3) PATH './item[id="MD_DOC_SBMT_FOH"]/value'
							, MD_DOC_REVIEW_OUTCOME	NVARCHAR2(140) PATH './item[id="MD_DOC_REVIEW_OUTCOME"]/value'
							, MD_DOC_ADMTV_ACCEPTABLE	NVARCHAR2(3) PATH './item[id="MD_DOC_ADMTV_ACCEPTABLE"]/value'
							, MD_DOC_ADMTV_REJECT_REASON	NUMBER(20,0) PATH './item[id="MD_DOC_ADMTV_REJECT_REASON"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
				TRG.MD_REQUEST_REASON = SRC.MD_REQUEST_REASON
				, TRG.MD_MED_DOC_SBMT_DEADLINE_DT = SRC.MD_MED_DOC_SBMT_DEADLINE_DT
				, TRG.MD_FMLA_DOC_SBMT_DT = SRC.MD_FMLA_DOC_SBMT_DT
				, TRG.MD_FMLA_BEGIN_DT = SRC.MD_FMLA_BEGIN_DT
				, TRG.MD_FMLA_APROVED = SRC.MD_FMLA_APROVED
				, TRG.MD_FMLA_DISAPRV_REASON = SRC.MD_FMLA_DISAPRV_REASON
				, TRG.MD_FMLA_GRIEVANCE = SRC.MD_FMLA_GRIEVANCE
				, TRG.MD_MEDEXAM_EXTENDED = SRC.MD_MEDEXAM_EXTENDED
				, TRG.MD_MEDEXAM_ACCEPTED = SRC.MD_MEDEXAM_ACCEPTED
				, TRG.MD_MEDEXAM_RECEIVED_DT = SRC.MD_MEDEXAM_RECEIVED_DT
				, TRG.MD_DOC_SUBMITTED = SRC.MD_DOC_SUBMITTED
				, TRG.MD_DOC_SBMT_DT = SRC.MD_DOC_SBMT_DT
				, TRG.MD_DOC_SBMT_FOH = SRC.MD_DOC_SBMT_FOH
				, TRG.MD_DOC_REVIEW_OUTCOME = SRC.MD_DOC_REVIEW_OUTCOME
				, TRG.MD_DOC_ADMTV_ACCEPTABLE = SRC.MD_DOC_ADMTV_ACCEPTABLE
				, TRG.MD_DOC_ADMTV_REJECT_REASON = SRC.MD_DOC_ADMTV_REJECT_REASON
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.MD_REQUEST_REASON
				, TRG.MD_MED_DOC_SBMT_DEADLINE_DT
				, TRG.MD_FMLA_DOC_SBMT_DT
				, TRG.MD_FMLA_BEGIN_DT
				, TRG.MD_FMLA_APROVED
				, TRG.MD_FMLA_DISAPRV_REASON
				, TRG.MD_FMLA_GRIEVANCE
				, TRG.MD_MEDEXAM_EXTENDED
				, TRG.MD_MEDEXAM_ACCEPTED
				, TRG.MD_MEDEXAM_RECEIVED_DT
				, TRG.MD_DOC_SUBMITTED
				, TRG.MD_DOC_SBMT_DT
				, TRG.MD_DOC_SBMT_FOH
				, TRG.MD_DOC_REVIEW_OUTCOME
				, TRG.MD_DOC_ADMTV_ACCEPTABLE
				, TRG.MD_DOC_ADMTV_REJECT_REASON
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.MD_REQUEST_REASON
				, SRC.MD_MED_DOC_SBMT_DEADLINE_DT
				, SRC.MD_FMLA_DOC_SBMT_DT
				, SRC.MD_FMLA_BEGIN_DT
				, SRC.MD_FMLA_APROVED
				, SRC.MD_FMLA_DISAPRV_REASON
				, SRC.MD_FMLA_GRIEVANCE
				, SRC.MD_MEDEXAM_EXTENDED
				, SRC.MD_MEDEXAM_ACCEPTED
				, SRC.MD_MEDEXAM_RECEIVED_DT
				, SRC.MD_DOC_SUBMITTED
				, SRC.MD_DOC_SBMT_DT
				, SRC.MD_DOC_SBMT_FOH
				, SRC.MD_DOC_REVIEW_OUTCOME
				, SRC.MD_DOC_ADMTV_ACCEPTABLE
				, SRC.MD_DOC_ADMTV_REJECT_REASON
               
            );

		END;

		--------------------------------
		-- ERLR_INFO_REQUEST table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_INFO_REQUEST TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.IR_REQUESTER	
					, X.IR_CMS_REQUESTER_NAME	
					, X.IR_CMS_REQUESTER_PHONE	
					, X.IR_NCMS_REQUESTER_LAST_NAME	
					, X.IR_NCMS_REQUESTER_FIRST_NAME
					, X.IR_NCMS_REQUESTER_MN	
					, X.IR_NON_CMS_REQUESTER_PHONE	
					, X.IR_NON_CMS_REQUESTER_EMAIL	
					, X.IR_NCMS_REQUESTER_ORG_AFFIL	
					, TO_DATE(X.IR_SUBMIT_DT,'MM/DD/YYYY HH24:MI:SS') AS IR_SUBMIT_DT
					, X.IR_MEET_PTCLRIZED_NEED_STND
					, X.IR_RSNABLY_AVAIL_N_NECESSARY
					, X.IR_PRTCT_DISCLOSURE_BY_LAW
					, X.IR_MAINTAINED_BY_AGENCY
					, X.IR_COLLECTIVE_BARGAINING_UNIT
					/*, X.IR_APPROVE
					, TO_DATE(X.IR_PROVIDE_DT,'MM/DD/YYYY HH24:MI:SS') AS IR_PROVIDE_DT
					, X.IR_DENIAL_NOTICE_DT_LIST
					, X.IR_APPEAL_DENIAL
                    */
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            IR_REQUESTER	NVARCHAR2(20)	 PATH './item[id="IR_REQUESTER"]/value'
							, IR_CMS_REQUESTER_NAME	NVARCHAR2(200)	PATH './item[id="IR_CMS_REQUESTER_NAME"]/value/value'
							, IR_CMS_REQUESTER_PHONE	NVARCHAR2(50)	PATH './item[id="IR_CMS_REQUESTER_PHONE"]/value'
							, IR_NCMS_REQUESTER_LAST_NAME	NVARCHAR2(50)	PATH './item[id="IR_NON_CMS_REQUESTER_LAST_NAME"]/value'
							, IR_NCMS_REQUESTER_FIRST_NAME	NVARCHAR2(50)	PATH './item[id="IR_NON_CMS_REQUESTER_FIRST_NAME"]/value'
							, IR_NCMS_REQUESTER_MN	NVARCHAR2(50)	PATH './item[id="IR_NON_CMS_REQUESTER_MIDDLE_NAME"]/value'
							, IR_NON_CMS_REQUESTER_PHONE	NVARCHAR2(50)	PATH './item[id="IR_NON_CMS_REQUESTER_PHONE"]/value'
							, IR_NON_CMS_REQUESTER_EMAIL	NVARCHAR2(100)	PATH './item[id="IR_NON_CMS_REQUESTER_EMAIL"]/value'
							, IR_NCMS_REQUESTER_ORG_AFFIL	NVARCHAR2(50)	PATH './item[id="IR_NON_CMS_REQUESTER_ORGANIZATION_AFFILIATION"]/value'
							, IR_SUBMIT_DT	NVARCHAR2(10)	PATH './item[id="IR_SUBMIT_DT"]/value'
							, IR_MEET_PTCLRIZED_NEED_STND	VARCHAR2(3)	PATH './item[id="IR_MEET_PARTICULARIZED_NEED_STANDARD"]/value'
							, IR_RSNABLY_AVAIL_N_NECESSARY	VARCHAR2(3)	PATH './item[id="IR_REASONABLY_AVAILABLE_AND_NECESSARY"]/value'
							, IR_PRTCT_DISCLOSURE_BY_LAW	VARCHAR2(3)	PATH './item[id="IR_PROTECTED_FROM_DISCLOSURE_BY_LAW"]/value'
							, IR_MAINTAINED_BY_AGENCY	VARCHAR2(3)	PATH './item[id="IR_MAINTAINED_BY_AGENCY"]/value'
							, IR_COLLECTIVE_BARGAINING_UNIT	VARCHAR2(3)	PATH './item[id="IR_COLLECTIVE_BARGAINING_UNIT"]/value'
						/*	, IR_APPROVE	VARCHAR2(3)	PATH './item[id="IR_APPROVE"]/value'
							, IR_PROVIDE_DT	VARCHAR2(10)	PATH './item[id="IR_PROVIDE_DT"]/value'
							, IR_DENIAL_NOTICE_DT_LIST	VARCHAR2(4000)	PATH './item[id="IR_PROVIDE_DT_LIST"]/value'
							, IR_APPEAL_DENIAL	VARCHAR2(3)	PATH './item[id="IR_APPEAL_DENIAL"]/value'
							*/
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
                TRG.IR_REQUESTER = SRC.IR_REQUESTER
				, TRG.IR_CMS_REQUESTER_NAME = SRC.IR_CMS_REQUESTER_NAME
				, TRG.IR_CMS_REQUESTER_PHONE = SRC.IR_CMS_REQUESTER_PHONE
				, TRG.IR_NCMS_REQUESTER_LAST_NAME = SRC.IR_NCMS_REQUESTER_LAST_NAME
				, TRG.IR_NCMS_REQUESTER_FIRST_NAME = SRC.IR_NCMS_REQUESTER_FIRST_NAME				
				, TRG.IR_NCMS_REQUESTER_MN = SRC.IR_NCMS_REQUESTER_MN
				, TRG.IR_NON_CMS_REQUESTER_PHONE = SRC.IR_NON_CMS_REQUESTER_PHONE
				, TRG.IR_NON_CMS_REQUESTER_EMAIL = 	SRC.IR_NON_CMS_REQUESTER_EMAIL
				, TRG.IR_NCMS_REQUESTER_ORG_AFFIL = SRC.IR_NCMS_REQUESTER_ORG_AFFIL
				, TRG.IR_SUBMIT_DT = SRC.IR_SUBMIT_DT
				, TRG.IR_MEET_PTCLRIZED_NEED_STND = SRC.IR_MEET_PTCLRIZED_NEED_STND
				, TRG.IR_RSNABLY_AVAIL_N_NECESSARY = SRC.IR_RSNABLY_AVAIL_N_NECESSARY
				, TRG.IR_PRTCT_DISCLOSURE_BY_LAW = SRC.IR_PRTCT_DISCLOSURE_BY_LAW
				, TRG.IR_MAINTAINED_BY_AGENCY = SRC.IR_MAINTAINED_BY_AGENCY
				, TRG.IR_COLLECTIVE_BARGAINING_UNIT = SRC.IR_COLLECTIVE_BARGAINING_UNIT
			/*	, TRG.IR_APPROVE = SRC.IR_APPROVE
				, TRG.IR_PROVIDE_DT = SRC.IR_PROVIDE_DT
				, TRG.IR_DENIAL_NOTICE_DT_LIST = SRC.IR_DENIAL_NOTICE_DT_LIST
				, TRG.IR_APPEAL_DENIAL = SRC.IR_APPEAL_DENIAL
				*/
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.IR_REQUESTER	
				, TRG.IR_CMS_REQUESTER_NAME	
				, TRG.IR_CMS_REQUESTER_PHONE	
				, TRG.IR_NCMS_REQUESTER_LAST_NAME	
				, TRG.IR_NCMS_REQUESTER_FIRST_NAME
				, TRG.IR_NCMS_REQUESTER_MN	
				, TRG.IR_NON_CMS_REQUESTER_PHONE	
				, TRG.IR_NON_CMS_REQUESTER_EMAIL	
				, TRG.IR_NCMS_REQUESTER_ORG_AFFIL	
				, TRG.IR_SUBMIT_DT
				, TRG.IR_MEET_PTCLRIZED_NEED_STND
				, TRG.IR_RSNABLY_AVAIL_N_NECESSARY
				, TRG.IR_PRTCT_DISCLOSURE_BY_LAW
				, TRG.IR_MAINTAINED_BY_AGENCY
				, TRG.IR_COLLECTIVE_BARGAINING_UNIT
			/*	, TRG.IR_APPROVE
				, TRG.IR_PROVIDE_DT
				, TRG.IR_DENIAL_NOTICE_DT_LIST
				, TRG.IR_APPEAL_DENIAL
              */ 
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.IR_REQUESTER	
				, SRC.IR_CMS_REQUESTER_NAME	
				, SRC.IR_CMS_REQUESTER_PHONE	
				, SRC.IR_NCMS_REQUESTER_LAST_NAME	
				, SRC.IR_NCMS_REQUESTER_FIRST_NAME
				, SRC.IR_NCMS_REQUESTER_MN	
				, SRC.IR_NON_CMS_REQUESTER_PHONE	
				, SRC.IR_NON_CMS_REQUESTER_EMAIL	
				, SRC.IR_NCMS_REQUESTER_ORG_AFFIL	
				, SRC.IR_SUBMIT_DT
				, SRC.IR_MEET_PTCLRIZED_NEED_STND
				, SRC.IR_RSNABLY_AVAIL_N_NECESSARY
				, SRC.IR_PRTCT_DISCLOSURE_BY_LAW
				, SRC.IR_MAINTAINED_BY_AGENCY
				, SRC.IR_COLLECTIVE_BARGAINING_UNIT
			/*	, SRC.IR_APPROVE
				, SRC.IR_PROVIDE_DT
				, SRC.IR_DENIAL_NOTICE_DT_LIST
				, SRC.IR_APPEAL_DENIAL
             */  
            );

		END;

		--------------------------------
		-- ERLR_3RDPARTY_HEAR table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_3RDPARTY_HEAR TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, THRD_PRTY_APPEAL_TYPE
					, TO_DATE(X.THRD_PRTY_APPEAL_FILE_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_APPEAL_FILE_DT
					, TO_DATE(X.THRD_PRTY_ASSISTANCE_REQ_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_ASSISTANCE_REQ_DT	
					, THRD_PRTY_HEARING_TIMING
					, THRD_PRTY_HEARING_REQUESTED
					, TO_DATE(X.THRD_PRTY_STEP_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_STEP_DECISION_DT	
					, THRD_PRTY_ARBITRATION_INVOKED
					, THRD_PRTY_ARBIT_LNM_3
					, THRD_PRTY_ARBIT_FNM_3
					, THRD_PRTY_ARBIT_MNM_3
					, THRD_PRTY_ARBIT_EMAIL_3
					, THRD_ERLR_ARBIT_PHONE_NUM_3
					, THRD_PRTY_ARBIT_ORG_AFFIL_3
					, THRD_PRTY_ARBIT_MAILING_ADDR_3
					, TO_DATE(X.THRD_PRTY_PREHEARING_DT_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_PREHEARING_DT_2	
					, TO_DATE(X.THRD_PRTY_HEARING_DT_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_HEARING_DT_2	
					, TO_DATE(X.THRD_PRTY_POSTHEAR_BRIEF_DUE_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_POSTHEAR_BRIEF_DUE_2	
					, TO_DATE(X.THRD_PRTY_FNL_ARBIT_DCSN_DT_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_FNL_ARBIT_DCSN_DT_2	
					, THRD_PRTY_EXCEPTION_FILED_2
					, TO_DATE(X.THRD_PRTY_EXCEPTION_FILE_DT_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_EXCEPTION_FILE_DT_2	
					, TO_DATE(X.THRD_PRTY_RSPS_TO_EXCPT_DUE_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_RSPS_TO_EXCPT_DUE_2	
					, TO_DATE(X.THRD_PRTY_FNL_FLRA_DCSN_DT_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_FNL_FLRA_DCSN_DT_2	
					, THRD_PRTY_ARBIT_LNM
					, THRD_PRTY_ARBIT_FNM
					, THRD_PRTY_ARBIT_MNM
					, THRD_PRTY_ARBIT_EMAIL
					, THRD_ERLR_ARBIT_PHONE_NUM
					, THRD_PRTY_ARBIT_ORG_AFFIL
					, THRD_PRTY_ARBIT_MAILING_ADDR
					, TO_DATE(X.THRD_PRTY_PREHEARING_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_PREHEARING_DT	
					, TO_DATE(X.THRD_PRTY_HEARING_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_HEARING_DT	
					, TO_DATE(X.THRD_PRTY_POSTHEAR_BRIEF_DUE,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_POSTHEAR_BRIEF_DUE	
					, TO_DATE(X.THRD_PRTY_FNL_ARBIT_DCSN_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_FNL_ARBIT_DCSN_DT	
					, THRD_PRTY_EXCEPTION_FILED
					, TO_DATE(X.THRD_PRTY_EXCEPTION_FILE_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_EXCEPTION_FILE_DT	
					, TO_DATE(X.THRD_PRTY_RSPS_TO_EXCPT_DUE,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_RSPS_TO_EXCPT_DUE	
					, TO_DATE(X.THRD_PRTY_FNL_FLRA_DCSN_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_FNL_FLRA_DCSN_DT	
					, THRD_PRTY_ARBIT_LNM_4
					, THRD_PRTY_ARBIT_FNM_4
					, THRD_PRTY_ARBIT_MNM_4
					, THRD_PRTY_ARBIT_EMAIL_4
					, THRD_ERLR_ARBIT_PHONE_NUM_4
					, THRD_PRTY_ARBIT_ORG_AFFIL_4
					, THRD_PRTY_ARBIT_MAILING_ADDR_4
					, TO_DATE(X.THRD_PRTY_DT_STLMNT_DSCUSN,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_STLMNT_DSCUSN	
					, TO_DATE(X.THRD_PRTY_DT_PREHEAR_DSCLS,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_PREHEAR_DSCLS	
					, TO_DATE(X.THRD_PRTY_DT_AGNCY_RSP_DUE,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_AGNCY_RSP_DUE	
					, TO_DATE(X.THRD_PRTY_PREHEARING_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_PREHEARING_DT_MSPB	
					, THRD_PRTY_WAS_DSCVRY_INIT
					, TO_DATE(X.THRD_PRTY_DT_DISCOVERY_DUE,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_DISCOVERY_DUE	
					, TO_DATE(X.THRD_PRTY_HEARING_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_HEARING_DT_MSPB	
					, TO_DATE(X.THRD_PRTY_INIT_DCSN_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_INIT_DCSN_DT_MSPB	
					, THRD_PRTY_WAS_PETI_FILED_MSPB
					, TO_DATE(X.THRD_PRTY_PETITION_RV_DT,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_PETITION_RV_DT	
					, TO_DATE(X.THRD_PRTY_FNL_BRD_DCSN_DT_MSPB,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_FNL_BRD_DCSN_DT_MSPB	
					, TO_DATE(X.THRD_PRTY_DT_STLMNT_DSCUSN_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_STLMNT_DSCUSN_2	
					, TO_DATE(X.THRD_PRTY_DT_PREHEAR_DSCLS_2,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DT_PREHEAR_DSCLS_2	
					, TO_DATE(X.THRD_PRTY_PREHEARING_CONF,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_PREHEARING_CONF	
					, TO_DATE(X.THRD_PRTY_HEARING_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_HEARING_DT_FLRA	
					, TO_DATE(X.THRD_PRTY_DECISION_DT_FLRA,'MM/DD/YYYY HH24:MI:SS') AS THRD_PRTY_DECISION_DT_FLRA	
					, THRD_PRTY_TIMELY_REQ
					, THRD_PRTY_PROC_ORDER
					, THRD_PRTY_PANEL_MEMBER_LNAME
					, THRD_PRTY_PANEL_MEMBER_FNAME
					, THRD_PRTY_PANEL_MEMBER_MNAME
					, THRD_PRTY_PANEL_MEMBER_EMAIL
					, THRD_PRTY_PANEL_MEMBER_PHONE
					, THRD_PRTY_PANEL_MEMBER_ORG
					, THRD_PRTY_PANEL_MEMBER_MAILING
					, THRD_PRTY_PANEL_DESCR
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            THRD_PRTY_APPEAL_TYPE	NVARCHAR2(200)	PATH './item[id="THRD_PRTY_APPEAL_TYPE"]/value'
							, THRD_PRTY_APPEAL_FILE_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_APPEAL_FILE_DT"]/value'
							, THRD_PRTY_ASSISTANCE_REQ_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_ASSISTANCE_REQ_DT"]/value'
							, THRD_PRTY_HEARING_TIMING	VARCHAR2(3)	PATH './item[id="THRD_PRTY_HEARING_TIMING"]/value'
							, THRD_PRTY_HEARING_REQUESTED	VARCHAR2(3)	PATH './item[id="THRD_PRTY_HEARING_REQUESTED"]/value'
							, THRD_PRTY_STEP_DECISION_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_STEP_DECISION_DT"]/value'
							, THRD_PRTY_ARBITRATION_INVOKED	VARCHAR2(3)	PATH './item[id="THRD_PRTY_ARBITRATION_INVOKED"]/value'
							, THRD_PRTY_ARBIT_LNM_3	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_LAST_NAME_3"]/value'
							, THRD_PRTY_ARBIT_FNM_3	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_FIRST_NAME_3"]/value'
							, THRD_PRTY_ARBIT_MNM_3	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_MIDDLE_NAME_3"]/value'
							, THRD_PRTY_ARBIT_EMAIL_3	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATOR_EMAIL_3"]/value'
							, THRD_ERLR_ARBIT_PHONE_NUM_3	NVARCHAR2(50)	PATH './item[id="THRD_ERLR_ARBITRATOR_PHONE_NUMBER_3"]/value'
							, THRD_PRTY_ARBIT_ORG_AFFIL_3	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATION_ORGANIZATION_AFFILIATION_3"]/value'
							, THRD_PRTY_ARBIT_MAILING_ADDR_3	NVARCHAR2(250)	PATH './item[id="THRD_PRTY_ARBITRATION_MAILING_ADDR_3"]/value'
							, THRD_PRTY_PREHEARING_DT_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_PREHEARING_DT_2"]/value'
							, THRD_PRTY_HEARING_DT_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_HEARING_DT_2"]/value'
							, THRD_PRTY_POSTHEAR_BRIEF_DUE_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_POSTHEARING_BRIEF_DUE_2"]/value'
							, THRD_PRTY_FNL_ARBIT_DCSN_DT_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_FINAL_ARBITRATOR_DECISION_DT_2"]/value'
							, THRD_PRTY_EXCEPTION_FILED_2	VARCHAR2(3)	PATH './item[id="THRD_PRTY_EXCEPTION_FILED_2"]/value'
							, THRD_PRTY_EXCEPTION_FILE_DT_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_EXCEPTION_FILE_DT_2"]/value'
							, THRD_PRTY_RSPS_TO_EXCPT_DUE_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_RESPONSE_TO_EXCEPTIONS_DUE_2"]/value'
							, THRD_PRTY_FNL_FLRA_DCSN_DT_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_FINAL_FLRA_DECISION_DT_2"]/value'
							, THRD_PRTY_ARBIT_LNM	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_LAST_NAME"]/value'
							, THRD_PRTY_ARBIT_FNM	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_FIRST_NAME"]/value'
							, THRD_PRTY_ARBIT_MNM	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_MIDDLE_NAME"]/value'
							, THRD_PRTY_ARBIT_EMAIL	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATOR_EMAIL"]/value'
							, THRD_ERLR_ARBIT_PHONE_NUM	NVARCHAR2(50)	PATH './item[id="THRD_ERLR_ARBITRATOR_PHONE_NUMBER"]/value'
							, THRD_PRTY_ARBIT_ORG_AFFIL	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATION_ORGANIZATION_AFFILIATION"]/value'
							, THRD_PRTY_ARBIT_MAILING_ADDR	NVARCHAR2(250)	PATH './item[id="THRD_PRTY_ARBITRATION_MAILING_ADDR"]/value'
							, THRD_PRTY_PREHEARING_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_PREHEARING_DT"]/value'
							, THRD_PRTY_HEARING_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_HEARING_DT"]/value'
							, THRD_PRTY_POSTHEAR_BRIEF_DUE	VARCHAR2(10)	PATH './item[id="THRD_PRTY_POSTHEARING_BRIEF_DUE"]/value'
							, THRD_PRTY_FNL_ARBIT_DCSN_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_FINAL_ARBITRATOR_DECISION_DT"]/value'
							, THRD_PRTY_EXCEPTION_FILED	VARCHAR2(3)	PATH './item[id="THRD_PRTY_EXCEPTION_FILED"]/value'
							, THRD_PRTY_EXCEPTION_FILE_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_EXCEPTION_FILE_DT"]/value'
							, THRD_PRTY_RSPS_TO_EXCPT_DUE	VARCHAR2(10)	PATH './item[id="THRD_PRTY_RESPONSE_TO_EXCEPTIONS_DUE"]/value'
							, THRD_PRTY_FNL_FLRA_DCSN_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_FINAL_FLRA_DECISION_DT"]/value'
							, THRD_PRTY_ARBIT_LNM_4	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_LAST_NAME_4"]/value'
							, THRD_PRTY_ARBIT_FNM_4	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_FIRST_NAME_4"]/value'
							, THRD_PRTY_ARBIT_MNM_4	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_ARBITRATOR_MIDDLE_NAME_4"]/value'
							, THRD_PRTY_ARBIT_EMAIL_4	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATOR_EMAIL_4"]/value'
							, THRD_ERLR_ARBIT_PHONE_NUM_4	NVARCHAR2(50)	PATH './item[id="THRD_ERLR_ARBITRATOR_PHONE_NUMBER_4"]/value'
							, THRD_PRTY_ARBIT_ORG_AFFIL_4	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_ARBITRATION_ORGANIZATION_AFFILIATION_4"]/value'
							, THRD_PRTY_ARBIT_MAILING_ADDR_4	NVARCHAR2(250)	PATH './item[id="THRD_PRTY_ARBITRATION_MAILING_ADDR_4"]/value'
							, THRD_PRTY_DT_STLMNT_DSCUSN	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_SETTLEMENT_DISCUSSION"]/value'
							, THRD_PRTY_DT_PREHEAR_DSCLS	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_PREHEARING_DISCLOSURE"]/value'
							, THRD_PRTY_DT_AGNCY_RSP_DUE	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_AGENCY_FILE_RESPONSE_DUE"]/value'
							, THRD_PRTY_PREHEARING_DT_MSPB	VARCHAR2(10)	PATH './item[id="THRD_PRTY_PREHEARING_DT_MSPB"]/value'
							, THRD_PRTY_WAS_DSCVRY_INIT	VARCHAR2(3)	PATH './item[id="THRD_PRTY_WAS_DISCOVERY_INITIATED"]/value'
							, THRD_PRTY_DT_DISCOVERY_DUE	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_DISCOVERY_DUE"]/value'
							, THRD_PRTY_HEARING_DT_MSPB	VARCHAR2(10)	PATH './item[id="THRD_PRTY_HEARING_DT_MSPB"]/value'
							, THRD_PRTY_INIT_DCSN_DT_MSPB	VARCHAR2(10)	PATH './item[id="THRD_PRTY_INITIAL_DECISION_DT_MSPB"]/value'
							, THRD_PRTY_WAS_PETI_FILED_MSPB	VARCHAR2(3)	PATH './item[id="THRD_PRTY_WAS_PETITION_FILED_MSPB"]/value'
							, THRD_PRTY_PETITION_RV_DT	VARCHAR2(10)	PATH './item[id="THRD_PRTY_PETITION_RV_DT"]/value'
							, THRD_PRTY_FNL_BRD_DCSN_DT_MSPB	VARCHAR2(10)	PATH './item[id="THRD_PRTY_FINAL_BOARD_DECISION_DT_MSPB"]/value'
							, THRD_PRTY_DT_STLMNT_DSCUSN_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_SETTLEMENT_DISCUSSION_2"]/value'
							, THRD_PRTY_DT_PREHEAR_DSCLS_2	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DT_PREHEARING_DISCLOSURE_2"]/value'
							, THRD_PRTY_PREHEARING_CONF	VARCHAR2(10)	PATH './item[id="THRD_PRTY_PREHEARING_CONF"]/value'
							, THRD_PRTY_HEARING_DT_FLRA	VARCHAR2(10)	PATH './item[id="THRD_PRTY_HEARING_DT_FLRA"]/value'
							, THRD_PRTY_DECISION_DT_FLRA	VARCHAR2(10)	PATH './item[id="THRD_PRTY_DECISION_DT_FLRA"]/value'
							, THRD_PRTY_TIMELY_REQ	VARCHAR2(3)	PATH './item[id="THRD_PRTY_TIMELY_REQ"]/value'
							, THRD_PRTY_PROC_ORDER	NVARCHAR2(2000)	PATH './item[id="THRD_PRTY_PROC_ORDER"]/value'
							, THRD_PRTY_PANEL_MEMBER_LNAME	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_LNAME"]/value'
							, THRD_PRTY_PANEL_MEMBER_FNAME	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_FNAME"]/value'
							, THRD_PRTY_PANEL_MEMBER_MNAME	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_MNAME"]/value'
							, THRD_PRTY_PANEL_MEMBER_EMAIL	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_EMAIL"]/value'
							, THRD_PRTY_PANEL_MEMBER_PHONE	NVARCHAR2(50)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_PHONE"]/value'
							, THRD_PRTY_PANEL_MEMBER_ORG	NVARCHAR2(100)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_ORG"]/value'
							, THRD_PRTY_PANEL_MEMBER_MAILING	NVARCHAR2(250)	PATH './item[id="THRD_PRTY_PANEL_MEMBER_MAILING"]/value'
							, THRD_PRTY_PANEL_DESCR	NVARCHAR2(500)	PATH './item[id="THRD_PRTY_PANEL_DESCR"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET                
				TRG.THRD_PRTY_APPEAL_TYPE = SRC.THRD_PRTY_APPEAL_TYPE
				, TRG.THRD_PRTY_APPEAL_FILE_DT = SRC.THRD_PRTY_APPEAL_FILE_DT
				, TRG.THRD_PRTY_ASSISTANCE_REQ_DT = SRC.THRD_PRTY_ASSISTANCE_REQ_DT
				, TRG.THRD_PRTY_HEARING_TIMING = SRC.THRD_PRTY_HEARING_TIMING
				, TRG.THRD_PRTY_HEARING_REQUESTED = SRC.THRD_PRTY_HEARING_REQUESTED
				, TRG.THRD_PRTY_STEP_DECISION_DT = SRC.THRD_PRTY_STEP_DECISION_DT
				, TRG.THRD_PRTY_ARBITRATION_INVOKED = SRC.THRD_PRTY_ARBITRATION_INVOKED
				, TRG.THRD_PRTY_ARBIT_LNM_3 = SRC.THRD_PRTY_ARBIT_LNM_3
				, TRG.THRD_PRTY_ARBIT_FNM_3 = SRC.THRD_PRTY_ARBIT_FNM_3
				, TRG.THRD_PRTY_ARBIT_MNM_3 = SRC.THRD_PRTY_ARBIT_MNM_3
				, TRG.THRD_PRTY_ARBIT_EMAIL_3 = SRC.THRD_PRTY_ARBIT_EMAIL_3
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM_3 = SRC.THRD_ERLR_ARBIT_PHONE_NUM_3
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL_3 = SRC.THRD_PRTY_ARBIT_ORG_AFFIL_3
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR_3 = SRC.THRD_PRTY_ARBIT_MAILING_ADDR_3
				, TRG.THRD_PRTY_PREHEARING_DT_2 = SRC.THRD_PRTY_PREHEARING_DT_2
				, TRG.THRD_PRTY_HEARING_DT_2 = SRC.THRD_PRTY_HEARING_DT_2
				, TRG.THRD_PRTY_POSTHEAR_BRIEF_DUE_2 = SRC.THRD_PRTY_POSTHEAR_BRIEF_DUE_2
				, TRG.THRD_PRTY_FNL_ARBIT_DCSN_DT_2 = SRC.THRD_PRTY_FNL_ARBIT_DCSN_DT_2
				, TRG.THRD_PRTY_EXCEPTION_FILED_2 = SRC.THRD_PRTY_EXCEPTION_FILED_2
				, TRG.THRD_PRTY_EXCEPTION_FILE_DT_2 = SRC.THRD_PRTY_EXCEPTION_FILE_DT_2
				, TRG.THRD_PRTY_RSPS_TO_EXCPT_DUE_2 = SRC.THRD_PRTY_RSPS_TO_EXCPT_DUE_2
				, TRG.THRD_PRTY_FNL_FLRA_DCSN_DT_2 = SRC.THRD_PRTY_FNL_FLRA_DCSN_DT_2
				, TRG.THRD_PRTY_ARBIT_LNM = SRC.THRD_PRTY_ARBIT_LNM
				, TRG.THRD_PRTY_ARBIT_FNM = SRC.THRD_PRTY_ARBIT_FNM
				, TRG.THRD_PRTY_ARBIT_MNM = SRC.THRD_PRTY_ARBIT_MNM
				, TRG.THRD_PRTY_ARBIT_EMAIL = SRC.THRD_PRTY_ARBIT_EMAIL
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM = SRC.THRD_ERLR_ARBIT_PHONE_NUM
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL = SRC.THRD_PRTY_ARBIT_ORG_AFFIL
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR = SRC.THRD_PRTY_ARBIT_MAILING_ADDR
				, TRG.THRD_PRTY_PREHEARING_DT = SRC.THRD_PRTY_PREHEARING_DT
				, TRG.THRD_PRTY_HEARING_DT = SRC.THRD_PRTY_HEARING_DT
				, TRG.THRD_PRTY_POSTHEAR_BRIEF_DUE = SRC.THRD_PRTY_POSTHEAR_BRIEF_DUE
				, TRG.THRD_PRTY_FNL_ARBIT_DCSN_DT = SRC.THRD_PRTY_FNL_ARBIT_DCSN_DT
				, TRG.THRD_PRTY_EXCEPTION_FILED = SRC.THRD_PRTY_EXCEPTION_FILED
				, TRG.THRD_PRTY_EXCEPTION_FILE_DT = SRC.THRD_PRTY_EXCEPTION_FILE_DT
				, TRG.THRD_PRTY_RSPS_TO_EXCPT_DUE = SRC.THRD_PRTY_RSPS_TO_EXCPT_DUE
				, TRG.THRD_PRTY_FNL_FLRA_DCSN_DT = SRC.THRD_PRTY_FNL_FLRA_DCSN_DT
				, TRG.THRD_PRTY_ARBIT_LNM_4 = SRC.THRD_PRTY_ARBIT_LNM_4
				, TRG.THRD_PRTY_ARBIT_FNM_4 = SRC.THRD_PRTY_ARBIT_FNM_4
				, TRG.THRD_PRTY_ARBIT_MNM_4 = SRC.THRD_PRTY_ARBIT_MNM_4
				, TRG.THRD_PRTY_ARBIT_EMAIL_4 = SRC.THRD_PRTY_ARBIT_EMAIL_4
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM_4 = SRC.THRD_ERLR_ARBIT_PHONE_NUM_4
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL_4 = SRC.THRD_PRTY_ARBIT_ORG_AFFIL_4
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR_4 = SRC.THRD_PRTY_ARBIT_MAILING_ADDR_4
				, TRG.THRD_PRTY_DT_STLMNT_DSCUSN = SRC.THRD_PRTY_DT_STLMNT_DSCUSN
				, TRG.THRD_PRTY_DT_PREHEAR_DSCLS = SRC.THRD_PRTY_DT_PREHEAR_DSCLS
				, TRG.THRD_PRTY_DT_AGNCY_RSP_DUE = SRC.THRD_PRTY_DT_AGNCY_RSP_DUE
				, TRG.THRD_PRTY_PREHEARING_DT_MSPB = SRC.THRD_PRTY_PREHEARING_DT_MSPB
				, TRG.THRD_PRTY_WAS_DSCVRY_INIT = SRC.THRD_PRTY_WAS_DSCVRY_INIT
				, TRG.THRD_PRTY_DT_DISCOVERY_DUE = SRC.THRD_PRTY_DT_DISCOVERY_DUE
				, TRG.THRD_PRTY_HEARING_DT_MSPB = SRC.THRD_PRTY_HEARING_DT_MSPB
				, TRG.THRD_PRTY_INIT_DCSN_DT_MSPB = SRC.THRD_PRTY_INIT_DCSN_DT_MSPB
				, TRG.THRD_PRTY_WAS_PETI_FILED_MSPB = SRC.THRD_PRTY_WAS_PETI_FILED_MSPB
				, TRG.THRD_PRTY_PETITION_RV_DT = SRC.THRD_PRTY_PETITION_RV_DT
				, TRG.THRD_PRTY_FNL_BRD_DCSN_DT_MSPB = SRC.THRD_PRTY_FNL_BRD_DCSN_DT_MSPB
				, TRG.THRD_PRTY_DT_STLMNT_DSCUSN_2 = SRC.THRD_PRTY_DT_STLMNT_DSCUSN_2
				, TRG.THRD_PRTY_DT_PREHEAR_DSCLS_2 = SRC.THRD_PRTY_DT_PREHEAR_DSCLS_2
				, TRG.THRD_PRTY_PREHEARING_CONF = SRC.THRD_PRTY_PREHEARING_CONF
				, TRG.THRD_PRTY_HEARING_DT_FLRA = SRC.THRD_PRTY_HEARING_DT_FLRA
				, TRG.THRD_PRTY_DECISION_DT_FLRA = SRC.THRD_PRTY_DECISION_DT_FLRA
				, TRG.THRD_PRTY_TIMELY_REQ = SRC.THRD_PRTY_TIMELY_REQ
				, TRG.THRD_PRTY_PROC_ORDER = SRC.THRD_PRTY_PROC_ORDER
				, TRG.THRD_PRTY_PANEL_MEMBER_LNAME = SRC.THRD_PRTY_PANEL_MEMBER_LNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_FNAME = SRC.THRD_PRTY_PANEL_MEMBER_FNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_MNAME = SRC.THRD_PRTY_PANEL_MEMBER_MNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_EMAIL = SRC.THRD_PRTY_PANEL_MEMBER_EMAIL
				, TRG.THRD_PRTY_PANEL_MEMBER_PHONE = SRC.THRD_PRTY_PANEL_MEMBER_PHONE
				, TRG.THRD_PRTY_PANEL_MEMBER_ORG = SRC.THRD_PRTY_PANEL_MEMBER_ORG
				, TRG.THRD_PRTY_PANEL_MEMBER_MAILING = SRC.THRD_PRTY_PANEL_MEMBER_MAILING
				, TRG.THRD_PRTY_PANEL_DESCR = SRC.THRD_PRTY_PANEL_DESCR
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.THRD_PRTY_APPEAL_TYPE
				, TRG.THRD_PRTY_APPEAL_FILE_DT
				, TRG.THRD_PRTY_ASSISTANCE_REQ_DT
				, TRG.THRD_PRTY_HEARING_TIMING
				, TRG.THRD_PRTY_HEARING_REQUESTED
				, TRG.THRD_PRTY_STEP_DECISION_DT
				, TRG.THRD_PRTY_ARBITRATION_INVOKED
				, TRG.THRD_PRTY_ARBIT_LNM_3
				, TRG.THRD_PRTY_ARBIT_FNM_3
				, TRG.THRD_PRTY_ARBIT_MNM_3
				, TRG.THRD_PRTY_ARBIT_EMAIL_3
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM_3
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL_3
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR_3
				, TRG.THRD_PRTY_PREHEARING_DT_2
				, TRG.THRD_PRTY_HEARING_DT_2
				, TRG.THRD_PRTY_POSTHEAR_BRIEF_DUE_2
				, TRG.THRD_PRTY_FNL_ARBIT_DCSN_DT_2
				, TRG.THRD_PRTY_EXCEPTION_FILED_2
				, TRG.THRD_PRTY_EXCEPTION_FILE_DT_2
				, TRG.THRD_PRTY_RSPS_TO_EXCPT_DUE_2
				, TRG.THRD_PRTY_FNL_FLRA_DCSN_DT_2
				, TRG.THRD_PRTY_ARBIT_LNM
				, TRG.THRD_PRTY_ARBIT_FNM
				, TRG.THRD_PRTY_ARBIT_MNM
				, TRG.THRD_PRTY_ARBIT_EMAIL
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR
				, TRG.THRD_PRTY_PREHEARING_DT
				, TRG.THRD_PRTY_HEARING_DT
				, TRG.THRD_PRTY_POSTHEAR_BRIEF_DUE
				, TRG.THRD_PRTY_FNL_ARBIT_DCSN_DT
				, TRG.THRD_PRTY_EXCEPTION_FILED
				, TRG.THRD_PRTY_EXCEPTION_FILE_DT
				, TRG.THRD_PRTY_RSPS_TO_EXCPT_DUE
				, TRG.THRD_PRTY_FNL_FLRA_DCSN_DT
				, TRG.THRD_PRTY_ARBIT_LNM_4
				, TRG.THRD_PRTY_ARBIT_FNM_4
				, TRG.THRD_PRTY_ARBIT_MNM_4
				, TRG.THRD_PRTY_ARBIT_EMAIL_4
				, TRG.THRD_ERLR_ARBIT_PHONE_NUM_4
				, TRG.THRD_PRTY_ARBIT_ORG_AFFIL_4
				, TRG.THRD_PRTY_ARBIT_MAILING_ADDR_4
				, TRG.THRD_PRTY_DT_STLMNT_DSCUSN
				, TRG.THRD_PRTY_DT_PREHEAR_DSCLS
				, TRG.THRD_PRTY_DT_AGNCY_RSP_DUE
				, TRG.THRD_PRTY_PREHEARING_DT_MSPB
				, TRG.THRD_PRTY_WAS_DSCVRY_INIT
				, TRG.THRD_PRTY_DT_DISCOVERY_DUE
				, TRG.THRD_PRTY_HEARING_DT_MSPB
				, TRG.THRD_PRTY_INIT_DCSN_DT_MSPB
				, TRG.THRD_PRTY_WAS_PETI_FILED_MSPB
				, TRG.THRD_PRTY_PETITION_RV_DT
				, TRG.THRD_PRTY_FNL_BRD_DCSN_DT_MSPB
				, TRG.THRD_PRTY_DT_STLMNT_DSCUSN_2
				, TRG.THRD_PRTY_DT_PREHEAR_DSCLS_2
				, TRG.THRD_PRTY_PREHEARING_CONF
				, TRG.THRD_PRTY_HEARING_DT_FLRA
				, TRG.THRD_PRTY_DECISION_DT_FLRA
				, TRG.THRD_PRTY_TIMELY_REQ
				, TRG.THRD_PRTY_PROC_ORDER
				, TRG.THRD_PRTY_PANEL_MEMBER_LNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_FNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_MNAME
				, TRG.THRD_PRTY_PANEL_MEMBER_EMAIL
				, TRG.THRD_PRTY_PANEL_MEMBER_PHONE
				, TRG.THRD_PRTY_PANEL_MEMBER_ORG
				, TRG.THRD_PRTY_PANEL_MEMBER_MAILING
				, TRG.THRD_PRTY_PANEL_DESCR               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.THRD_PRTY_APPEAL_TYPE
				, SRC.THRD_PRTY_APPEAL_FILE_DT
				, SRC.THRD_PRTY_ASSISTANCE_REQ_DT
				, SRC.THRD_PRTY_HEARING_TIMING
				, SRC.THRD_PRTY_HEARING_REQUESTED
				, SRC.THRD_PRTY_STEP_DECISION_DT
				, SRC.THRD_PRTY_ARBITRATION_INVOKED
				, SRC.THRD_PRTY_ARBIT_LNM_3
				, SRC.THRD_PRTY_ARBIT_FNM_3
				, SRC.THRD_PRTY_ARBIT_MNM_3
				, SRC.THRD_PRTY_ARBIT_EMAIL_3
				, SRC.THRD_ERLR_ARBIT_PHONE_NUM_3
				, SRC.THRD_PRTY_ARBIT_ORG_AFFIL_3
				, SRC.THRD_PRTY_ARBIT_MAILING_ADDR_3
				, SRC.THRD_PRTY_PREHEARING_DT_2
				, SRC.THRD_PRTY_HEARING_DT_2
				, SRC.THRD_PRTY_POSTHEAR_BRIEF_DUE_2
				, SRC.THRD_PRTY_FNL_ARBIT_DCSN_DT_2
				, SRC.THRD_PRTY_EXCEPTION_FILED_2
				, SRC.THRD_PRTY_EXCEPTION_FILE_DT_2
				, SRC.THRD_PRTY_RSPS_TO_EXCPT_DUE_2
				, SRC.THRD_PRTY_FNL_FLRA_DCSN_DT_2
				, SRC.THRD_PRTY_ARBIT_LNM
				, SRC.THRD_PRTY_ARBIT_FNM
				, SRC.THRD_PRTY_ARBIT_MNM
				, SRC.THRD_PRTY_ARBIT_EMAIL
				, SRC.THRD_ERLR_ARBIT_PHONE_NUM
				, SRC.THRD_PRTY_ARBIT_ORG_AFFIL
				, SRC.THRD_PRTY_ARBIT_MAILING_ADDR
				, SRC.THRD_PRTY_PREHEARING_DT
				, SRC.THRD_PRTY_HEARING_DT
				, SRC.THRD_PRTY_POSTHEAR_BRIEF_DUE
				, SRC.THRD_PRTY_FNL_ARBIT_DCSN_DT
				, SRC.THRD_PRTY_EXCEPTION_FILED
				, SRC.THRD_PRTY_EXCEPTION_FILE_DT
				, SRC.THRD_PRTY_RSPS_TO_EXCPT_DUE
				, SRC.THRD_PRTY_FNL_FLRA_DCSN_DT
				, SRC.THRD_PRTY_ARBIT_LNM_4
				, SRC.THRD_PRTY_ARBIT_FNM_4
				, SRC.THRD_PRTY_ARBIT_MNM_4
				, SRC.THRD_PRTY_ARBIT_EMAIL_4
				, SRC.THRD_ERLR_ARBIT_PHONE_NUM_4
				, SRC.THRD_PRTY_ARBIT_ORG_AFFIL_4
				, SRC.THRD_PRTY_ARBIT_MAILING_ADDR_4
				, SRC.THRD_PRTY_DT_STLMNT_DSCUSN
				, SRC.THRD_PRTY_DT_PREHEAR_DSCLS
				, SRC.THRD_PRTY_DT_AGNCY_RSP_DUE
				, SRC.THRD_PRTY_PREHEARING_DT_MSPB
				, SRC.THRD_PRTY_WAS_DSCVRY_INIT
				, SRC.THRD_PRTY_DT_DISCOVERY_DUE
				, SRC.THRD_PRTY_HEARING_DT_MSPB
				, SRC.THRD_PRTY_INIT_DCSN_DT_MSPB
				, SRC.THRD_PRTY_WAS_PETI_FILED_MSPB
				, SRC.THRD_PRTY_PETITION_RV_DT
				, SRC.THRD_PRTY_FNL_BRD_DCSN_DT_MSPB
				, SRC.THRD_PRTY_DT_STLMNT_DSCUSN_2
				, SRC.THRD_PRTY_DT_PREHEAR_DSCLS_2
				, SRC.THRD_PRTY_PREHEARING_CONF
				, SRC.THRD_PRTY_HEARING_DT_FLRA
				, SRC.THRD_PRTY_DECISION_DT_FLRA
				, SRC.THRD_PRTY_TIMELY_REQ
				, SRC.THRD_PRTY_PROC_ORDER
				, SRC.THRD_PRTY_PANEL_MEMBER_LNAME
				, SRC.THRD_PRTY_PANEL_MEMBER_FNAME
				, SRC.THRD_PRTY_PANEL_MEMBER_MNAME
				, SRC.THRD_PRTY_PANEL_MEMBER_EMAIL
				, SRC.THRD_PRTY_PANEL_MEMBER_PHONE
				, SRC.THRD_PRTY_PANEL_MEMBER_ORG
				, SRC.THRD_PRTY_PANEL_MEMBER_MAILING
				, SRC.THRD_PRTY_PANEL_DESCR
               
            );

		END;

		--------------------------------
		-- ERLE_PROB_ACTION table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_PROB_ACTION TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.PPA_ACTION_TYPE
					, X.PPA_TERMINATION_TYPE
					, TO_DATE(X.PPA_TERM_PROP_ACTION_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_PROP_ACTION_DT	
					, X.PPA_TERM_ORAL_PREZ_REQUESTED
					, TO_DATE(X.PPA_TERM_ORAL_PREZ_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_ORAL_PREZ_DT	
					, X.PPA_TERM_WRITTEN_RESP
					, TO_DATE(X.PPA_TERM_WRITTEN_RESP_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_WRITTEN_RESP_DUE_DT	
					, TO_DATE(X.PPA_TERM_WRITTEN_RESP_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_WRITTEN_RESP_DT	
					, X.PPA_TERM_AGENCY_DECISION
					, X.PPA_TERM_DECIDING_OFFCL_NAME
					, TO_DATE(X.PPA_TERM_DECISION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_DECISION_ISSUED_DT	
					, TO_DATE(X.PPA_TERM_EFFECTIVE_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_TERM_EFFECTIVE_DECISION_DT	
					, TO_DATE(X.PPA_PROB_TERM_DCSN_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_PROB_TERM_DCSN_ISSUED_DT	
					, X.PPA_PROBATION_CONDUCT
					, X.PPA_PROBATION_PERFORMANCE
					, TO_DATE(X.PPA_APPEAL_GRIEVANCE_DEADLINE,'MM/DD/YYYY HH24:MI:SS') AS PPA_APPEAL_GRIEVANCE_DEADLINE	
					, X.PPA_EMP_APPEAL_DECISION
					, TO_DATE(X.PPA_PROP_ACTION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_PROP_ACTION_ISSUED_DT	
					, X.PPA_ORAL_PREZ_REQUESTED
					, TO_DATE(X.PPA_ORAL_PREZ_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_ORAL_PREZ_DT	
					, X.PPA_ORAL_RESPONSE_SUBMITTED
					, TO_DATE(X.PPA_RESPONSE_DUE_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_RESPONSE_DUE_DT	
					, TO_DATE(X.PPA_WRITTEN_RESPONSE_SBMT_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_WRITTEN_RESPONSE_SBMT_DT	
					, X.PPA_POS_TITLE
					, X.PPA_PPLAN
					, X.PPA_SERIES
					, X.PPA_CURRENT_INFO_GRADE
					, X.PPA_CURRENT_INFO_STEP
					, X.PPA_PROPOSED_POS_TITLE
					, X.PPA_PROPOSED_PPLAN
					, X.PPA_PROPOSED_SERIES
					, X.PPA_PROPOSED_INFO_GRADE
					, X.PPA_PROPOSED_INFO_STEP
					, X.PPA_FINAL_POS_TITLE
					, X.PPA_FINAL_PPLAN
					, X.PPA_FINAL_SERIES
					, X.PPA_FINAL_INFO_GRADE
					, X.PPA_FINAL_INFO_STEP
					, TO_DATE(X.PPA_NOTICE_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_NOTICE_ISSUED_DT	
					, X.PPA_DEMO_FINAL_AGENCY_DECISION
					, X.PPA_DECIDING_OFFCL
					, TO_DATE(X.PPA_DECISION_ISSUED_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_DECISION_ISSUED_DT	
					, TO_DATE(X.PPA_DEMO_FINAL_AGENCY_EFF_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_DEMO_FINAL_AGENCY_EFF_DT	
					, X.PPA_NUMB_DAYS
					, TO_DATE(X.PPA_EFFECTIVE_DT,'MM/DD/YYYY HH24:MI:SS') AS PPA_EFFECTIVE_DT	
					, X.PPA_CURRENT_ADMIN_CODE
					, X.PPA_RE_ASSIGNMENT_CURR_ORG
					, X.PPA_FINAL_ADMIN_CODE
					, X.PPA_FINAL_ADMIN_CODE_FINAL_ORG
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS                            
							PPA_ACTION_TYPE	NVARCHAR2(200)	PATH './item[id="PPA_ACTION_TYPE"]/value'
							, PPA_TERMINATION_TYPE	NVARCHAR2(200)	PATH './item[id="PPA_TERMINATION_TYPE"]/value'
							, PPA_TERM_PROP_ACTION_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_PROP_ACTION_DT"]/value'
							, PPA_TERM_ORAL_PREZ_REQUESTED	VARCHAR2(3)	PATH './item[id="PPA_TERM_ORAL_PREZ_REQUESTED"]/value'
							, PPA_TERM_ORAL_PREZ_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_ORAL_PREZ_DT"]/value'
							, PPA_TERM_WRITTEN_RESP	VARCHAR2(3)	PATH './item[id="PPA_TERM_WRITTEN_RESP"]/value'
							, PPA_TERM_WRITTEN_RESP_DUE_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_WRITTEN_RESP_DUE_DT"]/value'
							, PPA_TERM_WRITTEN_RESP_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_WRITTEN_RESP_DT"]/value'
							, PPA_TERM_AGENCY_DECISION	NVARCHAR2(200)	PATH './item[id="PPA_TERM_AGENCY_DECISION"]/value'
							, PPA_TERM_DECIDING_OFFCL_NAME	NVARCHAR2(255)	PATH './item[id="PPA_TERM_DECIDING_OFFCL_NAME"]/value/name'
							, PPA_TERM_DECISION_ISSUED_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_DECISION_ISSUED_DT"]/value'
							, PPA_TERM_EFFECTIVE_DECISION_DT	VARCHAR2(10)	PATH './item[id="PPA_TERM_EFFECTIVE_DECISION_DT"]/value'
							, PPA_PROB_TERM_DCSN_ISSUED_DT	VARCHAR2(10)	PATH './item[id="PPA_PROBATION_TERMINATION_DECISION_ISSUED_DT"]/value'
							, PPA_PROBATION_CONDUCT	VARCHAR2(3)	PATH './item[id="PPA_PROBATION_CONDUCT"]/value'
							, PPA_PROBATION_PERFORMANCE	VARCHAR2(3)	PATH './item[id="PPA_PROBATION_PERFORMANCE"]/value'
							, PPA_APPEAL_GRIEVANCE_DEADLINE	VARCHAR2(10)	PATH './item[id="PPA_APPEAL_GRIEVANCE_DEADLINE"]/value'
							, PPA_EMP_APPEAL_DECISION	VARCHAR2(3)	PATH './item[id="PPA_EMP_APPEAL_DECISION"]/value'
							, PPA_PROP_ACTION_ISSUED_DT	VARCHAR2(10)	PATH './item[id="PPA_PROP_ACTION_ISSUED_DT"]/value'
							, PPA_ORAL_PREZ_REQUESTED	VARCHAR2(3)	PATH './item[id="PPA_ORAL_PREZ_REQUESTED"]/value'
							, PPA_ORAL_PREZ_DT	VARCHAR2(10)	PATH './item[id="PPA_ORAL_PREZ_DT"]/value'
							, PPA_ORAL_RESPONSE_SUBMITTED	VARCHAR2(3)	PATH './item[id="PPA_ORAL_RESPONSE_SUBMITTED"]/value'
							, PPA_RESPONSE_DUE_DT	VARCHAR2(10)	PATH './item[id="PPA_RESPONSE_DUE_DT"]/value'
							, PPA_WRITTEN_RESPONSE_SBMT_DT	VARCHAR2(10)	PATH './item[id="PPA_WRITTEN_RESPONSE_SUBMITTED_DT"]/value'
							, PPA_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PPA_POS_TITLE"]/value'
							, PPA_PPLAN	NVARCHAR2(50)	PATH './item[id="PPA_PPLAN"]/value'
							, PPA_SERIES	NVARCHAR2(50)	PATH './item[id="PPA_SERIES"]/value'
							, PPA_CURRENT_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="PPA_CURRENT_INFO_GRADE"]/value'
							, PPA_CURRENT_INFO_STEP	NVARCHAR2(50)	PATH './item[id="PPA_CURRENT_INFO_STEP"]/value'
							, PPA_PROPOSED_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PPA_PROPOSED_POS_TITLE"]/value'
							, PPA_PROPOSED_PPLAN	NVARCHAR2(50)	PATH './item[id="PPA_PROPOSED_PPLAN"]/value'
							, PPA_PROPOSED_SERIES	NVARCHAR2(50)	PATH './item[id="PPA_PROPOSED_SERIES"]/value'
							, PPA_PROPOSED_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="PPA_PROPOSED_INFO_GRADE"]/value'
							, PPA_PROPOSED_INFO_STEP	NVARCHAR2(50)	PATH './item[id="PPA_PROPOSED_INFO_STEP"]/value'
							, PPA_FINAL_POS_TITLE	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_POS_TITLE"]/value'
							, PPA_FINAL_PPLAN	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_PPLAN"]/value'
							, PPA_FINAL_SERIES	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_SERIES"]/value'
							, PPA_FINAL_INFO_GRADE	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_INFO_GRADE"]/value'
							, PPA_FINAL_INFO_STEP	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_INFO_STEP"]/value'
							, PPA_NOTICE_ISSUED_DT	VARCHAR2(10)	PATH './item[id="PPA_NOTICE_ISSUED_DT"]/value'
							, PPA_DEMO_FINAL_AGENCY_DECISION	NVARCHAR2(200)	PATH './item[id="PPA_DEMO_FINAL_AGENCY_DECISION"]/value'
							, PPA_DECIDING_OFFCL	NVARCHAR2(255)	PATH './item[id="PPA_DECIDING_OFFCL"]/value/name'
							, PPA_DECISION_ISSUED_DT	VARCHAR2(10)	PATH './item[id="PPA_DECISION_ISSUED_DT"]/value'
							, PPA_DEMO_FINAL_AGENCY_EFF_DT	VARCHAR2(10)	PATH './item[id="PPA_DEMO_FINAL_AGENCY_EFF_DT"]/value'
							, PPA_NUMB_DAYS	NUMBER(20,0)	PATH './item[id="PPA_NUMB_DAYS"]/value'
							, PPA_EFFECTIVE_DT	VARCHAR2(10)	PATH './item[id="GEN_CPPA_EFFECTIVE_DTASE_STATUS"]/value'
							, PPA_CURRENT_ADMIN_CODE	NVARCHAR2(8)	PATH './item[id="PPA_CURRENT_ADMIN_CODE"]/value'
							, PPA_RE_ASSIGNMENT_CURR_ORG	NVARCHAR2(50)	PATH './item[id="PPA_RE_ASSIGNMENT_CURR_ORG"]/value'
							, PPA_FINAL_ADMIN_CODE	NVARCHAR2(8)	PATH './item[id="PPA_FINAL_ADMIN_CODE"]/value'
							, PPA_FINAL_ADMIN_CODE_FINAL_ORG	NVARCHAR2(50)	PATH './item[id="PPA_FINAL_ADMIN_CODE_FINAL_ORG"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
				TRG.PPA_ACTION_TYPE = SRC.PPA_ACTION_TYPE
				, TRG.PPA_TERMINATION_TYPE = SRC.PPA_TERMINATION_TYPE
				, TRG.PPA_TERM_PROP_ACTION_DT = SRC.PPA_TERM_PROP_ACTION_DT
				, TRG.PPA_TERM_ORAL_PREZ_REQUESTED = SRC.PPA_TERM_ORAL_PREZ_REQUESTED
				, TRG.PPA_TERM_ORAL_PREZ_DT = SRC.PPA_TERM_ORAL_PREZ_DT
				, TRG.PPA_TERM_WRITTEN_RESP = SRC.PPA_TERM_WRITTEN_RESP
				, TRG.PPA_TERM_WRITTEN_RESP_DUE_DT = SRC.PPA_TERM_WRITTEN_RESP_DUE_DT
				, TRG.PPA_TERM_WRITTEN_RESP_DT = SRC.PPA_TERM_WRITTEN_RESP_DT
				, TRG.PPA_TERM_AGENCY_DECISION = SRC.PPA_TERM_AGENCY_DECISION
				, TRG.PPA_TERM_DECIDING_OFFCL_NAME = SRC.PPA_TERM_DECIDING_OFFCL_NAME
				, TRG.PPA_TERM_DECISION_ISSUED_DT = SRC.PPA_TERM_DECISION_ISSUED_DT	
				, TRG.PPA_TERM_EFFECTIVE_DECISION_DT = 	SRC.PPA_TERM_EFFECTIVE_DECISION_DT
				, TRG.PPA_PROB_TERM_DCSN_ISSUED_DT = SRC.PPA_PROB_TERM_DCSN_ISSUED_DT	
				, TRG.PPA_PROBATION_CONDUCT = SRC.PPA_PROBATION_CONDUCT
				, TRG.PPA_PROBATION_PERFORMANCE = SRC.PPA_PROBATION_PERFORMANCE
				, TRG.PPA_APPEAL_GRIEVANCE_DEADLINE = SRC.PPA_APPEAL_GRIEVANCE_DEADLINE	
				, TRG.PPA_EMP_APPEAL_DECISION = SRC.PPA_EMP_APPEAL_DECISION
				, TRG.PPA_PROP_ACTION_ISSUED_DT = SRC.PPA_PROP_ACTION_ISSUED_DT
				, TRG.PPA_ORAL_PREZ_REQUESTED = SRC.PPA_ORAL_PREZ_REQUESTED
				, TRG.PPA_ORAL_PREZ_DT = SRC.PPA_ORAL_PREZ_DT	
				, TRG.PPA_ORAL_RESPONSE_SUBMITTED = SRC.PPA_ORAL_RESPONSE_SUBMITTED
				, TRG.PPA_RESPONSE_DUE_DT = SRC.PPA_RESPONSE_DUE_DT	
				, TRG.PPA_WRITTEN_RESPONSE_SBMT_DT	 = SRC.PPA_WRITTEN_RESPONSE_SBMT_DT
				, TRG.PPA_POS_TITLE = SRC.PPA_POS_TITLE
				, TRG.PPA_PPLAN = SRC.PPA_PPLAN
				, TRG.PPA_SERIES = SRC.PPA_SERIES
				, TRG.PPA_CURRENT_INFO_GRADE = SRC.PPA_CURRENT_INFO_GRADE
				, TRG.PPA_CURRENT_INFO_STEP = SRC.PPA_CURRENT_INFO_STEP
				, TRG.PPA_PROPOSED_POS_TITLE = SRC.PPA_PROPOSED_POS_TITLE
				, TRG.PPA_PROPOSED_PPLAN = SRC.PPA_PROPOSED_PPLAN
				, TRG.PPA_PROPOSED_SERIES = SRC.PPA_PROPOSED_SERIES
				, TRG.PPA_PROPOSED_INFO_GRADE = SRC.PPA_PROPOSED_INFO_GRADE
				, TRG.PPA_PROPOSED_INFO_STEP = SRC.PPA_PROPOSED_INFO_STEP
				, TRG.PPA_FINAL_POS_TITLE = SRC.PPA_FINAL_POS_TITLE
				, TRG.PPA_FINAL_PPLAN = SRC.PPA_FINAL_PPLAN
				, TRG.PPA_FINAL_SERIES = SRC.PPA_FINAL_SERIES
				, TRG.PPA_FINAL_INFO_GRADE = SRC.PPA_FINAL_INFO_GRADE
				, TRG.PPA_FINAL_INFO_STEP = SRC.PPA_FINAL_INFO_STEP
				, TRG.PPA_NOTICE_ISSUED_DT = SRC.PPA_NOTICE_ISSUED_DT
				, TRG.PPA_DEMO_FINAL_AGENCY_DECISION = SRC.PPA_DEMO_FINAL_AGENCY_DECISION
				, TRG.PPA_DECIDING_OFFCL = SRC.PPA_DECIDING_OFFCL
				, TRG.PPA_DECISION_ISSUED_DT = 	SRC.PPA_DECISION_ISSUED_DT
				, TRG.PPA_DEMO_FINAL_AGENCY_EFF_DT = SRC.PPA_DEMO_FINAL_AGENCY_EFF_DT
				, TRG.PPA_NUMB_DAYS = SRC.PPA_NUMB_DAYS
				, TRG.PPA_EFFECTIVE_DT = SRC.PPA_EFFECTIVE_DT	
				, TRG.PPA_CURRENT_ADMIN_CODE = SRC.PPA_CURRENT_ADMIN_CODE
				, TRG.PPA_RE_ASSIGNMENT_CURR_ORG = SRC.PPA_RE_ASSIGNMENT_CURR_ORG
				, TRG.PPA_FINAL_ADMIN_CODE = SRC.PPA_FINAL_ADMIN_CODE
				, TRG.PPA_FINAL_ADMIN_CODE_FINAL_ORG = SRC.PPA_FINAL_ADMIN_CODE_FINAL_ORG
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.PPA_ACTION_TYPE
				, TRG.PPA_TERMINATION_TYPE
				, TRG.PPA_TERM_PROP_ACTION_DT
				, TRG.PPA_TERM_ORAL_PREZ_REQUESTED
				, TRG.PPA_TERM_ORAL_PREZ_DT	
				, TRG.PPA_TERM_WRITTEN_RESP
				, TRG.PPA_TERM_WRITTEN_RESP_DUE_DT	
				, TRG.PPA_TERM_WRITTEN_RESP_DT	
				, TRG.PPA_TERM_AGENCY_DECISION
				, TRG.PPA_TERM_DECIDING_OFFCL_NAME
				, TRG.PPA_TERM_DECISION_ISSUED_DT	
				, TRG.PPA_TERM_EFFECTIVE_DECISION_DT	
				, TRG.PPA_PROB_TERM_DCSN_ISSUED_DT	
				, TRG.PPA_PROBATION_CONDUCT
				, TRG.PPA_PROBATION_PERFORMANCE
				, TRG.PPA_APPEAL_GRIEVANCE_DEADLINE	
				, TRG.PPA_EMP_APPEAL_DECISION
				, TRG.PPA_PROP_ACTION_ISSUED_DT	
				, TRG.PPA_ORAL_PREZ_REQUESTED
				, TRG.PPA_ORAL_PREZ_DT	
				, TRG.PPA_ORAL_RESPONSE_SUBMITTED
				, TRG.PPA_RESPONSE_DUE_DT	
				, TRG.PPA_WRITTEN_RESPONSE_SBMT_DT	
				, TRG.PPA_POS_TITLE
				, TRG.PPA_PPLAN
				, TRG.PPA_SERIES
				, TRG.PPA_CURRENT_INFO_GRADE
				, TRG.PPA_CURRENT_INFO_STEP
				, TRG.PPA_PROPOSED_POS_TITLE
				, TRG.PPA_PROPOSED_PPLAN
				, TRG.PPA_PROPOSED_SERIES
				, TRG.PPA_PROPOSED_INFO_GRADE
				, TRG.PPA_PROPOSED_INFO_STEP
				, TRG.PPA_FINAL_POS_TITLE
				, TRG.PPA_FINAL_PPLAN
				, TRG.PPA_FINAL_SERIES
				, TRG.PPA_FINAL_INFO_GRADE
				, TRG.PPA_FINAL_INFO_STEP
				, TRG.PPA_NOTICE_ISSUED_DT	
				, TRG.PPA_DEMO_FINAL_AGENCY_DECISION
				, TRG.PPA_DECIDING_OFFCL
				, TRG.PPA_DECISION_ISSUED_DT	
				, TRG.PPA_DEMO_FINAL_AGENCY_EFF_DT	
				, TRG.PPA_NUMB_DAYS
				, TRG.PPA_EFFECTIVE_DT	
				, TRG.PPA_CURRENT_ADMIN_CODE
				, TRG.PPA_RE_ASSIGNMENT_CURR_ORG
				, TRG.PPA_FINAL_ADMIN_CODE
				, TRG.PPA_FINAL_ADMIN_CODE_FINAL_ORG
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.PPA_ACTION_TYPE
				, SRC.PPA_TERMINATION_TYPE
				, SRC.PPA_TERM_PROP_ACTION_DT
				, SRC.PPA_TERM_ORAL_PREZ_REQUESTED
				, SRC.PPA_TERM_ORAL_PREZ_DT	
				, SRC.PPA_TERM_WRITTEN_RESP
				, SRC.PPA_TERM_WRITTEN_RESP_DUE_DT	
				, SRC.PPA_TERM_WRITTEN_RESP_DT	
				, SRC.PPA_TERM_AGENCY_DECISION
				, SRC.PPA_TERM_DECIDING_OFFCL_NAME
				, SRC.PPA_TERM_DECISION_ISSUED_DT	
				, SRC.PPA_TERM_EFFECTIVE_DECISION_DT	
				, SRC.PPA_PROB_TERM_DCSN_ISSUED_DT	
				, SRC.PPA_PROBATION_CONDUCT
				, SRC.PPA_PROBATION_PERFORMANCE
				, SRC.PPA_APPEAL_GRIEVANCE_DEADLINE	
				, SRC.PPA_EMP_APPEAL_DECISION
				, SRC.PPA_PROP_ACTION_ISSUED_DT	
				, SRC.PPA_ORAL_PREZ_REQUESTED
				, SRC.PPA_ORAL_PREZ_DT	
				, SRC.PPA_ORAL_RESPONSE_SUBMITTED
				, SRC.PPA_RESPONSE_DUE_DT	
				, SRC.PPA_WRITTEN_RESPONSE_SBMT_DT	
				, SRC.PPA_POS_TITLE
				, SRC.PPA_PPLAN
				, SRC.PPA_SERIES
				, SRC.PPA_CURRENT_INFO_GRADE
				, SRC.PPA_CURRENT_INFO_STEP
				, SRC.PPA_PROPOSED_POS_TITLE
				, SRC.PPA_PROPOSED_PPLAN
				, SRC.PPA_PROPOSED_SERIES
				, SRC.PPA_PROPOSED_INFO_GRADE
				, SRC.PPA_PROPOSED_INFO_STEP
				, SRC.PPA_FINAL_POS_TITLE
				, SRC.PPA_FINAL_PPLAN
				, SRC.PPA_FINAL_SERIES
				, SRC.PPA_FINAL_INFO_GRADE
				, SRC.PPA_FINAL_INFO_STEP
				, SRC.PPA_NOTICE_ISSUED_DT	
				, SRC.PPA_DEMO_FINAL_AGENCY_DECISION
				, SRC.PPA_DECIDING_OFFCL
				, SRC.PPA_DECISION_ISSUED_DT	
				, SRC.PPA_DEMO_FINAL_AGENCY_EFF_DT	
				, SRC.PPA_NUMB_DAYS
				, SRC.PPA_EFFECTIVE_DT	
				, SRC.PPA_CURRENT_ADMIN_CODE
				, SRC.PPA_RE_ASSIGNMENT_CURR_ORG
				, SRC.PPA_FINAL_ADMIN_CODE
				, SRC.PPA_FINAL_ADMIN_CODE_FINAL_ORG
            );

		END;

		--------------------------------
		-- ERLR_ULP table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_ULP TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, TO_DATE(X.ULP_RECEIPT_CHARGE_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_RECEIPT_CHARGE_DT	
					, X.ULP_CHARGE_FILED_TIMELY
					, TO_DATE(X.ULP_AGENCY_RESPONSE_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_AGENCY_RESPONSE_DT	
					, X.ULP_FLRA_DOCUMENT_REUQESTED
					, TO_DATE(X.ULP_DOC_SUBMISSION_FLRA_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_DOC_SUBMISSION_FLRA_DT
					, X.ULP_DOCUMENT_DESCRIPTION
					, TO_DATE(X.ULP_DISPOSITION_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_DISPOSITION_DT
					, X.ULP_DISPOSITION_TYPE
					, TO_DATE(X.ULP_COMPLAINT_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_COMPLAINT_DT	
					, TO_DATE(X.ULP_AGENCY_ANSWER_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_AGENCY_ANSWER_DT	
					, TO_DATE(X.ULP_AGENCY_ANSWER_FILED_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_AGENCY_ANSWER_FILED_DT	
					, TO_DATE(X.ULP_SETTLEMENT_DISCUSSION_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_SETTLEMENT_DISCUSSION_DT	
					, TO_DATE(X.ULP_PREHEARING_DISCLOSURE_DUE,'MM/DD/YYYY HH24:MI:SS') AS ULP_PREHEARING_DISCLOSURE_DUE	
					, TO_DATE(X.ULP_PREHEARING_DISCLOSUE_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_PREHEARING_DISCLOSUE_DT	
					, TO_DATE(X.ULP_PREHEARING_CONFERENCE_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_PREHEARING_CONFERENCE_DT
					, TO_DATE(X.ULP_HEARING_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_HEARING_DT
					, TO_DATE(X.ULP_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_DECISION_DT
					, X.ULP_EXCEPTION_FILED
					, TO_DATE(X.ULP_EXCEPTION_FILED_DT,'MM/DD/YYYY HH24:MI:SS') AS ULP_EXCEPTION_FILED_DT
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS                            
							ULP_RECEIPT_CHARGE_DT	VARCHAR2(10)	PATH './item[id="ULP_RECEIPT_CHARGE_DT"]/value'
							, ULP_CHARGE_FILED_TIMELY	VARCHAR2(3)	PATH './item[id="ULP_CHARGE_FILED_TIMELY"]/value'
							, ULP_AGENCY_RESPONSE_DT	VARCHAR2(10)	PATH './item[id="ULP_AGENCY_RESPONSE_DT"]/value'
							, ULP_FLRA_DOCUMENT_REUQESTED	VARCHAR2(3)	PATH './item[id="ULP_FLRA_DOCUMENT_REUQESTED"]/value'
							, ULP_DOC_SUBMISSION_FLRA_DT	VARCHAR2(10)	PATH './item[id="ULP_DOCUMENT_SUBMISSION_FLRA_DT"]/value'
							, ULP_DOCUMENT_DESCRIPTION	NVARCHAR2(140)	PATH './item[id="ULP_DOCUMENT_DESCRIPTION"]/value'
							, ULP_DISPOSITION_DT	VARCHAR2(10)	PATH './item[id="ULP_DISPOSITION_DT"]/value'
							, ULP_DISPOSITION_TYPE	NVARCHAR2(200)	PATH './item[id="ULP_DISPOSITION_TYPE"]/value'
							, ULP_COMPLAINT_DT	VARCHAR2(10)	PATH './item[id="ULP_COMPLAINT_DT"]/value'
							, ULP_AGENCY_ANSWER_DT	VARCHAR2(10)	PATH './item[id="ULP_AGENCY_ANSWER_DT"]/value'
							, ULP_AGENCY_ANSWER_FILED_DT	VARCHAR2(10)	PATH './item[id="ULP_AGENCY_ANSWER_FILED_DT"]/value'
							, ULP_SETTLEMENT_DISCUSSION_DT	VARCHAR2(10)	PATH './item[id="ULP_SETTLEMENT_DISCUSSION_DT"]/value'
							, ULP_PREHEARING_DISCLOSURE_DUE	VARCHAR2(10)	PATH './item[id="ULP_PREHEARING_DISCLOSURE_DUE"]/value'
							, ULP_PREHEARING_DISCLOSUE_DT	VARCHAR2(10)	PATH './item[id="ULP_PREHEARING_DISCLOSUE_DT"]/value'
							, ULP_PREHEARING_CONFERENCE_DT	VARCHAR2(10)	PATH './item[id="ULP_PREHEARING_CONFERENCE_DT"]/value'
							, ULP_HEARING_DT	VARCHAR2(10)	PATH './item[id="ULP_HEARING_DT"]/value'
							, ULP_DECISION_DT	VARCHAR2(10)	PATH './item[id="ULP_DECISION_DT"]/value'
							, ULP_EXCEPTION_FILED	VARCHAR2(3)	PATH './item[id="ULP_EXCEPTION_FILED"]/value'
							, ULP_EXCEPTION_FILED_DT	VARCHAR2(10)	PATH './item[id="ULP_EXCEPTION_FILED_DT"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET
                TRG.ULP_RECEIPT_CHARGE_DT = SRC.ULP_RECEIPT_CHARGE_DT
				, TRG.ULP_CHARGE_FILED_TIMELY = SRC.ULP_CHARGE_FILED_TIMELY
				, TRG.ULP_AGENCY_RESPONSE_DT = SRC.ULP_AGENCY_RESPONSE_DT
				, TRG.ULP_FLRA_DOCUMENT_REUQESTED = SRC.ULP_FLRA_DOCUMENT_REUQESTED
				, TRG.ULP_DOC_SUBMISSION_FLRA_DT = SRC.ULP_DOC_SUBMISSION_FLRA_DT
				, TRG.ULP_DOCUMENT_DESCRIPTION = SRC.ULP_DOCUMENT_DESCRIPTION
				, TRG.ULP_DISPOSITION_DT = SRC.ULP_DISPOSITION_DT
				, TRG.ULP_DISPOSITION_TYPE = SRC.ULP_DISPOSITION_TYPE
				, TRG.ULP_COMPLAINT_DT = SRC.ULP_COMPLAINT_DT
				, TRG.ULP_AGENCY_ANSWER_DT = SRC.ULP_AGENCY_ANSWER_DT
				, TRG.ULP_AGENCY_ANSWER_FILED_DT = SRC.ULP_AGENCY_ANSWER_FILED_DT
				, TRG.ULP_SETTLEMENT_DISCUSSION_DT = SRC.ULP_SETTLEMENT_DISCUSSION_DT
				, TRG.ULP_PREHEARING_DISCLOSURE_DUE = SRC.ULP_PREHEARING_DISCLOSURE_DUE
				, TRG.ULP_PREHEARING_DISCLOSUE_DT = SRC.ULP_PREHEARING_DISCLOSUE_DT
				, TRG.ULP_PREHEARING_CONFERENCE_DT = SRC.ULP_PREHEARING_CONFERENCE_DT
				, TRG.ULP_HEARING_DT = SRC.ULP_HEARING_DT
				, TRG.ULP_DECISION_DT = SRC.ULP_DECISION_DT
				, TRG.ULP_EXCEPTION_FILED = SRC.ULP_EXCEPTION_FILED
				, TRG.ULP_EXCEPTION_FILED_DT = SRC.ULP_EXCEPTION_FILED_DT
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.ULP_RECEIPT_CHARGE_DT
				, TRG.ULP_CHARGE_FILED_TIMELY
				, TRG.ULP_AGENCY_RESPONSE_DT
				, TRG.ULP_FLRA_DOCUMENT_REUQESTED
				, TRG.ULP_DOC_SUBMISSION_FLRA_DT
				, TRG.ULP_DOCUMENT_DESCRIPTION
				, TRG.ULP_DISPOSITION_DT
				, TRG.ULP_DISPOSITION_TYPE
				, TRG.ULP_COMPLAINT_DT
				, TRG.ULP_AGENCY_ANSWER_DT
				, TRG.ULP_AGENCY_ANSWER_FILED_DT
				, TRG.ULP_SETTLEMENT_DISCUSSION_DT
				, TRG.ULP_PREHEARING_DISCLOSURE_DUE
				, TRG.ULP_PREHEARING_DISCLOSUE_DT
				, TRG.ULP_PREHEARING_CONFERENCE_DT
				, TRG.ULP_HEARING_DT
				, TRG.ULP_DECISION_DT
				, TRG.ULP_EXCEPTION_FILED
				, TRG.ULP_EXCEPTION_FILED_DT
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
                , SRC.ULP_RECEIPT_CHARGE_DT
				, SRC.ULP_CHARGE_FILED_TIMELY
				, SRC.ULP_AGENCY_RESPONSE_DT
				, SRC.ULP_FLRA_DOCUMENT_REUQESTED
				, SRC.ULP_DOC_SUBMISSION_FLRA_DT
				, SRC.ULP_DOCUMENT_DESCRIPTION
				, SRC.ULP_DISPOSITION_DT
				, SRC.ULP_DISPOSITION_TYPE
				, SRC.ULP_COMPLAINT_DT
				, SRC.ULP_AGENCY_ANSWER_DT
				, SRC.ULP_AGENCY_ANSWER_FILED_DT
				, SRC.ULP_SETTLEMENT_DISCUSSION_DT
				, SRC.ULP_PREHEARING_DISCLOSURE_DUE
				, SRC.ULP_PREHEARING_DISCLOSUE_DT
				, SRC.ULP_PREHEARING_CONFERENCE_DT
				, SRC.ULP_HEARING_DT
				, SRC.ULP_DECISION_DT
				, SRC.ULP_EXCEPTION_FILED
				, SRC.ULP_EXCEPTION_FILED_DT
            );

		END;

		--------------------------------
		-- ERLR_LABOR_NEGO table
		--------------------------------
		BEGIN
            MERGE INTO  ERLR_LABOR_NEGO TRG
            USING
            (
                SELECT
                    V_CASE_NUMBER AS ERLR_CASE_NUMBER
					, X.LN_NEGOTIATION_TYPE
					, X.LN_INITIATOR
					, TO_DATE(X.LN_DEMAND2BARGAIN_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_DEMAND2BARGAIN_DT
					, X.LN_BRIEFING_REQUEST
					, TO_DATE(X.LN_BRIEFING_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_BRIEFING_DT
					, TO_DATE(X.LN_PROPOSAL_SUBMISSION_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_PROPOSAL_SUBMISSION_DT
					, X.LN_PROPOSAL_SUBMISSION
					, X.LN_PROPOSAL_NEGOTIABLE
					, X.LN_NON_NEGOTIABLE_LETTER
					, X.LN_FILE_ULP
					, X.LN_PROPOSAL_INFO_GROUND_RULES
					, TO_DATE(X.LN_PRPSAL_INFO_NEG_COMMENCE_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_PRPSAL_INFO_NEG_COMMENCE_DT
					, X.LN_LETTER_PROVIDED
					, TO_DATE(X.LN_LETTER_PROVIDED_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_LETTER_PROVIDED_DT
					, X.LN_NEGOTIABLE_PROPOSAL
					, TO_DATE(X.LN_BARGAINING_BEGAN_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_BARGAINING_BEGAN_DT
					, TO_DATE(X.LN_IMPASSE_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_IMPASSE_DT
					, TO_DATE(X.LN_FSIP_DECISION_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_FSIP_DECISION_DT
					, TO_DATE(X.LN_BARGAINING_END_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_BARGAINING_END_DT
					, TO_DATE(X.LN_AGREEMENT_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_AGREEMENT_DT
					, X.LN_SUMMARY_OF_ISSUE
					, X.LN_SECON_LETTER_REQUEST
					, X.LN_2ND_LETTER_PROVIDED
					, X.LN_NEGOTIABL_ISSUE_SUMMARY
					, TO_DATE(X.LN_2ND_PROVIDED_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_2ND_PROVIDED_DT
					, TO_DATE(X.LN_MNGMNT_ARTICLE4_NTC_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_MNGMNT_ARTICLE4_NTC_DT
					, X.LN_MNGMNT_NOTICE_RESPONSE
					, X.LN_MNGMNT_BRIEFING_REQUEST
					, TO_DATE(X.LN_BRIEFING_REQUESTED2_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_BRIEFING_REQUESTED2_DT
					, TO_DATE(X.LN_MNGMNT_BARGAIN_SBMSSION_DT,'MM/DD/YYYY HH24:MI:SS') AS LN_MNGMNT_BARGAIN_SBMSSION_DT
					, X.LN_MNGMNT_PROPOSAL_SBMSSION
                    
                FROM TBL_FORM_DTL FD
                    , XMLTABLE('/formData/items'
						PASSING FD.FIELD_DATA
						COLUMNS
                            LN_NEGOTIATION_TYPE	NVARCHAR2(200)	PATH './item[id="LN_NEGOTIATION_TYPE"]/value'
							, LN_INITIATOR	NVARCHAR2(200)	PATH './item[id="LN_INITIATOR"]/value'
							, LN_DEMAND2BARGAIN_DT	VARCHAR2(10)	PATH './item[id="LN_DEMAND2BARGAIN_DT"]/value'
							, LN_BRIEFING_REQUEST	VARCHAR2(3)	PATH './item[id="LN_BRIEFING_REQUEST"]/value'
							, LN_BRIEFING_DT	VARCHAR2(10)	PATH './item[id="LN_BRIEFING_DT"]/value'
							, LN_PROPOSAL_SUBMISSION_DT	VARCHAR2(10)	PATH './item[id="LN_PROPOSAL_SUBMISSION_DT"]/value'
							, LN_PROPOSAL_SUBMISSION	VARCHAR2(3)	PATH './item[id="LN_PROPOSAL_SUBMISSION"]/value'
							, LN_PROPOSAL_NEGOTIABLE	VARCHAR2(3)	PATH './item[id="LN_PROPOSAL_NEGOTIABLE"]/value'
							, LN_NON_NEGOTIABLE_LETTER	VARCHAR2(3)	PATH './item[id="LN_NON_NEGOTIABLE_LETTER"]/value'
							, LN_FILE_ULP	VARCHAR2(3)	PATH './item[id="LN_FILE_ULP"]/value'
							, LN_PROPOSAL_INFO_GROUND_RULES	VARCHAR2(3)	PATH './item[id="LN_PROPOSAL_INFO_GROUND_RULES"]/value'
							, LN_PRPSAL_INFO_NEG_COMMENCE_DT	VARCHAR2(10)	PATH './item[id="LN_PROPOSAL_INFO_NEG_COMMENCED_DT"]/value'
							, LN_LETTER_PROVIDED	VARCHAR2(3)	PATH './item[id="LN_LETTER_PROVIDED"]/value'
							, LN_LETTER_PROVIDED_DT	VARCHAR2(10)	PATH './item[id="LN_LETTER_PROVIDED_DT"]/value'
							, LN_NEGOTIABLE_PROPOSAL	VARCHAR2(3)	PATH './item[id="LN_NEGOTIABLE_PROPOSAL"]/value'
							, LN_BARGAINING_BEGAN_DT	VARCHAR2(10)	PATH './item[id="LN_BARGAINING_BEGAN_DT"]/value'
							, LN_IMPASSE_DT	VARCHAR2(10)	PATH './item[id="LN_IMPASSE_DT"]/value'
							, LN_FSIP_DECISION_DT	VARCHAR2(10)	PATH './item[id="LN_FSIP_DECISION_DT"]/value'
							, LN_BARGAINING_END_DT	VARCHAR2(10)	PATH './item[id="LN_BARGAINING_END_DT"]/value'
							, LN_AGREEMENT_DT	VARCHAR2(10)	PATH './item[id="LN_AGREEMENT_DT"]/value'
							, LN_SUMMARY_OF_ISSUE	NVARCHAR2(500)	PATH './item[id="LN_SUMMARY_OF_ISSUE"]/value'
							, LN_SECON_LETTER_REQUEST	VARCHAR2(3)	PATH './item[id="LN_SECON_LETTER_REQUEST"]/value'
							, LN_2ND_LETTER_PROVIDED	VARCHAR2(3)	PATH './item[id="LN_2ND_LETTER_PROVIDED"]/value'
							, LN_NEGOTIABL_ISSUE_SUMMARY	NVARCHAR2(500)	PATH './item[id="LN_NEGOTIABL_ISSUE_SUMMARY"]/value'
							, LN_2ND_PROVIDED_DT	VARCHAR2(10)	PATH './item[id="LN_2ND_PROVIDED_DT"]/value'
							, LN_MNGMNT_ARTICLE4_NTC_DT	VARCHAR2(10)	PATH './item[id="LN_MNGMNT_ARTICLE4_NTC_DT"]/value'
							, LN_MNGMNT_NOTICE_RESPONSE	VARCHAR2(3)	PATH './item[id="LN_MNGMNT_NOTICE_RESPONSE"]/value'
							, LN_MNGMNT_BRIEFING_REQUEST	VARCHAR2(3)	PATH './item[id="LN_MNGMNT_BRIEFING_REQUEST"]/value'
							, LN_BRIEFING_REQUESTED2_DT	VARCHAR2(10)	PATH './item[id="LN_BRIEFING_REQUESTED2_DT"]/value'
							, LN_MNGMNT_BARGAIN_SBMSSION_DT	VARCHAR2(10)	PATH './item[id="LN_MNGMNT_BARGAIN_SUBMISSION_DT"]/value'
							, LN_MNGMNT_PROPOSAL_SBMSSION	VARCHAR2(3)	PATH './item[id="LN_MNGMNT_PROPOSAL_SUBMISSION"]/value'
                ) X
			    WHERE FD.PROCID = I_PROCID
            )SRC ON (SRC.ERLR_CASE_NUMBER = TRG.ERLR_CASE_NUMBER)
            WHEN MATCHED THEN UPDATE SET				
				TRG.LN_NEGOTIATION_TYPE = SRC.LN_NEGOTIATION_TYPE
				, TRG.LN_INITIATOR = SRC.LN_INITIATOR
				, TRG.LN_DEMAND2BARGAIN_DT = SRC.LN_DEMAND2BARGAIN_DT
				, TRG.LN_BRIEFING_REQUEST = SRC.LN_BRIEFING_REQUEST
				, TRG.LN_BRIEFING_DT = SRC.LN_BRIEFING_DT
				, TRG.LN_PROPOSAL_SUBMISSION_DT = SRC.LN_PROPOSAL_SUBMISSION_DT
				, TRG.LN_PROPOSAL_SUBMISSION = SRC.LN_PROPOSAL_SUBMISSION
				, TRG.LN_PROPOSAL_NEGOTIABLE = SRC.LN_PROPOSAL_NEGOTIABLE
				, TRG.LN_NON_NEGOTIABLE_LETTER = SRC.LN_NON_NEGOTIABLE_LETTER
				, TRG.LN_FILE_ULP = SRC.LN_FILE_ULP
				, TRG.LN_PROPOSAL_INFO_GROUND_RULES = SRC.LN_PROPOSAL_INFO_GROUND_RULES
				, TRG.LN_PRPSAL_INFO_NEG_COMMENCE_DT = SRC.LN_PRPSAL_INFO_NEG_COMMENCE_DT
				, TRG.LN_LETTER_PROVIDED = SRC.LN_LETTER_PROVIDED
				, TRG.LN_LETTER_PROVIDED_DT = SRC.LN_LETTER_PROVIDED_DT
				, TRG.LN_NEGOTIABLE_PROPOSAL = SRC.LN_NEGOTIABLE_PROPOSAL
				, TRG.LN_BARGAINING_BEGAN_DT = SRC.LN_BARGAINING_BEGAN_DT
				, TRG.LN_IMPASSE_DT = SRC.LN_IMPASSE_DT
				, TRG.LN_FSIP_DECISION_DT = SRC.LN_FSIP_DECISION_DT
				, TRG.LN_BARGAINING_END_DT = SRC.LN_BARGAINING_END_DT
				, TRG.LN_AGREEMENT_DT = SRC.LN_AGREEMENT_DT
				, TRG.LN_SUMMARY_OF_ISSUE = SRC.LN_SUMMARY_OF_ISSUE
				, TRG.LN_SECON_LETTER_REQUEST = SRC.LN_SECON_LETTER_REQUEST
				, TRG.LN_2ND_LETTER_PROVIDED = SRC.LN_2ND_LETTER_PROVIDED
				, TRG.LN_NEGOTIABL_ISSUE_SUMMARY = SRC.LN_NEGOTIABL_ISSUE_SUMMARY
				, TRG.LN_2ND_PROVIDED_DT = SRC.LN_2ND_PROVIDED_DT
				, TRG.LN_MNGMNT_ARTICLE4_NTC_DT = SRC.LN_MNGMNT_ARTICLE4_NTC_DT
				, TRG.LN_MNGMNT_NOTICE_RESPONSE = SRC.LN_MNGMNT_NOTICE_RESPONSE
				, TRG.LN_MNGMNT_BRIEFING_REQUEST = SRC.LN_MNGMNT_BRIEFING_REQUEST
				, TRG.LN_BRIEFING_REQUESTED2_DT = SRC.LN_BRIEFING_REQUESTED2_DT
				, TRG.LN_MNGMNT_BARGAIN_SBMSSION_DT = SRC.LN_MNGMNT_BARGAIN_SBMSSION_DT
				, TRG.LN_MNGMNT_PROPOSAL_SBMSSION = SRC.LN_MNGMNT_PROPOSAL_SBMSSION
            WHEN NOT MATCHED THEN INSERT
            (
                TRG.ERLR_CASE_NUMBER
				, TRG.LN_NEGOTIATION_TYPE
				, TRG.LN_INITIATOR
				, TRG.LN_DEMAND2BARGAIN_DT
				, TRG.LN_BRIEFING_REQUEST
				, TRG.LN_BRIEFING_DT
				, TRG.LN_PROPOSAL_SUBMISSION_DT
				, TRG.LN_PROPOSAL_SUBMISSION
				, TRG.LN_PROPOSAL_NEGOTIABLE
				, TRG.LN_NON_NEGOTIABLE_LETTER
				, TRG.LN_FILE_ULP
				, TRG.LN_PROPOSAL_INFO_GROUND_RULES
				, TRG.LN_PRPSAL_INFO_NEG_COMMENCE_DT
				, TRG.LN_LETTER_PROVIDED
				, TRG.LN_LETTER_PROVIDED_DT
				, TRG.LN_NEGOTIABLE_PROPOSAL
				, TRG.LN_BARGAINING_BEGAN_DT
				, TRG.LN_IMPASSE_DT
				, TRG.LN_FSIP_DECISION_DT
				, TRG.LN_BARGAINING_END_DT
				, TRG.LN_AGREEMENT_DT
				, TRG.LN_SUMMARY_OF_ISSUE
				, TRG.LN_SECON_LETTER_REQUEST
				, TRG.LN_2ND_LETTER_PROVIDED
				, TRG.LN_NEGOTIABL_ISSUE_SUMMARY
				, TRG.LN_2ND_PROVIDED_DT
				, TRG.LN_MNGMNT_ARTICLE4_NTC_DT
				, TRG.LN_MNGMNT_NOTICE_RESPONSE
				, TRG.LN_MNGMNT_BRIEFING_REQUEST
				, TRG.LN_BRIEFING_REQUESTED2_DT
				, TRG.LN_MNGMNT_BARGAIN_SBMSSION_DT
				, TRG.LN_MNGMNT_PROPOSAL_SBMSSION
               
            )
            VALUES
            (
                SRC.ERLR_CASE_NUMBER
				, SRC.LN_NEGOTIATION_TYPE
				, SRC.LN_INITIATOR
				, SRC.LN_DEMAND2BARGAIN_DT
				, SRC.LN_BRIEFING_REQUEST
				, SRC.LN_BRIEFING_DT
				, SRC.LN_PROPOSAL_SUBMISSION_DT
				, SRC.LN_PROPOSAL_SUBMISSION
				, SRC.LN_PROPOSAL_NEGOTIABLE
				, SRC.LN_NON_NEGOTIABLE_LETTER
				, SRC.LN_FILE_ULP
				, SRC.LN_PROPOSAL_INFO_GROUND_RULES
				, SRC.LN_PRPSAL_INFO_NEG_COMMENCE_DT
				, SRC.LN_LETTER_PROVIDED
				, SRC.LN_LETTER_PROVIDED_DT
				, SRC.LN_NEGOTIABLE_PROPOSAL
				, SRC.LN_BARGAINING_BEGAN_DT
				, SRC.LN_IMPASSE_DT
				, SRC.LN_FSIP_DECISION_DT
				, SRC.LN_BARGAINING_END_DT
				, SRC.LN_AGREEMENT_DT
				, SRC.LN_SUMMARY_OF_ISSUE
				, SRC.LN_SECON_LETTER_REQUEST
				, SRC.LN_2ND_LETTER_PROVIDED
				, SRC.LN_NEGOTIABL_ISSUE_SUMMARY
				, SRC.LN_2ND_PROVIDED_DT
				, SRC.LN_MNGMNT_ARTICLE4_NTC_DT
				, SRC.LN_MNGMNT_NOTICE_RESPONSE
				, SRC.LN_MNGMNT_BRIEFING_REQUEST
				, SRC.LN_BRIEFING_REQUESTED2_DT
				, SRC.LN_MNGMNT_BARGAIN_SBMSSION_DT
				, SRC.LN_MNGMNT_PROPOSAL_SBMSSION
               
            );

		END;
	
	END IF;
		

    COMMIT;

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

/**
 * This script will detect deleted ER/LR BizFlow process from certain date
 * , and remove corresponding ER/LR database records.
 *
 * @param P_STARTDATE - From Date of deletion
 * @param P_DEBUG_FLAG - 'T': not delete, 'F': delete records permanently
 *

 Example to run the SP
        SET SERVEROUTPUT ON; 
        CALL HHS_CMS_HR.SP_ERLR_CLEAN_PROC_DATA (SYSDATE, 'F');
    
    Query to verify the result. change ERLR_CASE_NUMBER and  number
        SELECT count(1) as ERLR_3RDPARTY_HEAR FROM HHS_CMS_HR.ERLR_3RDPARTY_HEAR WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_APPEAL FROM HHS_CMS_HR.ERLR_APPEAL WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_CNDT_ISSUE FROM HHS_CMS_HR.ERLR_CNDT_ISSUE WHERE ERLR_CASE_NUMBER = 10000;    
        SELECT count(1) as ERLR_EMPLOYEE_CASE FROM HHS_CMS_HR.ERLR_EMPLOYEE_CASE WHERE (CASEID = 10000 OR FROM_CASEID = 10000);
        SELECT count(1) as ERLR_GEN FROM HHS_CMS_HR.ERLR_GEN WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_GRIEVANCE FROM HHS_CMS_HR.ERLR_GRIEVANCE WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_INFO_REQUEST FROM HHS_CMS_HR.ERLR_INFO_REQUEST WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_INVESTIGATION FROM HHS_CMS_HR.ERLR_INVESTIGATION WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_LABOR_NEGO FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_LABOR_NEGO FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_MEDDOC FROM HHS_CMS_HR.ERLR_MEDDOC WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_PERF_ISSUE FROM HHS_CMS_HR.ERLR_PERF_ISSUE WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_PROB_ACTION FROM HHS_CMS_HR.ERLR_PROB_ACTION WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_ULP FROM HHS_CMS_HR.ERLR_ULP WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_WGI_DNL FROM HHS_CMS_HR.ERLR_WGI_DNL WHERE ERLR_CASE_NUMBER = 10000;
        
        SELECT count(1) as TBL_FORM_DTL HHS_CMS_HR.TBL_FORM_DTL WHERE PROCID = 123456;
        SELECT count(1) as TBL_FORM_DTL_AUDIT HHS_CMS_HR.TBL_FORM_DTL_AUDIT WHERE PROCID = 123456;        
*/

CREATE OR REPLACE PROCEDURE SP_ERLR_CLEAN_PROC_DATA
(
    P_STARTDATE         DATE := SYSDATE
    ,P_DEBUG_FLAG       VARCHAR2 := 'F' --[ 'T' | 'F' ]
)
IS
    C_ERLR_CASE_NUMBER	    NUMBER(20,0);
    C_ERLR_JOB_REQ_NUMBER	NVARCHAR2(16 CHAR);
    C_PROCID	            NUMBER(20,0);
    C_ERLR_CASE_STATUS_ID	NUMBER(20,0);
    C_ERLR_CASE_CREATE_DT	DATE;
    
    CURSOR CUR_DELETED_ERLR_PROCESSES(ip_StartDate DATE)
    IS
        SELECT ERLR_CASE_NUMBER, ERLR_JOB_REQ_NUMBER, PROCID, ERLR_CASE_STATUS_ID, ERLR_CASE_CREATE_DT
          FROM HHS_CMS_HR.ERLR_CASE
         WHERE ERLR_CASE_CREATE_DT >= SYSDATE - 10000
           AND NOT EXISTS (
                SELECT *
                  FROM BIZFLOW.PROCS P
                 WHERE P.NAME = 'ER/LR Case Initiation'
                   AND HHS_CMS_HR.ERLR_CASE.PROCID = P.PROCID
           )
    ;
    
BEGIN
    
    --DBMS_OUTPUT.PUT_LINE('P_DEBUG_FLAG=' || P_DEBUG_FLAG || ', P_STARTDATE=' || TO_CHAR(P_STARTDATE));    
    OPEN CUR_DELETED_ERLR_PROCESSES(P_STARTDATE);
    
    LOOP    
        FETCH
            CUR_DELETED_ERLR_PROCESSES
        INTO
            C_ERLR_CASE_NUMBER, C_ERLR_JOB_REQ_NUMBER, C_PROCID, C_ERLR_CASE_STATUS_ID, C_ERLR_CASE_CREATE_DT;
            
            IF C_PROCID IS NOT NULL THEN
            BEGIN
                --DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------');
                --DBMS_OUTPUT.PUT_LINE('PROCID = ' || TO_CHAR(C_PROCID) || ', ERLR_CASE_NUMBER = ' || TO_CHAR(C_ERLR_CASE_NUMBER));
                --DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------');

                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_3RDPARTY_HEAR'); 
                DELETE FROM HHS_CMS_HR.ERLR_3RDPARTY_HEAR WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_APPEAL');
                DELETE FROM HHS_CMS_HR.ERLR_APPEAL WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_CNDT_ISSUE');
                DELETE FROM HHS_CMS_HR.ERLR_CNDT_ISSUE WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;    
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_EMPLOYEE_CASE');
                DELETE FROM HHS_CMS_HR.ERLR_EMPLOYEE_CASE WHERE (CASEID = C_ERLR_CASE_NUMBER OR FROM_CASEID = C_ERLR_CASE_NUMBER) AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_GEN');
                DELETE FROM HHS_CMS_HR.ERLR_GEN WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_GRIEVANCE');
                DELETE FROM HHS_CMS_HR.ERLR_GRIEVANCE WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_INFO_REQUEST');
                DELETE FROM HHS_CMS_HR.ERLR_INFO_REQUEST WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_INVESTIGATION');
                DELETE FROM HHS_CMS_HR.ERLR_INVESTIGATION WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_LABOR_NEGO');
                DELETE FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_LABOR_NEGO');
                DELETE FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_MEDDOC');
                DELETE FROM HHS_CMS_HR.ERLR_MEDDOC WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_PERF_ISSUE');
                DELETE FROM HHS_CMS_HR.ERLR_PERF_ISSUE WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_PROB_ACTION');
                DELETE FROM HHS_CMS_HR.ERLR_PROB_ACTION WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_CASE');
                DELETE FROM HHS_CMS_HR.ERLR_CASE WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_ULP');
                DELETE FROM HHS_CMS_HR.ERLR_ULP WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_WGI_DNL');
                DELETE FROM HHS_CMS_HR.ERLR_WGI_DNL WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                
                --------- common tables    
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - TBL_FORM_DTL_AUDIT');
                DELETE FROM HHS_CMS_HR.TBL_FORM_DTL_AUDIT WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - TBL_FORM_DTL');
                DELETE FROM HHS_CMS_HR.TBL_FORM_DTL WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
                DELETE FROM HHS_CMS_HR.TBL_FORM_DTL_AUDIT WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
            END;
            END IF;
            
        EXIT WHEN CUR_DELETED_ERLR_PROCESSES%NOTFOUND;
    END LOOP;

    CLOSE CUR_DELETED_ERLR_PROCESSES;
    --DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    
    COMMIT;

EXCEPTION
	WHEN OTHERS THEN
    CLOSE CUR_DELETED_ERLR_PROCESSES;
    ROLLBACK;
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred -------------------');
    --DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
    --DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);    
END;
/

