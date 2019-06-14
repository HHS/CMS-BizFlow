-- CMS_06_BF_Update_Attach_for_Staffing_Chart.sql

SET DEFINE OFF;

UPDATE ( SELECT ATTACH.CATEGORY AS OLD
  FROM ATTACH
  INNER JOIN PROCS ON ATTACH.PROCID = PROCS.PROCID
  WHERE PROCS.PREPROCDEFNAME IN ('Strategic Consultation', 'Classification', 'Eligibility and Qualifications Review') AND ATTACH.CATEGORY = 'Organization Chart'
) T
SET T.OLD = 'Staffing Chart';
/

-- CMS_39_BF_update_rlvntdata_for_request_status.sql
UPDATE (
  select VALUE AS OLD_VALUE, INDEXVALUE AS OLD_INDEXVALUE
  from rlvntdata 
  where rlvntdataname = 'requestStatus' 
    and procid in (select procid from procs where name in ('Strategic Consultation', 'Classification', 'Eligibility and Qualification Review') and state = 'C')
    and value <> 'Request Cancelled'
) T
SET T.OLD_VALUE = 'Completed', T.OLD_INDEXVALUE = 'Completed'
/

-- CMS_117_BF_HHS_FN_AUTHORITY_SAM_DOCUMENTS.sql
UPDATE
(
  select VALUE AS OLD_VALUE, INDEXVALUE AS OLD_INDEXVALUE
  from rlvntdata 
  where rlvntdataname = 'requestStatus' 
    and procid in (select procid from procs where name in ('Strategic Consultation', 'Classification', 'Eligibility and Qualification Review') and state = 'C')
    and value <> 'Request Cancelled'
) T
SET T.OLD_VALUE = 'Completed', T.OLD_INDEXVALUE = 'Completed'
;
/

commit;
/

