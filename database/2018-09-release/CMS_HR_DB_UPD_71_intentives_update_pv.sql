--------------------------------------------------------
--  DDL for Procedure SP_UPDATE_PV_BY_XPATH
--------------------------------------------------------

/**
 * Parses the form data xml to retrieve process variable values,
 * and updates process variable table (BIZFLOW.RLVNTDATA) records for the respective
 * the Strategic Consultation process instance identified by the Process ID.
 *
 * @param I_PROCID - Process ID for the target process instance whose process variables should be updated.
 * @param I_FIELD_DATA - Form data xml.
 * @param I_RLVNTDATANAME - the name of a process variable to be updated
 * @param I_XPATH - the xpath of the value of a process variable
 * @param I_DISPXPATH - (optional) the xpath of the display value of a process variable
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
                V_VALUE := UTL_I18N.UNESCAPE_REFERENCE(V_XMLVALUE.GETSTRINGVAL());
            ELSE
                V_VALUE := NULL;
            END IF;

            IF I_DISPXPATH IS NOT NULL THEN
                V_XMLVALUE := I_FIELD_DATA.EXTRACT(I_DISPXPATH);
                IF V_XMLVALUE IS NOT NULL THEN
                    V_DISPVALUE := UTL_I18N.UNESCAPE_REFERENCE(V_XMLVALUE.GETSTRINGVAL());
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