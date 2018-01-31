---------------------
-- Replace ADMIN_CODES table with view to ADMINISTRATIVE_CODE table.
--
-- Admin Code is no longer maintained in local ADMIN_CODES table.
-- EHRP DBA team created ADMINISTRATIVE_CODE table to maintain the data
-- and ADMIN_CODES table is recreated as a view to the ADMINISTRATIVE_CODE
-- table.
---------------------

DROP TABLE HHS_CMS_HR.ADMIN_CODES CASCADE CONSTRAINTS;

DROP SEQUENCE ADMIN_CODES_SEQ;

--------------------------------------------------------
--  DDL for View ADMIN_CODES
--------------------------------------------------------
CREATE OR REPLACE VIEW HHS_CMS_HR.ADMIN_CODES AS
	SELECT
		ADMINISTRATIVE_CODE AS AC_ADMIN_CD
		, DESCRIPTION AS AC_ADMIN_CD_DESCR
		, SUBSTR(ADMINISTRATIVE_CODE, 1, LENGTH(ADMINISTRATIVE_CODE) -1) AS AC_PARENT_CD
	FROM HHS_CMS_HR.ADMINISTRATIVE_CODE
	WHERE ADMINISTRATIVE_CODE = 'F' OR ADMINISTRATIVE_CODE LIKE 'FC%'  -- filter for HHS and CMS
;
/
