CREATE OR REPLACE FUNCTION FN_GET_2ND_SUB_ORG
(
	I_ADMIN_CD IN  VARCHAR2	
)
RETURN VARCHAR2
IS
	V_RETURN_VAL    VARCHAR2(300);
	V_VALUE  VARCHAR2(30);	
    V_VALUE2 VARCHAR2(30);
    V_ORG_NAME  VARCHAR2(255);    
BEGIN
    --DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_2ND_SUB_ORG -------');
    --DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
    --DBMS_OUTPUT.PUT_LINE('    I_ADMIN_CD         = ' || I_ADMIN_CD );

    SELECT SUBSTR(I_ADMIN_CD, 1, 2) INTO V_VALUE FROM DUAL;
    IF V_VALUE != 'FC' THEN    
        V_RETURN_VAL := 'N/A';
    ELSE
        SELECT SUBSTR(I_ADMIN_CD, 3, 1) INTO V_VALUE FROM DUAL;
        CASE V_VALUE
            WHEN 'C' THEN V_RETURN_VAL := 'FCC';
            WHEN 'E' THEN V_RETURN_VAL := 'FCE';
            WHEN 'F' THEN V_RETURN_VAL := 'FCF';
            WHEN 'G' THEN V_RETURN_VAL := 'FCG';
            WHEN 'H' THEN V_RETURN_VAL := 'FCH';
            WHEN 'J' THEN V_RETURN_VAL := 'FCJ';
            WHEN 'L' THEN V_RETURN_VAL := 'FCL';
            WHEN 'M' THEN 
                SELECT SUBSTR(I_ADMIN_CD, 4, 1) INTO V_VALUE2 FROM DUAL;
                CASE V_VALUE2
                    WHEN 'B' THEN V_RETURN_VAL := 'FCMB';
                    WHEN 'C' THEN V_RETURN_VAL := 'FCMC';
                    WHEN 'G' THEN V_RETURN_VAL := 'FCMG';
                    WHEN 'H' THEN V_RETURN_VAL := 'FCMH';
                    WHEN 'J' THEN V_RETURN_VAL := 'FCMJ';
                    WHEN 'K' THEN V_RETURN_VAL := 'FCMK';
                    WHEN 'N' THEN V_RETURN_VAL := 'FCMN';
                    WHEN 'P' THEN V_RETURN_VAL := 'FCMP';
                    WHEN 'Q' THEN V_RETURN_VAL := 'FCMQ'; 
                END CASE;
            WHEN 'N' THEN V_RETURN_VAL := 'FCN';
            WHEN 'P' THEN V_RETURN_VAL := 'FCP';
            WHEN 'Q' THEN V_RETURN_VAL := 'FCQ';
            WHEN 'R' THEN V_RETURN_VAL := 'FCR';
            WHEN 'S' THEN V_RETURN_VAL := 'FCS';
            WHEN 'T' THEN V_RETURN_VAL := 'FCT';
            WHEN 'V' THEN V_RETURN_VAL := 'FCV';
            WHEN 'W' THEN V_RETURN_VAL := 'FCW';
            WHEN 'X' THEN V_RETURN_VAL := 'FCX';
            ELSE
                V_RETURN_VAL := 'N/A';    
         END CASE;         
    END IF;
    IF V_RETURN_VAL != 'N/A' THEN
      SELECT AC_ADMIN_CD_DESCR INTO V_ORG_NAME FROM ADMIN_CODES WHERE AC_ADMIN_CD = V_RETURN_VAL;              
      V_RETURN_VAL := V_RETURN_VAL || ' - ' || V_ORG_NAME;
    END IF;
    
    RETURN V_RETURN_VAL;
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_2ND_SUB_ORG -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
END;
/
