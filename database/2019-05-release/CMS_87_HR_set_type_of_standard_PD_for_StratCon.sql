
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



SET SERVEROUTPUT ON;

DECLARE    
    V_REQ_ID    NUMBER(20,0);
    V_STD_PD_TYPE VARCHAR2(200);    
BEGIN
    --DBMS_OUTPUT.ENABLE (buffer_size => NULL);
    DBMS_OUTPUT.PUT_LINE('START TYPE OF STANDARD PD ADJUSTMENT ------');

    FOR FORM_REC IN (
        SELECT PROCID, FIELD_DATA, 
                XMLQUERY('/DOCUMENT/GENERAL/STD_PD_TYPE/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STD_PD_TYPE,                
                XMLQUERY('count(/DOCUMENT/GENERAL/STD_PD_TYPE)' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as STD_PD_TYPE_COUNT
          FROM TBL_FORM_DTL         
         WHERE FORM_TYPE = 'CMSCLSF'
         
    )
    LOOP
        IF FORM_REC.STD_PD_TYPE_COUNT > 0 THEN                        
            
            UPDATE
            (
                select STD_PD_TYPE AS OLD_VALUE
                from PD_COVERSHEET
                where 
            ) T
            SET T.OLD_VALUE = STD_PD_TYPE;

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

