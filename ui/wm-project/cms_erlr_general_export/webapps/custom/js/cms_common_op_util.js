(function(window){
	'use strict';

 function CommonOpUtil(){
	 /*
		Set standard date constraint for date fields, who's maximum value is today's date.
		The query selector is a css class name, that all date fields with this constraint must bear in their class list in wm.
	 */
	 	function setStandardDateConstraint(fieldClass){
			if(fieldClass.replace(/\s/g,'') !== '' && fieldClass !== undefined){
			var list  = $('.'+fieldClass.replace(/\s/g,'')).get();
			 list.forEach(function(el){
			if(el.id !=='' && el.id !== undefined){
				hyf.calendar.setDateConstraint(el.id, 'Maximum', 'Today'); 
			}		
		});

	}
	}
	/*
		dynamically set fields required based on activityName.
		The query selector is activityName_dynamic_require. All elements that should be dynamically required must have a class activityName_dynamic_require
		set in the css classes property in wm.
	*/
	function dynamicMandatory(activityName){
		var dynamic_requireActivity = BFActivityOption.getActivityName().replace(/\s/g,'');
			if(dynamic_requireActivity === activityName){
			var list  = $('.'+activityName+'_dynamic_require').get();
			 list.forEach(function(el){
				 if(el.id !==''){
					hyf.util.setMandatoryConstraint(el.id, true); 
				 }
				
			});
		}	
	}
	/*
		Generic XMLRespose processor for auto complete ajax calls to employee table. This is passed as a parameter to setAutoComplete function.
	*/
	function responseMapper(xml){
	var data = $('record', xml).map(function (){
		return {
			email: $('EMAIL_ADDR', this).text(),
			last_name: $('LAST_NAME', this).text(),
			first_name: $('FIRST_NAME', this).text(),
			middle_name: $('MIDDLE_NAME', this).text(),
			adminCode: $('ORG_CD', this).text(),
			admin_code_desc :$('ADMIN_CODE_DESC', this).text(),
			series : $('SERIES', this).text(),
			grade :$('GRADE', this).text(),
			step : $('STEP', this).text(),
			pay_plan :$('PAY_PLAN', this).text(),
			position_title: $('POSITION_TITLE_NAME', this).text()
		};
	}).get();
	return data
}
	 return{
		 setStandardDateConstraint : setStandardDateConstraint,
		 dynamicMandatory : dynamicMandatory,
		 responseMapper : responseMapper
	 }
 }
 (window.CommonOpUtil !== undefined ? window.CommonOpUtil : (window.CommonOpUtil = CommonOpUtil()));
})(window)