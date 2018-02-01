

----------------------------------------------------
-- DBA statment to inspect deadlock and resolve
----------------------------------------------------
--SELECT s.sid, s.serial#, s.status, p.spid
--FROM v$session s, v$process p
--WHERE s.username = 'CMS'
--	AND p.addr(+) = s.paddr
--;
--ALTER SYSTEM KILL SESSION '22, 7157';


-------------------------------------------------------------------------------
-- DBA statement to change default profile to lift password expiration
-------------------------------------------------------------------------------
--SELECT * FROM DBA_USERS;
--SELECT * FROM DBA_PROFILES WHERE PROFILE='DEFAULT';
--ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;


----------------------------------------------------
-- DBA statement to reset password 
----------------------------------------------------
-- ALTER USER CMSADMIN IDENTIFIED BY <replace_with_password>;
-- ALTER USER HHS_CMS_HR IDENTIFIED BY <replace_with_password>;


----------------------------------------------------
-- backout statement
----------------------------------------------------
--DROP USER CMSADMIN CASCADE;
--DROP TABLESPACE HHS_CMS_HR_TS;
--DROP USER HHS_CMS_HR CASCADE;
--DROP USER CMSDEV CASCADE;
--DROP ROLE HHS_CMS_HR_RW_ROLE;
--DROP ROLE HHS_CMS_HR_DEV_ROLE;
--DROP ROLE BF_DEV_ROLE;





--=============================================================================
-- Create CMSADMIN user for DBA for CMS project
-------------------------------------------------------------------------------

-- admin user
CREATE USER CMSADMIN IDENTIFIED BY <replace_with_password>;
GRANT CONNECT, RESOURCE, DBA TO CMSADMIN;




--=============================================================================
-- Create TABLESPACE, USER for CMS project
-------------------------------------------------------------------------------


-- Make sure the directory to store the datafile actually exists on the server where DBMS is installed.
CREATE TABLESPACE HHS_CMS_HR_TS DATAFILE 'C:\bizflowdb\HHS_CMS_HR.DBF' SIZE 30M AUTOEXTEND ON NEXT 3M MAXSIZE UNLIMITED
;







CREATE USER HHS_CMS_HR IDENTIFIED BY <replace_with_password>
	DEFAULT TABLESPACE HHS_CMS_HR_TS
--	TEMPORARY TABLESPACE CMSTST
	QUOTA UNLIMITED ON HHS_CMS_HR_TS
;

-- developer user
CREATE USER CMSDEV IDENTIFIED BY <replace_with_password>
	DEFAULT TABLESPACE HHS_CMS_HR_TS
	QUOTA UNLIMITED ON HHS_CMS_HR_TS
;


-- create role and grant privilege
CREATE ROLE HHS_CMS_HR_RW_ROLE;
CREATE ROLE HHS_CMS_HR_DEV_ROLE;
CREATE ROLE BF_DEV_ROLE;

-- grant CMS role to CMS user
GRANT CONNECT, RESOURCE, HHS_CMS_HR_RW_ROLE TO HHS_CMS_HR;
GRANT CONNECT, RESOURCE, HHS_CMS_HR_DEV_ROLE TO CMSDEV;

-- grant CMS database privileges to CMS role
GRANT ALTER SESSION, CREATE CLUSTER, CREATE DATABASE LINK
	, CREATE SEQUENCE, CREATE SESSION, CREATE SYNONYM, CREATE TABLE, CREATE VIEW
	, CREATE PROCEDURE
	TO HHS_CMS_HR_RW_ROLE
;

-- grant CMS database privileges to CMS DEV role
GRANT ALTER SESSION, CREATE CLUSTER, CREATE DATABASE LINK
	, CREATE SEQUENCE, CREATE SESSION, CREATE SYNONYM, CREATE TABLE, CREATE VIEW
	, CREATE PROCEDURE
	TO HHS_CMS_HR_DEV_ROLE
;


-- grant workflow table access to role
BEGIN
	FOR ATAB IN (SELECT TABLE_NAME FROM ALL_TABLES WHERE OWNER = 'BIZFLOW') LOOP
		EXECUTE IMMEDIATE 'GRANT ALL ON BIZFLOW.'||ATAB.TABLE_NAME||' TO BF_DEV_ROLE';
	END LOOP;
END;





---------------------------------
-- CROSS schema access
---------------------------------

-- grant the CMS database access role to bizflow database user

GRANT HHS_CMS_HR_RW_ROLE TO BIZFLOW;


-- grant WORKFLOW database access role to HHS_CMS_HR database user

GRANT BF_DEV_ROLE TO HHS_CMS_HR;


-- grant WORKFLOW database access role to CMSDEV database user

GRANT BF_DEV_ROLE TO CMSDEV;
