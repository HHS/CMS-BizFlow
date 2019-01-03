

DROP TABLE ERROR_LOG;
DROP TABLE TBL_FORM_DTL;
DROP TABLE TBL_FORM_DTL_AUDIT;
DROP TABLE TBL_LOOKUP;

DROP SEQUENCE ERROR_LOG_SEQ;
DROP SEQUENCE CMS_FORM_DATA_SEQ;
DROP SEQUENCE TBL_FORM_DTL_AUDIT_SEQ;


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



COMMENT ON COLUMN ERROR_LOG.ID IS 'Unique primary key';
COMMENT ON COLUMN ERROR_LOG.ERROR_CD IS 'Error code';
COMMENT ON COLUMN ERROR_LOG.ERROR_MSG IS 'Error message';
COMMENT ON COLUMN ERROR_LOG.BACKTRACE IS 'Error trace';
COMMENT ON COLUMN ERROR_LOG.CALLSTACK IS 'PL/SQL call stack that leads to the error';
COMMENT ON COLUMN ERROR_LOG.CRT_DT IS 'Creation Date';
COMMENT ON COLUMN ERROR_LOG.CRT_USR IS 'Creation User';



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

--DROP INDEX TBL_FORM_DTL_UK1
--;
CREATE UNIQUE INDEX TBL_FORM_DTL_UK1 ON TBL_FORM_DTL (PROCID)
;

COMMENT ON COLUMN TBL_FORM_DTL.ID IS 'Unique primary key';
COMMENT ON COLUMN TBL_FORM_DTL.PROCID IS 'Foreign key. Process ID of the related BIZFLOW.PROCS table';
COMMENT ON COLUMN TBL_FORM_DTL.ACTSEQ IS 'Foreign key. Activity Sequence of the related BIZFLOW.ACT table';
COMMENT ON COLUMN TBL_FORM_DTL.WITEMSEQ IS 'Foreign key. Work Item Sequence of the related BIZFLOW.WITEM table';
COMMENT ON COLUMN TBL_FORM_DTL.FORM_TYPE IS 'Form Type.  Indicates what form data is stored in the record';
COMMENT ON COLUMN TBL_FORM_DTL.FIELD_DATA IS 'XML representation of the form data';
COMMENT ON COLUMN TBL_FORM_DTL.CRT_DT IS 'Creation Date';
COMMENT ON COLUMN TBL_FORM_DTL.CRT_USR IS 'Creation User';
COMMENT ON COLUMN TBL_FORM_DTL.MOD_DT IS 'Modification Date';
COMMENT ON COLUMN TBL_FORM_DTL.MOD_USR IS 'Modification User';


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





---------------------------------------------------
-- Auditing utility for form data xml table
---------------------------------------------------

-- DROP TABLE TBL_FORM_DTL_AUDIT;
-- DROP SEQUENCE TBL_FORM_DTL_AUDIT_SEQ;


CREATE TABLE TBL_FORM_DTL_AUDIT
(
	AUDITID                 NUMBER(20)

	, ID                    NUMBER(20)
	, PROCID                NUMBER(10)
	, ACTSEQ                NUMBER(10)
	, WITEMSEQ              NUMBER(10)
	, FORM_TYPE             VARCHAR2(50)
	, FIELD_DATA            XMLTYPE
	, CRT_DT                TIMESTAMP
	, CRT_USR               VARCHAR2(50)
	, MOD_DT                TIMESTAMP
	, MOD_USR               VARCHAR2(50)

	, AUDIT_ACTION          VARCHAR2(50)
	, AUDIT_TS				TIMESTAMP
);

ALTER TABLE TBL_FORM_DTL_AUDIT ADD CONSTRAINT TBL_FORM_DTL_AUDIT_PK PRIMARY KEY (AUDITID);

-- optional index for search performance
--DROP INDEX TBL_FORM_DTL_AUDIT_NK1;
CREATE INDEX TBL_FORM_DTL_AUDIT_NK1 ON TBL_FORM_DTL_AUDIT (ID);

