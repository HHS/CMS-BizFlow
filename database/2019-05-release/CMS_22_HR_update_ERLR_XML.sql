-- update GEN_CASE_CATEGORY
DECLARE
    V_LABEL VARCHAR2(200);
    C_XML XMLTYPE;
    V_XMLDOC XMLTYPE;    
BEGIN
    FOR FORM_REC IN (
          SELECT * FROM (
          SELECT F.PROCID, FIELD_DATA, MOD_DT,
                 XMLQUERY('/formData/items/item[id="GEN_CASE_CATEGORY"]/value/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as CATEGORY_IDS,
                 XMLQUERY('/formData/items/item[id="GEN_CASE_CATEGORY_SEL"]/value/value/text()' PASSING FIELD_DATA RETURNING CONTENT).getStringVal() as TARGET
          FROM TBL_FORM_DTL F JOIN BIZFLOW.PROCS P ON F.PROCID = P.PROCID WHERE FORM_TYPE = 'CMSERLR')
         WHERE TARGET IS NULL
    ) 
    LOOP
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
        
    END LOOP;
    
    COMMIT;
END;
