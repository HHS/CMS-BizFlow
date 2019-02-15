--------------------------------------------------------
--  DDL for altering the tables INCENTIVES_SAM
--------------------------------------------------------
ALTER TABLE INCENTIVES_SAM ADD (
	JUSTIFICATION_LASTMOD_NAME     VARCHAR2(100) NULL,
	JUSTIFICATION_LASTMOD_ID       VARCHAR2(10) NULL,
	JUSTIFICATION_LASTMOD_DATE     VARCHAR2(20) NULL
);
/
