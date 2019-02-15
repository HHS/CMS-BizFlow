create or replace FUNCTION FN_GET_2ND_SUB_ORG
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
    --Revision History
    --2/14/2019 : Sandesh Gurung : Added more Admin Codes to evaluate
    --2/14/2019 : Sandesh Gurung : Added length of an Admin Code in the evaluation logic 
    --2/15/2019 : Ginnah Lee : Fixed as it returned only for length of 3 and 4 admin codes.   

    SELECT SUBSTR(I_ADMIN_CD, 1, 2) INTO V_VALUE FROM DUAL;
    IF V_VALUE != 'FC' THEN    
        V_RETURN_VAL := 'N/A';
    ELSE    
        IF LENGTH(I_ADMIN_CD) = 2 THEN
            V_RETURN_VAL := 'FC';
        ELSE
            SELECT SUBSTR(I_ADMIN_CD, 3, 1) INTO V_VALUE FROM DUAL;
            CASE V_VALUE
                WHEN 'A' THEN V_RETURN_VAL := 'FCA';
                WHEN 'B' THEN V_RETURN_VAL := 'FCB';
                WHEN 'C' THEN V_RETURN_VAL := 'FCC';
                WHEN 'E' THEN V_RETURN_VAL := 'FCE';
                WHEN 'F' THEN V_RETURN_VAL := 'FCF';
                WHEN 'G' THEN V_RETURN_VAL := 'FCG';
                WHEN 'H' THEN V_RETURN_VAL := 'FCH';
                WHEN 'J' THEN V_RETURN_VAL := 'FCJ';
                WHEN 'K' THEN V_RETURN_VAL := 'FCK';
                WHEN 'L' THEN V_RETURN_VAL := 'FCL';
                WHEN 'M' THEN   
                    SELECT SUBSTR(I_ADMIN_CD, 4, 1) INTO V_VALUE2 FROM DUAL;
                    CASE V_VALUE2
                        WHEN '1' THEN V_RETURN_VAL := 'FCM1';
                        WHEN '2' THEN V_RETURN_VAL := 'FCM2';
                        WHEN '3' THEN V_RETURN_VAL := 'FCM3';
                        WHEN '4' THEN V_RETURN_VAL := 'FCM4';
                        WHEN 'A' THEN V_RETURN_VAL := 'FCMA';
                        WHEN 'B' THEN V_RETURN_VAL := 'FCMB';
                        WHEN 'C' THEN V_RETURN_VAL := 'FCMC';
                        WHEN 'E' THEN V_RETURN_VAL := 'FCME';
                        WHEN 'F' THEN V_RETURN_VAL := 'FCMF';
                        WHEN 'G' THEN V_RETURN_VAL := 'FCMG';
                        WHEN 'H' THEN V_RETURN_VAL := 'FCMH';
                        WHEN 'J' THEN V_RETURN_VAL := 'FCMJ';
                        WHEN 'K' THEN V_RETURN_VAL := 'FCMK';
                        WHEN 'L' THEN V_RETURN_VAL := 'FCML';
                        WHEN 'M' THEN V_RETURN_VAL := 'FCMM';                    
                        WHEN 'N' THEN V_RETURN_VAL := 'FCMN';
                        WHEN 'P' THEN V_RETURN_VAL := 'FCMP';
                        WHEN 'Q' THEN V_RETURN_VAL := 'FCMQ';                        
                        ELSE
                            V_RETURN_VAL := 'FCM';
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
    END IF;

    IF V_RETURN_VAL != 'N/A' THEN 
        V_ORG_NAME := '';
        SELECT AC_ADMIN_CD_DESCR INTO V_ORG_NAME FROM ADMIN_CODES WHERE AC_ADMIN_CD = V_RETURN_VAL;
        IF V_ORG_NAME IS NOT NULL AND LENGTH(V_ORG_NAME) > 0 THEN              
            V_RETURN_VAL := V_RETURN_VAL || ' - ' || V_ORG_NAME;
        END IF;
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