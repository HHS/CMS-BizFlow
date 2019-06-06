SET DEFINE OFF;

create or replace PROCEDURE SP_GET_REQUEST_NUM (P_REQUEST_NUM OUT VARCHAR2)
AS
	V_DATE DATE;
	V_SEQ NUMBER;
	V_NUM_OUT VARCHAR2(200);
BEGIN
	BEGIN
		SELECT RC_DATE, RC_SEQ INTO V_DATE, V_SEQ FROM REQUEST_CONTROL;
	EXCEPTION
		WHEN OTHERS THEN P_REQUEST_NUM := NULL;
		RETURN;
	END;
	IF TO_CHAR(V_DATE, 'YYYYMMDD') <> TO_CHAR(SYSDATE, 'YYYYMMDD') THEN
		BEGIN
			UPDATE REQUEST_CONTROL
			SET RC_DATE = SYSDATE
				, RC_SEQ = 1
				, RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-0001';
		END;
	ELSE
		BEGIN
			UPDATE REQUEST_CONTROL
			SET RC_SEQ = (V_SEQ + 1)
				, RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' ||
					TO_CHAR((V_SEQ + 1), 'FM0000');
		END;
	END IF;

	BEGIN
		SELECT RC_REQUEST_NUM INTO V_NUM_OUT FROM REQUEST_CONTROL;
	END;
	P_REQUEST_NUM := V_NUM_OUT;
EXCEPTION
	WHEN OTHERS THEN P_REQUEST_NUM := NULL;
	RETURN;
END SP_GET_REQUEST_NUM;

/

create or replace PROCEDURE SP_GET_INCENTIVES_REQUEST_NUM (P_REQUEST_NUM OUT VARCHAR2)
AS
               V_DATE DATE;
               V_SEQ NUMBER;
               V_NUM_OUT VARCHAR2(200);
BEGIN
               BEGIN
                              SELECT RC_DATE, RC_SEQ INTO V_DATE, V_SEQ FROM INCENTIVES_REQUEST_CONTROL;
               EXCEPTION
                              WHEN OTHERS THEN P_REQUEST_NUM := NULL;
                              RETURN;
               END;
               
               IF TO_CHAR(V_DATE, 'YYYYMMDD') <> TO_CHAR(SYSDATE, 'YYYYMMDD') THEN
                              BEGIN
                                             UPDATE INCENTIVES_REQUEST_CONTROL
                                             SET RC_DATE = SYSDATE
                                                            , RC_SEQ = 1001
                                                            , RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-1001';
                              END;
               ELSE
                              BEGIN
                                             UPDATE INCENTIVES_REQUEST_CONTROL
                                             SET RC_SEQ = (V_SEQ + 1)
                                                            , RC_REQUEST_NUM = TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' ||
                                                                           TO_CHAR((V_SEQ + 1), 'FM0000');
                              END;
               END IF;

               BEGIN
                              SELECT RC_REQUEST_NUM INTO V_NUM_OUT FROM INCENTIVES_REQUEST_CONTROL;
               END;
               P_REQUEST_NUM := V_NUM_OUT;
EXCEPTION
               WHEN OTHERS THEN P_REQUEST_NUM := NULL;
               RETURN;
END SP_GET_INCENTIVES_REQUEST_NUM;

/

GRANT EXECUTE ON HHS_CMS_HR.GET_INCENTIVES_REQUEST_NUM TO HHS_CMS_HR_RW_ROLE;
GRANT EXECUTE ON HHS_CMS_HR.GET_INCENTIVES_REQUEST_NUM TO HHS_CMS_HR_DEV_ROLE;

/