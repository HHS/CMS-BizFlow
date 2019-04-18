
-- Type of Standard PD for completed/existing StratCon request is 'N/A'
SET SERVEROUTPUT ON;

DECLARE    
    V_REQ_ID    NUMBER(20,0);
    V_STD_PD_TYPE VARCHAR2(200);    
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
       
        END IF;              
                    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('------ END');    

--  COMMIT;

END;
/

