update hhs_cms_hr.tbl_lookup set tbl_name='Pending Oral Presentation', tbl_label='Pending Oral Presentation' where TBL_LTYPE='ERLRInitialResponseCasesStatus' and TBL_NAME=' Pending Oral Presentation';
update hhs_cms_hr.tbl_lookup set tbl_name='Pending Internal Review', tbl_label='Pending Internal Review' where TBL_LTYPE='ERLRInitialResponseCasesStatus' and TBL_NAME='Pending Internal View';
update hhs_cms_hr.tbl_lookup set tbl_name='Investigation', tbl_label='Investigation' where TBL_LTYPE='ERLRInitialResponseCaseType' and TBL_NAME='Formal Investigation';
update hhs_cms_hr.tbl_lookup set tbl_name='NoActionTaken', tbl_label='No Action Taken' where TBL_LTYPE='ERLRDemotionFinDecision' and TBL_LABEL='No Decision Issued';
/
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1697,748,'ERLRCasesCompletedFinalAction',' Impasse',' Impasse','1',null,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1698,748,'ERLRCasesCompletedFinalAction','Negotiations Terminated','Negotiations Terminated','1',null,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1699,748,'ERLRCasesCompletedFinalAction','Partial Agreement Reached','Partial Agreement Reached','1',null,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1700,748,'ERLRCasesCompletedFinalAction','Mediation','Mediation','1',null,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1701,748,'ERLRCasesCompletedFinalAction','Request to Bargain Withdrawn','Request to Bargain Withdrawn','1',null,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1702,748,'ERLRCasesCompletedFinalAction','Full Agreement Reached','Full Agreement Reached','1',null,'N',null,'ERLR',TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
