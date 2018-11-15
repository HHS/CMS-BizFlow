-- CMS_HR_DB_UPD_12_core_initclsf.sql 

--------------------------------------------------------
--  DDL for Function FN_INIT_CLASSIFICATION
--------------------------------------------------------

/**
 * Retrieves the initial form data xml for Classification process
 * from the form data xml for the associated parent Strategic Consultation process instance.
 *
 * @param I_PROCID - Process ID of the Classification process.
 *
 * @return XMLTYPE - Form data xml as the initial Classification data.
 */
CREATE OR REPLACE FUNCTION FN_INIT_CLASSIFICATION
(
	I_PROCID                    IN NUMBER
)
RETURN XMLTYPE
IS
	V_PARENTPROCID              NUMBER(10);
	V_FIELD_DATA_SRC            XMLTYPE;
	V_FIELD_DATA_TRG            XMLTYPE;
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_INIT_CLASSIFICATION -------');

	-- get parent procid for Strategic Consultation process to pull data
	SELECT PARENTPROCID INTO V_PARENTPROCID
	FROM BIZFLOW.PROCS
	WHERE PROCID = I_PROCID;

	-- get form data xml
	--SELECT FIELD_DATA INTO V_FIELD_DATA_SRC
	--FROM TBL_FORM_DTL
	--WHERE PROCID = V_PARENTPROCID;


	-- construct initial Classification form data xml from the originating Strategic Consultation data
	--IF V_FIELD_DATA_SRC IS NOT NULL THEN
	--	--DBMS_OUTPUT.PUT_LINE('    V_FIELD_DATA_SRC = ' || V_FIELD_DATA_SRC.GETCLOBVAL());

		SELECT
			XMLQUERY(
				'
					<DOCUMENT>
						<MAIN>
							<SG_CT_ID>{data($sc/DOCUMENT/GENERAL/SG_CT_ID)}</SG_CT_ID>
						</MAIN>
						<GENERAL>
							<CS_TITLE>{data($sc/DOCUMENT/POSITION/POS_TITLE)}</CS_TITLE>
							<CS_PAY_PLAN_ID>{data($sc/DOCUMENT/POSITION/POS_PAY_PLAN_ID)}</CS_PAY_PLAN_ID>
							<CS_SR_ID>{data($sc/DOCUMENT/POSITION/POS_SERIES)}</CS_SR_ID>
							<CS_PD_NUMBER_JOBCD_1>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_1)}</CS_PD_NUMBER_JOBCD_1>
							<CS_CLASSIFICATION_DT_1>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_1)}</CS_CLASSIFICATION_DT_1>
							<CS_GR_ID_1>{data($sc/DOCUMENT/POSITION/POS_GRADE_1)}</CS_GR_ID_1>
							<CS_PD_NUMBER_JOBCD_2>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_2)}</CS_PD_NUMBER_JOBCD_2>
							<CS_CLASSIFICATION_DT_2>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_2)}</CS_CLASSIFICATION_DT_2>
							<CS_GR_ID_2>{data($sc/DOCUMENT/POSITION/POS_GRADE_2)}</CS_GR_ID_2>
							<CS_PD_NUMBER_JOBCD_3>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_3)}</CS_PD_NUMBER_JOBCD_3>
							<CS_CLASSIFICATION_DT_3>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_3)}</CS_CLASSIFICATION_DT_3>
							<CS_GR_ID_3>{data($sc/DOCUMENT/POSITION/POS_GRADE_3)}</CS_GR_ID_3>
							<CS_PD_NUMBER_JOBCD_4>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_4)}</CS_PD_NUMBER_JOBCD_4>
							<CS_CLASSIFICATION_DT_4>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_4)}</CS_CLASSIFICATION_DT_4>
							<CS_GR_ID_4>{data($sc/DOCUMENT/POSITION/POS_GRADE_4)}</CS_GR_ID_4>
							<CS_PD_NUMBER_JOBCD_5>{data($sc/DOCUMENT/POSITION/POS_DESC_NUMBER_5)}</CS_PD_NUMBER_JOBCD_5>
							<CS_CLASSIFICATION_DT_5>{data($sc/DOCUMENT/POSITION/POS_CLASSIFICATION_DT_5)}</CS_CLASSIFICATION_DT_5>
							<CS_GR_ID_5>{data($sc/DOCUMENT/POSITION/POS_GRADE_5)}</CS_GR_ID_5>
							<CS_PERFORMANCE_LEVEL>{data($sc/DOCUMENT/POSITION/POS_PERFORMANCE_LEVEL)}</CS_PERFORMANCE_LEVEL>
							<CS_SUPERVISORY>{data($sc/DOCUMENT/POSITION/POS_SUPERVISORY)}</CS_SUPERVISORY>
							<CS_AC_ID>{data($sc/DOCUMENT/GENERAL/SG_AC_ID)}</CS_AC_ID>
							<CS_ADMIN_CD>{data($sc/DOCUMENT/GENERAL/SG_ADMIN_CD)}</CS_ADMIN_CD>
							<SO_ID>{data($sc/DOCUMENT/GENERAL/SG_SO_ID)}</SO_ID>
							<SO_TITLE>{data($sc/DOCUMENT/GENERAL/SG_SO_TITLE)}</SO_TITLE>
							<SO_ORG>{data($sc/DOCUMENT/GENERAL/SG_SO_ORG)}</SO_ORG>
							<XO_ID>{data($sc/DOCUMENT/GENERAL/SG_XO_ID)}</XO_ID>
							<XO_TITLE>{data($sc/DOCUMENT/GENERAL/SG_XO_TITLE)}</XO_TITLE>
							<XO_ORG>{data($sc/DOCUMENT/GENERAL/SG_XO_ORG)}</XO_ORG>
							<HRL_ID>{data($sc/DOCUMENT/GENERAL/SG_HRL_ID)}</HRL_ID>
							<HRL_TITLE>{data($sc/DOCUMENT/GENERAL/SG_HRL_TITLE)}</HRL_TITLE>
							<HRL_ORG>{data($sc/DOCUMENT/GENERAL/SG_HRL_ORG)}</HRL_ORG>
							<SS_ID>{data($sc/DOCUMENT/GENERAL/SG_SS_ID)}</SS_ID>
							<CS_ID>{data($sc/DOCUMENT/GENERAL/SG_CS_ID)}</CS_ID>
							<POS_INFORMATION>
								<PD_PCA>{if (contains($molabel, "(PCA)")) then "true" else "false"}</PD_PCA>
								<PD_PDP>{if (contains($molabel, "(PDP)")) then "true" else "false"}</PD_PDP>
							</POS_INFORMATION>
						</GENERAL>
						<CLASSIFICATION_CODE>
							<CS_FIN_STMT_REQ_ID>{data($sc/DOCUMENT/POSITION/POS_CE_FINANCIAL_TYPE_ID)}</CS_FIN_STMT_REQ_ID>
							<CS_SEC_ID>{data($sc/DOCUMENT/POSITION/POS_SEC_ID)}</CS_SEC_ID>
						</CLASSIFICATION_CODE>
					</DOCUMENT>
				'
				-- WARNING: Oracle 12c causes problem ($molabel variable empty)
				-- with passing XMLTYPE variable (V_FIELD_DATA_SRC) for some reason.
				-- So, use table join and pass the XMLTYPE column (FD.FIELD_DATA), instead.
				--PASSING V_FIELD_DATA_SRC AS "sc", LUMO.TBL_LABEL AS "molabel"
				PASSING FD.FIELD_DATA AS "sc", LUMO.TBL_LABEL AS "molabel"
				RETURNING CONTENT
			) INTO V_FIELD_DATA_TRG
		FROM
			TBL_FORM_DTL FD
			, XMLTABLE('/DOCUMENT/POSITION' PASSING FD.FIELD_DATA
				COLUMNS
					POS_JOB_REQ_NUMBER     NVARCHAR2(10)  PATH 'POS_JOB_REQ_NUMBER'
					, POS_MED_OFFICERS_ID  NUMBER(20)     PATH 'POS_MED_OFFICERS_ID'
			) MO
			LEFT OUTER JOIN TBL_LOOKUP LUMO ON LUMO.TBL_ID = MO.POS_MED_OFFICERS_ID
		WHERE
			1=1
			AND FD.PROCID = V_PARENTPROCID
			AND XMLEXISTS('data($sc/DOCUMENT/POSITION)' PASSING FD.FIELD_DATA AS "sc")
		;
	--END IF;

	--DBMS_OUTPUT.PUT_LINE('    V_FIELD_DATA_TRG = ' || V_FIELD_DATA_TRG.GETCLOBVAL());
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_INIT_CLASSIFICATION -------');
	RETURN V_FIELD_DATA_TRG;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing classification initialization -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
		RETURN NULL;
END;

/
