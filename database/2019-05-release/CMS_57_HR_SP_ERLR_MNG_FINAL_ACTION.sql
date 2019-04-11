create or replace PROCEDURE SP_ERLR_MNG_FINAL_ACTION( 
    I_ACTION IN VARCHAR2,
    I_CASE_TYPE_ID IN VARCHAR2,
    I_LABEL IN VARCHAR2,
    I_UPDATED_LABEL IN VARCHAR2 DEFAULT ''
)
IS
/* This utility program is for ER/LR final action item deletion */

    V_DEL_LABEL VARCHAR2(100);
    V_XPATH VARCHAR2(200);
    V_XPATH_DEL VARCHAR2(200);
BEGIN
    IF I_ACTION = 'DELETE' THEN
        V_XPATH := '/formData/items/item[id="CC_FINAL_ACTION_SEL"]/value/value[.="'||I_LABEL||'"]/text()';
        V_XPATH_DEL := '/formData/items/item[id="CC_FINAL_ACTION_SEL"]/value/value[.="'||I_LABEL||'"]/..';
        FOR FORM_REC IN (
            SELECT P.PROCID, P.STATE, FIELD_DATA, XMLQUERY(V_XPATH PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as FINAL_ACTION,
                   XMLQUERY('/formData/items/item[id="GEN_CASE_TYPE"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as CASE_TYPE_ID
            FROM TBL_FORM_DTL F JOIN BIZFLOW.PROCS P ON F.PROCID = P.PROCID WHERE FORM_TYPE = 'CMSERLR' AND P.STATE != 'C'
        ) 
        LOOP
            IF FORM_REC.FINAL_ACTION IS NOT NULL AND FORM_REC.CASE_TYPE_ID = I_CASE_TYPE_ID THEN
                SELECT DELETEXML(FORM_REC.FIELD_DATA, V_XPATH_DEL) INTO FORM_REC.FIELD_DATA FROM DUAL;
    
                UPDATE TBL_FORM_DTL
                   SET FIELD_DATA = FORM_REC.FIELD_DATA
                 WHERE PROCID = FORM_REC.PROCID;
    
                SP_UPDATE_ERLR_TABLE(FORM_REC.PROCID);
            END IF;
        END LOOP;

       UPDATE TBL_LOOKUP
       SET TBL_ACTIVE = '0', 
           TBL_EXPIRATION_DT = TO_DATE('05/01/2019', 'MM/DD/YYYY')
       WHERE TBL_CATEGORY = 'ERLR'
         AND TBL_LABEL = I_LABEL
         AND TBL_LTYPE='ERLRCasesCompletedFinalAction'
         AND TBL_PARENT_ID = I_CASE_TYPE_ID; 
    ELSIF I_ACTION = 'UPDATE' THEN
        V_XPATH := '/formData/items/item[id="CC_FINAL_ACTION_SEL"]/value/value[.="'||I_LABEL||'"]/text()';
        FOR FORM_REC IN (
            SELECT P.PROCID, P.STATE, FIELD_DATA, XMLQUERY(V_XPATH PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as FINAL_ACTION,
                   XMLQUERY('/formData/items/item[id="GEN_CASE_TYPE"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as CASE_TYPE_ID
            FROM TBL_FORM_DTL F JOIN BIZFLOW.PROCS P ON F.PROCID = P.PROCID WHERE FORM_TYPE = 'CMSERLR'
        ) 
        LOOP
            IF FORM_REC.FINAL_ACTION IS NOT NULL AND FORM_REC.CASE_TYPE_ID = I_CASE_TYPE_ID THEN
                V_XPATH := '/formData/items/item[id="CC_FINAL_ACTION_SEL"]/value/value[.="'||I_LABEL||'"]/text()';
                SELECT UPDATEXML(FORM_REC.FIELD_DATA, V_XPATH, I_UPDATED_LABEL) INTO FORM_REC.FIELD_DATA FROM DUAL;
    
                V_XPATH := '/formData/items/item[id="CC_FINAL_ACTION_SEL"]/value/text[.="'||I_LABEL||'"]/text()';
                SELECT UPDATEXML(FORM_REC.FIELD_DATA, V_XPATH, I_UPDATED_LABEL) INTO FORM_REC.FIELD_DATA FROM DUAL;
    
                UPDATE TBL_FORM_DTL
                   SET FIELD_DATA = FORM_REC.FIELD_DATA
                 WHERE PROCID = FORM_REC.PROCID;
    
                SP_UPDATE_ERLR_TABLE(FORM_REC.PROCID);
            END IF;
        END LOOP;
        
        UPDATE TBL_LOOKUP
           SET TBL_NAME = I_UPDATED_LABEL,
               TBL_LABEL = I_UPDATED_LABEL
         WHERE TBL_CATEGORY = 'ERLR'
           AND TBL_LABEL = I_LABEL
           AND TBL_LTYPE='ERLRCasesCompletedFinalAction'
           AND TBL_PARENT_ID = I_CASE_TYPE_ID;
    END IF;
END;