-- optional index for search performance
--DROP INDEX TBL_FORM_DTL_AUDIT_NK2;
CREATE INDEX TBL_FORM_DTL_AUDIT_NK2 ON TBL_FORM_DTL_AUDIT (PROCID);


COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.AUDITID IS 'Unique primary key.';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.ID IS 'Unique primary key of TBL_FORM_DTL table record being audited.';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.PROCID IS 'Foreign key of TBL_FORM_DTL table record being audited. Process ID of the related BIZFLOW.PROCS table.';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.ACTSEQ IS 'Foreign key of TBL_FORM_DTL table record being audited. Activity Sequence of the related BIZFLOW.ACT table.';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.WITEMSEQ IS 'Foreign key of TBL_FORM_DTL table record being audited. Work Item Sequence of the related BIZFLOW.WITEM table.';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.FORM_TYPE IS 'Form Type of TBL_FORM_DTL table record being audited.  Indicates what form data is stored in the record.';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.FIELD_DATA IS 'XML representation of the form data of TBL_FORM_DTL table record being audited.';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.CRT_DT IS 'Creation Date of TBL_FORM_DTL table record being audited';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.CRT_USR IS 'Creation User of TBL_FORM_DTL table record being audited';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.MOD_DT IS 'Modification Date of TBL_FORM_DTL table record being audited';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.MOD_USR IS 'Modification User of TBL_FORM_DTL table record being audited';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.AUDIT_ACTION IS 'Audit action.  Expected values are INSERTING, UPDATING, or DELETING.';
COMMENT ON COLUMN TBL_FORM_DTL_AUDIT.AUDIT_TS IS 'Audit timestamp';


CREATE SEQUENCE TBL_FORM_DTL_AUDIT_SEQ
	INCREMENT BY 1
	START WITH 1
	NOMAXVALUE
	NOCYCLE
	NOCACHE;
/


CREATE OR REPLACE TRIGGER TBL_FORM_DTL_AUDIT_BIR
BEFORE INSERT ON TBL_FORM_DTL_AUDIT
FOR EACH ROW
BEGIN
	SELECT TBL_FORM_DTL_AUDIT_SEQ.NEXTVAL
	INTO :NEW.AUDITID
	FROM DUAL;
END;

/



-- Trigger on source table to record onto target audit table
CREATE OR REPLACE TRIGGER TBL_FORM_DTL_AIUDR
AFTER INSERT OR UPDATE OR DELETE ON TBL_FORM_DTL
FOR EACH ROW
DECLARE
	V_TRG_ACTION VARCHAR2(50);
