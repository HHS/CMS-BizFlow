CREATE OR REPLACE VIEW VW_CLASSIFICATION
AS
SELECT
	R.REQ_ID
	, R.REQ_JOB_REQ_NUMBER
	, R.REQ_JOB_REQ_CREATE_DT
	, R.REQ_STATUS_ID
	, R.REQ_CANCEL_DT
	, R.REQ_CANCEL_REASON

	, CS.CS_TITLE
	, CS.CS_PAY_PLAN_ID
	--, LU_PYPL.TBL_NAME AS CS_PAY_PLAN_DSCR
	, (SELECT LU_PYPL.TBL_NAME FROM TBL_LOOKUP LU_PYPL WHERE LU_PYPL.TBL_ID = CS.CS_PAY_PLAN_ID AND ROWNUM = 1) AS CS_PAY_PLAN_DSCR
	, CS.CS_SR_ID
	--, LU_SR.TBL_LABEL AS CS_SR_DSCR
	, (SELECT LU_SR.TBL_LABEL FROM TBL_LOOKUP LU_SR WHERE LU_SR.TBL_ID = CS.CS_SR_ID AND ROWNUM = 1) AS CS_SR_DSCR
	, CS.CS_PD_NUMBER_JOBCD_1
	, CS.CS_CLASSIFICATION_DT_1
	, CS.CS_GR_ID_1
	, CS.CS_FLSA_DETERM_ID_1
	--, LU_FLSA_1.TBL_LABEL AS CS_FLSA_DETERM_DSCR_1
	, (SELECT LU_FLSA.TBL_LABEL FROM TBL_LOOKUP LU_FLSA WHERE LU_FLSA.TBL_ID = CS.CS_FLSA_DETERM_ID_1 AND ROWNUM = 1) AS CS_FLSA_DETERM_DSCR_1
	, CS.CS_PD_NUMBER_JOBCD_2
	, CS.CS_CLASSIFICATION_DT_2
	, CS.CS_GR_ID_2
	, CS.CS_FLSA_DETERM_ID_2
	--, LU_FLSA_2.TBL_LABEL AS CS_FLSA_DETERM_DSCR_2
	, (SELECT LU_FLSA.TBL_LABEL FROM TBL_LOOKUP LU_FLSA WHERE LU_FLSA.TBL_ID = CS.CS_FLSA_DETERM_ID_2 AND ROWNUM = 1) AS CS_FLSA_DETERM_DSCR_2
	, CS.CS_PD_NUMBER_JOBCD_3
	, CS.CS_CLASSIFICATION_DT_3
	, CS.CS_GR_ID_3
	, CS.CS_FLSA_DETERM_ID_3
	--, LU_FLSA_3.TBL_LABEL AS CS_FLSA_DETERM_DSCR_3
	, (SELECT LU_FLSA.TBL_LABEL FROM TBL_LOOKUP LU_FLSA WHERE LU_FLSA.TBL_ID = CS.CS_FLSA_DETERM_ID_3 AND ROWNUM = 1) AS CS_FLSA_DETERM_DSCR_3
	, CS.CS_PD_NUMBER_JOBCD_4
	, CS.CS_CLASSIFICATION_DT_4
	, CS.CS_GR_ID_4
	, CS.CS_FLSA_DETERM_ID_4
	--, LU_FLSA_4.TBL_LABEL AS CS_FLSA_DETERM_DSCR_4
	, (SELECT LU_FLSA.TBL_LABEL FROM TBL_LOOKUP LU_FLSA WHERE LU_FLSA.TBL_ID = CS.CS_FLSA_DETERM_ID_4 AND ROWNUM = 1) AS CS_FLSA_DETERM_DSCR_4
	, CS.CS_PD_NUMBER_JOBCD_5
	, CS.CS_CLASSIFICATION_DT_5
	, CS.CS_GR_ID_5
	, CS.CS_FLSA_DETERM_ID_5
	--, LU_FLSA_5.TBL_LABEL AS CS_FLSA_DETERM_DSCR_5
	, (SELECT LU_FLSA.TBL_LABEL FROM TBL_LOOKUP LU_FLSA WHERE LU_FLSA.TBL_ID = CS.CS_FLSA_DETERM_ID_5 AND ROWNUM = 1) AS CS_FLSA_DETERM_DSCR_5
	, CS.CS_PERFORMANCE_LEVEL
	, CS.CS_SUPERVISORY
	--, LU_SUP.TBL_LABEL AS CS_SUPERVISORY_DSCR
	, (SELECT LU_SUP.TBL_LABEL FROM TBL_LOOKUP LU_SUP WHERE LU_SUP.TBL_ID = CS.CS_SUPERVISORY AND ROWNUM = 1) AS CS_SUPERVISORY_DSCR
	, CS.CS_AC_ID
	--, LU_AC.AC_ADMIN_CD AS CS_AC_CD
	--, LU_AC.AC_ADMIN_CD_DESCR AS CS_AC_DSCR
	, CS.CS_ADMIN_CD AS CS_ADMIN_CD
	--, LU_AC.AC_ADMIN_CD_DESCR AS CS_ADMIN_CD_DSCR
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = CS_ADMIN_CD AND ROWNUM = 1) AS CS_ADMIN_CD_DSCR
	, CS.SO_ID
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = CS.SO_ID AND ROWNUM = 1)  AS SO_NAME
	, CS.SO_TITLE
	, CS.SO_ORG
	, CS.XO_ID
	, FN_GET_NAMES(CS.XO_ID)  AS XO_NAME
	, CS.XO_TITLE
	, CS.XO_ORG
	, CS.HRL_ID
	, FN_GET_NAMES(CS.HRL_ID)  AS HL_NAME
	, CS.HRL_TITLE
	, CS.HRL_ORG
	, CS.SS_ID
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = CS.SS_ID AND ROWNUM = 1)  AS SS_NAME
	, CS.CS_ID
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = CS.CS_ID AND ROWNUM = 1)  AS CS_NAME
	, CS.CS_FIN_STMT_REQ_ID
	--, LU_FNTP.TBL_LABEL AS CS_FIN_STMT_REQ_DSCR
	, (SELECT LU_FNTP.TBL_LABEL FROM TBL_LOOKUP LU_FNTP WHERE LU_FNTP.TBL_ID = CS.CS_FIN_STMT_REQ_ID AND ROWNUM = 1) AS CS_FIN_STMT_REQ_DSCR
	, CS.CS_SEC_ID
	--, LU_SEC.TBL_LABEL AS CS_SEC_DSCR
	, (SELECT LU_SEC.TBL_LABEL FROM TBL_LOOKUP LU_SEC WHERE LU_SEC.TBL_ID = CS.CS_SEC_ID AND ROWNUM = 1) AS CS_SEC_DSCR
	, PD.PD_ID
	, PD.PD_PROCID
	, PD.PD_ORG_POS_TITLE
	, PD.PD_EMPLOYING_OFFICE
	--, LU_EO.TBL_LABEL AS PD_EMPLOYING_OFFICE_DSCR
	, (SELECT LU_EO.TBL_LABEL FROM TBL_LOOKUP LU_EO WHERE LU_EO.TBL_ID = PD.PD_EMPLOYING_OFFICE AND ROWNUM = 1) AS PD_EMPLOYING_OFFICE_DSCR
	, CASE WHEN PD.PD_SUBJECT_IA = '1' THEN 'Yes' ELSE 'No' END AS PD_SUBJECT_IA
	, PD.PD_ORGANIZATION
	, PD.PD_SUB_ORG_1
	--, LU_SO_1.AC_ADMIN_CD_DESCR AS PD_SUB_ORG_DSCR_1
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = PD_SUB_ORG_1 AND ROWNUM = 1) AS PD_SUB_ORG_DSCR_1
	, PD.PD_SUB_ORG_2
	--, LU_SO_2.AC_ADMIN_CD_DESCR AS PD_SUB_ORG_DSCR_2
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = PD_SUB_ORG_2 AND ROWNUM = 1) AS PD_SUB_ORG_DSCR_2
	, PD.PD_SUB_ORG_3
	--, LU_SO_3.AC_ADMIN_CD_DESCR AS PD_SUB_ORG_DSCR_3
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = PD_SUB_ORG_3 AND ROWNUM = 1) AS PD_SUB_ORG_DSCR_3
	, PD.PD_SUB_ORG_4
	--, LU_SO_4.AC_ADMIN_CD_DESCR AS PD_SUB_ORG_DSCR_4
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = PD_SUB_ORG_4 AND ROWNUM = 1) AS PD_SUB_ORG_DSCR_4
	, PD.PD_SUB_ORG_5
	--, LU_SO_5.AC_ADMIN_CD_DESCR AS PD_SUB_ORG_DSCR_5
	, (SELECT AC.AC_ADMIN_CD_DESCR FROM ADMIN_CODES AC WHERE AC.AC_ADMIN_CD = PD_SUB_ORG_5 AND ROWNUM = 1) AS PD_SUB_ORG_DSCR_5
	, PD.PD_SCOPE
    , PD.STD_PD_TYPE
	, CASE WHEN PD.PD_PCA = '1'        THEN 'Yes' ELSE 'No' END AS PD_PCA
	, CASE WHEN PD.PD_PDP = '1'        THEN 'Yes' ELSE 'No' END AS PD_PDP
	, CASE WHEN PD.PD_FTT = '1'        THEN 'Yes' ELSE 'No' END AS PD_FTT
	, CASE WHEN PD.PD_OUTSTATION = '1' THEN 'Yes' ELSE 'No' END AS PD_OUTSTATION
	, CASE WHEN PD.PD_INCUMBENCY = '1' THEN 'Yes' ELSE 'No' END AS PD_INCUMBENCY
	, PD.PD_REMARKS
	, PD.PD_CLS_STANDARDS
	, FN_GET_LOOKUP_DSCR(PD.PD_CLS_STANDARDS) AS PD_CLS_STANDARDS_DSCR
	, PD.PD_ACQ_CODE
	--, LU_ACQ.TBL_NAME AS PD_ACQ_CODE_DSCR
	, (SELECT LU_ACQ.TBL_NAME FROM TBL_LOOKUP LU_ACQ WHERE LU_ACQ.TBL_ID = PD.PD_ACQ_CODE AND ROWNUM = 1) AS PD_ACQ_CODE_DSCR
	, PD.PD_CYB_SEC_CD
	--, LU_CSEC.TBL_LABEL AS PD_CYB_SEC_CD_DSCR
	--, (SELECT LU_CSEC.TBL_LABEL FROM TBL_LOOKUP LU_CSEC WHERE LU_CSEC.TBL_ID = PD.PD_CYB_SEC_CD AND ROWNUM = 1) AS PD_CYB_SEC_CD_DSCR
	, FN_GET_LOOKUP_DSCR(PD.PD_CYB_SEC_CD) AS PD_CYB_SEC_CD_DSCR
	, PD.PD_COMPET_LVL_CD
	, PD.PD_BUS_CD
	--, LU_BUS.TBL_LABEL AS PD_BUS_CD_DSCR
	, (SELECT LU_BUS.TBL_LABEL FROM TBL_LOOKUP LU_BUS WHERE LU_BUS.TBL_ID = PD.PD_BUS_CD AND ROWNUM = 1) AS PD_BUS_CD_DSCR
	, PD.BYPASS_DWC_FL

	, CASE WHEN PD.PD_SUPV_CERT = '1' THEN 'Yes' ELSE 'No' END AS PD_SUPV_CERT
	, PD.PD_SUPV_NAME
	, PD.PD_SUPV_TITLE
	, PD.PD_SUPV_SIG
	, PD.PD_SUPV_SIG_DT
	, CASE WHEN PD.PD_CLS_SPEC_CERT = '1' THEN 'Yes' ELSE 'No' END AS PD_CLS_SPEC_CERT
	, PD.PD_CLS_SPEC_NAME
	, PD.PD_CLS_SPEC_TITLE
	, PD.PD_CLS_SPEC_SIG
	, PD.PD_CLS_SPEC_DT

	, CASE WHEN FLSA.FLSA_EX_EXEC = '1'            THEN 'Yes' ELSE 'No' END AS FLSA_EX_EXEC
	, CASE WHEN FLSA.FLSA_EX_ADMIN = '1'           THEN 'Yes' ELSE 'No' END AS FLSA_EX_ADMIN
	, CASE WHEN FLSA.FLSA_EX_PROF_LEARNED = '1'    THEN 'Yes' ELSE 'No' END AS FLSA_EX_PROF_LEARNED
	, CASE WHEN FLSA.FLSA_EX_PROF_CREATIVE = '1'   THEN 'Yes' ELSE 'No' END AS FLSA_EX_PROF_CREATIVE
	, CASE WHEN FLSA.FLSA_EX_PROF_COMPUTER = '1'   THEN 'Yes' ELSE 'No' END AS FLSA_EX_PROF_COMPUTER
	, CASE WHEN FLSA.FLSA_EX_LAW_ENFORC = '1'      THEN 'Yes' ELSE 'No' END AS FLSA_EX_LAW_ENFORC
	, CASE WHEN FLSA.FLSA_EX_FOREIGN = '1'         THEN 'Yes' ELSE 'No' END AS FLSA_EX_FOREIGN
	, FLSA.FLSA_EX_REMARKS
	, CASE WHEN FLSA.FLSA_NONEX_SALARY = '1'       THEN 'Yes' ELSE 'No' END AS FLSA_NONEX_SALARY
	, CASE WHEN FLSA.FLSA_NONEX_EQUIP_OPER = '1'   THEN 'Yes' ELSE 'No' END AS FLSA_NONEX_EQUIP_OPER
	, CASE WHEN FLSA.FLSA_NONEX_TECHN = '1'        THEN 'Yes' ELSE 'No' END AS FLSA_NONEX_TECHN
	, CASE WHEN FLSA.FLSA_NONEX_FED_WAGE_SYS = '1' THEN 'Yes' ELSE 'No' END AS FLSA_NONEX_FED_WAGE_SYS
	, FLSA.FLSA_NONEX_REMARKS

