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
  V_XMLVALUE             XMLTYPE;
  V_CNT                  INT;
  V_PRIMARY_SPECIALIST   VARCHAR2(20);
  CREATE_CASE_ACTIVITY CONSTANT VARCHAR2(50) := 'Create Case';
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

    IF UPPER(I_WIH_ACTION) = 'SAVE' THEN
        -- Set Primary Specialist to Workitem owner at Create Case Activity
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id=''GEN_PRIMARY_SPECIALIST'']/value/text()');
        IF V_XMLVALUE IS NOT NULL THEN
            V_PRIMARY_SPECIALIST := V_XMLVALUE.GETSTRINGVAL();
            V_PRIMARY_SPECIALIST := SUBSTR(V_PRIMARY_SPECIALIST, 4);
            
            UPDATE BIZFLOW.WITEM W
               SET (PRTCPTYPE, PRTCP, PRTCPNAME) = (SELECT TYPE, MEMBERID, NAME FROM BIZFLOW.MEMBER WHERE MEMBERID = V_PRIMARY_SPECIALIST)
             WHERE W.PROCID = I_PROCID
               AND W.ACTSEQ = I_ACTSEQ
               AND W.WITEMSEQ = I_WITEMSEQ
               AND W.PRTCP <> V_PRIMARY_SPECIALIST
               AND EXISTS (SELECT 1 
                             FROM BIZFLOW.ACT
                            WHERE NAME = CREATE_CASE_ACTIVITY 
                              AND PROCID = W.PROCID 
                              AND ACTSEQ = W.ACTSEQ);
        END IF;    
    END IF;

    -- Update process variable and transition xml into individual tables 
    -- for respective process definition 
    SP_UPDATE_PV_ERLR(I_PROCID, V_XMLDOC); 
    SP_UPDATE_ERLR_TABLE(I_PROCID); 

EXCEPTION 
  WHEN OTHERS THEN 
             SP_ERROR_LOG(); 

END;