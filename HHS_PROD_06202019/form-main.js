'use strict';

(function (window) {
    var USER_GROUP_KEY = {
        ADMIN_STEAM: 'Admin Team',
        DCO_MANAGERS_AND_LEADS: 'DCO Managers and Leads',
        DCO_MANAGERS_ONLY: 'DCO Managers Only',
        DWC: 'DWC',
        HR_SPECIAL_PROGRAMS: 'HR Special Programs',
        HR_STAFFING_SPECIALISTS: 'HR Staffing Specialists',
        REPORT_PILOT_TESTERS: 'Report Pilot Testers',
        STANDARD_USER_GROUP: 'Standard User Group',
        HR_CLASSIFICATION_SPECIALISTS: 'HR Classification Specialists',
        // Below are user groups Incentives use
        SELECTING_OFFICIALS: 'Selecting Officials',
        EXECUTIVE_OFFICERS: 'Executive Officers',
        HR_LIAISON: 'HR Liaison',
        //HR_SPECIALISTS: 'HR Specialists',
		HR_SPECIALISTS: 'HR Specialists Group A',
        DGHO_DIRECTORS: 'DGHO Directors',
        CHIEF_PHYSICIANS: 'Chief Physicians',
        OFM_DIRECTORS: 'OFM Directors',
        TABG_DIRECTORS: 'TABG Directors',
        OHC_DIRECTORS: 'OHC Directors',
        OFFICE_OF_THE_ADMINISTRATORS: 'Office of the Administrators',
        CENTER_OFFICE_CONSORTIUM_DIRECTORS: 'Center/Office/Consortium Directors',
		INCENTIVE_HR_SPECIALISTS: 'HR Specialists Group B' 
    };

    var PROCESS_NAME = {
        REQUEST: "Incentives Request_v1",
        PCA: "PCA Incentives",
        SAM: "SAM Incentives_v1",
        LE: "LE Incentives_v1",
        REQUEST_V2: "Incentives Request",
        PCA_V2: "PCA Incentives",
        SAM_V2: "SAM Incentives",
        LE_V2: "LE Incentives",
		PDP: "PDP Incentives"
    };

    var ACTIVITY_NAME = {
        START_NEW: 'Start New',
        COMP_REVIEW: 'Component Reviews Request',
        COMP_REVIEW_FOR_MODIFICATION: 'Component Reviews Request for Modification',
        SO_REVIEW: 'Selecting Official Reviews Request',
        COC_REVIEW: 'Center/Office/Consortium Reviews Request',
        HR_REVIEW_FOR_MODIFICATION: 'HR Specialist Reviews Request for Modification',
        HRS_REVIEW: 'HR Specialist Reviews Request',
        DGHO_REVIEW: 'TABG Division Director Reviews Request',
        CP_REVIEW: 'CP Reviews Request',
        OFM_REVIEW: 'OFM Director/Deputy Director Reviews Request',
        TABG_REVIEW: 'TABG Director/Deputy Director Reviews Request',
        OHC_REVIEW: 'OHC Director/Deputy Director Reviews Request',
        OA_REVIEW: 'OA Reviews Request',
        HRS_RECORD_CONCLUSION: 'HR Specialist Final Review of Documents',
		SO_REVIEW_FOR_MODIFICATION: 'Selecting Official Reviews Request for Modification',
		HR_REVIEW_APPROVAL: "HR Specialist Review and Approval Request"
    };

    var ATTACHMENT_CATEGORY = {
        //PCA_COVERSHEET: 'PD Coversheet/OF-8',  comment out due to change on PCA document 
		PCA_COVERSHEET: 'PCA Justification Worksheet',
        FINAL_PD_PACKAGE: 'Final Position Description Package',
        OTHER: 'Other'
    };

    var GENERATED_DOCUMENT_TYPE = {
		PCA_COVERSHEET: ATTACHMENT_CATEGORY.PCA_COVERSHEET,
		 SAM_JUSTIFICATION_WORKSHEET: 'SAM Justification Worksheet',
		 SAM_CHECKLIST: 'SAM Checklist',
		 LE_JUSTIFICATION_WORKSHEET: 'LE Justification Worksheet',
		 LE_SERVICE_AGREEMENT: 'Leave Enhancement Service Agreement',
		 PDP_HHS691: 'HHS 691',
		 PDP_JUSTIFICATION_COMPUTATION: 'PDP Justification-Computation',
		 PDP_PANEL_DOCUMENTATION: 'PDP Panel Documentation'
    };

    var NOT_DELETABLE_ATTACHMENT_CATEGORY = [
        GENERATED_DOCUMENT_TYPE.PCA_COVERSHEET,
        GENERATED_DOCUMENT_TYPE.SAM_JUSTIFICATION_WORKSHEET,
        GENERATED_DOCUMENT_TYPE.SAM_CHECKLIST,
        GENERATED_DOCUMENT_TYPE.LE_JUSTIFICATION_WORKSHEET,
        GENERATED_DOCUMENT_TYPE.LE_SERVICE_AGREEMENT,
		 GENERATED_DOCUMENT_TYPE.PDP_HHS691,
		GENERATED_DOCUMENT_TYPE.PDP_JUSTIFICATION_COMPUTATION,
		GENERATED_DOCUMENT_TYPE.PDP_PANEL_DOCUMENTATION
    ];

    var NOT_ADDABLE_ATTACHMENT_CATEGORY = [
        ATTACHMENT_CATEGORY.PCA_COVERSHEET
        // , ATTACHMENT_CATEGORY.FINAL_PD_PACKAGE
    ];

    var LAST_ENTRY_ATTACHMENT_CATEGORY = [
        ATTACHMENT_CATEGORY.OTHER
    ];

    var INCENTIVES_TYPE = {
        PCA: "PCA",
        LE: "LE",
        SAM: "SAM",
		PDP: "PDP"
    };

    var PCA_TYPE = {
        NEW: "New",
        RENEWAL: "Renewal"
    };

	var PDP_TYPE = {
        CHANGE: "Change to Existing PDP",  
        NEWHIRE: "New Hire",
		OTHER: "Other"
    };

    var REQUEST_STATUS = {
        NEW: "Start New",
        CREATED: "Request Created"
    };

    var _initializer1 = window.USER_GROUP_KEY || (window.USER_GROUP_KEY = USER_GROUP_KEY);
    var _initializer2 = window.PROCESS_NAME || (window.PROCESS_NAME = PROCESS_NAME);
    var _initializer3 = window.ACTIVITY_NAME || (window.ACTIVITY_NAME = ACTIVITY_NAME);
    var _initializer4 = window.ATTACHMENT_CATEGORY || (window.ATTACHMENT_CATEGORY = ATTACHMENT_CATEGORY);
    var _initializer5 = window.NOT_DELETABLE_ATTACHMENT_CATEGORY || (window.NOT_DELETABLE_ATTACHMENT_CATEGORY = NOT_DELETABLE_ATTACHMENT_CATEGORY);
    var _initializer6 = window.NOT_ADDABLE_ATTACHMENT_CATEGORY || (window.NOT_ADDABLE_ATTACHMENT_CATEGORY = NOT_ADDABLE_ATTACHMENT_CATEGORY);
    var _initializer7 = window.LAST_ENTRY_ATTACHMENT_CATEGORY || (window.LAST_ENTRY_ATTACHMENT_CATEGORY = LAST_ENTRY_ATTACHMENT_CATEGORY);
    var _initializer8 = window.INCENTIVES_TYPE || (window.INCENTIVES_TYPE = INCENTIVES_TYPE);
    var _initializer9 = window.PCA_TYPE || (window.PCA_TYPE = PCA_TYPE);
    var _initializer10 = window.REQUEST_STATUS || (window.REQUEST_STATUS = REQUEST_STATUS);
	 var _initializer11 = window.PDP_TYPE || (window.PDP_TYPE = PDP_TYPE);

})(window);

(function (window) {
    function MyInfo() {
        var myName = null;
        var myId = null;

        this.getMyName = function () {
            myName = myName || $("#h_currentUserName").val();
            return myName;
        };
        this.getMyMemberId = function () {
            myId = myId || $("#h_currentUserMemberID").val();
            return myId;
        };
        this.isSO = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.SELECTING_OFFICIALS);
        };
        this.isXO = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.EXECUTIVE_OFFICERS);
        };
        this.isHRL = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.HR_LIAISON);
        };
        this.isHRS = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.HR_SPECIALISTS);
        };
        this.isDGHO = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.DGHO_DIRECTORS);
        };
        this.isCP = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.CHIEF_PHYSICIANS);
        };
        this.isOFM = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.OFM_DIRECTORS);
        };
        this.isTABG = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.TABG_DIRECTORS);
        };
        this.isOHC = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.OHC_DIRECTORS);
        };
        this.isOffAdmin = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.OFFICE_OF_THE_ADMINISTRATORS);
        };
        this.isCOC = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.CENTER_OFFICE_CONSORTIUM_DIRECTORS);
        };
        this.isComponent = function () {
            return this.isHRL() || this.isXO() || this.isSO();
        }
		this.isINCENTIVEHRS = function () {
            return MyUserGroupManager.isUserMemberOf(USER_GROUP_KEY.INCENTIVE_HR_SPECIALISTS);
        }
    }

    var _initializer = window.myInfo || (window.myInfo = new MyInfo());
})(window);

