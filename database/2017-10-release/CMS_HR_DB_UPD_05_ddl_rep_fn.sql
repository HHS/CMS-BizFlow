SET DEFINE OFF;


--------------------------------------------------------
--  DDL for Function FN_GET_GRADE_ADVRT
--------------------------------------------------------

/**
 * Gets Grade Advertized value.
 *
 * @param POS_GA_1 through 15 - Grade Advertized field values.
 *
 * @return NVARCHAR2 - Concatenated Grade Advertized values delimitted by semicolon.
 */
CREATE OR REPLACE FUNCTION FN_GET_GRADE_ADVRT
(
	I_POS_GA_1                 IN  VARCHAR2
	, I_POS_GA_2               IN  VARCHAR2
	, I_POS_GA_3               IN  VARCHAR2
	, I_POS_GA_4               IN  VARCHAR2
	, I_POS_GA_5               IN  VARCHAR2
	, I_POS_GA_6               IN  VARCHAR2
	, I_POS_GA_7               IN  VARCHAR2
	, I_POS_GA_8               IN  VARCHAR2
	, I_POS_GA_9               IN  VARCHAR2
	, I_POS_GA_10              IN  VARCHAR2
	, I_POS_GA_11              IN  VARCHAR2
	, I_POS_GA_12              IN  VARCHAR2
	, I_POS_GA_13              IN  VARCHAR2
	, I_POS_GA_14              IN  VARCHAR2
	, I_POS_GA_15              IN  VARCHAR2
)
RETURN NVARCHAR2
IS
	V_RETURN_VAL                NVARCHAR2(100);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_GRADE_ADVRT -------');
	--DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_1  = ' || I_POS_GA_1 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_2  = ' || I_POS_GA_2 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_3  = ' || I_POS_GA_3 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_4  = ' || I_POS_GA_4 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_5  = ' || I_POS_GA_5 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_6  = ' || I_POS_GA_6 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_7  = ' || I_POS_GA_7 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_8  = ' || I_POS_GA_8 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_9  = ' || I_POS_GA_9 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_10 = ' || I_POS_GA_10 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_11 = ' || I_POS_GA_11 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_12 = ' || I_POS_GA_12 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_13 = ' || I_POS_GA_13 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_14 = ' || I_POS_GA_14 );
	--DBMS_OUTPUT.PUT_LINE('    I_POS_GA_15 = ' || I_POS_GA_15 );

	V_RETURN_VAL :=
		CASE WHEN I_POS_GA_1  = '1'    THEN '1; '  ELSE '' END
		|| CASE WHEN I_POS_GA_2  = '1' THEN '2; '  ELSE '' END
		|| CASE WHEN I_POS_GA_3  = '1' THEN '3; '  ELSE '' END
		|| CASE WHEN I_POS_GA_4  = '1' THEN '4; '  ELSE '' END
		|| CASE WHEN I_POS_GA_5  = '1' THEN '5; '  ELSE '' END
		|| CASE WHEN I_POS_GA_6  = '1' THEN '6; '  ELSE '' END
		|| CASE WHEN I_POS_GA_7  = '1' THEN '7; '  ELSE '' END
		|| CASE WHEN I_POS_GA_8  = '1' THEN '8; '  ELSE '' END
		|| CASE WHEN I_POS_GA_9  = '1' THEN '9; '  ELSE '' END
		|| CASE WHEN I_POS_GA_10 = '1' THEN '10; ' ELSE '' END
		|| CASE WHEN I_POS_GA_11 = '1' THEN '11; ' ELSE '' END
		|| CASE WHEN I_POS_GA_12 = '1' THEN '12; ' ELSE '' END
		|| CASE WHEN I_POS_GA_13 = '1' THEN '13; ' ELSE '' END
		|| CASE WHEN I_POS_GA_14 = '1' THEN '14; ' ELSE '' END
		|| CASE WHEN I_POS_GA_15 = '1' THEN '15; ' ELSE '' END
	;
	IF V_RETURN_VAL IS NOT NULL AND LENGTH(V_RETURN_VAL) > 0
		AND SUBSTR(V_RETURN_VAL, (LENGTH(V_RETURN_VAL) - 1)) = '; '
	THEN
		V_RETURN_VAL := SUBSTR(V_RETURN_VAL, 1, (LENGTH(V_RETURN_VAL) - 2));
	END IF;

	--DBMS_OUTPUT.PUT_LINE('    V_RETURN_VAL = ' || V_RETURN_VAL);
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_GET_GRADE_ADVRT -------');
	RETURN V_RETURN_VAL;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_GRADE_ADVRT -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
