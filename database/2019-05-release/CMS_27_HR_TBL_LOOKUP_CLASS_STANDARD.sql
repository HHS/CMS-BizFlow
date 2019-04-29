-- Add new standard
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT)
VALUES (1809, 0, 'PositionClassificationStandard', 'JFSProfWorkMedicalHealthcare', 'U.S. OPM JFS for Prof Work in Medical and Healthcare Group, GS-0600; 09/17', '1', null, 'N', null, 'NF', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

-- Update standard
UPDATE HHS_CMS_HR.TBL_LOOKUP SET TBL_LABEL = 'U.S. OPM JFS for Admin Work in Info Tech Group, GS-2200; October 2018'
WHERE TBL_LTYPE = 'PositionClassificationStandard'
  AND TBL_ID = 597;

-- Deactivate following standard
UPDATE HHS_CMS_HR.TBL_LOOKUP SET TBL_ACTIVE = '0'
where TBL_LTYPE = 'PositionClassificationStandard'
  AND TBL_ID in (609, 610, 619, 620, 622, 624);
