CREATE OR REPLACE FUNCTION HHS_CMS_HR.FN_PARSENAME 
(
  I_FULLNAME IN VARCHAR2 
, I_NAMEFORMAT IN VARCHAR2 
) RETURN VARCHAR2 AS

    FORMATTED_NAME VARCHAR2(1000);
    FULL_NAME VARCHAR2(1000);
    FIRST_NAME VARCHAR2(200);
    MIDDLE_NAME VARCHAR2(200);
    LAST_NAME VARCHAR2(200);
    LAST_NAME2 VARCHAR2(200);
    LAST_NAME_INITIAL VARCHAR2(10);
    SUFFIX_NAME VARCHAR2(200);
    IDX_COMMA INTEGER;
    IDX_SPACE INTEGER;

BEGIN

    IF I_FULLNAME IS NOT NULL THEN
        BEGIN    

            SELECT REPLACE(I_FULLNAME, '  ', '')
              INTO FULL_NAME
              FROM DUAL;

            SELECT INSTR(FULL_NAME, ',')
              INTO IDX_COMMA
              FROM DUAL;

            SELECT INSTR(FULL_NAME, ' ')
              INTO IDX_SPACE
              FROM DUAL;

            IF (IDX_COMMA > 0) THEN
                --FORMATTED_NAME := 'COMMA';

                SELECT REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,1),
                      REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,2),
                      REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,3),
                      TRANSLATE(REGEXP_SUBSTR(FULL_NAME,'( |\.|,)(JR|MR|MS|SR)(\.|,|$)',1,1),'A ,.','A')
                  INTO
                        LAST_NAME
                        ,FIRST_NAME
                        ,MIDDLE_NAME
                        ,SUFFIX_NAME
                  FROM DUAL;

            ELSE

                IF (IDX_SPACE > 0) THEN
                    SELECT REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,1),
                          REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,2),
                          REGEXP_SUBSTR(FULL_NAME,'[^, .]+',1,3),
                          TRANSLATE(REGEXP_SUBSTR(FULL_NAME,'( |\.|,)(JR|MR|MS|SR)(\.|,|$)',1,1),'A ,.','A')
                      INTO
                            FIRST_NAME
                            ,MIDDLE_NAME
                            ,LAST_NAME
                            ,SUFFIX_NAME
                      FROM DUAL;
                ELSE
                    LAST_NAME := FULL_NAME;
                    FIRST_NAME := '';
                    MIDDLE_NAME := '';
                    SUFFIX_NAME := '';

                END IF;

            END IF;

            --Exception Cases
            IF LAST_NAME IS NULL AND MIDDLE_NAME IS NOT NULL THEN
                LAST_NAME := MIDDLE_NAME;
                MIDDLE_NAME := '';
            END IF;

            IF MIDDLE_NAME = SUFFIX_NAME THEN
                MIDDLE_NAME := '';
            END IF;            

            IF LAST_NAME = SUFFIX_NAME THEN
                LAST_NAME := MIDDLE_NAME;
                MIDDLE_NAME := '';
            END IF;

            IF LAST_NAME = SUFFIX_NAME THEN
                LAST_NAME := MIDDLE_NAME;
                MIDDLE_NAME := '';
            END IF;

        END;    
    ELSE
        FORMATTED_NAME := '';
    END IF;

    SUFFIX_NAME := TRIM(NVL(SUFFIX_NAME, ''));
    
    IF INSTR(LAST_NAME, '-') > 0 THEN
        LAST_NAME2 := SUBSTR(LAST_NAME, INSTR(LAST_NAME, '-'));
        LAST_NAME_INITIAL := UPPER(SUBSTR(LAST_NAME, 1,1)) || UPPER(SUBSTR(LAST_NAME2, 2,1));
    ELSE
        LAST_NAME_INITIAL := UPPER(SUBSTR(LAST_NAME, 1,1));
    END IF;
    
    IF (I_NAMEFORMAT = 'FULL') THEN

        IF (SUFFIX_NAME IS NOT NULL) THEN
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME || '.' || SUFFIX_NAME;
        ELSE
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME;
        END IF;

    ELSIF (I_NAMEFORMAT = 'INITIAL') THEN
        
        FORMATTED_NAME := UPPER(SUBSTR(FIRST_NAME,1,1)) || LAST_NAME_INITIAL;
        
    ELSIF (I_NAMEFORMAT = 'FULL+INITIAL') THEN
        IF (SUFFIX_NAME IS NOT NULL) THEN
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME || '.' || SUFFIX_NAME || ' [' || LAST_NAME_INITIAL || ']';
        ELSE
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME || ' [' || LAST_NAME_INITIAL || ']';
        END IF;
    ELSE
        IF (SUFFIX_NAME IS NOT NULL) THEN
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME || '.' || SUFFIX_NAME;
        ELSE
            FORMATTED_NAME := LAST_NAME || ', ' || FIRST_NAME || ' ' || MIDDLE_NAME;
        END IF;

    END IF;

    RETURN FORMATTED_NAME;

END FN_PARSENAME;

/