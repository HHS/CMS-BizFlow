create or replace PROCEDURE SP_UPDATE_PV_STRATCON
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
  V_REC_CNT              NUMBER(10);
  V_XMLDOC               XMLTYPE;
  V_XMLVALUE             XMLTYPE;
  V_VALUE1               NVARCHAR2(2000);
  V_VALUE2               NVARCHAR2(2000);
  V_VALUE3               NVARCHAR2(2000);  
  lcntr                  NUMBER(2);
  
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

      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'adminCode', '/DOCUMENT/GENERAL/SG_ADMIN_CD/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'cancelReason', '/DOCUMENT/PROCESS_VARIABLE/cancelReason/text()', null);      
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingAckResponse', '/DOCUMENT/PROCESS_VARIABLE/meetingAckResponse/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingApvResponse', '/DOCUMENT/PROCESS_VARIABLE/meetingApvResponse/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingEmailRecipients', '/DOCUMENT/PROCESS_VARIABLE/meetingEmailRecipients/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingRequired', '/DOCUMENT/PROCESS_VARIABLE/meetingRequired/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingResched',  '/DOCUMENT/PROCESS_VARIABLE/meetingResched/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdClassSpec', '/DOCUMENT/GENERAL/SG_CS_ID/text()', null);      
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdSelectOff', '/DOCUMENT/GENERAL/SG_SO_ID/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'memIdStaffSpec', '/DOCUMENT/GENERAL/SG_SS_ID_PV/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'posLocation', '/DOCUMENT/POSITION/POS_LOCATION/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'posTitle', '/DOCUMENT/POSITION/POS_TITLE/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestNum', '/DOCUMENT/PROCESS_VARIABLE/requestNum/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'selectOfficialReviewReq', '/DOCUMENT/PROCESS_VARIABLE/selectOfficialReviewReq/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'specialProgram', '/DOCUMENT/PROCESS_VARIABLE/specialProgram/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'alertMessage', '/DOCUMENT/PROCESS_VARIABLE/alertMessage/text()', null);
      HHS_CMS_HR.SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'meetingReschedReason', '/DOCUMENT/PROCESS_VARIABLE/meetingReschedReason/text()', null);

      V_RLVNTDATANAME := 'appointmentType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_AT_ID/text()');

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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'candidateName';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_CNDT_FIRST_NM/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_CNDT_LAST_NM/text()');
      IF V_VALUE IS NOT NULL AND V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_VALUE || ' ' || V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'classSpecialist';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_CS_ID/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'classificationType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_CT_ID/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'lastActivityCompDate';
      BEGIN
        SELECT TO_CHAR(SYSTIMESTAMP AT TIME ZONE 'UTC', 'YYYY/MM/DD HH24:MI:SS') INTO V_VALUE FROM DUAL;
        EXCEPTION
        WHEN OTHERS THEN V_VALUE := NULL;
      END;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'meetingDate';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/MEETING/SSH_MEETING_SCHED_DT/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- date format and GMT conversion
        -------------------------------------
        V_VALUE := TO_CHAR(SYS_EXTRACT_UTC(TO_DATE(V_VALUE, 'YYYY-MM-DD')), 'YYYY/MM/DD HH24:MI:SS');
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'meetingDateCutOff';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/MEETING/SSH_MEETING_SCHED_DT/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- date format and GMT conversion
        -------------------------------------
        --V_VALUE := TO_CHAR(SYS_EXTRACT_UTC(TO_DATE(V_VALUE || ' 23:59:00', 'YYYY-MM-DD HH24:MI:SS')), 'YYYY/MM/DD HH24:MI:SS');
        -- For current date, make the cutoff date past so that wait activity is completed immediately.
        -- For future date, subtract one day and make the time before midnight, i.e. 23:59.
        V_VALUE := TO_CHAR((SYS_EXTRACT_UTC(TO_DATE(V_VALUE || ' 23:59:00', 'YYYY-MM-DD HH24:MI:SS')) - 1), 'YYYY/MM/DD HH24:MI:SS');
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'meetingDateString';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/MEETING/SSH_MEETING_SCHED_DT/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -------------------------------------
        -- date format for display
        -------------------------------------
        V_VALUE := TO_CHAR(TO_DATE(V_VALUE, 'YYYY-MM-DD'), 'MM/DD/YYYY');
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'meetingRecorders';
      --V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/meetingRecorders/text()');
      ---------------------------
      -- TODO: currently mapped to only classSpecialist, but it should be able to handle multiple participants
      ---------------------------
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_CS_ID/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
    
      --V_RLVNTDATANAME := 'memIdExecOff';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_XO_ID/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdExecOff';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'execOfficer';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;
        V_RLVNTDATANAME := 'execOfficer2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdExecOff3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;
        V_RLVNTDATANAME := 'execOfficer3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL
        WHERE RLVNTDATANAME IN ('memIdExecOff', 'memIdExecOff2', 'memIdExecOff3', 'execOfficer', 'execOfficer2', 'execOfficer3') AND PROCID = I_PROCID;

      END IF;

      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);

    V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_HRL_ID/text()');
    IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 1) INTO V_VALUE1 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 2) INTO V_VALUE2 FROM DUAL;
        SELECT REGEXP_SUBSTR (V_VALUE, '[^,]+', 1, 3) INTO V_VALUE3 FROM DUAL;

        V_RLVNTDATANAME := 'memIdHrLiaison';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE1 IS NOT NULL THEN
          V_VALUE1 := '[U]' || V_VALUE1;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE1) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdHrLiaison2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE2 IS NOT NULL THEN
          V_VALUE2 := '[U]' || V_VALUE2;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison2';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE2) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        V_RLVNTDATANAME := 'memIdHrLiaison3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

        IF V_VALUE3 IS NOT NULL THEN
          V_VALUE3 := '[U]' || V_VALUE3;
        END IF;
        V_RLVNTDATANAME := 'hrLiaison3';
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE3) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      ELSE

        UPDATE BIZFLOW.RLVNTDATA SET VALUE = NULL
        WHERE RLVNTDATANAME IN ('memIdHrLiaison', 'memIdHrLiaison2', 'memIdHrLiaison3', 'hrLiaison', 'hrLiaison2', 'hrLiaison3') AND PROCID = I_PROCID;

      END IF;
       
    V_RLVNTDATANAME := 'posNumber';
    V_VALUE := NULL;
    FOR lcntr IN 1 .. 5
    LOOP
        V_VALUE1 := '/DOCUMENT/POSITION/POS_DESC_NUMBER_' || lcntr || '/text()';
        V_XMLVALUE := I_FIELD_DATA.EXTRACT(V_VALUE1);
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE2 := V_XMLVALUE.GETSTRINGVAL();
            IF V_VALUE IS NULL THEN
                V_VALUE := V_VALUE2;
            ELSE    
                V_VALUE := V_VALUE || '; ' || V_VALUE2;
            END IF;
        END IF;
    END LOOP;
    IF V_VALUE IS NULL THEN
        V_VALUE := 'N/A';
    END IF;
    UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
    
      V_RLVNTDATANAME := 'posIs';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SUPERVISORY/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posPayPlan';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_PAY_PLAN_ID/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posSensitivity';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SEC_ID/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posSeries';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SERIES/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'posSupervisor';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/POSITION/POS_SUPERVISORY/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
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
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'requestType';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_RT_ID/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'returnToSOFromClassSpec';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSOFromClassSpec/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- This pv can be updated from multiple workitem
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'returnToSOFromStaffSpec';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/returnToSOFromStaffSpec/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- This pv can be updated from multiple workitem
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'secondSubOrg';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_ADMIN_CD/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        ---------------------------------
        -- replace with admin code desc lookup value
        ---------------------------------
        BEGIN
          SELECT AC_ADMIN_CD_DESCR INTO V_VALUE_LOOKUP
          FROM ADMIN_CODES
          WHERE AC_ADMIN_CD = SUBSTR(V_VALUE, 1, 3);
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'selectOfficial';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_SO_ID/text()');
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'smeEmailAddresses';
      V_VALUE := NULL;
      -- check and append SME_EMAIL_JA
      IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_JOB_ANALYSIS/text()') = 1
         AND I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_JOB_ANALYSIS/text()').GETSTRINGVAL() = 'true'
         AND I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_JA/text()') = 1
      THEN
        V_VALUE := V_VALUE || I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_JA/text()').GETSTRINGVAL() || ';';
      END IF;
      -- check and append SME_EMAIL_QUAL 1 and/or 2
      IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_QUALIFICATION/text()') = 1
         AND I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_FOR_QUALIFICATION/text()').GETSTRINGVAL() = 'true'
      THEN
        IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_1/text()') = 1
        THEN
          V_VALUE := V_VALUE || I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_1/text()').GETSTRINGVAL() || ';';
        END IF;
        IF I_FIELD_DATA.EXISTSNODE('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_2/text()') = 1
        THEN
          V_VALUE := V_VALUE || I_FIELD_DATA.EXTRACT('/DOCUMENT/SUBJECT_MATTER_EXPERT/SME_EMAIL_QUAL_2/text()').GETSTRINGVAL() || ';';
        END IF;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;

      V_RLVNTDATANAME := 'staffSpecialist';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/GENERAL/SG_SS_ID_PV/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        -------------------------------
        -- participant prefix
        -------------------------------
        --V_VALUE := '[U]' || V_XMLVALUE.GETSTRINGVAL();
        -- If the Job Request is for Special Program, SG_SS_ID_PV may point to User Group,
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
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'worksheetFeedbackClassSpec';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/worksheetFeedbackClassSpec/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- This pv can be updated from multiple workitem
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      V_RLVNTDATANAME := 'worksheetFeedbackSelectOfficial';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/worksheetFeedbackSelectOfficial/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;


      V_RLVNTDATANAME := 'worksheetFeedbackStaffSpec';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/DOCUMENT/PROCESS_VARIABLE/worksheetFeedbackStaffSpec/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;
      --DBMS_OUTPUT.PUT_LINE('    V_RLVNTDATANAME = ' || V_RLVNTDATANAME);
      --DBMS_OUTPUT.PUT_LINE('    V_VALUE         = ' || V_VALUE);
      -------------------------------------------------------------------------------
      -- This pv can be updated from multiple workitem
      -- Only update if not blank to prevent overwriting unintentionally
      -------------------------------------------------------------------------------
      IF V_VALUE IS NOT NULL THEN
        UPDATE BIZFLOW.RLVNTDATA SET VALUE = UTL_I18N.UNESCAPE_REFERENCE(V_VALUE) WHERE RLVNTDATANAME = V_RLVNTDATANAME AND PROCID = I_PROCID;
      END IF;


      --DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_STRATCON -------------------');
  END;