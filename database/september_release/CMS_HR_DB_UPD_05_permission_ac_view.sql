
---------------------
-- Grant access to ADMIN_CODES view to ADMINISTRATIVE_CODE table
---------------------

-- privilege for HHS_CMS_HR_DEV_ROLE;
GRANT SELECT ON HHS_CMS_HR.ADMIN_CODES TO HHS_CMS_HR_RW_ROLE;

-- privilege for HHS_CMS_HR_DEV_ROLE;
GRANT SELECT ON HHS_CMS_HR.ADMIN_CODES TO HHS_CMS_HR_DEV_ROLE;
