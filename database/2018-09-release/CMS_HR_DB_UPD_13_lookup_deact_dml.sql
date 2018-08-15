
SET DEFINE OFF;



-- deactivate 'Audit Position'
UPDATE TBL_LOOKUP 
SET TBL_ACTIVE = '0'
WHERE TBL_PARENT_ID IN (71, 473, 481, 707)
;


-- deactivate 'Conduct 5-year Recertification'
UPDATE TBL_LOOKUP 
SET TBL_ACTIVE = '0'
WHERE TBL_PARENT_ID IN (69, 78, 84, 471, 479, 705)
;