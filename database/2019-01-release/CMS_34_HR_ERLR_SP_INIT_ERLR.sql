create or replace PROCEDURE SP_INIT_ERLR
(
	I_PROCID               IN  NUMBER
)
IS
    V_CNT                   INT;
    V_SEQ                   NUMBER;
    V_FROM_PROCID           NUMBER(10);
    V_XMLDOC                XMLTYPE;
    V_ORG_XMLDOC            XMLTYPE;
    V_ORG_CASE_NUMBER       NUMBER(10);
    V_CASENUMBER_XML        XMLTYPE;
    V_CASE_NUMBER           NUMBER(10);
    V_REQUEST_NUMBER        VARCHAR(20);
    V_GEN_EMP_HHSID         VARCHAR2(64);    
    V_GEN_PRIMARY_SPECIALIST VARCHAR2(20);
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
        
/*
        IF V_FROM_PROCID IS NOT NULL THEN
            
        END IF;
        
        IF V_XMLDOC IS NULL THEN
            V_XMLDOC := XMLTYPE('<formData xmlns=""><items><item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item></items><history><item /></history></formData>');
        ELSE
            SELECT XMLQUERY('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).GETSTRINGVAL(),
                   XMLQUERY('/formData/items/item[id="GEN_PRIMARY_SPECIALIST"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).GETSTRINGVAL() 
              INTO V_GEN_EMP_HHSID, V_GEN_PRIMARY_SPECIALIST  
              FROM ERLR_CASE_TRIGGER
             WHERE SEQ = V_SEQ;
            
            SP_ERLR_EMPLOYEE_CASE_ADD(V_GEN_EMP_HHSID, V_CASE_NUMBER, V_ORG_CASE_NUMBER, NULL);
            
            
            SELECT APPENDCHILDXML(V_XMLDOC, '/formData/items', XMLTYPE('<item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item>')) INTO V_XMLDOC FROM DUAL;            
        END IF;
*/
        
        V_XMLDOC := XMLTYPE('<formData xmlns=""><items><item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item></items><history><item /></history></formData>');
        
        INSERT INTO TBL_FORM_DTL (PROCID, ACTSEQ, WITEMSEQ, FORM_TYPE, FIELD_DATA, CRT_DT, CRT_USR)
                          VALUES (I_PROCID, 0, 0, 'CMSERLR', V_XMLDOC, SYSDATE, 'System');
    END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;
/
