SET SERVEROUTPUT ON;


CREATE TABLE FORM_BACKUP (
  PROCID NUMBER,
  FIELD_DATA XMLTYPE,
  CMNT VARCHAR(200)
);

/*
select * from FORM_BACKUP
drop table FORM_BACKUP
commit
rollback
*/

-- update PD_CLS_STANDARDS
DECLARE
    C_XML XMLTYPE;
    V_VALUE VARCHAR2(400);
    V_NEW_CLASS_STANDARD VARCHAR2(200);
    V_REC_COUNT NUMBER;
    V_ID1 VARCHAR2(64);
    V_ID2 VARCHAR2(64);
    V_ID3 VARCHAR2(64);
    V_ID4 VARCHAR2(64);
    V_ID5 VARCHAR2(64);
    V_ID6 VARCHAR2(64);
    V_ID7 VARCHAR2(64);
BEGIN
    DBMS_OUTPUT.PUT_LINE('START CLASSIFICATION STANDARD ADJUSTMENT ------');

    FOR FORM_REC IN (
        SELECT A.PROCID, A.FIELD_DATA, 
                XMLQUERY('/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STANDARD_IDS,
                XMLQUERY('count(/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS)' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STANDARD_IDS_COUNT
          FROM TBL_FORM_DTL A
         INNER JOIN BIZFLOW.PROCS B ON A.PROCID = B.PROCID
         WHERE A.FORM_TYPE = 'CMSCLSF'
           AND B.STATE in ('R', 'E', 'V', 'S', 'D', 'J') -- Only Running Process.
    )
    LOOP
        IF FORM_REC.STANDARD_IDS IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('PROCID: [' || FORM_REC.PROCID || '] -- COUNT [' || FORM_REC.STANDARD_IDS_COUNT || '] STANDARD [' || FORM_REC.STANDARD_IDS || ']');
            V_NEW_CLASS_STANDARD := '';
            
            IF FORM_REC.STANDARD_IDS_COUNT = 1 THEN
                INSERT INTO FORM_BACKUP(PROCID, FIELD_DATA) VALUES(FORM_REC.PROCID, FORM_REC.FIELD_DATA);
              
                FOR ID_REC IN (        
                    SELECT TRIM(REGEXP_SUBSTR(V,'[^,]+', 1, level) ) STANDARD_ID
                      FROM (SELECT FORM_REC.STANDARD_IDS AS V FROM DUAL)
                      CONNECT BY REGEXP_SUBSTR(V, '[^,]+', 1, level) IS NOT NULL)
                LOOP
                    SELECT COUNT(*) INTO V_REC_COUNT 
                      FROM TBL_LOOKUP
                     WHERE TBL_ID = ID_REC.STANDARD_ID
                       AND TBL_ACTIVE = '1';

                    IF V_REC_COUNT > 0 THEN     
                        IF LENGTH(V_NEW_CLASS_STANDARD) > 0 THEN 
                            V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || ',';
                        END IF;
                        V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || ID_REC.STANDARD_ID;
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('        STANDARD [' || ID_REC.STANDARD_ID || '] IS REMOVED.');
                    END IF;
                END LOOP;
              
                DBMS_OUTPUT.PUT_LINE('        NEW VALUE [' || V_NEW_CLASS_STANDARD || ']');
              
                IF LENGTH(V_NEW_CLASS_STANDARD) > 0 THEN
                    SELECT updateXML(FORM_REC.FIELD_DATA, '/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS/text()', V_NEW_CLASS_STANDARD) into FORM_REC.FIELD_DATA FROM DUAL;
                    --DBMS_OUTPUT.PUT_LINE('        XML [' || FORM_REC.FIELD_DATA.getstringval() || ']');
                    UPDATE TBL_FORM_DTL SET FIELD_DATA = FORM_REC.FIELD_DATA WHERE PROCID = FORM_REC.PROCID;
                ELSE
                    UPDATE FORM_BACKUP SET CMNT = 'Empty Standard' WHERE PROCID = FORM_REC.PROCID;
                    DBMS_OUTPUT.PUT_LINE('        EMPTY STANDARD - CHECK THIS PROCESS.');
                END IF;

            ELSIF FORM_REC.STANDARD_IDS_COUNT = 0 THEN
                DBMS_OUTPUT.PUT_LINE('        DETECTED NO CLASS STANDARD.');
            ELSE
                --DBMS_OUTPUT.PUT_LINE('        DETECTED MULTIPLE CLASS STANDARD.');
                INSERT INTO FORM_BACKUP(PROCID, FIELD_DATA) VALUES(FORM_REC.PROCID, FORM_REC.FIELD_DATA);
              
                SELECT
                   XMLQUERY('/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS[1]/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STANDARD_IDS1,
                   XMLQUERY('/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS[2]/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STANDARD_IDS2,
                   XMLQUERY('/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS[3]/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STANDARD_IDS3,
                   XMLQUERY('/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS[4]/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STANDARD_IDS4,
                   XMLQUERY('/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS[5]/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STANDARD_IDS5,
                   XMLQUERY('/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS[6]/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STANDARD_IDS6,
                   XMLQUERY('/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS[7]/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STANDARD_IDS7
                   INTO V_ID1,V_ID2,V_ID3,V_ID4,V_ID5,V_ID6,V_ID7
                  FROM TBL_FORM_DTL 
                 WHERE PROCID = FORM_REC.PROCID;
             
                DBMS_OUTPUT.PUT_LINE('        V1[' || V_ID1 || '] V2[' || V_ID2 || '] V3[' || V_ID3 || '] V4[' || V_ID4 || '] V5[' || V_ID5 || '] V6[' || V_ID6 || '] V7[' || V_ID7 || ']');
             
                SELECT DELETEXML(FORM_REC.FIELD_DATA, '/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS') INTO FORM_REC.FIELD_DATA FROM DUAL;
             
                IF LENGTH(V_ID1) > 0 THEN
                    SELECT COUNT(*) INTO V_REC_COUNT FROM TBL_LOOKUP WHERE TBL_ID = V_ID1 AND TBL_ACTIVE = '1';
                    IF V_REC_COUNT > 0 THEN   
                        V_NEW_CLASS_STANDARD := V_ID1;
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('        CLASS [' || V_ID1 || '] IS REMOVED.');
                    END IF;   
                END IF;
             
                IF LENGTH(V_ID2) > 0 THEN
                    SELECT COUNT(*) INTO V_REC_COUNT FROM TBL_LOOKUP WHERE TBL_ID = V_ID2 AND TBL_ACTIVE = '1';
                  
                    IF V_REC_COUNT > 0 THEN   
                        IF LENGTH(V_NEW_CLASS_STANDARD) > 0 THEN 
                            V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || ',';
                        END IF;
               
                        V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || V_ID2;
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('        CLASS [' || V_ID2 || '] IS REMOVED.');
                    END IF;
                END IF;
             
                IF LENGTH(V_ID3) > 0 THEN
                    SELECT COUNT(*) INTO V_REC_COUNT FROM TBL_LOOKUP WHERE TBL_ID = V_ID3 AND TBL_ACTIVE = '1';
                  
                    IF V_REC_COUNT > 0 THEN                  
                        IF LENGTH(V_NEW_CLASS_STANDARD) > 0 THEN 
                            V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || ',';
                        END IF;
               
                        V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || V_ID3;
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('        CLASS [' || V_ID3 || '] IS REMOVED.');
                    END IF;
                END IF;

                IF LENGTH(V_ID4) > 0 THEN
                    SELECT COUNT(*) INTO V_REC_COUNT FROM TBL_LOOKUP WHERE TBL_ID = V_ID4 AND TBL_ACTIVE = '1';
                  
                    IF V_REC_COUNT > 0 THEN                  
                        IF LENGTH(V_NEW_CLASS_STANDARD) > 0 THEN 
                            V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || ',';
                        END IF;
                   
                        V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || V_ID4;
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('        CLASS [' || V_ID4 || '] IS REMOVED.');
                    END IF;
                END IF;

                IF LENGTH(V_ID5) > 0 THEN
                    SELECT COUNT(*) INTO V_REC_COUNT FROM TBL_LOOKUP WHERE TBL_ID = V_ID5 AND TBL_ACTIVE = '1';
                  
                    IF V_REC_COUNT > 0 THEN                  
                        IF LENGTH(V_NEW_CLASS_STANDARD) > 0 THEN 
                            V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || ',';
                        END IF;
                 
                        V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || V_ID5;
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('        CLASS [' || V_ID5 || '] IS REMOVED.');                   
                    END IF;
                END IF;

                IF LENGTH(V_ID6) > 0 THEN
                    SELECT COUNT(*) INTO V_REC_COUNT FROM TBL_LOOKUP WHERE TBL_ID = V_ID6 AND TBL_ACTIVE = '1';
                  
                    IF V_REC_COUNT > 0 THEN                  
                        IF LENGTH(V_NEW_CLASS_STANDARD) > 0 THEN 
                            V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || ',';
                        END IF;
               
                        V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || V_ID6;
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('        CLASS [' || V_ID6 || '] IS REMOVED.');
                    END IF;
                END IF;

                IF LENGTH(V_ID7) > 0 THEN
                    SELECT COUNT(*) INTO V_REC_COUNT FROM TBL_LOOKUP WHERE TBL_ID = V_ID7 AND TBL_ACTIVE = '1';
                  
                    IF V_REC_COUNT > 0 THEN                  
                        IF LENGTH(V_NEW_CLASS_STANDARD) > 0 THEN 
                            V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || ',';
                        END IF;
               
                        V_NEW_CLASS_STANDARD := V_NEW_CLASS_STANDARD || V_ID7;
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('        CLASS [' || V_ID7 || '] IS REMOVED.');
                    END IF;
                END IF;

                DBMS_OUTPUT.PUT_LINE('        NEW VALUE [' || V_NEW_CLASS_STANDARD || ']');
             
                IF LENGTH(V_NEW_CLASS_STANDARD) > 0 THEN
                    C_XML := XMLTYPE('<PD_CLS_STANDARDS>' || V_NEW_CLASS_STANDARD || '</PD_CLS_STANDARDS>');
                    SELECT APPENDCHILDXML(FORM_REC.FIELD_DATA, '/DOCUMENT/CLASSIFICATION_CODE', C_XML) INTO FORM_REC.FIELD_DATA FROM DUAL;
                    --DBMS_OUTPUT.PUT_LINE('        XML [' || FORM_REC.FIELD_DATA.getstringval() || ']');
                    UPDATE TBL_FORM_DTL SET FIELD_DATA = FORM_REC.FIELD_DATA WHERE PROCID = FORM_REC.PROCID;
                ELSE
                    UPDATE FORM_BACKUP SET CMNT = 'Empty Standard' WHERE PROCID = FORM_REC.PROCID;
                END IF;
            END IF;
        END IF;        
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('------ END');    

--  COMMIT;

END;
/

