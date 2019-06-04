
SET DEFINE OFF;


------------------------------------
--Backout Script
------------------------------------
/*
DROP VIEW HHS_CMS_HR.ADMIN_CODES;
*/


--------------------------------------------------------
--  DDL for View ADMIN_CODES
--------------------------------------------------------

	CREATE OR REPLACE VIEW HHS_CMS_HR.ADMIN_CODES
	AS
	SELECT
		ADMIN_CODE AS AC_ADMIN_CD,
		ADMIN_CODE_DESC AS AC_ADMIN_CD_DESCR,
		SUBSTR(ADMIN_CODE, 1, LENGTH(ADMIN_CODE) -1) AS AC_PARENT_CD
	FROM HHS_HR.ADMINISTRATIVE_CODE
	WHERE OPDIV = 'CMS'
	AND ADMIN_CODE = 'F' OR ADMIN_CODE LIKE 'FC%';
	
	COMMENT ON COLUMN HHS_CMS_HR.ADMIN_CODES.AC_ADMIN_CD IS 'Unique admin code';
	COMMENT ON COLUMN HHS_CMS_HR.ADMIN_CODES.AC_ADMIN_CD_DESCR IS 'Description of admin code';
	COMMENT ON COLUMN HHS_CMS_HR.ADMIN_CODES.AC_PARENT_CD IS 'Key value of associated parent admin code';	




