SET DEFINE OFF;

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
        SELECT COUNT(AC_ADMIN_CD_DESCR) INTO V_VALUE FROM ADMIN_CODES WHERE AC_ADMIN_CD = V_RETURN_VAL;
        IF V_VALUE > 0 THEN
            SELECT AC_ADMIN_CD_DESCR INTO V_ORG_NAME FROM ADMIN_CODES WHERE AC_ADMIN_CD = V_RETURN_VAL;            
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
/

create or replace FUNCTION FN_EXTRACT_STR
(
	  I_XMLDOC          IN  XMLTYPE
	, I_ID              IN  VARCHAR2
	, I_PATH            IN  VARCHAR2 DEFAULT 'value'
)
RETURN VARCHAR2
IS
    ELM XMLTYPE;
BEGIN
    ELM := I_XMLDOC.EXTRACT('//item[id="'||I_ID||'"]/'||I_PATH||'/text()');
    IF ELM IS NOT NULL THEN
        RETURN ELM.GETSTRINGVAL();
    ELSE
        RETURN NULL;
    END IF;
END;
/

create or replace FUNCTION FN_EXTRACT_DATE
(
	  I_XMLDOC          IN  XMLTYPE
	, I_ID              IN  VARCHAR2
	, I_PATH            IN  VARCHAR2 DEFAULT 'value'
)
RETURN VARCHAR2
IS
BEGIN
    RETURN TO_DATE(FN_EXTRACT_STR(I_XMLDOC, I_ID, I_PATH),'MM/DD/YYYY HH24:MI:SS');
END;
/

CREATE OR REPLACE FUNCTION FN_FILTER_CATEGORY
  (
    I_CASE_NUMBER IN  NUMBER,
    I_FILTER IN VARCHAR2
  )
  RETURN NUMBER
IS
  V_RETURN_VAL    NUMBER(20);
  BEGIN
    SELECT COUNT(*) into V_RETURN_VAL FROM (
      SELECT * FROM (
          WITH T AS ( SELECT GEN_CASE_CATEGORY FROM HHS_CMS_HR.VW_ERLR_GEN WHERE ERLR_CASE_NUMBER = I_CASE_NUMBER)
          SELECT TRIM(REGEXP_SUBSTR(GEN_CASE_CATEGORY, '[^,]+', 1, LEVEL )) AS VAL
            FROM T
          CONNECT BY REGEXP_SUBSTR(GEN_CASE_CATEGORY, '[^,]+', 1, LEVEL ) IS NOT NULL
      )

      INTERSECT

      SELECT * FROM (
         WITH X AS ( SELECT I_FILTER AS FILTER FROM DUAL )
         SELECT TRIM(REGEXP_SUBSTR(FILTER, '[^,]+', 1, LEVEL )) AS VAL
           FROM X
         CONNECT BY REGEXP_SUBSTR(FILTER, '[^,]+', 1, LEVEL ) IS NOT NULL
        )
     );

    RETURN V_RETURN_VAL;
    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_2ND_SUB_ORG -------------------');
    --DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
    --DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
    RETURN 0;
  END;
/

grant EXECUTE ON HHS_CMS_HR.FN_FILTER_CATEGORY TO BIZFLOW;
grant EXECUTE ON HHS_CMS_HR.FN_FILTER_CATEGORY TO HHS_CMS_HR_RW_ROLE;
grant EXECUTE ON HHS_CMS_HR.FN_FILTER_CATEGORY TO HHS_CMS_HR_DEV_ROLE;
/

create or replace FUNCTION FN_FILTER_FINALACTION
  (
    I_CASE_NUMBER IN  NUMBER,
    I_FILTER IN NVARCHAR2
  )
  RETURN NUMBER
IS
  V_RETURN_VAL    NUMBER(20);
  BEGIN
    SELECT COUNT(*) into V_RETURN_VAL FROM (
      SELECT * FROM (
          WITH T AS ( SELECT CC_FINAL_ACTION FROM HHS_CMS_HR.VW_ERLR_GEN WHERE ERLR_CASE_NUMBER = I_CASE_NUMBER)
          SELECT TRIM(REGEXP_SUBSTR(CC_FINAL_ACTION, '[^,]+', 1, LEVEL )) AS VAL
            FROM T
          CONNECT BY REGEXP_SUBSTR(CC_FINAL_ACTION, '[^,]+', 1, LEVEL ) IS NOT NULL
      )

      INTERSECT

      SELECT * FROM (
         WITH X AS ( SELECT I_FILTER AS FILTER FROM DUAL )
         SELECT TRIM(REGEXP_SUBSTR(FILTER, '[^,]+', 1, LEVEL )) AS VAL
           FROM X
         CONNECT BY REGEXP_SUBSTR(FILTER, '[^,]+', 1, LEVEL ) IS NOT NULL
        )
     );

    RETURN V_RETURN_VAL;
    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_2ND_SUB_ORG -------------------');
    --DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
    --DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
    RETURN 0;
  END;
/

grant EXECUTE ON HHS_CMS_HR.FN_FILTER_FINALACTION TO BIZFLOW;
grant EXECUTE ON HHS_CMS_HR.FN_FILTER_FINALACTION TO HHS_CMS_HR_RW_ROLE;
grant EXECUTE ON HHS_CMS_HR.FN_FILTER_FINALACTION TO HHS_CMS_HR_DEV_ROLE;
/

COMMIT;
/

