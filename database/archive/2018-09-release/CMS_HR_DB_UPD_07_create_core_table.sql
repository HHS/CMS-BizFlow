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
