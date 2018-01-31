--------------------------------------------------------
--  DDL for Table ADMINISTRATIVE_CODE
--------------------------------------------------------

CREATE TABLE HHS_CMS_HR.ADMINISTRATIVE_CODE 
(
	ADMINISTRATIVE_CODE         VARCHAR2(20 BYTE)
	, DESCRIPTION               VARCHAR2(128 BYTE)
	, HRC_COMPONENT_ID          NUMBER                  DEFAULT 1
	, INSTITUTE                 VARCHAR2(50 BYTE)
	, ORGANIZATION_INITIALS     VARCHAR2(50 BYTE)
	, CENTER                    VARCHAR2(50 BYTE)
	, PROGRAM_NAME              VARCHAR2(50 BYTE)
	, PERSONNEL_OFFICE_ID       VARCHAR2(50 BYTE)
	, PROGRAM_OPDIV             VARCHAR2(50 BYTE)
) 
;
--------------------------------------------------------
--  DDL for Index ADMINISTRATIVE_CODE_UK1
--------------------------------------------------------

CREATE UNIQUE INDEX HHS_CMS_HR.ADMINISTRATIVE_CODE_PK ON HHS_CMS_HR.ADMINISTRATIVE_CODE (ADMINISTRATIVE_CODE, HRC_COMPONENT_ID) 
;

--------------------------------------------------------
--  Constraints for Table ADMINISTRATIVE_CODE
--------------------------------------------------------

ALTER TABLE HHS_CMS_HR.ADMINISTRATIVE_CODE ADD CONSTRAINT ADMINISTRATIVE_CODE_PK PRIMARY KEY (ADMINISTRATIVE_CODE, HRC_COMPONENT_ID);
ALTER TABLE HHS_CMS_HR.ADMINISTRATIVE_CODE MODIFY (HRC_COMPONENT_ID NOT NULL ENABLE);
ALTER TABLE HHS_CMS_HR.ADMINISTRATIVE_CODE MODIFY (DESCRIPTION NOT NULL ENABLE);
ALTER TABLE HHS_CMS_HR.ADMINISTRATIVE_CODE MODIFY (ADMINISTRATIVE_CODE NOT NULL ENABLE);









--------------------------------------------------------
--  DDL for Table ADMINISTRATIVE_CODE_LOADER
--------------------------------------------------------

CREATE TABLE HHS_CMS_HR.ADMINISTRATIVE_CODE_LOADER 
(
	DEPTID                      VARCHAR2(10 BYTE)
	, GVT_DESCR40               VARCHAR2(255 BYTE)
	, HRC_COMPONENT_ID          NUMBER
	, SETID                     VARCHAR2(10 BYTE)
	, EFFDT                     DATE
)
;
