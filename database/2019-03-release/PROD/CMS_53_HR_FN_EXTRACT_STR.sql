create or replace FUNCTION FN_EXTRACT_STR
(
	  I_XMLDOC          IN  XMLTYPE
	, I_ID              IN  VARCHAR2
	, I_PATH            IN  VARCHAR2 DEFAULT 'value'
)
RETURN VARCHAR2
IS
    ELM XMLTYPE;
BEGIN
    ELM := I_XMLDOC.EXTRACT('//item[id="'||I_ID||'"]/'||I_PATH||'/text()');
    IF ELM IS NOT NULL THEN
        RETURN ELM.GETSTRINGVAL();
    ELSE
        RETURN NULL;
    END IF;
END;