UPDATE
( SELECT ATTACH.CATEGORY AS OLD
  FROM ATTACH
  INNER JOIN PROCS ON ATTACH.PROCID = PROCS.PROCID
  WHERE PROCS.PREPROCDEFNAME IN ('Strategic Consultation', 'Classification', 'Eligibility and Qualifications Review') AND ATTACH.CATEGORY = 'Organization Chart'
) T
SET T.OLD = 'Staffing Chart'

COMMIT;