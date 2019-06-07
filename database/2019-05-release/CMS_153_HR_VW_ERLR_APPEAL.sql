CREATE OR REPLACE VIEW VW_ERLR_APPEAL
AS
SELECT
    A.ERLR_CASE_NUMBER
    , EC.ERLR_JOB_REQ_NUMBER
    , EC.PROCID    
    , EC.ERLR_CASE_CREATE_DT
    , AP_ERLR_APPEAL_TYPE
	, A.AP_ERLR_APPEAL_FILE_DT
	, CASE WHEN A.AP_ERLR_APPEAL_TIMING = '1'  THEN 'Yes' ELSE 'No' END AS AP_ERLR_APPEAL_TIMING
	, CASE WHEN A.AP_APPEAL_HEARING_REQUESTED = '1'  THEN 'Yes' ELSE 'No' END AS AP_APPEAL_HEARING_REQUESTED
	, A.AP_ARBITRATOR_LAST_NAME
	, A.AP_ARBITRATOR_FIRST_NAME
	, A.AP_ARBITRATOR_MIDDLE_NAME
	, A.AP_ARBITRATOR_EMAIL
	, A.AP_ARBITRATOR_PHONE_NUM
	, A.AP_ARBITRATOR_ORG_AFFIL
	, A.AP_ARBITRATOR_MAILING_ADDR
	, A.AP_ERLR_PREHEARING_DT
	, A.AP_ERLR_HEARING_DT
	, A.AP_POSTHEARING_BRIEF_DUE
	, A.AP_FINAL_ARBITRATOR_DCSN_DT
	, CASE WHEN A.AP_ERLR_EXCEPTION_FILED = '1'  THEN 'Yes' ELSE 'No' END AS AP_ERLR_EXCEPTION_FILED
	, A.AP_ERLR_EXCEPTION_FILE_DT
	, A.AP_RESPON_TO_EXCEPT_DUE
	, A.AP_FINAL_FLRA_DECISION_DT
	, A.AP_ERLR_STEP_DECISION_DT
	, CASE WHEN A.AP_ERLR_ARBITRATION_INVOKED = '1'  THEN 'Yes' ELSE 'No' END AS AP_ERLR_ARBITRATION_INVOKED
	, A.AP_ARBITRATOR_LAST_NAME_3
	, A.AP_ARBITRATOR_FIRST_NAME_3
	, A.AP_ARBITRATOR_MIDDLE_NAME_3
	, A.AP_ARBITRATOR_EMAIL_3
	, A.AP_ARBITRATOR_PHONE_NUM_3
	, A.AP_ARBITRATOR_ORG_AFFIL_3
	, A.AP_ARBITRATION_MAILING_ADDR_3
	, A.AP_ERLR_PREHEARING_DT_2
	, A.AP_ERLR_HEARING_DT_2
	, A.AP_POSTHEARING_BRIEF_DUE_2
	, A.AP_FINAL_ARBITRATOR_DCSN_DT_2
	, CASE WHEN A.AP_ERLR_EXCEPTION_FILED_2 = '1'  THEN 'Yes' ELSE 'No' END AS AP_ERLR_EXCEPTION_FILED_2
	, A.AP_ERLR_EXCEPTION_FILE_DT_2
	, A.AP_RESPON_TO_EXCEPT_DUE_2
	, A.AP_FINAL_FLRA_DECISION_DT_2
	, A.AP_ARBITRATOR_LAST_NAME_2
	, A.AP_ARBITRATOR_FIRST_NAME_2
	, A.AP_ARBITRATOR_MIDDLE_NAME_2
	, A.AP_ARBITRATOR_EMAIL_2
	, A.AP_ARBITRATOR_PHONE_NUM_2
	, A.AP_ARBITRATOR_ORG_AFFIL_2
	, A.AP_ARBITRATION_MAILING_ADDR_2
	, A.AP_ERLR_PREHEARING_DT_SC
	, A.AP_ERLR_HEARING_DT_SC
	, A.AP_ARBITRATOR_LAST_NAME_4
	, A.AP_ARBITRATOR_FIRST_NAME_4
	, A.AP_ARBITRATOR_MIDDLE_NAME_4
	, A.AP_ARBITRATOR_EMAIL_4
	, A.AP_ARBITRATOR_PHONE_NUM_4
	, A.AP_ARBITRATOR_ORG_AFFIL_4
	, A.AP_ARBITRATOR_MAILING_ADDR_4
	, A.AP_DT_SETTLEMENT_DISCUSSION
	, A.AP_DT_PREHEARING_DISCLOSURE
    , A.AP_DT_AGNCY_FILE_RESPON_DUE
    , A.AP_ERLR_PREHEARING_DT_MSPB
	, CASE WHEN A.AP_WAS_DISCOVERY_INITIATED = '1'  THEN 'Yes' ELSE 'No' END AS AP_WAS_DISCOVERY_INITIATED
	, A.AP_ERLR_DT_DISCOVERY_DUE
	, A.AP_ERLR_HEARING_DT_MSPB
	, A.AP_PETITION_FILE_DT_MSPB
	, CASE WHEN A.AP_WAS_PETITION_FILED_MSPB = '1'  THEN 'Yes' ELSE 'No' END AS AP_WAS_PETITION_FILED_MSPB
	, A.AP_INITIAL_DECISION_DT_MSPB
	, A.AP_FINAL_BOARD_DCSN_DT_MSPB
	, A.AP_DT_SETTLEMENT_DISCUSSION_2
	, A.AP_DT_PREHEARING_DISCLOSURE_2
	, A.AP_DT_AGNCY_FILE_RESPON_DUE_2
	, A.AP_ERLR_PREHEARING_DT_FLRA
	, A.AP_ERLR_HEARING_DT_FLRA
	, A.AP_INITIAL_DECISION_DT_FLRA
	, CASE WHEN A.AP_WAS_PETITION_FILED_FLRA = '1'  THEN 'Yes' ELSE 'No' END AS AP_WAS_PETITION_FILED_FLRA
	, A.AP_PETITION_FILE_DT_FLRA
	, A.AP_FINAL_BOARD_DCSN_DT_FLRA

FROM
	ERLR_APPEAL A
    LEFT OUTER JOIN ERLR_CASE EC ON A.ERLR_CASE_NUMBER = EC.ERLR_CASE_NUMBER
;
/
