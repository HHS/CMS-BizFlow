UPDATE PROCS 
SET 
    ARCHIVEFLDRID = (SELECT FLDRID FROM FLDRLIST WHERE FLDRPATH = '/Process Archives/CMS'), 
    INSTFLDRID = (SELECT FLDRID FROM FLDRLIST WHERE FLDRPATH = '/Process Instances/CMS') 
WHERE 
    NAME IN ('Classification', 'Strategic Consultation', 'Eligibility and Qualification Review') 
    --AND ARCHIVEFLDRID = (SELECT FLDRID FROM FLDRLIST WHERE FLDRPATH = '/Process Archives') 
COMMIT;