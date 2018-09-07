(function(window){
	'use strict';

 function CommonOpUtil(){
	 	function setStandardDateConstraint(className){
			if(className.replace(/\s/g,'') !== '' && className !== undefined){
			var list  = $('.'+className.replace(/\s/g,'')).get();
			 list.forEach(function(el){
			if(el.id !==''){
				hyf.calendar.setDateConstraint(el, 'Maximum', 'Today'); 
			}		
			});

			}
		}
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
	 return{
		 setStandardDateConstraint : setStandardDateConstraint,
		 dynamicMandatory : dynamicMandatory
	 }
 }
 (window.CommonOpUtil !== undefined ? window.CommonOpUtil : (window.CommonOpUtil = CommonOpUtil()));
})(window)