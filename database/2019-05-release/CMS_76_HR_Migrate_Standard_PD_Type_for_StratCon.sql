SET SERVEROUTPUT ON;

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

--  COMMIT;

END;
/

