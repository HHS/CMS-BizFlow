update hhs_cms_hr.tbl_lookup set tbl_name='Pending Oral Presentation', tbl_label='Pending Oral Presentation' where TBL_LTYPE='ERLRInitialResponseCasesStatus' and TBL_NAME=' Pending Oral Presentation';
update hhs_cms_hr.tbl_lookup set tbl_name='Pending Internal Review', tbl_label='Pending Internal Review' where TBL_LTYPE='ERLRInitialResponseCasesStatus' and TBL_NAME='Pending Internal View';
update hhs_cms_hr.tbl_lookup set tbl_name='Investigation', tbl_label='Investigation' where TBL_LTYPE='ERLRInitialResponseCaseType' and TBL_NAME='Formal Investigation';
update hhs_cms_hr.tbl_lookup set tbl_name='NoActionTaken', tbl_label='No Action Taken' where TBL_LTYPE='ERLRDemotionFinDecision' and TBL_LABEL='No Decision Issued';
/
