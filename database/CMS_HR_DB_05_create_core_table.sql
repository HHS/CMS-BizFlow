

DROP TABLE ERROR_LOG;
DROP TABLE TBL_FORM_DTL;
DROP TABLE TBL_LOOKUP;

DROP SEQUENCE ERROR_LOG_SEQ;
DROP SEQUENCE CMS_FORM_DATA_SEQ;


--=============================================================================
-- Create TABLE and associated objects
--=============================================================================


--------------------------------------------------------
--  DDL for Table ERROR_LOG
--------------------------------------------------------

CREATE TABLE ERROR_LOG
(
	ID                  INTEGER
	, ERROR_CD          INTEGER
	, ERROR_MSG         VARCHAR2(4000)
	, BACKTRACE         CLOB
	, CALLSTACK         CLOB
	, CRT_DT            DATE
	, CRT_USR           VARCHAR2(50)
);

ALTER TABLE ERROR_LOG ADD CONSTRAINT ERROR_LOG_PK PRIMARY KEY (ID);
/


CREATE SEQUENCE ERROR_LOG_SEQ
	INCREMENT BY 1
	START WITH 1
	NOMAXVALUE
	NOCYCLE
	NOCACHE;

/


CREATE OR REPLACE TRIGGER ERROR_LOG_BIR
BEFORE INSERT ON ERROR_LOG
FOR EACH ROW
BEGIN
	SELECT ERROR_LOG_SEQ.NEXTVAL
	INTO :NEW.ID
	FROM DUAL;
END;

/










--------------------------------------------------------
--  DDL for Table TBL_FORM_DTL
--------------------------------------------------------

CREATE TABLE TBL_FORM_DTL
(
	ID                      NUMBER(20) NOT NULL
	, PROCID                NUMBER(10)
	, ACTSEQ                NUMBER(10)
	, WITEMSEQ              NUMBER(10)
	, FORM_TYPE             VARCHAR2(50)
	, FIELD_DATA            XMLTYPE
	, CRT_DT                TIMESTAMP
	, CRT_USR               VARCHAR2(50)
	, MOD_DT                TIMESTAMP
	, MOD_USR               VARCHAR2(50)
);

ALTER TABLE TBL_FORM_DTL ADD CONSTRAINT TBL_FORM_DTL_PK PRIMARY KEY (ID);

DROP INDEX TBL_FORM_DTL_NK1
;
CREATE INDEX TBL_FORM_DTL_NK1 ON TBL_FORM_DTL (PROCID)
;



CREATE SEQUENCE CMS_FORM_DATA_SEQ
	INCREMENT BY 1
	START WITH 1
	NOMAXVALUE
	NOCYCLE
	NOCACHE;

/

CREATE OR REPLACE TRIGGER TBL_FORM_DTL_BIR
BEFORE INSERT ON TBL_FORM_DTL
FOR EACH ROW
BEGIN
	SELECT CMS_FORM_DATA_SEQ.NEXTVAL
	INTO :NEW.ID
	FROM DUAL
	;
END
;

/









--------------------------------------------------------
--  DDL for Table TBL_LOOKUP
--------------------------------------------------------

CREATE TABLE TBL_LOOKUP
(
	TBL_ID NUMBER(*,0)
	, TBL_PARENT_ID NUMBER(*,0)
	, TBL_LTYPE NVARCHAR2(50)
	, TBL_NAME NVARCHAR2(100)
	, TBL_LABEL NVARCHAR2(1000)
	, TBL_ACTIVE CHAR(1)
	, TBL_DISP_ORDER NUMBER(*,0)
	, TBL_MANDATORY NVARCHAR2(10)
	, TBL_REGION NVARCHAR2(50)
	, TBL_CATEGORY NVARCHAR2(50)
	, TBL_EFFECTIVE_DT DATE
	, TBL_EXPIRATION_DT DATE
);

ALTER TABLE TBL_LOOKUP ADD CONSTRAINT TBL_LOOKUP_PK PRIMARY KEY (TBL_ID);

DROP INDEX TBL_LOOKUP_NK1
;
CREATE INDEX TBL_LOOKUP_NK1 ON TBL_LOOKUP (TBL_LTYPE)
;

COMMENT ON COLUMN TBL_LOOKUP.TBL_ID IS 'Unique primary key';
COMMENT ON COLUMN TBL_LOOKUP.TBL_PARENT_ID IS 'Key value of associated parent data';
COMMENT ON COLUMN TBL_LOOKUP.TBL_LTYPE IS 'List identity';
COMMENT ON COLUMN TBL_LOOKUP.TBL_NAME IS 'Name of unique value within the list';
COMMENT ON COLUMN TBL_LOOKUP.TBL_LABEL IS 'Actual value displayed for this name';
COMMENT ON COLUMN TBL_LOOKUP.TBL_ACTIVE IS 'Is this code active? 0=false, 1=true';
COMMENT ON COLUMN TBL_LOOKUP.TBL_DISP_ORDER IS 'The order number in which the label should appear within the list';
COMMENT ON COLUMN TBL_LOOKUP.TBL_MANDATORY IS 'Mandatory indicator (not used)';
COMMENT ON COLUMN TBL_LOOKUP.TBL_REGION IS 'Region to identify organization sub-division (future use)';
COMMENT ON COLUMN TBL_LOOKUP.TBL_CATEGORY IS 'Category indicator - alternate grouping (not used)';
COMMENT ON COLUMN TBL_LOOKUP.TBL_EFFECTIVE_DT IS 'Date this code is in effect';
COMMENT ON COLUMN TBL_LOOKUP.TBL_EXPIRATION_DT IS 'Date this code becomes obsolete';

/
