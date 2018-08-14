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
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('Chief Medical Officers', 'Chief Medical Officers', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('Office of the Administrators', 'Office of the Administrators', parent_mem_id);
  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) VALUES ('DGO Directors', 'DGO Directors', parent_mem_id);

  COMMIT;

  EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  RAISE;

END;
