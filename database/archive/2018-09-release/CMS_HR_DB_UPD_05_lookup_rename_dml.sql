
SET DEFINE OFF;

-- rename 'Reorganization for Existing Position' to 'Reorganization Pen & Ink'
UPDATE TBL_LOOKUP 
SET TBL_NAME = 'Reorganization Pen & Ink', TBL_LABEL = 'Reorganization Pen & Ink'
WHERE TBL_ID IN (73, 475, 483, 709)
;


-- deactivate 'Audit Position'
UPDATE TBL_LOOKUP 
SET TBL_ACTIVE = '0'
WHERE TBL_ID IN (71, 473, 481, 707)
;


-- deactivate 'Conduct 5-year Recertification'
UPDATE TBL_LOOKUP 
SET TBL_ACTIVE = '0'
WHERE TBL_ID IN (69, 78, 84, 471, 479, 705)
;
