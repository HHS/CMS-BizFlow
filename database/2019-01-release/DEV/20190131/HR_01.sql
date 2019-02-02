CREATE OR REPLACE VIEW VW_ERLR_GEN
AS
SELECT
    EG.ERLR_CASE_NUMBER
    , EC.ERLR_JOB_REQ_NUMBER
    , EC.PROCID    
    , EC.ERLR_CASE_CREATE_DT
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EG.GEN_PRIMARY_SPECIALIST AND ROWNUM = 1)  AS GEN_PRIMARY_SPECIALIST_NAME	
	, (SELECT M.NAME FROM BIZFLOW.MEMBER M WHERE M.MEMBERID = EG.GEN_SECONDARY_SPECIALIST AND ROWNUM = 1)  AS GEN_SECONDARY_SPECIALIST_NAME
	, EG.GEN_CUSTOMER_NAME
	, EG.GEN_CUSTOMER_PHONE
	, EG.GEN_CUSTOMER_ADMIN_CD
	, EG.GEN_CUSTOMER_ADMIN_CD_DESC
	, EG.GEN_EMPLOYEE_NAME
	, EG.GEN_EMPLOYEE_PHONE
	, EG.GEN_EMPLOYEE_ADMIN_CD
	, EG.GEN_EMPLOYEE_ADMIN_CD_DESC
	, FN_GET_2ND_SUB_ORG(EG.GEN_EMPLOYEE_ADMIN_CD) AS GEN_EMPLOYEE_2ND_SUB_ORG
	, EG.GEN_CASE_DESC
	, EG.GEN_CASE_STATUS
	, EG.GEN_CUST_INIT_CONTACT_DT
	, EG.GEN_PRIMARY_REP_AFFILIATION
	, EG.GEN_CMS_PRIMARY_REP_ID AS GEN_CMS_PRIMARY_REP_NAME
	, EG.GEN_CMS_PRIMARY_REP_PHONE
	, EG.GEN_NON_CMS_PRIMARY_FNAME
	, EG.GEN_NON_CMS_PRIMARY_MNAME
	, EG.GEN_NON_CMS_PRIMARY_LNAME
	, EG.GEN_NON_CMS_PRIMARY_EMAIL
	, EG.GEN_NON_CMS_PRIMARY_PHONE
	, EG.GEN_NON_CMS_PRIMARY_ORG
	, EG.GEN_NON_CMS_PRIMARY_ADDR
	, (SELECT L.TBL_LABEL FROM TBL_LOOKUP L WHERE L.TBL_ID = EG.GEN_CASE_TYPE AND ROWNUM = 1) AS GEN_CASE_TYPE
	, FN_GET_CASE_CATEGORY(EG.GEN_CASE_CATEGORY) AS GEN_CASE_CATEGORY
	, EG.GEN_INVESTIGATION
	, EG.GEN_INVESTIGATE_START_DT
	, EG.GEN_INVESTIGATE_END_DT
	, EG.GEN_STD_CONDUCT
	, GEN_STD_CONDUCT_TYPE
	, CC_FINAL_ACTION
	, EG.CC_CASE_COMPLETE_DT
	, (SELECT STATE FROM BIZFLOW.PROCS P WHERE P.PROCID = EC.PROCID) AS BF_PROCS_STATE
	, ETPH.THRD_PRTY_APPEAL_TYPE
FROM
	ERLR_GEN EG
    LEFT OUTER JOIN ERLR_CASE EC ON EG.ERLR_CASE_NUMBER = EC.ERLR_CASE_NUMBER
	LEFT OUTER JOIN ERLR_3RDPARTY_HEAR ETPH ON EG.ERLR_CASE_NUMBER = ETPH.ERLR_CASE_NUMBER
;
/

create or replace PROCEDURE SP_UPDATE_PV_ERLR
  (
      I_PROCID            IN      NUMBER
    , I_FIELD_DATA      IN      XMLTYPE
  )