END;

/




--------------------------------------------------------
--  DDL for Function FN_GET_ANNOUNCE_NOT_REQ
--------------------------------------------------------

/**
 * Gets Areas of Consideration - Announcement Not Required section data.
 *
 * @param I_AOC_30PCT_DISABLED_VETS - 30% or More Disabled Veterans
 * @param I_AOC_EXPERT_CONS - Expert/Consultant
 * @param I_AOC_IPA - Intergovernmental Personnel Act (IPA)
 * @param I_AOC_OPER_WARFIGHTER - Operation Warfighter Program
 * @param I_AOC_DISABILITIES - Schedule A (for persons with disabilities)
 * @param I_AOC_STUDENT_VOL - Student Volunteer Program
 * @param I_AOC_VETS_RECRUIT_APPT - Veterans Recruitment Appointment
 * @param I_AOC_VOC_REHAB_EMPL - Voc. Rehab & Employment Program
 * @param I_AOC_WORKFORCE_RECRUIT - Workforce Recruitment Program
 *
 * @return NVARCHAR2 - Concatenated Announcement Not Required section values delimitted by semicolon.
 */
CREATE OR REPLACE FUNCTION FN_GET_ANNOUNCE_NOT_REQ
(
	I_AOC_30PCT_DISABLED_VETS      IN  VARCHAR2
	, I_AOC_EXPERT_CONS            IN  VARCHAR2
	, I_AOC_IPA                    IN  VARCHAR2
	, I_AOC_OPER_WARFIGHTER        IN  VARCHAR2
	, I_AOC_DISABILITIES           IN  VARCHAR2
	, I_AOC_STUDENT_VOL            IN  VARCHAR2
	, I_AOC_VETS_RECRUIT_APPT      IN  VARCHAR2
	, I_AOC_VOC_REHAB_EMPL         IN  VARCHAR2
	, I_AOC_WORKFORCE_RECRUIT      IN  VARCHAR2
)
RETURN NVARCHAR2
IS
	V_RETURN_VAL                NVARCHAR2(500);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_ANNOUNCE_NOT_REQ -------');
	--DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_30PCT_DISABLED_VETS  = ' || I_AOC_30PCT_DISABLED_VETS );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_EXPERT_CONS          = ' || I_AOC_EXPERT_CONS );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_IPA                  = ' || I_AOC_IPA );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_OPER_WARFIGHTER      = ' || I_AOC_OPER_WARFIGHTER );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_DISABILITIES         = ' || I_AOC_DISABILITIES );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_STUDENT_VOL          = ' || I_AOC_STUDENT_VOL );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_VETS_RECRUIT_APPT    = ' || I_AOC_VETS_RECRUIT_APPT );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_VOC_REHAB_EMPL       = ' || I_AOC_VOC_REHAB_EMPL );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_WORKFORCE_RECRUIT    = ' || I_AOC_WORKFORCE_RECRUIT );

	V_RETURN_VAL :=
		CASE WHEN I_AOC_30PCT_DISABLED_VETS = '1'     THEN '30% or More Disabled Veterans; ' ELSE '' END
		|| CASE WHEN I_AOC_EXPERT_CONS = '1'          THEN 'Expert/Consultant; ' ELSE '' END
		|| CASE WHEN I_AOC_IPA = '1'                  THEN 'Intergovernmental Personnel Act (IPA); ' ELSE '' END
		|| CASE WHEN I_AOC_OPER_WARFIGHTER = '1'      THEN 'Operation Warfighter Program; ' ELSE '' END
		|| CASE WHEN I_AOC_DISABILITIES = '1'         THEN 'Schedule A (for persons with disabilities); ' ELSE '' END
		|| CASE WHEN I_AOC_STUDENT_VOL = '1'          THEN 'Student Volunteer Program; ' ELSE '' END
		|| CASE WHEN I_AOC_VETS_RECRUIT_APPT = '1'    THEN 'Veterans Recruitment Appointment; ' ELSE '' END
		|| CASE WHEN I_AOC_VOC_REHAB_EMPL = '1'       THEN 'Voc. Rehab & Employment Program; ' ELSE '' END
		|| CASE WHEN I_AOC_WORKFORCE_RECRUIT = '1'    THEN 'Workforce Recruitment Program; ' ELSE '' END
	;
	IF V_RETURN_VAL IS NOT NULL AND LENGTH(V_RETURN_VAL) > 0
		AND SUBSTR(V_RETURN_VAL, (LENGTH(V_RETURN_VAL) - 1)) = '; '
	THEN
		V_RETURN_VAL := SUBSTR(V_RETURN_VAL, 1, (LENGTH(V_RETURN_VAL) - 2));
	END IF;

	--DBMS_OUTPUT.PUT_LINE('    V_RETURN_VAL = ' || V_RETURN_VAL);
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_GET_ANNOUNCE_NOT_REQ -------');
	RETURN V_RETURN_VAL;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_ANNOUNCE_NOT_REQ -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
