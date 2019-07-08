/* global _ angular $ CMS_REPORT_FILTER */
(function () {
    'use strict';

    angular.module('bizflow.app').component('reportFilter', {
        templateUrl: function ($element, $attrs, bizflowContext) {
            var template = 'features/reportFilter/report-filter.html';
            return template;
        },
        controller: Ctrl
    });

    function Ctrl ($scope, blockUI, bizflowContext, $log, $window, $filter, $location) {
        var vm = this;

        // Attributes
        vm.report = {'name': '', 'description':''};
        vm.group = {};

        // Primitive Options - Not for Selectize
        vm._components = ['By Admin Code', 'Office of the Administrator (OA) Only'];
        vm._includeSubOrgs = ['Yes', 'No'];
        vm._requestTypes = ['All', 'Appointment', 'Classification Only', 'Recruitment'];
        vm._appointmentTypes = ['All', '30% or more disabled veterans', 'Expert/Consultant', 'Schedule A', 'Veteran Recruitment Appointment (VRA)', 'Volunteer'];
        vm._scheduleATypes = ['All', 'CMS Fellows-Paid (R)', 'Digital Services', 'Disability (U)', 'Innovator-In-Residence', 'Interpreters (LL)', 'WRP (Summer Hire)'];
        vm._volunteerTypes = ['All', 'CMS Fellows-Unpaid', 'Student Volunteer', 'Wounded Warriors', 'Youth Works'];
        vm._dayTypes = ['Business Days', 'Calendar Days'];
        //vm.dayTypes = [{key:'Business',value: 'Business Days'}, {key:'Calendar', value: 'Calendar Days'}];
        vm._standardPDs = ['All', 'N/A', 'HHS-wide', 'CMS-wide', 'Consortia-wide', 'Component-wide', 'Group-wide or below'];

        vm.reportMap = [{
                'name': 'CMS Time of Possession - Classification Only Report - Completed', 
                'description': 'Calculates the time HR and Component users held a request. This report only displays data for "Classification Only" requests.',
                'requestType': ["Classification Only"]
            },{
                'name': 'CMS Time to Consult Report - Completed', 
                'description': 'Calculates the number of business days it took for a job request to complete the Strategic Consultation process.',
                'showTypeOfStandardPD': 'true'
            },{
                'name': 'CMS Time to Classify Report - Completed', 
                'description': 'Calculates the number of business days it took for a job request to complete the Classification process.',
                'showTypeOfStandardPD': 'true'
            },{
                'name': 'CMS Time to Appoint Report - Completed', 
                'description': 'Calculates the number of business days it took to complete a job request through the Appointment Only process.',
                'requestType': ["Appointment"]
            },{
                'name': 'CMS Time to Staff Report - Completed', 
                'description': 'Calculates the number of business days it took for a recruitment request to go through the staffing process in USA Staffing. Time starts when a request is approved in USA Staffing, and tracks it through the Certificate Review Return Date.',
                'requestType': ["Recruitment"],
                'dateLabel': 'Date Certificate Review Return Completed',
            },{
                'name': 'CMS Time to Offer Report - Completed', 
                'description': 'Calculates the number of business days it took a recruitment and/or appointment request to go through the USA Staffing offer process. Time starts when a new hire request is created in USA Staffing, and tracks through the Send Official Offer Complete date.',
                'requestType': ['All', 'Appointment', 'Recruitment'],
                'dateLabel': 'Date Send Official Offer Completed',
            },{
                'name': 'CMS Time of Possession - Strategic Consultation and Classification Report - Completed', 
                'description': 'Calculates the time HR and Component users held a request. This report displays data for the Strategic Consultation and Classification processes.'
            },{
                'name': 'CMS Time to Hire End to End Report - Completed', 
                'description': 'Calculates the number of business days it took a recruitment and/or appointment request to go through the entire process. Time starts when a new request is created in NEIL, and tracks through the Send Official Offer Complete date.',
				'requestType': ['All','Appointment', 'Recruitment'],
                'dateLabel': 'Date Send Official Completed',
                'showTypeOfStandardPD': 'true'
            }, {
				'name': 'CMS My Monitor - Active Requests Report', 
                'description': 'Mandatory filters required to run the report.',				
				'dateLabel': 'Date Request Created'
			}, {
				'name': 'CMS My Monitor - Completed Requests Report', 
                'description': 'Mandatory filters required to run the report.'		
			}, {
				'name': 'CMS Request Current Status Report', 
                'description': 'Mandatory filters required to run the report.',
				'dateLabel': 'Date Request Created'				
			}, {
				'name': 'CMS HR Appointment Workload Summary Report', 
                'description': 'Mandatory filters required to run the report.',
				'requestType': ["Appointment"],
				'dateLabel': 'Date Request Created'
			},{
                'name': 'CMS Appointment Eligibility and Qual Review', 
                'description': 'Calculates the number of business days it took to complete a job request through the Appointment Only process.',
                'requestType': ["Appointment"],
                'appointmentType': ['All', '30% or more disabled veterans', 'Expert/Consultant', 'Schedule A', 'Veteran Recruitment Appointment (VRA)']
            }, {
                'name': 'CMS USA Staffing Active Requests', 
                'description': 'Mandatory filters required to run the report.',				
                'requestType': ["All", "Appointment", "Recruitment"],
				'dateLabel': 'Date Request Created'
            }, {
                'name': 'CMS Time of Possession End to End Report - Active', 
                'description': 'Mandatory filters required to run the report.',				
                'requestType': ["All", "Appointment", "Recruitment"],
				'dateLabel': 'Date Request Created'
            }, {
                'name': 'CMS Time of Possession End to End Report - Completed', 
                'description': 'Mandatory filters required to run the report.',				
                'requestType': ["All", "Appointment", "Recruitment"],
				'dateLabel': 'Date Verify New Hire Completed'
            }
        ];

        // Default Values
        vm.orgSelected = {
            component: '',
            adminCode: '',
            includeSubOrg: 'Yes',
            requestType: 'All',
            classificationType: 'All',
            appointmentType: 'All',
            scheduleAType: 'All',
            volunteerType: 'All',
            fromDate: null,
            toDate: null,
            selectingOfficial: 'All',
            executiveOfficer: 'All',
            hrLiaison: 'All',
            staffSpecialist: 'All',
            classSpecialist: 'All',
            standardPD: 'All',
            selectingOfficial508: null,
            executiveOfficer508: null,
            hrLiaison508: null,
            staffSpecialist508: null,
            classSpecialist508: null
        };
        // Selected Values
        vm.selected = {};

        // Date From - To
        vm.dateLabel = "Date Request Completed";

        vm.fromDateOpened = false;
        vm.toDateOpened = false;
        vm.dateOptionFrom = { showWeeks: false, maxDate: new Date() };
        vm.dateOptionTo = { showWeeks: false, maxDate: new Date() };

        // Selectize configuration for members in User Group
        vm.membersInGroupConfig = {
            maxItems:1,
            create: false,
            valueField: 'memberid',
            labelField: 'name',
            searchField: ['name'],
            selectOnTab: true,
        };
        // Selectize configuration for simple list
        vm.simpleConfig = {
            maxItems:1,
            create: false,
            valueField: 'value',
            labelField: 'key'
        };

        vm.getSelectizeOptions = function(items) {
            if (vm.isSection508User == false) {
                return items.map(function(item) {
                    return {key: item, value: item};
                })
            } else {
                return items;
            }
        }
        vm.copyItems = function(targets, sources) {
            if (targets) {
                if (targets.length > 0) {
                    targets.length = 0;
                }
                for (var i = 0; i < sources.length; i++) {
                    targets.push(sources[i]);
                }
            }
        }

        vm.classTypesForAll = [];
        vm.classTypesForClass = [];
        vm.classTypesForRecruitment = [];
        vm.classTypesForAppointment = [];
        vm.classTypesForOther = [];

        vm.allClassificationTypes = ['All', 'Audit Position', 'Create New Position Description', 'Reorganization Pen & Ink',
                                    'Reorganization for New Position', 'Review Existing Position Description','Update Coversheet', 'Update Major Duties'];
        vm.recruitmentClassificationTypes = ['All','Create New Position Description', 'Reorganization Pen & Ink', 
                                'Reorganization for New Position', 'Review Existing Position Description', 'Update Coversheet', 'Update Major Duties'];

        // Functions
        vm.getClassificationTypes = function () {
            if (vm.selected.requestType === 'All') {
                if (vm.classTypesForAll.length == 0) {
                    for (var i=0; i<vm._requestTypes.length; ++i) {
                        if (vm._requestTypes[i] === 'Classification Only') {
                            vm.classTypesForAll = _.union(vm.classTypesForAll, vm.allClassificationTypes);        
                        } else if (vm._requestTypes[i] === 'Recruitment'){
                            vm.classTypesForAll = _.union(vm.classTypesForAll, vm.recruitmentClassificationTypes);        
                        } else if (vm._requestTypes[i] === 'Appointment') {
                            vm.classTypesForAll = _.union(vm.classTypesForAll, vm.recruitmentClassificationTypes);        
                        }                        
                    }                    
                    vm.classTypesForAll.sort();
                    vm.classTypesForAll = vm.getSelectizeOptions(vm.classTypesForAll);
                }
                return vm.classTypesForAll;                
            } else if (vm.selected.requestType === 'Classification Only') {
                if (vm.classTypesForClass.length == 0) {
                    vm.classTypesForClass = vm.classTypesForClass.concat(vm.allClassificationTypes);
                    vm.classTypesForClass.sort();
                    vm.classTypesForClass = vm.getSelectizeOptions(vm.classTypesForClass);
                }
                return vm.classTypesForClass;                
            } else if (vm.selected.requestType === 'Recruitment') {
                if (vm.classTypesForRecruitment.length == 0) {
                    vm.classTypesForRecruitment = vm.classTypesForRecruitment.concat(vm.recruitmentClassificationTypes);
                    vm.classTypesForRecruitment.sort();
                    vm.classTypesForRecruitment = vm.getSelectizeOptions(vm.classTypesForRecruitment);
                }
                return vm.classTypesForRecruitment;
            } else if (vm.selected.requestType === 'Appointment') {
                if (vm.classTypesForAppointment.length == 0) {
                    vm.classTypesForAppointment = vm.classTypesForAppointment.concat(vm.recruitmentClassificationTypes);
                    vm.classTypesForAppointment.sort();
                    vm.classTypesForAppointment = vm.getSelectizeOptions(vm.classTypesForAppointment);
                }
                return vm.classTypesForAppointment;
            } else {
                return vm.classTypesForOther;
            }
        };

        vm.adjustBizCoveUI = function () {
            try {
                $('#mainWrapper table.tableTab', window.parent.document).remove(); // Remove BizCove Header
                $('#mainWrapper table.list td', window.parent.document).css({'padding': '0px 0px 0px 0px'}); // Adjust padding
                $('#modalPopupMax0Title', window.parent.parent.document).text(vm.report.name); // Set report name
            } catch (e) {
                $log.error(e);
            }
        };

        vm.initUserGroups = function () {
            for (var prop in vm.group) {
                if (vm.group.hasOwnProperty(prop)) {
                    vm.group[prop].unshift({grpname: '', grpid: '', memberid: 'All', name: 'All'});
                }
            }
            var amIDCOManagerLeads = _.filter(vm.group['DCO Managers and Leads'], function (item) {
                return item.memberid === CMS_REPORT_FILTER.CURUSERID;
            });
            var amIAdminTeam = _.filter(vm.group['Admin Team'], function (item) {
                return item.memberid === CMS_REPORT_FILTER.CURUSERID;
            });
            if (amIDCOManagerLeads.length > 0 || amIAdminTeam.length > 0) {
                vm._components = ['By Admin Code', 'CMS-wide', 'Office of the Administrator (OA) Only'];
            }
        };

        // Calendar functions & configuration
        vm.changeFromOption = function () {
            vm.dateOptionTo.minDate = vm.selected.fromDate ? vm.selected.fromDate : null;
        };
        vm.changeToOption = function () {
            vm.dateOptionFrom.maxDate = vm.selected.toDate ? vm.selected.toDate : new Date();
        };
        vm.openFromDate = function ($event) {
            $event.preventDefault();
            $event.stopPropagation();
            vm.toDateOpened = false;
            vm.fromDateOpened = true;
        }
        vm.openToDate = function ($event) {
            $event.preventDefault();
            $event.stopPropagation();
            vm.toDateOpened = true;
            vm.fromDateOpened = false;
        }

        vm.getDateString = function (when) {
            var month = when.getMonth() + 1;
            month = month < 10 ? ('0' + month) : month;
            var day = when.getDate();
            day = day < 10 ? ('0' + day) : day;
            var year = when.getFullYear();
            var dateString = year + '-' + month + '-' + day;
            return dateString;
        };

        vm.getTargetReportURL = function () {

            if (vm.isSection508User == true) {
                if (vm.selected.selectingOfficial508) vm.selected.selectingOfficial = vm.selected.selectingOfficial508.memberid;
                if (vm.selected.executiveOfficer508) vm.selected.executiveOfficer = vm.selected.executiveOfficer508.memberid;
                if (vm.selected.hrLiaison508) vm.selected.hrLiaison = vm.selected.hrLiaison508.memberid;
                if (vm.selected.staffSpecialist508) vm.selected.staffSpecialist = vm.selected.staffSpecialist508.memberid;
                if (vm.selected.classSpecialist508) vm.selected.classSpecialist = vm.selected.classSpecialist508.memberid;
            }

            var url = '/bizflowadvreport/flow.html?_flowId=viewReportFlow&decorate=no';
            url = url + '&j_memberid=' + CMS_REPORT_FILTER.CURUSERID; // j_memberid
            url = url + '&j_username=' + CMS_REPORT_FILTER.CURLOGINID; // j_username
            url = url + '&reportUnit=' + CMS_REPORT_FILTER.REPORTPATH; // reportUnit
            if (vm.selected.component.length > 0) { // Component
                url = url + '&COMPONENT=' + encodeURI(vm.selected.component);
            }
            if (vm.selected.adminCode != undefined && vm.selected.adminCode.length > 0) { // Admin Code
                url = url + '&ADMIN_CD=' + vm.selected.adminCode.toUpperCase();
            } else {
                url = url + '&ADMIN_CD=~NULL~';
            }
            if (vm.selected.fromDate != null) { // COMP_DATE_FROM
                var from = vm.getDateString(vm.selected.fromDate);
                url = url + '&COMP_DATE_FROM=' + from;
            } else {
                url = url + '&COMP_DATE_FROM=2000-01-01';
            }
            if (vm.selected.toDate != null) { // COMP_DATE_TO
                var to = vm.getDateString(vm.selected.toDate);
                url = url + '&COMP_DATE_TO=' + to;
            } else {
                url = url + '&COMP_DATE_TO=2050-12-31';
            }
            url = url + '&REQ_TYPE=' + encodeURI(vm.selected.requestType); // Request Type
            url = url + '&CLSF_TYPE=' + encodeURI(vm.selected.classificationType); // Classification Type
            url = url + '&APPT_TYPE=' + encodeURI(vm.selected.appointmentType); // Appointment Type
            url = url + '&SCHDA_TYPE=' + encodeURI(vm.selected.scheduleAType); // Schedula A Type
            url = url + '&VOL_TYPE=' + encodeURI(vm.selected.volunteerType); // Volunteer Type
            url = url + '&SO_ID=' + vm.selected.selectingOfficial; // Selecting Official
            url = url + '&XO_ID=' + vm.selected.executiveOfficer; // Executive Officer
            url = url + '&HRL_ID=' + vm.selected.hrLiaison; // HR Liaison
            url = url + '&SS_ID=' + vm.selected.staffSpecialist; // Staff specialist
            url = url + '&CS_ID=' + vm.selected.classSpecialist; // Class specialist
            url = url + '&INC_SUBORG=' + vm.selected.includeSubOrg; // Include Requests for Sub-Org
            url = url + '&DAYS=' + vm.selected.dayType; // Business day or Calendar day
            url = url + '&STANDARD_PD=' + encodeURI(vm.selected.standardPD);
            url = url + '&_bf508=' + (vm.isSection508User ? 'y' : 'n');
            //$log.debug('Report URL [' + url + ']');

            return url;
        };

        vm.submit = function () {
            if (vm.selected.component !== 'By Admin Code') {
                vm.selected.adminCode = '';
                vm.selected.includeSubOrg = '';
            }
            if (vm.selected.appointmentType === 'Expert/Consultant' || vm.selected.appointmentType === 'Volunteer') {
                vm.selected.classificationType = 'All';
            }
            if (vm.selected.requestType !== 'Appointment') {
                vm.selected.appointmentType = 'All';
            }
            if (vm.selected.appointmentType !== 'Schedule A') {
                vm.selected.scheduleAType = 'All';
            }
            if (vm.selected.appointmentType !== 'Volunteer') {
                vm.selected.volunteerType = 'All';
            }
            var url = vm.getTargetReportURL();

            window.open(url, '_blank');
            setTimeout(function () { vm.close(); }, 0);
        };

        vm.reset = function () {
            vm.selected = _.assign({}, vm.orgSelected);
        };

        vm.close = function () {
            try {
                $('#modalPopupMax0CloseButton', window.parent.parent.document).click();
            } catch (e) {
                $log.info('Cancel button is clicked but failed to dismiss BizCove. ' + e);
            }
        }

        vm.initReportMap = function () {
            if (CMS_REPORT_FILTER.REPORTNAME && CMS_REPORT_FILTER.REPORTNAME.length > 0) {
                var foundReportMap = _.find(vm.reportMap, function(item) {
                    if (item.name === CMS_REPORT_FILTER.REPORTNAME) {
                        return true;
                    } else {
                        return false;
                    }
                });

                if (foundReportMap) {
                    vm.report = foundReportMap
                    if (foundReportMap.requestType && foundReportMap.requestType.length > 0) {
                        // vm._requestTypes = foundReportMap.requestType;
                        vm.copyItems(vm._requestTypes, foundReportMap.requestType);
                        if (vm._requestTypes.length == 1) {
                            vm.orgSelected.requestType = vm._requestTypes[0]
                        }
                    }
                    if (foundReportMap.appointmentType && foundReportMap.appointmentType.length > 0) {
                        // vm._appointmentTypes = foundReportMap.appointmentType;
                        vm.copyItems(vm._appointmentTypes, foundReportMap.appointmentType);
                        if (vm._appointmentTypes.length == 1) {
                            vm.orgSelected.appointmentType = vm._appointmentTypes[0]
                        }
                    }

                    if (foundReportMap.dateLabel && foundReportMap.dateLabel.length > 0) {
                        vm.dateLabel = foundReportMap.dateLabel
                    }
                } else {
                    $log.info('No report found from report map. [' + CMS_REPORT_FILTER.REPORTNAME + ']');
                }
            }
        };

        vm.checkParameter = function() {
            var message = '';
            var validParameter = true;
            var mandatoryParameters = ['CURUSERID', 'CURUSERNAME', 'CURLOGINID', 'SESSION', 'GROUPS','REPORTPATH','DESCRIPTION'];

            mandatoryParameters.forEach(function(parameter) {
                var value = CMS_REPORT_FILTER[parameter];
                if (value == null || value == '') {
                    message = message + '<li>' + 'Parameter [' + parameter + '] is mandatory, but has null or empty value.' + '</li>';
                    validParameter = false;
                }
            })

            vm.report.user = {};
            vm.report.user.memberID = CMS_REPORT_FILTER['CURUSERID'];
            vm.report.user.loginID = CMS_REPORT_FILTER['CURLOGINID'];
            vm.report.user.name = CMS_REPORT_FILTER['CURUSERNAME'];
            vm.report.user.session = CMS_REPORT_FILTER['SESSION'];

            vm.report.name = CMS_REPORT_FILTER['REPORTNAME'];
            vm.report.path = CMS_REPORT_FILTER['REPORTPATH'];
            vm.report.description = CMS_REPORT_FILTER['DESCRIPTION'];

            var groups = JSON.parse(CMS_REPORT_FILTER.GROUPS).groups;
            CMS_REPORT_FILTER.GROUPS = null;
            vm.group = _.groupBy(groups, 'grpname');            

            vm.report.element = {};
            vm.report.element.Date = {};
            vm.report.element.TypeOfStandardPD = {};

            // LABEL.DATE
            if (CMS_REPORT_FILTER.LABEL.DATE.length > 0) {
                vm.report.element.Date.label = CMS_REPORT_FILTER.LABEL.DATE;
            } else {
                vm.report.element.Date.label = 'Date Request Completed';
            }

            // SHOW.TYPE_OF_STANDARD_PD
            vm.report.element.TypeOfStandardPD.show = false; // Default
            vm.report.element.TypeOfStandardPD.hide = true;  // Default
            if (CMS_REPORT_FILTER.SHOW.TYPE_OF_STANDARD_PD && CMS_REPORT_FILTER.SHOW.TYPE_OF_STANDARD_PD.length > 0) {
                if (CMS_REPORT_FILTER.SHOW.TYPE_OF_STANDARD_PD.toUpperCase() == 'TRUE') {
                    vm.report.element.TypeOfStandardPD.show = true;
                    vm.report.element.TypeOfStandardPD.hide = false;
                }
            }

            // Request Type
            if (CMS_REPORT_FILTER.REQUESTTYPE && CMS_REPORT_FILTER.REQUESTTYPE.length > 0) {
                vm._requestTypes = JSON.parse(CMS_REPORT_FILTER.REQUESTTYPE);
                if (vm._requestTypes.length > 0) { 
                    if (vm._requestTypes.length == 1) {
                        vm.orgSelected.requestType = vm._requestTypes[0]
                    }
                } else {
                    validParameter = false;
                    message = message + '<li>' + 'Parameter [REQUESTTYPE] has empty list or invalid.' + '</li>';
                }
            }

            // Appointment Type
            if (CMS_REPORT_FILTER.APPOINTMENTTYPE && CMS_REPORT_FILTER.APPOINTMENTTYPE.length > 0) {
                vm._appointmentTypes = JSON.parse(CMS_REPORT_FILTER.APPOINTMENTTYPE);
                if (vm._appointmentTypes.length > 0) {
                    if (vm._appointmentTypes.length == 1) {
                        vm.orgSelected.appointmentType = vm._appointmentTypes[0]
                    }
                } else {
                    validParameter = false;
                    message = message + '<li>' + 'Parameter [APPOINTMENTTYPE] has empty list or invalid.' + '</li>';
                }
            }

            if (validParameter == false) {
                var errorMessage = "<h4 style='color:red'>Invalid Report Filter UI Configuration</h4><p><h5>Please check following parameter(s).</h5></p><ul>";
                errorMessage = errorMessage + message + '</ul>';
    
                bootbox.alert(errorMessage);
            }
        };

        vm.getMemberObject = function(members, memberid) {
            var foundMember = _.find(members, function(item) {
                if (item.memberid === memberid) {
                    return true;
                } else {
                    return false;
                }
            });

            return (foundMember != null && foundMember.length == 1) ? foundMember[0] : null;
        }

        vm.isValidMember = function($event, member) {
            if (typeof member == 'string') {
                return member == 'All' ? true : false;
            } else if (typeof member == 'object') {
                return parseInt(member.memberid) != NaN ? true : false;
            } else {
                return false;
            }
        }

        vm.onBlur = function(groups, item, $event) {
            console.log($event);

            if (item == null || typeof item != 'object') {
                item = groups[0];
            }
        }

        vm.getValidMember = function($event, model, groupName) {
            console.log('Model type [' + typeof model + '] - Typed [' + $($event.currentTarget).val() + ']' );
            if (typeof model == 'object' && $($event.currentTarget).val() == model.name) {
                console.log('Same');
                return model;
            } else {
                console.log('Not Object, or different name');
                return vm.group[groupName][0];
            }
        }        

        vm.errorMessages = {
            'selectComponent': {
                'required': 'Select a value from the component filter'
            },
            'requestNumberInput': {
                'required': 'Type a request number for the report'
            },
            'adminCodeInput': {
                'required': 'Type an administrative code for the report',
                'minlength': 'Enter a minimum of three characters for the administrative code'
            },
            'dateRCompletedFromInput': {
                'required': 'Type the from date in the format "MM/DD/YYYY" for the request date range',
                'date': 'Type the date in the format: MM/DD/YYYY.'
            },
            'dateRCompletedToInput': {
                'required': 'Type the end date in the format "MM/DD/YYYY" for the request date range',
                'date': 'Type the date in the format: MM/DD/YYYY.'
            },
            'dayType': {
                'required': 'Select Business or Calendar Days'
            }
        }

        vm.getErrorMessage = function(which, $error) {
            var message = '';
            if (which != undefined && which && $error != undefined && $error) {
                var names = Object.getOwnPropertyNames($error);
                var count = names.length;
                for (var index = 0; index < count; index++) {
                    if ($error.hasOwnProperty(names[index]) && $error[names[index]] == true) {
                        message = vm.errorMessages[which][names[index]];
                        break;
                    }
                }
            }
            return message;
        }

        vm.onKeyDownComponent = function($event) {
            setTimeout(function() {
                var component = $('#selectComponent option:selected').text();
                var keyCode = $event.keyCode;
    
                if (component == 'By Admin Code' && keyCode == 9) {
                    $event.preventDefault();
                    setTimeout(function() {
                        $('#adminCodeInput').focus();
                    }, 0);
                }
            }, 0);
        }
        vm.onKeyDownAppointmentType = function($event) {
            setTimeout(function() {
                var component = $('#appointmentTypeSelect option:selected').text();
                var keyCode = $event.keyCode;
    
                if (component == 'Schedule A' && keyCode == 9) {
                    $event.preventDefault();
                    setTimeout(function() {
                        $('#scheduleATypeSelect').focus();
                    }, 0);
                } else if (component == 'Volunteer' && keyCode == 9) {
                    $event.preventDefault();
                    setTimeout(function() {
                        $('#volunteerTypeSelect').focus();
                    }, 0);
                }
            }, 0);
        }

        vm.$onInit = function () {
            $log.info('reportFilter $onInit');

            vm.isSection508User = Section508.isSection508User();

            // This should be called first.
            vm.checkParameter();
            //vm.initReportMap();
            vm.initUserGroups();
            
            vm.adjustBizCoveUI();
            if (vm.isSection508User == true) {
                vm.orgSelected.selectingOfficial508 = vm.group['Selecting Officials'][0];
                vm.orgSelected.executiveOfficer508 = vm.group['Executive Officers'][0];
                vm.orgSelected.hrLiaison508 = vm.group['HR Liaison'][0];
                vm.orgSelected.staffSpecialist508 = vm.group['HR Staffing Specialists'][0];
                vm.orgSelected.classSpecialist508 = vm.group['HR Classification Specialists'][0];
            }

            vm.selected = _.assign({}, vm.orgSelected);

            vm.requestTypes = vm.getSelectizeOptions(vm._requestTypes);
            vm.appointmentTypes = vm.getSelectizeOptions(vm._appointmentTypes);
            vm.scheduleATypes = vm.getSelectizeOptions(vm._scheduleATypes);
            vm.volunteerTypes = vm.getSelectizeOptions(vm._volunteerTypes);
            vm.components = vm.getSelectizeOptions(vm._components);
            vm.includeSubOrgs = vm.getSelectizeOptions(vm._includeSubOrgs);
            vm.standardPDs = vm.getSelectizeOptions(vm._standardPDs);
            vm.dayTypes = vm.getSelectizeOptions(vm._dayTypes);

            if (vm.isSection508User == true) {
                // #selectComponent is not processed yet. So, use setTimeout.
                setTimeout(function() {
                    $('#selectComponent').on('keydown', vm.onKeyDownComponent);
                    $('#appointmentTypeSelect').on('keydown', vm.onKeyDownAppointmentType);
                }, 0);
            }

            $('#mandatorySectionHelp small').html(vm.report.description);

            setTimeout(function() {
                $('#reportFilterBody').attr('aria-busy', 'false');
                $('#reportFilterBody').removeClass('hidden');
                $('#selectComponent').focus(); 
            }, 100);
        };

        vm.$onDestroy = function () {
            $log.info('reportFilter $onDestroy');
        };
    }
})();