IS
  V_RLVNTDATANAME        VARCHAR2(100);
  V_VALUE                NVARCHAR2(2000);
  V_VALUE_LOOKUP         NVARCHAR2(2000);
  V_CURRENTDATE          DATE;
  V_CURRENTDATESTR       NVARCHAR2(30);
  V_VALUE_DATE           DATE;
  V_VALUE_DATESTR        NVARCHAR2(30);
  V_XMLVALUE             XMLTYPE;
  V_REQUEST_NUMBER       VARCHAR2(20);
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
    --DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
    --DBMS_OUTPUT.PUT_LINE(' ----------------');

    IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
      --DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

      --SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseCategory', '/formData/items/item[id=''CASE_CATEGORY'']/value/text()');
      V_RLVNTDATANAME := 'caseCategory';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_CATEGORY'']/value/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with lookup value
        ---------------------------------
        BEGIN
          -- Case Category is multi-select value, thus multi-value concatenation required
          --SELECT TBL_LABEL INTO V_VALUE_LOOKUP
          --FROM TBL_LOOKUP
          --WHERE TBL_ID = TO_NUMBER(V_VALUE);
          SELECT FN_GET_LOOKUP_DSCR(V_VALUE) INTO V_VALUE_LOOKUP
          FROM DUAL;
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

      --SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseStatus', '/formData/items/item[id=''CASE_STATUS'']/value/text()');
      V_RLVNTDATANAME := 'caseStatus';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_STATUS'']/value/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      --SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseType', '/formData/items/item[id=''CASE_TYPE'']/value/text()');
      V_RLVNTDATANAME := 'caseType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_TYPE'']/value/text()');
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
        
        --- set requestNum ------
        SELECT VALUE INTO V_REQUEST_NUMBER 
          FROM BIZFLOW.RLVNTDATA 
         WHERE RLVNTDATANAME = 'requestNum' 
           AND PROCID = I_PROCID;
        IF V_REQUEST_NUMBER IS NULL THEN
            GET_REQUEST_NUM (V_REQUEST_NUMBER);
            UPDATE BIZFLOW.RLVNTDATA 
               SET VALUE = V_REQUEST_NUMBER
             WHERE RLVNTDATANAME = 'requestNum' 
               AND PROCID = I_PROCID;
        END IF;        
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'contactName', '/formData/items/item[id=''GEN_CUSTOMER_NAME'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'employeeName', '/formData/items/item[id=''GEN_EMPLOYEE_NAME'']/value/text()');


      --SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'initialContactDate', '/formData/items/item[id=''CUSTOMER_CONTACT_DT'']/value/text()');
      V_RLVNTDATANAME := 'initialContactDate';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CUST_INIT_CONTACT_DT'']/value/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- date format and GMT conversion
        -------------------------------------
        V_VALUE := TO_CHAR(SYS_EXTRACT_UTC(TO_DATE(V_VALUE, 'MM/DD/YYYY')), 'YYYY/MM/DD HH24:MI:SS');
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      UPDATE BIZFLOW.RLVNTDATA SET VALUE = TO_CHAR((sys_extract_utc(systimestamp)), 'YYYY/MM/DD HH24:MI:SS') WHERE RLVNTDATANAME = 'lastModifiedDate' AND PROCID = I_PROCID;


      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'organization',           '/formData/items/item[id=''GEN_EMPLOYEE_ADMIN_CD'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'primaryDWCSpecialist',   '/formData/items/item[id=''GEN_PRIMARY_SPECIALIST'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'reassign',               '/formData/items/item[id=''reassign'']/value/text()');      
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestStatusDate',      '/formData/items/item[id=''REQ_STATUS_DT'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'secondaryDWCSpecialist', '/formData/items/item[id=''GEN_SECONDARY_SPECIALIST'']/value/text()');

      --DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_ERLR -------------------');
  END;
  /

CREATE OR REPLACE FUNCTION FN_GET_2ND_SUB_ORG
(
	I_ADMIN_CD IN  VARCHAR2	
)
RETURN VARCHAR2
IS
	V_RETURN_VAL    VARCHAR2(300);
	V_VALUE  VARCHAR2(30);	
    V_VALUE2 VARCHAR2(30);
    V_ORG_NAME  VARCHAR2(255);    
BEGIN
    --DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_2ND_SUB_ORG -------');
    --DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
    --DBMS_OUTPUT.PUT_LINE('    I_ADMIN_CD         = ' || I_ADMIN_CD );

    SELECT SUBSTR(I_ADMIN_CD, 1, 2) INTO V_VALUE FROM DUAL;
    IF V_VALUE != 'FC' THEN    
        V_RETURN_VAL := 'N/A';
    ELSE
        SELECT SUBSTR(I_ADMIN_CD, 3, 1) INTO V_VALUE FROM DUAL;
        CASE V_VALUE
            WHEN 'C' THEN V_RETURN_VAL := 'FCC';
            WHEN 'E' THEN V_RETURN_VAL := 'FCE';
            WHEN 'F' THEN V_RETURN_VAL := 'FCF';
            WHEN 'G' THEN V_RETURN_VAL := 'FCG';
            WHEN 'H' THEN V_RETURN_VAL := 'FCH';
            WHEN 'J' THEN V_RETURN_VAL := 'FCJ';
            WHEN 'L' THEN V_RETURN_VAL := 'FCL';
            WHEN 'M' THEN 
                SELECT SUBSTR(I_ADMIN_CD, 4, 1) INTO V_VALUE2 FROM DUAL;
                CASE V_VALUE2
                    WHEN 'B' THEN V_RETURN_VAL := 'FCMB';
                    WHEN 'C' THEN V_RETURN_VAL := 'FCMC';
                    WHEN 'G' THEN V_RETURN_VAL := 'FCMG';
                    WHEN 'H' THEN V_RETURN_VAL := 'FCMH';
                    WHEN 'J' THEN V_RETURN_VAL := 'FCMJ';
                    WHEN 'K' THEN V_RETURN_VAL := 'FCMK';
                    WHEN 'N' THEN V_RETURN_VAL := 'FCMN';
                    WHEN 'P' THEN V_RETURN_VAL := 'FCMP';
                    WHEN 'Q' THEN V_RETURN_VAL := 'FCMQ'; 
                END CASE;
            WHEN 'N' THEN V_RETURN_VAL := 'FCN';
            WHEN 'P' THEN V_RETURN_VAL := 'FCP';
            WHEN 'Q' THEN V_RETURN_VAL := 'FCQ';
            WHEN 'R' THEN V_RETURN_VAL := 'FCR';
            WHEN 'S' THEN V_RETURN_VAL := 'FCS';
            WHEN 'T' THEN V_RETURN_VAL := 'FCT';
            WHEN 'V' THEN V_RETURN_VAL := 'FCV';
            WHEN 'W' THEN V_RETURN_VAL := 'FCW';
            WHEN 'X' THEN V_RETURN_VAL := 'FCX';
            ELSE
                V_RETURN_VAL := 'N/A';    
         END CASE;         
    END IF;
    IF V_RETURN_VAL != 'N/A' THEN
      SELECT AC_ADMIN_CD_DESCR INTO V_ORG_NAME FROM ADMIN_CODES WHERE AC_ADMIN_CD = V_RETURN_VAL;              
      V_RETURN_VAL := V_RETURN_VAL || ' - ' || V_ORG_NAME;
    END IF;
    
    RETURN V_RETURN_VAL;
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_2ND_SUB_ORG -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
END;
/

/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * the Incentives process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_PV_INCENTIVES
	(
		  I_PROCID            IN      NUMBER
		, I_FIELD_DATA      IN      XMLTYPE
	)
IS
	V_XMLVALUE             XMLTYPE;
	V_INCENTIVE_TYPE     NVARCHAR2(50);

	BEGIN
		--DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
		--DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
		--DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
		--DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
		--DBMS_OUTPUT.PUT_LINE(' ----------------');

		IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
			--DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestNumber', '/formData/items/item[id="associatedNEILRequest"]/value/requestNumber/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestDate', '/formData/items/item[id="requestDate"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'administrativeCode', '/formData/items/item[id="administrativeCode"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'associatedIncentives', '/formData/items/item[id="associatedIncentives"]/value/requestNumber/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'candidateName', '/formData/items/item[id="candidateName"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrSpecialist', '/formData/items/item[id="hrSpecialist"]/value/participantId/text()', '/formData/items/item[id="hrSpecialist"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'incentiveType', '/formData/items/item[id="incentiveType"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'payPlanSeriesGrade', '/formData/items/item[id="payPlanSeriesGrade"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'positionTitle', '/formData/items/item[id="positionTitle"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'componentUserIds', '/formData/items/item[id="componentUserIds"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'relatedUserIds', '/formData/items/item[id="relatedUserIds"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'selectingOfficial', '/formData/items/item[id="selectingOfficial"]/value/participantId/text()', '/formData/items/item[id="selectingOfficial"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'pcaType', '/formData/items/item[id="pcaType"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'candidateAccept', '/formData/items/item[id="candiAgreeRenewal"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requesterRole', '/formData/items/item[id="requesterRole"]/value/text()');

			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'execOfficer', '/formData/items/item[id="executiveOfficers"]/value[1]/participantId/text()', '/formData/items/item[id="executiveOfficers"]/value[1]/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'execOfficer2', '/formData/items/item[id="executiveOfficers"]/value[2]/participantId/text()', '/formData/items/item[id="executiveOfficers"]/value[2]/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'execOfficer3', '/formData/items/item[id="executiveOfficers"]/value[3]/participantId/text()', '/formData/items/item[id="executiveOfficers"]/value[3]/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrLiaison', '/formData/items/item[id="hrLiaisons"]/value[1]/participantId/text()', '/formData/items/item[id="hrLiaisons"]/value[1]/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrLiaison2', '/formData/items/item[id="hrLiaisons"]/value[2]/participantId/text()', '/formData/items/item[id="hrLiaisons"]/value[2]/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrLiaison3', '/formData/items/item[id="hrLiaisons"]/value[3]/participantId/text()', '/formData/items/item[id="hrLiaisons"]/value[3]/name/text()');

			V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id="incentiveType"]/value/text()');
			IF V_XMLVALUE IS NOT NULL THEN
				V_INCENTIVE_TYPE := V_XMLVALUE.GETSTRINGVAL();
			ELSE
				V_INCENTIVE_TYPE := NULL;
			END IF;

			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'oaApprovalReq', '/formData/items/item[id="requireAdminApproval"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcApprovalReq', '/formData/items/item[id="requireOHCApproval"]/value/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'dgoDirector', '/formData/items/item[id="dghoDirector"]/value/participantId/text()', '/formData/items/item[id="dghoDirector"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'chiefMedicalOfficer', '/formData/items/item[id="chiefPhysician"]/value/participantId/text()', '/formData/items/item[id="chiefPhysician"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ofmDirector', '/formData/items/item[id="ofmDirector"]/value/participantId/text()', '/formData/items/item[id="ofmDirector"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgDirector', '/formData/items/item[id="tabgDirector"]/value/participantId/text()', '/formData/items/item[id="tabgDirector"]/value/name/text()');
			SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ofcAdmin', '/formData/items/item[id="offAdmin"]/value/participantId/text()', '/formData/items/item[id="offAdmin"]/value/name/text()');

			IF 'PCA' = V_INCENTIVE_TYPE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcDirector', '/formData/items/item[id="ohcDirector"]/value/participantId/text()', '/formData/items/item[id="ohcDirector"]/value/name/text()');
			ELSIF 'SAM' = V_INCENTIVE_TYPE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'samSupport', '/formData/items/item[id="supportSAM"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcDirector', '/formData/items/item[id="reviewRcmdApprovalOHCDirector"]/value/participantId/text()', '/formData/items/item[id="reviewRcmdApprovalOHCDirector"]/value/name/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgdApprove', '/formData/items/item[id="approvalDGHOValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgApprove', '/formData/items/item[id="approvalTABGValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'ohcApprove', '/formData/items/item[id="approvalOHCValue"]/value/text()');
                SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocDirector', '/formData/items/item[id="cocDirector"]/value/participantId/text()', '/formData/items/item[id="cocDirector"]/value/name/text()');
			ELSIF 'LE' = V_INCENTIVE_TYPE THEN
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'leSupport', '/formData/items/item[id="supportLE"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgdApprove', '/formData/items/item[id="leApprovalDGHOValue"]/value/text()');
				SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'tabgApprove', '/formData/items/item[id="leApprovalTABGValue"]/value/text()');
                SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cocDirector', '/formData/items/item[id="lecocDirector"]/value/participantId/text()', '/formData/items/item[id="lecocDirector"]/value/name/text()');
			END IF;

		--DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

		END IF;

		EXCEPTION
		WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_INCENTIVES -------------------');
	END;

/

Update ERLR_GEN SET GEN_CASE_STATUS = null;

ALTER TABLE 
   ERLR_GEN
MODIFY 
(    
   GEN_CASE_STATUS  NVARCHAR2(200)   
);

COMMENT ON COLUMN ERLR_GEN.GEN_CASE_STATUS IS 'Case status';

Update ERLR_CASE SET ERLR_CASE_STATUS_ID = null;

ALTER TABLE 
   ERLR_CASE
MODIFY 
(    
   ERLR_CASE_STATUS_ID  NVARCHAR2(200)   
);

COMMIT;
/


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
						<APPROVAL></APPROVAL>
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

/**
 * This script will detect deleted ER/LR BizFlow process from certain date
 * , and remove corresponding ER/LR database records.
 *
 * @param P_STARTDATE - From Date of deletion
 * @param P_DEBUG_FLAG - 'T': not delete, 'F': delete records permanently
 *

 Example to run the SP
        SET SERVEROUTPUT ON; 
        CALL HHS_CMS_HR.SP_ERLR_CLEAN_PROC_DATA (SYSDATE, 'F');
    
    Query to verify the result. change ERLR_CASE_NUMBER and  number
        SELECT count(1) as ERLR_3RDPARTY_HEAR FROM HHS_CMS_HR.ERLR_3RDPARTY_HEAR WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_APPEAL FROM HHS_CMS_HR.ERLR_APPEAL WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_CNDT_ISSUE FROM HHS_CMS_HR.ERLR_CNDT_ISSUE WHERE ERLR_CASE_NUMBER = 10000;    
        SELECT count(1) as ERLR_EMPLOYEE_CASE FROM HHS_CMS_HR.ERLR_EMPLOYEE_CASE WHERE (CASEID = 10000 OR FROM_CASEID = 10000);
        SELECT count(1) as ERLR_GEN FROM HHS_CMS_HR.ERLR_GEN WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_GRIEVANCE FROM HHS_CMS_HR.ERLR_GRIEVANCE WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_INFO_REQUEST FROM HHS_CMS_HR.ERLR_INFO_REQUEST WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_INVESTIGATION FROM HHS_CMS_HR.ERLR_INVESTIGATION WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_LABOR_NEGO FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_LABOR_NEGO FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_MEDDOC FROM HHS_CMS_HR.ERLR_MEDDOC WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_PERF_ISSUE FROM HHS_CMS_HR.ERLR_PERF_ISSUE WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_PROB_ACTION FROM HHS_CMS_HR.ERLR_PROB_ACTION WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_ULP FROM HHS_CMS_HR.ERLR_ULP WHERE ERLR_CASE_NUMBER = 10000;
        SELECT count(1) as ERLR_WGI_DNL FROM HHS_CMS_HR.ERLR_WGI_DNL WHERE ERLR_CASE_NUMBER = 10000;
        
        SELECT count(1) as TBL_FORM_DTL HHS_CMS_HR.TBL_FORM_DTL WHERE PROCID = 123456;
        SELECT count(1) as TBL_FORM_DTL_AUDIT HHS_CMS_HR.TBL_FORM_DTL_AUDIT WHERE PROCID = 123456;        
*/

CREATE OR REPLACE PROCEDURE SP_ERLR_CLEAN_PROC_DATA
(
    P_STARTDATE         DATE := SYSDATE
    ,P_DEBUG_FLAG       VARCHAR2 := 'F' --[ 'T' | 'F' ]
)
IS
    C_ERLR_CASE_NUMBER	    NUMBER(20,0);
    C_ERLR_JOB_REQ_NUMBER	NVARCHAR2(16 CHAR);
    C_PROCID	            NUMBER(20,0);
    C_ERLR_CASE_STATUS_ID	NUMBER(20,0);
    C_ERLR_CASE_CREATE_DT	DATE;
    
    CURSOR CUR_DELETED_ERLR_PROCESSES(ip_StartDate DATE)
    IS
        SELECT ERLR_CASE_NUMBER, ERLR_JOB_REQ_NUMBER, PROCID, ERLR_CASE_STATUS_ID, ERLR_CASE_CREATE_DT
          FROM HHS_CMS_HR.ERLR_CASE
         WHERE ERLR_CASE_CREATE_DT >= SYSDATE - 10000
           AND NOT EXISTS (
                SELECT *
                  FROM BIZFLOW.PROCS P
                 WHERE P.NAME = 'ER/LR Case Initiation'
                   AND HHS_CMS_HR.ERLR_CASE.PROCID = P.PROCID
           )
    ;
    
BEGIN
    
    --DBMS_OUTPUT.PUT_LINE('P_DEBUG_FLAG=' || P_DEBUG_FLAG || ', P_STARTDATE=' || TO_CHAR(P_STARTDATE));    
    OPEN CUR_DELETED_ERLR_PROCESSES(P_STARTDATE);
    
    LOOP    
        FETCH
            CUR_DELETED_ERLR_PROCESSES
        INTO
            C_ERLR_CASE_NUMBER, C_ERLR_JOB_REQ_NUMBER, C_PROCID, C_ERLR_CASE_STATUS_ID, C_ERLR_CASE_CREATE_DT;
            
            IF C_PROCID IS NOT NULL THEN
            BEGIN
                --DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------');
                --DBMS_OUTPUT.PUT_LINE('PROCID = ' || TO_CHAR(C_PROCID) || ', ERLR_CASE_NUMBER = ' || TO_CHAR(C_ERLR_CASE_NUMBER));
                --DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------');

                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_3RDPARTY_HEAR'); 
                DELETE FROM HHS_CMS_HR.ERLR_3RDPARTY_HEAR WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_APPEAL');
                DELETE FROM HHS_CMS_HR.ERLR_APPEAL WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_CNDT_ISSUE');
                DELETE FROM HHS_CMS_HR.ERLR_CNDT_ISSUE WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;    
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_EMPLOYEE_CASE');
                DELETE FROM HHS_CMS_HR.ERLR_EMPLOYEE_CASE WHERE (CASEID = C_ERLR_CASE_NUMBER OR FROM_CASEID = C_ERLR_CASE_NUMBER) AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_GEN');
                DELETE FROM HHS_CMS_HR.ERLR_GEN WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_GRIEVANCE');
                DELETE FROM HHS_CMS_HR.ERLR_GRIEVANCE WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_INFO_REQUEST');
                DELETE FROM HHS_CMS_HR.ERLR_INFO_REQUEST WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_INVESTIGATION');
                DELETE FROM HHS_CMS_HR.ERLR_INVESTIGATION WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_LABOR_NEGO');
                DELETE FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_LABOR_NEGO');
                DELETE FROM HHS_CMS_HR.ERLR_LABOR_NEGO WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_MEDDOC');
                DELETE FROM HHS_CMS_HR.ERLR_MEDDOC WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_PERF_ISSUE');
                DELETE FROM HHS_CMS_HR.ERLR_PERF_ISSUE WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_PROB_ACTION');
                DELETE FROM HHS_CMS_HR.ERLR_PROB_ACTION WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_CASE');
                DELETE FROM HHS_CMS_HR.ERLR_CASE WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_ULP');
                DELETE FROM HHS_CMS_HR.ERLR_ULP WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - ERLR_WGI_DNL');
                DELETE FROM HHS_CMS_HR.ERLR_WGI_DNL WHERE ERLR_CASE_NUMBER = C_ERLR_CASE_NUMBER AND 'F' = P_DEBUG_FLAG;
                
                --------- common tables    
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - TBL_FORM_DTL_AUDIT');
                DELETE FROM HHS_CMS_HR.TBL_FORM_DTL_AUDIT WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
                --DBMS_OUTPUT.PUT_LINE('DELETING RECORDS - TBL_FORM_DTL');
                DELETE FROM HHS_CMS_HR.TBL_FORM_DTL WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
                DELETE FROM HHS_CMS_HR.TBL_FORM_DTL_AUDIT WHERE PROCID = C_PROCID AND 'F' = P_DEBUG_FLAG;
            END;
            END IF;
            
        EXIT WHEN CUR_DELETED_ERLR_PROCESSES%NOTFOUND;
    END LOOP;

    CLOSE CUR_DELETED_ERLR_PROCESSES;
    --DBMS_OUTPUT.PUT_LINE('--------------------------------------');
    
    COMMIT;

EXCEPTION
	WHEN OTHERS THEN
    CLOSE CUR_DELETED_ERLR_PROCESSES;
    ROLLBACK;
    --DBMS_OUTPUT.PUT_LINE('ERROR occurred -------------------');
    --DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
    --DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);    
END;
/

GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_CLEAN_PROC_DATA TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.SP_ERLR_CLEAN_PROC_DATA TO HHS_CMS_HR_DEV_ROLE;
/



delete HHS_CMS_HR.TBL_LOOKUP where TBL_ID = 1666;

INSERT INTO TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT)
VALUES (1666, 0, 'ERLRPipFinDecision', 'No Action Taken (employee resigned, retired, transferred)', 'No Action Taken (employee resigned, retired, transferred)', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
;

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (1673, 0, 'ERLRGIExtReason', 'Gathering Information', 'Gathering Information', '1', 2, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
;
/


