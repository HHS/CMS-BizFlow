
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
		CASE WHEN I_POS_GA_1  = '1'    THEN '01; ' ELSE '' END
		|| CASE WHEN I_POS_GA_2  = '1' THEN '02; ' ELSE '' END
		|| CASE WHEN I_POS_GA_3  = '1' THEN '03; ' ELSE '' END
		|| CASE WHEN I_POS_GA_4  = '1' THEN '04; ' ELSE '' END
		|| CASE WHEN I_POS_GA_5  = '1' THEN '05; ' ELSE '' END
		|| CASE WHEN I_POS_GA_6  = '1' THEN '06; ' ELSE '' END
		|| CASE WHEN I_POS_GA_7  = '1' THEN '07; ' ELSE '' END
		|| CASE WHEN I_POS_GA_8  = '1' THEN '08; ' ELSE '' END
		|| CASE WHEN I_POS_GA_9  = '1' THEN '09; ' ELSE '' END
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
