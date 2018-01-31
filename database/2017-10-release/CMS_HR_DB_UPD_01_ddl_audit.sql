
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


-- DROP TRIGGER TBL_FORM_DTL_AIUDR;

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




---------------------------------------------------
-- Missing column comments for core tables
---------------------------------------------------

COMMENT ON COLUMN ERROR_LOG.ID IS 'Unique primary key';
COMMENT ON COLUMN ERROR_LOG.ERROR_CD IS 'Error code';
COMMENT ON COLUMN ERROR_LOG.ERROR_MSG IS 'Error message';
COMMENT ON COLUMN ERROR_LOG.BACKTRACE IS 'Error trace';
COMMENT ON COLUMN ERROR_LOG.CALLSTACK IS 'PL/SQL call stack that leads to the error';
COMMENT ON COLUMN ERROR_LOG.CRT_DT IS 'Creation Date';
COMMENT ON COLUMN ERROR_LOG.CRT_USR IS 'Creation User';

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
