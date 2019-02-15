SET DEFINE OFF ;




--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_CLSF_TABLE
--------------------------------------------------------

/**
 * Parses Classification form XML data and stores it
 * into the operational tables for Classification.
 *
 * @param I_PROCID - Process ID
 */

CREATE OR REPLACE PROCEDURE SP_UPDATE_CLSF_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
	V_JOB_REQ_ID                NUMBER(20);
	V_JOB_REQ_NUM               NVARCHAR2(50);
	V_PD_ID                     NUMBER(20);
	V_CLOBVALUE                 CLOB;
	V_VALUE                     NVARCHAR2(4000);
	V_VALUE_LOOKUP              NVARCHAR2(2000);
	V_REC_CNT                   NUMBER(10);
	V_XMLDOC                    XMLTYPE;
	V_XMLVALUE                  XMLTYPE;
	--V_ISMODIFIED                NUMBER(1);
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
	E_INVALID_PROCID            EXCEPTION;
	E_INVALID_JOB_REQ_ID        EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
	E_INVALID_STRATCON_DATA     EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_STRATCON_DATA, -20905);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_CLSF_TABLE - BEGIN ============================');
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE(' ----------------');



	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		------------------------------------------------------
		-- Transfer XML data into operational table
		--
		-- 1. Get Job Request Number
		-- 1.1 Select it from data xml from TBL_FORM_DTL table.
		-- 1.2 If not found, select it from BIZFLOW.RLVNTDATA table.
		-- 2. If Job Request Number not found, issue error.
		-- 3. For each target table,
		-- 3.1. If record found for the REQ_ID, update record.
		-- 3.2. If record not found for the REQ_ID, insert record.
		------------------------------------------------------
		--DBMS_OUTPUT.PUT_LINE('Starting xml data retrieval and table update ----------');

		--------------------------------
		-- get Job Request Number
		--------------------------------
		BEGIN
			SELECT VALUE
			INTO V_JOB_REQ_NUM
			FROM BIZFLOW.RLVNTDATA
			WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'requestNum';
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_NUM := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM);
		IF V_JOB_REQ_NUM IS NULL THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_CLSF_TABLE: Job Request Number is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END IF;


		--------------------------------
		-- REQUEST table
		--------------------------------
		--DBMS_OUTPUT.PUT_LINE('    REQUEST table');
		BEGIN
			SELECT REQ_ID INTO V_JOB_REQ_ID
			FROM REQUEST
			WHERE REQ_JOB_REQ_NUMBER = V_JOB_REQ_NUM;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_ID := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('        V_JOB_REQ_ID = ' || V_JOB_REQ_ID);

		-- Unlike STRATCON, REQUEST record must be available by the time CLSF starts
		IF V_JOB_REQ_ID IS NULL THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_CLSF_TABLE: Job Request ID is invalid.  I_PROCID = '
				|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END IF;

		BEGIN
			--------------------------------
			-- REQUEST table update for cancellation
			--------------------------------
			MERGE INTO REQUEST TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS REQ_ID
					, V_JOB_REQ_NUM AS REQ_JOB_REQ_NUMBER
					, X.REQ_CANCEL_DT_STR
					, TO_DATE(X.REQ_CANCEL_DT_STR, 'YYYY/MM/DD HH24:MI:SS') AS REQ_CANCEL_DT
					, X.REQ_CANCEL_REASON
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/PROCESS_VARIABLE'
						PASSING FD.FIELD_DATA
						COLUMNS
							REQ_CANCEL_DT_STR                   NVARCHAR2(30)   PATH 'if (requestStatus/text() = "Request Cancelled") then requestStatusDate else ""'
							, REQ_CANCEL_REASON                 NVARCHAR2(140)  PATH 'cancelReason'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.REQ_ID = TRG.REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.REQ_CANCEL_DT           = SRC.REQ_CANCEL_DT
				, TRG.REQ_CANCEL_REASON     = SRC.REQ_CANCEL_REASON
			;
		END;


		BEGIN
			--------------------------------
			-- CLASSIF_STRATCON table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    CLASSIF_STRATCON table');
			MERGE INTO CLASSIF_STRATCON TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS CS_REQ_ID
					, XG.CS_TITLE
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = XG.CS_PAY_PLAN_ID AND ROWNUM = 1) AS CS_PAY_PLAN_ID
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = XG.CS_SR_ID AND ROWNUM = 1) AS CS_SR_ID
					, XG.CS_PD_NUMBER_JOBCD_1
					, XG.CS_CLASSIFICATION_DT_1
					--, XG.CS_GR_ID_1
					, CASE WHEN LENGTH(XG.CS_GR_ID_1) = 1 THEN '0' || XG.CS_GR_ID_1 ELSE XG.CS_GR_ID_1 END AS CS_GR_ID_1
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_1 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_1
					, XG.CS_PD_NUMBER_JOBCD_2
					, XG.CS_CLASSIFICATION_DT_2
					--, XG.CS_GR_ID_2
					, CASE WHEN LENGTH(XG.CS_GR_ID_2) = 1 THEN '0' || XG.CS_GR_ID_2 ELSE XG.CS_GR_ID_2 END AS CS_GR_ID_2
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_2 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_2
					, XG.CS_PD_NUMBER_JOBCD_3
					, XG.CS_CLASSIFICATION_DT_3
					--, XG.CS_GR_ID_3
					, CASE WHEN LENGTH(XG.CS_GR_ID_3) = 1 THEN '0' || XG.CS_GR_ID_3 ELSE XG.CS_GR_ID_3 END AS CS_GR_ID_3
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_3 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_3
					, XG.CS_PD_NUMBER_JOBCD_4
					, XG.CS_CLASSIFICATION_DT_4
					--, XG.CS_GR_ID_4
					, CASE WHEN LENGTH(XG.CS_GR_ID_4) = 1 THEN '0' || XG.CS_GR_ID_4 ELSE XG.CS_GR_ID_4 END AS CS_GR_ID_4
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_4 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_4
					, XG.CS_PD_NUMBER_JOBCD_5
					, XG.CS_CLASSIFICATION_DT_5
					--, XG.CS_GR_ID_5
					, CASE WHEN LENGTH(XG.CS_GR_ID_5) = 1 THEN '0' || XG.CS_GR_ID_5 ELSE XG.CS_GR_ID_5 END AS CS_GR_ID_5
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'FairLaborStandardsAct' AND TBL_NAME = XG.CS_FLSA_DETERM_ID_5 AND ROWNUM = 1) AS CS_FLSA_DETERM_ID_5
					--, XG.CS_PERFORMANCE_LEVEL
					, CASE WHEN LENGTH(XG.CS_PERFORMANCE_LEVEL) = 1 THEN '0' || XG.CS_PERFORMANCE_LEVEL ELSE XG.CS_PERFORMANCE_LEVEL END AS CS_PERFORMANCE_LEVEL
					, XG.CS_SUPERVISORY
					, XG.CS_AC_ID
					, XG.CS_ADMIN_CD
					, XG.SO_ID
					, XG.SO_TITLE
					, XG.SO_ORG
					, XG.XO_ID
					, XG.XO_TITLE
					, XG.XO_ORG
					, XG.HRL_ID
					, XG.HRL_TITLE
					, XG.HRL_ORG
					, XG.SS_ID
					, XG.CS_ID
					, XC.CS_FIN_STMT_REQ_ID
					, XC.CS_SEC_ID
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/GENERAL'
						PASSING FD.FIELD_DATA
						COLUMNS
							CS_TITLE                            NVARCHAR2(140)  PATH 'CS_TITLE'
							, CS_PAY_PLAN_ID                    NVARCHAR2(140)  PATH 'CS_PAY_PLAN_ID'
							, CS_SR_ID                          NVARCHAR2(140)  PATH 'CS_SR_ID'
							, CS_PD_NUMBER_JOBCD_1              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_1'
							, CS_CLASSIFICATION_DT_1            DATE            PATH 'CS_CLASSIFICATION_DT_1'
							--, CS_GR_ID_1                        NUMBER(2)       PATH 'CS_GR_ID_1'
							, CS_GR_ID_1                        NVARCHAR2(2)    PATH 'CS_GR_ID_1'
							, CS_FLSA_DETERM_ID_1               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_1'
							, CS_PD_NUMBER_JOBCD_2              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_2'
							, CS_CLASSIFICATION_DT_2            DATE            PATH 'CS_CLASSIFICATION_DT_2'
							--, CS_GR_ID_2                        NUMBER(2)       PATH 'CS_GR_ID_2'
							, CS_GR_ID_2                        NVARCHAR2(2)    PATH 'CS_GR_ID_2'
							, CS_FLSA_DETERM_ID_2               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_2'
							, CS_PD_NUMBER_JOBCD_3              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_3'
							, CS_CLASSIFICATION_DT_3            DATE            PATH 'CS_CLASSIFICATION_DT_3'
							--, CS_GR_ID_3                        NUMBER(2)       PATH 'CS_GR_ID_3'
							, CS_GR_ID_3                        NVARCHAR2(2)    PATH 'CS_GR_ID_3'
							, CS_FLSA_DETERM_ID_3               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_3'
							, CS_PD_NUMBER_JOBCD_4              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_4'
							, CS_CLASSIFICATION_DT_4            DATE            PATH 'CS_CLASSIFICATION_DT_4'
							--, CS_GR_ID_4                        NUMBER(2)       PATH 'CS_GR_ID_4'
							, CS_GR_ID_4                        NVARCHAR2(2)    PATH 'CS_GR_ID_4'
							, CS_FLSA_DETERM_ID_4               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_4'
							, CS_PD_NUMBER_JOBCD_5              NVARCHAR2(10)   PATH 'CS_PD_NUMBER_JOBCD_5'
							, CS_CLASSIFICATION_DT_5            DATE            PATH 'CS_CLASSIFICATION_DT_5'
							--, CS_GR_ID_5                        NUMBER(2)       PATH 'CS_GR_ID_5'
							, CS_GR_ID_5                        NVARCHAR2(2)    PATH 'CS_GR_ID_5'
							, CS_FLSA_DETERM_ID_5               NVARCHAR2(10)   PATH 'CS_FLSA_DETERM_ID_5'
							--, CS_PERFORMANCE_LEVEL              NUMBER(9)       PATH 'CS_PERFORMANCE_LEVEL'
							, CS_PERFORMANCE_LEVEL              NVARCHAR2(2)    PATH 'CS_PERFORMANCE_LEVEL'
							, CS_SUPERVISORY                    NUMBER(20)      PATH 'CS_SUPERVISORY'
							, CS_AC_ID                          NUMBER(20)      PATH 'CS_AC_ID'
							, CS_ADMIN_CD                       NVARCHAR2(8)    PATH 'CS_ADMIN_CD'
							, SO_ID                             NVARCHAR2(10)   PATH 'SO_ID'
							, SO_TITLE                          NVARCHAR2(50)   PATH 'SO_TITLE'
							, SO_ORG                            NVARCHAR2(50)   PATH 'SO_ORG'
							, XO_ID                             NVARCHAR2(10)   PATH 'XO_ID'
							, XO_TITLE                          NVARCHAR2(50)   PATH 'XO_TITLE'
							, XO_ORG                            NVARCHAR2(50)   PATH 'XO_ORG'
							, HRL_ID                            NVARCHAR2(10)   PATH 'HRL_ID'
							, HRL_TITLE                         NVARCHAR2(50)   PATH 'HRL_TITLE'
							, HRL_ORG                           NVARCHAR2(50)   PATH 'HRL_ORG'
							, SS_ID                             NVARCHAR2(10)   PATH 'SS_ID'
							, CS_ID                             NVARCHAR2(10)   PATH 'CS_ID'
					) XG
					, XMLTABLE('/DOCUMENT/CLASSIFICATION_CODE'
						PASSING FD.FIELD_DATA
						COLUMNS
							CS_FIN_STMT_REQ_ID                  NUMBER(20)      PATH 'CS_FIN_STMT_REQ_ID'
							, CS_SEC_ID                         NUMBER(20)      PATH 'CS_SEC_ID'
					) XC
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.CS_REQ_ID = TRG.CS_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.CS_TITLE                    = SRC.CS_TITLE
				, TRG.CS_PAY_PLAN_ID            = SRC.CS_PAY_PLAN_ID
				, TRG.CS_SR_ID                  = SRC.CS_SR_ID
				, TRG.CS_PD_NUMBER_JOBCD_1      = SRC.CS_PD_NUMBER_JOBCD_1
				, TRG.CS_CLASSIFICATION_DT_1    = SRC.CS_CLASSIFICATION_DT_1
				, TRG.CS_GR_ID_1                = SRC.CS_GR_ID_1
				, TRG.CS_FLSA_DETERM_ID_1       = SRC.CS_FLSA_DETERM_ID_1
				, TRG.CS_PD_NUMBER_JOBCD_2      = SRC.CS_PD_NUMBER_JOBCD_2
				, TRG.CS_CLASSIFICATION_DT_2    = SRC.CS_CLASSIFICATION_DT_2
				, TRG.CS_GR_ID_2                = SRC.CS_GR_ID_2
				, TRG.CS_FLSA_DETERM_ID_2       = SRC.CS_FLSA_DETERM_ID_2
				, TRG.CS_PD_NUMBER_JOBCD_3      = SRC.CS_PD_NUMBER_JOBCD_3
				, TRG.CS_CLASSIFICATION_DT_3    = SRC.CS_CLASSIFICATION_DT_3
				, TRG.CS_GR_ID_3                = SRC.CS_GR_ID_3
				, TRG.CS_FLSA_DETERM_ID_3       = SRC.CS_FLSA_DETERM_ID_3
				, TRG.CS_PD_NUMBER_JOBCD_4      = SRC.CS_PD_NUMBER_JOBCD_4
				, TRG.CS_CLASSIFICATION_DT_4    = SRC.CS_CLASSIFICATION_DT_4
				, TRG.CS_GR_ID_4                = SRC.CS_GR_ID_4
				, TRG.CS_FLSA_DETERM_ID_4       = SRC.CS_FLSA_DETERM_ID_4
				, TRG.CS_PD_NUMBER_JOBCD_5      = SRC.CS_PD_NUMBER_JOBCD_5
				, TRG.CS_CLASSIFICATION_DT_5    = SRC.CS_CLASSIFICATION_DT_5
				, TRG.CS_GR_ID_5                = SRC.CS_GR_ID_5
				, TRG.CS_FLSA_DETERM_ID_5       = SRC.CS_FLSA_DETERM_ID_5
				, TRG.CS_PERFORMANCE_LEVEL      = SRC.CS_PERFORMANCE_LEVEL
				, TRG.CS_SUPERVISORY            = SRC.CS_SUPERVISORY
				, TRG.CS_AC_ID                  = SRC.CS_AC_ID
				, TRG.CS_ADMIN_CD               = SRC.CS_ADMIN_CD
				, TRG.SO_ID                     = SRC.SO_ID
				, TRG.SO_TITLE                  = SRC.SO_TITLE
				, TRG.SO_ORG                    = SRC.SO_ORG
				, TRG.XO_ID                     = SRC.XO_ID
				, TRG.XO_TITLE                  = SRC.XO_TITLE
				, TRG.XO_ORG                    = SRC.XO_ORG
				, TRG.HRL_ID                    = SRC.HRL_ID
				, TRG.HRL_TITLE                 = SRC.HRL_TITLE
				, TRG.HRL_ORG                   = SRC.HRL_ORG
				, TRG.SS_ID                     = SRC.SS_ID
				, TRG.CS_ID                     = SRC.CS_ID
				, TRG.CS_FIN_STMT_REQ_ID        = SRC.CS_FIN_STMT_REQ_ID
				, TRG.CS_SEC_ID                 = SRC.CS_SEC_ID
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.CS_REQ_ID
				, TRG.CS_TITLE
				, TRG.CS_PAY_PLAN_ID
				, TRG.CS_SR_ID
				, TRG.CS_PD_NUMBER_JOBCD_1
				, TRG.CS_CLASSIFICATION_DT_1
				, TRG.CS_GR_ID_1
				, TRG.CS_FLSA_DETERM_ID_1
				, TRG.CS_PD_NUMBER_JOBCD_2
				, TRG.CS_CLASSIFICATION_DT_2
				, TRG.CS_GR_ID_2
				, TRG.CS_FLSA_DETERM_ID_2
				, TRG.CS_PD_NUMBER_JOBCD_3
				, TRG.CS_CLASSIFICATION_DT_3
				, TRG.CS_GR_ID_3
				, TRG.CS_FLSA_DETERM_ID_3
				, TRG.CS_PD_NUMBER_JOBCD_4
				, TRG.CS_CLASSIFICATION_DT_4
				, TRG.CS_GR_ID_4
				, TRG.CS_FLSA_DETERM_ID_4
				, TRG.CS_PD_NUMBER_JOBCD_5
				, TRG.CS_CLASSIFICATION_DT_5
				, TRG.CS_GR_ID_5
				, TRG.CS_FLSA_DETERM_ID_5
				, TRG.CS_PERFORMANCE_LEVEL
				, TRG.CS_SUPERVISORY
				, TRG.CS_AC_ID
				, TRG.CS_ADMIN_CD
				, TRG.SO_ID
				, TRG.SO_TITLE
				, TRG.SO_ORG
				, TRG.XO_ID
				, TRG.XO_TITLE
				, TRG.XO_ORG
				, TRG.HRL_ID
				, TRG.HRL_TITLE
				, TRG.HRL_ORG
				, TRG.SS_ID
				, TRG.CS_ID
				, TRG.CS_FIN_STMT_REQ_ID
				, TRG.CS_SEC_ID
			)
			VALUES
			(
				SRC.CS_REQ_ID
				, SRC.CS_TITLE
				, SRC.CS_PAY_PLAN_ID
				, SRC.CS_SR_ID
				, SRC.CS_PD_NUMBER_JOBCD_1
				, SRC.CS_CLASSIFICATION_DT_1
				, SRC.CS_GR_ID_1
				, SRC.CS_FLSA_DETERM_ID_1
				, SRC.CS_PD_NUMBER_JOBCD_2
				, SRC.CS_CLASSIFICATION_DT_2
				, SRC.CS_GR_ID_2
				, SRC.CS_FLSA_DETERM_ID_2
				, SRC.CS_PD_NUMBER_JOBCD_3
				, SRC.CS_CLASSIFICATION_DT_3
				, SRC.CS_GR_ID_3
				, SRC.CS_FLSA_DETERM_ID_3
				, SRC.CS_PD_NUMBER_JOBCD_4
				, SRC.CS_CLASSIFICATION_DT_4
				, SRC.CS_GR_ID_4
				, SRC.CS_FLSA_DETERM_ID_4
				, SRC.CS_PD_NUMBER_JOBCD_5
				, SRC.CS_CLASSIFICATION_DT_5
				, SRC.CS_GR_ID_5
				, SRC.CS_FLSA_DETERM_ID_5
				, SRC.CS_PERFORMANCE_LEVEL
				, SRC.CS_SUPERVISORY
				, SRC.CS_AC_ID
				, SRC.CS_ADMIN_CD
				, SRC.SO_ID
				, SRC.SO_TITLE
				, SRC.SO_ORG
				, SRC.XO_ID
				, SRC.XO_TITLE
				, SRC.XO_ORG
				, SRC.HRL_ID
				, SRC.HRL_TITLE
				, SRC.HRL_ORG
				, SRC.SS_ID
				, SRC.CS_ID
				, SRC.CS_FIN_STMT_REQ_ID
				, SRC.CS_SEC_ID
			)
			;


			--------------------------------
			-- PD_COVERSHEET table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    PD_COVERSHEET table');
			MERGE INTO PD_COVERSHEET TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS PD_REQ_ID
					, I_PROCID AS PD_PROCID
					, XG.PD_ORG_POS_TITLE
					, XG.PD_EMPLOYING_OFFICE
					, XG.PD_SUBJECT_IA
					, XG.PD_ORGANIZATION
					, XG.PD_SUB_ORG_1
					, XG.PD_SUB_ORG_2
					, XG.PD_SUB_ORG_3
					, XG.PD_SUB_ORG_4
					, XG.PD_SUB_ORG_5
					, XG.PD_SCOPE
					, XG.PD_PCA
					, XG.PD_PDP
					, XG.PD_FTT
					, XG.PD_OUTSTATION
					, XG.PD_INCUMBENCY
					, XG.PD_REMARKS
					, XC.PD_CLS_STANDARDS
					, XC.PD_ACQ_CODE
					, XC.PD_CYB_SEC_CD
					, XC.PD_COMPET_LVL_CD
					, XC.PD_BUS_CD
					, XC.BYPASS_DWC_FL
					, XA.PD_SUPV_CERT
					, XA.PD_SUPV_NAME
					, XA.PD_SUPV_TITLE
					, XA.PD_SUPV_SIG
					, XA.PD_SUPV_SIG_DT
					, XA.PD_CLS_SPEC_CERT
					, XA.PD_CLS_SPEC_NAME
					, XA.PD_CLS_SPEC_TITLE
					, XA.PD_CLS_SPEC_SIG
					, XA.PD_CLS_SPEC_DT
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/GENERAL'
						PASSING FD.FIELD_DATA
						COLUMNS
							PD_ORG_POS_TITLE                    NVARCHAR2(140)  PATH 'PD_ORG_POS_TITLE'
							, PD_EMPLOYING_OFFICE               NUMBER(20)      PATH 'PD_EMPLOYING_OFFICE'
							, PD_SUBJECT_IA                     CHAR(1)         PATH 'PD_SUBJECT_IA'
							, PD_ORGANIZATION                   NVARCHAR2(10)   PATH 'PD_ORGANIZATION'
							, PD_SUB_ORG_1                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_1'
							, PD_SUB_ORG_2                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_2'
							, PD_SUB_ORG_3                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_3'
							, PD_SUB_ORG_4                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_4'
							, PD_SUB_ORG_5                      NVARCHAR2(10)   PATH 'PD_SUB_ORG_5'
							, PD_SCOPE                          NVARCHAR2(10)   PATH 'PD_SCOPE'
							, PD_PCA                            CHAR(1)         PATH 'if (POS_INFORMATION/PD_PCA/text() = "true") then 1 else 0'
							, PD_PDP                            CHAR(1)         PATH 'if (POS_INFORMATION/PD_PDP/text() = "true") then 1 else 0'
							, PD_FTT                            CHAR(1)         PATH 'if (POS_INFORMATION/PD_FTT/text() = "true") then 1 else 0'
							, PD_OUTSTATION                     CHAR(1)         PATH 'if (POS_INFORMATION/PD_OUTSTATION/text() = "true") then 1 else 0'
							, PD_INCUMBENCY                     CHAR(1)         PATH 'if (POS_INFORMATION/PD_INCUMBENCY/text() = "true") then 1 else 0'
							, PD_REMARKS                        NVARCHAR2(500)  PATH 'PD_REMARKS'
					) XG
					, XMLTABLE('/DOCUMENT/CLASSIFICATION_CODE'
						PASSING FD.FIELD_DATA
						COLUMNS
							PD_CLS_STANDARDS                    NVARCHAR2(100)  PATH 'string-join(PD_CLS_STANDARDS/text(), ",")'
							, PD_ACQ_CODE                       NUMBER(20)      PATH 'PD_ACQ_CODE'
							, PD_CYB_SEC_CD                     NVARCHAR2(100)  PATH 'string-join(PD_CYB_SEC_CD/text(), ",")'
							, PD_COMPET_LVL_CD                  NVARCHAR2(10)   PATH 'PD_COMPET_LVL_CD'
							, PD_BUS_CD                         NUMBER(20)      PATH 'PD_BUS_CD'
							, BYPASS_DWC_FL                     NVARCHAR2(10)   PATH 'BYPASS_DWC_FL'
					) XC
					, XMLTABLE('/DOCUMENT/APPROVAL'
						PASSING FD.FIELD_DATA
						COLUMNS
							PD_SUPV_CERT                        CHAR(1)         PATH 'if (PD_SUPV_CERT/text() = "true") then 1 else 0'
							, PD_SUPV_NAME                      NVARCHAR2(100)  PATH 'PD_SUPV_NAME'
							, PD_SUPV_TITLE                     NVARCHAR2(140)  PATH 'PD_SUPV_TITLE'
							, PD_SUPV_SIG                       NVARCHAR2(10)   PATH 'PD_SUPV_SIG'
							, PD_SUPV_SIG_DT                    DATE            PATH 'PD_SUPV_SIG_DT'
							, PD_CLS_SPEC_CERT                  CHAR(1)         PATH 'if (PD_CLS_SPEC_CERT/text() = "true") then 1 else 0'
							, PD_CLS_SPEC_NAME                  NVARCHAR2(100)  PATH 'PD_CLS_SPEC_NAME'
							, PD_CLS_SPEC_TITLE                 NVARCHAR2(140)  PATH 'PD_CLS_SPEC_TITLE'
							, PD_CLS_SPEC_SIG                   NVARCHAR2(10)   PATH 'PD_CLS_SPEC_SIG'
							, PD_CLS_SPEC_DT                    DATE            PATH 'PD_CLS_SPEC_DT'
					) XA
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.PD_REQ_ID = TRG.PD_REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.PD_PROCID               = SRC.PD_PROCID
				, TRG.PD_ORG_POS_TITLE      = SRC.PD_ORG_POS_TITLE
				, TRG.PD_EMPLOYING_OFFICE   = SRC.PD_EMPLOYING_OFFICE
				, TRG.PD_SUBJECT_IA    	    = SRC.PD_SUBJECT_IA
				, TRG.PD_ORGANIZATION       = SRC.PD_ORGANIZATION
				, TRG.PD_SUB_ORG_1          = SRC.PD_SUB_ORG_1
				, TRG.PD_SUB_ORG_2          = SRC.PD_SUB_ORG_2
				, TRG.PD_SUB_ORG_3          = SRC.PD_SUB_ORG_3
				, TRG.PD_SUB_ORG_4          = SRC.PD_SUB_ORG_4
				, TRG.PD_SUB_ORG_5          = SRC.PD_SUB_ORG_5
				, TRG.PD_SCOPE              = SRC.PD_SCOPE
				, TRG.PD_PCA                = SRC.PD_PCA
				, TRG.PD_PDP                = SRC.PD_PDP
				, TRG.PD_FTT                = SRC.PD_FTT
				, TRG.PD_OUTSTATION         = SRC.PD_OUTSTATION
				, TRG.PD_INCUMBENCY         = SRC.PD_INCUMBENCY
				, TRG.PD_REMARKS            = SRC.PD_REMARKS
				, TRG.PD_CLS_STANDARDS      = SRC.PD_CLS_STANDARDS
				, TRG.PD_ACQ_CODE           = SRC.PD_ACQ_CODE
				, TRG.PD_CYB_SEC_CD         = SRC.PD_CYB_SEC_CD
				, TRG.PD_COMPET_LVL_CD      = SRC.PD_COMPET_LVL_CD
				, TRG.PD_BUS_CD             = SRC.PD_BUS_CD
				, TRG.BYPASS_DWC_FL         = SRC.BYPASS_DWC_FL
				, TRG.PD_SUPV_CERT          = SRC.PD_SUPV_CERT
				, TRG.PD_SUPV_NAME          = SRC.PD_SUPV_NAME
				, TRG.PD_SUPV_TITLE         = SRC.PD_SUPV_TITLE
				, TRG.PD_SUPV_SIG           = SRC.PD_SUPV_SIG
				, TRG.PD_SUPV_SIG_DT        = SRC.PD_SUPV_SIG_DT
				, TRG.PD_CLS_SPEC_CERT      = SRC.PD_CLS_SPEC_CERT
				, TRG.PD_CLS_SPEC_NAME      = SRC.PD_CLS_SPEC_NAME
				, TRG.PD_CLS_SPEC_TITLE     = SRC.PD_CLS_SPEC_TITLE
				, TRG.PD_CLS_SPEC_SIG       = SRC.PD_CLS_SPEC_SIG
				, TRG.PD_CLS_SPEC_DT        = SRC.PD_CLS_SPEC_DT
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.PD_REQ_ID
				, TRG.PD_PROCID
				, TRG.PD_ORG_POS_TITLE
				, TRG.PD_EMPLOYING_OFFICE
				, TRG.PD_SUBJECT_IA
				, TRG.PD_ORGANIZATION
				, TRG.PD_SUB_ORG_1
				, TRG.PD_SUB_ORG_2
				, TRG.PD_SUB_ORG_3
				, TRG.PD_SUB_ORG_4
				, TRG.PD_SUB_ORG_5
				, TRG.PD_SCOPE
				, TRG.PD_PCA
				, TRG.PD_PDP
				, TRG.PD_FTT
				, TRG.PD_OUTSTATION
				, TRG.PD_INCUMBENCY
				, TRG.PD_REMARKS
				, TRG.PD_CLS_STANDARDS
				, TRG.PD_ACQ_CODE
				, TRG.PD_CYB_SEC_CD
				, TRG.PD_COMPET_LVL_CD
				, TRG.PD_BUS_CD
				, TRG.BYPASS_DWC_FL
				, TRG.PD_SUPV_CERT
				, TRG.PD_SUPV_NAME
				, TRG.PD_SUPV_TITLE
				, TRG.PD_SUPV_SIG
				, TRG.PD_SUPV_SIG_DT
				, TRG.PD_CLS_SPEC_CERT
				, TRG.PD_CLS_SPEC_NAME
				, TRG.PD_CLS_SPEC_TITLE
				, TRG.PD_CLS_SPEC_SIG
				, TRG.PD_CLS_SPEC_DT
			)
			VALUES
			(
				SRC.PD_REQ_ID
				, SRC.PD_PROCID
				, SRC.PD_ORG_POS_TITLE
				, SRC.PD_EMPLOYING_OFFICE
				, SRC.PD_SUBJECT_IA
				, SRC.PD_ORGANIZATION
				, SRC.PD_SUB_ORG_1
				, SRC.PD_SUB_ORG_2
				, SRC.PD_SUB_ORG_3
				, SRC.PD_SUB_ORG_4
				, SRC.PD_SUB_ORG_5
				, SRC.PD_SCOPE
				, SRC.PD_PCA
				, SRC.PD_PDP
				, SRC.PD_FTT
				, SRC.PD_OUTSTATION
				, SRC.PD_INCUMBENCY
				, SRC.PD_REMARKS
				, SRC.PD_CLS_STANDARDS
				, SRC.PD_ACQ_CODE
				, SRC.PD_CYB_SEC_CD
				, SRC.PD_COMPET_LVL_CD
				, SRC.PD_BUS_CD
				, SRC.BYPASS_DWC_FL
				, SRC.PD_SUPV_CERT
				, SRC.PD_SUPV_NAME
				, SRC.PD_SUPV_TITLE
				, SRC.PD_SUPV_SIG
				, SRC.PD_SUPV_SIG_DT
				, SRC.PD_CLS_SPEC_CERT
				, SRC.PD_CLS_SPEC_NAME
				, SRC.PD_CLS_SPEC_TITLE
				, SRC.PD_CLS_SPEC_SIG
				, SRC.PD_CLS_SPEC_DT
			)
			;


			--------------------------------
			-- Get V_PD_ID for FLSA table
			--------------------------------
			BEGIN
				SELECT PD_ID INTO V_PD_ID
				FROM PD_COVERSHEET
				WHERE PD_REQ_ID = V_JOB_REQ_ID;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN V_JOB_REQ_ID := NULL;
			END;

			--------------------------------
			-- FLSA table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    FLSA table');
			MERGE INTO FLSA TRG
			USING
			(
				SELECT
					V_PD_ID AS FLSA_PD_ID
					, XE.FLSA_EX_EXEC
					, XE.FLSA_EX_ADMIN
					, XE.FLSA_EX_PROF_LEARNED
					, XE.FLSA_EX_PROF_CREATIVE
					, XE.FLSA_EX_PROF_COMPUTER
					, XE.FLSA_EX_LAW_ENFORC
					, XE.FLSA_EX_FOREIGN
					, XE.FLSA_EX_REMARKS
					, XN.FLSA_NONEX_SALARY
					, XN.FLSA_NONEX_EQUIP_OPER
					, XN.FLSA_NONEX_TECHN
					, XN.FLSA_NONEX_FED_WAGE_SYS
					, XN.FLSA_NONEX_REMARKS
				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT/FLSA_EX'
						PASSING FD.FIELD_DATA
						COLUMNS
							FLSA_EX_EXEC                        CHAR(1)         PATH 'if (FLSA_EX_EXEC/text() = "true") then 1 else 0'
							, FLSA_EX_ADMIN                     CHAR(1)         PATH 'if (FLSA_EX_ADMIN/text() = "true") then 1 else 0'
							, FLSA_EX_PROF_LEARNED              CHAR(1)         PATH 'if (FLSA_EX_PROF_LEARNED/text() = "true") then 1 else 0'
							, FLSA_EX_PROF_CREATIVE             CHAR(1)         PATH 'if (FLSA_EX_PROF_CREATIVE/text() = "true") then 1 else 0'
							, FLSA_EX_PROF_COMPUTER             CHAR(1)         PATH 'if (FLSA_EX_PROF_COMPUTER/text() = "true") then 1 else 0'
							, FLSA_EX_LAW_ENFORC                CHAR(1)         PATH 'if (FLSA_EX_LAW_ENFORC/text() = "true") then 1 else 0'
							, FLSA_EX_FOREIGN                   CHAR(1)         PATH 'if (FLSA_EX_FOREIGN/text() = "true") then 1 else 0'
							, FLSA_EX_REMARKS                   NVARCHAR2(140)  PATH 'FLSA_REMARKS'
					) XE
					, XMLTABLE('/DOCUMENT/FLSA_NONEX'
						PASSING FD.FIELD_DATA
						COLUMNS
							FLSA_NONEX_SALARY                   CHAR(1)         PATH 'if (FLSA_NONEX_SALARY/text() = "true") then 1 else 0'
							, FLSA_NONEX_EQUIP_OPER             CHAR(1)         PATH 'if (FLSA_NONEX_EQUIP_OPER/text() = "true") then 1 else 0'
							, FLSA_NONEX_TECHN                  CHAR(1)         PATH 'if (FLSA_NONEX_TECHN/text() = "true") then 1 else 0'
							, FLSA_NONEX_FED_WAGE_SYS           CHAR(1)         PATH 'if (FLSA_NONEX_FED_WAGE_SYS/text() = "true") then 1 else 0'
							, FLSA_NONEX_REMARKS                NVARCHAR2(140)  PATH 'FLSA_REMARKS'
					) XN
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.FLSA_PD_ID = TRG.FLSA_PD_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.FLSA_EX_EXEC               = SRC.FLSA_EX_EXEC
				, TRG.FLSA_EX_ADMIN            = SRC.FLSA_EX_ADMIN
				, TRG.FLSA_EX_PROF_LEARNED     = SRC.FLSA_EX_PROF_LEARNED
				, TRG.FLSA_EX_PROF_CREATIVE    = SRC.FLSA_EX_PROF_CREATIVE
				, TRG.FLSA_EX_PROF_COMPUTER    = SRC.FLSA_EX_PROF_COMPUTER
				, TRG.FLSA_EX_LAW_ENFORC       = SRC.FLSA_EX_LAW_ENFORC
				, TRG.FLSA_EX_FOREIGN          = SRC.FLSA_EX_FOREIGN
				, TRG.FLSA_EX_REMARKS          = SRC.FLSA_EX_REMARKS
				, TRG.FLSA_NONEX_SALARY        = SRC.FLSA_NONEX_SALARY
				, TRG.FLSA_NONEX_EQUIP_OPER    = SRC.FLSA_NONEX_EQUIP_OPER
				, TRG.FLSA_NONEX_TECHN         = SRC.FLSA_NONEX_TECHN
				, TRG.FLSA_NONEX_FED_WAGE_SYS  = SRC.FLSA_NONEX_FED_WAGE_SYS
				, TRG.FLSA_NONEX_REMARKS       = SRC.FLSA_NONEX_REMARKS
			WHEN NOT MATCHED THEN INSERT
			(
				TRG.FLSA_PD_ID
				, TRG.FLSA_EX_EXEC
				, TRG.FLSA_EX_ADMIN
				, TRG.FLSA_EX_PROF_LEARNED
				, TRG.FLSA_EX_PROF_CREATIVE
				, TRG.FLSA_EX_PROF_COMPUTER
				, TRG.FLSA_EX_LAW_ENFORC
				, TRG.FLSA_EX_FOREIGN
				, TRG.FLSA_EX_REMARKS
				, TRG.FLSA_NONEX_SALARY
				, TRG.FLSA_NONEX_EQUIP_OPER
				, TRG.FLSA_NONEX_TECHN
				, TRG.FLSA_NONEX_FED_WAGE_SYS
				, TRG.FLSA_NONEX_REMARKS
			)
			VALUES
			(
				SRC.FLSA_PD_ID
				, SRC.FLSA_EX_EXEC
				, SRC.FLSA_EX_ADMIN
				, SRC.FLSA_EX_PROF_LEARNED
				, SRC.FLSA_EX_PROF_CREATIVE
				, SRC.FLSA_EX_PROF_COMPUTER
				, SRC.FLSA_EX_LAW_ENFORC
				, SRC.FLSA_EX_FOREIGN
				, SRC.FLSA_EX_REMARKS
				, SRC.FLSA_NONEX_SALARY
				, SRC.FLSA_NONEX_EQUIP_OPER
				, SRC.FLSA_NONEX_TECHN
				, SRC.FLSA_NONEX_FED_WAGE_SYS
				, SRC.FLSA_NONEX_REMARKS
			)
			;

		EXCEPTION
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20905, 'SP_UPDATE_CLSF_TABLE: Invalid Classification data.  I_PROCID = '
					|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END;
		--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_CLSF_TABLE - END ==========================');

	END IF;

