--------------------------------------------------------
--  DDL for altering the tables INCENTIVES_LE
--------------------------------------------------------
ALTER TABLE INCENTIVES_LE ADD (
  TOTAL_CREDITABLE_YEARS NUMBER(10) DEFAULT 0 NULL,
  TOTAL_CREDITABLE_MONTHS NUMBER(10) DEFAULT 0 NULL
);
/
