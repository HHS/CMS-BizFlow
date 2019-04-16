-- Deactivate Component-wied lookup
UPDATE HHS_CMS_HR.TBL_LOOKUP SET TBL_ACTIVE = '0'
where TBL_LTYPE = 'PDScope'
  AND TBL_CATEGORY = 'NF'