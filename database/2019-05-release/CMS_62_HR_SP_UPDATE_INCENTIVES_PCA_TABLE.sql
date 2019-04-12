/*
 * Performance Tuning
 * Data Type mismatch: Currency and Date fields are all varchar2.
 * new columns are added with correct datatype.
 * Change the stored procedure to update new columns.
 */
create or replace PROCEDURE SP_UPDATE_INCENTIVES_PCA_TABLE
  (
    I_PROCID            IN      NUMBER
  )
IS
    V_XMLREC_CNT                INTEGER := 0;
BEGIN

    --DBMS_OUTPUT.PUT_LINE('SP_UPDATE_INCENTIVES_LE_TBL2');
    --DBMS_OUTPUT.PUT_LINE('I_PROCID=' || TO_CHAR(I_PROCID));
	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN

        SELECT COUNT(*)
          INTO V_XMLREC_CNT
          FROM TBL_FORM_DTL
         WHERE PROCID = I_PROCID;
        
        IF V_XMLREC_CNT > 0 THEN
			--DBMS_OUTPUT.PUT_LINE('RECORD FOUND PROCID=' || TO_CHAR(I_PROCID));
            
			MERGE INTO INCENTIVES_PCA TRG
			USING
			(
                     SELECT FD.PROCID AS PROC_ID
                            , X.PCA_TYPE
                            , X.CANDI_AGREE
                            , X.CP_NAME
                            , X.CP_EMAIL
                            , X.CP_ID
                            , X.OFM_NAME
                            , X.OFM_EMAIL
                            , X.OFM_ID
                            , X.ADMIN_APPROVAL_REQ
                            , X.OHC_NAME
                            , X.OHC_EMAIL
                            , X.OHC_ID
                            , X.OADMIN_NAME
                            , X.OADMIN_EMAIL
                            , X.OADMIN_ID
                            , X.WORK_SCHEDULE
                            , X.HOURS_PER_WEEK
                            , X.BD_CERT_REQ
                            , X.LIC_INFO
                            , X.LIC_STATE1_STATE
                            , X.LIC_STATE1_NAME
                            , X.LIC_STATE1_EXP_DATE
                            , X.LIC_STATE2_STATE
                            , X.LIC_STATE2_NAME
                            , X.LIC_STATE2_EXP_DATE
                            , X.BD_CERT_SPEC1
                            , X.BD_CERT_SPEC2
                            , X.BD_CERT_SPEC3
                            , X.BD_CERT_SPEC4
                            , X.BD_CERT_SPEC5
                            , X.BD_CERT_SPEC6
                            , X.BD_CERT_SPEC7
                            , X.BD_CERT_SPEC8
                            , X.BD_CERT_SPEC9
                            , X.BD_CERT_SPEC_OTHER
                            , X.LEN_SERVED
                            , X.LEN_SERVICE
                            , X.ALW_CATEGORY
                            , X.ALW_BD_CERT
                            , X.ALW_MULTI_YEAR_AGMT
                            , X.ALW_MISSION_SC
                            , X.ALW_TOTAL
                            , X.ALW_TOTAL_PAYABLE
                            , X.DETAIL_REMARKS
                            , X.RVW_SO_NAME
                            , X.RVW_SO_ID
                            , X.RVW_SO_DATE
                            , X.RVW_DGHO_NAME
                            , X.RVW_DGHO_ID
                            , X.RVW_DGHO_DATE
                            , X.RVW_CP_NAME
                            , X.RVW_CP_ID
                            , X.RVW_CP_DATE
                            , X.RVW_OFM_NAME
                            , X.RVW_OFM_ID
                            , X.RVW_OFM_DATE
                            , X.RVW_TABG_NAME
                            , X.RVW_TABG_ID
                            , X.RVW_TABG_DATE
                            , X.RVW_OHC_NAME
                            , X.RVW_OHC_ID
                            , X.RVW_OHC_DATE
                            , X.APPROVAL_TABG_NAME
                            , X.APPROVAL_TABG_ID
                            , X.APPROVAL_TABG_DATE
                            , X.APPROVAL_OADMIN_NAME
                            , X.APPROVAL_OADMIN_ID
                            , X.APPROVAL_OADMIN_DATE
                            -- new columsn for data type fixes
                            , TO_DATE(regexp_replace(X."LIC_STATE1_EXP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as LIC_STATE1_EXP_DATE_D
                            , TO_DATE(regexp_replace(X."LIC_STATE2_EXP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as LIC_STATE2_EXP_DATE_D
                            , regexp_replace(X."ALW_CATEGORY", '[^0-9|.]', '') as ALW_CATEGORY_N
                            , regexp_replace(X."ALW_BD_CERT", '[^0-9|.]', '') as ALW_BD_CERT_N
                            , regexp_replace(X."ALW_MULTI_YEAR_AGMT", '[^0-9|.]', '') as ALW_MULTI_YEAR_AGMT_N
                            , regexp_replace(X."ALW_MISSION_SC", '[^0-9|.]', '') as ALW_MISSION_SC_N
                            , regexp_replace(X."ALW_TOTAL", '[^0-9|.]', '') as ALW_TOTAL_N
                            , regexp_replace(X."ALW_TOTAL_PAYABLE", '[^0-9|.]', '') as ALW_TOTAL_PAYABLE_N
                            , TO_DATE(regexp_replace(X."RVW_SO_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_SO_DATE_D
                            , TO_DATE(regexp_replace(X."RVW_DGHO_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_DGHO_DATE_D
                            , TO_DATE(regexp_replace(X."RVW_CP_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_CP_DATE_D
                            , TO_DATE(regexp_replace(X."RVW_OFM_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_OFM_DATE_D
                            , TO_DATE(regexp_replace(X."RVW_TABG_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_TABG_DATE_D
                            , TO_DATE(regexp_replace(X."RVW_OHC_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as RVW_OHC_DATE_D
                            , TO_DATE(regexp_replace(X."APPROVAL_TABG_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_TABG_DATE_D
                            , TO_DATE(regexp_replace(X."APPROVAL_OADMIN_DATE", '[^0-9|/]', ''), 'mm/dd/yyyy') as APPROVAL_OADMIN_DATE_D
                            
                    FROM TBL_FORM_DTL FD,
                         XMLTABLE('/formData/items' PASSING FD.FIELD_DATA COLUMNS
                        PCA_TYPE VARCHAR2(10) PATH './item[id="pcaType"]/value'
                        , CANDI_AGREE VARCHAR2(5) PATH './item[id="candiAgreeRenewal"]/value'
                        -- Chief Physician
                        , CP_NAME VARCHAR2(100) PATH './item[id="chiefPhysician"]/value/name'
                        , CP_EMAIL VARCHAR2(100) PATH './item[id="chiefPhysician"]/value/email'
                        , CP_ID VARCHAR2(10) PATH './item[id="chiefPhysician"]/value/id'
                        -- OFM Director
                        , OFM_NAME VARCHAR2(100) PATH './item[id="ofmDirector"]/value/name'
                        , OFM_EMAIL VARCHAR2(100) PATH './item[id="ofmDirector"]/value/email'
                        , OFM_ID VARCHAR2(10) PATH './item[id="ofmDirector"]/value/id'
                        -- Does the PCA require the Office of the Administrator approval?
                        , ADMIN_APPROVAL_REQ VARCHAR2(5) PATH './item[id="requireAdminApproval"]/value'
                        -- OHC Director
                        , OHC_NAME VARCHAR2(100) PATH './item[id="ohcDirector"]/value/name'
                        , OHC_EMAIL VARCHAR2(100) PATH './item[id="ohcDirector"]/value/email'
                        , OHC_ID VARCHAR2(10) PATH './item[id="ohcDirector"]/value/id'
                        -- Administrator
                        , OADMIN_NAME VARCHAR2(100) PATH './item[id="offAdmin"]/value/name'
                        , OADMIN_EMAIL VARCHAR2(100) PATH './item[id="offAdmin"]/value/email'
                        , OADMIN_ID VARCHAR2(10) PATH './item[id="offAdmin"]/value/id'
                        -- Position
                        , WORK_SCHEDULE VARCHAR2(15) PATH './item[id="workSchedule"]/value'
                        , HOURS_PER_WEEK VARCHAR2(5) PATH './item[id="hoursPerWeek"]/value'
                        , BD_CERT_REQ VARCHAR2(5) PATH './item[id="requireBoardCert"]/value'
                        , LIC_INFO VARCHAR2(140) PATH './item[id="licenseInfo"]/value'
                        -- licenseState
                        , LIC_STATE1_STATE VARCHAR2(2) PATH './item[id="licenseState"]/value[1]/state'
                        , LIC_STATE1_NAME VARCHAR2(50) PATH './item[id="licenseState"]/value[1]/name'
                        , LIC_STATE1_EXP_DATE VARCHAR2(10) PATH './item[id="licenseState"]/value[1]/expDate'
                        , LIC_STATE2_STATE VARCHAR2(2) PATH './item[id="licenseState"]/value[2]/state'
                        , LIC_STATE2_NAME VARCHAR2(50) PATH './item[id="licenseState"]/value[2]/name'
                        , LIC_STATE2_EXP_DATE VARCHAR2(10) PATH './item[id="licenseState"]/value[2]/expDate'
                        -- boardCertSpecialty
                        , BD_CERT_SPEC1 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[1]/text'
                        , BD_CERT_SPEC2 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[2]/text'
                        , BD_CERT_SPEC3 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[3]/text'
                        , BD_CERT_SPEC4 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[4]/text'
                        , BD_CERT_SPEC5 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[5]/text'
                        , BD_CERT_SPEC6 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[6]/text'
                        , BD_CERT_SPEC7 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[7]/text'
                        , BD_CERT_SPEC8 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[8]/text'
                        , BD_CERT_SPEC9 VARCHAR2(30) PATH './item[id="boardCertSpecialty"]/value[9]/text'
                        , BD_CERT_SPEC_OTHER VARCHAR2(140) PATH './item[id="otherSpeciality"]/value'
                        -- allowance
                        , LEN_SERVED VARCHAR2(25) PATH './item[id="lengthOfServed"]/value'
                        , LEN_SERVICE VARCHAR2(2) PATH './item[id="lengthOfService"]/value'
                        , ALW_CATEGORY VARCHAR2(15) PATH './item[id="allowanceCategory"]/value'
                        , ALW_BD_CERT VARCHAR2(15) PATH './item[id="allowanceBoardCertification"]/value'
                        , ALW_MULTI_YEAR_AGMT VARCHAR2(15) PATH './item[id="allowanceMultiYearAgreement"]/value'
                        , ALW_MISSION_SC VARCHAR2(15) PATH './item[id="allowanceMissionSpecificCriteria"]/value'
                        , ALW_TOTAL VARCHAR2(15) PATH './item[id="allowanceTotal"]/value'
                        , ALW_TOTAL_PAYABLE VARCHAR2(15) PATH './item[id="totalPayablePCACalculation"]/value'
                        -- remarks
                        , DETAIL_REMARKS VARCHAR2(500) PATH './item[id="detailRemarks"]/value'
                        -- Review
                        , RVW_SO_NAME VARCHAR2(100) PATH './item[id="reviewSO"]/value'
                        , RVW_SO_ID VARCHAR2(10) PATH './item[id="reviewSOId"]/value'
                        , RVW_SO_DATE VARCHAR2(10) PATH './item[id="reviewSODate"]/value'
                        , RVW_DGHO_NAME VARCHAR2(100) PATH './item[id="reviewDGHO"]/value'
                        , RVW_DGHO_ID VARCHAR2(10) PATH './item[id="reviewDGHOId"]/value'
                        , RVW_DGHO_DATE VARCHAR2(10) PATH './item[id="reviewDGHODate"]/value'
                        , RVW_CP_NAME VARCHAR2(100) PATH './item[id="reviewCP"]/value'
                        , RVW_CP_ID VARCHAR2(10) PATH './item[id="reviewCPId"]/value'
                        , RVW_CP_DATE VARCHAR2(10) PATH './item[id="reviewCPDate"]/value'
                        , RVW_OFM_NAME VARCHAR2(100) PATH './item[id="reviewOFM"]/value'
                        , RVW_OFM_ID VARCHAR2(10) PATH './item[id="reviewOFMId"]/value'
                        , RVW_OFM_DATE VARCHAR2(10) PATH './item[id="reviewOFMDate"]/value'
                        , RVW_TABG_NAME VARCHAR2(100) PATH './item[id="reviewTABG"]/value'
                        , RVW_TABG_ID VARCHAR2(10) PATH './item[id="reviewTABGId"]/value'
                        , RVW_TABG_DATE VARCHAR2(10) PATH './item[id="reviewTABGDate"]/value'
                        , RVW_OHC_NAME VARCHAR2(100) PATH './item[id="reviewOHC"]/value'
                        , RVW_OHC_ID VARCHAR2(10) PATH './item[id="reviewOHCId"]/value'
                        , RVW_OHC_DATE VARCHAR2(10) PATH './item[id="reviewOHCDate"]/value'
                        -- Approvals
                        , APPROVAL_TABG_NAME VARCHAR2(100) PATH './item[id="pcaApproveTABG"]/value'
                        , APPROVAL_TABG_ID VARCHAR2(10) PATH './item[id="pcaApproveTABGId"]/value'
                        , APPROVAL_TABG_DATE VARCHAR2(10) PATH './item[id="pcaApproveTABGDate"]/value'
                        , APPROVAL_OADMIN_NAME VARCHAR2(100) PATH './item[id="pcaApproveADM"]/value'
                        , APPROVAL_OADMIN_ID VARCHAR2(10) PATH './item[id="pcaApproveADMId"]/value'
                        , APPROVAL_OADMIN_DATE VARCHAR2(10) PATH './item[id="pcaApproveADMDate"]/value'
                        ) X
                    WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.PROC_ID = TRG.PROC_ID)
            WHEN MATCHED THEN UPDATE SET
                        TRG.PCA_TYPE = SRC.PCA_TYPE
                        ,TRG.CANDI_AGREE = SRC.CANDI_AGREE
                        ,TRG.CP_NAME = SRC.CP_NAME
                        ,TRG.CP_EMAIL = SRC.CP_EMAIL
                        ,TRG.CP_ID = SRC.CP_ID
                        ,TRG.OFM_NAME = SRC.OFM_NAME
                        ,TRG.OFM_EMAIL = SRC.OFM_EMAIL
                        ,TRG.OFM_ID = SRC.OFM_ID
                        ,TRG.ADMIN_APPROVAL_REQ = SRC.ADMIN_APPROVAL_REQ
                        ,TRG.OHC_NAME = SRC.OHC_NAME
                        ,TRG.OHC_EMAIL = SRC.OHC_EMAIL
                        ,TRG.OHC_ID = SRC.OHC_ID
                        ,TRG.OADMIN_NAME = SRC.OADMIN_NAME
                        ,TRG.OADMIN_EMAIL = SRC.OADMIN_EMAIL
                        ,TRG.OADMIN_ID = SRC.OADMIN_ID
                        ,TRG.WORK_SCHEDULE = SRC.WORK_SCHEDULE
                        ,TRG.HOURS_PER_WEEK = SRC.HOURS_PER_WEEK
                        ,TRG.BD_CERT_REQ = SRC.BD_CERT_REQ
                        ,TRG.LIC_INFO = SRC.LIC_INFO
                        ,TRG.LIC_STATE1_STATE = SRC.LIC_STATE1_STATE
                        ,TRG.LIC_STATE1_NAME = SRC.LIC_STATE1_NAME
                        ,TRG.LIC_STATE1_EXP_DATE = SRC.LIC_STATE1_EXP_DATE
                        ,TRG.LIC_STATE2_STATE = SRC.LIC_STATE2_STATE
                        ,TRG.LIC_STATE2_NAME = SRC.LIC_STATE2_NAME
                        ,TRG.LIC_STATE2_EXP_DATE = SRC.LIC_STATE2_EXP_DATE
                        ,TRG.BD_CERT_SPEC1 = SRC.BD_CERT_SPEC1
                        ,TRG.BD_CERT_SPEC2 = SRC.BD_CERT_SPEC2
                        ,TRG.BD_CERT_SPEC3 = SRC.BD_CERT_SPEC3
                        ,TRG.BD_CERT_SPEC4 = SRC.BD_CERT_SPEC4
                        ,TRG.BD_CERT_SPEC5 = SRC.BD_CERT_SPEC5
                        ,TRG.BD_CERT_SPEC6 = SRC.BD_CERT_SPEC6
                        ,TRG.BD_CERT_SPEC7 = SRC.BD_CERT_SPEC7
                        ,TRG.BD_CERT_SPEC8 = SRC.BD_CERT_SPEC8
                        ,TRG.BD_CERT_SPEC9 = SRC.BD_CERT_SPEC9
                        ,TRG.BD_CERT_SPEC_OTHER = SRC.BD_CERT_SPEC_OTHER
                        ,TRG.LEN_SERVED = SRC.LEN_SERVED
                        ,TRG.LEN_SERVICE = SRC.LEN_SERVICE
                        ,TRG.ALW_CATEGORY = SRC.ALW_CATEGORY
                        ,TRG.ALW_BD_CERT = SRC.ALW_BD_CERT
                        ,TRG.ALW_MULTI_YEAR_AGMT = SRC.ALW_MULTI_YEAR_AGMT
                        ,TRG.ALW_MISSION_SC = SRC.ALW_MISSION_SC
                        ,TRG.ALW_TOTAL = SRC.ALW_TOTAL
                        ,TRG.ALW_TOTAL_PAYABLE = SRC.ALW_TOTAL_PAYABLE
                        ,TRG.DETAIL_REMARKS = SRC.DETAIL_REMARKS
                        ,TRG.RVW_SO_NAME = SRC.RVW_SO_NAME
                        ,TRG.RVW_SO_ID = SRC.RVW_SO_ID
                        ,TRG.RVW_SO_DATE = SRC.RVW_SO_DATE
                        ,TRG.RVW_DGHO_NAME = SRC.RVW_DGHO_NAME
                        ,TRG.RVW_DGHO_ID = SRC.RVW_DGHO_ID
                        ,TRG.RVW_DGHO_DATE = SRC.RVW_DGHO_DATE
                        ,TRG.RVW_CP_NAME = SRC.RVW_CP_NAME
                        ,TRG.RVW_CP_ID = SRC.RVW_CP_ID
                        ,TRG.RVW_CP_DATE = SRC.RVW_CP_DATE
                        ,TRG.RVW_OFM_NAME = SRC.RVW_OFM_NAME
                        ,TRG.RVW_OFM_ID = SRC.RVW_OFM_ID
                        ,TRG.RVW_OFM_DATE = SRC.RVW_OFM_DATE
                        ,TRG.RVW_TABG_NAME = SRC.RVW_TABG_NAME
                        ,TRG.RVW_TABG_ID = SRC.RVW_TABG_ID
                        ,TRG.RVW_TABG_DATE = SRC.RVW_TABG_DATE
                        ,TRG.RVW_OHC_NAME = SRC.RVW_OHC_NAME
                        ,TRG.RVW_OHC_ID = SRC.RVW_OHC_ID
                        ,TRG.RVW_OHC_DATE = SRC.RVW_OHC_DATE
                        ,TRG.APPROVAL_TABG_NAME = SRC.APPROVAL_TABG_NAME
                        ,TRG.APPROVAL_TABG_ID = SRC.APPROVAL_TABG_ID
                        ,TRG.APPROVAL_TABG_DATE = SRC.APPROVAL_TABG_DATE
                        ,TRG.APPROVAL_OADMIN_NAME = SRC.APPROVAL_OADMIN_NAME
                        ,TRG.APPROVAL_OADMIN_ID = SRC.APPROVAL_OADMIN_ID
                        ,TRG.APPROVAL_OADMIN_DATE = SRC.APPROVAL_OADMIN_DATE
                        ------------
                        ,TRG.LIC_STATE1_EXP_DATE_D = SRC.LIC_STATE1_EXP_DATE_D
                        ,TRG.LIC_STATE2_EXP_DATE_D = SRC.LIC_STATE2_EXP_DATE_D
                        ,TRG.ALW_CATEGORY_N = SRC.ALW_CATEGORY_N
                        ,TRG.ALW_BD_CERT_N = SRC.ALW_BD_CERT_N
                        ,TRG.ALW_MULTI_YEAR_AGMT_N = SRC.ALW_MULTI_YEAR_AGMT_N
                        ,TRG.ALW_MISSION_SC_N = SRC.ALW_MISSION_SC_N
                        ,TRG.ALW_TOTAL_N = SRC.ALW_TOTAL_N
                        ,TRG.ALW_TOTAL_PAYABLE_N = SRC.ALW_TOTAL_PAYABLE_N
                        ,TRG.RVW_SO_DATE_D = SRC.RVW_SO_DATE_D
                        ,TRG.RVW_DGHO_DATE_D = SRC.RVW_DGHO_DATE_D
                        ,TRG.RVW_CP_DATE_D = SRC.RVW_CP_DATE_D
                        ,TRG.RVW_OFM_DATE_D = SRC.RVW_OFM_DATE_D
                        ,TRG.RVW_TABG_DATE_D = SRC.RVW_TABG_DATE_D
                        ,TRG.RVW_OHC_DATE_D = SRC.RVW_OHC_DATE_D
                        ,TRG.APPROVAL_TABG_DATE_D = SRC.APPROVAL_TABG_DATE_D
                        ,TRG.APPROVAL_OADMIN_DATE_D = SRC.APPROVAL_OADMIN_DATE_D                  
            WHEN NOT MATCHED THEN INSERT (
                            TRG.PROC_ID
                            ,TRG.PCA_TYPE
                            ,TRG.CANDI_AGREE
                            ,TRG.CP_NAME
                            ,TRG.CP_EMAIL
                            ,TRG.CP_ID
                            ,TRG.OFM_NAME
                            ,TRG.OFM_EMAIL
                            ,TRG.OFM_ID
                            ,TRG.ADMIN_APPROVAL_REQ
                            ,TRG.OHC_NAME
                            ,TRG.OHC_EMAIL
                            ,TRG.OHC_ID
                            ,TRG.OADMIN_NAME
                            ,TRG.OADMIN_EMAIL
                            ,TRG.OADMIN_ID
                            ,TRG.WORK_SCHEDULE
                            ,TRG.HOURS_PER_WEEK
                            ,TRG.BD_CERT_REQ
                            ,TRG.LIC_INFO
                            ,TRG.LIC_STATE1_STATE
                            ,TRG.LIC_STATE1_NAME
                            ,TRG.LIC_STATE1_EXP_DATE
                            ,TRG.LIC_STATE2_STATE
                            ,TRG.LIC_STATE2_NAME
                            ,TRG.LIC_STATE2_EXP_DATE
                            ,TRG.BD_CERT_SPEC1
                            ,TRG.BD_CERT_SPEC2
                            ,TRG.BD_CERT_SPEC3
                            ,TRG.BD_CERT_SPEC4
                            ,TRG.BD_CERT_SPEC5
                            ,TRG.BD_CERT_SPEC6
                            ,TRG.BD_CERT_SPEC7
                            ,TRG.BD_CERT_SPEC8
                            ,TRG.BD_CERT_SPEC9
                            ,TRG.BD_CERT_SPEC_OTHER
                            ,TRG.LEN_SERVED
                            ,TRG.LEN_SERVICE
                            ,TRG.ALW_CATEGORY
                            ,TRG.ALW_BD_CERT
                            ,TRG.ALW_MULTI_YEAR_AGMT
                            ,TRG.ALW_MISSION_SC
                            ,TRG.ALW_TOTAL
                            ,TRG.ALW_TOTAL_PAYABLE
                            ,TRG.DETAIL_REMARKS
                            ,TRG.RVW_SO_NAME
                            ,TRG.RVW_SO_ID
                            ,TRG.RVW_SO_DATE
                            ,TRG.RVW_DGHO_NAME
                            ,TRG.RVW_DGHO_ID
                            ,TRG.RVW_DGHO_DATE
                            ,TRG.RVW_CP_NAME
                            ,TRG.RVW_CP_ID
                            ,TRG.RVW_CP_DATE
                            ,TRG.RVW_OFM_NAME
                            ,TRG.RVW_OFM_ID
                            ,TRG.RVW_OFM_DATE
                            ,TRG.RVW_TABG_NAME
                            ,TRG.RVW_TABG_ID
                            ,TRG.RVW_TABG_DATE
                            ,TRG.RVW_OHC_NAME
                            ,TRG.RVW_OHC_ID
                            ,TRG.RVW_OHC_DATE
                            ,TRG.APPROVAL_TABG_NAME
                            ,TRG.APPROVAL_TABG_ID
                            ,TRG.APPROVAL_TABG_DATE
                            ,TRG.APPROVAL_OADMIN_NAME
                            ,TRG.APPROVAL_OADMIN_ID
                            ,TRG.APPROVAL_OADMIN_DATE
                            ----------
                            ,TRG.LIC_STATE1_EXP_DATE_D
                            ,TRG.LIC_STATE2_EXP_DATE_D
                            ,TRG.ALW_CATEGORY_N
                            ,TRG.ALW_BD_CERT_N
                            ,TRG.ALW_MULTI_YEAR_AGMT_N
                            ,TRG.ALW_MISSION_SC_N
                            ,TRG.ALW_TOTAL_N
                            ,TRG.ALW_TOTAL_PAYABLE_N
                            ,TRG.RVW_SO_DATE_D
                            ,TRG.RVW_DGHO_DATE_D
                            ,TRG.RVW_CP_DATE_D
                            ,TRG.RVW_OFM_DATE_D
                            ,TRG.RVW_TABG_DATE_D
                            ,TRG.RVW_OHC_DATE_D
                            ,TRG.APPROVAL_TABG_DATE_D
                            ,TRG.APPROVAL_OADMIN_DATE_D                             
                        ) VALUES (
                            SRC.PROC_ID
                            ,SRC.PCA_TYPE
                            ,SRC.CANDI_AGREE
                            ,SRC.CP_NAME
                            ,SRC.CP_EMAIL
                            ,SRC.CP_ID
                            ,SRC.OFM_NAME
                            ,SRC.OFM_EMAIL
                            ,SRC.OFM_ID
                            ,SRC.ADMIN_APPROVAL_REQ
                            ,SRC.OHC_NAME
                            ,SRC.OHC_EMAIL
                            ,SRC.OHC_ID
                            ,SRC.OADMIN_NAME
                            ,SRC.OADMIN_EMAIL
                            ,SRC.OADMIN_ID
                            ,SRC.WORK_SCHEDULE
                            ,SRC.HOURS_PER_WEEK
                            ,SRC.BD_CERT_REQ
                            ,SRC.LIC_INFO
                            ,SRC.LIC_STATE1_STATE
                            ,SRC.LIC_STATE1_NAME
                            ,SRC.LIC_STATE1_EXP_DATE
                            ,SRC.LIC_STATE2_STATE
                            ,SRC.LIC_STATE2_NAME
                            ,SRC.LIC_STATE2_EXP_DATE
                            ,SRC.BD_CERT_SPEC1
                            ,SRC.BD_CERT_SPEC2
                            ,SRC.BD_CERT_SPEC3
                            ,SRC.BD_CERT_SPEC4
                            ,SRC.BD_CERT_SPEC5
                            ,SRC.BD_CERT_SPEC6
                            ,SRC.BD_CERT_SPEC7
                            ,SRC.BD_CERT_SPEC8
                            ,SRC.BD_CERT_SPEC9
                            ,SRC.BD_CERT_SPEC_OTHER
                            ,SRC.LEN_SERVED
                            ,SRC.LEN_SERVICE
                            ,SRC.ALW_CATEGORY
                            ,SRC.ALW_BD_CERT
                            ,SRC.ALW_MULTI_YEAR_AGMT
                            ,SRC.ALW_MISSION_SC
                            ,SRC.ALW_TOTAL
                            ,SRC.ALW_TOTAL_PAYABLE
                            ,SRC.DETAIL_REMARKS
                            ,SRC.RVW_SO_NAME
                            ,SRC.RVW_SO_ID
                            ,SRC.RVW_SO_DATE
                            ,SRC.RVW_DGHO_NAME
                            ,SRC.RVW_DGHO_ID
                            ,SRC.RVW_DGHO_DATE
                            ,SRC.RVW_CP_NAME
                            ,SRC.RVW_CP_ID
                            ,SRC.RVW_CP_DATE
                            ,SRC.RVW_OFM_NAME
                            ,SRC.RVW_OFM_ID
                            ,SRC.RVW_OFM_DATE
                            ,SRC.RVW_TABG_NAME
                            ,SRC.RVW_TABG_ID
                            ,SRC.RVW_TABG_DATE
                            ,SRC.RVW_OHC_NAME
                            ,SRC.RVW_OHC_ID
                            ,SRC.RVW_OHC_DATE
                            ,SRC.APPROVAL_TABG_NAME
                            ,SRC.APPROVAL_TABG_ID
                            ,SRC.APPROVAL_TABG_DATE
                            ,SRC.APPROVAL_OADMIN_NAME
                            ,SRC.APPROVAL_OADMIN_ID
                            ,SRC.APPROVAL_OADMIN_DATE
                            ----------
                            ,SRC.LIC_STATE1_EXP_DATE_D
                            ,SRC.LIC_STATE2_EXP_DATE_D
                            ,SRC.ALW_CATEGORY_N
                            ,SRC.ALW_BD_CERT_N
                            ,SRC.ALW_MULTI_YEAR_AGMT_N
                            ,SRC.ALW_MISSION_SC_N
                            ,SRC.ALW_TOTAL_N
                            ,SRC.ALW_TOTAL_PAYABLE_N
                            ,SRC.RVW_SO_DATE_D
                            ,SRC.RVW_DGHO_DATE_D
                            ,SRC.RVW_CP_DATE_D
                            ,SRC.RVW_OFM_DATE_D
                            ,SRC.RVW_TABG_DATE_D
                            ,SRC.RVW_OHC_DATE_D
                            ,SRC.APPROVAL_TABG_DATE_D
                            ,SRC.APPROVAL_OADMIN_DATE_D                       
                        );
        END IF;

    END IF;
        
    EXCEPTION
    WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION=' || SUBSTR(SQLERRM, 1, 200));
          --err_code := SQLCODE;
          --err_msg := SUBSTR(SQLERRM, 1, 200);    
    SP_ERROR_LOG();
  END;
