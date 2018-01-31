-------------------------------------------------------------------------------
-- The program below updates the form xml data for STRATCON and CLSF
-- for the structural changes done as part of the data source switch
-- for Admin Code (from local ADMIN_CODES table to the ADMINISTRATIVE_CODE
-- table maintained by EHRP DBA team.
--
-- WARNING: The program below should be run before the ADMIN_CODES table 
--          is recreated as the view to the ADMINISTRATIVE_CODE table.
-------------------------------------------------------------------------------




---------------------
-- Update form xml with ADMIN_CD for STRATCON
---------------------

--SET SERVEROUTPUT ON;
DECLARE
	V_LOOP_CNT                 NUMBER(10);
	V_PROCID                   NUMBER(20);
	V_SRC_XML                  XMLTYPE;
	V_TMP_XML                  XMLTYPE;
	V_STR_VALUE                NVARCHAR2(2000);
	V_INT_VALUE                NUMBER(20);

	REC_FORMDTL                TBL_FORM_DTL%ROWTYPE;
	TYPE FORMDTL_TYPE IS REF CURSOR RETURN TBL_FORM_DTL%ROWTYPE;
	CUR_FORMDTL                FORMDTL_TYPE;
BEGIN

	--DBMS_OUTPUT.PUT_LINE('Begin data conversion for SG_ADMIN_CD');
	OPEN CUR_FORMDTL FOR
		SELECT *
		FROM TBL_FORM_DTL
		WHERE FORM_TYPE = 'CMSSTRATCON'
		ORDER BY PROCID;

	--DBMS_OUTPUT.PUT_LINE('Opened cursor for TBL_FORM_DTL');

	V_LOOP_CNT := 0;
	LOOP
		FETCH CUR_FORMDTL INTO REC_FORMDTL;
		EXIT WHEN CUR_FORMDTL%NOTFOUND;

		----------------------------------------
		-- main action to perform per record
		----------------------------------------
		V_LOOP_CNT := V_LOOP_CNT + 1;
		V_PROCID := REC_FORMDTL.PROCID;
		V_SRC_XML := REC_FORMDTL.FIELD_DATA;
		SELECT XMLQUERY('/DOCUMENT/GENERAL/SG_ADMIN_CD' PASSING V_SRC_XML RETURNING CONTENT)
		INTO V_TMP_XML
		FROM DUAL;
		--DBMS_OUTPUT.PUT_LINE('Fetched record, loop count = ' || TO_CHAR(V_LOOP_CNT) || ' PROCID = ' || V_PROCID);
		--IF V_SRC_XML IS NULL THEN
		--	DBMS_OUTPUT.PUT_LINE('V_SRC_XML = NULL');
		--ELSE
		--	DBMS_OUTPUT.PUT_LINE('V_SRC_XML = ' || V_SRC_XML.GETCLOBVAL());
		--END IF;
		--IF V_TMP_XML IS NULL THEN
		--	DBMS_OUTPUT.PUT_LINE('V_TMP_XML = NULL');
		--ELSE
		--	DBMS_OUTPUT.PUT_LINE('V_TMP_XML = ' || V_TMP_XML.GETCLOBVAL());
		--END IF;

		V_STR_VALUE := NULL;  -- clear before setting
		BEGIN
			-- Extract ID
			SELECT TO_NUMBER(XMLQUERY('/DOCUMENT/GENERAL/SG_AC_ID/text()' PASSING V_SRC_XML RETURNING CONTENT).GETSTRINGVAL())
			INTO V_INT_VALUE
			FROM DUAL;
			--DBMS_OUTPUT.PUT_LINE(' V_INT_VALUE = ' || TO_CHAR(V_INT_VALUE));

			-- Lookup Admin Code
			SELECT AC_ADMIN_CD
			INTO V_STR_VALUE
			FROM ADMIN_CODES
			WHERE AC_ID = V_INT_VALUE;
			--DBMS_OUTPUT.PUT_LINE(' V_STR_VALUE = ' || V_STR_VALUE);

			-- Update xml element for Admin Code
			IF V_STR_VALUE IS NOT NULL THEN
				IF V_TMP_XML IS NULL THEN
					UPDATE TBL_FORM_DTL
					SET FIELD_DATA = INSERTCHILDXMLAFTER(FIELD_DATA
						, '/DOCUMENT/GENERAL'
						, 'SG_AC_ID[1]'
						, XMLTYPE('<SG_ADMIN_CD>' || V_STR_VALUE || '</SG_ADMIN_CD>'))
					WHERE PROCID = V_PROCID;
				ELSE
					UPDATE TBL_FORM_DTL
					SET FIELD_DATA = UPDATEXML(FIELD_DATA
						, '/DOCUMENT/GENERAL/SG_ADMIN_CD'
						, XMLTYPE('<SG_ADMIN_CD>' || V_STR_VALUE || '</SG_ADMIN_CD>'))
					WHERE PROCID = V_PROCID;
				END IF;
			END IF;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_PROCID := NULL;
				V_SRC_XML := NULL;
			WHEN OTHERS THEN
				SP_ERROR_LOG();
				V_PROCID := NULL;
				V_SRC_XML := NULL;
		END;

	END LOOP;
	CLOSE CUR_FORMDTL;

	COMMIT;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		SP_ERROR_LOG();
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/





---------------------
-- Update form xml with ADMIN_CD for CLSF
---------------------

--SET SERVEROUTPUT ON;
DECLARE
	V_LOOP_CNT                 NUMBER(10);
	V_PROCID                   NUMBER(20);
	V_SRC_XML                  XMLTYPE;
	V_TMP_XML                  XMLTYPE;
	V_STR_VALUE                NVARCHAR2(2000);
	V_INT_VALUE                NUMBER(20);

	REC_FORMDTL                TBL_FORM_DTL%ROWTYPE;
	TYPE FORMDTL_TYPE IS REF CURSOR RETURN TBL_FORM_DTL%ROWTYPE;
	CUR_FORMDTL                FORMDTL_TYPE;
BEGIN

	--DBMS_OUTPUT.PUT_LINE('Begin data conversion for CS_ADMIN_CD');
	OPEN CUR_FORMDTL FOR
		SELECT *
		FROM TBL_FORM_DTL
		WHERE FORM_TYPE = 'CMSCLSF'
		ORDER BY PROCID;

	--DBMS_OUTPUT.PUT_LINE('Opened cursor for TBL_FORM_DTL');

	V_LOOP_CNT := 0;
	LOOP
		FETCH CUR_FORMDTL INTO REC_FORMDTL;
		EXIT WHEN CUR_FORMDTL%NOTFOUND;

		----------------------------------------
		-- main action to perform per record
		----------------------------------------
		V_LOOP_CNT := V_LOOP_CNT + 1;
		V_PROCID := REC_FORMDTL.PROCID;
		V_SRC_XML := REC_FORMDTL.FIELD_DATA;
		SELECT XMLQUERY('/DOCUMENT/GENERAL/CS_ADMIN_CD' PASSING V_SRC_XML RETURNING CONTENT)
		INTO V_TMP_XML
		FROM DUAL;
		--DBMS_OUTPUT.PUT_LINE('Fetched record, loop count = ' || TO_CHAR(V_LOOP_CNT) || ' PROCID = ' || V_PROCID);
		--IF V_SRC_XML IS NULL THEN
		--	DBMS_OUTPUT.PUT_LINE('V_SRC_XML = NULL');
		--ELSE
		--	DBMS_OUTPUT.PUT_LINE('V_SRC_XML = ' || V_SRC_XML.GETCLOBVAL());
		--END IF;
		--IF V_TMP_XML IS NULL THEN
		--	DBMS_OUTPUT.PUT_LINE('V_TMP_XML = NULL');
		--ELSE
		--	DBMS_OUTPUT.PUT_LINE('V_TMP_XML = ' || V_TMP_XML.GETCLOBVAL());
		--END IF;

		V_STR_VALUE := NULL;  -- clear before setting
		BEGIN
			-- Extract ID
			SELECT TO_NUMBER(XMLQUERY('/DOCUMENT/GENERAL/CS_AC_ID/text()' PASSING V_SRC_XML RETURNING CONTENT).GETSTRINGVAL())
			INTO V_INT_VALUE
			FROM DUAL;
			--DBMS_OUTPUT.PUT_LINE(' V_INT_VALUE = ' || TO_CHAR(V_INT_VALUE));

			-- Lookup Admin Code
			SELECT AC_ADMIN_CD
			INTO V_STR_VALUE
			FROM ADMIN_CODES
			WHERE AC_ID = V_INT_VALUE;
			--DBMS_OUTPUT.PUT_LINE(' V_STR_VALUE = ' || V_STR_VALUE);

			-- Update xml element for Admin Code
			IF V_STR_VALUE IS NOT NULL THEN
				IF V_TMP_XML IS NULL THEN
					UPDATE TBL_FORM_DTL
					SET FIELD_DATA = INSERTCHILDXMLAFTER(FIELD_DATA
						, '/DOCUMENT/GENERAL'
						, 'CS_AC_ID[1]'
						, XMLTYPE('<CS_ADMIN_CD>' || V_STR_VALUE || '</CS_ADMIN_CD>'))
					WHERE PROCID = V_PROCID;
				ELSE
					UPDATE TBL_FORM_DTL
					SET FIELD_DATA = UPDATEXML(FIELD_DATA
						, '/DOCUMENT/GENERAL/CS_ADMIN_CD'
						, XMLTYPE('<CS_ADMIN_CD>' || V_STR_VALUE || '</CS_ADMIN_CD>'))
					WHERE PROCID = V_PROCID;
				END IF;
			END IF;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				V_PROCID := NULL;
				V_SRC_XML := NULL;
			WHEN OTHERS THEN
				SP_ERROR_LOG();
				V_PROCID := NULL;
				V_SRC_XML := NULL;
		END;

	END LOOP;
	CLOSE CUR_FORMDTL;

	COMMIT;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		SP_ERROR_LOG();
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
