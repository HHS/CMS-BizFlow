-- CMS_HR_DB_UPD_48_core_tbl_ddl.sql

SET DEFINE OFF;

/**
 * NOTE:
 *
 * The following is conversion script to add unique key for PROCID on TBL_FORM_DTL table.
 * If there are already duplicate records in the target table, the creation of index will fail.
 * Therefore, inspection query is provided to run to figure out how many duplicate records exist.
 * Cleanup query is provided to remove duplicate record.  
 * If there are more than 2 duplicate records for any PROCID, you need to run the cleanup query as many times as needed.
 */


DROP INDEX TBL_FORM_DTL_NK1
;

-- inspect duplicate records
WITH D AS (
	SELECT PROCID, COUNT(PROCID) CNT
	FROM TBL_FORM_DTL
	GROUP BY PROCID
) 
SELECT ID, PROCID
FROM TBL_FORM_DTL 
WHERE PROCID IN (SELECT PROCID FROM D WHERE D.CNT > 1)
ORDER BY PROCID, ID
;

-- delete duplicate records
DELETE TBL_FORM_DTL 
WHERE ID IN (
	SELECT MIN(ID) AS ID FROM TBL_FORM_DTL
	WHERE PROCID IN (
		SELECT D.PROCID 
		FROM (
			SELECT PROCID, COUNT(PROCID) CNT
			FROM TBL_FORM_DTL
			GROUP BY PROCID
		) D
		WHERE D.CNT > 1
	)
	GROUP BY PROCID
	--ORDER BY ID
)
;

CREATE UNIQUE INDEX TBL_FORM_DTL_UK1 ON TBL_FORM_DTL (PROCID)
;