(function (window) {
    function AccessControl() {
        this.isDesignator = function (name) {
            var designator = FormState.getElementSingleValue(name);
            return typeof designator !== "undefined" && designator.id === myInfo.getMyMemberId();
        };
        this.isDesignatedSO = function () {
            return this.isDesignator("selectingOfficial");
        };
        this.isDesignatedDGHO = function () {
            return this.isDesignator("dghoDirector");
        };
        this.isDesignatedCP = function () {
            return this.isDesignator("chiefPhysician");
        };
        this.isDesignatedOHC = function (name) {
            return this.isDesignator(name || "ohcDirector");
        };
        this.isDesignatedOFM = function () {
            return this.isDesignator("ofmDirector");
        };
        this.isDesignatedOffAdmin = function () {
            return this.isDesignator("offAdmin");
        };
        this.isDesignatedTABG = function () {
            return this.isDesignator("tabgDirector");
        };
        this.isDesignatedCOC = function () {
            return this.isDesignator("cocDirector");
        };
    }

    var _initializer = window.accessControl || (window.accessControl = new AccessControl());
})(window);


(function (window) {
    function ActivityStep() {
        var _activityName;

        this.setActivityName = function (activityName) {
            _activityName = activityName;
        };
        this.getActivityName = function () {
            _activityName = _activityName || ActivityManager.getActivityName();
            return _activityName;
        };
        this.isStartNew = function () {
            return this.getActivityName() === ACTIVITY_NAME.START_NEW;
        };
        this.isCOMPReview = function () {
            var processName = FormMain.getProcessInfo().process.definitionName;
            if ((processName === PROCESS_NAME.SAM_V2) || (processName === PROCESS_NAME.LE_V2)) {
                return this.getActivityName() === ACTIVITY_NAME.COMP_REVIEW;
            } else {
                if(this.getActivityName() === ACTIVITY_NAME.SO_REVIEW) {
                    return myInfo.isXO() || myInfo.isHRL();  
                }
            }
            return false;
        };
        this.isCOMPReviewForModification = function () {
            return this.getActivityName() === ACTIVITY_NAME.COMP_REVIEW_FOR_MODIFICATION;
        };
        this.isSOReview = function () {
            return this.getActivityName() === ACTIVITY_NAME.SO_REVIEW;
        };
        this.isCOCReview = function () {
            return this.getActivityName() === ACTIVITY_NAME.COC_REVIEW;
        };
        this.isHRSReviewForModification = function () {
            return this.getActivityName() === ACTIVITY_NAME.HR_REVIEW_FOR_MODIFICATION;
        };
        this.isHRSReview = function () {
            return this.getActivityName() === ACTIVITY_NAME.HRS_REVIEW;
        };
        this.isDGHOReview = function () {
            return this.getActivityName() === ACTIVITY_NAME.DGHO_REVIEW;
        };
        this.isCPReview = function () {
            return this.getActivityName() === ACTIVITY_NAME.CP_REVIEW;
        };
        this.isOFMReview = function () {
            return this.getActivityName() === ACTIVITY_NAME.OFM_REVIEW;
        };
        this.isTABGReview = function () {
            return this.getActivityName() === ACTIVITY_NAME.TABG_REVIEW;
        };
        this.isOHCReview = function () {
            return this.getActivityName() === ACTIVITY_NAME.OHC_REVIEW
        };
        this.isOAReview = function () {
            return this.getActivityName() === ACTIVITY_NAME.OA_REVIEW;
        };
        this.isHRSRecordConclusion = function () {
            return this.getActivityName() === ACTIVITY_NAME.HRS_RECORD_CONCLUSION;
        };
		this.isSOReviewForModification = function () {
            return this.getActivityName() === ACTIVITY_NAME.SO_REVIEW_FOR_MODIFICATION;
        };
		this.isHR_REVIEW_APPROVAL = function () {
            return this.getActivityName() === ACTIVITY_NAME.HR_REVIEW_APPROVAL;
        };
        this.getCurrentRoleGroup = function () {
            var role = "";

            if (this.isHRSReviewForModification() || this.isHRSReview()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.HR_SPECIALISTS);
            else if (this.isCOCReview()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.CENTER_OFFICE_CONSORTIUM_DIRECTORS);
            else if (this.isDGHOReview()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.DGHO_DIRECTORS);
            else if (this.isCPReview()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.CHIEF_PHYSICIANS);
            else if (this.isOFMReview()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.OFM_DIRECTORS);
            else if (this.isTABGReview()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.TABG_DIRECTORS);
            else if (this.isOHCReview()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.OHC_DIRECTORS);
            else if (this.isOAReview()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.OFFICE_OF_THE_ADMINISTRATORS);
            else if (this.isHRSRecordConclusion()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.HR_SPECIALISTS);
		
            else {
                if (myInfo.isHRS()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.HR_SPECIALISTS);
                else if (myInfo.isCOC()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.CENTER_OFFICE_CONSORTIUM_DIRECTORS);
                else if (myInfo.isSO()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.SELECTING_OFFICIALS);
                else if (myInfo.isXO()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.EXECUTIVE_OFFICERS);
                else if (myInfo.isHRL()) role = MyUserGroupManager.getCurrentUserGroupName(USER_GROUP_KEY.HR_LIAISON);
            }

            return role;
        }
    }

    var _initializer = window.activityStep || (window.activityStep = new ActivityStep());
})(window);

