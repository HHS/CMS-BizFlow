update hhs_cms_hr.tbl_lookup set tbl_name='Investigation', tbl_label='Investigation' where TBL_LTYPE='ERLRInitialResponseCaseType' and TBL_NAME='Formal Investigation';
update hhs_cms_hr.tbl_lookup set tbl_name='NoActionTaken', tbl_label='No Action Taken' where TBL_LTYPE='ERLRDemotionFinDecision' and TBL_LABEL='No Decision Issued';
update HHS_CMS_HR.TBL_LOOKUP
   set tbl_name = trim(tbl_name), tbl_label = trim(tbl_label)
where tbl_name like ' %';

delete HHS_CMS_HR.TBL_LOOKUP where tbl_ltype = 'ERLRCasesCompletedFinalAction' and tbl_id between 1697 and 1756;

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1697,748,'ERLRCasesCompletedFinalAction','Impasse','Impasse','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1698,748,'ERLRCasesCompletedFinalAction','Negotiations Terminated','Negotiations Terminated','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1699,748,'ERLRCasesCompletedFinalAction','Partial Agreement Reached','Partial Agreement Reached','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1700,748,'ERLRCasesCompletedFinalAction','Mediation','Mediation','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1701,748,'ERLRCasesCompletedFinalAction','Request to Bargain Withdrawn','Request to Bargain Withdrawn','1',50,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1702,748,'ERLRCasesCompletedFinalAction','Full Agreement Reached','Full Agreement Reached','1',60,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1703,747,'ERLRCasesCompletedFinalAction','Information Provided','Information Provided','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1704,747,'ERLRCasesCompletedFinalAction','Information Request Denied','Information Request Denied','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1705,747,'ERLRCasesCompletedFinalAction','Information Provided in Part and Denied in Part','Information Provided in Part and Denied in Part','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1706,747,'ERLRCasesCompletedFinalAction','Settlement Agreement','Settlement Agreement','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1707,746,'ERLRCasesCompletedFinalAction','Documentation Provided','Documentation Provided','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1708,746,'ERLRCasesCompletedFinalAction','Documentation Not Provided','Documentation Not Provided','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1709,746,'ERLRCasesCompletedFinalAction','Documentation Accepted','Documentation Accepted','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1710,746,'ERLRCasesCompletedFinalAction','Documentation Not Accepted','Documentation Not Accepted','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1711,746,'ERLRCasesCompletedFinalAction','Documentation Request Rescinded','Documentation Request Rescinded','1',50,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1712,746,'ERLRCasesCompletedFinalAction','Settlement Agreement','Settlement Agreement','1',60,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1714,809,'ERLRCasesCompletedFinalAction','WGI Denied','WGI Denied','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1715,809,'ERLRCasesCompletedFinalAction','WGI Granted','WGI Granted','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1716,809,'ERLRCasesCompletedFinalAction','WGI Delayed','WGI Delayed','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1717,809,'ERLRCasesCompletedFinalAction','Other','Other','1',999,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1718,745,'ERLRCasesCompletedFinalAction','Grievance Granted','Grievance Granted','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1719,745,'ERLRCasesCompletedFinalAction','Grievance Denied','Grievance Denied','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1720,745,'ERLRCasesCompletedFinalAction','Grievance Granted in Part, Denied in Part','Grievance Granted in Part, Denied in Part','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1721,745,'ERLRCasesCompletedFinalAction','Settlement Agreement','Settlement Agreement','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1722,745,'ERLRCasesCompletedFinalAction','Grievance Withdrawn by Union','Grievance Withdrawn by Union','1',50,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1723,745,'ERLRCasesCompletedFinalAction','Grievance Withdrawn by Management','Grievance Withdrawn by Management','1',60,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1724,745,'ERLRCasesCompletedFinalAction','Other','Other','1',999,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1725,754,'ERLRCasesCompletedFinalAction','ULP Dismissed','ULP Dismissed','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1726,754,'ERLRCasesCompletedFinalAction','ULP Upheld','ULP Upheld','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1727,754,'ERLRCasesCompletedFinalAction','ULP Dismissed in Part, Upheld in Part','ULP Dismissed in Part, Upheld in Part','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1728,754,'ERLRCasesCompletedFinalAction','Posting','Posting','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1729,754,'ERLRCasesCompletedFinalAction','ULP Withdrawn by Union','ULP Withdrawn by Union','1',50,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1731,754,'ERLRCasesCompletedFinalAction','ULP Withdrawn by Management','ULP Withdrawn by Management','1',60,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1732,754,'ERLRCasesCompletedFinalAction','Other','Other','1',999,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1733,1772,'ERLRCasesCompletedFinalAction','Arbitrator''s Decision Upheld','Arbitrator''s Decision Upheld','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1734,1772,'ERLRCasesCompletedFinalAction','Arbitrator''s Decision Reversed','Arbitrator''s Decision Reversed','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1735,1772,'ERLRCasesCompletedFinalAction','Arbitrator''s Decision Upheld in Part, Reversed in Part','Arbitrator''s Decision Upheld in Part, Reversed in Part','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1736,1772,'ERLRCasesCompletedFinalAction','Case Remanded to Arbitrator for Revised Decision','Case Remanded to Arbitrator for Revised Decision','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1737,1772,'ERLRCasesCompletedFinalAction','Case Remanded to Parties for New Hearing','Case Remanded to Parties for New Hearing','1',50,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1738,1772,'ERLRCasesCompletedFinalAction','Settlement Agreement','Settlement Agreement','1',60,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1739,1772,'ERLRCasesCompletedFinalAction','Case Withdrawn by Union','Case Withdrawn by Union','1',70,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1740,1772,'ERLRCasesCompletedFinalAction','Case Withdrawn by Management','Case Withdrawn by Management','1',80,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1741,1772,'ERLRCasesCompletedFinalAction','ULP Dismissed','ULP Dismissed','1',90,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1742,1772,'ERLRCasesCompletedFinalAction','Posting Ordered','Posting Ordered','1',100,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1743,1772,'ERLRCasesCompletedFinalAction','Other','Other','1',999,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1744,1773,'ERLRCasesCompletedFinalAction','Med- Arb Agency Win','Med- Arb Agency Win','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1745,1773,'ERLRCasesCompletedFinalAction','Med- Arb Union Win','Med- Arb Union Win','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1746,1773,'ERLRCasesCompletedFinalAction','Med- Arb Split Decision','Med- Arb Split Decision','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1747,1773,'ERLRCasesCompletedFinalAction','Agency''s Last Final Offer','Agency''s Last Final Offer','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1748,1773,'ERLRCasesCompletedFinalAction','Union''s Last Final Offer','Union''s Last Final Offer','1',50,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1749,1773,'ERLRCasesCompletedFinalAction','FSIP Developed Decision','FSIP Developed Decision','1',60,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1750,1773,'ERLRCasesCompletedFinalAction','Other','Other','1',999,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1751,1775,'ERLRCasesCompletedFinalAction','Appeal Dismissed','Appeal Dismissed','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1752,1775,'ERLRCasesCompletedFinalAction','Appeal Granted','Appeal Granted','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1753,1775,'ERLRCasesCompletedFinalAction','Settlement Agreement','Settlement Agreement','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1754,1775,'ERLRCasesCompletedFinalAction','Appeal Granted in Part, Dismissed in Part','Appeal Granted in Part, Dismissed in Part','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1755,1775,'ERLRCasesCompletedFinalAction','Appeal Withdrawn','Appeal Withdrawn','1',50,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1756,1775,'ERLRCasesCompletedFinalAction','Other','Other','1',999,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1757,1771,'ERLRCasesCompletedFinalAction','Grievance Granted','Grievance Granted','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1758,1771,'ERLRCasesCompletedFinalAction','Grievance Denied','Grievance Denied','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1759,1771,'ERLRCasesCompletedFinalAction','Grievance Granted in Part, Denied in Part','Grievance Granted in Part, Denied in Part','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1760,1771,'ERLRCasesCompletedFinalAction','Settlement Agreement','Settlement Agreement','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1761,1771,'ERLRCasesCompletedFinalAction','Grievance Withdrawn by Union','Grievance Withdrawn by Union','1',50,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1762,1771,'ERLRCasesCompletedFinalAction','Grievance Withdrawn by Management','Grievance Withdrawn by Management','1',60,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1763,1771,'ERLRCasesCompletedFinalAction','Other','Other','1',999,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1764,1774,'ERLRCasesCompletedFinalAction','Grievance Granted','Grievance Granted','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1765,1774,'ERLRCasesCompletedFinalAction','Grievance Denied','Grievance Denied','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1766,1774,'ERLRCasesCompletedFinalAction','Grievance Granted in Part, Denied in Part','Grievance Granted in Part, Denied in Part','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1767,1774,'ERLRCasesCompletedFinalAction','Settlement Agreement','Settlement Agreement','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1768,1774,'ERLRCasesCompletedFinalAction','Grievance Withdrawn by Union','Grievance Withdrawn by Union','1',50,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1769,1774,'ERLRCasesCompletedFinalAction','Grievance Withdrawn by Management','Grievance Withdrawn by Management','1',60,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1770,1774,'ERLRCasesCompletedFinalAction','Other','Other','1',999,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1771,753,'ERLRCasesCompletedFinalAction','Arbitration','Arbitration','1',10,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1772,753,'ERLRCasesCompletedFinalAction','FLRA','FLRA','1',20,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1773,753,'ERLRCasesCompletedFinalAction','FSIP','FSIP','1',30,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1774,753,'ERLRCasesCompletedFinalAction','Grievance','Grievance','1',40,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) values (1775,753,'ERLRCasesCompletedFinalAction','MSPB','MSPB','1',50,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
