create or replace PROCEDURE SP_INIT_ERLR
(
	I_PROCID               IN  NUMBER
)
IS
    V_CNT                   INT;    
    V_FROM_PROCID           NUMBER(10);
    V_XMLDOC                XMLTYPE;    
    V_ORG_CASE_NUMBER       NUMBER(10);
    V_CASE_NUMBER           NUMBER(10);    
    V_GEN_EMP_HHSID         VARCHAR2(64);
    V_NEW_CASE_TYPE_ID	    NUMBER(38);
    V_NEW_CASE_TYPE_NAME    VARCHAR2(100);
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
            SELECT FIELD_DATA
              INTO V_XMLDOC
              FROM TBL_FORM_DTL
             WHERE PROCID = V_FROM_PROCID;

            SELECT TO_NUMBER(VALUE)
              INTO V_NEW_CASE_TYPE_ID
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'caseTypeID' 
               AND PROCID = I_PROCID;

            SELECT TO_NUMBER(VALUE)
              INTO V_ORG_CASE_NUMBER
              FROM BIZFLOW.RLVNTDATA 
             WHERE RLVNTDATANAME = 'caseNumber' 
               AND PROCID = V_FROM_PROCID;

            BEGIN
              SELECT TBL_LABEL
                INTO V_NEW_CASE_TYPE_NAME
                FROM TBL_LOOKUP
               WHERE TBL_ID = V_NEW_CASE_TYPE_ID;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              V_NEW_CASE_TYPE_NAME := TO_CHAR(V_NEW_CASE_TYPE_ID);
              WHEN OTHERS THEN
              V_NEW_CASE_TYPE_NAME := TO_CHAR(V_NEW_CASE_TYPE_ID);
            END;

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='employeeName' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='employeeName';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='contactName' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='contactName';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='initialContactDate' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='initialContactDate';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='organization' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='organization';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='primaryDWCSpecialist' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='primaryDWCSpecialist';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = (SELECT VALUE FROM BIZFLOW.RLVNTDATA WHERE RLVNTDATANAME='secondaryDWCSpecialist' AND PROCID = V_FROM_PROCID)
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='secondaryDWCSpecialist';

            UPDATE BIZFLOW.RLVNTDATA
               SET VALUE = V_NEW_CASE_TYPE_NAME
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME='caseType';

            SELECT XMLQUERY('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()' PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_GEN_EMP_HHSID FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item/id[not(contains(text(),"GEN_"))]/..') INTO V_XMLDOC FROM DUAL;
            SELECT DELETEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_CATEGORY"]') INTO V_XMLDOC FROM DUAL;
            
            IF V_NEW_CASE_TYPE_ID IS NOT NULL AND V_NEW_CASE_TYPE_NAME IS NOT NULL THEN
                SELECT UPDATEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_TYPE"]/value/text()', V_NEW_CASE_TYPE_ID) INTO V_XMLDOC FROM DUAL;
                SELECT UPDATEXML(V_XMLDOC,'/formData/items/item[id="GEN_CASE_TYPE"]/text/text()',  V_NEW_CASE_TYPE_NAME) INTO V_XMLDOC FROM DUAL;                
            END IF;
        END IF;        
        
        IF V_XMLDOC IS NULL THEN
            V_XMLDOC := XMLTYPE('<formData xmlns=""><items><item><id>CASE_NUMBER</id><etype>variable</etype><value>'|| V_CASE_NUMBER ||'</value></item></items><history><item /></history></formData>');
        ELSE
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