update conddef set expr = '([IV:caseStatus] != "Closed")' where expr = '([IV:caseStatus] != "closeNow")';
update conddef set expr = '([IV:caseStatus] != "Closed")' where expr = '([IV:caseStatus] != "closeNow")';
update cond    set expr = '([IV:caseStatus] == "Closed")' where expr = '([IV:caseStatus] == "closeNow")';
update cond    set expr = '([IV:caseStatus] == "Closed")' where expr = '([IV:caseStatus] == "closeNow")';
commit;