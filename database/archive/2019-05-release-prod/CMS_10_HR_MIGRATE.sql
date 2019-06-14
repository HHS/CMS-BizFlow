SET SERVEROUTPUT ON;
SET DEFINE OFF

-- CMS_22_HR_update_ERLR_XML.sql

-- update GEN_CASE_CATEGORY
DECLARE
    V_LABEL VARCHAR2(200);
    C_XML XMLTYPE;
    V_XMLDOC XMLTYPE;    
BEGIN
    FOR FORM_REC IN (
          SELECT F.PROCID, FIELD_DATA, MOD_DT,
                 XMLQUERY('/formData/items/item[id="GEN_CASE_CATEGORY"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as CATEGORY_IDS,
                 XMLQUERY('/formData/items/item[id="GEN_CASE_CATEGORY_SEL"]/value/value/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as TARGET
          FROM TBL_FORM_DTL F JOIN BIZFLOW.PROCS P ON F.PROCID = P.PROCID WHERE FORM_TYPE = 'CMSERLR'
    ) 
    LOOP
        IF FORM_REC.TARGET IS NULL THEN
            IF FORM_REC.CATEGORY_IDS IS NOT NULL THEN
                C_XML := XMLTYPE('<item><id>GEN_CASE_CATEGORY_SEL</id><etype>object</etype></item>');
                FOR ID_REC IN (        
                    SELECT TRIM(REGEXP_SUBSTR(V,'[^,]+', 1, level) ) CATEGORY_ID
                      FROM (SELECT FORM_REC.CATEGORY_IDS AS V FROM DUAL)
                      CONNECT BY REGEXP_SUBSTR(V, '[^,]+', 1, level) IS NOT NULL)
                LOOP
                    SELECT MAX(TBL_LABEL)
                      INTO V_LABEL
                      FROM TBL_LOOKUP 
                     WHERE TBL_ID = ID_REC.CATEGORY_ID;
                    
                    SELECT APPENDCHILDXML(C_XML, 'item', XMLELEMENT("value", XMLELEMENT("value", ID_REC.CATEGORY_ID), XMLELEMENT("text", V_LABEL))) INTO C_XML FROM DUAL;                                
                END LOOP;
                
                SELECT DELETEXML(FORM_REC.FIELD_DATA,'/formData/items/item[id="GEN_CASE_CATEGORY"]') INTO FORM_REC.FIELD_DATA FROM DUAL;
                SELECT DELETEXML(FORM_REC.FIELD_DATA,'/formData/items/item[id="GEN_CASE_CATEGORY_SEL"]') INTO FORM_REC.FIELD_DATA FROM DUAL;
                UPDATE TBL_FORM_DTL
                   SET FIELD_DATA = APPENDCHILDXML(FORM_REC.FIELD_DATA, '/formData/items', C_XML)
                 WHERE PROCID = FORM_REC.PROCID;
            END IF;        
            
            SP_UPDATE_ERLR_TABLE(FORM_REC.PROCID);
            
            UPDATE ERLR_GEN
               SET MOD_DT = FORM_REC.MOD_DT
             WHERE PROCID = FORM_REC.PROCID;        
        END IF;        
    END LOOP;
    
    COMMIT;
END;
/

-- CMS_33_HR_UPDATE_CLASS_IN_FORM.sql


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

END;
/

-- CMS_76_HR_Migrate_Standard_PD_Type_for_StratCon.sql
CREATE TABLE FORM_BACKUP_CW (
  PROCID NUMBER,
  FIELD_DATA XMLTYPE,
  CMNT VARCHAR(200)
);

DECLARE
    C_XML XMLTYPE;    
    V_STD_PD_TYPE VARCHAR2(200);    
BEGIN
    --DBMS_OUTPUT.ENABLE (buffer_size => NULL);
    DBMS_OUTPUT.PUT_LINE('START ADD TYPE OF STANDARD PD TO STRATCON FOMR DATA ------');

    FOR FORM_REC IN (
        SELECT PROCID, FIELD_DATA,                 
                XMLQUERY('count(/DOCUMENT/POSITION/POS_STD_PD_TYPE)' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STD_PD_TYPE_COUNT
          FROM TBL_FORM_DTL         
         WHERE FORM_TYPE = 'CMSSTRATCON'
         
    )
    LOOP
        IF FORM_REC.STD_PD_TYPE_COUNT = 0 THEN            
            
            V_STD_PD_TYPE := 'N/A';

            -- Back up
            INSERT INTO FORM_BACKUP_CW(PROCID, FIELD_DATA) VALUES(FORM_REC.PROCID, FORM_REC.FIELD_DATA);            
            
            --DBMS_OUTPUT.PUT_LINE('PROCID: [' || FORM_REC.PROCID || ']');

            -- Add Type of Standard PD into Form data
            C_XML := XMLTYPE('<POS_STD_PD_TYPE>' || V_STD_PD_TYPE || '</POS_STD_PD_TYPE>');
            SELECT APPENDCHILDXML(FORM_REC.FIELD_DATA, '/DOCUMENT/POSITION', C_XML) INTO FORM_REC.FIELD_DATA FROM DUAL;
            
            --DBMS_OUTPUT.PUT_LINE('        XML [' || FORM_REC.FIELD_DATA.getstringval() || ']');           

            UPDATE TBL_FORM_DTL SET FIELD_DATA = FORM_REC.FIELD_DATA WHERE PROCID = FORM_REC.PROCID;

        END IF;              
                    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('------ END');    
END;
/

-- CMS_78_HR_Migrate_ComponentWide_to_StandardPDType.sql
SET SERVEROUTPUT ON;

DECLARE
    C_XML XMLTYPE;    
    V_STD_PD_TYPE VARCHAR2(200);    
BEGIN
    --DBMS_OUTPUT.ENABLE (buffer_size => NULL);
    DBMS_OUTPUT.PUT_LINE('START TYPE OF STANDARD PD ADJUSTMENT ------');

    FOR FORM_REC IN (
        SELECT PROCID, FIELD_DATA, 
                XMLQUERY('/DOCUMENT/GENERAL/PD_SCOPE/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as PD_SCOPE,
                XMLQUERY('count(/DOCUMENT/GENERAL/PD_SCOPE)' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as PD_SCOPE_COUNT,
                XMLQUERY('count(/DOCUMENT/GENERAL/STD_PD_TYPE)' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STD_PD_TYPE_COUNT
          FROM TBL_FORM_DTL         
         WHERE FORM_TYPE = 'CMSCLSF'
         
    )
    LOOP
        IF FORM_REC.STD_PD_TYPE_COUNT = 0 and FORM_REC.PD_SCOPE_COUNT > 0 THEN            
            
            -- Back up
            INSERT INTO FORM_BACKUP_CW(PROCID, FIELD_DATA) VALUES(FORM_REC.PROCID, FORM_REC.FIELD_DATA);

            -- Get the value of Component Wide Field and translate it to the value for Type of Standard PD
            IF FORM_REC.PD_SCOPE = 'Yes' THEN
                V_STD_PD_TYPE := 'CMS-wide';
            ELSE
                V_STD_PD_TYPE := 'N/A';
            END IF;    
            
        --    DBMS_OUTPUT.PUT_LINE('PROCID: [' || FORM_REC.PROCID || '] -- COUNT [' || FORM_REC.PD_SCOPE_COUNT || '] COMPONENT-WIDE [' || FORM_REC.PD_SCOPE || '] TYPE OF STANDARD PD [' || V_STD_PD_TYPE || ']');

            -- Add Type of Standard PD into Form data
            C_XML := XMLTYPE('<STD_PD_TYPE>' || V_STD_PD_TYPE || '</STD_PD_TYPE>');
            SELECT APPENDCHILDXML(FORM_REC.FIELD_DATA, '/DOCUMENT/GENERAL', C_XML) INTO FORM_REC.FIELD_DATA FROM DUAL;
            
        --    DBMS_OUTPUT.PUT_LINE('        XML [' || FORM_REC.FIELD_DATA.getstringval() || ']');           

            UPDATE TBL_FORM_DTL SET FIELD_DATA = FORM_REC.FIELD_DATA WHERE PROCID = FORM_REC.PROCID;

        END IF;              
                    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('------ END');    

--  COMMIT;

END;
/

-- CMS_87_HR_set_type_of_standard_PD_for_StratCon.sql
-- Type of Standard PD for completed/existing StratCon request is 'N/A'
 
DECLARE   
    V_REQ_ID    NUMBER(20,0);
    V_STD_PD_TYPE VARCHAR2(200);
    V_COUNT     NUMBER(20,0);
BEGIN   
    DBMS_OUTPUT.PUT_LINE('START SETTING VALUE FOR TYPE OF STANDARD PD IN REPORT TABLES OF STRATEGIC CONSULTATION ------');
 
    FOR FORM_REC IN (
        SELECT PROCID,
                XMLQUERY('/DOCUMENT/PROCESS_VARIABLE/requestNum/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() AS REQ_NUM,
                XMLQUERY('/DOCUMENT/POSITION/POS_STD_PD_TYPE/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() AS STD_PD_TYPE,               
                XMLQUERY('count(/DOCUMENT/POSITION/POS_STD_PD_TYPE)' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() AS STD_PD_TYPE_COUNT
          FROM TBL_FORM_DTL        
         WHERE FORM_TYPE = 'CMSSTRATCON'
        
    )
    LOOP
        IF FORM_REC.STD_PD_TYPE_COUNT = 0 OR FORM_REC.REQ_NUM IS NULL THEN                       
            DBMS_OUTPUT.PUT_LINE('Nothing to update FOR PROCID: [' || FORM_REC.PROCID || ']' );
           
        ELSE
 
            V_STD_PD_TYPE := FORM_REC.STD_PD_TYPE;
           
            SELECT COUNT(*) INTO V_COUNT
            FROM REQUEST
            WHERE REQ_JOB_REQ_NUMBER = FORM_REC.REQ_NUM;
           
            IF V_COUNT >= 1 THEN
            SELECT REQ_ID INTO V_REQ_ID
            FROM REQUEST
            WHERE REQ_JOB_REQ_NUMBER = FORM_REC.REQ_NUM;
 
            UPDATE
            (
                SELECT POS_STD_PD_TYPE AS OLD_VALUE
                FROM POSITION
                WHERE POS_REQ_ID = V_REQ_ID
            ) T
            SET T.OLD_VALUE = V_STD_PD_TYPE;
          
            DBMS_OUTPUT.PUT_LINE('PROCID: [' || FORM_REC.PROCID || '] -- TYPE OF STANDARD PD [' || V_STD_PD_TYPE || '] -- REQ_ID :[' || V_REQ_ID || '] -- REQ_NUMBER : [' || FORM_REC.REQ_NUM || ']');
          ELSE
            DBMS_OUTPUT.PUT_LINE('NOT FOUND : ' || FORM_REC.REQ_NUM);
          END IF;
        END IF;             
                    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('------ END');   
 
END;
/

-- CMS_88_HR_set_type_of_standard_PD_for_Classification.sql
DECLARE    
    V_REQ_ID    NUMBER(20,0);
    V_JOB_REQ_NUM VARCHAR2(200);
    V_STD_PD_TYPE VARCHAR2(200);    
BEGIN    
    DBMS_OUTPUT.PUT_LINE('START SETTING VALUE FOR TYPE OF STANDARD PD IN REPORT TABLES OF CLASSIFICATION ------');

    FOR FORM_REC IN (
        SELECT PROCID,                
                XMLQUERY('/DOCUMENT/GENERAL/STD_PD_TYPE/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() AS STD_PD_TYPE,                
                XMLQUERY('count(/DOCUMENT/GENERAL/STD_PD_TYPE)' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() AS STD_PD_TYPE_COUNT
          FROM TBL_FORM_DTL         
         WHERE FORM_TYPE = 'CMSCLSF'
         
    )
    LOOP
        BEGIN
          SELECT VALUE
          INTO V_JOB_REQ_NUM
          FROM BIZFLOW.RLVNTDATA
          WHERE PROCID = FORM_REC.PROCID AND RLVNTDATANAME = 'requestNum';        
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_JOB_REQ_NUM := NULL;
        END;
        
        IF FORM_REC.STD_PD_TYPE_COUNT = 0 OR V_JOB_REQ_NUM IS NULL THEN                        
            DBMS_OUTPUT.PUT_LINE('Nothing to update FOR PROCID: [' || FORM_REC.PROCID || ']' );
            
        ELSE

            V_STD_PD_TYPE := FORM_REC.STD_PD_TYPE;
            
            BEGIN
              SELECT REQ_ID INTO V_REQ_ID
              FROM REQUEST
              WHERE REQ_JOB_REQ_NUMBER = V_JOB_REQ_NUM;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              V_REQ_ID := NULL;
            END;
            
            IF V_REQ_ID IS NULL THEN
              DBMS_OUTPUT.PUT_LINE('NO REQ_ID FOR : [' || V_JOB_REQ_NUM || ']' );
            ELSE             

              UPDATE
              (
                  SELECT STD_PD_TYPE AS OLD_VALUE
                  FROM PD_COVERSHEET
                  WHERE PD_REQ_ID = V_REQ_ID 
              ) T
              SET T.OLD_VALUE = V_STD_PD_TYPE;
             
              DBMS_OUTPUT.PUT_LINE('PROCID: [' || FORM_REC.PROCID || '] -- TYPE OF STANDARD PD [' || V_STD_PD_TYPE || '] -- REQ_ID :[' || V_REQ_ID || '] -- REQ_NUMBER : [' || V_JOB_REQ_NUM || ']');
            
            END IF;
        END IF;              
                    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('------ END');    

END;
/

SET SERVEROUTPUT ON

DECLARE 
   type caseNumbersArray IS VARRAY(50) OF INTEGER; 
   type cancelReasonArray IS VARRAY(50) OF VARCHAR2(400); 
   caseNumbers caseNumbersArray; 
   cancelReasons cancelReasonArray; 
   total integer; 
BEGIN 
   cancelReasons := cancelReasonArray('Settlement', 'Management Direction', 'Case Opened in Error', 'Settlement', 'Case Opened in Error', 
'Duplicate Case', 'Case Opened in Error', 'Duplicate Case', 'Case Opened in Error', 'Union Did Not Pursue Case',
'Management Direction', 'Management Direction', 'Union Did Not Pursue Case', 'Management Direction', 'Management Direction',
'Management Direction', 'Management Direction', 'Management Direction', 'Management Direction', 'Management Direction',
'Case Opened in Error', 'Manager Decided Not to Pursue', 'Employee Transferred', 'Management Direction', 'Manager Decided Not to Pursue', 
'Management Direction', 'Management Direction', 'Management Direction', 'Management Direction', 'Union Did Not Pursue Case',
'Management Direction', 'Management Direction', 'Management Direction', 'Management Direction', 'Manager Decided Not to Pursue',
'Manager Decided Not to Pursue', 'Manager Decided Not to Pursue', 'Management Direction', 'Management Direction', 'Management Direction', 
'Case Opened in Error', 'Case Opened in Error', 'Settlement', 'Management Direction', 'Manager Decided Not to Pursue',
'Management Direction', 'Management Direction', 'Management Direction', 'Management Direction', 'Management Direction');

   caseNumbers:= caseNumbersArray(725027, 725033, 725038, 725043, 725062, 725063, 725065, 725066, 725076, 725085, 
725086, 725087, 725088, 725096, 725097, 725098,  725099, 725100, 725101, 725102,
725104, 725105, 725107, 725108, 725109, 725110, 725111, 725112, 725113, 725120,
725123, 725125, 725126, 725132, 725133, 725134, 725135, 725137, 725138, 725139, 
725148, 725149, 725181, 725201, 725226, 725069, 725103, 725214, 725221, 725223); 
   total := caseNumbers.count; 
   dbms_output.put_line('Total '|| total || ' Requests'); 
   dbms_output.put_line('ERLR Request Number : Cancellation Reason'); 
   FOR i in 1 .. total LOOP     
    dbms_output.put_line(caseNumbers(i) || '  ' || cancelReasons(i)); 
    UPDATE ERLR_GEN SET CANCEL_REASON = cancelReasons(i) WHERE ERLR_CASE_NUMBER = caseNumbers(i); 
   END LOOP; 
END; 
/

COMMIT;
/


