create or replace FUNCTION         HHS_FN_AUTHORITY_SAM_DOCUMENTS(
    I_MEMBER_ID VARCHAR2,
    I_PROCID NUMBER
)
  -- MEMBER CAN ACCESS SAM'S DOCUMENTS IF RETURN 0, OTHERWISE CANNOT ACCESS DOCUMENTS.
  RETURN INT
IS
 L_CNT INT;
BEGIN
    SELECT SUM(CNT)
      INTO L_CNT
      FROM (
            SELECT COUNT(*) CNT 
              FROM USRGRPPRTCP UG JOIN MEMBER M ON M.MEMBERID = UG.USRGRPID 
             WHERE PRTCP = I_MEMBER_ID
              AND M.NAME IN ('TABG Division Directors','TABG Directors')
            UNION
            SELECT COUNT(*) 
              FROM RLVNTDATA
             WHERE PROCID = I_PROCID
               AND RLVNTDATANAME IN ('hrSpecialist','secondaryHrSpecialist','ohcDirector')
               AND VALUE LIKE CONCAT('%',I_MEMBER_ID)
               
            );    
    RETURN L_CNT;
END;