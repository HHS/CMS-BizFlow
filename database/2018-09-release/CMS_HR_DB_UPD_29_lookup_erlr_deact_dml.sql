
SET DEFINE OFF;



-- deactivate 'Alternative Discipline'
UPDATE TBL_LOOKUP 
SET TBL_ACTIVE = '0'
WHERE TBL_ID IN (731)
;

