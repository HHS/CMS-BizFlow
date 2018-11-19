-- CMS_HR_DB_UPD_04_incentives.sql 
-- CMS_HR_DB_UPD_08_erlr_program.sql

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