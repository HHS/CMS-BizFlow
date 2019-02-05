create or replace PACKAGE BODY            CMS_TTH_WEEKLY_DATA_PKS AS
--------------------------------------------------------------------------------------------------------
--THIS PACKAGE WILL HANDLE PULLING AND POPULATING CMS_TIME_TO_HIRE_WEEKLY_PILOT TABLES in HHS_HR SCHEMA 
--------------------------------------------------------------------------------------------------------
 
--======================================================
-- - - -- - - - - - - - - - - - - - - - - - - - - - - -
 
--CURSORS and TYPES
 
-- - - - - - - - - - - - - - - - - - - - - - - - - - - -
--======================================================
--------------------------------------------------------
--CURSOR: CUR_CMS_TTH_DATA
--DESCRIPTION: 
--------------------------------------------------------
CURSOR CUR_CMS_TTH_DATA 
    IS
    SELECT	ADMIN_CODE || ' - ' || ADMIN_CODE_DESC AS COMPONENT,
			REQ_JOB_REQ_NUMBER AS REQUEST_NUMBER,
			PROCESS_ID,
			PROCESS_CREATION_DATE AS STRAT_CON_START,
			PROCESS_COMPLETION_DATE AS STRAT_CON_END,
			CASE
				WHEN BIZFLOW.HHS_FN_GET_BUSDAYSDIFF(PROCESS_CREATION_DATE,PROCESS_COMPLETION_DATE) > 6
				THEN 1
				ELSE 0
			END AS MISSED_STRAT_CON,
			PROCESS_COMPLETION_DATE AS CLASS_START,
			BIZFLOW.HHS_FN_SUBTRACT_BUSDAY(ANNOUNCEMENT_OPEN_DATE, 1) AS CLASS_END,
			CASE
				WHEN BIZFLOW.HHS_FN_GET_BUSDAYSDIFF(PROCESS_COMPLETION_DATE,BIZFLOW.HHS_FN_SUBTRACT_BUSDAY(ANNOUNCEMENT_OPEN_DATE, 1)) > 15
				THEN 1
				ELSE 0
			END AS MISSED_CLASS,
			ANNOUNCEMENT_CLOSE_DATE AS QUALS_START,
			MIN(REVIEW_SENT_DATE) AS QUALS_END,
			CASE
				WHEN BIZFLOW.HHS_FN_GET_BUSDAYSDIFF(ANNOUNCEMENT_CLOSE_DATE,MIN(REVIEW_SENT_DATE)) > 17
				THEN 1
				ELSE 0
			END AS MISSED_QUALS,
			MIN(REVIEW_SENT_DATE) AS SELECTION_START,
			MIN(REVIEW_RETURN_DATE) AS SELECTION_END,
			CASE
				WHEN BIZFLOW.HHS_FN_GET_BUSDAYSDIFF(MIN(REVIEW_SENT_DATE), MIN(REVIEW_RETURN_DATE)) > 15
				THEN 1
				ELSE 0
			END AS MISSED_SELECTION
	FROM HHS_HR.ADMINISTRATIVE_CODE AC
	LEFT JOIN 
			(SELECT REQ_JOB_REQ_NUMBER,
					SUB_ORG_2_CD,
					SUB_ORG_2_DSCR,
					PROCESS_ID,
					PROCESS_NAME,
					PROCESS_CREATION_DATE,
					PROCESS_COMPLETION_DATE,
					REQUEST_STATUS
			FROM HHS_CMS_HR.VW_STRATCON SCF
			JOIN BIZFLOW.HHS_VW_CONSULTATION_PROC SCP
				ON SCF.SG_PROCID = SCP.PROCESS_ID
			WHERE REQUEST_STATUS = 'Strategic Consultation Approved'
			AND PROCESS_COMPLETION_DATE IS NOT NULL) STRATCON
		ON AC.ADMIN_CODE = STRATCON.SUB_ORG_2_CD
		AND PROCESS_CREATION_DATE > '03-FEB-19' 
	LEFT JOIN HHS_HR.DSS_CMS_TIME_TO_HIRE TTH
		ON TTH.REQUEST_NUMBER = STRATCON.REQ_JOB_REQ_NUMBER
	WHERE ((LENGTH(ADMIN_CODE) <= 3 AND ADMIN_CODE LIKE 'FC%')
	OR (LENGTH(ADMIN_CODE) = 4 AND ADMIN_CODE LIKE 'FCM%'))
	AND TTH.EOD_DATE IS NULL
	GROUP BY
			AC.ADMIN_CODE || ' - ' || AC.ADMIN_CODE_DESC,
			REQ_JOB_REQ_NUMBER,
			PROCESS_ID,
			PROCESS_CREATION_DATE,
			PROCESS_COMPLETION_DATE,
			ANNOUNCEMENT_OPEN_DATE,
			ANNOUNCEMENT_CLOSE_DATE; 
 
    TYPE TYP_CMS_TTH_DATA IS TABLE OF CUR_CMS_TTH_DATA%ROWTYPE
    INDEX BY PLS_INTEGER;
 
    CMS_TTH_DATA TYP_CMS_TTH_DATA;
 
--======================================================
-- - - -- - - - - - - - - - - - - - - - - - - - - - - -
 
--PROCEDURES
 
-- - - - - - - - - - - - - - - - - - - - - - - - - - - -
--======================================================
 
