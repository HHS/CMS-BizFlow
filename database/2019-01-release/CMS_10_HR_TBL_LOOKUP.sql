/*
Inactivate the following ER/LR Case Type
Administrative Leave
Career Ladder Promotion
Offer of Medical Exam
Reasonable Accomodation
Union Dues Start/Stop
Union Notification
*/
update hhs_cms_hr.tbl_lookup 
   set tbl_active = 0
 where tbl_id in (741, 742, 749, 752, 755, 756);

delete hhs_cms_hr.tbl_lookup where tbl_ltype = 'ERLRInitialResponseCasesStatus' and tbl_id in (768,769,770,771,772);

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) VALUES (768, 0, 'ERLRInitialResponseCasesStatus', 'Pending Third Party Decision', 'Pending Third Party Decision', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) VALUES (769, 0, 'ERLRInitialResponseCasesStatus', 'Researching', 'Researching', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) VALUES (770, 0, 'ERLRInitialResponseCasesStatus', 'Settlement Discussions', 'Settlement Discussions', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) VALUES (771, 0, 'ERLRInitialResponseCasesStatus', 'Waiting for Information', 'Waiting for Information', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1950-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));