EXCEPTION
	WHEN E_INVALID_PROCID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
	WHEN E_INVALID_JOB_REQ_ID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
	WHEN E_INVALID_STRATCON_DATA THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_CLSF_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
END;

/





--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_CLSF
--------------------------------------------------------

/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * the Classification process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_PV_CLSF
(
	I_PROCID            IN      NUMBER
	, I_FIELD_DATA      IN      XMLTYPE
)
IS
	V_RLVNTDATANAME VARCHAR2(100);
	V_VALUE NVARCHAR2(2000);
	V_VALUE_LOOKUP NVARCHAR2(2000);
	V_REC_CNT NUMBER(10);
	V_XMLDOC XMLTYPE;
	V_XMLVALUE XMLTYPE;
BEGIN
	--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
	--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
	--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
	--DBMS_OUTPUT.PUT_LINE(' ----------------');
	--V_XMLDOC := XMLTYPE(I_FIELD_DATA);
	V_XMLDOC := I_FIELD_DATA;


	IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
		--DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

		V_RLVNTDATANAME := 'adminCode';
		--V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_AC_ID/text()');
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_ADMIN_CD/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		--	---------------------------------
		--	-- replace with admin code desc lookup value
		--	---------------------------------
		--	BEGIN
		--		SELECT AC_ADMIN_CD INTO V_VALUE_LOOKUP
		--		FROM ADMIN_CODES
		--		WHERE AC_ID = TO_NUMBER(V_VALUE);
		--	EXCEPTION
		--		WHEN NO_DATA_FOUND THEN
		--			V_VALUE_LOOKUP := NULL;
		--		WHEN OTHERS THEN
		--			V_VALUE_LOOKUP := NULL;
		--	END;
		--	V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


