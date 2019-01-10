create or replace PROCEDURE SP_UPDATE_ERLR_FORM_DATA 
   (I_WIH_ACTION IN VARCHAR2, -- SAVE, SUBMIT
    I_FIELD_DATA IN CLOB, 
    I_USER       IN VARCHAR2, 
    I_PROCID     IN NUMBER, 
    I_ACTSEQ     IN NUMBER, 
    I_WITEMSEQ   IN NUMBER) 
IS 
  V_XMLDOC               XMLTYPE;
  V_FORM_TYPE            VARCHAR2(20) := 'CMSERLR';
  V_CNT                  INT;
  COMPLATE_CASE_ACTIVITY CONSTANT VARCHAR2(50) := 'Complete Case';
  DWC_SUPERVISOR         CONSTANT VARCHAR2(50) := 'DWC Supervisor';
BEGIN 
    -- sanity check: ignore and exit if form data xml is null or empty 
    IF I_FIELD_DATA IS NULL OR LENGTH(I_FIELD_DATA) <= 0 OR I_PROCID IS NULL OR I_USER IS NULL OR I_ACTSEQ IS NULL THEN 
      RETURN; 
    END IF;
    
    -- TODO: I_USER should be member of work item checked out
    --

    V_XMLDOC := XMLTYPE(I_FIELD_DATA); 

    MERGE INTO TBL_FORM_DTL A
    USING (SELECT * FROM TBL_FORM_DTL WHERE PROCID=I_PROCID) B
       ON (A.PROCID = B.PROCID)
     WHEN MATCHED THEN
          UPDATE 
             SET A.FIELD_DATA = V_XMLDOC, 
                 A.MOD_DT = SYS_EXTRACT_UTC(SYSTIMESTAMP), 
                 A.MOD_USR = I_USER 
     WHEN NOT MATCHED THEN     
          INSERT (A.PROCID, A.ACTSEQ, A.WITEMSEQ, A.FORM_TYPE, A.FIELD_DATA, A.CRT_DT, A.CRT_USR) 
          VALUES (I_PROCID, NVL(I_ACTSEQ, 0), NVL(I_WITEMSEQ, 0), V_FORM_TYPE, V_XMLDOC, SYS_EXTRACT_UTC(SYSTIMESTAMP), I_USER); 

    -- Update process variable and transition xml into individual tables 
    -- for respective process definition 
    SP_UPDATE_PV_ERLR(I_PROCID, V_XMLDOC); 
    SP_UPDATE_ERLR_TABLE(I_PROCID); 
/*************************************************    
    IF UPPER(I_WIH_ACTION) = 'SUBMIT' THEN
        -- CHECK: 'Complate Case' activity
        SELECT COUNT(*)
          INTO V_CNT
          FROM BIZFLOW.ACT
         WHERE PROCID = I_PROCID
           AND ACTSEQ = I_ACTSEQ
           AND NAME = COMPLETE_CASE_ACTIVITY;
        IF 0<V_CNT THEN
            -- CHECK: I_USER is member of 'DWC Supervisor' group
            SELECT COUNT(*)
              INTO V_CNT
              FROM BIZFLOW.USRGRPPRTCP P JOIN BIZFLOW.MEMBER M ON P.USRGRPID = M.MEMBERID
             WHERE M.TYPE='G'
               AND M.NAME = DWC_SUPERVISOR
               AND P.PRTCP = I_USER;
            IF 0<V_CNT THEN
                -- DWC Superviosr complete the 'Complete Case' activity
                UPDATE BIZFLOW.RLVNTDATA
                   SET VALUE = 'Yes'
                 WHERE RLVNTDATANAME = 'completeCaseActivityPostCondition'
                   AND PROCID = I_PROCID;
            ELSE
                
            END IF;
        END IF;
    END IF;
****************************************************/   
EXCEPTION 
  WHEN OTHERS THEN 
             SP_ERROR_LOG(); 
END; 
/

GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_ERLR_FORM_DATA TO HHS_CMS_HR_RW_ROLE;
/
