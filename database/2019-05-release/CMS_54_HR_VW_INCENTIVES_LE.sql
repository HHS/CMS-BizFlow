--------------------------------------------------------
--  DDL for View VW_INCENTIVES_LE
--------------------------------------------------------
  CREATE OR REPLACE FORCE VIEW HHS_CMS_HR.VW_INCENTIVES_LE(
                PROC_ID
                ,INIT_ANN_LA_RATE
                ,SUPPORT_LE
                ,PROPS_ANN_LA_RATE
                ,JUSTIFICATION_SKILL_EXP
                ,JUSTIFICATION_AGENCY_GOAL
                ,SELECTEE_ELIGIBILITY
                ,HRS_RVW_CERT
                ,HRS_NOT_SPT_RSN
                ,RVW_HRS
                ,HRS_RVW_DATE
                ,RCMD_LA_RATE
                ,APPROVAL_SO_VALUE
                ,APPROVAL_SO
                ,APPROVAL_SO_RESP_DATE
                ,APPROVAL_DGHO_VALUE
                ,APPROVAL_DGHO
                ,APPROVAL_DGHO_RESP_DATE
                ,APPROVAL_TABG_VALUE
                ,APPROVAL_TABG
                ,APPROVAL_TABG_RESP_DATE
                ,COC_NAME
                ,COC_EMAIL
                ,COC_ID
                ,COC_TITLE
                ,APPROVAL_COC_VALUE
                ,APPROVAL_COC_ACTING
                ,APPROVAL_COC
                ,APPROVAL_COC_RESP_DATE
                ,APPROVAL_SO_ACTING
                ,APPROVAL_DGHO_ACTING
                ,APPROVAL_TABG_ACTING
                ,JUSTIFICATION_VER
                ,JUSTIFICATION_CRT_NAME
                ,JUSTIFICATION_CRT_ID
                ,JUSTIFICATION_CRT_DATE
                ,JUSTIFICATION_LASTMOD_NAME
                ,JUSTIFICATION_LASTMOD_ID
                ,JUSTIFICATION_LASTMOD_DATE
                ,JUSTIFICATION_MOD_REASON
                ,JUSTIFICATION_MOD_SUMMARY
                ,JUSTIFICATION_MODIFIER_NAME
                ,JUSTIFICATION_MODIFIER_ID
                ,JUSTIFICATION_MODIFIED_DATE
                ,TOTAL_CREDITABLE_YEARS
                ,TOTAL_CREDITABLE_MONTHS
                ,APPROVER_NOTES
                ,HRS_RVW_DATE_D
                ,APPROVAL_SO_RESP_DATE_D
                ,APPROVAL_DGHO_RESP_DATE_D
)
AS
--------------------------------------------------------------------------------------------------------------------------------
SELECT 

                PROC_ID
                ,INIT_ANN_LA_RATE
                ,SUPPORT_LE
                ,PROPS_ANN_LA_RATE
                ,JUSTIFICATION_SKILL_EXP
                ,JUSTIFICATION_AGENCY_GOAL
                ,SELECTEE_ELIGIBILITY
                ,HRS_RVW_CERT
                ,HRS_NOT_SPT_RSN
                ,RVW_HRS
                ,TO_CHAR(HRS_RVW_DATE_D, 'mm/dd/yyyy') as HRS_RVW_DATE
                ,RCMD_LA_RATE
                ,APPROVAL_SO_VALUE
                ,APPROVAL_SO
                ,TO_CHAR(APPROVAL_SO_RESP_DATE_D, 'mm/dd/yyyy') as APPROVAL_SO_RESP_DATE
                ,APPROVAL_DGHO_VALUE
                ,APPROVAL_DGHO
                ,TO_CHAR(APPROVAL_DGHO_RESP_DATE_D, 'mm/dd/yyyy') as APPROVAL_DGHO_RESP_DATE
                ,APPROVAL_TABG_VALUE
                ,APPROVAL_TABG
                ,TO_CHAR(APPROVAL_TABG_RESP_DATE_D, 'mm/dd/yyyy') as APPROVAL_TABG_RESP_DATE
                ,COC_NAME
                ,COC_EMAIL
                ,COC_ID
                ,COC_TITLE
                ,APPROVAL_COC_VALUE
                ,APPROVAL_COC_ACTING
                ,APPROVAL_COC
                ,TO_CHAR(APPROVAL_COC_RESP_DATE_D, 'mm/dd/yyyy') as APPROVAL_COC_RESP_DATE
                ,APPROVAL_SO_ACTING
                ,APPROVAL_DGHO_ACTING
                ,APPROVAL_TABG_ACTING
                ,JUSTIFICATION_VER
                ,JUSTIFICATION_CRT_NAME
                ,JUSTIFICATION_CRT_ID
                ,TO_CHAR(JUSTIFICATION_CRT_DATE_D, 'mm/dd/yyyy hh24:mi:ss') as JUSTIFICATION_CRT_DATE
                ,JUSTIFICATION_LASTMOD_NAME
                ,JUSTIFICATION_LASTMOD_ID
                ,TO_CHAR(JUSTIFICATION_LASTMOD_DATE_D, 'mm/dd/yyyy hh24:mi:ss') as JUSTIFICATION_LASTMOD_DATE
                ,JUSTIFICATION_MOD_REASON
                ,JUSTIFICATION_MOD_SUMMARY
                ,JUSTIFICATION_MODIFIER_NAME
                ,JUSTIFICATION_MODIFIER_ID
                ,TO_CHAR(JUSTIFICATION_MODIFIED_DATE_D, 'mm/dd/yyyy hh24:mi:ss') as JUSTIFICATION_MODIFIED_DATE
                ,TOTAL_CREDITABLE_YEARS
                ,TOTAL_CREDITABLE_MONTHS
                ,APPROVER_NOTES
                ,HRS_RVW_DATE_D
                ,APPROVAL_SO_RESP_DATE_D
                ,APPROVAL_DGHO_RESP_DATE_D
FROM HHS_CMS_HR.INCENTIVES_LE                
;