/** * Define Tabs and Activities */
(function (window) {
    var tab1 = new Tab('tab1', 'General', '/cms_incentives_form1/loadGeneralForm.do', 'partial_tab1', true, ['/cms_incentives_form1/custom/js/form1.js']);

    tab1.onInit = function (readOnly) {
        cms_incentives_general.init(readOnly, this);
    };
    tab1.renderer = function (action) {
        cms_incentives_general.render(action);
    };
    tab1.postDisableTab = function (afterAllTabLoaded, tab) {
        cms_incentives_general.postDisableTab(afterAllTabLoaded, tab);
    };

    var tab2 = new Tab('tab2', 'Position', '/cms_incentives_form2/loadPositionForm.do', 'partial_tab2', true, ['/cms_incentives_form2/custom/js/form2.js']);
    tab2.onInit = function (readOnly) {
        cms_incentives_position.init(readOnly, this);
    };
    tab2.renderer = function (action) {
        cms_incentives_position.render(action);
    };
    tab2.postDisableTab = function (afterAllTabLoaded, tab) {
        cms_incentives_position.postDisableTab(afterAllTabLoaded, tab);
    };

    var tab3 = new Tab('tab3', 'PCADetails', '/cms_incentives_form3/loadPCADetails.do', 'partial_tab3', true, ['/cms_incentives_form3/custom/js/form3.js']);
    tab3.onInit = function (readOnly) {
        cms_incentives_pca_details.init(readOnly, this);
    };
    tab3.renderer = function (action) {
        cms_incentives_pca_details.render(action);
    };

    var tab4 = new Tab('tab4', 'PCAReview', '/cms_incentives_form4/loadPCAReview.do', 'partial_tab4', true, ['/cms_incentives_form4/custom/js/form4.js']);
    tab4.onInit = function (readOnly) {
        cms_incentives_pca_review.init(readOnly, this);
    };
    tab4.renderer = function (action) {
        cms_incentives_pca_review.render(action);
    };

    var tab5 = new Tab('tab5', 'PCAApproval', '/cms_incentives_form5/loadPCAApproval.do', 'partial_tab5', true, ['/cms_incentives_form5/custom/js/form5.js']);
    tab5.onInit = function (readOnly) {
        cms_incentives_pca_approval.init(readOnly, this);
    };
    tab5.renderer = function (action) {
        cms_incentives_pca_approval.render(action);
    };

    var tab6 = new Tab('tab6', 'SAMDetails', '/cms_incentives_form6/loadSAMDetails.do', 'partial_tab6', true, ['/cms_incentives_form6/custom/js/form6.js']);
    tab6.onInit = function (readOnly) {
        cms_incentives_sam_details.init(readOnly, this);
    };
    tab6.renderer = function (action) {
        cms_incentives_sam_details.render(action);
    };
    tab6.validator = function () {
        return cms_incentives_sam_details.validateForm();
    };

    var tab9 = new Tab('tab9', 'SAMJustification', '/cms_incentives_form9/loadSAMJustification.do', 'partial_tab9', true, ['/cms_incentives_form9/custom/js/form9.js']);
    tab9.onInit = function (readOnly) {
        cms_incentives_sam_justification.init(readOnly, this);
    };
    tab9.renderer = function (action) {
        cms_incentives_sam_justification.render(action);
    };

    var tab7 = new Tab('tab7', 'SAMReview', '/cms_incentives_form7/loadSAMReview.do', 'partial_tab7', true, ['/cms_incentives_form7/custom/js/form7.js']);
    tab7.onInit = function (readOnly) {
        cms_incentives_sam_review.init(readOnly, this);
    };
    tab7.renderer = function (action) {
        cms_incentives_sam_review.render(action);
    };

    var tab8 = new Tab('tab8', 'SAMApproval', '/cms_incentives_form8/loadSAMApproval.do', 'partial_tab8', true, ['/cms_incentives_form8/custom/js/form8.js']);
    tab8.onInit = function (readOnly) {
        cms_incentives_sam_approval.init(readOnly, this);
    };
    tab8.renderer = function (action) {
        cms_incentives_sam_approval.render(action);
    };

    var tab10 = new Tab('tab10', 'LEDetails', '/cms_incentives_form10/loadLEDetails.do', 'partial_tab10', true, ['/cms_incentives_form10/custom/js/form10.js']);
    tab10.onInit = function (readOnly) {
        cms_incentives_le_details.init(readOnly, this);
    };
    tab10.renderer = function (action) {
        cms_incentives_le_details.render(action);
    };

    var tab11 = new Tab('tab11', 'LEJustification', '/cms_incentives_form11/loadLEJustification.do', 'partial_tab11', true, ['/cms_incentives_form11/custom/js/form11.js']);
    tab11.onInit = function (readOnly) {
        cms_incentives_le_justification.init(readOnly, this);
    };
    tab11.renderer = function (action) {
        cms_incentives_le_justification.render(action);
    };

    var tab12 = new Tab('tab12', 'LEReview', '/cms_incentives_form12/loadLEReview.do', 'partial_tab12', true, ['/cms_incentives_form12/custom/js/form12.js']);
    tab12.onInit = function (readOnly) {
        cms_incentives_le_review.init(readOnly, this);
    };
    tab12.renderer = function (action) {
        cms_incentives_le_review.render(action);
    };

    var tab13 = new Tab('tab13', 'LEApproval', '/cms_incentives_form13/loadLEApproval.do', 'partial_tab13', true, ['/cms_incentives_form13/custom/js/form13.js']);
    tab13.onInit = function (readOnly) {
        cms_incentives_le_approval.init(readOnly, this);
    };
    tab13.renderer = function (action) {
        cms_incentives_le_approval.render(action);
    };

	//no more tab14. moved  to tab2

	var tab15 = new Tab('tab15', 'PDPDetails', '/cms_incentives_form15/loadPDPDetails.do', 'partial_tab15', true, ['/cms_incentives_form15/custom/js/form15.js']);
    tab15.onInit = function (readOnly) {
		cms_incentives_pdp_details.init(readOnly, this);
    };
    tab15.renderer = function (action) {
	    cms_incentives_pdp_details.render(action);
	};

	var tab16 = new Tab('tab16', 'PDPPanel', '/cms_incentives_form16/loadPDPPanel.do', 'partial_tab16', true, ['/cms_incentives_form16/custom/js/form16.js']);
	tab16.onInit = function (readOnly) {
		if (typeof(cms_incentives_pdp_panel) != "undefined") {
			if (typeof(cms_incentives_pdp_panel.init) != "undefined") {
				cms_incentives_pdp_panel.init(readOnly, this);
			}
		}
    };
	tab16.renderer = function (action) {
		if (typeof(cms_incentives_pdp_panel) != "undefined") {
			if (typeof(cms_incentives_pdp_panel.render) != "undefined") {
				cms_incentives_pdp_panel.render(action);
			}
		}
    }; 

	var tab17 = new Tab('tab17', 'PDPReview', '/cms_incentives_form17/loadPDPReview.do', 'partial_tab17', true, ['/cms_incentives_form17/custom/js/form17.js']);
    tab17.onInit = function (readOnly) {
		if (typeof(cms_incentives_pdp_review) != "undefined") {
            if (typeof(cms_incentives_pdp_review.init)!= "undefined") {
                  cms_incentives_pdp_review.init(readOnly, this);
			}
		}
    };
    tab17.renderer = function (action) {
		if (typeof(cms_incentives_pdp_review) != "undefined") {
            if (typeof(cms_incentives_pdp_review.render) != "undefined") {
                cms_incentives_pdp_review.render(action);
			}
		}
    };

	var tab18 = new Tab('tab18', 'PDPApproval', '/cms_incentives_form18/loadPDPApproval.do', 'partial_tab18', true, ['/cms_incentives_form18/custom/js/form18.js']);
    tab18.onInit = function (readOnly) {
		if (typeof(cms_incentives_pdp_approval) != "undefined") {
			if (typeof(cms_incentives_pdp_approval.init) != "undefined") {
				cms_incentives_pdp_approval.init(readOnly, this);
			}
		}
    };
    tab18.renderer = function (action) {
		if (typeof(cms_incentives_pdp_approval) != "undefined") {
			if (typeof(cms_incentives_pdp_approval.render) != "undefined") {
				cms_incentives_pdp_approval.render(action);
			}
		}
    };

    var tab99 = new Tab('tab99', 'Documents', '/cms_common/showAttachment.do', 'partial_tab99');
    tab99.displayMissingRequiredFields = false;
    tab99.validator = function () {
        return 'true' === $('#h_mandatoryDocumentsValid').val();
    };

    var tab90 = new Tab('tab90', 'Notes', '/cms_common/showComment.do', 'partial_tab90');
    tab90.displayMissingRequiredFields = false;

    var tabs = [tab1, tab2, tab3, tab4, tab5, tab6, tab9, tab7, tab8, tab10, tab11, tab12, tab13, tab15,tab16,tab17, tab18, tab99, tab90];

    var MENU_TAB = {
        GENERAL: "tab1",
        POSITION: "tab2",
        PCA_DETAILS: "tab3",
        PCA_REVIEW: "tab4",
        PCA_APPROVAL: "tab5",
        SAM_DETAILS: "tab6",
        SAM_JUSTIFICATION: "tab9",
        SAM_REVIEW: "tab7",
        SAM_APPROVAL: "tab8",
        LE_DETAILS: "tab10",
        LE_JUSTIFICATION: "tab11",
        LE_REVIEW: "tab12",
        LE_APPROVAL: "tab13",
//		PCA_PDP_POSITION: "tab14",  use tab2
		PDP_DETAILS: "tab15",
		PDP_PANEL: "tab16",
		PDP_REVIEW: "tab17",
		PDP_APPROVAL: "tab18",
        DOCUMENTS: "tab99",
        NOTES: "tab90"
    };

    function getActivityReadOnlyTabIds() {
        var incentiveType = FormState.getElementValue('incentiveType', '');
        var readOnlyTabs = [];

        if (INCENTIVES_TYPE.PCA === incentiveType) {
            if (activityStep.isStartNew()) {
                readOnlyTabs = [];
            } else if (activityStep.isSOReview()) {
                readOnlyTabs = [MENU_TAB.GENERAL,MENU_TAB.POSITION];
            } else if (activityStep.isHR_REVIEW_APPROVAL()) {
                readOnlyTabs = [];
            } else if (activityStep.isSOReviewForModification()) {
                readOnlyTabs = [MENU_TAB.GENERAL,MENU_TAB.POSITION];
            } else {
                readOnlyTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION, MENU_TAB.PCA_DETAILS, MENU_TAB.DOCUMENTS];
            }
        } else if (INCENTIVES_TYPE.SAM === incentiveType) {
            if (activityStep.isStartNew()) {
                readOnlyTabs = [];
            } else if (activityStep.isCOCReview()) {
                readOnlyTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION, MENU_TAB.SAM_DETAILS, MENU_TAB.SAM_JUSTIFICATION, MENU_TAB.SAM_REVIEW];
            } else if (activityStep.isHRSReview() || activityStep.isDGHOReview()) {
                readOnlyTabs = [];
            } else if(activityStep.isCOMPReviewForModification()) {
                readOnlyTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION, MENU_TAB.SAM_REVIEW, MENU_TAB.DOCUMENTS];
            } else if (activityStep.isHRSRecordConclusion()) {
                //readOnlyTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION, MENU_TAB.SAM_DETAILS, MENU_TAB.SAM_JUSTIFICATION, MENU_TAB.SAM_REVIEW, MENU_TAB.SAM_APPROVAL, MENU_TAB.DOCUMENTS];
				readOnlyTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION, MENU_TAB.SAM_DETAILS, MENU_TAB.SAM_JUSTIFICATION, MENU_TAB.SAM_REVIEW, MENU_TAB.SAM_APPROVAL];
            } else {
                readOnlyTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION, MENU_TAB.DOCUMENTS];
            }

            if (activityStep.isTABGReview() || activityStep.isOHCReview()) {
                readOnlyTabs.push(MENU_TAB.DOCUMENTS);
            }
        } else if (INCENTIVES_TYPE.LE === incentiveType) {
            if (activityStep.isStartNew()) {
                readOnlyTabs = [];
            } else if (activityStep.isCOCReview()) {
                readOnlyTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION, MENU_TAB.LE_DETAILS, MENU_TAB.LE_JUSTIFICATION, MENU_TAB.LE_REVIEW, MENU_TAB.DOCUMENTS];
            } else if (activityStep.isHRSReview() || activityStep.isDGHOReview()) {
                readOnlyTabs = [];
            } else if (activityStep.isHRSRecordConclusion()) {
                readOnlyTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION, MENU_TAB.LE_DETAILS, MENU_TAB.LE_JUSTIFICATION, MENU_TAB.LE_REVIEW, MENU_TAB.LE_APPROVAL];
            } else {
                readOnlyTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION, MENU_TAB.DOCUMENTS];
            }

            if (activityStep.isTABGReview() || activityStep.isOHCReview()) {
                readOnlyTabs.push(MENU_TAB.DOCUMENTS);
            }

            if (!activityStep.isSOReview() && !activityStep.isCOMPReview() && !activityStep.isHRSReview() && !activityStep.isCOMPReviewForModification()) {
                readOnlyTabs.push(MENU_TAB.LE_JUSTIFICATION);
            }
        }  else if (INCENTIVES_TYPE.PDP === incentiveType) {
			if (activityStep.isStartNew()) {
				readOnlyTabs = [];
			} else if (activityStep.isSOReview()) {
                readOnlyTabs = [MENU_TAB.GENERAL,MENU_TAB.POSITION];
            } else if (activityStep.isHR_REVIEW_APPROVAL()) {
                readOnlyTabs = [];
            } else if (activityStep.isSOReviewForModification()) {
                readOnlyTabs = [MENU_TAB.GENERAL,MENU_TAB.POSITION];
            } else {
                readOnlyTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION, MENU_TAB.PDP_DETAILS, MENU_TAB.PDP_PANEL, MENU_TAB.DOCUMENTS];
            }
        } 

        return readOnlyTabs;
    }

    var allTabs = [MENU_TAB.GENERAL, MENU_TAB.POSITION
        , MENU_TAB.PCA_DETAILS, MENU_TAB.PCA_REVIEW, MENU_TAB.PCA_APPROVAL
        , MENU_TAB.SAM_DETAILS, MENU_TAB.SAM_JUSTIFICATION, MENU_TAB.SAM_REVIEW, MENU_TAB.SAM_APPROVAL
        , MENU_TAB.LE_DETAILS, MENU_TAB.LE_JUSTIFICATION, MENU_TAB.LE_REVIEW, MENU_TAB.LE_APPROVAL
		, MENU_TAB.PDP_DETAILS, MENU_TAB.PDP_PANEL, MENU_TAB.PDP_REVIEW,MENU_TAB.PDP_APPROVAL
        , MENU_TAB.DOCUMENTS, MENU_TAB.NOTES];

    /** * Define Activities */
    var activity1 = new Activity(ACTIVITY_NAME.START_NEW, allTabs, [MENU_TAB.DOCUMENTS], getActivityReadOnlyTabIds);
    var activity13 = new Activity(ACTIVITY_NAME.COMP_REVIEW, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity14 = new Activity(ACTIVITY_NAME.COMP_REVIEW_FOR_MODIFICATION, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity2 = new Activity(ACTIVITY_NAME.SO_REVIEW, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity12 = new Activity(ACTIVITY_NAME.COC_REVIEW, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity3 = new Activity(ACTIVITY_NAME.HRS_REVIEW, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity4 = new Activity(ACTIVITY_NAME.DGHO_REVIEW, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity5 = new Activity(ACTIVITY_NAME.CP_REVIEW, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity6 = new Activity(ACTIVITY_NAME.OFM_REVIEW, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity7 = new Activity(ACTIVITY_NAME.TABG_REVIEW, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity8 = new Activity(ACTIVITY_NAME.OHC_REVIEW, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity9 = new Activity(ACTIVITY_NAME.OA_REVIEW, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity10 = new Activity(ACTIVITY_NAME.HRS_RECORD_CONCLUSION, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activity11 = new Activity(ACTIVITY_NAME.HR_REVIEW_FOR_MODIFICATION, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], [MENU_TAB.PCA_REVIEW, MENU_TAB.PCA_APPROVAL]);
	var activity15 = new Activity(ACTIVITY_NAME.HR_REVIEW_APPROVAL, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
	var activity16 = new Activity(ACTIVITY_NAME.SO_REVIEW_FOR_MODIFICATION, allTabs, [MENU_TAB.DOCUMENTS, MENU_TAB.NOTES], getActivityReadOnlyTabIds);
    var activities = [activity1, activity13, activity14, activity2, activity12, activity3, activity4, activity5, activity6, activity7, activity8, activity9, activity10, activity11,activity15,activity16];

    /** * Creating activityTabDefinition and initialize */
    var _initializer1 = window.MENU_TAB || (window.MENU_TAB = MENU_TAB);
    var activityTabDefinition = window.activityTabDefinition || (window.activityTabDefinition = new ActivityTabDefinition(tabs, activities));
    FormLog.setLogLevel(FormLog.LOG_LEVEL.INFO);
    FormRequire.loadScripts(activityTabDefinition.tabs);
})(window);

(function (window) {
    /** * Form Main Object. This is main object that starts a form. */
    var FormMain = function () {
        var _processInfo;

        function formRenderer() {
        }

        function updateIncentiveTypeOutput(incentiveType) {
            $('#output_incentiveType').text(incentiveType);
        }

        function updateStatusBar(requestNumber, requestDate, incentiveType, requestStatus) {
            $('#output_requestNumber').text(requestNumber);
            $('#output_requestDate').text(requestDate);
            $('#output_requestStatus').text(requestStatus);
            updateIncentiveTypeOutput(incentiveType);
        }

        function initStatusBar() {
            var requestNumber = FormState.getElementValue('requestNumber');
            var requestDate = FormUtility.getLocalDateString(FormState.getElementValue('requestDate'), 'mm/dd/yyyy');
            var incentiveType = FormState.getElementValue('incentiveType');
            var requestStatus = FormUtility.getInputElementValue('pv_requestStatus');
            updateStatusBar(requestNumber, requestDate, incentiveType, requestStatus);
        }

        function setRequesterRole() {
            var role = "";

            if (myInfo.isSO()) role = "SO";
            else if (myInfo.isXO()) role = "XO";
            else if (myInfo.isHRL()) role = "HRL";
            else if (myInfo.isCOC()) role = "COC";
            else if (myInfo.isHRS()) role = "HRS";
            else if (myInfo.isDGHO()) role = "TABG Division";
            else if (myInfo.isCP()) role = "CP";
            else if (myInfo.isOFM()) role = "OFM";
            else if (myInfo.isTABG()) role = "TABG";
            else if (myInfo.isOHC()) role = "OHC";
            else if (myInfo.isOffAdmin()) role = "OA";
			else if (myInfo.isINCENTIVEHRS()) role = "INCENTIVEHRS";

            FormState.updateObjectValue("requesterRole", role);
            return role;
        }

        function setSubmitButtonLabel(opt) {
            opt = opt || {};
            var processName = getProcessInfo().process.definitionName;
            var button = document.getElementById("button_SubmitWorkitem");
            var incentiveType = undefined !== opt.incentiveType ? opt.incentiveType : FormState.getElementValue('incentiveType');
            var label = "Submit";
            var requesterRole;

            hyf.util.hideComponent('button_CancelWorkitem');
            hyf.util.showComponent('button_SaveWorkitem');
            hyf.util.hideComponent('button_SendTo1');
            hyf.util.hideComponent('button_SendTo2');

            if (activityStep.isStartNew()) {
                requesterRole = setRequesterRole();
            }

            if (INCENTIVES_TYPE.PCA === incentiveType) {
                label = "Send to HR";
                if (activityStep.isStartNew()) {
                    hyf.util.showComponent('button_CancelWorkitem');
                    var pcaType = undefined !== opt.pcaType ? opt.pcaType : FormState.getElementValue('pcaType');
                    if (PCA_TYPE.RENEWAL === pcaType) {
                        var candiAgreeRenewal = undefined !== opt.candiAgreeRenewal ? opt.candiAgreeRenewal : FormState.getElementValue('candiAgreeRenewal');
						if ("No" === candiAgreeRenewal) { 
							if(requesterRole == "HRS") {
								 label = "Send to Offer";
							}
						}
						else { // ("Yes" === candiAgreeRenewal || "" === candiAgreeRenewal ) { 
							if(requesterRole !== "SO") {
								 label = "Send to Selecting Official";
							}
                        }
                    } else {
						if(requesterRole  !== "SO") {
								 label = "Send to Selecting Official";
						}
                    }
                }
				else if (activityStep.isHR_REVIEW_APPROVAL()) {
					hyf.util.showComponent('button_CancelWorkitem');					
					label = "Send to Offer";
                }
			} else if (INCENTIVES_TYPE.PDP === incentiveType) {
                label = "Send to HR";
                if (activityStep.isStartNew()) {
                    hyf.util.showComponent('button_CancelWorkitem');
                    if(requesterRole !== "SO") {
						label = "Send to Selecting Official";
					}
                } 
				else if (activityStep.isHR_REVIEW_APPROVAL()) {
					hyf.util.showComponent('button_CancelWorkitem');					
					label = "Send to Offer";
                }
            } else if (INCENTIVES_TYPE.SAM === incentiveType) {
                var approvalCOCValue = FormState.getElementValue("approvalCOCValue", "");
                var approvalCOCCheck = FormState.getElementValue("approvalCOCCheck", "");
                // var approvalCOCActing = FormState.getElementValue("approvalCOCActing", "");
                // var approvalChecked = ("true" == approvalCOCCheck) && ("" != approvalCOCActing) && (("Approve" == approvalCOCValue) || ("Disapprove" == approvalCOCValue));
                var approvalChecked = ("true" == approvalCOCCheck) && (("Approve" == approvalCOCValue) || ("Disapprove" == approvalCOCValue));
			
                FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Move forward the incentives action to the next activity");
                label = "Send to HR";
                if (activityStep.isStartNew()) {
                    hyf.util.showComponent('button_CancelWorkitem');
                    label = "Send to Component";
                } else if (activityStep.isCOMPReview()) {
                    label = "Send to Selecting Official";
                    FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click the button to send to the request to the Selecting Official");
                } else if (activityStep.isCOMPReviewForModification()) {
                   
				    label = "Send to HR";
                    $("#button_SendTo1").attr({
                        "value": "Send to Selecting Official",
                        "title": "Click to send the request to the Selecting Official for re-approval",
                        "responseName" : "SendBackToSO"
                    });
                    hyf.util.showComponent('button_SendTo1');
					hyf.util.hideComponent('button_SubmitWorkitem');
				
					/*
                    $("#button_SendTo2").attr({
                        "value": "Send to Center/Office",
                        "title": "Click to send to the Center/Office/Consortium Director",
                        "responseName" : "SendBackToCOC"
                    });
                    hyf.util.showComponent('button_SendTo2');
                    if (approvalChecked) {
                        hyf.util.setComponentUsability('button_SendTo2', false);
                        hyf.util.setComponentUsability('button_SubmitWorkitem', true);
                    } else {
                        var approvalSOValue = FormState.getElementValue("approvalSOValue", "");
                        var approvalSOActing = FormState.getElementValue("approvalSOActing", "");
                        var cocDirector = FormState.getElementValue('cocDirector', '');
                        if((approvalSOValue != "") && (approvalSOActing != "") && (cocDirector != "")) {
                            var supportSAM = FormState.getElementValue("supportSAM");
                            if (("undefined" != typeof(supportSAM)) && ("Yes" == supportSAM)) {
                                hyf.util.setComponentUsability('button_SendTo2', true);
                            } else if ("No" == supportLE) {
                                hyf.util.setComponentUsability('button_SendTo2', false);
                            }
                        } else {
                            hyf.util.setComponentUsability('button_SendTo2', false);
                        }

                        hyf.util.setComponentUsability('button_SubmitWorkitem', false);
                    }
					*/
                    FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click to send to the HR Specialist");
					
                } else if (activityStep.isSOReview()) {
                    if (processName === PROCESS_NAME.SAM_V2) {
                        var supportSAM = FormState.getElementValue("supportSAM");
                        if ("undefined" != typeof(supportSAM)) {
                            if ("Yes" == supportSAM) {
                                label = "Send to Center/Office";
                                FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click to send to the Center/Office/Consortium Director");

                                $("#button_SendTo1").attr({
                                    "value": "Send to HR",
                                    "title": "Click the button to send to the HR Specialist",
                                    "responseName" : "SendToHR"
                                });
                                hyf.util.showComponent('button_SendTo1');

                                if (approvalChecked) {
                                    hyf.util.setComponentUsability('button_SendTo1', true); // Send to HR
                                    hyf.util.setComponentUsability('button_SubmitWorkitem', false); // Send to Center/Office
                                } else {
                                    hyf.util.setComponentUsability('button_SendTo1', false); // Send to HR
                                    hyf.util.setComponentUsability('button_SubmitWorkitem', true); // Send to Center/Office
                                }
                            } else if ("No" == supportSAM) {
                                // Go to HR Specialist Records Candidate Acceptance or Rejection
                                label = "Send to HR";
                                FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click to send to the HR Specialist");
                                hyf.util.hideComponent('button_SendTo1');
                            }
                        }
                    }
                } else if (activityStep.isCOCReview()) {
                    label = "Send to HR";
                    FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click the button to send to the HR Specialist");
                    if (approvalChecked) {
                        hyf.util.setComponentUsability('button_SubmitWorkitem', true);
                    } else {
                        hyf.util.setComponentUsability('button_SubmitWorkitem', false);
                    }

                    FormUtility.setElementAttribute("button_SaveWorkitem", "title", "Click to save the request information");
                } else if (activityStep.isHRSReviewForModification()) {
                    hyf.util.setComponentVisibility('button_CancelWorkitem', myInfo.isHRS());
                    label = "Send to Component";
                } else if (activityStep.isHRSReview()) {
                    hyf.util.showComponent('button_CancelWorkitem');
                    var returnFrom = FormUtility.getInputElementValue("pv_returnFrom", '');
                    if (returnFrom === "" || returnFrom === "null" || returnFrom === "TABG Div") {
                        returnFrom = "Division Approver";
                    } else if (returnFrom === "SO") {
                        returnFrom = "Selecting Official";
                    }

                    label = "Send to " + returnFrom;
                } else if (activityStep.isDGHOReview()) {
                    label = "Send to TABG";
                } else if (activityStep.isTABGReview()) {
                    var requireOHCApproval = undefined !== opt.requireOHCApproval ? opt.requireOHCApproval : FormState.getElementValue('requireOHCApproval');
                    if ("Yes" === requireOHCApproval) {
                        label = "Send to OHC";
                        FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click to send to OHC");
                    }
                } else if (activityStep.isHRSRecordConclusion()) {
                    hyf.util.showComponent('button_CancelWorkitem');
                    hyf.util.hideComponent('button_SaveWorkitem');
                    label = "Send to Offer";
                }
            } else if (INCENTIVES_TYPE.LE === incentiveType) {
                var approvalCOCValue = FormState.getElementValue("leApprovalCOCValue", "");
                var approvalCOCCheck = FormState.getElementValue("leApprovalCOCCheck", "");
                // var approvalCOCActing = FormState.getElementValue("leApprovalCOCActing", "");
                // var approvalChecked = ("true" == approvalCOCCheck) && ("" != approvalCOCActing) && (("Approve" == approvalCOCValue) || ("Disapprove" == approvalCOCValue));
                var approvalChecked = ("true" == approvalCOCCheck) && (("Approve" == approvalCOCValue) || ("Disapprove" == approvalCOCValue));
                label = "Send to HR";
                if (activityStep.isStartNew()) {
                    hyf.util.setComponentVisibility('button_CancelWorkitem', myInfo.isHRS());
                    label = "Send to Component";
                } else if (activityStep.isCOMPReview()) {
                    label = "Send to Selecting Official";
                    FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click the button to send to the request to the Selecting Official");
                } else if (activityStep.isCOMPReviewForModification()) {
					label = "Send to HR";
                    $("#button_SendTo1").attr({
                        "value": "Send to Selecting Official",
                        "title": "Click to send the request to the Selecting Official for re-approval",
                        "responseName" : "SendBackToSO"
                    });
                    hyf.util.showComponent('button_SendTo1');
					hyf.util.hideComponent('button_SubmitWorkitem');
					/*
                    $("#button_SendTo2").attr({
                        "value": "Send to Center/Office",
                        "title": "Click to send to the Center/Office/Consortium Director",
                        "responseName" : "SendBackToCOC"
                    });
                    hyf.util.showComponent('button_SendTo2');
					
                    if (approvalChecked) {
                        hyf.util.setComponentUsability('button_SendTo2', false);
                        hyf.util.setComponentUsability('button_SubmitWorkitem', true);
                    } else {
                        var leapprovalSOValue = FormState.getElementValue("leApprovalSOValue", "");
                        var leapprovalSOActing = FormState.getElementValue("leApprovalSOActing", "");
                        var lecocDirector = FormState.getElementValue('lecocDirector', '');

                        if((leapprovalSOValue != "") && (leapprovalSOActing != "") && (lecocDirector != "")) {
                            var supportLE = FormState.getElementValue("supportLE");
                            if (("undefined" != typeof(supportLE)) && ("Yes" == supportLE)) {
                                hyf.util.setComponentUsability('button_SendTo2', true);
                            } else if ("No" == supportLE) {
                                hyf.util.setComponentUsability('button_SendTo2', false);
                            }
                        } else {
                            hyf.util.setComponentUsability('button_SendTo2', false);
                        }
                        hyf.util.setComponentUsability('button_SubmitWorkitem', false);

                    }
					*/
                    FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click to send to the HR Specialist");
					
					
                } else if (activityStep.isSOReview()) {
                    if (processName === PROCESS_NAME.LE_V2) {
                        var supportLE = FormState.getElementValue("supportLE");
                        if ("undefined" != typeof(supportLE)) {
                            if ("Yes" == supportLE) {
                                label = "Send to Center/Office";
                                FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click to send to the Center/Office/Consortium Director");

                                $("#button_SendTo1").attr({
                                    "value": "Send to HR",
                                    "title": "Click the button to send to the HR Specialist",
                                    "responseName": "SendToHR"
                                });
                                hyf.util.showComponent('button_SendTo1');

                                if (approvalChecked) {
                                    hyf.util.setComponentUsability('button_SendTo1', true); // Send to HR
                                    hyf.util.setComponentUsability('button_SubmitWorkitem', false); // Send to Center/Office
                                } else {
                                    hyf.util.setComponentUsability('button_SendTo1', false); // Send to HR
                                    hyf.util.setComponentUsability('button_SubmitWorkitem', true); // Send to Center/Office
                                }
                            } else if ("No" == supportLE) {
                                // Go to HR Specialist Records Candidate Acceptance or Rejection
                                label = "Send to HR";
                                FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click to send to the HR Specialist");
                                hyf.util.hideComponent('button_SendTo1');
                            }
                        }
                    }
                } else if (activityStep.isCOCReview()) {
                    label = "Send to HR";
                    FormUtility.setElementAttribute("button_SubmitWorkitem", "title", "Click the button to send to the HR Specialist");
                    if (approvalChecked) {
                        hyf.util.setComponentUsability('button_SubmitWorkitem', true);
                    } else {
                        hyf.util.setComponentUsability('button_SubmitWorkitem', false);
                    }

                    FormUtility.setElementAttribute("button_SaveWorkitem", "title", "Click to save the request information");
                } else if (activityStep.isHRSReviewForModification()) {
                    hyf.util.setComponentVisibility('button_CancelWorkitem', myInfo.isHRS());
                    label = "Send to Component";
                } else if (activityStep.isHRSReview()) {
                    hyf.util.showComponent('button_CancelWorkitem');
                    var returnFrom = FormUtility.getInputElementValue("pv_returnFrom", '');
                    if (returnFrom === "" || returnFrom === "null" || returnFrom === "TABG Div") {
                        returnFrom = "Division Approver";
                    } else if (returnFrom === "SO") {
                        returnFrom = "Selecting Official";
                    }

                    label = "Send to " + returnFrom;
                } else if (activityStep.isDGHOReview()) {
                    label = "Send to TABG";
                } else if (activityStep.isTABGReview()) {
                } else if (activityStep.isHRSRecordConclusion()) {
                    hyf.util.showComponent('button_CancelWorkitem');
                    hyf.util.hideComponent('button_SaveWorkitem');
                    label = "Send to Offer";
                }

            }
            button.value = label;
        }

        function setTabVisibility(incentiveType, candiAgreeRenewal, callResetTabs) {
            var processName = getProcessInfo().process.definitionName;
			var pca = INCENTIVES_TYPE.PCA === incentiveType;
            var sam = INCENTIVES_TYPE.SAM === incentiveType;
            var le = INCENTIVES_TYPE.LE === incentiveType;
            var agree = "No" !== candiAgreeRenewal;
			var pdp = INCENTIVES_TYPE.PDP === incentiveType;
			
            var documentTab = !(sam && (activityStep.isStartNew() || activityStep.isHRSReviewForModification() || activityStep.isSOReview()));
            if(sam && (activityStep.isCOMPReview() || activityStep.isCOMPReviewForModification() || activityStep.isCOCReview())) {
                documentTab = false;
            }
            var startNew = activityStep.isStartNew();

            TabManager.setTabHeaderVisibility(MENU_TAB.NOTES, !startNew);
            TabManager.setTabHeaderVisibility(MENU_TAB.POSITION, agree);
            TabManager.setTabHeaderVisibility(MENU_TAB.PCA_DETAILS, pca && agree);
            TabManager.setTabHeaderVisibility(MENU_TAB.PCA_REVIEW, pca && agree);
            //TabManager.setTabHeaderVisibility(MENU_TAB.PCA_APPROVAL, pca && agree);
			TabManager.setTabHeaderVisibility(MENU_TAB.PCA_APPROVAL, pca && !(startNew || activityStep.isSOReview() || activityStep.isSOReviewForModification()) && agree);
            TabManager.setTabHeaderVisibility(MENU_TAB.SAM_DETAILS, sam);
            TabManager.setTabHeaderVisibility(MENU_TAB.SAM_JUSTIFICATION, sam && !(startNew || activityStep.isHRSReviewForModification()));
            TabManager.setTabHeaderVisibility(MENU_TAB.SAM_REVIEW, sam);
            TabManager.setTabHeaderVisibility(MENU_TAB.SAM_APPROVAL, sam && !(startNew || activityStep.isHRSReviewForModification() || activityStep.isCOMPReview() || activityStep.isCOMPReviewForModification()));
            TabManager.setTabHeaderVisibility(MENU_TAB.LE_DETAILS, le);
            TabManager.setTabHeaderVisibility(MENU_TAB.LE_JUSTIFICATION, le && !(startNew || activityStep.isHRSReviewForModification()));
			TabManager.setTabHeaderVisibility(MENU_TAB.LE_REVIEW, le);
			TabManager.setTabHeaderVisibility(MENU_TAB.PDP_DETAILS, pdp);
			//hide Panel tab when process is "Incentive Request"
			TabManager.setTabHeaderVisibility(MENU_TAB.PDP_PANEL, pdp && processName != PROCESS_NAME.REQUEST_V2 && processName != PROCESS_NAME.REQUEST && !activityStep.isSOReview());
			var pdpReviewTabVisible = pdp;
            //hide PDP Review tab when user is HRS, HRL or XO; in the first activity
            if (pdpReviewTabVisible) {
                if (activityStep.isStartNew() && (myInfo.isHRS() || myInfo.isINCENTIVEHRS() || myInfo.isHRL() || myInfo.isXO())) {
                    pdpReviewTabVisible = false;
                }
            }
            TabManager.setTabHeaderVisibility(MENU_TAB.PDP_REVIEW, pdpReviewTabVisible);

			TabManager.setTabHeaderVisibility(MENU_TAB.PDP_APPROVAL, pdp && activityStep.isHR_REVIEW_APPROVAL());

            var leApprovalTabVisible = le && !(startNew || activityStep.isHRSReviewForModification() || activityStep.isCOMPReview());
            if(leApprovalTabVisible) {
                if(myInfo.isXO() || myInfo.isHRL()) {
                    leApprovalTabVisible = false;
                }
            }
            TabManager.setTabHeaderVisibility(MENU_TAB.LE_APPROVAL, leApprovalTabVisible);
            TabManager.setTabHeaderVisibility(MENU_TAB.DOCUMENTS, documentTab);
            if ("undefined" == typeof(callResetTabs)) {
                callResetTabs = true;
            }
            if(callResetTabs) {
                TabManager.resetTabs();
            }
        }

        function setButtonVisibility() {
            var incentiveType = FormState.getElementValue('incentiveType');
			var candiAgreeRenewal = FormState.getElementValue("candiAgreeRenewal");
		
            var show = activityStep.isDGHOReview()
                || activityStep.isCPReview()
                || activityStep.isOFMReview()
                || activityStep.isTABGReview()
                || activityStep.isOHCReview()
                || activityStep.isOAReview()
                || activityStep.isCOCReview()
                //|| ((incentiveType === INCENTIVES_TYPE.LE || incentiveType === INCENTIVES_TYPE.SAM) && (activityStep.isSOReview() || activityStep.isHRSReview()  || activityStep.isCOMPReview() || activityStep.isCOMPReviewForModification()))
				|| ((incentiveType === INCENTIVES_TYPE.LE || incentiveType === INCENTIVES_TYPE.SAM) && (activityStep.isHRSReview()))
				|| (incentiveType === INCENTIVES_TYPE.PCA || incentiveType === INCENTIVES_TYPE.PDP) &&  (activityStep.isHR_REVIEW_APPROVAL() && candiAgreeRenewal!="No");

            var responseName = "ReturnForModification";
            var buttonTitle = "Click to return the request for modifications";
			var label = "Return for Modification";

            var processName = getProcessInfo().process.definitionName;
            if((processName === PROCESS_NAME.SAM) || (processName === PROCESS_NAME.LE)) {
                responseName = "ReturnToHR";
            } else if((processName === PROCESS_NAME.SAM_V2) || (processName === PROCESS_NAME.LE_V2)) {
                responseName = "ReturnForModification";
            }
            if (incentiveType === INCENTIVES_TYPE.PCA ) {
                responseName = "ReturnForModification";
            } else if (incentiveType === INCENTIVES_TYPE.PDP ) {
				responseName = "ReturnForModification";
            } else if (incentiveType === INCENTIVES_TYPE.LE ) {
                if (activityStep.isCOMPReviewForModification()) {
                    buttonTitle = "Click to return the request for modifications";
                } else if (activityStep.isDGHOReview() || activityStep.isTABGReview() || activityStep.isOHCReview()) {
                    responseName = "ReturnToHR";
                    buttonTitle = "Click the button to return the request to the HR Specialist";
                } else if (activityStep.isSOReview()) {
                    buttonTitle = "Click the button to return the request to the HR Specialist";
                } else if (activityStep.isCOCReview()) {
					label = "Modify Justification";
                    buttonTitle = "Click the button to return the request to the Component";
                } else if (activityStep.isHRSReview()) {
					label = "Modify Justification";
                    buttonTitle = "Click the button to return the request to the Component";
                }
            } else if (incentiveType === INCENTIVES_TYPE.SAM ) {
                if (activityStep.isCOMPReviewForModification()) {
                    buttonTitle = "Click to return the request for modifications";
                } else if (activityStep.isDGHOReview() || activityStep.isTABGReview() || activityStep.isOHCReview()) {
                    responseName = "ReturnToHR";
                    buttonTitle = "Click the button to return the request to the HR Specialist";
                } else if (activityStep.isSOReview()) {
                    buttonTitle = "Click the button to return the request to the HR Specialist";
                } else if (activityStep.isCOCReview()) {
					label = "Modify Justification";
                    buttonTitle = "Click the button to return the request to the Component";
                } else if (activityStep.isHRSReview()) {
					label = "Modify Justification";
                    buttonTitle = "Click the button to return the request to the Component";
                }
            }
			
            $("#button_ReturnForModification").attr({
				"value": label,
                "title": buttonTitle,
                "responseName" : responseName
            });

            hyf.util.setComponentVisibility('button_ReturnForModification', show);
        }

        function showReturnReason() {
            var returnFrom = FormUtility.getInputElementValue("pv_returnFrom", '');
            var returnReason = FormState.getElementValue("returnReason");
            var returnedBy = FormState.getElementValue("returnedBy");
            if(returnFrom == "null") {
                returnFrom = "";
            }
            if ('' !== returnFrom && returnReason && returnedBy) {
                var incentiveType = FormState.getElementValue('incentiveType');
				if(incentiveType == "PCA" || incentiveType == "PDP") { 
					if (activityStep.isSOReviewForModification()) {
						bootbox.dialog({
							title: 'Requested Changes by ' + returnedBy,
							message: '<textarea disabled rows="5" class="bootbox-input bootbox-input-text form-control">' + returnReason + '</textarea>',
							onEscape: true,
							buttons: {
								confirm: {
									label: 'Close',
									className: 'btn-success'
								}
							}
						});
					}
				}
				else {
					if (activityStep.isHRSReviewForModification() || activityStep.isHRSReview() || activityStep.isCOMPReviewForModification()) {
						bootbox.dialog({
							title: 'Requested Changes by ' + returnedBy,
							message: '<textarea disabled rows="5" class="bootbox-input bootbox-input-text form-control">' + returnReason + '</textarea>',
							onEscape: true,
							buttons: {
								confirm: {
									label: 'Close',
									className: 'btn-success'
								}
							}
						});
					}
				}
            }
        }

        function initForm() {
            initStatusBar();
            setSubmitButtonLabel();
            setButtonVisibility();
        }

        function updateStatusValues(associatedNEILRequest) {
            var requestNumber = FormState.getElementValue('requestNumber');
			var incentiveType = FormState.getElementValue('incentiveType');
			var existingRequest = FormState.getElementValue('associatedRequest');
            associatedNEILRequest = associatedNEILRequest || FormState.getElementSingleValue("associatedNEILRequest", {requestNumber: ''});
			if ((INCENTIVES_TYPE.PCA === incentiveType || INCENTIVES_TYPE.PDP === incentiveType) && existingRequest == 'No' && requestNumber !='') {
				FormState.updateObjectValue('requestNumber', requestNumber);
				FormState.updateObjectValue('requestDate', FormUtility.getNowUTCString());
			}
			else {
				 if (requestNumber !== associatedNEILRequest.requestNumber) {
					FormState.updateObjectValue('requestNumber', associatedNEILRequest.requestNumber);
					FormState.updateObjectValue('requestDate', associatedNEILRequest.requestNumber ? FormUtility.getNowUTCString() : '');
				}
			}
			FormState.updateObjectValue('requestStatus', FormState.getElementValue('pv_requestStatus'));
			initStatusBar();
        }

        function onSaveFormData() {
            if (FormUtility.isReadOnly() === false) {
				var incentiveType = FormState.getElementValue('incentiveType');
				var existingRequest = FormState.getElementValue('associatedRequest');
				var requestNumber = FormState.getElementValue('requestNumber');
				var requestGenerated = FormState.getElementValue('requestGenerated');
				if ((INCENTIVES_TYPE.PCA === incentiveType || INCENTIVES_TYPE.PDP === incentiveType) && (requestNumber == null || requestNumber.length == 0) &&  existingRequest == 'No' && (requestGenerated =='No' || requestGenerated == undefined)) {	
					if(INCENTIVES_TYPE.PCA === incentiveType && hyf.validation.validateField('candiAgreeRenewal') && hyf.validation.validateField('pdpRequestType') 
						&&	 hyf.validation.validateField('candiLastName') && hyf.validation.validateField('candiFirstName') && hyf.validation.validateField('administrativeCode_ac') 
						&& hyf.validation.validateField('organizationName_ac') && hyf.validation.validateField('selectingOfficial_ac') && hyf.validation.validateField('executiveOfficer_ac') 
						&& hyf.validation.validateField('staffingSpecialist_ac')) {
						getRequestNumber();
						alert("A NEIL Request Number has been generated for this request. To enter an existing NEIL Request Number, cancel this request and create a new request with that information");
						if (cms_incentives_general) cms_incentives_general.setRequestGenerated("PCA");
					}
					if(INCENTIVES_TYPE.PDP === incentiveType && hyf.validation.validateField('pdpType') && hyf.validation.validateField('pdpRequestType')  
						&& hyf.validation.validateField('pdpTypeOther')  && hyf.validation.validateField('vacancyNumber') 
						&&	 hyf.validation.validateField('candiLastName') && hyf.validation.validateField('candiFirstName') && hyf.validation.validateField('administrativeCode_ac') 
						&& hyf.validation.validateField('organizationName_ac') && hyf.validation.validateField('selectingOfficial_ac') && hyf.validation.validateField('executiveOfficer_ac') 
						&& hyf.validation.validateField('staffingSpecialist_ac')) {
						getRequestNumber();
						alert("A NEIL Request Number has been generated for this request. To enter an existing NEIL Request Number, cancel this request and create a new request with that information");					
						if (cms_incentives_general) cms_incentives_general.setRequestGenerated();
					}
				}
				updateStatusValues();
            }
        }
		function getRequestNumber() {
			var url = '/bizflowwebmaker/cms_incentives_service/getRequestNumberPDPPCA.do';
			$.ajax({
				url: url,
				dataType: "xml",
				async: false,
				cache: false,
				success: function (xmlResponse) {
					var data = $('record', xmlResponse ).map(function() {
					FormState.updateObjectValue('requestNumber', $( 'RC_REQUEST_NUM', this ).text());
					FormState.updateObjectValue('requestGenerated', 'Yes');
					}).get();
				}
			});
		}

        function getProcessInfo() {
            if (_processInfo) return _processInfo;
            else {
                return {
                    user: {
                        id: FormUtility.getInputElementValue('h_currentUserMemberID'),
                        name: FormUtility.getInputElementValue('h_currentUserName')
                    },
                    process: {
                        id: FormUtility.getInputElementValue('h_procid'),
                        definitionName: FormUtility.getInputElementValue('h_definitionName')
                    },
                    activity: {
                        name: FormUtility.getInputElementValue('h_activityName'),
                        sequence: FormUtility.parseInt(FormUtility.getInputElementValue('h_activitySeq'), 0)
                    },
                    workitem: {
                        participantId: FormUtility.getInputElementValue('h_witemParticipantID'),
                        participantName: FormUtility.getInputElementValue('h_witemParticipantName'),
                        sequence: FormUtility.parseInt(FormUtility.getInputElementValue('h_witemSeq'), 0)
                    }
                };
            }
        }

        function saveProcessInfo(processInfo) {
            FormState.updateObjectValue("processName", processInfo.process.definitionName);
            FormState.updateObjectValue("processInfo", processInfo);
        }

        function checkAuthority() {
            var authority = false;

            if (activityStep.isStartNew()) {
                authority = true;
            } else if (activityStep.isCOMPReview() || activityStep.isCOMPReviewForModification()) {
                authority = myInfo.isComponent();
            } else if (activityStep.isSOReview()) {
                // authority = myInfo.isComponent();
                authority = myInfo.isSO();
            } else if (activityStep.isCOCReview()) {
                authority = myInfo.isCOC();
            } else if (activityStep.isHRSReviewForModification() || activityStep.isHRSReview()) {
                authority = myInfo.isHRS();
            } else if (activityStep.isDGHOReview()) {
                authority = myInfo.isDGHO();
            } else if (activityStep.isCPReview()) {
                authority = myInfo.isCP();
            } else if (activityStep.isOFMReview()) {
                authority = myInfo.isOFM();
            } else if (activityStep.isTABGReview()) {
                authority = myInfo.isTABG();
            } else if (activityStep.isOHCReview()) {
                authority = myInfo.isOHC();
            } else if (activityStep.isOAReview()) {
                authority = myInfo.isOffAdmin();
            } else if (activityStep.isHRSRecordConclusion()) {
                authority = myInfo.isHRS();
            }else if (activityStep.isHR_REVIEW_APPROVAL()) {
                authority = myInfo.isINCENTIVEHRS();
            }else if (activityStep.isSOReviewForModification()) {
                authority = myInfo.isSO();
            }
            return authority;
        }

        function init() {
            $('#main_buttons_layout_group').css('visibility', 'hidden');
            if (FormUtility.getInputElementValue('WIH_exit_requested') === 'true') {
                basicWIHActionClient.exit({confirmMsg: null});
            }

            _processInfo = getProcessInfo();
            var formData = FormUtility.getInputElementValue('h_formData');
            var userGroups = FormUtility.getInputElementValue('h_userGroups', '', '');
            var userGroupMapping = FormUtility.getInputElementValue('h_userGroupMappingString', '', '');

            activityStep.setActivityName(_processInfo.activity.name);
            MyUserGroupManager.init(userGroups, userGroupMapping);
            LookupManager.init();
            if (checkAuthority() || FormUtility.isReadOnly()) {
                FormManager.init(_processInfo.activity.name, activityTabDefinition, formData, formRenderer);
                FormMainHandler.init(_processInfo);
                DocumentRuleManager.init('cms-incentives-document-rules', 'Incentives', function () {
                    return [{
                        "fieldId": "rule",
                        "fieldValue": "RequiredDocuments"
                    }, {
                        "fieldId": "incentiveType",
                        "fieldValue": FormState.getElementValue('incentiveType', '')
                    }, {
                        "fieldId": "requestType",
                        "fieldValue": FormState.getElementValue('requestType', '')
                    }, {
                        "fieldId": "pcaType",
                        "fieldValue": FormState.getElementValue('pcaType', '')
                    }, {
                        "fieldId": "requireBoardCert",
                        "fieldValue": FormState.getElementValue('requireBoardCert', '')
                    }, {
                        "fieldId": "candiAgreeRenewal",
                        "fieldValue": FormState.getElementValue('candiAgreeRenewal', '')
                    }, {
                        "fieldId": "doesHaveResume",
                        "fieldValue": FormAttachmentHandler.doesHaveAssociatedAttachmentCategory("Resume")
                    }, {
                        "fieldId": "doesHavePackage",
                        "fieldValue": FormAttachmentHandler.doesHaveAssociatedAttachmentCategory("Final Package")
                    }, {
                        "fieldId": "doesHaveOther",
                        "fieldValue": FormAttachmentHandler.doesHaveAttachmentCategory("Other")
                    }, {
                        "fieldId": "supportSAM",
                        "fieldValue": FormState.getElementValue('supportSAM', '')
                    }];
                });
                TabManager.setHideNavigationButton(true);
                FormUtility.setRemainingCharacterDispType("NOW_MAX");

                setTimeout(function () {
                    showReturnReason();
                }, 10);

                saveProcessInfo(_processInfo);
                initForm();

                $('a.selectedTab').focus();
            } else {
                bootbox.alert("You don't have an authority to open this request.", function () {
                    basicWIHActionClient.exit({confirmMsg: null});
                });
            }
        }

        // This function will be called after getRequestNumber.do is completed.
        function resetRequestNumber() {
            var requestNumber = FormUtility.getInputElementValue('h_response_requestNumber');
            var requestDate = FormUtility.getInputElementValue('h_now');
            // var requestStatus = REQUEST_STATUS.CREATED;

            FormState.updateObjectValue('requestNumber', requestNumber);
            FormState.updateObjectValue('requestDate', requestDate);
            // FormState.updateObjectValue('requestStatus', requestStatus);

            FormMainHandler.saveFormData();

            initStatusBar();
        }

        function resetMandatoryMark(tabObj) {
            if ("undefined" == typeof(tabObj)) {
                return;
            }
            setTimeout(function () {
                // Remove mandatory mark for read-only fields
                var $layoutContainer = $("#" + tabObj.targetGroup + " div.layoutContainer");
                if($layoutContainer.length > 0) {
                    $layoutContainer.each(function() {
                        var styleAttr = $(this).attr("style");
                        if ("undefined" == typeof(styleAttr)) {
                            styleAttr = "";
                        }
                        if (styleAttr.indexOf("display: none;") < 0) {
                            // var $disabledMandatoryMark = $(this).find("> div.layoutContainerContent > div.controlContainer > div.controlRow > .labelControl.isDisabled > label.label > span.mandatory");
                            var $disabledMandatoryMark = $(this).find("> .layoutContainerContent .labelControl.isDisabled > label.label > span.mandatory");
                            if($disabledMandatoryMark.length > 0) {
                                $disabledMandatoryMark.each(function(i) {
                                    // console.log("hide1:" + $(this).parent().attr("id"));
                                    $(this).hide();
                                });
                            }
                            // var $enabledMandatoryMark = $(this).find("> div.layoutContainerContent > div.controlContainer > div.controlRow > .labelControl:not(.isDisabled) > label.label > span.mandatory");
                            var $enabledMandatoryMark = $(this).find("> .layoutContainerContent .labelControl:not(.isDisabled) > label.label > span.mandatory");
                            if($enabledMandatoryMark.length > 0) {
                                $enabledMandatoryMark.each(function(i) {
                                    var inputControlId = $(this).parent("label.label").attr("for");
                                    var $disabledInputControl = $("#" + tabObj.targetGroup  + " #" + inputControlId);
                                    if($disabledInputControl.length > 0) {
                                        if ($disabledInputControl.hasClass("disabled") || ($disabledInputControl.closest(".isDisabled").length > 0)) {
                                            // console.log("hide2:" + $(this).parent().attr("id"));
                                            $(this).hide();
                                        } else if ($disabledInputControl.hasClass("ui-autocomplete-input") && ($disabledInputControl.closest(".hidden").length > 0)) {
                                            if ($("#" + tabObj.targetGroup  + " #" + inputControlId + "_DISP .removeButton").length == 0) {
                                                // console.log("hide3:" + $(this).parent().attr("id"));
                                                $(this).hide();
                                            } else {
                                                // console.log("show1:" + $(this).parent().attr("id"));
                                                $(this).show();
                                            }
                                        } else {
                                            // console.log("show2:" + $(this).parent().attr("id"));
                                            $(this).show();
                                        }
                                    }
                                });
                            }
                        }
                    });
                }
                resetDisabledSelectAndCheckBox(tabObj);
            }, 500);
        }

        function resetDisabledSelectAndCheckBox(tabObj) {
            if ("undefined" == typeof(tabObj)) {
                return;
            }
            setTimeout(function () {
                if ((typeof FormSection508 !== "undefined") && FormSection508.isUseSection508()) {
                    $("#" + tabObj.targetGroup + " .selectControl:not(.hidden) select.select.disabled:disabled").each(function(i) {
                        var selectId = $(this).attr("id");
                        if (("none" == $(this).css("display")) || ($("#" + selectId + "Output").length > 0)) {
                            // This disabled select box has already been hidden
                        } else {
                            var $divOutput = $("<div class='sr-only' id='" + selectId + "Output'></div>");
                            var selectedValue = FormState.getElementValue(selectId, "");
                            var selectedTextValue = $(this).children("[value='" + selectedValue +"']").text();
                            if(selectedTextValue == "") {
                                selectedTextValue = "&nbsp;";
                            }
                            $divOutput.html(selectedTextValue);
                            var $labelObject = $("#" + selectId + "_label");
                            if ($labelObject.length > 0) {
                                $divOutput.prepend($labelObject.clone().children().remove().end().text() + " ");
                            }
                            $(this).parent().attr("tabindex", "0");
                            $(this).parent().prepend($divOutput);
                        }
                    });
                    $("#" + tabObj.targetGroup + " .checkboxControl:not(.hidden) input.checkbox.disabled:disabled").each(function(i) {
                        var selectId = $(this).attr("id");
                        if (("none" == $(this).css("display")) || ($("#" + selectId + "Output").length > 0)) {
                            // This disabled select box has already been hidden
                        } else {
                            var $divOutput = $("<div class='sr-only' id='" + selectId + "Output'></div>");
                            var checked = $(this).is(":checked");
                            var $labelObject = $("#" + selectId + "_label");
                            if ($labelObject.length > 0) {
                                $divOutput.prepend($labelObject.clone().children().remove().end().text() + " ");
                            }
                            $(this).parent().attr({"tabindex": "0", "role": "checkbox", "aria-checked": checked, "aria-readonly": "true"});
                            $(this).parent().prepend($divOutput);
                        }
                    });
                }
            }, 300);
        }

        function setComponentVisibility(objectId, visible) {
            hyf.util.setComponentVisibility(objectId, visible);
            if(visible) {
                $("#" + objectId + " span.mandatory").each(function(i, element) {
                    var markerId = $(element).attr("id");
                    var targetId = markerId.replace("_marker", "");
                    var $inputObject = $("#" + targetId);
                    if ($inputObject.length > 0) {
                        try {
                            if ($inputObject.is(":disabled") || ($inputObject.closest(".isDisabled").length > 0)) {
                                $(element).hide();
                            } else {
                                $(element).show();
                            }
                        } catch(e) {
                            // ignore
                        }
                    }
                });
            }
        }

        function setComponentUsability(objectId, enable) {
            var $selectElement = $("#" + objectId);
            if ($selectElement.length == 0) {
                return;
            }
            if (enable) {
                if ($selectElement.is("select") || $selectElement.hasClass("checkbox")) {
                    if ((typeof FormSection508 !== "undefined") && FormSection508.isUseSection508()) {
                        if($selectElement.length > 0) {
                            var $selectElementOutput = $("#" + objectId + "Output");
                            if($selectElementOutput.length > 0) {
                                $selectElementOutput.empty();
                                $selectElement.parent().removeAttr("tabindex");
                                $selectElement.parent().removeAttr("role");
                                $selectElement.parent().removeAttr("aria-checked");
                                $selectElement.parent().removeAttr("aria-readonly");
                            }
                        }
                    }
                }
                var $selectElementMarker = $("#" + objectId + "_marker");
                if ($selectElementMarker.length > 0) {
                    $selectElementMarker.show();
                }
                hyf.util.enableComponent(objectId);
            } else {
                hyf.util.disableComponent(objectId);
                var $selectElementMarker = $("#" + objectId + "_marker");
                if ($selectElementMarker.length > 0) {
                    $selectElementMarker.hide();
                }
                if ((typeof FormSection508 !== "undefined") && FormSection508.isUseSection508()) {
                    if ($selectElement.is("select")) {
                        if ("none" == $selectElement.css("display")) {
                            return;
                        }
                        if ($("#" + objectId + "Output").length > 0) {
                            $("#" + objectId + "Output").remove();
                        }
                        if ($("#" + objectId + "Output").length == 0) {
                            var $divOutput = $("<div class='sr-only' id='" + objectId + "Output'></div>");
                            var selectedValue = FormState.getElementValue(objectId, "");
                            var selectedTextValue = $selectElement.children("[value='" + selectedValue + "']").text();
                            if (selectedTextValue == "") {
                                selectedTextValue = "&nbsp;";
                            }
                            $divOutput.html(selectedTextValue);
                            var $labelObject = $("#" + objectId + "_label");
                            if ($labelObject.length > 0) {
                                $divOutput.prepend($labelObject.clone().children().remove().end().text() + " ");
                            }
                            $selectElement.parent().attr("tabindex", "0");
                            $selectElement.parent().prepend($divOutput);
                        }
                    }
                    if ($selectElement.hasClass("checkbox")) {
                        if ("none" == $selectElement.css("display")) {
                            return;
                        }
                        if ($("#" + objectId + "Output").length > 0) {
                            $("#" + objectId + "Output").remove();
                        }
                        if ($("#" + objectId + "Output").length == 0) {
                            var $divOutput = $("<div class='sr-only' id='" + objectId + "Output'></div>");
                            var checked = $(this).is(":checked");
                            var $labelObject = $("#" + objectId + "_label");
                            if ($labelObject.length > 0) {
                                $divOutput.prepend($labelObject.clone().children().remove().end().text() + " ");
                            }
                            $selectElement.parent().attr({"tabindex": "0", "role": "checkbox", "aria-checked": checked, "aria-readonly": "true"});
                            $selectElement.parent().prepend($divOutput);
                        }
                    }
                }
            }
        }

        function setMandatoryConstraint(objectId, isMandatory) {
            try {
                hyf.util.setMandatoryConstraint(objectId, isMandatory);
            } catch(e) {
            }
        }

        function getDisabledObjects(tabId) {
            var disabledObjects = [];
            $("#partial_" + tabId + " .controlBody.isDisabled > .disabled:not([type='hidden'])").each(function(i, element) {
                var objId = $(element).attr("widgetid");
                if(!objId) {
                    objId = $(element).attr("id")
                }
                disabledObjects.push(objId);
            });
            return disabledObjects;
        }

        return {
            init: init,
            getProcessInfo: getProcessInfo,
            onSaveFormData: onSaveFormData,
            resetRequestNumber: resetRequestNumber,
            setSubmitButtonLabel: setSubmitButtonLabel,
            setTabVisibility: setTabVisibility,
            updateIncentiveTypeOutput: updateIncentiveTypeOutput,
            updateStatusValues: updateStatusValues,
            resetMandatoryMark: resetMandatoryMark,
            getDisabledObjects: getDisabledObjects,
            setMandatoryConstraint: setMandatoryConstraint,
            setComponentVisibility: setComponentVisibility,
            setComponentUsability: setComponentUsability
        }
    };

    var _initializer = window.FormMain || (window.FormMain = FormMain());
})(window);

/** * An error message that shows up when there is any errors. */
var SYSTEM_ERROR_MESSAGE = "<h3 style='color:red'>Something went wrong</h3><p><h4>The system has encountered an error. Please try again, and if it still doesn't work, contact EWITS 2.0 help desk.</h4>";

$(document).ready(function () {
    try {
        FormMain.init();
    } catch (e) {
        FormLog.log(FormLog.LOG_LEVEL.ERROR, 'FormMain::init ==>', e);
        bootbox.alert({
            message: SYSTEM_ERROR_MESSAGE,
            callback: function () {
                basicWIHActionClient.exit({confirmMsg: null});
            }
        });
    }
});

$(document).ajaxError(function (event, request, settings, thrownError) {
    if(request.statusText === 'abort') {
        return;
    }

    FormLog.log(FormLog.LOG_LEVEL.ERROR, 'ajaxError ==>', thrownError, request, settings);
    bootbox.alert(SYSTEM_ERROR_MESSAGE);
});

