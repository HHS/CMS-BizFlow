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

