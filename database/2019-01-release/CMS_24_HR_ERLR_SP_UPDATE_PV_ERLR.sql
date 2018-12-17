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


      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseNumber', '/formData/items/item[id=''CASE_NUMBER'']/value/text()');


      --SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'caseStatus', '/formData/items/item[id=''CASE_STATUS'']/value/text()');
      V_RLVNTDATANAME := 'caseStatus';
      V_XMLVALUE := I_FIELD_DATA.EXTRACT('/formData/items/item[id=''GEN_CASE_STATUS'']/value/text()');
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        -- skip looking up hard-coded value for case cancellation
        IF  V_VALUE <> 'Case Created' AND V_VALUE <> 'closeNow' THEN
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
        END IF;
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
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestNum',             '/formData/items/item[id=''REQ_NUMBER'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'requestStatusDate',      '/formData/items/item[id=''REQ_STATUS_DT'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'secondaryDWCSpecialist', '/formData/items/item[id=''GEN_SECONDARY_SPECIALIST'']/value/text()');

      --DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_ERLR -------------------');
  END;