END;

/




--------------------------------------------------------
--  DDL for Function FN_GET_ANNOUNCE_REQ
--------------------------------------------------------

/**
 * Gets Areas of Consideration - Announcement Required section data.
 *
 * @param I_AOC_MIL_SPOUSES - Certain Military Spouses
 * @param I_AOC_DIRECT_HIRE - Direct Hire
 * @param I_AOC_RE_EMPLOYMENT - Reemployed Annuitant
 * @param I_AOC_PATHWAYS - Pathways Program (Intern, PMF, RG)
 * @param I_AOC_PEACE_CORPS_VOL - Peace Corps/Volunteers
 * @param I_AOC_REINSTATEMENT - Reinstatement
 * @param I_AOC_SHARED_CERT - Shared Certificate
 *
 * @return NVARCHAR2 - Concatenated Announcement Required section values delimitted by semicolon.
 */
CREATE OR REPLACE FUNCTION FN_GET_ANNOUNCE_REQ
(
	I_AOC_MIL_SPOUSES          IN  VARCHAR2
	, I_AOC_DIRECT_HIRE        IN  VARCHAR2
	, I_AOC_RE_EMPLOYMENT      IN  VARCHAR2
	, I_AOC_PATHWAYS           IN  VARCHAR2
	, I_AOC_PEACE_CORPS_VOL    IN  VARCHAR2
	, I_AOC_REINSTATEMENT      IN  VARCHAR2
	, I_AOC_SHARED_CERT        IN  VARCHAR2
)
RETURN NVARCHAR2
IS
	V_RETURN_VAL                NVARCHAR2(500);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_ANNOUNCE_REQ -------');
	--DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_MIL_SPOUSES      = ' || I_AOC_MIL_SPOUSES );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_DIRECT_HIRE      = ' || I_AOC_DIRECT_HIRE );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_RE_EMPLOYMENT    = ' || I_AOC_RE_EMPLOYMENT );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_PATHWAYS         = ' || I_AOC_PATHWAYS );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_PEACE_CORPS_VOL  = ' || I_AOC_PEACE_CORPS_VOL );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_REINSTATEMENT    = ' || I_AOC_REINSTATEMENT );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_SHARED_CERT      = ' || I_AOC_SHARED_CERT );

	V_RETURN_VAL :=
		CASE WHEN I_AOC_MIL_SPOUSES = '1'           THEN 'Certain Military Spouses; ' ELSE '' END
		|| CASE WHEN I_AOC_DIRECT_HIRE = '1'        THEN 'Direct Hire; ' ELSE '' END
		|| CASE WHEN I_AOC_RE_EMPLOYMENT = '1'      THEN 'Reemployed Annuitant; ' ELSE '' END
		|| CASE WHEN I_AOC_PATHWAYS = '1'           THEN 'Pathways Program (Intern, PMF, RG); ' ELSE '' END
		|| CASE WHEN I_AOC_PEACE_CORPS_VOL = '1'    THEN 'Peace Corps/Volunteers; ' ELSE '' END
		|| CASE WHEN I_AOC_REINSTATEMENT = '1'      THEN 'Reinstatement; ' ELSE '' END
		|| CASE WHEN I_AOC_SHARED_CERT = '1'        THEN 'Shared Certificate; ' ELSE '' END
	;
	IF V_RETURN_VAL IS NOT NULL AND LENGTH(V_RETURN_VAL) > 0
		AND SUBSTR(V_RETURN_VAL, (LENGTH(V_RETURN_VAL) - 1)) = '; '
	THEN
		V_RETURN_VAL := SUBSTR(V_RETURN_VAL, 1, (LENGTH(V_RETURN_VAL) - 2));
	END IF;

	--DBMS_OUTPUT.PUT_LINE('    V_RETURN_VAL = ' || V_RETURN_VAL);
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_GET_ANNOUNCE_REQ -------');
	RETURN V_RETURN_VAL;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_ANNOUNCE_REQ -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
