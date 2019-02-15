-- CMS_08_HR_UG_MAPPING.sql

SET DEFINE OFF;

DECLARE parent_mem_id VARCHAR(10);
BEGIN

  SELECT memberid INTO parent_mem_id FROM BIZFLOW.MEMBER WHERE type='H' and name='CMS';

  INSERT INTO UG_MAPPING(KEY, NAME, PARENT_MEM_ID) 
  VALUES ('Center/Office/Consortium Directors', 'Center/Office/Consortium Directors', parent_mem_id);

END;
/

COMMIT;
/
