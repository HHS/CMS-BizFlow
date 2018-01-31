
INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_MANDATORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT)
VALUES (716, 0, 'IneligibilityReason', 'NOT_US_CITIZEN', 'The candidate is not a US Citizen and therefore ineligible for consideration under this hiring authority.', '1', 'N', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_MANDATORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT)
VALUES (717, 0, 'IneligibilityReason', 'NOT_MEET_REQUIREMENT', 'The candidate does not meet eligibility requirements for this hiring authority.', '1', 'N', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_MANDATORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT)
VALUES (718, 0, 'IneligibilityReason', 'SA_NO_SCHEDULE_A_DOC', 'Did not provide proper Schedule A documentation demonstrating Schedule A eligibility.', '1', 'N', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_MANDATORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT)
VALUES (719, 0, 'IneligibilityReason', 'VS_NO_CURRENT_ENRL', 'The candidate''s transcript(s) does not show current enrollment in order to be considered under the student volunteer program.', '1', 'N', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO HHS_CMS_HR.TBL_LOOKUP (TBL_ID, TBL_PARENT_ID, TBL_LTYPE, TBL_NAME, TBL_LABEL, TBL_ACTIVE, TBL_MANDATORY, TBL_EFFECTIVE_DT, TBL_EXPIRATION_DT)
VALUES (720, 0, 'IneligibilityReason', 'VS_LOW_GPA', 'The candidate''s transcripts does not show a current GPA of 2.0 or higher in order to be considered under the student volunteer program.', '1', 'N', TO_DATE('2017-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2050-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));

COMMIT;
