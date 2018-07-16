SET DEFINE OFF ;


-------------------------------------------------------
-- Change datatype of PD_CYB_SEC_CD and convert data
-------------------------------------------------------
ALTER TABLE PD_COVERSHEET ADD PD_CYB_SEC_CD_NEW NVARCHAR2(100) ;

UPDATE PD_COVERSHEET SET PD_CYB_SEC_CD_NEW = TO_CHAR(PD_CYB_SEC_CD) ;

ALTER TABLE PD_COVERSHEET DROP COLUMN PD_CYB_SEC_CD ;

ALTER TABLE PD_COVERSHEET RENAME COLUMN PD_CYB_SEC_CD_NEW TO PD_CYB_SEC_CD ;


