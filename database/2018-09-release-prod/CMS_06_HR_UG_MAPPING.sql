-- CMS_HR_DB_UPD_07_create_core_table.sql

--------------------------------------------------------
--  DDL for Table UG_MAPPING
--------------------------------------------------------

CREATE TABLE UG_MAPPING
(
    KEY NVARCHAR2(100)
  , NAME NVARCHAR2(100)
  , PARENT_MEM_ID VARCHAR2(10)
);

ALTER TABLE UG_MAPPING ADD CONSTRAINT UG_MAPPING_PK PRIMARY KEY (KEY);

COMMENT ON COLUMN UG_MAPPING.KEY IS 'Unique primary key';
COMMENT ON COLUMN UG_MAPPING.NAME IS 'The name of current user group';
COMMENT ON COLUMN UG_MAPPING.PARENT_MEM_ID IS 'Parent member ID';

/

-- CMS_HR_DB_UPD_08_insert_seed_data_UG.sql
-- CMS_HR_DB_UPD_30_ug_mapping.sql 
-- CMS_HR_DB_UPD_51_ug_mapping.sql

SET DEFINE OFF;

DECLARE parent_mem_id VARCHAR(10);
BEGIN

  SELECT memberid INTO parent_mem_id FROM BIZFLOW.MEMBER WHERE type='H' and name='CMS';

  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('HR Classification Specialists', 'HR Classification Specialists', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('Executive Officers', 'Executive Officers', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('HR Liaison', 'HR Liaison', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('HR Staffing Specialists', 'HR Staffing Specialists', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('Selecting Officials', 'Selecting Officials', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('Standard User Group', 'Standard User Group', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('DWC', 'DWC', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('Admin Team', 'Admin Team', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('HR Special Programs', 'HR Special Programs', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('DCO Managers and Leads', 'DCO Managers and Leads', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('DCO Managers Only', 'DCO Managers Only', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('Report Pilot Testers', 'Report Pilot Testers', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('HR Specialists', 'HR Specialists', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('TABG Directors', 'TABG Directors', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('OHC Directors', 'OHC Directors', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('OFM Directors', 'OFM Directors', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('Chief Physicians', 'Chief Physicians', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('Office of the Administrators', 'Office of the Administrators', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('DGHO Directors', 'TABG Division Directors', parent_mem_id);

END;
/

-- CMS_HR_DB_UPD_10_permission_core.sql
GRANT SELECT, UPDATE ON HHS_CMS_HR.UG_MAPPING TO BIZFLOW;
GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.UG_MAPPING TO HHS_CMS_HR_RW_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON HHS_CMS_HR.UG_MAPPING TO HHS_CMS_HR_DEV_ROLE;