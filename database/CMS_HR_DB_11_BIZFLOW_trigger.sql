CREATE OR REPLACE TRIGGER member_ug_name_bur
  BEFORE UPDATE OF name
  ON member
  REFERENCING NEW AS NEW OLD AS OLD
  FOR EACH ROW
  WHEN (new.type = 'G')
  BEGIN

    IF :new.name <> :old.name THEN
      UPDATE HHS_CMS_HR.UG_MAPPING SET NAME = :new.name, PARENT_MEM_ID = :new.parentdeptid
      WHERE NAME = :old.name and PARENT_MEM_ID = :old.parentdeptid;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20927, SQLERRM);
  END;

/

