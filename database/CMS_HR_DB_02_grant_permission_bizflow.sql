

--=============================================================================
-- Grant privileges on objects under CMS schema to roles
-------------------------------------------------------------------------------


-- privilege on BIZFLOW tables to be used in stored procedure of HHS_CMS_HR schema
-- NOTE: This cannot be granted through role and should be granted individually and directly to user

GRANT SELECT, INSERT, UPDATE, DELETE ON BIZFLOW.RLVNTDATA TO HHS_CMS_HR;
GRANT SELECT, INSERT, UPDATE, DELETE ON BIZFLOW.PROCDEF TO HHS_CMS_HR;
GRANT SELECT, INSERT, UPDATE, DELETE ON BIZFLOW.PROCS TO HHS_CMS_HR WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON BIZFLOW.MEMBER TO HHS_CMS_HR WITH GRANT OPTION;
GRANT SELECT, UPDATE ON BIZFLOW.WITEM TO HHS_CMS_HR WITH GRANT OPTION;
GRANT SELECT ON BIZFLOW.ACT TO HHS_CMS_HR WITH GRANT OPTION;