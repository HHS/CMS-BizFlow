create or replace FUNCTION FN_GET_FINAL_ACTIONS
  (
    I_PROCID              IN  NVARCHAR2
  )
  RETURN NVARCHAR2
IS
  VAL VARCHAR2(200);
BEGIN
    SELECT 
      XMLQUERY('for $i in /formData/items/item[id="CC_FINAL_ACTION_SEL"]/value
                   return concat($i/value/text(), ",")' 
      PASSING field_data 
    RETURNING CONTENT).GETSTRINGVAL() 
    INTO VAL
    FROM TBL_FORM_DTL
    WHERE PROCID=I_PROCID;
   
    VAL := SUBSTR(VAL, 0, LENGTH(VAL)-1);
    DBMS_OUTPUT.PUT_LINE(VAL);
    RETURN VAL;
END;