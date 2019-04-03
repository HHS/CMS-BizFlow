create or replace PROCEDURE SP_FINALIZE_ERLR
(
	I_PROCID               IN  NUMBER
)
IS
    V_CNT                   INT;
    V_XMLDOC                XMLTYPE;
    V_XMLVALUE              XMLTYPE;
    V_CASE_TYPE_ID          VARCHAR2(10);
    V_VALUE                 VARCHAR2(100);
    V_NEW_CASE_TYPE_ID      VARCHAR2(10);
    V_NEW_CASE_TYPE_NAME    VARCHAR2(100);
    V_GEN_EMP_ID            VARCHAR2(64);
    V_CASE_NUMBER           NUMBER(10);
    V_TRIGGER_NEW_CASE      BOOLEAN := FALSE;
    YES                     CONSTANT VARCHAR2(3) := 'Yes';
    
    CONDUCT_ISSUE_ID		CONSTANT VARCHAR2(10) :='743';
    CONDUCT_ISSUE			CONSTANT VARCHAR2(50) :='Conduct Issue';
    GRIEVANCE_ID			CONSTANT VARCHAR2(10) :='745';
    GRIEVANCE			    CONSTANT VARCHAR2(50) :='Grievance';
    INVESTIGATION_ID		CONSTANT VARCHAR2(10) :='744';
    INVESTIGATION			CONSTANT VARCHAR2(50) :='Investigation';
    LABOR_NEGOTIATION_ID	CONSTANT VARCHAR2(10) :='748';
    LABOR_NEGOTIATION		CONSTANT VARCHAR2(50) :='Labor Negotiation';
    MEDICAL_DOCUMENTATION_ID CONSTANT VARCHAR2(10) :='746';
    MEDICAL_DOCUMENTATION	CONSTANT VARCHAR2(50) :='Medical Documentation';
    PERFORMANCE_ISSUE_ID	CONSTANT VARCHAR2(10) :='750';
    PERFORMANCE_ISSUE		CONSTANT VARCHAR2(50) :='Performance Issue';
    PROBATIONARY_PERIOD_ID	CONSTANT VARCHAR2(10) :='751';
    PROBATIONARY_PERIOD		CONSTANT VARCHAR2(50) :='Probationary Period Action';
    UNFAIR_LABOR_PRACTICES_ID	CONSTANT VARCHAR2(10) :='754';
    UNFAIR_LABOR_PRACTICES	CONSTANT VARCHAR2(50) :='Unfair Labor Practices';
    WGI_DENIAL_ID			CONSTANT VARCHAR2(10) :='809';
    WGI_DENIAL			    CONSTANT VARCHAR2(50) :='Within Grade Increase Denial/Reconsideration';    
    INFORMATION_REQUEST_ID  CONSTANT VARCHAR2(10) := '747';    
    THIRD_PARTY_HEARING_ID  CONSTANT VARCHAR2(10) := '753';    
    THIRD_PARTY_HEARING     CONSTANT VARCHAR2(50) := 'Third Party Hearing';
    ACTION_TYPE_COUNSELING_ID CONSTANT VARCHAR2(10) := '785';
    ACTION_TYPE_PIP_ID      CONSTANT VARCHAR2(10) := '787';
    ACTION_TYPE_WNR_ID      CONSTANT VARCHAR2(10) := '790';    
    REASON_FMLA_ID          CONSTANT VARCHAR2(10) := '1650';
    ACTION_TYPE_CLPD        CONSTANT VARCHAR2(10) := '1794';    
