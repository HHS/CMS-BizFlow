INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (1830, 1771, 'ERLRCasesCompletedFinalAction', 'Grievance Withdrawn by Employee', 'Grievance Withdrawn by Employee', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (1831, 1772, 'ERLRCasesCompletedFinalAction', 'Case Withdrawn by Employee', 'Case Withdrawn by Employee', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (1832, 1772, 'ERLRCasesCompletedFinalAction', 'FLRA Case Remanded to Parties for New Hearing', 'FLRA Case Remanded to Parties for New Hearing', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (1833, 1773, 'ERLRCasesCompletedFinalAction', 'Case Withdrawn by Employee', 'Case Withdrawn by Employee', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (1834, 1773, 'ERLRCasesCompletedFinalAction', 'FSIP Imposed Agency Final Offer', 'FSIP Imposed Agency Final Offer', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_DISP_ORDER, TBL_MANDATORY, TBL_REGION, TBL_CATEGORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT) 
VALUES (1835, 1774, 'ERLRCasesCompletedFinalAction', 'Grievance Withdrawn by Employee', 'Grievance Withdrawn by Employee', '1', null, 'N', null, 'ERLR', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));


BEGIN
    SP_ERLR_MNG_FINAL_ACTION('UPDATE', '1775', 'Appeal Dismissed', 'MSPB Appeal Dismissed');
    SP_ERLR_MNG_FINAL_ACTION('UPDATE', '1775', 'Appeal Granted', 'MSPB Appeal Granted');
    SP_ERLR_MNG_FINAL_ACTION('UPDATE', '1775', 'Appeal Granted in Part, Dismissed in Part', 'MSPB Appeal Granted in Part, Dismissed in Part');
    SP_ERLR_MNG_FINAL_ACTION('UPDATE', '1775', 'Appeal Withdrawn', 'MSPB Appeal Withdrawn by Employee');
    SP_ERLR_MNG_FINAL_ACTION('UPDATE', '1772', 'Posting Ordered', 'FLRA Posting Ordered');
    SP_ERLR_MNG_FINAL_ACTION('UPDATE', '1773', 'FSIP Developed Decision', 'FSIP Imposed Decision');
    SP_ERLR_MNG_FINAL_ACTION('UPDATE', '1773', 'Union''s Last Final Offer', 'FSIP Imposed Union''s Last Final Offer');
    SP_ERLR_MNG_FINAL_ACTION('UPDATE', '1773', 'Med- Arb Split Decision', 'Mediation/Arbitration Split Decision');
    SP_ERLR_MNG_FINAL_ACTION('UPDATE', '1773', 'Med- Arb Agency Win', 'Mediation/Arbitration Agency Prevailed');
    SP_ERLR_MNG_FINAL_ACTION('UPDATE', '1773', 'Med- Arb Union Win', 'Mediation/Arbitration Union Prevailed');
END;

Commit;