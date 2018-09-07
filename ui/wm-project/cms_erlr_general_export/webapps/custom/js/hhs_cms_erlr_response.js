var  cms_main_tab1  = {
    initialized: false,
	pageElements : [
		'contact_info_auto',
		'emp_info_auto',
		'org_assign'
		],
    groups : [
		'cms_rep_name_group',
		'investigation_conducted_date_group',
		'emp_info',
		'contactInfo',
		'primary_rep_group',
		'non_cms_primary_group',
		'non_cms_primary_group2',
		'selected_case_cats'
	],
	dropdownTargets : {
		/*I intend to have a list of dropdowns and their corresponding dynamic sections that I can access in a generic event hanlder
		like hyfShowOrHide({value:dropdownValue},dropdownTargets[event.target.id]);
		*/
		 GEN_DWC_SPECIALIST:'initiatorName', 
		 GEN_PRIMARY_REP:'primary_cms_non_cms',
		 GEN_INVESTIGATION:'primary_start_end_date',
		 GEN_STD_CONDUCT:'conduct_type_group'
	}
	init: function (){
		$('#main_buttons_layout_group').removeAttr('style');
		 cms_main_tab1.showCaseView('adr');
		cms_main_tab1.groups.forEach(function(el,index){
				hyf.util.hideComponent(el);
		});
		$('#primary_start_end_date,#conduct_type_group').hide();
		$('#delete_cust,#delete_emp').on('click',deleteContact);
		$('#cat_1,#cat_2,#cat_3').on('click',selectedCatChange);
	},
    render: function(){
		var contact = FormState.getState('custContact');
		var empContact = FormState.getState('empContact');
		var conduct = FormState.getState('std_conduct');
		var investigation = FormState.getState('investigation');
		var primarySpecialist = FormState.getState('dwc_specialist');
		var status = FormState.getState('case_status');
		var cmsRep = FormState.getState('primary_rep');
		var relatedTo = FormState.getState('relatedCaseNumber');
		var relatedToHidden = FormState.getState('related_to_case');
		var caseCat = FormState.getState('selected_category');
	    var caseType = FormState.getState('case_type');
		if(caseType && caseType.dirty){
			if(caseType.value.replace(/\s/g,'') === 'PerformanceIssue'){
				hyf.util.hideComponent('caseTypeHidden');
			}else{
				hyf.util.showComponent('caseTypeHidden');
			}
		}
		if(conduct && conduct.dirty){
			stdConduct(conduct.value);
		}
		if(investigation && investigation.dirty){
			investigationConducted(investigation.value);
		}
		if(primarySpecialist && primarySpecialist.dirty){
			primaryDWCSpecialist(primarySpecialist.text);
		}
		if(status && status.dirty && status.value !=='default'){
			$('#output_caseStatus').text(status.text);
		}
		if(cmsRep && cmsRep.dirty && cmsRep.value === 'cms'){
			primaryRep();
			hyf.util.showComponent('cms_rep_name_group');
		}else if(cmsRep && cmsRep.dirty && cmsRep.value === 'non_cms'){
			primaryRep();
			hyf.util.showComponent('non_cms_primary_group');
			hyf.util.showComponent('non_cms_primary_group2');
		}else if(cmsRep && cmsRep.dirty){
			primaryRep();
		}
		if((contact && contact.dirty)){	
			var name  = contact.value.split(',');
			populateContactInfo({last_name: name[0],first_name: name[1],adminCode : name[2],admin_code_desc:name[3]
			,step:name[4],grade:name[5],series:name[7],pay_plan:name[6]},'contact_info_auto');
		}
		if((empContact && empContact.dirty)){
			var name  = empContact.value.split(',');				
			populateContactInfo({last_name: name[0],first_name: name[1],adminCode : name[2],admin_code_desc:name[3]
			,step:name[4],grade:name[5],series:name[7],pay_plan:name[6],position_title:name[8]},'emp_info_auto');
		}
		if(!cms_main_tab1.initialized && (relatedToHidden && relatedToHidden.dirty)){
			var parse = (relatedToHidden.value.indexOf(',') > -1) ? relatedToHidden.value.split(',') : [relatedToHidden.value];
			parse.forEach(function(el, indx){
				if(el !='' && el !== undefined){
				$('#related_case').append('<br/><a href="#" id="'+el+'">'+el+'</a>');
				}
			});
		}
		if((relatedTo && relatedTo.dirty)){
			if(relatedTo.dirty){relatedCaseNumber(relatedTo.value);}
		}
		if( relatedToHidden && relatedToHidden.dirty){
			if(relatedToHidden.dirty){relatedCaseNumber(relatedToHidden.value);}
		}
		if(caseCat && caseCat.dirty){
			caseCategory();
			hyf.util.showComponent('selected_case_cats');
		}
		if(!cms_main_tab1.initialized){
		FormAutoComplete.setAutoComplete('contact_info_auto','/bizflowwebmaker/cms_erlr_service/contactInfo.do?cust=',populateContactInfo,CommonOpUtil.responseMapper,appendInfo);
		FormAutoComplete.setAutoComplete('emp_info_auto','/bizflowwebmaker/cms_erlr_service/contactInfo.do?emp=',populateContactInfo,CommonOpUtil.responseMapper,appendInfo);
		FormAutoComplete.setAutoComplete('cms_primary_rep','/bizflowwebmaker/cms_erlr_service/contactInfo.do?cust=',populateContactInfo,CommonOpUtil.responseMapper,appendInfo);
		hyf.calendar.setDateConstraint('date_customer_contacted', 'Maximum', 'Today');
		hyf.calendar.setDateConstraint('start_date', 'Maximum', 'Today');
		hyf.calendar.setDateConstraint('end_date', 'Maximum', 'Today');
		cms_main_tab1.initialized = true;
	   }
	  
    },
	// load case view will be used as event handler on case type select box. 
	showCaseView : function(caseValue){
		var tempGroups = cms_main_tab1.groups;
		tempGroups.forEach(function(el,index){
			if(el.indexOf(caseValue) > -1){
				hyf.util.showComponent(el);	
			}			
		});
	},
	/*using a generic function to handle all autocomplete features is better practice,
	than repeating same logic all over the place for different autocomplete controls
	@param : url represents the endpoint for the ajax call, eg : /bizflowwebmaker/someAutocompleteProject/somePartialPage.do'
	@param : id represents the id of the control to attach autocomplete event handler to.
	@param : callBack represents a function to be called,passing in the selected item
	*/
	setAutoComplete: function(id,url,selectionCallBack,responseProcessor,appender){
			if(id != undefined && url != undefined){
				$('#' + id).autocomplete({
				source: function (request, response){
                $.ajax({
                    url: url +$('#' + id).val(),
                    dataType: 'xml',
                    cache: false,
                    success: function (xmlResponse){
					var data =responseProcessor(xmlResponse);
                    response(data);
                    }
                });
            },
            minLength: 2,
            change: function (e, u) {
                var pos = $(this).position();
                if (u.item == null) {
                    $(this).val('');
                    return false;
                }
            },
            select: function (event, ui){
                event.preventDefault();
                //call a function passing in the selected item
				selectionCallBack(ui.item,id);				
            },
            open: function () {
                $('.ui-autocomplete').css('z-index', 5000);
            },
            close: function () {
                $('.ui-autocomplete').css('z-index', 1);
            }
        })
        .autocomplete().data('ui-autocomplete')._renderItem = function (ul, item) {
            ul.attr('role', 'listbox');
			var el =''+ appender(item);
            return $('<li>')
                .append(el)
                .appendTo(ul);
        };
		}       
    }
};
//implement case specific logic in the function to be as an API in the render function.
//@param caseSelected: The value of the case type selected from dropdown
function CaseType(){	
	return{
		conductIssue : conductIssue,
		populateDropdowns : populateDropdowns
	}	
	function conductIssue(){
		
	}		
}