BEGIN
	CASE
		WHEN INSERTING THEN
			V_TRG_ACTION := 'INSERTING';
			INSERT INTO TBL_FORM_DTL_AUDIT
			(
				ID
				, PROCID
				, ACTSEQ
				, WITEMSEQ
				, FORM_TYPE
				, FIELD_DATA
				, CRT_DT
				, CRT_USR
				, MOD_DT
				, MOD_USR
				, AUDIT_ACTION
				, AUDIT_TS
			)
			VALUES
			(
				:NEW.ID
				, :NEW.PROCID
				, :NEW.ACTSEQ
				, :NEW.WITEMSEQ
				, :NEW.FORM_TYPE
				, :NEW.FIELD_DATA
				, :NEW.CRT_DT
				, :NEW.CRT_USR
				, :NEW.MOD_DT
				, :NEW.MOD_USR
				, V_TRG_ACTION
				, SYSTIMESTAMP
			);
		WHEN UPDATING THEN
			V_TRG_ACTION := 'UPDATING';
			INSERT INTO TBL_FORM_DTL_AUDIT
			(
				ID
				, PROCID
				, ACTSEQ
				, WITEMSEQ
				, FORM_TYPE
				, FIELD_DATA
				, CRT_DT
				, CRT_USR
				, MOD_DT
				, MOD_USR
				, AUDIT_ACTION
				, AUDIT_TS
			)
			VALUES
			(
				:NEW.ID
				, :NEW.PROCID
				, :NEW.ACTSEQ
				, :NEW.WITEMSEQ
				, :NEW.FORM_TYPE
				, :NEW.FIELD_DATA
				, :NEW.CRT_DT
				, :NEW.CRT_USR
				, :NEW.MOD_DT
				, :NEW.MOD_USR
				, V_TRG_ACTION
				, SYSTIMESTAMP
			);
		WHEN DELETING THEN
			V_TRG_ACTION := 'DELETING';
			INSERT INTO TBL_FORM_DTL_AUDIT
			(
				ID
				, PROCID
				, ACTSEQ
				, WITEMSEQ
				, FORM_TYPE
				, FIELD_DATA
				, CRT_DT
				, CRT_USR
				, MOD_DT
				, MOD_USR
				, AUDIT_ACTION
				, AUDIT_TS
			)
			VALUES
			(
				:OLD.ID
				, :OLD.PROCID
				, :OLD.ACTSEQ
				, :OLD.WITEMSEQ
				, :OLD.FORM_TYPE
				, :OLD.FIELD_DATA
				, :OLD.CRT_DT
				, :OLD.CRT_USR
				, :OLD.MOD_DT
				, :OLD.MOD_USR
				, V_TRG_ACTION
				, SYSTIMESTAMP
			);
		ELSE V_TRG_ACTION := NULL;
	END CASE;

EXCEPTION
	WHEN OTHERS THEN
		SP_ERROR_LOG();

END;

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

--DROP INDEX TBL_LOOKUP_NK1
--;
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


--------------------------------------------------------
--  DDL for Table UG_MAPPING
--------------------------------------------------------

CREATE TABLE UG_MAPPING
(
	KEY NVARCHAR2(100)
	, NAME NVARCHAR2(100)
	, PARENT_MEM_ID VARCHAR2(10)
);

ALTER TABLE UG_MAPPING ADD CONSTRAINT UG_MAPPING_PK PRIMARY KEY (KEY);

COMMENT ON COLUMN UG_MAPPING.KEY IS 'Unique primary key';
COMMENT ON COLUMN UG_MAPPING.NAME IS 'The name of current user group';
COMMENT ON COLUMN UG_MAPPING.PARENT_MEM_ID IS 'Parent member ID';

/

CREATE OR REPLACE VIEW VW_LOOKUP AS 
  SELECT 
   TBL_ID ID
   , TBL_PARENT_ID PARENTID
   , TBL_LTYPE LTYPE
   , TBL_NAME NAME
   , TBL_LABEL LABEL
   , TBL_ACTIVE ACTIVE
   , TBL_DISP_ORDER DISPORDER
   , TBL_CATEGORY CATEGORY
FROM HHS_CMS_HR.TBL_LOOKUP 
ORDER BY TBL_PARENT_ID, TBL_LTYPE, DISPORDER, TBL_LABEL, TBL_NAME
;
/

CREATE TABLE ERLR_EMPLOYEE_CASE
(
	HHSID VARCHAR2(64) NOT NULL,
	CASEID NUMBER(10) NOT NULL,    
	FROM_CASEID NUMBER(10),
	M_DT DATE,
	M_MEMBER_ID NUMBER(10),
	M_MEMBER_NAME NVARCHAR2(100)
);

ALTER TABLE ERLR_EMPLOYEE_CASE ADD CONSTRAINT ERLR_EMPLOYEE_CASE_PK PRIMARY KEY (HHSID, CASEID);
/
CREATE OR REPLACE FORCE VIEW VW_ERLR_EMPLOYEE_CASE AS 
  SELECT * 
    FROM ERLR_EMPLOYEE_CASE     
  ORDER BY CASEID;
/