--adminEmailAddress


		V_RLVNTDATANAME := 'cancelReason';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'classSpecialist';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'coversheetApprovedBySO';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/coversheetApprovedBySO/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'execOfficer';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/XO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'finalPackageApprovedSO';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/finalPackageApprovedSO/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'hrLiaison';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/HRL_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'lastActivityCompDate';
		BEGIN
			SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
		EXCEPTION
			WHEN OTHERS THEN V_VALUE := NULL;
		END;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'modifyCoversheetFeedback';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/modifyCoversheetFeedback/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'modifyFinalPackageFeedback';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/modifyFinalPackageFeedback/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


--posGrade


		V_RLVNTDATANAME := 'posIs';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_SUPERVISORY/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posLocation';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/PD_EMPLOYING_OFFICE/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

-------------------
--TODO: maybe we need this
		V_RLVNTDATANAME := 'posPayPlan';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/CS_PAY_PLAN_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				--WHERE TBL_ID = TO_NUMBER(V_VALUE);
				WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = V_VALUE;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


--posNumber


		V_RLVNTDATANAME := 'posSensitivity';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/CLASSIFICATION_CODE/CS_SEC_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				WHERE TBL_ID = TO_NUMBER(V_VALUE);
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posSeries';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_SR_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			---------------------------------
			-- replace with lookup value
			---------------------------------
			BEGIN
				SELECT TBL_LABEL INTO V_VALUE_LOOKUP
				FROM TBL_LOOKUP
				--WHERE TBL_ID = TO_NUMBER(V_VALUE);
				WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = V_VALUE;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_VALUE_LOOKUP := NULL;
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;
			V_VALUE := V_VALUE_LOOKUP;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'posTitle';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/CS_TITLE/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'requestStatus';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatus/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'requestStatusDate';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/requestStatusDate/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			-------------------------------------
			-- even though it is date, do not format or perform GMT conversion
			-------------------------------------
			V_VALUE := V_VALUE;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		-------------------------------------------------------------------------------
		-- Only update if not blank to prevent overwriting unintentionally
		-------------------------------------------------------------------------------
		IF V_VALUE IS NOT NULL THEN
			UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
		END IF;


		V_RLVNTDATANAME := 'returnToSO';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSO/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'selectOfficial';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SO_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		V_RLVNTDATANAME := 'staffSpecialist';
		V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SS_ID/text()');
		IF V_XMLVALUE IS NOT NULL THEN
			-------------------------------
			-- participant prefix
			-------------------------------
			--V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
			-- If the Job Request is for Special Program, SS_ID may point to User Group,
			-- rather than individual user.  Therefore, lookup
			V_VALUE := V_XMLVALUE.GETSTRINGVAL();
			BEGIN
				SELECT TYPE INTO V_VALUE_LOOKUP FROM BIZFLOW.MEMBER WHERE MEMBERID = V_VALUE;
			EXCEPTION
				WHEN OTHERS THEN
					V_VALUE_LOOKUP := NULL;
			END;

			IF V_VALUE_LOOKUP IS NOT NULL THEN
				V_VALUE := '[' || V_VALUE_LOOKUP || ']' || V_XMLVALUE.GETSTRINGVAL();
			ELSE
				V_VALUE := NULL;
			END IF;
		ELSE
			V_VALUE := NULL;
		END IF;
		--DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
		--DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
		UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


		--DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

		COMMIT;

	END IF;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_CLSF -------------------');
END;

/




--------------------------------------------------------
--  DDL for VW_CLASSIFICATION
--------------------------------------------------------
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
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = CS.XO_ID AND ROWNUM = 1)  AS XO_NAME
	, CS.XO_TITLE
	, CS.XO_ORG
	, CS.HRL_ID
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = CS.HRL_ID AND ROWNUM = 1)  AS HL_NAME
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

/
