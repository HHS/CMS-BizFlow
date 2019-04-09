--------------------------------------------------------
--  File created - Thursday-March-09-2017
--------------------------------------------------------
REM INSERTING into REQUEST_CONTROL
SET DEFINE OFF;
Insert into REQUEST_CONTROL (RC_DATE,RC_SEQ,RC_REQUEST_NUM) values (to_date('09-MAR-17','DD-MON-RR'),2,'20170309-0002');


--------------------------------------------------------
--------------------------------------------------------
REM INSERTING into INCENTIVES_REQUEST_CONTROL
SET DEFINE OFF;
Insert into INCENTIVES_REQUEST_CONTROL (RC_DATE,RC_SEQ,RC_REQUEST_NUM) values (to_date('09-MAR-17','DD-MON-RR'),1001,'20170309-0002');

commit;
