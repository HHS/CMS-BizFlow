
DROP TABLE HHS_REPORTDOMAINLOOKUP
;

CREATE TABLE HHS_REPORTDOMAINLOOKUP (
	PATH  VARCHAR2(64) NOT NULL,
	VALUE VARCHAR2(32) NOT NULL,
	LABEL VARCHAR2(256) NOT NULL
)
/
CREATE UNIQUE INDEX PK_HHS_REPOARTDOMAINLOOKUP ON HHS_REPORTDOMAINLOOKUP (
	PATH, VALUE
)
/
ALTER TABLE HHS_REPORTDOMAINLOOKUP ADD (PRIMARY KEY (PATH, VALUE))
/


INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.prtcptype','U','User');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.prtcptype','D','Organizational Unit');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.prtcptype','G','User Group') ;
/

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','I','Created');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','R','Running');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','V','Overdue');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','C','Completed');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','E','Errored');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','T','Terminated');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','S','Suspended');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','P','Partially completed');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','D','Dead');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','W','Forwarded');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','Y','Being processed asynchronously');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','1','Deleted (Created)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','2','Deleted (Running)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','3','Deleted (Overdue)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','4','Deleted (Completed)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','5','Deleted (Errored)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','7','Deleted (Terminated)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','8','Deleted (Suspended)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','9','Deleted (Partially completed)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','-','Deleted (Forwarded)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','+','Deleted (Dead)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.state','*','Deleted (Being processed asynchronously)');
/

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.urgent','T','Yes');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('witem.urgent','F','No');
/

-- Procs.State
INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', 'N', 'Not Started');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', 'R', 'Running');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', 'E', 'Error');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', 'V', 'Overdue');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', 'S', 'Suspended');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', 'T', 'Terminated');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', 'C', 'Completed');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', 'D', 'Dead');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', '0', 'Deleted (Not Started)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', '1', 'Deleted (Running)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', '2', 'Deleted (Error)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', '3', 'Deleted (Overdue)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', '4', 'Deleted (Suspended)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', '6', 'Deleted (Terminated)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', '7', 'Deleted (Completed)');

INSERT INTO HHS_REPORTDOMAINLOOKUP (PATH, VALUE, LABEL)
VALUES ('procs.state', '8', 'Deleted (Dead)');
/

COMMIT;
/



/**
 * Gets description value of given code value from report lookup table.
 *
 * @param I_LOOKUP_PATH - lookup path
 * @param I_LOOKUP_VALUE - lookup value
 * @return Description (label) corresponding to the given path/value.
 */
CREATE OR REPLACE FUNCTION HHS_FN_GET_RPTLOOKUPVAL(
	I_LOOKUP_PATH          IN      VARCHAR2
	, I_LOOKUP_VALUE       IN      VARCHAR2
)
RETURN VARCHAR2 IS
	V_LABEL VARCHAR2(256) := '';
BEGIN
	SELECT LABEL INTO V_LABEL
	FROM HHS_REPORTDOMAINLOOKUP
	WHERE PATH = I_LOOKUP_PATH
	AND VALUE = I_LOOKUP_VALUE;

  RETURN V_LABEL;

EXCEPTION
	WHEN OTHERS THEN
		RETURN '';
END;
/




/**
 * Gets elapsed business days count.
 *
 * Note: The working day and holiday that are defined in BizFlow Calendar tables
 *       (CAL table and MEMBERCAL table) are used to determine the business day.
 *
 * @param I_FROMDATE - The date when the business days count starts.
 * @param I_TODATE - The date when the business days count ends
 * @return Integer value to indicate the number of business days between
 *         the start/end date.
 */
CREATE OR REPLACE FUNCTION HHS_FN_GET_BUSDAYSDIFF(
	I_FROMDATE             IN      DATE
	, I_TODATE             IN      DATE
)
RETURN INT
IS
	V_DAYS INT;
BEGIN
	SELECT COUNT(1) INTO V_DAYS
	FROM CAL C INNER JOIN CALHEAD CH ON CH.DAYOFWEEK = C.DAYOFWEEK
	WHERE CH.DAYTYPE <> 'H'
		AND C.CALDTIME NOT IN (SELECT CALDTIME FROM MEMBERCAL WHERE DAYTYPE = 'H' AND MEMBERID = '0000000000') -- AND memberid = calendarID)
		AND C.CALDTIME > I_FROMDATE
		AND C.CALDTIME <= I_TODATE
		AND CH.MEMBERID = '0000000000';

    RETURN NVL(V_DAYS, 0);