---------------------------------------------------------
--PROCEDURE: INSERT_CMS_TTH_WEEKLY_DATA
--DESCRIPTION : 
---------------------------------------------------------
PROCEDURE INSERT_CMS_TTH_WEEKLY_DATA
AS  
COUNT_REQUESTS        NUMBER(10);
SUM_MISSED_STRAT_CON  NUMBER(10);
SUM_MISSED_CLASS      NUMBER(10);
SUM_MISSED_QUALS      NUMBER(10);
SUM_MISSED_SELECTION  NUMBER(10);
BEGIN
 
    OPEN CUR_CMS_TTH_DATA;
    FETCH CUR_CMS_TTH_DATA BULK COLLECT INTO CMS_TTH_DATA;
    CLOSE CUR_CMS_TTH_DATA;
 
    IF CMS_TTH_DATA.COUNT > 0 THEN
    DBMS_OUTPUT.PUT_LINE('COUNT: ' || CMS_TTH_DATA.COUNT);
    
        
         FOR i IN CMS_TTH_DATA.FIRST.. CMS_TTH_DATA.LAST LOOP
         --Insert record into HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT table
            BEGIN
          INSERT INTO HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT
            (DATA_PULLED_ON, 
            WEEK_OF, 
            COMPONENT, 
            REQUEST_NUMBER, 
            PROCESS_ID, 
            STRAT_CON_START, 
            STRAT_CON_END, 
            MISSED_STRAT_CON, 
            CLASS_START, 
            CLASS_END,
            MISSED_CLASS, 
            QUALS_START, 
            QUALS_END, 
            MISSED_QUALS, 
            SELECTION_START, 
            SELECTION_END, 
            MISSED_SELECTION)
          VALUES 
            (SYSDATE,  
            NEXT_DAY(SYSDATE - 7,'Sunday'), 
            CMS_TTH_DATA(i).COMPONENT, 
            CMS_TTH_DATA(i).REQUEST_NUMBER, 
            CMS_TTH_DATA(i).PROCESS_ID, 
            CMS_TTH_DATA(i).STRAT_CON_START, 
            CMS_TTH_DATA(i).STRAT_CON_END, 
            CMS_TTH_DATA(i).MISSED_STRAT_CON, 
            CMS_TTH_DATA(i).CLASS_START, 
            CMS_TTH_DATA(i).CLASS_END,
            CMS_TTH_DATA(i).MISSED_CLASS, 
            CMS_TTH_DATA(i).QUALS_START, 
            CMS_TTH_DATA(i).QUALS_END, 
            CMS_TTH_DATA(i).MISSED_QUALS, 
            CMS_TTH_DATA(i).SELECTION_START, 
            CMS_TTH_DATA(i).SELECTION_END, 
            CMS_TTH_DATA(i).MISSED_SELECTION);   
     
          EXCEPTION
                WHEN OTHERS THEN
                        SP_ERROR_LOG();
            END;
        END LOOP;
        
        --To calculate totals for each missed process for CMS
        SELECT COUNT(REQUEST_NUMBER), SUM(MISSED_STRAT_CON), SUM(MISSED_CLASS), SUM(MISSED_QUALS), SUM(MISSED_SELECTION)
        INTO COUNT_REQUESTS, SUM_MISSED_STRAT_CON, SUM_MISSED_CLASS, SUM_MISSED_QUALS, SUM_MISSED_SELECTION
        FROM CMS_TIME_TO_HIRE_WEEKLY_PILOT
        WHERE TRUNC(DATA_PULLED_ON)=TRUNC(SYSDATE);
        
        --Insert a new row with totals for CMS
        INSERT INTO HHS_CMS_HR.CMS_TIME_TO_HIRE_WEEKLY_PILOT
            (DATA_PULLED_ON, 
            WEEK_OF, 
            COMPONENT,
            REQUEST_NUMBER,
            MISSED_STRAT_CON, 
            MISSED_CLASS,
            MISSED_QUALS, 
            MISSED_SELECTION)
          VALUES 
            (SYSDATE,  
            NEXT_DAY(SYSDATE - 7,'Sunday'), 
            'CMS - wide', 
            COUNT_REQUESTS,
            SUM_MISSED_STRAT_CON, 
            SUM_MISSED_CLASS,
            SUM_MISSED_QUALS, 
            SUM_MISSED_SELECTION); 
        
         COMMIT;
      END IF;
 
END INSERT_CMS_TTH_WEEKLY_DATA;
 
--------------------------------------------------------
--FUNCTION: FN_IMPORT_CMS_TTH_WEEKLY_DATA
--DESCRIPTION: Entry point for this package,calls individual 
--procedure run INSERT scrip inside the procedure. It will
-- return and error code and message if any. This function
--will be called by spring batch.
--------------------------------------------------------
FUNCTION FN_IMPORT_CMS_TTH_WEEKLY_DATA
RETURN VARCHAR2
AS
BEGIN
        INSERT_CMS_TTH_WEEKLY_DATA(); 
RETURN ERROR_LOG();
END FN_IMPORT_CMS_TTH_WEEKLY_DATA;
 
--------------------------------------------------------
--PROCEDURE: ERROR_LOG
--DESCRIPTION: Return SQLCODE and SQLERRM
--------------------------------------------------------
FUNCTION ERROR_LOG
RETURN VARCHAR2
IS
        ERR_CODE   PLS_INTEGER        :=SQLCODE;
        ERR_MSG    VARCHAR2(32767)    := SQLERRM;
BEGIN
        RETURN ERR_CODE ||' : ' ||ERR_MSG;
END ERROR_LOG;
 
END CMS_TTH_WEEKLY_DATA_PKS;