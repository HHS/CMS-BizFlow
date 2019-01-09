--------------------------------------------------------
--  DDL for altering the tables INCENTIVES_SAM
--------------------------------------------------------
ALTER TABLE INCENTIVES_SAM ADD (
	JUSTIFICATION_MOD_REASON       VARCHAR2(100) NULL,
	JUSTIFICATION_MOD_SUMMARY      VARCHAR2(500) NULL,
	JUSTIFICATION_MODIFIER_NAME    VARCHAR2(100) NULL,
	JUSTIFICATION_MODIFIER_ID      VARCHAR2(10) NULL,
	JUSTIFICATION_MODIFIED_DATE    VARCHAR2(20) NULL	
);
/
