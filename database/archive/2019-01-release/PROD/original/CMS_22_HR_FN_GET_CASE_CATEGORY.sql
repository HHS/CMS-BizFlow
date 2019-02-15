--------------------------------------------------------
--  DDL for Function FN_GET_CASE_CATEGORY
--------------------------------------------------------

/**
 * Get case categories from case category IDs
 *
 *
 * @param I_CASE_CATEGORY_IDS - Case category lookup IDs with comma delimiter 
 *
 * @return NVARCHAR2 - Case categories for the input IDs with comma delimiter
 */
CREATE OR REPLACE FUNCTION FN_GET_CASE_CATEGORY
(
	I_CASE_CATEGORY_IDS IN  VARCHAR2	
)
RETURN VARCHAR2
IS
	V_RETURN_VAL    VARCHAR2(600);
	V_VALUE  VARCHAR2(100);	
    V_CATEGORY  VARCHAR2(200);
    V_ITER  NUMBER(1);
BEGIN
    --DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_CASE_CATEGORY -------');
    --DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
    --DBMS_OUTPUT.PUT_LINE('    I_CASE_CATEGORY_IDS         = ' || I_CASE_CATEGORY_IDS );

    V_ITER := 1;
    IF I_CASE_CATEGORY_IDS IS NOT NULL THEN        
        SELECT REGEXP_SUBSTR (I_CASE_CATEGORY_IDS, '[^,]+', 1, 1) INTO V_VALUE FROM DUAL;
        IF V_VALUE IS NOT NULL THEN
		    SELECT L.TBL_LABEL INTO V_CATEGORY FROM TBL_LOOKUP L WHERE L.TBL_ID = V_VALUE AND ROWNUM = 1;
		    V_RETURN_VAL := V_CATEGORY;
	    END IF;
        
        WHILE V_VALUE IS NOT NULL
        LOOP
            V_ITER := V_ITER + 1;
            SELECT REGEXP_SUBSTR (I_CASE_CATEGORY_IDS, '[^,]+', 1, V_ITER) INTO V_VALUE FROM DUAL;
            IF V_VALUE IS NOT NULL THEN
		        SELECT L.TBL_LABEL INTO V_CATEGORY FROM TBL_LOOKUP L WHERE L.TBL_ID = V_VALUE AND ROWNUM = 1;
		        V_RETURN_VAL := V_RETURN_VAL || ', ' || V_CATEGORY;
	        END IF;
        END LOOP;

    END IF;

    RETURN V_RETURN_VAL;
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_CASE_CATEGORY -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
END;

/

GRANT EXECUTE ON HHS_CMS_HR.FN_GET_CASE_CATEGORY TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.FN_GET_CASE_CATEGORY TO HHS_CMS_HR_DEV_ROLE;
