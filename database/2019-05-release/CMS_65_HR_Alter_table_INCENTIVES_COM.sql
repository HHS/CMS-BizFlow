
ALTER TABLE HHS_CMS_HR.INCENTIVES_COM ADD REQ_DATE DATE;

UPDATE INCENTIVES_COM IC
   SET REQ_DATE = (
        SELECT DECODE(LENGTH(FN_EXTRACT_STR(FIELD_DATA, 'requestDate')), 
                            19, TO_DATE(FN_EXTRACT_STR(FIELD_DATA, 'requestDate') , 'yyyy/mm/dd hh24:mi:ss')
                            , null)
          FROM TBL_FORM_DTL FD
         WHERE FD.PROCID = IC.PROC_ID
           AND ROWNUM = 1
    );