END;

/




--------------------------------------------------------
--  DDL for Function FN_GET_ANNOUNCE_TYPE
--------------------------------------------------------

/**
 * Gets Areas of Consideration - Announcement Type section data.
 *
 * @param I_AOC_DELEGATE_EXAM - Delegated Examining (DE) - All U.S. citizens
 * @param I_AOC_DH_US_CITIZENS - Direct Hire - All U.S. citizens
 * @param I_AOC_MP_GOV_WIDE - MP Government-wide
 * @param I_AOC_MP_HHS_ONLY - MP HHS-wide ONLY
 * @param I_AOC_MP_CMS_ONLY - MP CMS-wide ONLY
 * @param I_AOC_MP_COMP_CONS_ONLY - MP Component/Consortium-wide ONLY
 * @param I_AOC_MP_I_CTAP_VEGA - ICTAP and VEOA Only
 *
 * @return NVARCHAR2 - Concatenated Announcement Type section values delimitted by semicolon.
 */
CREATE OR REPLACE FUNCTION FN_GET_ANNOUNCE_TYPE
(
	I_AOC_DELEGATE_EXAM            IN  VARCHAR2
	, I_AOC_DH_US_CITIZENS         IN  VARCHAR2
	, I_AOC_MP_GOV_WIDE            IN  VARCHAR2
	, I_AOC_MP_HHS_ONLY            IN  VARCHAR2
	, I_AOC_MP_CMS_ONLY            IN  VARCHAR2
	, I_AOC_MP_COMP_CONS_ONLY      IN  VARCHAR2
	, I_AOC_MP_I_CTAP_VEGA         IN  VARCHAR2
)
RETURN NVARCHAR2
IS
	V_RETURN_VAL                NVARCHAR2(500);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_ANNOUNCE_TYPE -------');
	--DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_DELEGATE_EXAM      = ' || I_AOC_DELEGATE_EXAM );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_DH_US_CITIZENS     = ' || I_AOC_DH_US_CITIZENS );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_MP_GOV_WIDE        = ' || I_AOC_MP_GOV_WIDE );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_MP_HHS_ONLY        = ' || I_AOC_MP_HHS_ONLY );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_MP_CMS_ONLY        = ' || I_AOC_MP_CMS_ONLY );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_MP_COMP_CONS_ONLY  = ' || I_AOC_MP_COMP_CONS_ONLY );
	--DBMS_OUTPUT.PUT_LINE('    I_AOC_MP_I_CTAP_VEGA     = ' || I_AOC_MP_I_CTAP_VEGA );

	V_RETURN_VAL :=
		CASE WHEN I_AOC_DELEGATE_EXAM = '1'        THEN 'Delegated Examining (DE) - All U.S. citizens; ' ELSE '' END
		|| CASE WHEN I_AOC_DH_US_CITIZENS = '1'    THEN 'Direct Hire - All U.S. citizens; ' ELSE '' END
		|| CASE WHEN I_AOC_MP_GOV_WIDE = '1'       THEN 'MP Government-wide; ' ELSE '' END
		|| CASE WHEN I_AOC_MP_HHS_ONLY = '1'       THEN 'MP HHS-wide ONLY; ' ELSE '' END
		|| CASE WHEN I_AOC_MP_CMS_ONLY = '1'       THEN 'MP CMS-wide ONLY; ' ELSE '' END
		|| CASE WHEN I_AOC_MP_COMP_CONS_ONLY = '1' THEN 'MP Component/Consortium-wide ONLY; ' ELSE '' END
		|| CASE WHEN I_AOC_MP_I_CTAP_VEGA = '1'    THEN 'ICTAP and VEOA Only; ' ELSE '' END
	;
	IF V_RETURN_VAL IS NOT NULL AND LENGTH(V_RETURN_VAL) > 0
		AND SUBSTR(V_RETURN_VAL, (LENGTH(V_RETURN_VAL) - 1)) = '; '
	THEN
		V_RETURN_VAL := SUBSTR(V_RETURN_VAL, 1, (LENGTH(V_RETURN_VAL) - 2));
	END IF;

	--DBMS_OUTPUT.PUT_LINE('    V_RETURN_VAL = ' || V_RETURN_VAL);
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_GET_ANNOUNCE_TYPE -------');
	RETURN V_RETURN_VAL;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_ANNOUNCE_TYPE -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
