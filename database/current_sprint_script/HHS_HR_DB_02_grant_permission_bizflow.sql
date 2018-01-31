

--=============================================================================
-- Grant privileges on objects under HHS schema to roles
-------------------------------------------------------------------------------


-- privilege on BIZFLOW tables to be used in stored procedure of HHS_HR schema
-- NOTE: This cannot be granted through role and should be granted individually and directly to user

GRANT SELECT, INSERT, UPDATE, DELETE ON BIZFLOW.MEMBER TO HHS_HR WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON BIZFLOW.MEMBERINFO TO HHS_HR WITH GRANT OPTION;
GRANT EXECUTE ON BIZFLOW.SP_GET_ID TO HHS_HR WITH GRANT OPTION;