FROM
	REQUEST R
	LEFT OUTER JOIN CLASSIF_STRATCON CS ON CS.CS_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN PD_COVERSHEET PD ON PD.PD_REQ_ID = R.REQ_ID
	LEFT OUTER JOIN FLSA FLSA ON FLSA.FLSA_PD_ID = PD.PD_ID

	--LEFT OUTER JOIN TBL_LOOKUP LU_PYPL ON LU_PYPL.TBL_ID = CS.CS_PAY_PLAN_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_SR ON LU_SR.TBL_ID = CS.CS_SR_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_FLSA_1 ON LU_FLSA_1.TBL_ID = CS.CS_FLSA_DETERM_ID_1
	--LEFT OUTER JOIN TBL_LOOKUP LU_FLSA_2 ON LU_FLSA_2.TBL_ID = CS.CS_FLSA_DETERM_ID_2
	--LEFT OUTER JOIN TBL_LOOKUP LU_FLSA_3 ON LU_FLSA_3.TBL_ID = CS.CS_FLSA_DETERM_ID_3
	--LEFT OUTER JOIN TBL_LOOKUP LU_FLSA_4 ON LU_FLSA_4.TBL_ID = CS.CS_FLSA_DETERM_ID_4
	--LEFT OUTER JOIN TBL_LOOKUP LU_FLSA_5 ON LU_FLSA_5.TBL_ID = CS.CS_FLSA_DETERM_ID_5
	--LEFT OUTER JOIN TBL_LOOKUP LU_SUP ON LU_SUP.TBL_ID = CS.CS_SUPERVISORY
	--LEFT OUTER JOIN ADMIN_CODES LU_AC ON LU_AC.AC_ID = CS.CS_AC_ID
	--LEFT OUTER JOIN ADMIN_CODES LU_AC ON LU_AC.AC_ADMIN_CD = CS.CS_ADMIN_CD
	--LEFT OUTER JOIN TBL_LOOKUP LU_FNTP ON LU_FNTP.TBL_ID = CS.CS_FIN_STMT_REQ_ID
	--LEFT OUTER JOIN TBL_LOOKUP LU_SEC ON LU_SEC.TBL_ID = CS.CS_SEC_ID

	--LEFT OUTER JOIN TBL_LOOKUP LU_EO ON LU_EO.TBL_ID = PD.PD_EMPLOYING_OFFICE
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_1 ON LU_SO_1.AC_ADMIN_CD = PD.PD_SUB_ORG_1
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_2 ON LU_SO_2.AC_ADMIN_CD = PD.PD_SUB_ORG_2
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_3 ON LU_SO_3.AC_ADMIN_CD = PD.PD_SUB_ORG_3
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_4 ON LU_SO_4.AC_ADMIN_CD = PD.PD_SUB_ORG_4
	--LEFT OUTER JOIN ADMIN_CODES LU_SO_5 ON LU_SO_5.AC_ADMIN_CD = PD.PD_SUB_ORG_5
	--LEFT OUTER JOIN TBL_LOOKUP LU_ACQ ON LU_ACQ.TBL_ID = PD.PD_ACQ_CODE
	--LEFT OUTER JOIN TBL_LOOKUP LU_CSEC ON LU_CSEC.TBL_ID = PD.PD_CYB_SEC_CD
	--LEFT OUTER JOIN TBL_LOOKUP LU_BUS ON LU_BUS.TBL_ID = PD.PD_BUS_CD
;
 
