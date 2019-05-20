
--In order to give select permission to a view in HHS_CMS_HR
GRANT SELECT ON BIZFLOW.CAL TO HHS_CMS_HR WITH GRANT OPTION; -- in order to allow HHS_CMS_HR create a view accessing bizflow.cal table. 
GRANT SELECT ON BIZFLOW.CAL TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT ON BIZFLOW.CAL TO BF_DEV_ROLE;
/