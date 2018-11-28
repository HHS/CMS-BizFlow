--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_STRATCON_DATA
--------------------------------------------------------
/**
 * Modifies the form data XML for Strategic Consultation for business rule.
 * Currently, it inserts a new meeting history record depending on the reschedule flag.
 *
 * @param I_XMLDOC_PREV - Previous form data xml from the existing record.
 * @param IO_XMLDOC - Form data xml as an input and output.
 *
 * @return IO_XMLDOC - Form data xml that is modified in accordance with business rule.
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_STRATCON_DATA2
  (
    I_PROCID      IN     NUMBER,
    I_ACTSEQ      IN     NUMBER,
    I_LOGINID     IN     VARCHAR2,
    I_XMLDOC_PREV IN     XMLTYPE,
    IO_XMLDOC     IN OUT XMLTYPE
  )
IS
  V_IS_RESCHEDULE                 VARCHAR2(50);
  V_SCA_CLASS_SPEC_SIG_PREV       VARCHAR2(50);
  V_SCA_CLASS_SPEC_SIG_DT_PREV    VARCHAR2(50);
  V_SCA_STAFF_SIG_PREV            VARCHAR2(50);
  V_SCA_STAFF_SIG_DT_PREV         VARCHAR2(50);
  V_SCA_CLASS_SPEC_SIG            VARCHAR2(50);
  V_SCA_CLASS_SPEC_SIG_DT         VARCHAR2(50);
  V_SCA_STAFF_SIG                 VARCHAR2(50);
  V_SCA_STAFF_SIG_DT              VARCHAR2(50);
  V_IS_APPROVE_ACTIVITY           NUMBER(10);
  V_IS_CLASSIFIER                 NUMBER(10);
  V_IS_STAFF_SPECIALIST           NUMBER(10);
  V_MEMBERID                      VARCHAR2(10);
  BEGIN
    ----------------------------------
    -- MEETING_HISTORY
    ----------------------------------
    SELECT LOWER(EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/IS_RESCHEDULE'))
    INTO V_IS_RESCHEDULE
    FROM DUAL;

    IF (V_IS_RESCHEDULE = 'true') THEN
      SELECT APPENDCHILDXML(IO_XMLDOC, 'DOCUMENT/MEETING/MEETING_HISTORY', XMLTYPE
      (
          '<record>' ||
          '<SSH_ID>'                  || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_ID')                  || '</SSH_ID>' ||
          '<SSH_MEETING_SCHED_DT>'    || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_MEETING_SCHED_DT')    || '</SSH_MEETING_SCHED_DT>' ||
          '<SSH_RESCHED_FROM_DT>'     || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_FROM_DT')     || '</SSH_RESCHED_FROM_DT>' ||
          '<SSH_RESCHED_REASON_ID>'   || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_REASON_ID')   || '</SSH_RESCHED_REASON_ID>' ||
          '<SSH_RESCHED_REASON_TEXT>' || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_REASON_TEXT') || '</SSH_RESCHED_REASON_TEXT>' ||
          '<SSH_RESCHED_COMMENTS>'    || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_COMMENTS')    || '</SSH_RESCHED_COMMENTS>' ||
          '<SSH_RESCHED_BY_ID>'       || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_BY_ID')       || '</SSH_RESCHED_BY_ID>' ||
          '<SSH_RESCHED_BY_NAME>'     || EXTRACTVALUE(IO_XMLDOC, 'DOCUMENT/MEETING/SSH_RESCHED_BY_NAME')     || '</SSH_RESCHED_BY_NAME>' ||
          '<SSH_RESCHED_ON>'          || TO_CHAR(SYS_EXTRACT_UTC(SYSTIMESTAMP), 'YYYY-MM-DD HH24:MI:SS')     || '</SSH_RESCHED_ON>' ||
          '</record>'
      ))
      INTO IO_XMLDOC
      FROM DUAL;
    END IF;

    ----------------------------------
    -- APPROVAL
    ----------------------------------
    -- If there are multiple work items for one approval activity, and they are being approved at the same time,
    -- the signature data of the other will be overwritten (blanked out).  Prevent such overwrite.

    SELECT COUNT(1) INTO V_IS_APPROVE_ACTIVITY
    FROM BIZFLOW.ACT
    WHERE PROCID = I_PROCID
          AND ACTSEQ = I_ACTSEQ
          AND NAME = 'Approve Strat Cons Meeting';

    IF (V_IS_APPROVE_ACTIVITY = 1) THEN

      SELECT MEMBERID INTO V_MEMBERID
      FROM BIZFLOW.MEMBER
      WHERE LOGINID = I_LOGINID;

      SELECT COUNT(1) INTO V_IS_CLASSIFIER
      FROM BIZFLOW.RLVNTDATA
      WHERE PROCID = I_PROCID
            AND RLVNTDATANAME = 'memIdClassSpec'
            AND VALUE = V_MEMBERID;

      SELECT COUNT(1) INTO V_IS_STAFF_SPECIALIST
      FROM BIZFLOW.RLVNTDATA
      WHERE PROCID = I_PROCID
            AND RLVNTDATANAME = 'memIdStaffSpec'
            AND VALUE = V_MEMBERID;

      -- If current user is same with classSpecialist (memIdClassSpec)
      -- update classifier signature
      -- maintain staff specialist signature

      -- If current user is same with staffSpecialist (memIdStaffSpec)
      -- maintain classifier signature
      -- update staff specialist signature

      -- If current user is same with classSpecialist and also staffSpecialist
      -- update classifier signature
      -- update staff specialist signature

      -- If current user is not same with classSpecialist and also staffSpecialist
      -- SKIP updating approval section

      IF ((V_IS_CLASSIFIER = 1) OR (V_IS_STAFF_SPECIALIST = 1)) THEN
        IF ((V_IS_CLASSIFIER <> 1) OR (V_IS_STAFF_SPECIALIST <> 1)) THEN
          SELECT
            X.SCA_CLASS_SPEC_SIG_PREV,
            X.SCA_CLASS_SPEC_SIG_DT_PREV,
            X.SCA_STAFF_SIG_PREV,
            X.SCA_STAFF_SIG_DT_PREV,
            X.SCA_CLASS_SPEC_SIG,
            X.SCA_CLASS_SPEC_SIG_DT,
            X.SCA_STAFF_SIG,
            X.SCA_STAFF_SIG_DT
          INTO
            V_SCA_CLASS_SPEC_SIG_PREV,
            V_SCA_CLASS_SPEC_SIG_DT_PREV,
            V_SCA_STAFF_SIG_PREV,
            V_SCA_STAFF_SIG_DT_PREV,
            V_SCA_CLASS_SPEC_SIG,
            V_SCA_CLASS_SPEC_SIG_DT,
            V_SCA_STAFF_SIG,
            V_SCA_STAFF_SIG_DT
          FROM
            XMLTABLE('/DOCUMENT/APPROVAL'
                     PASSING I_XMLDOC_PREV
                     COLUMNS
                     SCA_CLASS_SPEC_SIG_PREV             VARCHAR2(50)    PATH 'SCA_CLASS_SPEC_SIG'
            , SCA_CLASS_SPEC_SIG_DT_PREV        VARCHAR2(50)    PATH 'SCA_CLASS_SPEC_SIG_DT'
            , SCA_STAFF_SIG_PREV                VARCHAR2(50)    PATH 'SCA_STAFF_SIG'
            , SCA_STAFF_SIG_DT_PREV             VARCHAR2(50)    PATH 'SCA_STAFF_SIG_DT'
            ) X
            , XMLTABLE('/DOCUMENT/APPROVAL'
                       PASSING IO_XMLDOC
                       COLUMNS
                       SCA_CLASS_SPEC_SIG                  VARCHAR2(50)    PATH 'SCA_CLASS_SPEC_SIG'
          , SCA_CLASS_SPEC_SIG_DT             VARCHAR2(50)    PATH 'SCA_CLASS_SPEC_SIG_DT'
          , SCA_STAFF_SIG                     VARCHAR2(50)    PATH 'SCA_STAFF_SIG'
          , SCA_STAFF_SIG_DT                  VARCHAR2(50)    PATH 'SCA_STAFF_SIG_DT'
              ) X
          ;

          IF (V_IS_CLASSIFIER = 1) THEN
            -- COPY STAFF FROM OLD ONE


            SELECT UPDATEXML(IO_XMLDOC,
                             '/DOCUMENT/APPROVAL/SCA_STAFF_SIG', '<SCA_STAFF_SIG>' || V_SCA_STAFF_SIG_PREV || '</SCA_STAFF_SIG>',
                             '/DOCUMENT/APPROVAL/SCA_STAFF_SIG_DT', '<SCA_STAFF_SIG_DT>' || V_SCA_STAFF_SIG_DT_PREV || '</SCA_STAFF_SIG_DT>')
            INTO IO_XMLDOC
            FROM dual;

          END IF;

          IF (V_IS_STAFF_SPECIALIST = 1) THEN
            -- COPY CLASSIFIER FROM OLD ONE

            SELECT UPDATEXML(IO_XMLDOC,
                             '/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG', '<SCA_CLASS_SPEC_SIG>' || V_SCA_CLASS_SPEC_SIG_PREV || '</SCA_CLASS_SPEC_SIG>',
                             '/DOCUMENT/APPROVAL/SCA_CLASS_SPEC_SIG_DT', '<SCA_CLASS_SPEC_SIG_DT>' || V_SCA_CLASS_SPEC_SIG_DT_PREV || '</SCA_CLASS_SPEC_SIG_DT>')
            INTO IO_XMLDOC
            FROM DUAL;

          END IF;
        END IF;
      END IF;
    END IF;    -- IF V_IS_APPROVE_ACTIVITY = 1

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_STRATCON_DATA -------------------');
  END;

/



commit

--select * from bizflow.rlvntdata where rlvntdataname = 'posTitle' and procid = 4158
--select * from TBL_FORM_DTL where procid = 4158

--
-- INSERT INTO ERROR_LOG
-- (
--   ERROR_CD
--   , ERROR_MSG
--   , BACKTRACE
--   , CALLSTACK
--   , CRT_DT
--   , CRT_USR
-- )
-- VALUES (
--   1
--   , 'STAFF'
--   , null
--   , null
--   , SYSDATE
--   , USER
-- );
--
-- COMMIT;