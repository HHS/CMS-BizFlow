update hhs_cms_hr.tbl_lookup set tbl_name='Investigation', tbl_label='Investigation' where TBL_LTYPE='ERLRInitialResponseCaseType' and TBL_NAME='Formal Investigation';
update hhs_cms_hr.tbl_lookup set tbl_name='NoActionTaken', tbl_label='No Action Taken' where TBL_LTYPE='ERLRDemotionFinDecision' and TBL_LABEL='No Decision Issued';
