BEGIN
    SP_ERLR_UPDATE_FINAL_RATING('Achieved Unsatisfactory Results',     '1 - Achieved Unsatisfactory Results');
    SP_ERLR_UPDATE_FINAL_RATING('Partially Achieved Expected Results', '2 - Partially Achieved Expected Results');
    SP_ERLR_UPDATE_FINAL_RATING('Achieved Expected Results',	       '3 - Achieved Expected Results');
    SP_ERLR_UPDATE_FINAL_RATING('Achieved More Than Expected Results', '4 - Achieved More Than Expected Results');
    SP_ERLR_UPDATE_FINAL_RATING('Achieved Outstanding Results',	       '5 - Achieved Outstanding Results');
END;
/