function populateContactInfo(item,id){
		var validName  = (item.last_name  && item.first_name) ? true :false;
		if(id ==='contact_info_auto'){
			if(!validName){
				hyf.util.hideComponent('contactInfo');
			}else{ 
				var name = item.last_name +','+item.first_name +' '+item.middle_name;	
				if(item.email!=='' && item.email !== undefined){
					name +=' ('+item.email+')';	
				}
				if(item.admin_code_desc ==='' || item.admin_code_desc === undefined){
					item.admin_code_desc ='';	
				}
				name = name.replace(/undefined/g,'');
				$('#contactName').text(name);                
                FormState.doAction(StateAction.changeText('contactName', name), false); // For PV binding by Ginnah
				$('#admin_code2').text(item.adminCode);
				$('#custContact').val(name);
				$('#cust_org').text(item.admin_code_desc);
				FormState.doActionNoRender(StateAction.changeText('custContact',name +','+item.adminCode+','+item.admin_code_desc+','+item.step+','+item.grade,+','+item.series+','+item.pay_plan));
				$('#contact_info_auto').val('');
				hyf.util.showComponent('contactInfo');	
				hyf.util.setMandatoryConstraint('contact_info_auto', false);
			}			
		}else if(id ==='emp_info_auto'){
		if(!validName){
				hyf.util.hideComponent('emp_info');	
			}else{
				var name = item.last_name +','+item.first_name +' '+item.middle_name;				
				if(item.email!=='' && item.email !== undefined){
					name +=' ('+item.email+')';
				}
				if(item.admin_code_desc ==='' || item.admin_code_desc === undefined){
					item.admin_code_desc ='';	
				}
				name = name.replace(/undefined/g,'');
				$('#empName').text(name);                
                FormState.doAction(StateAction.changeText('empName', name), false); // For PV binding by Ginnah
				$('#admin_code').text(item.adminCode);
				$('#emp_org').text(item.admin_code_desc);                
				FormState.doActionNoRender(StateAction.changeText('empOrg', item.admin_code_desc)); // For PV binding by Ginnah
                var txt = item.adminCode+','+item.admin_code_desc+','+item.step+','+item.grade+','+item.series+','+item.pay_plan+','+item.position_title;
				$('#empContact').val(name+','+txt);	
				FormState.doActionNoRender(StateAction.changeText('empContact',name+','+txt));                
				$('#emp_info_auto').val('');
				hyf.util.showComponent('emp_info');	
		}			
	}else if(id ==='cms_primary_rep'){
		if(validName){
			var name = item.last_name +','+item.first_name +' '+item.middle_name;
				name = name.replace(/undefined/g,'');			
		if(item.email!=='' && item.email !== undefined){
				name +='('+item.email+')';
			}
			$('#cms_primary_rep').val(name);	
			FormState.doActionNoRender(StateAction.changeText('cms_primary_rep',name));
		}
	}		
}
function appendInfo(item){
		var name = item.last_name +','+item.first_name +' '+item.middle_name;
		if(item.email!=='' && item.email !== undefined){
			name +='('+item.email+')';	
		}
	return '<a role="option">' + name +'</a>'
}
function append(item){
	return '<option value="'+item.name+'">'+ item.name + ' ('+ item.email +')</option>';
}
function deleteContact(e){
	if(e.target.id ==='delete_cust'){
		$('#contactName').text('');	
		$('#admin_code2').text('');
		$('#cust_org').text('');		
		$('#phone').val('');
		$('#custContact').val(''+','+''+','+''+','+'');
		FormState.doActionNoRender(StateAction.changeText('custContact',''+','+''+','+''+','+''));
		FormState.doActionNoRender(StateAction.changeText('phone',''));
		hyf.util.setMandatoryConstraint('contact_info_auto', true);
		hyf.util.hideComponent('contactInfo');
	}else if(e.target.id ==='delete_emp'){
		$('#empName').text('');	
		$('#admin_code').text('');
		$('#emp_org').text('');		
		$('#phone_2').val('');		
		$('#empContact').val(''+','+''+','+''+','+'');	
		FormState.doActionNoRender(StateAction.changeText('empContact',''+','+''+','+''+','+''));
		FormState.doActionNoRender(StateAction.changeText('phone_2',''));
		hyf.util.hideComponent('emp_info');		
	}
}
function primaryRep(){
	var val = $('#primary_rep').val();
	if(val ==='cms'){
		hyf.util.showComponent('cms_rep_name_group');
		hyf.util.hideComponent('non_cms_primary_group');
		hyf.util.hideComponent('non_cms_primary_group2');
	}else{
		hyf.util.hideComponent('cms_rep_name_group');
	}
	if(val ==='non_cms'){
		hyf.util.showComponent('non_cms_primary_group');
		hyf.util.showComponent('non_cms_primary_group2');
	}else{
		hyf.util.hideComponent('non_cms_primary_group');
		hyf.util.hideComponent('non_cms_primary_group2');
	}
}
function investigationConducted(e){
	//var yes = (e === 'Y') ? true : false;
	if(e === 'Y'){
		hyf.util.showComponent('primary_start_end_date');
	}else{
		hyf.util.hideComponent('primary_start_end_date');
	}
}
function stdConduct(e){
	//var yes = (e === 'Y') ? true : false;
	if(e === 'Y'){
		hyf.util.showComponent('conduct_type_group');
	}else{
		hyf.util.hideComponent('conduct_type_group');
	}
}
function primaryDWCSpecialist(e){
	if(e !== 'Select One'){
		if(e && e.indexOf('(')){
		$('#initiatorName').text(e.substring(0, e.indexOf('(')));
	}else{
		$('#initiatorName').text(e);
	}
	}		
}
function caseCategory(){
	var selection = $('#case_category').val();
	var hidenVal = $('#selected_category').val() +','+selection;
	$(selection).prop('checked', true);
	FormState.doActionNoRender(StateAction.changeText('selected_category',hidenVal));
	hyf.util.showComponent('selected_case_cats');
}
function relatedCaseNumber(val){
	var relatedTo ='';
	if(val != undefined && val !==''){
		relatedTo = $('#related_to_case').val() +','+ val;
		$('#relatedCaseNumber').val('');
		FormState.doActionNoRender(StateAction.changeText('related_to_case',relatedTo));
		$('#relatedCaseNumber').attr('value','');
		var selction = relatedTo.split(',');
		$('#related_case').html('');
		if(selction.length == 1){
			$('#related_case').append('<a href="#">'+el+'</a>');
		}else{
			selction.forEach(function(el){
			if(el !==''){
			$('#related_case').append('<a href="#">'+el+'</a><br/>');
			}
		});
		}		
	}	
}
function selectedCatChange(){
	var values = ['cat_1','cat_2','cat_3'];
		values.forEach(function(el, indx){
		if($(el).val() === 'true'){
			$(el).show();
		}else{
			$(el).hide();
		}
	});
}