END;

/




--------------------------------------------------------
--  DDL for Function FN_GET_ASSESS_TYPE
--------------------------------------------------------

/**
 * Gets Job Analysis - Assessement Type section data.
 *
 * @param I_JA_TYPE_YES_NO - Yes/No (True/False)
 * @param I_JA_TYPE_REQ_DEFAULT - Default scale
 * @param I_JA_TYPE_KNOWL_SCALE - Knowledge scale
 *
 * @return NVARCHAR2 - Concatenated Assessement Type section values delimitted by semicolon.
 */
CREATE OR REPLACE FUNCTION FN_GET_ASSESS_TYPE
(
	I_JA_TYPE_YES_NO           IN  VARCHAR2
	, I_JA_TYPE_REQ_DEFAULT    IN  VARCHAR2
	, I_JA_TYPE_KNOWL_SCALE    IN  VARCHAR2
)
RETURN NVARCHAR2
IS
	V_RETURN_VAL                NVARCHAR2(100);
BEGIN
	--DBMS_OUTPUT.PUT_LINE('------- START: FN_GET_ASSESS_TYPE -------');
	--DBMS_OUTPUT.PUT_LINE('-- PARAMETERS --');
	--DBMS_OUTPUT.PUT_LINE('    I_JA_TYPE_YES_NO         = ' || I_JA_TYPE_YES_NO );
	--DBMS_OUTPUT.PUT_LINE('    I_JA_TYPE_REQ_DEFAULT    = ' || I_JA_TYPE_REQ_DEFAULT );
	--DBMS_OUTPUT.PUT_LINE('    I_JA_TYPE_KNOWL_SCALE    = ' || I_JA_TYPE_KNOWL_SCALE );

	V_RETURN_VAL :=
		CASE WHEN I_JA_TYPE_YES_NO = '1'          THEN 'Yes/No (True/False); ' ELSE '' END
		|| CASE WHEN I_JA_TYPE_REQ_DEFAULT = '1'  THEN 'Default scale; ' ELSE '' END
		|| CASE WHEN I_JA_TYPE_KNOWL_SCALE = '1'  THEN 'Knowledge scale; ' ELSE '' END
	;
	IF V_RETURN_VAL IS NOT NULL AND LENGTH(V_RETURN_VAL) > 0
		AND SUBSTR(V_RETURN_VAL, (LENGTH(V_RETURN_VAL) - 1)) = '; '
	THEN
		V_RETURN_VAL := SUBSTR(V_RETURN_VAL, 1, (LENGTH(V_RETURN_VAL) - 2));
	END IF;

	--DBMS_OUTPUT.PUT_LINE('    V_RETURN_VAL = ' || V_RETURN_VAL);
	--DBMS_OUTPUT.PUT_LINE('------- END: FN_GET_ASSESS_TYPE -------');
	RETURN V_RETURN_VAL;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();
		--DBMS_OUTPUT.PUT_LINE('ERROR occurred while executing FN_GET_ASSESS_TYPE -------------------');
		--DBMS_OUTPUT.PUT_LINE('Error code    = ' || SQLCODE);
		--DBMS_OUTPUT.PUT_LINE('Error message = ' || SQLERRM);
		RETURN NULL;
END;

/
