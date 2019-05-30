SET DEFINE OFF;

create or replace PACKAGE SLA_PKS as
    
    FUNCTION GET_HIRING_TIMELINE_SLA
      (
        I_REQUEST_NUMBER IN VARCHAR2,
        I_CALENDAR_TYPE  IN VARCHAR2 DEFAULT 'Calendar',    
        I_TIMEZONE       IN VARCHAR2 DEFAULT 'America/New_York'
      )
    RETURN SLA_RESULT_TABLE ;
    
    FUNCTION GET_TIMEZONE_OFFSET(
        I_TIMEZONE  IN VARCHAR2 DEFAULT 'America/New_York'
    ) 
    RETURN FLOAT;
    
    FUNCTION NEW_TIMEZONE(
        I_DATE             DATE,
        I_TIMEZONE_OFFSET  IN FLOAT
    )
    RETURN DATE;

    FUNCTION GET_HIRING_TIMELINE (
        I_REQUEST_NUMBER IN VARCHAR2,
        I_CALENDAR_TYPE  IN VARCHAR2 DEFAULT 'Calendar',
        I_TIMEZONE       IN VARCHAR2 DEFAULT 'America/New_York'
    ) RETURN HIRING_TIMELINE_TABLE;

    FUNCTION GET_ACT_DATETIME 
    (
        I_REQUEST_NUMBER IN VARCHAR2 
        , I_SLA_PROCNM IN VARCHAR2
        , I_SLA_ACTNM IN VARCHAR2 
        , I_DATE_TP IN VARCHAR2 -- START | END    
    ) 
    RETURN DATE ;    
    
    FUNCTION TO_REPORT
    (
        I_SLA_RESULT_RECORD SLA_RESULT_RECORD,
        I_DATE_TYPE     VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION LOOKUP_LABEL 
    (
        I_ID NUMBER
    ) 
    RETURN VARCHAR2;

END;
/
create or replace PACKAGE BODY              "SLA_PKS" as

FUNCTION LOOKUP_LABEL 
(
    I_ID NUMBER
) 
RETURN VARCHAR2
IS
    V_RESULT VARCHAR2(100);
BEGIN
    SELECT TBL_LABEL
      INTO V_RESULT
      FROM TBL_LOOKUP 
     WHERE TBL_ID = I_ID;

    RETURN V_RESULT;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;

FUNCTION NEW_TIMEZONE(
    I_DATE             DATE,
    I_TIMEZONE_OFFSET  IN FLOAT
)
RETURN DATE
IS  
    V_DT            DATE;
BEGIN
    IF I_DATE IS NULL THEN
        RETURN NULL;
    END IF;
    
    EXECUTE IMMEDIATE 'SELECT TO_DATE('''||TO_CHAR(I_DATE,'YYYYMMDDHH24MISS')||''', ''YYYYMMDDHH24MISS'') + INTERVAL '''||I_TIMEZONE_OFFSET||''' HOUR FROM DUAL' INTO V_DT;
    RETURN V_DT;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;

FUNCTION GET_TIMEZONE_OFFSET(
    I_TIMEZONE  IN VARCHAR2 DEFAULT 'America/New_York'
)
RETURN FLOAT
IS
   V_TZ_OFFSET     VARCHAR2(10); 
BEGIN   
    V_TZ_OFFSET := TZ_OFFSET(I_TIMEZONE);
    RETURN SIGN(TO_NUMBER(SUBSTR(V_TZ_OFFSET, 1, 3))) * (TO_NUMBER(SUBSTR(V_TZ_OFFSET, 2, 2)) + TO_NUMBER(SUBSTR(V_TZ_OFFSET, 5, 2)) / 60);
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;

FUNCTION TO_REPORT
(
    I_SLA_RESULT_RECORD SLA_RESULT_RECORD,
    I_DATE_TYPE     VARCHAR2
    
) RETURN VARCHAR2
IS
    V_RESULT VARCHAR2(20);
BEGIN
    IF I_DATE_TYPE = 'ASD' THEN
        IF I_SLA_RESULT_RECORD.ASD_STR IS NULL THEN
            IF I_SLA_RESULT_RECORD.ASD IS NULL THEN
                V_RESULT := 'TBD';
            ELSE
                V_RESULT := TO_CHAR(I_SLA_RESULT_RECORD.ASD, 'MM/DD/YYYY');
            END IF;
        ELSE
            V_RESULT := I_SLA_RESULT_RECORD.ASD_STR;
        END IF;
    ELSIF I_DATE_TYPE = 'ACD' THEN
        IF I_SLA_RESULT_RECORD.ACD_STR IS NULL THEN
            IF I_SLA_RESULT_RECORD.ACD IS NULL THEN
                V_RESULT := 'TBD';
            ELSE
                V_RESULT := TO_CHAR(I_SLA_RESULT_RECORD.ACD, 'MM/DD/YYYY');
            END IF;
        ELSE
            V_RESULT := I_SLA_RESULT_RECORD.ACD_STR;
        END IF;
    ELSIF I_DATE_TYPE = 'TCD' THEN
        IF I_SLA_RESULT_RECORD.TCD_STR IS NULL THEN
            IF I_SLA_RESULT_RECORD.TCD IS NULL THEN
                V_RESULT := 'N/A';
            ELSE
                V_RESULT := TO_CHAR(I_SLA_RESULT_RECORD.TCD, 'MM/DD/YYYY');
            END IF;
        ELSE
            V_RESULT := I_SLA_RESULT_RECORD.TCD_STR;
        END IF;
    END IF;
    RETURN V_RESULT;
END TO_REPORT;

FUNCTION GET_HIRING_TIMELINE_SLA
  (
    I_REQUEST_NUMBER IN VARCHAR2,
    I_CALENDAR_TYPE  IN VARCHAR2 DEFAULT 'Calendar',
    I_TIMEZONE       IN VARCHAR2 DEFAULT 'America/New_York'
  )
RETURN SLA_RESULT_TABLE 
IS
    REQ_TYPE_CLASSIFICATION_ONLY   CONSTANT NUMBER := 17; -- Classification Only
    REQ_TYPE_RECRUITMENT           CONSTANT NUMBER := 18; -- Recruitment
    REQ_TYPE_APPOINTMENT           CONSTANT NUMBER := 76; -- Appointment
    APP_TYPE_30_MORE_DISABLED_VET  CONSTANT NUMBER := 641;

    V_RESULT               HIRING_TIMELINE_TABLE := HIRING_TIMELINE_TABLE();
    V_SLA_ACTIVITY_TBL     SLA_ACTIVITY_TABLE;
    V_SLA_RESULT_TBL       SLA_RESULT_TABLE;
    V_CANCEL_DT            DATE;
    V_PREV_TCD             DATE;
    V_REQUEST_TYPE_ID      NUMBER(10);
    V_REQUEST_STATUS_USA_STAFF VARCHAR2(50);
    V_ADMIN_CODE            VARCHAR2(50);

    V_CLASS_TYPE_ID         NUMBER(10);
    V_APPOINTMENT_TYPE_ID   NUMBER(10);
    V_CLASS_MAJOR_FLAG      CHAR(1);
    V_TIMEZONE_OFFSET       FLOAT(4);
    V_IS_BUSINESS_CAL       BOOLEAN := TRUE;

    IDX                     INT;

BEGIN
    -- Get all normal activities
    /*
    SELECT SLA_ACTIVITY_RECORD(P.NAME, A.NAME, A.STARTDTIME, A.CMPLTDTIME)
      BULK COLLECT INTO V_SLA_ACTIVITY_TBL
      FROM BIZFLOW.PROCDEF P 
           JOIN BIZFLOW.ACT A ON P.PROCDEFID = A.DEFPROCDEFID 
           JOIN BIZFLOW.RLVNTDATA R ON R.PROCID = A.PROCID 
     WHERE R.RLVNTDATANAME = 'requestNum' 
       AND R.VALUE = I_REQUEST_NUMBER
       AND A.TYPE = 'P'
       AND A.STATE != 'D'
       AND A.STARTDTIME IS NOT NULL;
    */

    -- Get general information
    BEGIN
        SELECT R.REQ_CANCEL_DT,
               SG.SG_ADMIN_CD, 
               SG.SG_RT_ID, -- Request Type ID
               SG.SG_CT_ID,
               SG.SG_AT_ID,
               CASE WHEN SG.SG_CT_ID IN (68,72,77,80,83,86) THEN 'T' ELSE 'F' END -- Classification Type: 'Create New Position Description', 'Update Major Duties'
          INTO V_CANCEL_DT,
               V_ADMIN_CODE,
               V_REQUEST_TYPE_ID,
               V_CLASS_TYPE_ID,
               V_APPOINTMENT_TYPE_ID,
               V_CLASS_MAJOR_FLAG
          FROM REQUEST R
               LEFT OUTER JOIN STRATCON_GEN SG ON SG.SG_REQ_ID = R.REQ_ID
         WHERE R.REQ_JOB_REQ_NUMBER = I_REQUEST_NUMBER;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;

    -- Get USA Staffing data
    BEGIN
        SELECT REQUEST_STATUS
          INTO V_REQUEST_STATUS_USA_STAFF
          FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS 
         WHERE REQUEST_NUMBER = I_REQUEST_NUMBER
           AND ROWNUM = 1
         ORDER BY ANNOUNCEMENT_OPEN_DATE DESC;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        V_REQUEST_STATUS_USA_STAFF := NULL;
    END;

    V_TIMEZONE_OFFSET := GET_TIMEZONE_OFFSET(I_TIMEZONE);
    IF UPPER(I_CALENDAR_TYPE) = 'BUSINESS' THEN
        V_IS_BUSINESS_CAL := TRUE;
    ELSE
        V_IS_BUSINESS_CAL := FALSE;
    END IF;

    --  TEST ---
    --V_REQUEST_TYPE_ID := REQ_TYPE_APPOINTMENT;
    --V_CLASS_TYPE_ID := 0;
    --V_APPOINTMENT_TYPE_ID :=642;
    -------

    SELECT SLA_RESULT_RECORD(SLA_ID,PROCESS_NAME,ACTIVITY_NAME,SG_RT_ID,TARGET_BUSINESS_DAY,TOTAL_CALENDAR_DAY,DISPLAY_ORDER,NULL,NULL,NULL,NULL,NULL,NULL)
      BULK COLLECT INTO V_SLA_RESULT_TBL
      FROM SLA_HIRING_TIMELINE
     WHERE SG_RT_ID = V_REQUEST_TYPE_ID
       AND (CLASS_MAJOR IS NULL OR CLASS_MAJOR = V_CLASS_MAJOR_FLAG)
     ORDER BY DISPLAY_ORDER;

    -- Calculate Activity Start Date (ASD), Actual Completion Date (ACD), and Target Completion Date (TCD)
    FOR IDX IN V_SLA_RESULT_TBL.FIRST..V_SLA_RESULT_TBL.LAST LOOP
        IF V_REQUEST_STATUS_USA_STAFF = 'Request Cancelled' THEN
            -- Eligibility and Qualifications Review, and Offer section 
            --IF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_EQRA%' ESCAPE '\' OR V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_O\_%' ESCAPE '\' THEN
                V_SLA_RESULT_TBL(IDX).ASD_STR := 'N/A';
                V_SLA_RESULT_TBL(IDX).ACD_STR := 'N/A';
                V_SLA_RESULT_TBL(IDX).TCD_STR := 'N/A';
                CONTINUE;
            --END IF; 
        END IF;
        IF V_REQUEST_TYPE_ID = REQ_TYPE_CLASSIFICATION_ONLY THEN
            IF V_CLASS_TYPE_ID in (70,73) THEN --Update Coversheet, Reorganization Pen & Ink
                IF V_SLA_RESULT_TBL(IDX).SLA_ID IN ('C_SC_2','C_SC_3','C_SC_4') THEN
                    V_SLA_RESULT_TBL(IDX).ASD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).ACD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).TCD_STR := 'N/A';
                    CONTINUE;
                END IF;                
            ELSIF  V_CLASS_TYPE_ID = 75 THEN --Review Existing Position Description
                IF V_SLA_RESULT_TBL(IDX).SLA_ID IN ('C_SC_2','C_SC_3') OR V_SLA_RESULT_TBL(IDX).SLA_ID LIKE 'C\_C%' ESCAPE '\' THEN
                    V_SLA_RESULT_TBL(IDX).ASD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).ACD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).TCD_STR := 'N/A';
                    CONTINUE;
                END IF;
            END IF;
        ELSIF V_REQUEST_TYPE_ID = REQ_TYPE_RECRUITMENT THEN
            IF V_CLASS_TYPE_ID = 82 THEN -- Review Existing Position Description
                IF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE 'R\_C%' ESCAPE '\' THEN
                    V_SLA_RESULT_TBL(IDX).ASD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).ACD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).TCD_STR := 'N/A';
                    CONTINUE;
                END IF; 
            END IF;
        ELSIF V_REQUEST_TYPE_ID = REQ_TYPE_APPOINTMENT THEN
            IF V_APPOINTMENT_TYPE_ID = 642 THEN -- Expert/Consultant
                IF V_SLA_RESULT_TBL(IDX).SLA_ID IN ('A_SC_2','A_SC_3','A_SC_4','A_EQRA_2') OR V_SLA_RESULT_TBL(IDX).SLA_ID LIKE 'A\_C%' ESCAPE '\'  OR V_SLA_RESULT_TBL(IDX).SLA_ID LIKE 'A\_O%' ESCAPE '\' THEN
                    V_SLA_RESULT_TBL(IDX).ASD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).ACD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).TCD_STR := 'N/A';
                    CONTINUE;
                END IF; 
            ELSIF V_APPOINTMENT_TYPE_ID = 646 THEN -- Volunteer
                IF V_SLA_RESULT_TBL(IDX).SLA_ID IN ('A_SC_2','A_SC_3','A_SC_4','A_EQRA_2') OR V_SLA_RESULT_TBL(IDX).SLA_ID LIKE 'A\_C%' ESCAPE '\'  OR V_SLA_RESULT_TBL(IDX).SLA_ID LIKE 'A\_O%' ESCAPE '\' THEN
                    V_SLA_RESULT_TBL(IDX).ASD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).ACD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).TCD_STR := 'N/A';
                    CONTINUE;
                END IF; 
            ELSIF V_CLASS_TYPE_ID = 87 THEN -- Review Existing Position Description
                IF V_SLA_RESULT_TBL(IDX).SLA_ID IN ('A_SC_2','A_SC_3') OR V_SLA_RESULT_TBL(IDX).SLA_ID LIKE 'A\_C%' ESCAPE '\' THEN
                    V_SLA_RESULT_TBL(IDX).ASD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).ACD_STR := 'N/A';
                    V_SLA_RESULT_TBL(IDX).TCD_STR := 'N/A';
                    CONTINUE;
                END IF; 
            END IF;
        END IF;

        V_SLA_RESULT_TBL(IDX).ASD := GET_ACT_DATETIME(I_REQUEST_NUMBER, V_SLA_RESULT_TBL(IDX).PROCESS_NAME, V_SLA_RESULT_TBL(IDX).ACTIVITY_NAME, 'START');
        V_SLA_RESULT_TBL(IDX).ACD := GET_ACT_DATETIME(I_REQUEST_NUMBER, V_SLA_RESULT_TBL(IDX).PROCESS_NAME, V_SLA_RESULT_TBL(IDX).ACTIVITY_NAME, 'END');

        IF V_SLA_RESULT_TBL(IDX).ASD IS NOT NULL THEN
            
            -- Change to local timezone
            IF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_SC%' ESCAPE '\' OR V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_C%' ESCAPE '\' OR V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_EQRA%' ESCAPE '\' THEN
                V_SLA_RESULT_TBL(IDX).ASD := NEW_TIMEZONE(V_SLA_RESULT_TBL(IDX).ASD, V_TIMEZONE_OFFSET);
                V_SLA_RESULT_TBL(IDX).ACD := NEW_TIMEZONE(V_SLA_RESULT_TBL(IDX).ACD, V_TIMEZONE_OFFSET);
            END IF;            
            
            IF V_IS_BUSINESS_CAL THEN
                V_SLA_RESULT_TBL(IDX).TCD :=  BIZFLOW.HHS_FN_ADD_BUSDAY(V_SLA_RESULT_TBL(IDX).ASD, V_SLA_RESULT_TBL(IDX).TARGET_BUSINESS_DAY);
            ELSE
                V_SLA_RESULT_TBL(IDX).TCD :=  V_SLA_RESULT_TBL(IDX).ASD + V_SLA_RESULT_TBL(IDX).TOTAL_CALENDAR_DAY;
            END IF;
        END IF;


        --DBMS_OUTPUT.PUT_LINE('V_PREV_TCD='||TO_CHAR(V_PREV_TCD, 'MM/DD/YYYY'));
                
        IF V_SLA_RESULT_TBL(IDX).TCD IS NULL THEN
            IF V_IS_BUSINESS_CAL THEN
                --DBMS_OUTPUT.PUT_LINE(IDX||': '||V_SLA_RESULT_TBL(IDX).SLA_ID||': TARGET_BUSINESS_DAY='||V_SLA_RESULT_TBL(IDX).TARGET_BUSINESS_DAY);
                V_SLA_RESULT_TBL(IDX).TCD :=  BIZFLOW.HHS_FN_ADD_BUSDAY(V_PREV_TCD, V_SLA_RESULT_TBL(IDX).TARGET_BUSINESS_DAY);
            ELSE
                --DBMS_OUTPUT.PUT_LINE(IDX||': '||V_SLA_RESULT_TBL(IDX).SLA_ID||': TOTAL_CALENDAR_DAY='||V_SLA_RESULT_TBL(IDX).TOTAL_CALENDAR_DAY);
                V_SLA_RESULT_TBL(IDX).TCD :=  V_PREV_TCD + V_SLA_RESULT_TBL(IDX).TOTAL_CALENDAR_DAY;
            END IF;
        END IF;

        V_PREV_TCD := V_SLA_RESULT_TBL(IDX).TCD;

        IF V_SLA_RESULT_TBL(IDX).ASD_STR IS NULL THEN
            V_SLA_RESULT_TBL(IDX).ASD_STR := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
        END IF;
        IF V_SLA_RESULT_TBL(IDX).ACD_STR IS NULL THEN
            V_SLA_RESULT_TBL(IDX).ACD_STR := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
        END IF;
        IF V_SLA_RESULT_TBL(IDX).TCD_STR IS NULL THEN
            V_SLA_RESULT_TBL(IDX).TCD_STR := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        END IF;

    END LOOP;

    RETURN V_SLA_RESULT_TBL;
END GET_HIRING_TIMELINE_SLA;

FUNCTION GET_HIRING_TIMELINE 
  (
    I_REQUEST_NUMBER IN VARCHAR2,
    I_CALENDAR_TYPE  IN VARCHAR2 DEFAULT 'Calendar',
    I_TIMEZONE       IN VARCHAR2 DEFAULT 'America/New_York'
  )
RETURN HIRING_TIMELINE_TABLE 
IS
    REQ_TYPE_CLASSIFICATION_ONLY   CONSTANT NUMBER := 17; -- Classification Only
    REQ_TYPE_RECRUITMENT           CONSTANT NUMBER := 18; -- Recruitment
    REQ_TYPE_APPOINTMENT           CONSTANT NUMBER := 76; -- Appointment
    APP_TYPE_30_MORE_DISABLED_VET  CONSTANT NUMBER := 641;

    V_RESULT               HIRING_TIMELINE_TABLE := HIRING_TIMELINE_TABLE();
    V_SLA_ACTIVITY_TBL     SLA_ACTIVITY_TABLE;
    V_SLA_RESULT_TBL       SLA_RESULT_TABLE;
    V_CLASS_MAJOR_FLAG     CHAR(1);
    V_CANCEL_DT            DATE;
    V_PREV_TCD             DATE;
    V_TH_REC               HIRING_TIMELINE_RECORD := HIRING_TIMELINE_RECORD(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                                            NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                                            NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                                            NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                                                            NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

BEGIN

    V_SLA_RESULT_TBL := GET_HIRING_TIMELINE_SLA(TRIM(I_REQUEST_NUMBER), TRIM(I_CALENDAR_TYPE), I_TIMEZONE);

    V_TH_REC.REQUEST_NUMBER := I_REQUEST_NUMBER;

    -- Get general information
    BEGIN
        SELECT R.REQ_CANCEL_DT,
               TO_CHAR(R.REQ_JOB_REQ_CREATE_DT,'MM/DD/YYYY'),            
               SG.SG_ADMIN_CD, 
               SG.SG_RT_ID, -- Request Type ID
               LOOKUP_LABEL(SG.SG_RT_ID), -- Request Type
               LOOKUP_LABEL(SG.SG_CT_ID), -- Class Type
               CASE WHEN SG.SG_AT_ID = APP_TYPE_30_MORE_DISABLED_VET THEN '30% or More Disabled Veterans' ELSE LOOKUP_LABEL(SG.SG_AT_ID) END,  -- Appointment Type
               CASE WHEN SG.SG_CT_ID IN (68,72,77,80,83,86) THEN 'T' ELSE 'F' END -- Classification Type: 'Create New Position Description', 'Update Major Duties'
          INTO V_CANCEL_DT,
               V_TH_REC.CREATE_DATE,
               V_TH_REC.ADMIN_CODE,
               V_TH_REC.REQUEST_TYPE_ID,
               V_TH_REC.REQUEST_TYPE,
               V_TH_REC.CLASS_TYPE,
               V_TH_REC.APPOINTMENT_TYPE,
               V_CLASS_MAJOR_FLAG
          FROM REQUEST R
               LEFT OUTER JOIN STRATCON_GEN SG ON SG.SG_REQ_ID = R.REQ_ID
         WHERE R.REQ_JOB_REQ_NUMBER = I_REQUEST_NUMBER;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;

    -- Get USA Staffing data
    BEGIN
        SELECT REQUEST_STATUS
          INTO V_TH_REC.REQUEST_STATUS_USA_STAFF
          FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS 
         WHERE REQUEST_NUMBER = I_REQUEST_NUMBER
           AND ROWNUM = 1
         ORDER BY ANNOUNCEMENT_OPEN_DATE DESC;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        V_TH_REC.REQUEST_STATUS_USA_STAFF := NULL;
    END;

    -- Set Summary
    V_TH_REC.SUMMARY := 'NEIL Request Number '||I_REQUEST_NUMBER||CHR(10);
    IF V_TH_REC.CLASS_TYPE IS NOT NULL THEN
        V_TH_REC.SUMMARY := V_TH_REC.SUMMARY ||'Classification Type: '||V_TH_REC.CLASS_TYPE||CHR(10);
    END IF;
    
    IF V_TH_REC.REQUEST_TYPE_ID = REQ_TYPE_APPOINTMENT THEN
        V_TH_REC.SUMMARY := V_TH_REC.SUMMARY || V_TH_REC.APPOINTMENT_TYPE || ' ' || V_TH_REC.REQUEST_TYPE ||' Request Created on '|| V_TH_REC.CREATE_DATE;
    ELSE
        V_TH_REC.SUMMARY := V_TH_REC.SUMMARY || ' ' || V_TH_REC.REQUEST_TYPE ||' Request Created on '|| V_TH_REC.CREATE_DATE;
    END IF;

    IF V_TH_REC.ADMIN_CODE IS NOT NULL THEN
        V_TH_REC.SUMMARY := V_TH_REC.SUMMARY || ' for ' || V_TH_REC.ADMIN_CODE ;
    END IF;


    -- Set section title
    IF V_TH_REC.REQUEST_TYPE_ID = REQ_TYPE_APPOINTMENT THEN
        V_TH_REC.TTL_STRATEGIC_CONSULTATION := 'Strategic Consultation (Appointment Actions)';
    ELSIF V_TH_REC.REQUEST_TYPE_ID = REQ_TYPE_CLASSIFICATION_ONLY THEN
        V_TH_REC.TTL_STRATEGIC_CONSULTATION := 'Strategic Consultation (Classification Only Actions)';
    ELSIF V_TH_REC.REQUEST_TYPE_ID = REQ_TYPE_RECRUITMENT THEN
        V_TH_REC.TTL_STRATEGIC_CONSULTATION := 'Strategic Consultation (Recruitment Actions)';
    END IF;
    V_TH_REC.TTL_CLASSIFICATION := 'Classification';
    V_TH_REC.TTL_RECRUITMENT := 'Recruitment';
    V_TH_REC.TTL_OFFER := 'Offer';

    -- Show/hide section
    V_TH_REC.SHOW_STRATEGIC_CONSULTATION := 'T';
    V_TH_REC.SHOW_CLASSIFICATION := 'T';
    V_TH_REC.SHOW_EQRA := 'F';
    V_TH_REC.SHOW_RECRUITMENT := 'F';
    V_TH_REC.SHOW_OFFER := 'F';

    -- Binding to column
    FOR IDX IN V_SLA_RESULT_TBL.FIRST..V_SLA_RESULT_TBL.LAST LOOP
        IF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_SC\_1' ESCAPE '\' THEN
            V_TH_REC.SC_1_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.SC_1_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.SC_1_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_SC\_2' ESCAPE '\' THEN
            V_TH_REC.SC_2_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.SC_2_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.SC_2_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_SC\_3' ESCAPE '\' THEN
            V_TH_REC.SC_3_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.SC_3_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.SC_3_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_SC\_4' ESCAPE '\' THEN
            V_TH_REC.SC_4_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.SC_4_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.SC_4_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_CM_\_1' ESCAPE '\' THEN
            V_TH_REC.CM_1_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.CM_1_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.CM_1_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_CM_\_2' ESCAPE '\' THEN
            V_TH_REC.CM_2_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.CM_2_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.CM_2_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_CM_\_3' ESCAPE '\' THEN
            V_TH_REC.CM_3_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.CM_3_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.CM_3_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_CM_\_4' ESCAPE '\' THEN
            V_TH_REC.CM_4_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.CM_4_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.CM_4_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_CM_\_5' ESCAPE '\' THEN
            V_TH_REC.CM_5_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.CM_5_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.CM_5_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_R\_1' ESCAPE '\' THEN
            V_TH_REC.SHOW_RECRUITMENT := 'T';
            V_TH_REC.R_1_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.R_1_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.R_1_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_R\_2' ESCAPE '\' THEN
            V_TH_REC.R_2_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.R_2_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.R_2_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_R\_3' ESCAPE '\' THEN
            V_TH_REC.R_3_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.R_3_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.R_3_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_R\_4' ESCAPE '\' THEN
            V_TH_REC.R_4_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.R_4_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.R_4_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_R\_5' ESCAPE '\' THEN
            V_TH_REC.R_5_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.R_5_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.R_5_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_R\_6' ESCAPE '\' THEN
            V_TH_REC.R_6_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.R_6_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.R_6_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_R\_7' ESCAPE '\' THEN
            V_TH_REC.R_7_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.R_7_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.R_7_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_EQRA\_1' ESCAPE '\' THEN
            V_TH_REC.SHOW_EQRA := 'T';
            V_TH_REC.EQRA_1_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.EQRA_1_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.EQRA_1_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_EQRA\_2' ESCAPE '\' THEN
            V_TH_REC.EQRA_2_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.EQRA_2_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.EQRA_2_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');            
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_O\_1' ESCAPE '\' THEN
            V_TH_REC.SHOW_OFFER := 'T';
            V_TH_REC.O_1_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.O_1_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.O_1_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_O\_2' ESCAPE '\' THEN
            V_TH_REC.O_2_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.O_2_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.O_2_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_O\_3' ESCAPE '\' THEN
            V_TH_REC.O_3_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.O_3_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.O_3_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_O\_4' ESCAPE '\' THEN
            V_TH_REC.O_4_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.O_4_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.O_4_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_O\_5' ESCAPE '\' THEN
            V_TH_REC.O_5_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.O_5_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.O_5_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        ELSIF V_SLA_RESULT_TBL(IDX).SLA_ID LIKE '_\_O\_6' ESCAPE '\' THEN
            V_TH_REC.O_6_ASD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ASD');
            V_TH_REC.O_6_ACD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'ACD');
            V_TH_REC.O_6_TCD := TO_REPORT(V_SLA_RESULT_TBL(IDX), 'TCD');
        END IF;
    END LOOP;

    V_RESULT.EXTEND;
    V_RESULT(1) := V_TH_REC;

    RETURN V_RESULT;
END GET_HIRING_TIMELINE;

FUNCTION GET_ACT_DATETIME 
(
    I_REQUEST_NUMBER IN VARCHAR2 
    , I_SLA_PROCNM IN VARCHAR2
    , I_SLA_ACTNM IN VARCHAR2 
    , I_DATE_TP IN VARCHAR2 -- START | END
) 
RETURN DATE 
IS
    V_PROCID INTEGER;
    PROCNM VARCHAR2(500);
    DATA_SRC VARCHAR2(10);
    DEBUG_MSG VARCHAR2(1000);
    DT_START DATE;
    DT_COMPLETION DATE;
    ACTNM_1 VARCHAR2(1000);
    ACTNM_2 VARCHAR2(1000);
    ACTNM_3 VARCHAR2(1000);
    ACTNM_4 VARCHAR2(1000);
    ACTNM_5 VARCHAR2(1000);

BEGIN
  /* 
    ------------------------------------------------------------------------------------------   
    SLA Activities
    ------------------------------------------------------------------------------------------
    Strategic Consultation	Acknowledge Strategic Consultation Meeting (Component)
    Strategic Consultation	Approve Strategic Consultation Meeting (HR)
    Strategic Consultation	Create/Review/Modify Request (Component)
    Strategic Consultation	Hold Strategic Consultation Meeting (HR)
    Classification - Major	Approve Coversheet (Component)
    Classification - Major	BUS Code Review (HR)
    Classification - Major	Complete PD Coversheet & Classification Analysis (HR)
    Classification - Major	Confirm Analysis (Component)
    Classification - Major	Create Final Package (HR)
    Classification - Minor	Approve Coversheet (Component)
    Classification - Minor	BUS Code Review (HR)
    Classification - Minor	Complete PD Coversheet & Classification Analysis (HR)
    Classification - Minor	Confirm Analysis (Component)
    Classification - Minor	Create Final Package (HR)
    Eligibility and Qualifications Review Activities	SO Selection Determination (Component)
    Eligibility and Qualifications Review Activities	Staff or Spec. Staff determines eligibility and qualifications (HR)

    Recruitment	Announcement Open Period (Other)
    Recruitment	Certificate Issue (HR)
    Recruitment	Certificate Return (Component)
    Recruitment	Draft announcement (HR)
    Recruitment	Final Edits and Post to USA jobs (HR)
    Recruitment	Qualification Analysis (HR)
    Recruitment	Review Assessment/Announcement (Component)    
    Offer	Complete Pre-Employment Forms & Initiate Background Investigation (HR)
    Offer	Establish Entry on Duty Date (HR)
    Offer	Receive Background Investigation Clearance (Other)
    Offer	Receive Background Investigation Clearance (Security)
    Offer	Receive Tentative Offer Response (Applicant)
    Offer	Send Official Offer (HR)
    Offer	Send Tentative Offer (HR)

    ------------------------------------------------------------------------------------------   
    BizFlow Activities
    ------------------------------------------------------------------------------------------   
    Strategic Consultation	Acknowledge Strat Cons Meeting
    Strategic Consultation	Approve Strat Cons Meeting
    Strategic Consultation	Create Request
    Strategic Consultation	Hold Strategic Consultation Meeting
    Strategic Consultation	Modify Request
    Strategic Consultation	Review Request       Classification	Approve Coversheet and Create Final Pkg
    Classification	Approve PD Coversheet - SO
    Classification	Complete PD Coversheet and Classification Analysis
    Classification	Confirm BUS Code
    Classification	Confirm Classification Analysis
    Classification	Confirm Final BUS Code
    Eligibility and Qualifications Review	Approve Candidate for Appointment
    Eligibility and Qualifications Review	Conduct Eligibility and Qualifications Review
    Eligibility and Qualifications Review	Select Candidate for Appointment
    Eligibility and Qualifications Review	Update the Request
*/

    DBMS_OUTPUT.PUT_LINE('I_REQUEST_NUMBER=' || I_REQUEST_NUMBER);
    DBMS_OUTPUT.PUT_LINE('I_SLA_PROCNM=' || I_SLA_PROCNM);
    DBMS_OUTPUT.PUT_LINE('I_SLA_ACTNM=' || I_SLA_ACTNM);
    DBMS_OUTPUT.PUT_LINE('I_DATE_TP=' || I_DATE_TP);

    IF UPPER(I_SLA_PROCNM) = 'STRATEGIC CONSULTATION' THEN
        PROCNM := 'Strategic Consultation';
    ELSIF UPPER(I_SLA_PROCNM) = 'ELIGIBILITY AND QUALIFICATIONS REVIEW ACTIVITIES' THEN
        PROCNM := 'Eligibility and Qualifications Review';
    ELSIF UPPER(I_SLA_PROCNM) = 'CLASSIFICATION - MAJOR' THEN
        PROCNM := 'Classification';
    ELSIF UPPER(I_SLA_PROCNM) = 'CLASSIFICATION - MINOR' THEN
        PROCNM := 'Classification';
    END IF;

    IF UPPER(I_SLA_PROCNM) = 'OFFER' OR UPPER(I_SLA_PROCNM) = 'RECRUITMENT' THEN
        DATA_SRC := 'USAS'; --USA Staffing table
    ELSE
        DATA_SRC := 'EWITS';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('PROCNM=' || PROCNM);
    DBMS_OUTPUT.PUT_LINE('DATA_SRC=' || DATA_SRC);

    ----------------------------------------------------------------------------------------------------
    IF DATA_SRC = 'EWITS' THEN

        BEGIN
            SELECT P.PROCID
              INTO V_PROCID
              FROM BIZFLOW.RLVNTDATA PV
                    JOIN BIZFLOW.PROCS P ON P.PROCID = PV.PROCID
             WHERE PV.RLVNTDATANAME = 'requestNum'
               AND PV.VALUE = I_REQUEST_NUMBER
               AND P.NAME = PROCNM;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        END;
        DBMS_OUTPUT.PUT_LINE('PROCID=' || V_PROCID);

        --MAP between SLA ACT to BizFlow ACT
        IF UPPER(I_SLA_PROCNM) = 'STRATEGIC CONSULTATION' THEN

            IF UPPER(I_SLA_ACTNM) = UPPER('Create/Review/Modify Request (Component)') THEN
                ACTNM_1 := 'Create Request';
                ACTNM_2 := 'Review Request';
                ACTNM_3 := 'Modify Request';
            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Hold Strategic Consultation Meeting (HR)') THEN
                ACTNM_1 := 'Hold Strategic Consultation Meeting';
            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Acknowledge Strategic Consultation Meeting (Component)') THEN
                ACTNM_1 := 'Acknowledge Strat Cons Meeting';
            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Approve Strategic Consultation Meeting (HR)') THEN
                ACTNM_1 := 'Approve Strat Cons Meeting';
            END IF;

        ELSIF (UPPER(I_SLA_PROCNM) = 'ELIGIBILITY AND QUALIFICATIONS REVIEW ACTIVITIES') THEN

            IF UPPER(I_SLA_ACTNM) = UPPER('SO Selection Determination (Component)') THEN          
                ACTNM_1 := 'Select Candidate for Appointment';
            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Staff or Spec. Staff determines eligibility and qualifications (HR)') THEN
                ACTNM_1 := 'Conduct Eligibility and Qualifications Review';
            END IF;

        ELSIF (UPPER(I_SLA_PROCNM) = 'CLASSIFICATION - MAJOR' 
            OR UPPER(I_SLA_PROCNM) = 'CLASSIFICATION - MINOR') THEN

            IF UPPER(I_SLA_ACTNM) = UPPER('Complete PD Coversheet & Classification Analysis (HR)') THEN
                ACTNM_1 := 'Complete PD Coversheet and Classification Analysis';
            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Confirm Analysis (Component)') THEN
                ACTNM_1 := 'Confirm Classification Analysis';
            ELSIF UPPER(I_SLA_ACTNM) = UPPER('BUS Code Review (HR)') THEN
                ACTNM_1 := 'Confirm BUS Code';
                ACTNM_2 := 'Confirm Final BUS Code';
            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Approve Coversheet (Component)') THEN
                ACTNM_1 := 'Approve PD Coversheet - SO';
            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Create Final Package (HR)') THEN
                ACTNM_1 := 'Approve Coversheet and Create Final Pkg';
            END IF;

        END IF;

        DBMS_OUTPUT.PUT_LINE('ACTNM_1=' || ACTNM_1);
        DBMS_OUTPUT.PUT_LINE('ACTNM_2=' || ACTNM_2);
        DBMS_OUTPUT.PUT_LINE('ACTNM_3=' || ACTNM_3);
        DBMS_OUTPUT.PUT_LINE('ACTNM_4=' || ACTNM_4);
        DBMS_OUTPUT.PUT_LINE('ACTNM_5=' || ACTNM_5);

        IF UPPER(I_DATE_TP) = 'START' THEN
            DBMS_OUTPUT.PUT_LINE('GETTING MIN STARTDTIME PROCID=' || TO_CHAR(V_PROCID));
            SELECT MIN(STARTDTIME)
              INTO DT_START
              FROM BIZFLOW.ACT
             WHERE TYPE = 'P'
               AND STATE != 'D'
               AND PROCID = V_PROCID
               AND NAME IN (ACTNM_1, ACTNM_2, ACTNM_3, ACTNM_4, ACTNM_5);

        ELSE
            DBMS_OUTPUT.PUT_LINE('GETTING max cmpltdtime');
            SELECT MAX(cmpltdtime)
              INTO DT_COMPLETION
              FROM BIZFLOW.ACT
             WHERE TYPE = 'P'
               AND STATE != 'D'
               AND PROCID = V_PROCID
               AND NAME IN (ACTNM_1, ACTNM_2, ACTNM_3, ACTNM_4, ACTNM_5);

         END IF;

    ----------------------------------------------------------------------------------------------------  
    --USA STAFFING
    ELSE 


        IF UPPER(I_SLA_PROCNM) = 'RECRUITMENT' THEN

            IF UPPER(I_SLA_ACTNM) = UPPER('Draft announcement (HR)') THEN
                SELECT MIN(REQUEST_APPROVAL_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(HM_ANN_RVW_SENT_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;  

            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Review Assessment/Announcement (Component)') THEN 
                SELECT MIN(HM_ANN_RVW_SENT_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(HM_ANN_RVW_CMPL_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;      

            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Final Edits and Post to USA jobs (HR)') THEN
                SELECT MIN(HM_ANN_RVW_CMPL_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(ANNOUNCEMENT_OPEN_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;  

            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Announcement Open Period (Other)') THEN
                SELECT MIN(ANNOUNCEMENT_OPEN_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(ANNOUNCEMENT_CLOSE_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;                   

            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Qualification Analysis (HR)') THEN
                SELECT MIN(ANNOUNCEMENT_CLOSE_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(CERTIFICATE_ISSUE_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;  

            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Certificate Issue (HR)') THEN
                SELECT MIN(CERTIFICATE_ISSUE_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(REVIEW_SENT_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;  

            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Certificate Return (Component)') THEN
                SELECT MIN(REVIEW_SENT_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(REVIEW_RETURN_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;  

            END IF;

        ELSIF UPPER(I_SLA_PROCNM) = 'OFFER' THEN

            IF UPPER(I_SLA_ACTNM) = UPPER('Send Tentative Offer (HR)') THEN
                SELECT MIN(NEW_HIRE_CREATE_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(SEND_TENT_OFFR_CMPL_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;   

             ELSIF UPPER(I_SLA_ACTNM) = UPPER('Receive Tentative Offer Response (Applicant)') THEN
                SELECT MIN(SEND_TENT_OFFR_CMPL_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(TENT_OFFR_RSPNS_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;  

            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Complete Pre-Employment Forms & Initiate Background Investigation (HR)') THEN
                SELECT MIN(TENT_OFFR_RSPNS_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(NEW_HIRE_CREATE_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;      

            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Receive Background Investigation Clearance (Other)') THEN
                SELECT MIN(INIT_BKGRND_INVST_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(RCVE_BKGRND_INVST_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;   
            --NOTES: No rule was defined for this SLA activity in the Hiring Timelines 20190520 v1 document.
            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Receive Background Investigation Clearance (Security)') THEN
                SELECT MIN(INIT_BKGRND_INVST_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(RCVE_BKGRND_INVST_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;    

            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Establish Entry on Duty Date (HR)') THEN
                SELECT MIN(RCVE_BKGRND_INVST_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(EOD_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;             

            ELSIF UPPER(I_SLA_ACTNM) = UPPER('Send Official Offer (HR)') THEN
                SELECT MIN(EOD_DATE)
                  INTO DT_START
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;

                SELECT MAX(SEND_OFCL_OFFR_CMPL_DATE)
                  INTO DT_COMPLETION
                  FROM HHS_HR.DSS_CMS_TIME_OF_POSSESS D
                 WHERE D.REQUEST_NUMBER = I_REQUEST_NUMBER
                ;             

            END IF;

        END IF;

    END IF;

    DBMS_OUTPUT.PUT_LINE('>DT_START=' || TO_CHAR(DT_START, 'YYYY/MM/DD'));
    DBMS_OUTPUT.PUT_LINE('>DT_COMPLETION=' || TO_CHAR(DT_COMPLETION, 'YYYY/MM/DD'));

    IF UPPER(I_DATE_TP) = 'START' OR UPPER(I_DATE_TP) = 'S' THEN
        RETURN DT_START;
    ELSE
        RETURN DT_COMPLETION;
    END IF;


END GET_ACT_DATETIME;

END;
/