END;
/





/**
 * Gets accumulated business days count accumulated for the given process
 * and activity to complete.
 *
 * @param I_PROCID - The target Process ID.
 * @param I_ACTNAME - The target Activity Name.
 * @return Integer value to indicate the number of accumulated business days
 *         taken to complete an activity.
 */
CREATE OR REPLACE FUNCTION HHS_FN_GET_ACCBUSDAYSDIFF(
	I_PROCID               IN      INT
	, I_ACTNAME            IN      VARCHAR2
)
RETURN INT
IS
	V_EVENT CHAR(1);
	V_EXECDTIME DATE;
	V_END DATE;
	V_FOUND_COMPLETED_DATE CHAR(1);
	V_DAYDIFF INT;
	V_DAYDIFF_TOTAL INT;

	CURSOR CUR_AUDITINFO IS
		SELECT EVENT, EXECDTIME
		FROM AUDITINFO
		WHERE OBJNAME = I_ACTNAME
			AND EVENT IN ('R', 'C')
			AND OBJTYPE = 'A'
			AND PROCID = I_PROCID
		ORDER BY EXECSEQ DESC;
BEGIN
	V_FOUND_COMPLETED_DATE := 'N';
	V_DAYDIFF := 0;
	V_DAYDIFF_TOTAL := 0;

	OPEN CUR_AUDITINFO;

	LOOP
		FETCH CUR_AUDITINFO INTO V_EVENT, V_EXECDTIME;
		EXIT WHEN CUR_AUDITINFO%NOTFOUND;

		IF (V_EVENT = 'R' AND V_FOUND_COMPLETED_DATE = 'Y') THEN
			SELECT HHS_FN_GET_BUSDAYSDIFF(V_EXECDTIME, V_END) INTO V_DAYDIFF FROM dual;
			V_DAYDIFF_TOTAL := V_DAYDIFF_TOTAL + V_DAYDIFF;
			V_FOUND_COMPLETED_DATE := 'N';
		ELSIF (V_EVENT = 'C') THEN
			V_FOUND_COMPLETED_DATE := 'Y';
			V_END := V_EXECDTIME;
		END IF;

	END LOOP;

	CLOSE CUR_AUDITINFO;
	RETURN V_DAYDIFF_TOTAL;
END;
/





CREATE OR REPLACE VIEW HHS_VW_WORKITEM
AS
	SELECT
		C.PROCID                      AS PROCESS_ID
		, C.WITEMSEQ                  AS WORKITEM_ID
		, HHS_FN_GET_RPTLOOKUPVAL('witem.prtcptype', C.PRTCPTYPE) AS PARTICIPANT_TYPE
		, HHS_FN_GET_RPTLOOKUPVAL('witem.state', C.STATE) AS STATE_LABEL
		, C.STATE                     AS STATE
		, C.ACTSEQ                    AS ACTIVITY_ID
		, C.PRTCP                     AS PARTICIPANT_ID
		, C.PRTCPNAME                 AS PARTICIPANT_NAME
		, C.CMPLTUSR                  AS COMPLETER_ID
		, C.CMPLTUSRNAME              AS COMPLETER_NAME
		, C.CREATIONDTIME             AS CREATION_DATE
		, C.STARTDTIME                AS START_DATE
		, C.CMPLTDTIME                AS COMPLETION_DATE
		, ''                          AS COMPLETION_DURATION
	FROM WITEM C
	WHERE C.ONASYNC = 'F';
/




CREATE OR REPLACE VIEW HHS_VW_PROCESS
AS
	SELECT
		A.PROCID                      AS PROCESS_ID
		, HHS_FN_GET_RPTLOOKUPVAL('procs.state', A.STATE) AS STATE_LABEL
		, A.STATE                     AS STATE
		, A.CMNTCNT                   AS COMMENT_COUNT
		, A.ATTACHCNT                 AS ATTACHMENT_COUNT
		, A.NAME                      AS NAME
		, A.CREATIONDTIME             AS CREATION_DATE
		, A.CREATOR                   AS CREATOR_ID
		, A.CREATORNAME               AS CREATOR_NAME
		, A.CMPLTDTIME                AS COMPLETION_DATE
		, A.PARENTPROCID              AS PARENT_PROCESS_ID
		, B.NAME                      AS PARENT_PROCESS_NAME
		, A.PARENTACTSEQ              AS PARENT_ACTIVITY_ID
		, HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, A.CMPLTDTIME) AS COMPLETION_DURATION
	FROM
		PROCS A
		LEFT JOIN PROCS B ON A.PARENTPROCID = B.PROCID;
