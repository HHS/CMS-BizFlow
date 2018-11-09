update HHS_CMS_HR.TBL_LOOKUP 
   set TBL_NAME ='Inappropriate Use of Government Credit Card - Travel', 
       TBL_LABEL = 'Inappropriate Use of Government Credit Card - Travel'
where tbl_ltype = 'ERLRCaseCategory'
  and TBL_NAME ='Inappropriate Use of Government Credit Card - Travle';