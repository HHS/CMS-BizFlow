
SET DEFINE OFF;










--------------------------------------------------------
--  DDL for Function FN_GET_SUBORG_CD
--------------------------------------------------------

/**
 * Gets Admin Code to map to Sub-Organization.
 *
 * Sub Organization 1 - Use the first charactor of Admin Code.
 * Sub Organization 2 - Use the leading 3 charactors of Admin Code.  
 *                      If the leading 3 characters is 'FCM' and the full Admin Code is not 'FCM2',
 *                      use the leading 4 characters.
 * Sub Organization 3 - Use one more charactor of Admin Code than Sub Organization 2 if its length does not exceed the full Admin Code length.
 * Sub Organization 4 - Use one more charactor of Admin Code than Sub Organization 3 if its length does not exceed the full Admin Code length.
 * Sub Organization 5 - Use one more charactor of Admin Code than Sub Organization 4 if its length does not exceed the full Admin Code length.
 *
 * @param I_ADMIN_CD - The full Admin Code value to evaluate.
 * @param I_SUB_ORG_LVL - Sub-Organization Level
 *
 * @return VARCHAR2 - The Admin Code to map to Sub-Organization.  
 *                  If there is no matching Sub-Organization for the given level, return NULL. 
 */
CREATE OR REPLACE FUNCTION FN_GET_SUBORG_CD
(
	I_ADMIN_CD              IN  VARCHAR2
	, I_SUB_ORG_LVL         IN  NUMBER
)
RETURN VARCHAR2
IS
	V_RETURN_VAL                VARCHAR2(10);
	V_FULL_LENGTH               NUMBER(1);
	V_OFFSET                    NUMBER(1);
	V_IS_SHIFTED                CHAR(1);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_SUBORG_CD -------');
	--DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
	--DBMS_OUTPUT.PUT_LINE('    I_ADMIN_CD         = ' || I_ADMIN_CD );
	--DBMS_OUTPUT.PUT_LINE('    I_SUB_ORG_LVL      = ' || I_SUB_ORG_LVL );
	V_FULL_LENGTH := LENGTH(I_ADMIN_CD);
	V_OFFSET := 3;
	V_IS_SHIFTED := CASE WHEN SUBSTR(I_ADMIN_CD, 1, 3) = 'FCM' AND I_ADMIN_CD != 'FCM2' THEN 'Y' ELSE 'N' END;
	IF I_SUB_ORG_LVL = 1 THEN
		IF V_FULL_LENGTH >= 1 THEN 
			V_OFFSET := 1;
		ELSE
			V_OFFSET := 0;
		END IF;
	ELSE
		IF V_IS_SHIFTED = 'N' THEN
			--IF I_SUB_ORG_LVL = 2 AND V_FULL_LENGTH >= 3 THEN
			IF I_SUB_ORG_LVL = 2 THEN
				V_OFFSET := 3;
			ELSIF I_SUB_ORG_LVL = 3 AND V_FULL_LENGTH >= 4 THEN
				V_OFFSET := 4;
			ELSIF I_SUB_ORG_LVL = 4 AND V_FULL_LENGTH >= 5 THEN
				V_OFFSET := 5;
			ELSIF I_SUB_ORG_LVL = 5 AND V_FULL_LENGTH >= 6 THEN
				V_OFFSET := 6;
			ELSE
				V_OFFSET := 0;
			END IF;
		ELSE
			--IF I_SUB_ORG_LVL = 2 AND V_FULL_LENGTH >= 4 THEN
			IF I_SUB_ORG_LVL = 2 THEN
				V_OFFSET := 4;
			ELSIF I_SUB_ORG_LVL = 3 AND V_FULL_LENGTH >= 5 THEN
				V_OFFSET := 5;
			ELSIF I_SUB_ORG_LVL = 4 AND V_FULL_LENGTH >= 6 THEN
				V_OFFSET := 6;
			ELSIF I_SUB_ORG_LVL = 5 AND V_FULL_LENGTH >= 7 THEN
				V_OFFSET := 7;
			ELSE
				V_OFFSET := 0;
			END IF;
		END IF;
	END IF;

	V_RETURN_VAL := SUBSTR(I_ADMIN_CD, 1, V_OFFSET);

	--DBMS_OUTPUT.PUT_LINE('    V_RETURN_VAL = ' || V_RETURN_VAL);
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_GET_SUBORG_CD -------');
	RETURN V_RETURN_VAL;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_SUBORG_CD -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
END;

/