/




-----------------------------
-- VW_CONSULTATION_PROC
-----------------------------

CREATE OR REPLACE VIEW HHS_VW_CONSULTATION_PROC
AS
	SELECT
		A.PROCID                      AS PROCESS_ID
		, HHS_FN_GET_RPTLOOKUPVAL('procs.state', a.state) AS PROCESS_STATE_DESC
		, A.STATE                     AS PROCESS_STATE  -- #1 State
		, A.NAME                      AS PROCESS_NAME -- #2 Name
		, A.CREATIONDTIME             AS PROCESS_CREATION_DATE -- #3 Create DATE
		, A.CREATOR                   AS PROCESS_CREATOR_ID
		, A.CREATORNAME               AS PROCESS_CREATOR_NAME -- #4 Initiator Name
		, B.NAME                      AS CURRENT_ACTIVITY_NAME -- #5 Current Step
		, C.PRTCPNAME                 AS CURRENT_USER_NAME
		, C.PRTCP                     AS CURRENT_USER_ID -- #6 Current Participant
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestStatus') AS REQUEST_STATUS -- #7 Current Status
		, TO_DATE(REPLACE(FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'D', 'requestStatusDate'), 'T', ' '),  'YYYY-MM-DD HH24:MI:SS') AS REQUEST_STATUS_DATE -- #8 Current State DATE
		, HHS_FN_GET_BUSDAYSDIFF(TO_DATE(REPLACE(FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'D', 'requestStatusDate'), 'T', ' '),  'YYYY-MM-DD HH24:MI:SS'), SYSDATE) AS REQUEST_STATUS_AGE -- #9. Current State Age
		, A.CMPLTDTIME AS PROCESS_COMPLETION_DATE -- #10 Complete DATE
		, HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, A.CMPLTDTIME) AS PROCESS_AGE -- #11 Days to Complete (Process)
		, HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Create Request') AS CREATE_REQUEST_AGE -- #13 Days to Complete (Hold Strategic Consultation Meeting - Accumulated days)
		, HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Hold Strategic Consultation Meeting') AS HOLD_MEETING_AGE -- #13 Days to Complete (Hold Strategic Consultation Meeting - Accumulated days)
		, HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Acknowledge Strat Cons Meeting') AS ACK_MEETING_AGE -- #14 Days to Complete (Acknowledge Strat Cons Meeting - Accumulated days)
		, NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Acknowledge Strat Cons Meeting'), 0) AS ACK_MEETING_COMPLETION_COUNT
		, HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Approve Strat Cons Meeting') AS APRV_MEETING_AGE -- #16 Days to Complete (Approve Strat Cons Meeting - Accumulated days)
		, NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Approve Strat Cons Meeting'), 0) AS APRV_MEETING_COMPLETION_COUNT
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'adminCode') AS V_ADMIN_CODE
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'cancelReason') AS V_CANCEL_REASON
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestNum') AS V_REQUEST_NUMBER
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestType') AS V_REQUEST_TYPE
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'classificationType') AS V_CLASSIFICATION_TYPE
	FROM
		PROCS A
		LEFT JOIN ACT B ON A.PROCID = B.PROCID AND B.STATE IN ('R', 'V', 'E') AND B.TYPE = 'P'
		LEFT JOIN WITEM C ON A.PROCID = C.PROCID AND B.ACTSEQ = C.ACTSEQ AND C.STATE IN ('I','V','E','P','R')
	WHERE A.PREPROCDEFNAME = 'Strategic Consultation'
	ORDER BY A.PROCID;
/




------------------------------
-- VW_CLASSIFICATION_PROC
------------------------------

