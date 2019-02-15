/**
 * Script to compile all invalid objects in a shema in Oracle database
 * Last Updated by Taeho Lee on Feb 14, 2019
 * Usage: change P_SCHEMA_OWNER name before run if different.
 **/

/*
    -- Query to check if invalid object still exists after running this query
    SELECT * 
      FROM ALL_OBJECTS
     WHERE STATUS != 'VALID';
*/

SET SERVEROUTPUT ON;

DECLARE 
    P_SCHEMA_OWNER VARCHAR2(100) := 'HHS_CMS_HR';
    V_NUM_OF_INVALID_OBJECT INTEGER := 0;
BEGIN

    DBMS_OUTPUT.PUT_LINE('>> Recompilation begins ');
    
    -- Loop up to 5 for depenpencies
    FOR i IN 1..5 LOOP
    BEGIN
        DBMS_OUTPUT.PUT_LINE('>> (' || TO_CHAR(i) || ') scanning ----------');
        FOR OBJ IN (SELECT OBJECT_NAME, OBJECT_TYPE FROM ALL_OBJECTS WHERE OWNER = P_SCHEMA_OWNER AND STATUS != 'VALID' ORDER BY OBJECT_NAME ) LOOP
            IF OBJ.OBJECT_TYPE = 'VIEW' OR OBJ.OBJECT_TYPE = 'FUNCTION' OR OBJ.OBJECT_TYPE = 'PROCEDURE' OR OBJ.OBJECT_TYPE = 'PACKAGE' OR OBJ.OBJECT_TYPE = 'TRIGGER' THEN
                DBMS_OUTPUT.PUT_LINE('ALTER ' || OBJ.OBJECT_TYPE || ' ' || OBJ.OBJECT_NAME ||' COMPILE;');
                EXECUTE IMMEDIATE 'ALTER ' || OBJ.OBJECT_TYPE || ' ' || OBJ.OBJECT_NAME ||' COMPILE';
            ELSIF OBJ.OBJECT_TYPE = 'PACKAGE BODY' THEN
                DBMS_OUTPUT.PUT_LINE('ALTER PACKAGE ' || OBJ.OBJECT_NAME ||' COMPILE BODY;');
                EXECUTE IMMEDIATE 'ALTER PACKAGE ' || OBJ.OBJECT_NAME ||' COMPILE BODY';
            END IF;
        END LOOP;
    END;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('>> Recompilation ends!');

    SELECT count(1) 
      INTO V_NUM_OF_INVALID_OBJECT
      FROM ALL_OBJECTS
     WHERE STATUS != 'VALID';
     
     DBMS_OUTPUT.PUT_LINE('>> ' || TO_CHAR(V_NUM_OF_INVALID_OBJECT) || ' invalid objects exists');
END;
/
