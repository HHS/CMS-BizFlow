create or replace PROCEDURE SP_UPDATE_ELIGQUAL_TABLE
(
	I_PROCID            IN      NUMBER
)
IS
	V_JOB_REQ_ID                NUMBER(20);
	V_JOB_REQ_NUM               NVARCHAR2(50);
	V_CLOBVALUE                 CLOB;
	V_VALUE                     NVARCHAR2(4000);
	V_VALUE_LOOKUP              NVARCHAR2(2000);
	V_REC_CNT                   NUMBER(10);
	V_XMLDOC                    XMLTYPE;
	V_XMLVALUE                  XMLTYPE;
	V_ERRCODE                   NUMBER(10);
	V_ERRMSG                    VARCHAR2(512);
	E_INVALID_PROCID            EXCEPTION;
	E_INVALID_JOB_REQ_ID        EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_JOB_REQ_ID, -20902);
	E_INVALID_STRATCON_DATA     EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_INVALID_STRATCON_DATA, -20905);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_ELIGQUAL_TABLE - BEGIN ============================');
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
			SELECT XMLQUERY('/DOCUMENT/PROCESS_VARIABLE/requestNum/text()'
				PASSING FD.FIELD_DATA RETURNING CONTENT).GETSTRINGVAL()
				, FD.FIELD_DATA
			INTO V_JOB_REQ_NUM, V_XMLDOC
			FROM TBL_FORM_DTL FD
			WHERE FD.PROCID = I_PROCID;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN V_JOB_REQ_NUM := NULL;
		END;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (from xml) = ' || V_JOB_REQ_NUM);
		IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
			BEGIN
				SELECT VALUE
				INTO V_JOB_REQ_NUM
				FROM BIZFLOW.RLVNTDATA
				WHERE PROCID = I_PROCID AND RLVNTDATANAME = 'requestNum';
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					V_JOB_REQ_NUM := NULL;
					RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request Number is invalid.  I_PROCID = '
						|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
			END;
		END IF;

		--DBMS_OUTPUT.PUT_LINE('    V_JOB_REQ_NUM (after pv check) = ' || V_JOB_REQ_NUM);
		IF V_JOB_REQ_NUM IS NULL OR LENGTH(V_JOB_REQ_NUM) = 0 THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request Number is invalid.  I_PROCID = '
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

		-- Unlike STRATCON, REQUEST record must be available by the time ELIGQUAL starts
		IF V_JOB_REQ_ID IS NULL THEN
			RAISE_APPLICATION_ERROR(-20902, 'SP_UPDATE_ELIGQUAL_TABLE: Job Request ID is invalid.  I_PROCID = '
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
			-- ELIG_QUAL table
			--------------------------------
			--DBMS_OUTPUT.PUT_LINE('    ELIG_QUAL table');
			MERGE INTO ELIG_QUAL TRG
			USING
			(
				SELECT
					V_JOB_REQ_ID AS REQ_ID
					, I_PROCID AS PROCID

					, X.ADMIN_CD
					, X.RT_ID
					, X.AT_ID
					, X.VT_ID
					, X.SAT_ID
					, X.CT_ID
					, X.SO_ID
					, X.SO_TITLE
					, X.SO_ORG
					, X.XO_ID
					, X.XO_TITLE
					, X.XO_ORG
					, X.HRL_ID
					, X.HRL_TITLE
					, X.HRL_ORG
					, X.SS_ID
					, X.CS_ID
					, X.SO_AGREE
					, X.OTHER_CERT
					
					, X.CNDT_LAST_NM
					, X.CNDT_FIRST_NM
					, X.CNDT_MIDDLE_NM
					, X.BGT_APR_OFM
					, X.SPNSR_ORG_NM
					, X.SPNSR_ORG_FUND_PC
					, X.POS_TITLE
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'PayPlan' AND TBL_NAME = X.PAY_PLAN_ID AND ROWNUM = 1) AS PAY_PLAN_ID
					, (SELECT TBL_ID FROM TBL_LOOKUP WHERE TBL_LTYPE = 'OccupationalSeries' AND TBL_NAME = X.SERIES AND ROWNUM = 1) AS SERIES
					, X.POS_DESC_NUMBER_1
					, X.CLASSIFICATION_DT_1
					, CASE WHEN LENGTH(X.GRADE_1) = 1 THEN '0' || X.GRADE_1 ELSE X.GRADE_1 END AS GRADE_1
					, X.POS_DESC_NUMBER_2
					, X.CLASSIFICATION_DT_2
					, CASE WHEN LENGTH(X.GRADE_2) = 1 THEN '0' || X.GRADE_2 ELSE X.GRADE_2 END AS GRADE_2
					, X.POS_DESC_NUMBER_3
					, X.CLASSIFICATION_DT_3
					, CASE WHEN LENGTH(X.GRADE_3) = 1 THEN '0' || X.GRADE_3 ELSE X.GRADE_3 END AS GRADE_3
					, X.POS_DESC_NUMBER_4
					, X.CLASSIFICATION_DT_4
					, CASE WHEN LENGTH(X.GRADE_4) = 1 THEN '0' || X.GRADE_4 ELSE X.GRADE_4 END AS GRADE_4
					, X.POS_DESC_NUMBER_5
					, X.CLASSIFICATION_DT_5
					, CASE WHEN LENGTH(X.GRADE_5) = 1 THEN '0' || X.GRADE_5 ELSE X.GRADE_5 END AS GRADE_5
					, X.MED_OFFICERS_ID
					, CASE WHEN LENGTH(X.PERFORMANCE_LEVEL) = 1 THEN '0' || X.PERFORMANCE_LEVEL ELSE X.PERFORMANCE_LEVEL END AS PERFORMANCE_LEVEL
					, X.SUPERVISORY
					, X.SKILL
					, X.LOCATION
					, X.VACANCIES
					, X.REPORT_SUPERVISOR
					, X.CAN
					, X.VICE
					, X.VICE_NAME
					, X.DAYS_ADVERTISED
					, X.TA_ID
					, X.NTE
					, X.WORK_SCHED_ID
					, X.HOURS_PER_WEEK
					, X.DUAL_EMPLMT
					, X.SEC_ID
					, X.CE_FINANCIAL_DISC
					, X.CE_FINANCIAL_TYPE_ID
					, X.CE_PE_PHYSICAL
					, X.CE_DRUG_TEST
					, X.CE_IMMUN
					, X.CE_TRAVEL
					, X.CE_TRAVEL_PER
					, X.CE_LIC
					, X.CE_LIC_INFO
					, X.REMARKS
					, X.PROC_REQ_TYPE
					, X.RECRUIT_OFFICE_ID
					, X.REQ_CREATE_NOTIFY_DT
					, X.ASSOC_DESCR_NUMBERS
					, X.PROMOTE_POTENTIAL
					, X.VICE_EMPL_ID
					, X.SR_ID
					, X.GR_ID
					, X.GA_1
					, X.GA_2
					, X.GA_3
					, X.GA_4
					, X.GA_5
					, X.GA_6
					, X.GA_7
					, X.GA_8
					, X.GA_9
					, X.GA_10
					, X.GA_11
					, X.GA_12
					, X.GA_13
					, X.GA_14
					, X.GA_15
					
					, X.CNDT_ELIGIBLE
					, X.INELIG_REASON
					, X.CNDT_QUALIFIED
					, X.DISQUAL_REASON

					, X.SEL_DETERM
					
					, X.DCO_CERT
					, X.DCO_NAME
					, X.DCO_SIG
					, X.DCO_SIG_DT

				FROM TBL_FORM_DTL FD
					, XMLTABLE('/DOCUMENT'
						PASSING FD.FIELD_DATA
						COLUMNS
						
							ADMIN_CD                        NVARCHAR2(8)    PATH 'GENERAL/ADMIN_CD'
							, RT_ID                         NUMBER(20)      PATH 'GENERAL/RT_ID'
							, AT_ID                         NUMBER(20)      PATH 'GENERAL/AT_ID'
							, VT_ID                         NUMBER(20)      PATH 'GENERAL/VT_ID'
							, SAT_ID                        NUMBER(20)      PATH 'GENERAL/SAT_ID'
							, CT_ID                         NUMBER(20)      PATH 'GENERAL/CT_ID'
							, SO_ID                         NVARCHAR2(10)   PATH 'GENERAL/SO_ID'
							, SO_TITLE                      NVARCHAR2(50)   PATH 'GENERAL/SO_TITLE'
							, SO_ORG                        NVARCHAR2(50)   PATH 'GENERAL/SO_ORG'
							, XO_ID                         NVARCHAR2(32)   PATH 'GENERAL/XO_ID'
							, XO_TITLE                      NVARCHAR2(200)   PATH 'GENERAL/XO_TITLE'
							, XO_ORG                        NVARCHAR2(200)   PATH 'GENERAL/XO_ORG'
							, HRL_ID                        NVARCHAR2(10)   PATH 'GENERAL/HRL_ID'
							, HRL_TITLE                     NVARCHAR2(50)   PATH 'GENERAL/HRL_TITLE'
							, HRL_ORG                       NVARCHAR2(50)   PATH 'GENERAL/HRL_ORG'
							, SS_ID                         NVARCHAR2(10)   PATH 'GENERAL/SS_ID'
							, CS_ID                         NVARCHAR2(10)   PATH 'GENERAL/CS_ID'
							, SO_AGREE                      CHAR(1)         PATH 'if (GENERAL/SO_AGREE/text() = "true") then 1 else 0'
							, OTHER_CERT                    NVARCHAR2(200)  PATH 'GENERAL/OTHER_CERT'
							
							, CNDT_LAST_NM                  NVARCHAR2(50)   PATH 'POSITION/CNDT_LAST_NM'
							, CNDT_FIRST_NM                 NVARCHAR2(50)   PATH 'POSITION/CNDT_FIRST_NM'
							, CNDT_MIDDLE_NM                NVARCHAR2(50)   PATH 'POSITION/CNDT_MIDDLE_NM'
							, BGT_APR_OFM                   CHAR(1)         PATH 'POSITION/BGT_APR_OFM'
							, SPNSR_ORG_NM                  NVARCHAR2(140)  PATH 'POSITION/SPNSR_ORG_NM'
							, SPNSR_ORG_FUND_PC             NUMBER(3,0)     PATH 'POSITION/SPNSR_ORG_FUND_PC'
							, POS_TITLE                     NVARCHAR2(140)  PATH 'POSITION/POS_TITLE'
							, PAY_PLAN_ID                   VARCHAR2(140)   PATH 'POSITION/PAY_PLAN_ID'
							, SERIES                        VARCHAR2(140)   PATH 'POSITION/SERIES'
							, POS_DESC_NUMBER_1             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_1'
							, CLASSIFICATION_DT_1           DATE            PATH 'POSITION/CLASSIFICATION_DT_1'
							, GRADE_1                       VARCHAR2(2)     PATH 'POSITION/GRADE_1'
							, POS_DESC_NUMBER_2             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_2'
							, CLASSIFICATION_DT_2           DATE            PATH 'POSITION/CLASSIFICATION_DT_2'
							, GRADE_2                       VARCHAR2(2)     PATH 'POSITION/GRADE_2'
							, POS_DESC_NUMBER_3             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_3'
							, CLASSIFICATION_DT_3           DATE            PATH 'POSITION/CLASSIFICATION_DT_3'
							, GRADE_3                       VARCHAR2(2)     PATH 'POSITION/GRADE_3'
							, POS_DESC_NUMBER_4             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_4'
							, CLASSIFICATION_DT_4           DATE            PATH 'POSITION/CLASSIFICATION_DT_4'
							, GRADE_4                       VARCHAR2(2)     PATH 'POSITION/GRADE_4'
							, POS_DESC_NUMBER_5             VARCHAR2(20)    PATH 'POSITION/POS_DESC_NUMBER_5'
							, CLASSIFICATION_DT_5           DATE            PATH 'POSITION/CLASSIFICATION_DT_5'
							, GRADE_5                       VARCHAR2(2)     PATH 'POSITION/GRADE_5'
							, MED_OFFICERS_ID               NUMBER(20)      PATH 'POSITION/MED_OFFICERS_ID'
							, PERFORMANCE_LEVEL             NVARCHAR2(2)    PATH 'POSITION/PERFORMANCE_LEVEL'
							, SUPERVISORY                   NUMBER(20)      PATH 'POSITION/SUPERVISORY'
							, SKILL                         NVARCHAR2(200)  PATH 'POSITION/SKILL'
							, LOCATION                      NVARCHAR2(2000) PATH 'POSITION/LOCATION'
							, VACANCIES                     NUMBER(9)       PATH 'POSITION/VACANCIES'
							, REPORT_SUPERVISOR             NVARCHAR2(10)   PATH 'POSITION/REPORT_SUPERVISOR'
							, CAN                           NVARCHAR2(8)    PATH 'POSITION/CAN'
							, VICE                          CHAR(1)         PATH 'POSITION/VICE'
							, VICE_NAME                     NVARCHAR2(50)   PATH 'POSITION/VICE_NAME'
							, DAYS_ADVERTISED               NVARCHAR2(50)   PATH 'POSITION/DAYS_ADVERTISED'
							, TA_ID                         NUMBER(20)      PATH 'POSITION/TA_ID'
							, NTE                           NVARCHAR2(140)  PATH 'POSITION/NTE'
							, WORK_SCHED_ID                 NUMBER(20)      PATH 'POSITION/WORK_SCHED_ID'
							, HOURS_PER_WEEK                NVARCHAR2(50)   PATH 'POSITION/HOURS_PER_WEEK'
							, DUAL_EMPLMT                   NVARCHAR2(10)   PATH 'POSITION/DUAL_EMPLMT'
							, SEC_ID                        NUMBER(20)      PATH 'POSITION/SEC_ID'
							, CE_FINANCIAL_DISC             CHAR(1)         PATH 'if (POSITION/CE_FINANCIAL_DISC/text() = "true") then 1 else 0'
							, CE_FINANCIAL_TYPE_ID          NUMBER(20)      PATH 'POSITION/CE_FINANCIAL_TYPE_ID'
							, CE_PE_PHYSICAL                CHAR(1)         PATH 'if (POSITION/CE_PE_PHYSICAL/text() = "true") then 1 else 0'
							, CE_DRUG_TEST                  CHAR(1)         PATH 'if (POSITION/CE_DRUG_TEST/text() = "true") then 1 else 0'
							, CE_IMMUN                      CHAR(1)         PATH 'if (POSITION/CE_IMMUN/text() = "true") then 1 else 0'
							, CE_TRAVEL                     CHAR(1)         PATH 'if (POSITION/CE_TRAVEL/text() = "true") then 1 else 0'
							, CE_TRAVEL_PER                 NVARCHAR2(3)    PATH 'POSITION/CE_TRAVEL_PER'
							, CE_LIC                        CHAR(1)         PATH 'if (POSITION/CE_LIC/text() = "true") then 1 else 0'
							, CE_LIC_INFO                   NVARCHAR2(140)  PATH 'POSITION/CE_LIC_INFO'
							, REMARKS                       NVARCHAR2(500)  PATH 'POSITION/REMARKS'
							, PROC_REQ_TYPE                 NUMBER(20)      PATH 'POSITION/PROC_REQ_TYPE'
							, RECRUIT_OFFICE_ID             NUMBER(20)      PATH 'POSITION/RECRUIT_OFFICE_ID'
							, REQ_CREATE_NOTIFY_DT          DATE            PATH 'POSITION/REQ_CREATE_NOTIFY_DT'
							, ASSOC_DESCR_NUMBERS           NVARCHAR2(100)  PATH 'POSITION/ASSOC_DESCR_NUMBERS'
							, PROMOTE_POTENTIAL             NUMBER(2)       PATH 'POSITION/PROMOTE_POTENTIAL'
							, VICE_EMPL_ID                  NVARCHAR2(25)   PATH 'POSITION/VICE_EMPL_ID'
							, SR_ID                         NUMBER(20)      PATH 'POSITION/SR_ID'
							, GR_ID                         NUMBER(20)      PATH 'POSITION/GR_ID'
							, GA_1                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_1/text() = "true") then 1 else 0'
							, GA_2                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_2/text() = "true") then 1 else 0'
							, GA_3                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_3/text() = "true") then 1 else 0'
							, GA_4                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_4/text() = "true") then 1 else 0'
							, GA_5                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_5/text() = "true") then 1 else 0'
							, GA_6                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_6/text() = "true") then 1 else 0'
							, GA_7                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_7/text() = "true") then 1 else 0'
							, GA_8                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_8/text() = "true") then 1 else 0'
							, GA_9                          CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_9/text() = "true") then 1 else 0'
							, GA_10                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_10/text() = "true") then 1 else 0'
							, GA_11                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_11/text() = "true") then 1 else 0'
							, GA_12                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_12/text() = "true") then 1 else 0'
							, GA_13                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_13/text() = "true") then 1 else 0'
							, GA_14                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_14/text() = "true") then 1 else 0'
							, GA_15                         CHAR(1)         PATH 'if (POSITION/GRADE_ADVERTISED/GA_15/text() = "true") then 1 else 0'

							, CNDT_ELIGIBLE                 NVARCHAR2(10)   PATH 'REVIEW/CNDT_ELIGIBLE'
							, INELIG_REASON                 NUMBER(20,0)    PATH 'REVIEW/INELIG_REASON'
							, CNDT_QUALIFIED                NVARCHAR2(10)   PATH 'REVIEW/CNDT_QUALIFIED'
							, DISQUAL_REASON                NUMBER(20,0)    PATH 'REVIEW/DISQUAL_REASON'

							, SEL_DETERM                    NUMBER(20,0)    PATH 'SELECTION/SEL_DETERM'
							
							, DCO_CERT                      NVARCHAR2(10)   PATH 'APPROVAL/DCO_CERT'
							, DCO_NAME                      NVARCHAR2(100)  PATH 'APPROVAL/DCO_NAME'
							, DCO_SIG                       NVARCHAR2(100)  PATH 'APPROVAL/DCO_SIG'
							, DCO_SIG_DT                    DATE            PATH 'APPROVAL/DCO_SIG_DT'
					) X
				WHERE FD.PROCID = I_PROCID
			) SRC ON (SRC.REQ_ID = TRG.REQ_ID)
			WHEN MATCHED THEN UPDATE SET
				TRG.PROCID       = SRC.PROCID

				, TRG.ADMIN_CD   = SRC.ADMIN_CD
				, TRG.RT_ID      = SRC.RT_ID
				, TRG.CT_ID      = SRC.CT_ID
				, TRG.AT_ID      = SRC.AT_ID
				, TRG.VT_ID      = SRC.VT_ID
				, TRG.SAT_ID     = SRC.SAT_ID
				, TRG.SO_ID      = SRC.SO_ID
				, TRG.SO_TITLE   = SRC.SO_TITLE
				, TRG.SO_ORG     = SRC.SO_ORG
				, TRG.XO_ID      = SRC.XO_ID
				, TRG.XO_TITLE   = SRC.XO_TITLE
				, TRG.XO_ORG     = SRC.XO_ORG
				, TRG.HRL_ID     = SRC.HRL_ID
				, TRG.HRL_TITLE  = SRC.HRL_TITLE
				, TRG.HRL_ORG    = SRC.HRL_ORG
				, TRG.SS_ID      = SRC.SS_ID
				, TRG.CS_ID      = SRC.CS_ID
				, TRG.SO_AGREE   = SRC.SO_AGREE
				, TRG.OTHER_CERT = SRC.OTHER_CERT

				, TRG.CNDT_LAST_NM          = SRC.CNDT_LAST_NM
				, TRG.CNDT_FIRST_NM         = SRC.CNDT_FIRST_NM
				, TRG.CNDT_MIDDLE_NM        = SRC.CNDT_MIDDLE_NM
				, TRG.BGT_APR_OFM           = SRC.BGT_APR_OFM
				, TRG.SPNSR_ORG_NM          = SRC.SPNSR_ORG_NM
				, TRG.SPNSR_ORG_FUND_PC     = SRC.SPNSR_ORG_FUND_PC
				, TRG.POS_TITLE             = SRC.POS_TITLE
				, TRG.PAY_PLAN_ID           = SRC.PAY_PLAN_ID
				, TRG.SERIES                = SRC.SERIES
				, TRG.POS_DESC_NUMBER_1     = SRC.POS_DESC_NUMBER_1
				, TRG.CLASSIFICATION_DT_1   = SRC.CLASSIFICATION_DT_1
				, TRG.GRADE_1               = SRC.GRADE_1
				, TRG.POS_DESC_NUMBER_2     = SRC.POS_DESC_NUMBER_2
				, TRG.CLASSIFICATION_DT_2   = SRC.CLASSIFICATION_DT_2
				, TRG.GRADE_2               = SRC.GRADE_2
				, TRG.POS_DESC_NUMBER_3     = SRC.POS_DESC_NUMBER_3
				, TRG.CLASSIFICATION_DT_3   = SRC.CLASSIFICATION_DT_3
				, TRG.GRADE_3               = SRC.GRADE_3
				, TRG.POS_DESC_NUMBER_4     = SRC.POS_DESC_NUMBER_4
				, TRG.CLASSIFICATION_DT_4   = SRC.CLASSIFICATION_DT_4
				, TRG.GRADE_4               = SRC.GRADE_4
				, TRG.POS_DESC_NUMBER_5     = SRC.POS_DESC_NUMBER_5
				, TRG.CLASSIFICATION_DT_5   = SRC.CLASSIFICATION_DT_5
				, TRG.GRADE_5               = SRC.GRADE_5
				, TRG.MED_OFFICERS_ID       = SRC.MED_OFFICERS_ID
				, TRG.PERFORMANCE_LEVEL     = SRC.PERFORMANCE_LEVEL
				, TRG.SUPERVISORY           = SRC.SUPERVISORY
				, TRG.SKILL                 = SRC.SKILL
				, TRG.LOCATION              = SRC.LOCATION
				, TRG.VACANCIES             = SRC.VACANCIES
				, TRG.REPORT_SUPERVISOR     = SRC.REPORT_SUPERVISOR
				, TRG.CAN                   = SRC.CAN
				, TRG.VICE                  = SRC.VICE
				, TRG.VICE_NAME             = SRC.VICE_NAME
				, TRG.DAYS_ADVERTISED       = SRC.DAYS_ADVERTISED
				, TRG.TA_ID                 = SRC.TA_ID
				, TRG.NTE                   = SRC.NTE
				, TRG.WORK_SCHED_ID         = SRC.WORK_SCHED_ID
				, TRG.HOURS_PER_WEEK        = SRC.HOURS_PER_WEEK
				, TRG.DUAL_EMPLMT           = SRC.DUAL_EMPLMT
				, TRG.SEC_ID                = SRC.SEC_ID
				, TRG.CE_FINANCIAL_DISC     = SRC.CE_FINANCIAL_DISC
				, TRG.CE_FINANCIAL_TYPE_ID  = SRC.CE_FINANCIAL_TYPE_ID
				, TRG.CE_PE_PHYSICAL        = SRC.CE_PE_PHYSICAL
				, TRG.CE_DRUG_TEST          = SRC.CE_DRUG_TEST
				, TRG.CE_IMMUN              = SRC.CE_IMMUN
				, TRG.CE_TRAVEL             = SRC.CE_TRAVEL
				, TRG.CE_TRAVEL_PER         = SRC.CE_TRAVEL_PER
				, TRG.CE_LIC                = SRC.CE_LIC
				, TRG.CE_LIC_INFO           = SRC.CE_LIC_INFO
				, TRG.REMARKS               = SRC.REMARKS
				, TRG.PROC_REQ_TYPE         = SRC.PROC_REQ_TYPE
				, TRG.RECRUIT_OFFICE_ID     = SRC.RECRUIT_OFFICE_ID
				, TRG.REQ_CREATE_NOTIFY_DT  = SRC.REQ_CREATE_NOTIFY_DT
				, TRG.ASSOC_DESCR_NUMBERS   = SRC.ASSOC_DESCR_NUMBERS
				, TRG.PROMOTE_POTENTIAL     = SRC.PROMOTE_POTENTIAL
				, TRG.VICE_EMPL_ID          = SRC.VICE_EMPL_ID
				, TRG.SR_ID                 = SRC.SR_ID
				, TRG.GR_ID                 = SRC.GR_ID
				, TRG.GA_1                  = SRC.GA_1
				, TRG.GA_2                  = SRC.GA_2
				, TRG.GA_3                  = SRC.GA_3
				, TRG.GA_4                  = SRC.GA_4
				, TRG.GA_5                  = SRC.GA_5
				, TRG.GA_6                  = SRC.GA_6
				, TRG.GA_7                  = SRC.GA_7
				, TRG.GA_8                  = SRC.GA_8
				, TRG.GA_9                  = SRC.GA_9
				, TRG.GA_10                 = SRC.GA_10
				, TRG.GA_11                 = SRC.GA_11
				, TRG.GA_12                 = SRC.GA_12
				, TRG.GA_13                 = SRC.GA_13
				, TRG.GA_14                 = SRC.GA_14
				, TRG.GA_15                 = SRC.GA_15
				
				, TRG.CNDT_ELIGIBLE         = SRC.CNDT_ELIGIBLE
				, TRG.INELIG_REASON         = SRC.INELIG_REASON
				, TRG.CNDT_QUALIFIED        = SRC.CNDT_QUALIFIED
				, TRG.DISQUAL_REASON        = SRC.DISQUAL_REASON

				, TRG.SEL_DETERM            = SRC.SEL_DETERM
				
				, TRG.DCO_CERT              = SRC.DCO_CERT
				, TRG.DCO_NAME              = SRC.DCO_NAME
				, TRG.DCO_SIG               = SRC.DCO_SIG
				, TRG.DCO_SIG_DT            = SRC.DCO_SIG_DT

			WHEN NOT MATCHED THEN INSERT
			(
				TRG.REQ_ID
				, TRG.PROCID

				, TRG.ADMIN_CD
				, TRG.RT_ID
				, TRG.CT_ID
				, TRG.AT_ID
				, TRG.VT_ID
				, TRG.SAT_ID
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
				, TRG.SO_AGREE
				, TRG.OTHER_CERT
				
				, TRG.CNDT_LAST_NM
				, TRG.CNDT_FIRST_NM
				, TRG.CNDT_MIDDLE_NM
				, TRG.BGT_APR_OFM
				, TRG.SPNSR_ORG_NM
				, TRG.SPNSR_ORG_FUND_PC
				, TRG.POS_TITLE
				, TRG.PAY_PLAN_ID
				, TRG.SERIES
				, TRG.POS_DESC_NUMBER_1
				, TRG.CLASSIFICATION_DT_1
				, TRG.GRADE_1
				, TRG.POS_DESC_NUMBER_2
				, TRG.CLASSIFICATION_DT_2
				, TRG.GRADE_2
				, TRG.POS_DESC_NUMBER_3
				, TRG.CLASSIFICATION_DT_3
				, TRG.GRADE_3
				, TRG.POS_DESC_NUMBER_4
				, TRG.CLASSIFICATION_DT_4
				, TRG.GRADE_4
				, TRG.POS_DESC_NUMBER_5
				, TRG.CLASSIFICATION_DT_5
				, TRG.GRADE_5
				, TRG.MED_OFFICERS_ID
				, TRG.PERFORMANCE_LEVEL
				, TRG.SUPERVISORY
				, TRG.SKILL
				, TRG.LOCATION
				, TRG.VACANCIES
				, TRG.REPORT_SUPERVISOR
				, TRG.CAN
				, TRG.VICE
				, TRG.VICE_NAME
				, TRG.DAYS_ADVERTISED
				, TRG.TA_ID
				, TRG.NTE
				, TRG.WORK_SCHED_ID
				, TRG.HOURS_PER_WEEK
				, TRG.DUAL_EMPLMT
				, TRG.SEC_ID
				, TRG.CE_FINANCIAL_DISC
				, TRG.CE_FINANCIAL_TYPE_ID
				, TRG.CE_PE_PHYSICAL
				, TRG.CE_DRUG_TEST
				, TRG.CE_IMMUN
				, TRG.CE_TRAVEL
				, TRG.CE_TRAVEL_PER
				, TRG.CE_LIC
				, TRG.CE_LIC_INFO
				, TRG.REMARKS
				, TRG.PROC_REQ_TYPE
				, TRG.RECRUIT_OFFICE_ID
				, TRG.REQ_CREATE_NOTIFY_DT
				, TRG.ASSOC_DESCR_NUMBERS
				, TRG.PROMOTE_POTENTIAL
				, TRG.VICE_EMPL_ID
				, TRG.SR_ID
				, TRG.GR_ID
				, TRG.GA_1
				, TRG.GA_2
				, TRG.GA_3
				, TRG.GA_4
				, TRG.GA_5
				, TRG.GA_6
				, TRG.GA_7
				, TRG.GA_8
				, TRG.GA_9
				, TRG.GA_10
				, TRG.GA_11
				, TRG.GA_12
				, TRG.GA_13
				, TRG.GA_14
				, TRG.GA_15
				
				, TRG.CNDT_ELIGIBLE
				, TRG.INELIG_REASON
				, TRG.CNDT_QUALIFIED
				, TRG.DISQUAL_REASON

				, TRG.SEL_DETERM
				
				, TRG.DCO_CERT
				, TRG.DCO_NAME
				, TRG.DCO_SIG
				, TRG.DCO_SIG_DT
			)
			VALUES
			(
				SRC.REQ_ID
				, SRC.PROCID

				, SRC.ADMIN_CD
				, SRC.RT_ID
				, SRC.CT_ID
				, SRC.AT_ID
				, SRC.VT_ID
				, SRC.SAT_ID
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
				, SRC.SO_AGREE
				, SRC.OTHER_CERT

				, SRC.CNDT_LAST_NM
				, SRC.CNDT_FIRST_NM
				, SRC.CNDT_MIDDLE_NM
				, SRC.BGT_APR_OFM
				, SRC.SPNSR_ORG_NM
				, SRC.SPNSR_ORG_FUND_PC
				, SRC.POS_TITLE
				, SRC.PAY_PLAN_ID
				, SRC.SERIES
				, SRC.POS_DESC_NUMBER_1
				, SRC.CLASSIFICATION_DT_1
				, SRC.GRADE_1
				, SRC.POS_DESC_NUMBER_2
				, SRC.CLASSIFICATION_DT_2
				, SRC.GRADE_2
				, SRC.POS_DESC_NUMBER_3
				, SRC.CLASSIFICATION_DT_3
				, SRC.GRADE_3
				, SRC.POS_DESC_NUMBER_4
				, SRC.CLASSIFICATION_DT_4
				, SRC.GRADE_4
				, SRC.POS_DESC_NUMBER_5
				, SRC.CLASSIFICATION_DT_5
				, SRC.GRADE_5
				, SRC.MED_OFFICERS_ID
				, SRC.PERFORMANCE_LEVEL
				, SRC.SUPERVISORY
				, SRC.SKILL
				, SRC.LOCATION
				, SRC.VACANCIES
				, SRC.REPORT_SUPERVISOR
				, SRC.CAN
				, SRC.VICE
				, SRC.VICE_NAME
				, SRC.DAYS_ADVERTISED
				, SRC.TA_ID
				, SRC.NTE
				, SRC.WORK_SCHED_ID
				, SRC.HOURS_PER_WEEK
				, SRC.DUAL_EMPLMT
				, SRC.SEC_ID
				, SRC.CE_FINANCIAL_DISC
				, SRC.CE_FINANCIAL_TYPE_ID
				, SRC.CE_PE_PHYSICAL
				, SRC.CE_DRUG_TEST
				, SRC.CE_IMMUN
				, SRC.CE_TRAVEL
				, SRC.CE_TRAVEL_PER
				, SRC.CE_LIC
				, SRC.CE_LIC_INFO
				, SRC.REMARKS
				, SRC.PROC_REQ_TYPE
				, SRC.RECRUIT_OFFICE_ID
				, SRC.REQ_CREATE_NOTIFY_DT
				, SRC.ASSOC_DESCR_NUMBERS
				, SRC.PROMOTE_POTENTIAL
				, SRC.VICE_EMPL_ID
				, SRC.SR_ID
				, SRC.GR_ID
				, SRC.GA_1
				, SRC.GA_2
				, SRC.GA_3
				, SRC.GA_4
				, SRC.GA_5
				, SRC.GA_6
				, SRC.GA_7
				, SRC.GA_8
				, SRC.GA_9
				, SRC.GA_10
				, SRC.GA_11
				, SRC.GA_12
				, SRC.GA_13
				, SRC.GA_14
				, SRC.GA_15
				
				, SRC.CNDT_ELIGIBLE
				, SRC.INELIG_REASON
				, SRC.CNDT_QUALIFIED
				, SRC.DISQUAL_REASON

				, SRC.SEL_DETERM
				
				, SRC.DCO_CERT
				, SRC.DCO_NAME
				, SRC.DCO_SIG
				, SRC.DCO_SIG_DT
			)
			;

		EXCEPTION
			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR(-20905, 'SP_UPDATE_ELIGQUAL_TABLE: Invalid ELIGQUAL data.  I_PROCID = '
					|| TO_CHAR(I_PROCID) || ' V_JOB_REQ_NUM = ' || V_JOB_REQ_NUM || '  V_JOB_REQ_ID = ' || TO_CHAR(V_JOB_REQ_ID));
		END;

		--DBMS_OUTPUT.PUT_LINE('SP_UPDATE_ELIGQUAL_TABLE - END ==========================');

	END IF;

EXCEPTION
	WHEN E_INVALID_PROCID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Process ID is not valid');
	WHEN E_INVALID_JOB_REQ_ID THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Job Request ID is not valid');
	WHEN E_INVALID_STRATCON_DATA THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('ERROR message = ' || 'Invalid data');
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		V_ERRCODE := SQLCODE;
		V_ERRMSG := SQLERRM;
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing SP_UPDATE_ELIGQUAL_TABLE -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || V_ERRCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || V_ERRMSG);
END;