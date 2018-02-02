CREATE OR REPLACE
FUNCTION fn_get_busdaysdiff(i_fromdate IN date, i_todate IN date)
  return int IS
  nDays int;
  BEGIN
    SELECT count(1) INTO nDays
      FROM cal c INNER JOIN calhead ch ON ch.dayofweek = c.dayofweek
     WHERE ch.daytype <> 'H'
       AND c.caldtime NOT IN (SELECT caldtime FROM membercal WHERE daytype = 'H' AND memberid = '0000000000') -- and memberid = calendarID)
       AND c.caldtime > i_fromdate
       AND c.caldtime <= i_todate
       AND ch.memberid = '0000000000';

    return NVL(nDays, 0);
  END;