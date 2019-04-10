-- Re-activate Component-wied lookup for creating test scenarios
UPDATE HHS_CMS_HR.TBL_LOOKUP SET TBL_ACTIVE = '1'
where TBL_LTYPE = 'PDScope'
  AND TBL_CATEGORY = 'NF'