/*
Inactivate the following ER/LR Case Type
Administrative Leave
Career Ladder Promotion
Offer of Medical Exam
Reasonable Accomodation
Union Dues Start/Stop
Union Notification
*/
update hhs_cms_hr.tbl_lookup 
   set tbl_active = 0
 where tbl_id in (741, 742, 749, 752, 755, 756);
