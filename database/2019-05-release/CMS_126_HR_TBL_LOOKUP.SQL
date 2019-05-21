UPDATE TBL_LOOKUP SET TBL_ACTIVE = 0 WHERE TBL_ID IN(
1840,
1687,
1723,
1722,
1720,
1719,
1718,
1684);
BEGIN
	SP_ERLR_MNG_FINAL_ACTION('DELETE', '745', 'Grievance Withdrawn by Management');
	SP_ERLR_MNG_FINAL_ACTION('DELETE', '745', 'Grievance Withdrawn by Union');
	SP_ERLR_MNG_FINAL_ACTION('DELETE', '745', 'Grievance Granted in Part, Denied in Part');
	SP_ERLR_MNG_FINAL_ACTION('DELETE', '745', 'Grievance Granted');
	SP_ERLR_MNG_FINAL_ACTION('DELETE', '745', 'Grievance Denied');
	SP_ERLR_MNG_FINAL_ACTION('DELETE', '745', 'Resolved');
END;