CREATE OR REPLACE VIEW HHS_VW_CLASSIFICATION_PROC
AS
	SELECT
		A.PROCID                      AS PROCESS_ID
		, HHS_FN_GET_RPTLOOKUPVAL('procs.state', A.STATE) AS PROCESS_STATE_DESC
		, A.STATE                     AS PROCESS_STATE -- #1 State
		, A.NAME                      AS PROCESS_NAME -- #2 Name
		, A.CREATIONDTIME             AS PROCESS_CREATION_DATE -- #3 Create DATE
		, A.CREATOR                   AS PROCESS_CREATOR_ID
		, A.CREATORNAME               AS PROCESS_CREATOR_NAME -- #4 Initiator Name
		, B.NAME                      AS CURRENT_ACTIVITY_NAME -- #5 Current Step
		, C.PRTCPNAME                 AS CURRENT_USER_NAME
		, C.PRTCP                     AS CURRENT_USER_ID -- #6 Current Participant
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestStatus') AS REQUEST_STATUS -- #7 Current Status
		, TO_DATE(REPLACE(FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'D', 'requestStatusDate'), 'T', ' '),  'YYYY-MM-DD HH24:MI:SS') AS REQUEST_STATUS_DATE -- #8 Current State DATE
		, HHS_FN_GET_BUSDAYSDIFF(TO_DATE(REPLACE(FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'D', 'requestStatusDate'), 'T', ' '),  'YYYY-MM-DD HH24:MI:SS'), SYSDATE) AS REQUEST_STATUS_AGE -- #9. Current State Age
		, A.CMPLTDTIME                AS PROCESS_COMPLETION_DATE -- #10 Complete DATE
		, HHS_FN_GET_BUSDAYSDIFF(A.CREATIONDTIME, A.CMPLTDTIME) AS PROCESS_AGE -- #11 Days to Complete (Process)
		, HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Complete PD Coversheet AND Classification Analysis') AS COMPLETE_PD_COVERSHEET_AGE -- #12 Days to Complete (Complete PD Coversheet AND Classification Analysis)
		, NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Complete PD Coversheet AND Classification Analysis'), 0) AS COMPLETE_PD_COVERSHEET_COUNT -- #13
		, HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Confirm Classification Analysis') AS CONFIRM_ANALYSIS_AGE -- #14 Days to Complete (Confirm Classification Analysis)
		, NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Confirm Classification Analysis'), 0) AS CONFIRM_ANALYSIS_COUNT -- #15
		, HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Confirm BUS Code') AS CONFIRM_BUS_CODE_AGE -- #16 Days to Complete (Confirm BUS code)
		, HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Review DWC Entry') AS REVIEW_DWC_ENTRY_AGE -- #17 Days to Complete (Confirm Classification Analysis)
		, NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Review DWC Entry'), 0) AS REVIEW_DWC_ENTRY_COUNT -- #18 Completion count
		, HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Approve PD Coversheet - SO') AS APPROVE_PD_COVERSHEET_AGE -- #19 Days to Complete (Approve PD Coversheet)
		, NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Approve PD Coversheet - SO'), 0) AS APPROVE_PD_COVERSHEET_COUNT -- #20 Completion count
		, HHS_FN_GET_ACCBUSDAYSDIFF(A.PROCID, 'Approve Coversheet AND Create Final Pkg') AS CREATE_FINAL_PKG_AGE -- #21 Days to Complete (Approve Coversheet AND Create Final Pkg)
		, NVL((SELECT CMPLTCNT FROM ACT WHERE PROCID = A.PROCID AND NAME = 'Approve Coversheet AND Create Final Pkg'), 0) AS CREATE_FINAL_PKG_COUNT -- #22 Completion count
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'adminCode') AS V_ADMIN_CODE
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'cancelReason') AS V_CANCEL_REASON
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestNum') AS V_REQUEST_NUMBER
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'requestType') AS V_REQUEST_TYPE
		, FN_GET_RLVNTDATAVALUE(A.PROCID, 'I', 'S', 'classificationType') AS V_CLASSIFICATION_TYPE
	FROM
		PROCS A
		LEFT JOIN ACT B ON A.PROCID = B.PROCID AND B.STATE IN ('R', 'V', 'E') AND B.TYPE = 'P'
		LEFT JOIN WITEM C ON A.PROCID = C.PROCID AND B.ACTSEQ = C.ACTSEQ AND C.STATE IN ('I','V','E','P','R')
	WHERE A.PREPROCDEFNAME = 'Classification'
	ORDER BY A.PROCID;
/
