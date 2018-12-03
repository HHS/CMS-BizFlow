update hhs_cms_hr.tbl_lookup set tbl_name='Pending Oral Presentation', tbl_label='Pending Oral Presentation' where tbl_LTYPE='ERLRInitialResponseCasesStatus' and tbl_NAME=' Pending Oral Presentation';
update hhs_cms_hr.tbl_lookup set tbl_name='Pending Internal Review', tbl_label='Pending Internal Review' where tbl_LTYPE='ERLRInitialResponseCasesStatus' and tbl_NAME='Pending Internal View';
/
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1697,748,'ERLRCasesCompletedFinalAction',' Impasse',' Impasse','1',null,'N',null,'ERLR',to_date('01-JAN-17','DD-MON-RR'),to_date('01-JAN-50','DD-MON-RR'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1698,748,'ERLRCasesCompletedFinalAction','Negotiations Terminated','Negotiations Terminated','1',null,'N',null,'ERLR',to_date('01-JAN-17','DD-MON-RR'),to_date('01-JAN-50','DD-MON-RR'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1699,748,'ERLRCasesCompletedFinalAction','Partial Agreement Reached','Partial Agreement Reached','1',null,'N',null,'ERLR',to_date('01-JAN-17','DD-MON-RR'),to_date('01-JAN-50','DD-MON-RR'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1700,748,'ERLRCasesCompletedFinalAction','Mediation','Mediation','1',null,'N',null,'ERLR',to_date('01-JAN-17','DD-MON-RR'),to_date('01-JAN-50','DD-MON-RR'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1701,748,'ERLRCasesCompletedFinalAction','Request to Bargain Withdrawn','Request to Bargain Withdrawn','1',null,'N',null,'ERLR',to_date('01-JAN-17','DD-MON-RR'),to_date('01-JAN-50','DD-MON-RR'));
Insert into HHS_CMS_HR.TBL_LOOKUP (TBL_ID,TBL_PARENT_ID,TBL_LTYPE,TBL_NAME,TBL_LABEL,TBL_ACTIVE,TBL_DISP_ORDER,TBL_MANDATORY,TBL_REGION,TBL_CATEGORY,TBL_EFFECTIVE_DT,TBL_EXPIRATION_DT) 
values (1702,748,'ERLRCasesCompletedFinalAction','Full Agreement Reached','Full Agreement Reached','1',null,'N',null,'ERLR',to_date('01-JAN-17','DD-MON-RR'),to_date('01-JAN-50','DD-MON-RR'));
