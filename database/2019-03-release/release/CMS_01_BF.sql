SET DEFINE OFF;

create or replace FUNCTION HHS_FN_GETREQUESTDT
(
	I_PROCID IN NUMBER
)
RETURN DATE
IS
	L_PARENTPROCID NUMBER(20);
    L_GRANDPARENTPROCID NUMBER(20);
	L_PROCNAME VARCHAR2(100);
    L_PARENTPROCNAME VARCHAR2(100);
	L_RETURN_DATE DATE;

BEGIN
	BEGIN
		SELECT PARENTPROCID, NAME, CREATIONDTIME
		INTO L_PARENTPROCID, L_PROCNAME, L_RETURN_DATE
		FROM PROCS
		WHERE PROCID = I_PROCID;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			L_PARENTPROCID := NULL;
			L_PROCNAME := NULL;
			L_RETURN_DATE := NULL;
		WHEN OTHERS THEN
			L_PARENTPROCID := NULL;
			L_PROCNAME := NULL;
			L_RETURN_DATE := NULL;
	END;

	
	IF L_PARENTPROCID IS NOT NULL AND L_PARENTPROCID > 0 THEN
        -- Get the parent process name
        SELECT NAME INTO L_PARENTPROCNAME FROM PROCS 
        WHERE PROCID = L_PARENTPROCID;

            -- For Classification process, lookup parent's creationdtime
            IF L_PROCNAME IS NOT NULL AND L_PROCNAME = 'Classification' THEN
                BEGIN
                    SELECT CREATIONDTIME INTO L_RETURN_DATE FROM PROCS
                    WHERE PROCID = L_PARENTPROCID;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            L_RETURN_DATE := NULL;
                        WHEN OTHERS THEN
                            L_RETURN_DATE := NULL;                
                END;
            END IF;
             -- For Eligibility and Qualifications Review process, lookup Strategic Consultation process' creationdtime
            IF L_PROCNAME IS NOT NULL AND L_PROCNAME = 'Eligibility and Qualifications Review' THEN
                BEGIN
                    IF L_PARENTPROCNAME IS NOT NULL AND L_PARENTPROCNAME = 'Strategic Consultation' THEN
                        BEGIN
                            SELECT CREATIONDTIME INTO L_RETURN_DATE FROM PROCS
                            WHERE PROCID = L_PARENTPROCID;                        
                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    L_RETURN_DATE := NULL;
                                WHEN OTHERS THEN
                                    L_RETURN_DATE := NULL;
                        END;
                    END IF;
                    
                    IF L_PARENTPROCNAME IS NOT NULL AND L_PARENTPROCNAME = 'Classification' THEN
                        BEGIN
                            SELECT PARENTPROCID INTO L_GRANDPARENTPROCID FROM PROCS
		                    WHERE PROCID = L_PARENTPROCID;

                            IF L_GRANDPARENTPROCID IS NOT NULL AND L_GRANDPARENTPROCID > 0 THEN
                                BEGIN
                                    SELECT CREATIONDTIME INTO L_RETURN_DATE FROM PROCS
                                    WHERE PROCID = L_GRANDPARENTPROCID;                        
                                    EXCEPTION
                                        WHEN NO_DATA_FOUND THEN
                                            L_RETURN_DATE := NULL;
                                        WHEN OTHERS THEN
                                            L_RETURN_DATE := NULL;
                                END;
                            END IF;
                        END;
                    END IF;                
                END;
            END IF;        
	END IF;

	RETURN L_RETURN_DATE;
END;
/

GRANT SELECT, UPDATE ON BIZFLOW.WITEM TO HHS_CMS_HR WITH GRANT OPTION;
GRANT SELECT, UPDATE ON BIZFLOW.RLVNTDATA TO HHS_CMS_HR WITH GRANT OPTION;
GRANT SELECT ON BIZFLOW.ACT TO HHS_CMS_HR WITH GRANT OPTION;
/

COMMIT;
/



