UPDATE
(
  select VALUE AS OLD_VALUE, INDEXVALUE AS OLD_INDEXVALUE
  from rlvntdata 
  where rlvntdataname = 'requestStatus' 
    and procid in (select procid from procs where name in ('Strategic Consultation', 'Classification', 'Eligibility and Qualification Review') and state = 'C')
    and value <> 'Request Cancelled'
) T
SET T.OLD_VALUE = 'Completed', T.OLD_INDEXVALUE = 'Completed'

COMMIT;
