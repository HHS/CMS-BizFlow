/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * the Strategic Consultation process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 * @param I_RLVNTDATANAME - the name of a process variable to be updated
 * @param I_XPATH - the xpath of the value of a process variable
 */
CREATE OR REPLACE PROCEDURE SP_UPDATE_PV_BY_XPATH
  (
      I_PROCID            IN      NUMBER
    , I_FIELD_DATA      IN      XMLTYPE
    , I_RLVNTDATANAME   IN     VARCHAR2
    , I_XPATH        IN VARCHAR2
    , I_DISPXPATH        IN VARCHAR2 DEFAULT NULL
  )
IS
  V_XMLVALUE             XMLTYPE;
  V_VALUE                NVARCHAR2(2000);
  V_DISPVALUE                NVARCHAR2(100);
  BEGIN

    IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN

      V_DISPVALUE := NULL;

      V_XMLVALUE := I_FIELD_DATA.EXTRACT(I_XPATH);
      IF V_XMLVALUE IS NOT NULL THEN
        V_VALUE := V_XMLVALUE.GETSTRINGVAL();
      ELSE
        V_VALUE := NULL;
      END IF;

      IF I_DISPXPATH IS NOT NULL THEN
        V_XMLVALUE := I_FIELD_DATA.EXTRACT(I_DISPXPATH);
        IF V_XMLVALUE IS NOT NULL THEN
          V_DISPVALUE := V_XMLVALUE.GETSTRINGVAL();
        ELSE
          V_DISPVALUE := NULL;
        END IF;

      END IF;

      UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_VALUE, DISPVALUE = V_DISPVALUE WHERE RLVNTDATANAME = I_RLVNTDATANAME AND PROCID = I_PROCID;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
  END;

/

--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_INCENTIVES
--------------------------------------------------------

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
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('PARAMETERS ----------------');
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID IS NULL?  = ' || (CASE WHEN I_PROCID IS NULL THEN 'YES' ELSE 'NO' END));
    --DBMS_OUTPUT.PUT_LINE('    I_PROCID           = ' || TO_CHAR(I_PROCID));
    --DBMS_OUTPUT.PUT_LINE('    I_FIELD_DATA       = ' || I_FIELD_DATA.GETCLOBVAL());
    --DBMS_OUTPUT.PUT_LINE(' ----------------');

    IF I_PROCID IS NOT NULL AND I_PROCID > 0 THEN
      --DBMS_OUTPUT.PUT_LINE('Starting PV update ----------');

      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'administrativeCode', '/formData/items/item[id=''administrativeCode'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'associatedIncentives', '/formData/items/item[id=''associatedIncentives'']/value/requestNumber/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'candidateName', '/formData/items/item[id=''candidateName'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'hrSpecialist', '/formData/items/item[id=''hrSpecialist'']/value/participantId/text()', '/formData/items/item[id=''hrSpecialist'']/value/name/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'incentiveType', '/formData/items/item[id=''incentiveType'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'payPlanSeriesGrade', '/formData/items/item[id=''payPlanSeriesGrade'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'positionTitle', '/formData/items/item[id=''positionTitle'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'relatedUserIds', '/formData/items/item[id=''relatedUserIds'']/value/text()');
      SP_UPDATE_PV_BY_XPATH(I_PROCID, I_FIELD_DATA, 'selectingOfficial', '/formData/items/item[id=''selectingOfficial'']/value/participantId/text()', '/formData/items/item[id=''selectingOfficial'']/value/name/text()');

    --DBMS_OUTPUT.PUT_LINE('End PV update  -------------------');

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    SP_ERROR_LOG();
    --DBMS_OUTPUT.PUT_LINE('Error occurred while executing SP_UPDATE_PV_INCENTIVES -------------------');
  END;

/