create or replace PROCEDURE SP_UPDATE_INCENTIVES_PDP_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
    V_XMLDOC                            XMLTYPE;
    V_CLINICAL_SPCLTY_BOARD_CERT        VARCHAR2(2000);
    V_INCENTIVES_APPRVD_BY_TABG         VARCHAR2(2000);
BEGIN
    --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_INCENTIVES_PDP_TBL2');
    --DBMS_OUTPUT.PUT_LINE('I_PROCID=' || TO_CHAR(I_PROCID));

	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN

        SELECT FIELD_DATA
          INTO V_XMLDOC
          FROM TBL_FORM_DTL
         WHERE PROCID = I_PROCID;
         
        --DBMS_OUTPUT.PUT_LINE('DELETE INCENTIVES_PDP');
		DELETE INCENTIVES_PDP WHERE PROC_ID = I_PROCID;

        --DBMS_OUTPUT.PUT_LINE('INSERT INTO INCENTIVES_PDP');
		INSERT INTO INCENTIVES_PDP (
                            PROC_ID
                            ,PDP_TYPE
                            ,PDP_TYPE_OTHER
                            ,EXISTINGREQUEST
                            ,WORK_SCHEDULE
                            ,HOURS_PER_WEEK
                            ,BD_CERT_REQ
                            ,LIC_INFO
                            ,MARKET_PAY_RATE
                            ,CURRENT_FED_EMPLOYEE
                            ,LEVEL_RESPONSIBILITY
                            ,EXEC_RESP_AMT_REQUESTED
                            ,EXEC_RESP_JUSTIF_DETERMIN_AMT
                            ,EXPT_QF_Q1_AMT_REQUESTED
                            ,EXPT_QF_Q1_JUSTIF_DETERMIN_AMT
                            ,EXPT_QF_Q2_AMT_REQUESTED
                            ,EXPT_QF_Q2_JUSTIF_DETERMIN_AMT
                            ,EXPT_QF_Q3_AMT_REQUESTED
                            ,EXPT_QF_Q3_JUSTIF_DETERMIN_AMT
                            ,EXPT_QF_Q4_AMT_REQUESTED
                            ,EXPT_QF_Q4_JUSTIF_DETERMIN_AMT
                            ,EXPT_QF_Q5_AMT_REQUESTED
                            ,EXPT_QF_Q5_JUSTIF_DETERMIN_AMT
                            ,TOTAL_AMT_EXPT_QUALIFICATIONS
                            ,CURRENT_PAY_GRADE
                            ,CURRENT_PAY_STEP
                            ,CURRENT_PAY_POSITION_TITLE
                            ,CURRENT_PAY_TABLE
                            ,CURRENT_PAY_TIER
                            --,CLINICAL_SPECIALTY_BOARD_CERT --converted multiple value type
                          ,OTHER_SPECIALTY
                            ,CURRENT_PAY_RECRUITMENT
                            ,CURRENT_PAY_RELOCATION
                            ,CURRENT_PAY_RETENTION
                            ,CURRENT_PAY_3R_TOTAL
                            ,CURRENT_PAY_BASE
                            ,CURRENT_PAY_LOCALITY_MARKET
                            ,CURRENT_PAY_TOTAL_ANNUAL_PAY
                            ,CURRENT_PAY_TOTAL_COMPENSATION
                           ,CURRENT_PAY_NOTES
                           ,PROPOSED_PAY_STEP
                            ,PROPOSED_PAY_TABLE
                            ,PROPOSED_PAY_TIER
                            ,PROPOSED_PAY_RECRUITMENT
                            ,PROPOSED_PAY_RELOCATION
                            ,PROPOSED_PAY_RETENTION
                            ,PROPOSED_PAY_TOTAL_3R
                            ,PROPOSED_GS_BASE_PAY,PROPOSED_MARKET_PAY
                            ,PROPOSED_TOTAL_ANNUAL_PAY
                            ,PROPOSED_TOTAL_ANNUAL_COMPENS
                            --,INCENTIVES_APPROVED_BY_TABG --converted multiple value type
                            ,PROPOSED_PAY_NOTES
                            --Panel Tab
                             ,DATE_OF_MEETING
                            ,DATE_OF_RECOMMENDATION --added
                            ,QUORUM_REACHED
                            ,PANEL_CURRENT_SALARY
                            ,PANEL_PDP_AMOUNT
                            ,PANEL_RECOMM_ANNUAL_SALARY

                            ,SELECTING_OFFICIAL_REVIEWER
                            ,SELECTING_OFFICIAL_REVIEW_DT
                            ,TABG_DIVISION_DIR_REVIEW_DT
                            ,CMS_CHIEF_PHYSICIAN_REVIEW_DT
                            ,OFM_REVIEW_DATE
                            ,TABG_REVIEW_DATE
                            ,OHC_REVIEW_DATE
                            ,ADMINISTRATOR_APPROVAL_DATE 
                            )
                    SELECT FD.PROCID AS PROC_ID
                            ,X."PDP_TYPE"
                            ,X."PDP_TYPE_OTHER"
                            ,X."EXISTINGREQUEST"
                            ,X."WORK_SCHEDULE"
                            ,X."HOURS_PER_WEEK"
                            ,X."BD_CERT_REQ"
                            ,X."LIC_INFO"
                            ,X."MARKET_PAY_RATE"
                            ,X."CURRENT_FED_EMPLOYEE"
                            ,X."LEVEL_RESPONSIBILITY"
                            ,regexp_replace(X."EXEC_RESP_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXEC_RESP_JUSTIF_DETERMIN_AMT"
                            ,regexp_replace(X."EXPT_QF_Q1_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXPT_QF_Q1_JUSTIF_DETERMIN_AMT"
                            ,regexp_replace(X."EXPT_QF_Q2_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXPT_QF_Q2_JUSTIF_DETERMIN_AMT"
                            ,regexp_replace(X."EXPT_QF_Q3_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXPT_QF_Q3_JUSTIF_DETERMIN_AMT"
                            ,regexp_replace(X."EXPT_QF_Q4_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXPT_QF_Q4_JUSTIF_DETERMIN_AMT"
                            ,regexp_replace(X."EXPT_QF_Q5_AMT_REQUESTED", '[^0-9|.]', '')
                            ,X."EXPT_QF_Q5_JUSTIF_DETERMIN_AMT"
                           ,regexp_replace(X."TOTAL_AMT_EXPT_QUALIFICATIONS", '[^0-9|.]', '')
                            ,X."CURRENT_PAY_GRADE"
                            ,X."CURRENT_PAY_STEP"
                            ,X."CURRENT_PAY_POSITION_TITLE"
                            ,X."CURRENT_PAY_TABLE"
                            ,X."CURRENT_PAY_TIER"
                            --,X."CLINICAL_SPECIALTY_BOARD_CERT" --converted multiple value type
                            ,X."OTHER_SPECIALTY"
                            ,regexp_replace(X."CURRENT_PAY_RECRUITMENT", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_RELOCATION", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_RETENTION", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_3R_TOTAL", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_BASE", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_LOCALITY_MARKET", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_TOTAL_ANNUAL_PAY", '[^0-9|.]', '')
                            ,regexp_replace(X."CURRENT_PAY_TOTAL_COMPENSATION", '[^0-9|.]', '')
                            ,X."CURRENT_PAY_NOTES"
                            ,X."PROPOSED_PAY_STEP"
                            ,X."PROPOSED_PAY_TABLE"
                            ,X."PROPOSED_PAY_TIER"
                            ,regexp_replace(X."PROPOSED_PAY_RECRUITMENT", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_PAY_RELOCATION", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_PAY_RETENTION", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_PAY_TOTAL_3R", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_GS_BASE_PAY", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_MARKET_PAY", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_TOTAL_ANNUAL_PAY", '[^0-9|.]', '')
                            ,regexp_replace(X."PROPOSED_TOTAL_ANNUAL_COMPENS", '[^0-9|.]', '')
                            --,X."INCENTIVES_APPROVED_BY_TABG" --converted multiple value type
                            ,X."PROPOSED_PAY_NOTES"
                            --Panel tab
                             ,TO_DATE(regexp_replace(X."DATE_OF_MEETING", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."DATE_OF_RECOMMENDATION", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,X."QUORUM_REACHED"
                            ,regexp_replace(X."PANEL_CURRENT_SALARY", '[^0-9|.]', '')
                            ,regexp_replace(X."PANEL_PDP_AMOUNT", '[^0-9|.]', '')
                            ,regexp_replace(X."PANEL_RECOMM_ANNUAL_SALARY", '[^0-9|.]', '') 
                            ,X."SELECTING_OFFICIAL_REVIEWER"
                            ,TO_DATE(regexp_replace(X."SELECTING_OFFICIAL_REVIEW_DT", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."TABG_DIVISION_DIR_REVIEW_DT", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."CMS_CHIEF_PHYSICIAN_REVIEW_DT", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."OFM_REVIEW_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."TABG_REVIEW_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."OHC_REVIEW_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy')
                            ,TO_DATE(regexp_replace(X."ADMINISTRATOR_APPROVAL_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') 
                FROM TBL_FORM_DTL FD,
                     XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
                    PDP_TYPE VARCHAR2(18) PATH './item[id="pdpType"]/value'
                    ,PDP_TYPE_OTHER	VARCHAR2(150)PATH './item[id="pdpTypeOther"]/value'
                    ,EXISTINGREQUEST	VARCHAR2(1)PATH './item[id="associatedRequest"]/value'
                    -- Position
                    ,WORK_SCHEDULE        VARCHAR2(15) PATH './item[id="workSchedule"]/value'
                    ,HOURS_PER_WEEK       VARCHAR2(5) PATH './item[id="hoursPerWeek"]/value'
                    ,BD_CERT_REQ          VARCHAR2(5) PATH './item[id="requireBoardCert"]/value'
                    ,LIC_INFO             VARCHAR2(140) PATH './item[id="licenseInfo"]/value'
                    --Details
                    ,MARKET_PAY_RATE VARCHAR2(9) PATH './item[id="marketPayRate"]/value' 
                    ,CURRENT_FED_EMPLOYEE  VARCHAR2(1) PATH './item[id="currentFederalEmployee"]/value' 
                    ,LEVEL_RESPONSIBILITY VARCHAR2(50) PATH './item[id="execRespLevelOfResponsability"]/value'
                    ,EXEC_RESP_AMT_REQUESTED VARCHAR2(50) PATH './item[id="execRespAmountRequested"]/value' 
                    ,EXEC_RESP_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="execRespJustification"]/value' 
                    ,EXPT_QF_Q1_AMT_REQUESTED VARCHAR2(50) PATH './item[id="excepQualAmountRequested_1"]/value' 
                    ,EXPT_QF_Q1_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_1"]/value' 
                    ,EXPT_QF_Q2_AMT_REQUESTED VARCHAR2(50) PATH './item[id="excepQualAmountRequested_2"]/value' 
                    ,EXPT_QF_Q2_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_2"]/value' 
                    ,EXPT_QF_Q3_AMT_REQUESTED VARCHAR2(50) PATH './item[id="excepQualAmountRequested_3"]/value' 
                    ,EXPT_QF_Q3_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_3"]/value' 
                    ,EXPT_QF_Q4_AMT_REQUESTED VARCHAR2(50) PATH './item[id="excepQualAmountRequested_4"]/value' 
                    ,EXPT_QF_Q4_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_4"]/value' 
                    ,EXPT_QF_Q5_AMT_REQUESTED VARCHAR2(50) PATH './item[id="excepQualAmountRequested_5"]/value' 
                    ,EXPT_QF_Q5_JUSTIF_DETERMIN_AMT VARCHAR2(1000) PATH './item[id="excepQualJustification_5"]/value' 
                    ,TOTAL_AMT_EXPT_QUALIFICATIONS VARCHAR2(50) PATH './item[id="excepQualTotalAmount"]/value'
                    ,CURRENT_PAY_GRADE VARCHAR2(20) PATH './item[id="currentPayInfoGrade"]/value' 
                    ,CURRENT_PAY_STEP VARCHAR2(20) PATH './item[id="currentPayInfoStep"]/value' 
                    ,CURRENT_PAY_POSITION_TITLE VARCHAR2(70) PATH './item[id="currentPayInfoPositionTitle"]/value' 
                    ,CURRENT_PAY_TABLE VARCHAR2(20) PATH './item[id="currentPayInfoTable"]/value' 
                    ,CURRENT_PAY_TIER VARCHAR2(20) PATH './item[id="currentPayInfoTier"]/value' 
                    --,CLINICAL_SPECIALTY_BOARD_CERT VARCHAR2(200) PATH './item[id="currentPayInfoSpecialtyCertification"]/value' --converted multiple value type
                     ,OTHER_SPECIALTY VARCHAR2(140) PATH './item[id="currentPayOtherSpecialty"]/value'
                     ,CURRENT_PAY_RECRUITMENT VARCHAR2(50) PATH './item[id="currentPayInfoRecruitment"]/value' 
                    ,CURRENT_PAY_RELOCATION VARCHAR2(50) PATH './item[id="currentPayInfoRelocation"]/value' 
                    ,CURRENT_PAY_RETENTION VARCHAR2(50) PATH './item[id="currentPayInfoRetention"]/value' 
                    ,CURRENT_PAY_3R_TOTAL VARCHAR2(50) PATH './item[id="currentPayInfoTotal3R"]/value' 
                    ,CURRENT_PAY_BASE VARCHAR2(50) PATH './item[id="currentPayInfoBasePay"]/value' 
                    ,CURRENT_PAY_LOCALITY_MARKET VARCHAR2(50) PATH './item[id="currentPayInfoLocality"]/value' 
                    ,CURRENT_PAY_TOTAL_ANNUAL_PAY VARCHAR2(50) PATH './item[id="currentPayInfoTotalAnnualPay"]/value' 
                    ,CURRENT_PAY_TOTAL_COMPENSATION VARCHAR2(50) PATH './item[id="currentPayInfoTotalAnnualComp"]/value' 
                    ,CURRENT_PAY_NOTES VARCHAR2(500) PATH './item[id="currentPayInfoNotes"]/value' 
                   ,PROPOSED_PAY_STEP VARCHAR2(20) PATH './item[id="proposedPayInfoStep"]/value' 
                    ,PROPOSED_PAY_TABLE VARCHAR2(20) PATH './item[id="proposedPayInfoTable"]/value' 
                    ,PROPOSED_PAY_TIER VARCHAR2(20) PATH './item[id="proposedPayInfoTier"]/value' 
                    ,PROPOSED_PAY_RECRUITMENT VARCHAR2(50) PATH './item[id="proposedPayInfoRecruitment"]/value' 
                    ,PROPOSED_PAY_RELOCATION VARCHAR2(50) PATH './item[id="proposedPayInfoRelocation"]/value' 
                    ,PROPOSED_PAY_RETENTION VARCHAR2(50) PATH './item[id="proposedPayInfoRetention"]/value' 
                    ,PROPOSED_PAY_TOTAL_3R VARCHAR2(50) PATH './item[id="proposedPayInfoTotal3R"]/value' 
                    ,PROPOSED_GS_BASE_PAY VARCHAR2(50) PATH './item[id="proposedPayInfoGSBasePay"]/value' 
                    ,PROPOSED_MARKET_PAY VARCHAR2(50) PATH './item[id="proposedPayInfoMarketPay"]/value' 
                    ,PROPOSED_TOTAL_ANNUAL_PAY VARCHAR2(50) PATH './item[id="proposedPayInfoTotalAnnualPay"]/value'  
                    ,PROPOSED_TOTAL_ANNUAL_COMPENS VARCHAR2(50) PATH './item[id="proposedPayInfoTotalAnnualComp"]/value' 
                    --,INCENTIVES_APPROVED_BY_TABG VARCHAR2(3) PATH './item[id="proposedPayInfoIncentivesApprTABG"]/value' --converted multiple value type
                    ,PROPOSED_PAY_NOTES VARCHAR2(500) PATH './item[id="proposedPayInfoNotes"]/value' 
                    --Panel
                    ,DATE_OF_MEETING VARCHAR2(10) PATH './item[id="panelDateOfMeeting"]/value' 
                    ,DATE_OF_RECOMMENDATION VARCHAR2(10) PATH './item[id="panelDateOfRecommendation"]/value' 
                    ,QUORUM_REACHED VARCHAR2(1) PATH './item[id="selectQuorumReached"]/value'
                    ,PANEL_CURRENT_SALARY VARCHAR2(20) PATH './item[id="panelCurrentSalaryGP"]/value' 
                    ,PANEL_PDP_AMOUNT VARCHAR2(20) PATH './item[id="panelPDPAmount"]/value' 
                    ,PANEL_RECOMM_ANNUAL_SALARY VARCHAR2(20) PATH './item[id="panelRecommendedAnnualSalary"]/value' 
                    --Approval and Review
                    ,SELECTING_OFFICIAL_REVIEWER VARCHAR2(100) PATH './item[id="pdp_reviewSO"]/value' 
                    ,SELECTING_OFFICIAL_REVIEW_DT VARCHAR2(10) PATH './item[id="pdp_reviewSODate"]/value' 
                    ,TABG_DIVISION_DIR_REVIEW_DT VARCHAR2(10) PATH './item[id="pdp_reviewDGODate"]/value' 
                    ,CMS_CHIEF_PHYSICIAN_REVIEW_DT VARCHAR2(10) PATH './item[id="pdp_reviewCPDate"]/value' 
                    ,OFM_REVIEW_DATE VARCHAR2(10) PATH './item[id="pdp_reviewOFMDate"]/value' 
                    ,TABG_REVIEW_DATE VARCHAR2(10) PATH './item[id="pdp_reviewTABGDate"]/value' 
                    ,OHC_REVIEW_DATE VARCHAR2(10) PATH './item[id="pdp_reviewOHCDate"]/value' 
                    ,ADMINISTRATOR_APPROVAL_DATE VARCHAR2(10) PATH './item[id="pdp_adminApprovalDate"]/value'
                    ) X
            WHERE FD.PROCID = I_PROCID;

        --------------------
        -- Details Tab / Muti value (used same methods in other workstream implementation).    
        SELECT XMLQUERY('for $i in /formData/items/item[id="currentPayInfoSpecialtyCertification"]/value[string-length(value/text()) > 0] return concat($i/value/text(), ", ")'
               PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_CLINICAL_SPCLTY_BOARD_CERT FROM DUAL;
        V_CLINICAL_SPCLTY_BOARD_CERT := SUBSTR(V_CLINICAL_SPCLTY_BOARD_CERT, 0, LENGTH(V_CLINICAL_SPCLTY_BOARD_CERT)-2);
        --DBMS_OUTPUT.PUT_LINE('V_CLINICAL_SPCLTY_BOARD_CERT=[' || V_CLINICAL_SPCLTY_BOARD_CERT || ']');

        SELECT XMLQUERY('for $i in /formData/items/item[id="proposedPayInfoIncentivesApprTABG"]/value[string-length(value/text()) > 0] return concat($i/value/text(), ", ")'
               PASSING V_XMLDOC RETURNING CONTENT).GETSTRINGVAL() INTO V_INCENTIVES_APPRVD_BY_TABG FROM DUAL;
        V_INCENTIVES_APPRVD_BY_TABG := SUBSTR(V_INCENTIVES_APPRVD_BY_TABG, 0, LENGTH(V_INCENTIVES_APPRVD_BY_TABG)-2);
        --DBMS_OUTPUT.PUT_LINE('V_INCENTIVES_APPRVD_BY_TABG=[' || V_INCENTIVES_APPRVD_BY_TABG || ']');

        UPDATE INCENTIVES_PDP
           SET CLINICAL_SPECIALTY_BOARD_CERT = V_CLINICAL_SPCLTY_BOARD_CERT
               , INCENTIVES_APPROVED_BY_TABG = V_INCENTIVES_APPRVD_BY_TABG
         WHERE PROC_ID = I_PROCID;

        --------------------
        --Panel Tab
        --DBMS_OUTPUT.PUT_LINE('PANEL TAB');
        --DBMS_OUTPUT.PUT_LINE('PANEL TAB-DELETE');
        DELETE FROM HHS_CMS_HR.INCENTIVES_PDP_PANEL
        WHERE PROC_ID = I_PROCID;

        --DBMS_OUTPUT.PUT_LINE('PANEL TAB-INSERT');
        INSERT INTO INCENTIVES_PDP_PANEL
                                (
                                PROC_ID
                                ,SEQ_NUM
                                ,FULL_NAME
                                ,COMPONENT_NAME
                                ,EMAIL
                                ,HHSID
                                ,ADMIN_CODE
                                ,PANEL_ROLE
                                ,VOTING_STATUS
                                ,PANEL_REC_COMP
                                )
                    SELECT FD.PROCID
                           ,ROWNUM
                           ,x.FULL_NAME
                           ,x.COMPONENT_NAME
                           ,x.EMAIL
                           ,x.HHSID
                           ,x.ADMIN_CODE
                           ,x.PANEL_ROLE
                           ,x.VOTING_STATUS
                           ,x.PANEL_REC_COMP        
                    FROM TBL_FORM_DTL FD,
                         XMLTABLE('/formData/items/item[id="panelItems"]/value' PASSING FD.FIELD_DATA COLUMNS
                            FULL_NAME			VARCHAR2(200) PATH './name'
                            ,COMPONENT_NAME		VARCHAR2(200) PATH './component'
                            ,EMAIL		        VARCHAR2(100) PATH './email'
                            ,HHSID		        VARCHAR2(20) PATH './HHSID'
                            ,ADMIN_CODE		    VARCHAR2(20) PATH './adminCode'
                            ,PANEL_ROLE		    VARCHAR2(20) PATH './role'
                            ,VOTING_STATUS		VARCHAR2(50) PATH './votingStatus'
                            ,PANEL_REC_COMP	    VARCHAR2(50) PATH './recCompensation'
                        ) X
                    WHERE FD.PROCID = I_PROCID;

	END IF;

	EXCEPTION
	WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION=' || SUBSTR(SQLERRM, 1, 200));
          --err_code := SQLCODE;
          --err_msg := SUBSTR(SQLERRM, 1, 200);
		SP_ERROR_LOG();
END;
/

GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_PDP_TABLE TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_UPDATE_INCENTIVES_PDP_TABLE TO HHS_CMS_HR_DEV_ROLE;
/