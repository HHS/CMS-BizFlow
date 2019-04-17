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

--  COMMIT;

END;
/
