/*
 * Performance Tuning
 * Data Type mismatch: Currency and Date fields are all varchar2.
 * new columns are added with correct datatype.
 * Change the stored procedure to update new columns.
 */
create or replace PROCEDURE SP_UPDATE_INCENTIVES_LE_TABLE
  (
    I_PROCID            IN      NUMBER
  )
IS
    V_XMLREC_CNT                INTEGER := 0;
BEGIN

    DBMS_OUTPUT.PUT_LINE('SP_UPDATE_INCENTIVES_LE_TBL2');
    DBMS_OUTPUT.PUT_LINE('I_PROCID=' || TO_CHAR(I_PROCID));
	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN

        SELECT COUNT(*)
          INTO V_XMLREC_CNT
          FROM TBL_FORM_DTL
         WHERE PROCID = I_PROCID;
        
        
        IF V_XMLREC_CNT > 0 THEN
			DBMS_OUTPUT.PUT_LINE('RECORD FOUND PROCID=' || TO_CHAR(I_PROCID));
            
			MERGE INTO INCENTIVES_LE TRG
			USING
			(
                     SELECT FD.PROCID AS PROC_ID
                            , X.INIT_ANN_LA_RATE
                            , X.SUPPORT_LE
                            , X.PROPS_ANN_LA_RATE
                            , X.JUSTIFICATION_SKILL_EXP
                            , X.JUSTIFICATION_AGENCY_GOAL
                            , X.SELECTEE_ELIGIBILITY
                            , X.HRS_RVW_CERT
                            , X.HRS_NOT_SPT_RSN
                            , X.RVW_HRS
                            , X.HRS_RVW_DATE
                            , X.RCMD_LA_RATE
                            , X.APPROVAL_SO_VALUE
                            , X.APPROVAL_SO
                            , X.APPROVAL_SO_RESP_DATE
                            , X.APPROVAL_DGHO_VALUE
                            , X.APPROVAL_DGHO
                            , X.APPROVAL_DGHO_RESP_DATE
                            , X.APPROVAL_TABG_VALUE
                            , X.APPROVAL_TABG
                            , X.APPROVAL_TABG_RESP_DATE
                            , X.COC_NAME
                            , X.COC_EMAIL
                            , X.COC_ID
                            , X.COC_TITLE
                            , X.APPROVAL_COC_VALUE
                            , X.APPROVAL_COC_ACTING
                            , X.APPROVAL_COC
                            , X.APPROVAL_COC_RESP_DATE
                            , X.APPROVAL_SO_ACTING
                            , X.APPROVAL_DGHO_ACTING
                            , X.APPROVAL_TABG_ACTING
                            --, X.JUSTIFICATION_VER
                            --, X.JUSTIFICATION_CRT_NAME
                            --, X.JUSTIFICATION_CRT_ID
                            --, X.JUSTIFICATION_CRT_DATE
                            , X.JUSTIFICATION_LASTMOD_NAME
                            , X.JUSTIFICATION_LASTMOD_ID
                            --, X.JUSTIFICATION_LASTMOD_DATE
                            , X.JUSTIFICATION_MOD_REASON
                            , X.JUSTIFICATION_MOD_SUMMARY
                            , X.JUSTIFICATION_MODIFIER_NAME
                            , X.JUSTIFICATION_MODIFIER_ID
                            , X.JUSTIFICATION_MODIFIED_DATE
                            , X.TOTAL_CREDITABLE_YEARS
                            , X.TOTAL_CREDITABLE_MONTHS
                            , X.APPROVER_NOTES
                            ,TO_DATE(regexp_replace(X."HRS_RVW_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as HRS_RVW_DATE_D
                            ,TO_DATE(regexp_replace(X."APPROVAL_SO_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_SO_RESP_DATE_D
                            ,TO_DATE(regexp_replace(X."APPROVAL_DGHO_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_DGHO_RESP_DATE_D
                            ,TO_DATE(regexp_replace(X."APPROVAL_TABG_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_TABG_RESP_DATE_D
                            ,TO_DATE(regexp_replace(X."APPROVAL_COC_RESP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_COC_RESP_DATE_D
                            --,TO_DATE(regexp_replace(X."JUSTIFICATION_CRT_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as JUSTIFICATION_CRT_DATE_D
                            --,TO_DATE(regexp_replace(X."JUSTIFICATION_LASTMOD_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as JUSTIFICATION_LASTMOD_DATE_D
                            ,TO_DATE(regexp_replace(X."JUSTIFICATION_MODIFIED_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as JUSTIFICATION_MODIFIED_DATE_D
                    FROM TBL_FORM_DTL FD,
                         XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
                            COC_NAME VARCHAR2(100) PATH './item[id="lecocDirector"]/value/name'
                            , COC_EMAIL VARCHAR2(100) PATH './item[id="lecocDirector"]/value/email'
                            , COC_ID VARCHAR2(10) PATH './item[id="lecocDirector"]/value/id'
                            , COC_TITLE VARCHAR2(100) PATH './item[id="lecocDirector"]/value/title'
                            , INIT_ANN_LA_RATE VARCHAR2(10) PATH './item[id="initialOfferedAnnualLeaveAccrualRate"]/value'
                            , SUPPORT_LE VARCHAR2(5) PATH './item[id="supportLE"]/value'
                            , PROPS_ANN_LA_RATE VARCHAR2(10) PATH './item[id="proposedAnnualLeaveAccrualRate"]/value'
                            , TOTAL_CREDITABLE_YEARS NUMBER(10) PATH './item[id="totalCreditableServiceYears"]/value'
                            , TOTAL_CREDITABLE_MONTHS NUMBER(10) PATH './item[id="totalCreditableServiceMonths"]/value'
                            -- Justification
                            , JUSTIFICATION_LASTMOD_NAME VARCHAR2(100) PATH './item[id="currentUser"]/value'
                            , JUSTIFICATION_LASTMOD_ID VARCHAR2(10) PATH './item[id="currentUserId"]/value'
                            , JUSTIFICATION_MOD_REASON VARCHAR2(200) PATH './item[id="leJustificationModificationReason"]/value'
                            , JUSTIFICATION_MOD_SUMMARY VARCHAR2(500) PATH './item[id="leJustificationModificationSummary"]/value'
                            , JUSTIFICATION_MODIFIER_NAME VARCHAR2(100) PATH './item[id="leJustificationModifier"]/value'
                            , JUSTIFICATION_MODIFIER_ID VARCHAR2(10) PATH './item[id="leJustificationModifierId"]/value'
                            , JUSTIFICATION_MODIFIED_DATE VARCHAR2(20) PATH './item[id="leJustificationModified"]/value'
                            , JUSTIFICATION_SKILL_EXP VARCHAR2(4000) PATH './item[id="justificationSkillAndExperience"]/value'
                            , JUSTIFICATION_AGENCY_GOAL VARCHAR2(4000) PATH './item[id="justificationAgencyMissionOrPerformanceGoal"]/value'
                            -- Review
                            , SELECTEE_ELIGIBILITY VARCHAR2(100) PATH './item[id="leSelecteeEligibility"]/value'
                            , HRS_RVW_CERT VARCHAR2(100) PATH './item[id="hrSpecialistLEReviewCertification"]/value'
                            , HRS_NOT_SPT_RSN VARCHAR2(100) PATH './item[id="hrSpecialistLENotSupportReason"]/value'
                            , RVW_HRS VARCHAR2(100) PATH './item[id="leReviewHRSpecialist"]/value'
                            , HRS_RVW_DATE VARCHAR2(10) PATH './item[id="hrSpecialistLEReviewDate"]/value'
                            , RCMD_LA_RATE VARCHAR2(10) PATH './item[id="rcmdAnnualLeaveAccrualRate"]/value'
                            -- Approvals
                            , APPROVAL_SO_VALUE VARCHAR2(10) PATH './item[id="leApprovalSOValue"]/value'
                            , APPROVAL_SO_ACTING VARCHAR2(10) PATH './item[id="leApprovalSOActing"]/value'
                            , APPROVAL_SO VARCHAR2(100) PATH './item[id="leApprovalSO"]/value'
                            , APPROVAL_SO_RESP_DATE VARCHAR2(10) PATH './item[id="leApprovalSOResponseDate"]/value'
                            , APPROVAL_COC_VALUE VARCHAR2(10) PATH './item[id="leApprovalCOCValue"]/value'
                            , APPROVAL_COC_ACTING VARCHAR2(10) PATH './item[id="leApprovalCOCActing"]/value'
                            , APPROVAL_COC VARCHAR2(100) PATH './item[id="leApprovalCOC"]/value'
                            , APPROVAL_COC_RESP_DATE VARCHAR2(10) PATH './item[id="leApprovalCOCResponseDate"]/value'
                            , APPROVAL_DGHO_VALUE VARCHAR2(10) PATH './item[id="leApprovalDGHOValue"]/value'
                            , APPROVAL_DGHO_ACTING VARCHAR2(10) PATH './item[id="leApprovalDGHOActing"]/value'
                            , APPROVAL_DGHO VARCHAR2(100) PATH './item[id="leApprovalDGHO"]/value'
                            , APPROVAL_DGHO_RESP_DATE VARCHAR2(10) PATH './item[id="leApprovalDGHOResponseDate"]/value'
                            , APPROVAL_TABG_VALUE VARCHAR2(10) PATH './item[id="leApprovalTABGValue"]/value'
                            , APPROVAL_TABG_ACTING VARCHAR2(10) PATH './item[id="leApprovalTABGActing"]/value'
                            , APPROVAL_TABG VARCHAR2(100) PATH './item[id="leApprovalTABG"]/value'
                            , APPROVAL_TABG_RESP_DATE VARCHAR2(10) PATH './item[id="leApprovalTABGResponseDate"]/value'
                            , APPROVER_NOTES VARCHAR2(500) PATH './item[id="leApproverNotes"]/value'
                        ) X
                    WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.PROC_ID = TRG.PROC_ID)
            WHEN MATCHED THEN UPDATE SET
                            TRG.INIT_ANN_LA_RATE = SRC.INIT_ANN_LA_RATE
                            , TRG.SUPPORT_LE = SRC.SUPPORT_LE
                            , TRG.PROPS_ANN_LA_RATE = SRC.PROPS_ANN_LA_RATE
                            , TRG.JUSTIFICATION_SKILL_EXP = SRC.JUSTIFICATION_SKILL_EXP
                            , TRG.JUSTIFICATION_AGENCY_GOAL = SRC.JUSTIFICATION_AGENCY_GOAL
                            , TRG.SELECTEE_ELIGIBILITY = SRC.SELECTEE_ELIGIBILITY
                            , TRG.HRS_RVW_CERT = SRC.HRS_RVW_CERT
                            , TRG.HRS_NOT_SPT_RSN = SRC.HRS_NOT_SPT_RSN
                            , TRG.RVW_HRS = SRC.RVW_HRS
                            , TRG.HRS_RVW_DATE = SRC.HRS_RVW_DATE
                            , TRG.RCMD_LA_RATE = SRC.RCMD_LA_RATE
                            , TRG.APPROVAL_SO_VALUE = SRC.APPROVAL_SO_VALUE
                            , TRG.APPROVAL_SO = SRC.APPROVAL_SO
                            , TRG.APPROVAL_SO_RESP_DATE = SRC.APPROVAL_SO_RESP_DATE
                            , TRG.APPROVAL_DGHO_VALUE = SRC.APPROVAL_DGHO_VALUE
                            , TRG.APPROVAL_DGHO = SRC.APPROVAL_DGHO
                            , TRG.APPROVAL_DGHO_RESP_DATE = SRC.APPROVAL_DGHO_RESP_DATE
                            , TRG.APPROVAL_TABG_VALUE = SRC.APPROVAL_TABG_VALUE
                            , TRG.APPROVAL_TABG = SRC.APPROVAL_TABG
                            , TRG.APPROVAL_TABG_RESP_DATE = SRC.APPROVAL_TABG_RESP_DATE
                            , TRG.COC_NAME = SRC.COC_NAME
                            , TRG.COC_EMAIL = SRC.COC_EMAIL
                            , TRG.COC_ID = SRC.COC_ID
                            , TRG.COC_TITLE = SRC.COC_TITLE
                            , TRG.APPROVAL_COC_VALUE = SRC.APPROVAL_COC_VALUE
                            , TRG.APPROVAL_COC_ACTING = SRC.APPROVAL_COC_ACTING
                            , TRG.APPROVAL_COC = SRC.APPROVAL_COC
                            , TRG.APPROVAL_COC_RESP_DATE = SRC.APPROVAL_COC_RESP_DATE
                            , TRG.APPROVAL_SO_ACTING = SRC.APPROVAL_SO_ACTING
                            , TRG.APPROVAL_DGHO_ACTING = SRC.APPROVAL_DGHO_ACTING
                            , TRG.APPROVAL_TABG_ACTING = SRC.APPROVAL_TABG_ACTING
                            --, TRG.JUSTIFICATION_VER = SRC.JUSTIFICATION_VER
                            --, TRG.JUSTIFICATION_CRT_NAME = SRC.JUSTIFICATION_CRT_NAME
                            --, TRG.JUSTIFICATION_CRT_ID = SRC.JUSTIFICATION_CRT_ID
                            --, TRG.JUSTIFICATION_CRT_DATE = SRC.JUSTIFICATION_CRT_DATE
                            , TRG.JUSTIFICATION_LASTMOD_NAME = SRC.JUSTIFICATION_LASTMOD_NAME
                            , TRG.JUSTIFICATION_LASTMOD_ID = SRC.JUSTIFICATION_LASTMOD_ID
                            --, TRG.JUSTIFICATION_LASTMOD_DATE = SRC.JUSTIFICATION_LASTMOD_DATE
                            , TRG.JUSTIFICATION_MOD_REASON = SRC.JUSTIFICATION_MOD_REASON
                            , TRG.JUSTIFICATION_MOD_SUMMARY = SRC.JUSTIFICATION_MOD_SUMMARY
                            , TRG.JUSTIFICATION_MODIFIER_NAME = SRC.JUSTIFICATION_MODIFIER_NAME
                            , TRG.JUSTIFICATION_MODIFIER_ID = SRC.JUSTIFICATION_MODIFIER_ID
                            , TRG.JUSTIFICATION_MODIFIED_DATE = SRC.JUSTIFICATION_MODIFIED_DATE
                            , TRG.TOTAL_CREDITABLE_YEARS = SRC.TOTAL_CREDITABLE_YEARS
                            , TRG.TOTAL_CREDITABLE_MONTHS = SRC.TOTAL_CREDITABLE_MONTHS
                            , TRG.APPROVER_NOTES = SRC.APPROVER_NOTES
                            , TRG.HRS_RVW_DATE_D = SRC.HRS_RVW_DATE_D
                            , TRG.APPROVAL_SO_RESP_DATE_D = SRC.APPROVAL_SO_RESP_DATE_D
                            , TRG.APPROVAL_DGHO_RESP_DATE_D = SRC.APPROVAL_DGHO_RESP_DATE_D
                            , TRG.APPROVAL_TABG_RESP_DATE_D = SRC.APPROVAL_TABG_RESP_DATE_D
                            , TRG.APPROVAL_COC_RESP_DATE_D = SRC.APPROVAL_COC_RESP_DATE_D
                            --, TRG.JUSTIFICATION_CRT_DATE_D = SRC.JUSTIFICATION_CRT_DATE_D
                            --, TRG.JUSTIFICATION_LASTMOD_DATE_D = SRC.JUSTIFICATION_LASTMOD_DATE_D
                            , TRG.JUSTIFICATION_MODIFIED_DATE_D = SRC.JUSTIFICATION_MODIFIED_DATE_D 
            WHEN NOT MATCHED THEN INSERT (
                            TRG.PROC_ID
                            , TRG.INIT_ANN_LA_RATE
                            , TRG.SUPPORT_LE
                            , TRG.PROPS_ANN_LA_RATE
                            , TRG.JUSTIFICATION_SKILL_EXP
                            , TRG.JUSTIFICATION_AGENCY_GOAL
                            , TRG.SELECTEE_ELIGIBILITY
                            , TRG.HRS_RVW_CERT
                            , TRG.HRS_NOT_SPT_RSN
                            , TRG.RVW_HRS
                            , TRG.HRS_RVW_DATE
                            , TRG.RCMD_LA_RATE
                            , TRG.APPROVAL_SO_VALUE
                            , TRG.APPROVAL_SO
                            , TRG.APPROVAL_SO_RESP_DATE
                            , TRG.APPROVAL_DGHO_VALUE
                            , TRG.APPROVAL_DGHO
                            , TRG.APPROVAL_DGHO_RESP_DATE
                            , TRG.APPROVAL_TABG_VALUE
                            , TRG.APPROVAL_TABG
                            , TRG.APPROVAL_TABG_RESP_DATE
                            , TRG.COC_NAME
                            , TRG.COC_EMAIL
                            , TRG.COC_ID
                            , TRG.COC_TITLE
                            , TRG.APPROVAL_COC_VALUE
                            , TRG.APPROVAL_COC_ACTING
                            , TRG.APPROVAL_COC
                            , TRG.APPROVAL_COC_RESP_DATE
                            , TRG.APPROVAL_SO_ACTING
                            , TRG.APPROVAL_DGHO_ACTING
                            , TRG.APPROVAL_TABG_ACTING
                            --, TRG.JUSTIFICATION_VER
                            --, TRG.JUSTIFICATION_CRT_NAME
                            --, TRG.JUSTIFICATION_CRT_ID
                            --, TRG.JUSTIFICATION_CRT_DATE
                            , TRG.JUSTIFICATION_LASTMOD_NAME
                            , TRG.JUSTIFICATION_LASTMOD_ID
                            --, TRG.JUSTIFICATION_LASTMOD_DATE
                            , TRG.JUSTIFICATION_MOD_REASON
                            , TRG.JUSTIFICATION_MOD_SUMMARY
                            , TRG.JUSTIFICATION_MODIFIER_NAME
                            , TRG.JUSTIFICATION_MODIFIER_ID
                            , TRG.JUSTIFICATION_MODIFIED_DATE
                            , TRG.TOTAL_CREDITABLE_YEARS
                            , TRG.TOTAL_CREDITABLE_MONTHS
                            , TRG.APPROVER_NOTES
                            , TRG.HRS_RVW_DATE_D
                            , TRG.APPROVAL_SO_RESP_DATE_D
                            , TRG.APPROVAL_DGHO_RESP_DATE_D
                            , TRG.APPROVAL_TABG_RESP_DATE_D
                            , TRG.APPROVAL_COC_RESP_DATE_D
                            --, TRG.JUSTIFICATION_CRT_DATE_D
                            --, TRG.JUSTIFICATION_LASTMOD_DATE_D
                            , TRG.JUSTIFICATION_MODIFIED_DATE_D
                            
                        ) VALUES (
                            SRC.PROC_ID
                            , SRC.INIT_ANN_LA_RATE
                            , SRC.SUPPORT_LE
                            , SRC.PROPS_ANN_LA_RATE
                            , SRC.JUSTIFICATION_SKILL_EXP
                            , SRC.JUSTIFICATION_AGENCY_GOAL
                            , SRC.SELECTEE_ELIGIBILITY
                            , SRC.HRS_RVW_CERT
                            , SRC.HRS_NOT_SPT_RSN
                            , SRC.RVW_HRS
                            , SRC.HRS_RVW_DATE
                            , SRC.RCMD_LA_RATE
                            , SRC.APPROVAL_SO_VALUE
                            , SRC.APPROVAL_SO
                            , SRC.APPROVAL_SO_RESP_DATE
                            , SRC.APPROVAL_DGHO_VALUE
                            , SRC.APPROVAL_DGHO
                            , SRC.APPROVAL_DGHO_RESP_DATE
                            , SRC.APPROVAL_TABG_VALUE
                            , SRC.APPROVAL_TABG
                            , SRC.APPROVAL_TABG_RESP_DATE
                            , SRC.COC_NAME
                            , SRC.COC_EMAIL
                            , SRC.COC_ID
                            , SRC.COC_TITLE
                            , SRC.APPROVAL_COC_VALUE
                            , SRC.APPROVAL_COC_ACTING
                            , SRC.APPROVAL_COC
                            , SRC.APPROVAL_COC_RESP_DATE
                            , SRC.APPROVAL_SO_ACTING
                            , SRC.APPROVAL_DGHO_ACTING
                            , SRC.APPROVAL_TABG_ACTING
                            --, SRC.JUSTIFICATION_VER
                            --, SRC.JUSTIFICATION_CRT_NAME
                            --, SRC.JUSTIFICATION_CRT_ID
                            --, SRC.JUSTIFICATION_CRT_DATE
                            , SRC.JUSTIFICATION_LASTMOD_NAME
                            , SRC.JUSTIFICATION_LASTMOD_ID
                            --, SRC.JUSTIFICATION_LASTMOD_DATE
                            , SRC.JUSTIFICATION_MOD_REASON
                            , SRC.JUSTIFICATION_MOD_SUMMARY
                            , SRC.JUSTIFICATION_MODIFIER_NAME
                            , SRC.JUSTIFICATION_MODIFIER_ID
                            , SRC.JUSTIFICATION_MODIFIED_DATE
                            , SRC.TOTAL_CREDITABLE_YEARS
                            , SRC.TOTAL_CREDITABLE_MONTHS
                            , SRC.APPROVER_NOTES
                            , SRC.HRS_RVW_DATE_D
                            , SRC.APPROVAL_SO_RESP_DATE_D
                            , SRC.APPROVAL_DGHO_RESP_DATE_D
                            , SRC.APPROVAL_TABG_RESP_DATE_D
                            , SRC.APPROVAL_COC_RESP_DATE_D
                            --, SRC.JUSTIFICATION_CRT_DATE_D
                            --, SRC.JUSTIFICATION_LASTMOD_DATE_D
                            , SRC.JUSTIFICATION_MODIFIED_DATE_D
                        );

			DELETE INCENTIVES_LE_CRED WHERE PROC_ID = I_PROCID;
			INSERT INTO INCENTIVES_LE_CRED(
                    PROC_ID
                    , SEQ_NUM
                    , START_DATE
                    , END_DATE
                    , WORK_SCHEDULE
                    , POS_TITLE
                    , CALCULATED_YEARS
                    , CALCULATED_MONTHS
                    , CREDITABLE_YEARS
                    , CREDITABLE_MONTHS)
            SELECT FD.PROCID
                    , x.SEQ_NUM
                    , x.START_DATE
                    , x.END_DATE
                    , x.WORK_SCHEDULE
                    , x.POS_TITLE
                    , NVL(x.CALCULATED_YEARS,0) AS CALCULATED_YEARS
                    , NVL(x.CALCULATED_MONTHS,0) AS CALCULATED_MONTHS
                    , NVL(x.CREDITABLE_YEARS,0) AS CREDITABLE_YEARS
                    , NVL(x.CREDITABLE_MONTHS,0) AS CREDITABLE_MONTHS
            FROM TBL_FORM_DTL FD,
             XMLTABLE('/formData/items/item[id="creditableNonFederalServices"]/value' PASSING FD.FIELD_DATA COLUMNS
                    SEQ_NUM FOR ORDINALITY,
                    START_DATE			VARCHAR2(10) PATH './startDate',
                    END_DATE			VARCHAR2(10) PATH './endDate',
                    WORK_SCHEDULE		VARCHAR2(15) PATH './workSchedule',
                    POS_TITLE			VARCHAR2(140) PATH './positionTitle',
                    CALCULATED_YEARS	NUMBER(10) PATH './calculatedTime/years',
                    CALCULATED_MONTHS	NUMBER(10) PATH './calculatedTime/months',
                    CREDITABLE_YEARS	NUMBER(10) PATH './creditableTime/years',
                    CREDITABLE_MONTHS	NUMBER(10) PATH './creditableTime/months'
            ) X
			WHERE FD.PROCID = I_PROCID;

        END IF;

    END IF;
        
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION=' || SUBSTR(SQLERRM, 1, 200));
          --err_code := SQLCODE;
          --err_msg := SUBSTR(SQLERRM, 1, 200);    
    SP_ERROR_LOG();
  END;
