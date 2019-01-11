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
            BEGIN
                SELECT SEQ, CASE_NUMBER, FIELD_DATA
                  INTO V_SEQ, V_ORG_CASE_NUMBER, V_XMLDOC
                  FROM ERLR_CASE_TRIGGER
                 WHERE FROM_PROCID = V_FROM_PROCID
                   AND STATUS = 'WAIT'
                   AND TO_PROCID IS NULL;
            EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                V_SEQ := NULL;
            END;
            
            IF V_SEQ IS NULL THEN
                UPDATE ERLR_CASE_TRIGGER
                   SET STATUS = 'DONE',
                       TO_PROCID = I_PROCID
                 WHERE SEQ = V_SEQ
                   AND STATUS = 'WAIT'
                   AND TO_PROCID IS NULL;                
            END IF;
        END IF;
        
        IF V_XMLDOC IS NULL THEN
            V_XMLDOC := XMLTYPE('<formData xmlns=""><items><item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item></items><history><item /></history></formData>');
        ELSE
            SELECT XMLQUERY('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).GETSTRINGVAL() 
              INTO V_GEN_EMP_HHSID 
              FROM ERLR_CASE_TRIGGER
             WHERE SEQ = V_SEQ;
            
            SP_ERLR_EMPLOYEE_CASE_ADD(V_GEN_EMP_HHSID, V_CASE_NUMBER, V_ORG_CASE_NUMBER, NULL);
            
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