BEGIN
    SELECT FIELD_DATA
      INTO V_XMLDOC
      FROM TBL_FORM_DTL
     WHERE PROCID = I_PROCID;

    V_CASE_TYPE_ID := V_XMLDOC.EXTRACT('/formData/items/item[id="GEN_CASE_TYPE"]/value/text()').getStringVal();        
    V_CASE_NUMBER  := TO_NUMBER(V_XMLDOC.EXTRACT('/formData/items/item[id="CASE_NUMBER"]/value/text()').getStringVal());    
    V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="GEN_EMPLOYEE_ID"]/value/text()');
    IF V_XMLVALUE IS NOT NULL THEN
        V_GEN_EMP_ID := V_XMLVALUE.GETSTRINGVAL();
    END IF;
    
    IF V_CASE_TYPE_ID = INFORMATION_REQUEST_ID THEN -- Information Request
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="IR_APPEAL_DENIAL"]/value/text()'); -- Did Requester Appeal Denial?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN
            V_NEW_CASE_TYPE_ID   := THIRD_PARTY_HEARING_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;
    ELSIF V_CASE_TYPE_ID = INVESTIGATION_ID THEN -- Investigation
        -- Triggering Conduct Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="I_MISCONDUCT_FOUND"]/value/text()'); --Was Misconduct Found?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN
            V_NEW_CASE_TYPE_ID   := CONDUCT_ISSUE_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;
    ELSIF V_CASE_TYPE_ID = MEDICAL_DOCUMENTATION_ID THEN -- Medical Documentation
        -- Triggering Grievance Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="MD_REQUEST_REASON"]/value/text()'); -- Reason for Request
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = REASON_FMLA_ID THEN  -- FMLA      
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="MD_FMLA_GRIEVANCE"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
        END IF;
    ELSIF V_CASE_TYPE_ID = LABOR_NEGOTIATION_ID THEN -- Labor Negotiation
        -- Triggering Unfair Labor Practices Case
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="LN_FILE_ULP"]/value/text()');--Did Union File ULP?
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = YES THEN        
            V_NEW_CASE_TYPE_ID   := UNFAIR_LABOR_PRACTICES_ID;
            UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
        END IF;        
    ELSIF V_CASE_TYPE_ID = PERFORMANCE_ISSUE_ID THEN -- Performance Issue
        V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_ACTION_TYPE"]/value/text()');
        IF V_XMLVALUE IS NOT NULL THEN
            V_VALUE := V_XMLVALUE.GETSTRINGVAL();
        END IF;
        
        IF V_VALUE = ACTION_TYPE_COUNSELING_ID THEN -- Action Type: Counseling
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_CNSL_GRV_DECISION"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
        ELSIF V_VALUE = ACTION_TYPE_PIP_ID THEN -- Action Type: PIP
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_PIP_EMPL_GRIEVANCE"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;
            
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_PIP_WGI_WTHLD"]/value/text()'); --Was WGI Withheld?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := WGI_DENIAL_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID2' AND PROCID = I_PROCID;
            END IF;
        ELSIF V_VALUE = ACTION_TYPE_WNR_ID THEN -- Action Type: Written Narrative Review
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_WNR_WGI_WTHLD"]/value/text()'); -- Was WGI Withheld?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := WGI_DENIAL_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;        
        ELSIF V_VALUE = ACTION_TYPE_CLPD THEN -- Action Type: Career Ladder Promotion Denial
            -- Triggering Grievance Case
            V_XMLVALUE := V_XMLDOC.EXTRACT('/formData/items/item[id="PI_CLPD_EMP_GRIEVANCE"]/value/text()'); -- Did Employee File a Grievance?
            IF V_XMLVALUE IS NOT NULL THEN
                V_VALUE := V_XMLVALUE.GETSTRINGVAL();
            END IF;
            
            IF V_VALUE = YES THEN
                V_NEW_CASE_TYPE_ID   := GRIEVANCE_ID;
                UPDATE BIZFLOW.RLVNTDATA SET VALUE = V_NEW_CASE_TYPE_ID WHERE RLVNTDATANAME = 'triggeringCaseTypeID1' AND PROCID = I_PROCID;
            END IF;            
        END IF;
    END IF;
    
EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
END;