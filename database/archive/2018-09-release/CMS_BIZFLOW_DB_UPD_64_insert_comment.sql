/**
* Insert comment into the cmnt table
* This SP is for Notes Tab implementation.
*
* @param	I_SVRID
* @param	I_PROCID
* @param	I_WITEMSEQ
* @param	I_ACTSEQ
* @param	I_ACTNAME
* @param	I_CREATOR
* @param	I_CREATORNAME
* @param	I_CONTENTS
*/
create or replace PROCEDURE SP_INSERT_COMMENT
  (
      I_SVRID           IN      VARCHAR2
    , I_PROCID          IN      NUMBER
    , I_WITEMSEQ        IN      NUMBER
    , I_ACTSEQ          IN      NUMBER
    , I_ACTNAME         IN      VARCHAR2
    , I_CREATOR         IN      VARCHAR2
    , I_CREATORNAME     IN      VARCHAR2
    , I_CONTENTS        IN      VARCHAR2
  )
IS
  V_CMNTSEQ     NUMBER(10);
  V_PROCIDSTR   VARCHAR2(10);
  V_UTC         DATE;    

  BEGIN

    IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
    
      SELECT TO_CHAR(I_PROCID)
      INTO V_PROCIDSTR
      FROM DUAL;
      
      SP_GET_ID(I_SVRID, V_PROCIDSTR, 1, V_CMNTSEQ);
      COMMIT;      
      
      SELECT SYSTIMESTAMP AT TIME ZONE 'UTC'
      INTO V_UTC
      FROM DUAL;      
      
      INSERT INTO CMNT
      (SVRID, PROCID, CMNTSEQ, GETTYPE, SENDTYPE, WITEMSEQ, ACTSEQ, ACTNAME, CREATIONDTIME, CREATOR, CREATORNAME, CONTENTS)
      VALUES
      (I_SVRID, I_PROCID, V_CMNTSEQ, 'C', 'B', I_WITEMSEQ, I_ACTSEQ, I_ACTNAME, V_UTC, I_CREATOR, I_CREATORNAME, I_CONTENTS);
      
      COMMIT;

    END IF;

  EXCEPTION
  
    WHEN OTHERS THEN
      raise_application_error(-20714, sqlerrm);
  
  END;

  /
