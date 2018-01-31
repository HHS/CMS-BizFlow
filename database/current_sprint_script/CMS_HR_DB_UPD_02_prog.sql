

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


		V_RLVNTDATANAME := 'execOfficer';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
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


		V_RLVNTDATANAME := 'lastActivityCompDate';
		BEGIN
			SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
		EXCEPTION
			WHEN OTHERS THEN V_VALUE := NULL;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


--TODO: verify whether or not we need it
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


--TODO: verify whether or not we need it
		V_RLVNTDATANAME := 'memIdExecOff';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


--TODO: verify whether or not we need it
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


--TODO: verify whether or not we need it
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


--TODO: verify whether or not we need it
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
	V_ID NUMBER(20);
	V_FORM_TYPE VARCHAR2(50);
	V_USER VARCHAR2(50);
	V_PROCID NUMBER(10);
	V_ACTSEQ NUMBER(10);
	V_WITEMSEQ NUMBER(10);
	V_REC_CNT NUMBER(10);
	V_MAX_ID NUMBER(20);
	V_XMLDOC XMLTYPE;
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
	V_XMLDOC := XMLTYPE(I_FIELD_DATA);

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

	BEGIN
		SELECT COUNT(*) INTO V_REC_CNT FROM TBL_FORM_DTL WHERE ID = V_ID;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			V_REC_CNT := -1;
	END;

	V_FORM_TYPE := I_FORM_TYPE;
	V_USER := I_USER;

	--DBMS_OUTPUT.PUT_LINE('Inspected existence of same record.');
	--DBMS_OUTPUT.PUT_LINE('    V_ID       = ' || TO_CHAR(V_ID));
	--DBMS_OUTPUT.PUT_LINE('    V_PROCID   = ' || TO_CHAR(V_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    V_ACTSEQ   = ' || TO_CHAR(V_ACTSEQ));
	--DBMS_OUTPUT.PUT_LINE('    V_WITEMSEQ = ' || TO_CHAR(V_WITEMSEQ));
	--DBMS_OUTPUT.PUT_LINE('    V_REC_CNT  = ' || TO_CHAR(V_REC_CNT));

	-- Strategic Consultation specific xml data manipulation before insert/update
	IF V_FORM_TYPE = 'CMSSTRATCON' THEN
		SP_UPDATE_STRATCON_DATA( V_XMLDOC );
	END IF;

	IF V_REC_CNT > 0 THEN
		--DBMS_OUTPUT.PUT_LINE('Record found so that field data will be updated on the same record.');

		UPDATE TBL_FORM_DTL
		SET
			PROCID = V_PROCID
			, ACTSEQ = V_ACTSEQ
			, WITEMSEQ = V_WITEMSEQ
			, FIELD_DATA = V_XMLDOC
			, MOD_DT = SYSDATE
			, MOD_USR = V_USER
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
		--TODO: table update for ELIGQUAL
		--SP_UPDATE_ELIGQUAL_TABLE(V_PROCID);
	END IF;

	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_FORM_DATA -------------------');
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
						<MED_OFFICERS_ID>{      data($sc/DOCUMENT/POSITION/POS_MED_OFFICERS_ID)}</MED_OFFICERS_ID>
						<PERFORMANCE_LEVEL>{    data($sc/DOCUMENT/POSITION/POS_PERFORMANCE_LEVEL)}</PERFORMANCE_LEVEL>
						<SUPERVISORY>{          data($sc/DOCUMENT/POSITION/POS_SUPERVISORY)}</SUPERVISORY>
						<SKILL>{                data($sc/DOCUMENT/POSITION/POS_SKILL)}</SKILL>
						<GRADES_ADVERTISED>{    data($sc/DOCUMENT/POSITION/POS_GRADES_ADVERTISED)}</GRADES_ADVERTISED>
						<LOCATION>{             data($sc/DOCUMENT/POSITION/POS_LOCATION)}</LOCATION>
						<VACANCIES>{            data($sc/DOCUMENT/POSITION/POS_VACANCIES)}</VACANCIES>
						<REPORT_SUPERVISOR>{    data($sc/DOCUMENT/POSITION/POS_REPORT_SUPERVISOR)}</REPORT_SUPERVISOR>
						<CAN>{                  data($sc/DOCUMENT/POSITION/POS_CAN)}</CAN>
						<VICE>{                 data($sc/DOCUMENT/POSITION/POS_VICE)}</VICE>
						<VICE_NAME>{            data($sc/DOCUMENT/POSITION/POS_VICE_NAME)}</VICE_NAME>
						<DAYS_ADVERTISED>{      data($sc/DOCUMENT/POSITION/POS_DAYS_ADVERTISED)}</DAYS_ADVERTISED>
						<AT_ID>{                data($sc/DOCUMENT/POSITION/POS_AT_ID)}</AT_ID>
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
						<SO_ID>{                data($sc/DOCUMENT/POSITION/POS_SO_ID)}</SO_ID>
						<ASSOC_DESCR_NUMBERS>{  data($sc/DOCUMENT/POSITION/POS_ASSOC_DESCR_NUMBERS)}</ASSOC_DESCR_NUMBERS>
						<PROMOTE_POTENTIAL>{    data($sc/DOCUMENT/POSITION/POS_PROMOTE_POTENTIAL)}</PROMOTE_POTENTIAL>
						<VICE_EMPL_ID>{         data($sc/DOCUMENT/POSITION/POS_VICE_EMPL_ID)}</VICE_EMPL_ID>
						<SR_ID>{                data($sc/DOCUMENT/POSITION/POS_SR_ID)}</SR_ID>
						<GR_ID>{                data($sc/DOCUMENT/POSITION/POS_GR_ID)}</GR_ID>
						<PROC_ID>{              data($sc/DOCUMENT/POSITION/POS_PROC_ID)}</PROC_ID>
						<AC_ID>{                data($sc/DOCUMENT/POSITION/POS_AC_ID)}</AC_ID>
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
		--TODO: implement return xml
		RETURN NULL;

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
