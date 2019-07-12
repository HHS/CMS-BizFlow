<?xml version="1.0" encoding="UTF-8"?>
<out:stylesheet exclude-result-prefixes="fm" version="1.0" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:out="http://www.w3.org/1999/XSL/Transform">
	<!--Some information has been retained from the existing file!-->
	<out:import href="demo_skin.xsl" />
	<out:output encoding="UTF-8" indent="yes" method="xml" />
	<out:template name="section_title">NewForm</out:template>
	<out:template name="page_meta_tags">
		<!--Insert any required page specific meta tags in here-->
	</out:template>
	<out:template match="node() | @*" mode="maintain-dynamic-content">
		<out:copy>
			<out:apply-templates mode="maintain-dynamic-content" select="@*" />
			<out:apply-templates mode="maintain-dynamic-content" />
		</out:copy>
	</out:template>
	<out:template match="*" mode="maintain-dynamic-content">
		<out:element name="{name()}" namespace="{namespace-uri()}">
			<out:apply-templates mode="maintain-dynamic-content" select="@*" />
			<out:apply-templates mode="maintain-dynamic-content" />
		</out:element>
	</out:template>
	<out:template name="css_imports">
		<link href="css/webmaker_layout.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;!--[if lte IE 7]&gt;</out:text>
		<link href="css/webmaker_layout_ie_6_7.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;![endif]--&gt;</out:text>
		<link href="custom/css/jquery-ui-1.9.2.custom.min.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="theme/bizflow_default/css/theme.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;!--[if lte IE 8]&gt;</out:text>
		<link href="theme/bizflow_default/css/theme_ie8.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;![endif]--&gt;</out:text>
		<link href="theme/bizflow_default/css/print_completed.css?rev=20190613202429" media="print" rel="stylesheet" type="text/css" xmlns="" />
		<link href="theme/bizflow_default/css/theme_mobile.css?rev=20190613202429" media="only screen and (max-width: 1024px)" rel="stylesheet" type="text/css" xmlns="" />
		<link href="../cms_common/js/angularjs/bower_components/bootstrap/dist/css/bootstrap.min.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="../cms_common/js/angularjs/bower_components/bootstrap/dist/css/bootstrap.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="../cms_common/js/angularjs/bower_components/angular-inform/dist/angular-inform.min.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="../cms_common/js/angularjs/bower_components/angular-ui-select/dist/select.min.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="../cms_common/js/angularjs/bower_components/angular-block-ui/dist/angular-block-ui.min.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="../cms_common/js/angularjs/bower_components/angular-ui-grid/ui-grid.min.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="../cms_common/js/angularjs/common/css/bootstrap-ext.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="../cms_common/js/angularjs/common/css/app.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="custom/css/form-main.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="../cms_common/custom/css/form-common.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<link href="../cms_common/custom/css/cmscomment.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
	</out:template>
	<out:template name="page_scripts">
		<script src="../cms_common/custom/js/removeamd.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/jquery/dist/jquery.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="custom/js/jquery-ui-1.9.2.custom.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/blockUI.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/bootstrap/dist/js/bootstrap.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular/angular.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-cookies/angular-cookies.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-inform/dist/angular-inform.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-animate/angular-animate.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-ui-select/dist/select.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-file-upload/dist/angular-file-upload.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-block-ui/dist/angular-block-ui.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-sanitize/angular-sanitize.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-messages/angular-messages.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-ui-grid/ui-grid.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/bootbox/bootbox.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/bower_components/x2js/xml2json.js?rev=20190613202429 " type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/lodash.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/redux.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/form-state.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/common/js/angular-ext.min.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/common/js/angular-bizflow.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/common/common.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/common/components/common.components.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/common/components/common.directive.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/common/components/attachment/attachment.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/form-log.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/form-require.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/form-utility.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/form-attachment.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/js/angularjs/common/components/comment/comment.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/cmscomment.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/form-auto-complete.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/lookup-manager.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/form-manager.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/form-usergroup.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="../cms_common/custom/js/form-section508.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="custom/js/form-main-common.js?rev=20190613202429" type="text/javascript" xmlns=""></script>
		<script src="custom/js/form-main.js?rev=20190618202429" type="text/javascript" xmlns=""></script>
	</out:template>
	<out:template name="section_body">
<xform:xform xmlns:xform="http://www.w3.org/2001/08/xforms" xmlns="" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:xfact="http://www.hyfinity.com/xfactory" >		<xform:instance id="actionWorkitem" xmlns:xform="http://www.w3.org/2001/08/xforms">
			<eForm xmlns="http://www.hyfinity.com/mvc" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:xfact="http://www.hyfinity.com/xfactory" xmlns:xg="http://www.hyfinity.com/xgate">
				<Control>
					<Page />
					<Controller />
					<requestAction />
				</Control>
				<Data>
					<formData>
						<tab_control />
						<h_procid />
						<WIH_exit_requested />
						<WIH_save_requested />
						<WIH_complete_requested />
						<h_formData />
						<h_activityName />
						<h_witemParticipantID />
						<h_witemParticipantName />
						<h_userGroups />
						<h_currentUserMemberID />
						<h_currentUserName />
						<h_creationdate />
						<h_lookupXMLString />
						<h_sessioninfo />
						<h_now />
						<h_definitionName />
						<h_readOnly />
						<h_currentTabID />
						<ResultActionWorkitemtErrorMessage />
						<h_userGroupMappingString />
						<pv_returnFrom />
						<h_witemSeq />
						<h_activitySeq />
						<pv_requestStatus />
						<pv_disableIncentiveType />
						<requestGenerated />
					</formData>
					<WorkitemContext xmlns="">
						<SessionInfoXML />
						<Process>
							<ID />
							<Name />
							<Description />
							<State />
							<ProcessDefinitionID />
							<ProcessDefinitionName />
							<Deadline />
							<Initiator />
							<InitiatorName />
							<CreationDateTime />
							<CompleteDateTime />
							<ProcessVariables>
								<administrativeCode />
								<associatedNEILRequest />
								<candidateName />
								<currentOwner />
								<hrSpecialist />
								<incentiveType />
								<payPlanSeriesGrade />
								<positionTitle />
								<relatedUserIds />
								<requestDate />
								<requestNumber />
								<requestStatus />
								<selectingOfficial />
								<wihmode />
							</ProcessVariables>
							<CustomAttributes>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
							</CustomAttributes>
						</Process>
						<Activity>
							<Sequence />
							<Name />
							<Description />
							<State />
							<CreationDateTime />
							<CompleteDateTime />
							<Responses>
								<Response>
									<Name />
									<IsDefault />
									<Rule />
								</Response>
								<Response>
									<Name />
									<IsDefault />
									<Rule />
								</Response>
								<Response>
									<Name />
									<IsDefault />
									<Rule />
								</Response>
							</Responses>
							<CustomAttributes>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
							</CustomAttributes>
						</Activity>
						<Workitem>
							<Sequence />
							<Participant />
							<ParticipantName />
							<ParticipantType />
							<State />
							<CreationDateTime />
							<StartDateTime />
							<CompleteDateTime />
							<CheckedOutUser />
							<CheckedOutUserName />
							<Deadline />
						</Workitem>
						<User>
							<LoginID />
							<MemberID />
							<Name />
							<ShortName />
							<DepartmentName />
							<EmployeeCode />
							<Email />
							<JobTitle1 />
							<JobTitle2 />
							<JobTitle3 />
							<CustomAttribute1 />
							<CustomAttribute2 />
							<CustomAttribute3 />
							<CustomAttribute4 />
							<CustomAttribute5 />
							<UserGroups>
								<UserGroup>
									<ID />
									<Name />
									<Path />
								</UserGroup>
								<UserGroup>
									<ID />
									<Name />
									<Path />
								</UserGroup>
								<UserGroup>
									<ID />
									<Name />
									<Path />
								</UserGroup>
							</UserGroups>
						</User>
						<Application>
							<Name />
							<ApplicationState />
							<CheckOutState />
							<CheckedOutUser />
							<Updatable />
							<ViewType />
						</Application>
					</WorkitemContext>
				</Data>
			</eForm>
		</xform:instance>
		<xform:instance id="getRequestNumber" xmlns:xform="http://www.w3.org/2001/08/xforms">
			<eForm xmlns="http://www.hyfinity.com/mvc" xmlns:mvc="http://www.hyfinity.com/mvc">
				<Control>
					<Page />
					<Controller />
				</Control>
				<Data>
					<formData>
						<tab_control />
						<h_procid />
						<WIH_exit_requested />
						<WIH_save_requested />
						<WIH_complete_requested />
						<h_formData />
						<h_activityName />
						<h_witemParticipantID />
						<h_witemParticipantName />
						<h_userGroups />
						<h_currentUserMemberID />
						<h_currentUserName />
						<h_creationdate />
						<h_lookupXMLString />
						<h_sessioninfo />
						<h_definitionName />
						<h_readOnly />
						<h_currentTabID />
						<h_now />
						<ResultActionWorkitemtErrorMessage />
						<h_userGroupMappingString />
						<pv_returnFrom />
						<h_witemSeq />
						<h_activitySeq />
						<pv_requestStatus />
						<pv_disableIncentiveType />
						<requestGenerated />
					</formData>
					<WorkitemContext xmlns="">
						<SessionInfoXML />
						<Process>
							<ID />
							<Name />
							<Description />
							<State />
							<ProcessDefinitionID />
							<ProcessDefinitionName />
							<Deadline />
							<Initiator />
							<InitiatorName />
							<CreationDateTime />
							<CompleteDateTime />
							<ProcessVariables>
								<administrativeCode />
								<associatedNEILRequest />
								<candidateName />
								<currentOwner />
								<hrSpecialist />
								<incentiveType />
								<payPlanSeriesGrade />
								<positionTitle />
								<relatedUserIds />
								<requestDate />
								<requestNumber />
								<requestStatus />
								<selectingOfficial />
								<wihmode />
							</ProcessVariables>
							<CustomAttributes>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
							</CustomAttributes>
						</Process>
						<Activity>
							<Sequence />
							<Name />
							<Description />
							<State />
							<CreationDateTime />
							<CompleteDateTime />
							<Responses>
								<Response>
									<Name />
									<IsDefault />
									<Rule />
								</Response>
								<Response>
									<Name />
									<IsDefault />
									<Rule />
								</Response>
								<Response>
									<Name />
									<IsDefault />
									<Rule />
								</Response>
							</Responses>
							<CustomAttributes>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
								<CustomAttribute>
									<Name />
									<CustomAttributeValueType />
									<Value />
									<Description />
								</CustomAttribute>
							</CustomAttributes>
						</Activity>
						<Workitem>
							<Sequence />
							<Participant />
							<ParticipantName />
							<ParticipantType />
							<State />
							<CreationDateTime />
							<StartDateTime />
							<CompleteDateTime />
							<CheckedOutUser />
							<CheckedOutUserName />
							<Deadline />
						</Workitem>
						<User>
							<LoginID />
							<MemberID />
							<Name />
							<ShortName />
							<DepartmentName />
							<EmployeeCode />
							<Email />
							<JobTitle1 />
							<JobTitle2 />
							<JobTitle3 />
							<CustomAttribute1 />
							<CustomAttribute2 />
							<CustomAttribute3 />
							<CustomAttribute4 />
							<CustomAttribute5 />
							<UserGroups>
								<UserGroup>
									<ID />
									<Name />
									<Path />
								</UserGroup>
								<UserGroup>
									<ID />
									<Name />
									<Path />
								</UserGroup>
								<UserGroup>
									<ID />
									<Name />
									<Path />
								</UserGroup>
							</UserGroups>
						</User>
						<Application>
							<Name />
							<ApplicationState />
							<CheckOutState />
							<CheckedOutUser />
							<Updatable />
							<ViewType />
						</Application>
					</WorkitemContext>
				</Data>
			</eForm>
		</xform:instance>
		<div class="form" xmlns="">
			<form action="process.do" method="post" name="NewForm">
				<out:if test="/mvc:eForm/mvc:Control/mvc:Language != ''">
					<input name="Language" type="hidden" value="{/mvc:eForm/mvc:Control/mvc:Language}" />
				</out:if>
				<input name="is_script_enabled" type="hidden" value="false" />
				<script type="text/javascript">
					<out:text>document.NewForm</out:text>
					<out:text>.is_script_enabled.value = 'true';</out:text>
				</script>
				<meta content="width=device-width, initial-scale=1, max-scale=1" name="viewport" />
				<script type="text/javascript">
                FormUtility.greyOutScreen(true);
            </script>
				<div class="layoutContainer alignVertical alignLeft alignTop  expandHeight " id="background">
					<div class="layoutContainerContent  expandWidth">
						<div class="layoutContainer alignVertical alignLeft alignMiddle  expandWidth fitHeight " id="container" style="margin-left: 10px; margin-right: 10px; background-color : #ffffff;">
							<div class="layoutContainerContent  expandWidth">
								<div class="layoutContainer alignHorizontal alignLeft alignMiddle  expandWidth " id="logoSection">
									<div class="layoutContainerContent">
										<div class="controlContainer labelLeft">
											<div class="controlRow">
												<span class="defaultBackground imageControl alignLeft alignMiddle  " id="cmslogo4_container">
													<span class="controlBody">
														<img alt="CMS Logo" class="image cmslogo " id="cmslogo4" name="cmslogo4" src="images/CMSLogo.png" />
													</span>
												</span>
											</div>
										</div>
									</div>
									<div class="layoutContainerSep"></div>
									<div class="layoutContainerContent">
										<div class="layoutContainer alignHorizontal alignLeft alignMiddle  " id="title">
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="defaultBackground outputControl " id="formTitle_container">
															<span class="controlBody">
																<span class="output " id="formTitle" style="font-family : Arial; font-size : 28pt; ">Incentives Request</span>
															</span>
														</span>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>
							<div class="layoutContainerSep"></div>
							<div class="layoutContainerContent  expandWidth">
								<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="commonHeader">
									<div class="layoutContainerContent  expandWidth">
										<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth " id="commmonInfo" style="background-color : #c0c0c0; height:40px;">
											<div class="layoutContainerContent expandHeight">
												<div class="controlContainer labelLeft expandHeight">
													<div class="controlRow">
														<span class="labelBackground labelControl header_label alignRight alignMiddle  expandHeight " id="output_requestNumber_label_container" style="width : 50px;">
															<label class="label " for="output_requestNumber" id="output_requestNumber_label">Request Number:</label>
														</span>
														<span class="defaultBackground outputControl header_value alignLeft alignTop  expandHeight " id="output_requestNumber_container">
															<span class="controlBody">
																<span class="output " id="output_requestNumber" style="width : 100px;"></span>
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent expandHeight">
												<div class="controlContainer labelLeft expandHeight">
													<div class="controlRow">
														<span class="labelBackground labelControl header_label alignRight alignMiddle  expandHeight " id="output_requestDate_label_container" style="width : 50px;">
															<label class="label " for="output_requestDate" id="output_requestDate_label">Request Date:</label>
														</span>
														<span class="defaultBackground outputControl header_value alignLeft alignMiddle  expandHeight " id="output_requestDate_container">
															<span class="controlBody">
																<span class="output " id="output_requestDate" style="width : 70px;"></span>
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent expandHeight">
												<div class="controlContainer labelLeft expandHeight">
													<div class="controlRow">
														<span class="labelBackground labelControl  expandHeight " id="output_incentiveType_label_container" style="width : 50px;">
															<label class="label " for="output_incentiveType" id="output_incentiveType_label">Incentive Type:</label>
														</span>
														<span class="defaultBackground outputControl  expandHeight " id="output_incentiveType_container">
															<span class="controlBody">
																<span class="output " id="output_incentiveType" style="width : 30px;">
																	<out:choose>
																		<out:when test="not(enter_xpath_here) or (enter_xpath_here = '')">
																			<out:text disable-output-escaping="yes">&amp;#160;</out:text>
																		</out:when>
																		<out:otherwise>
																			<out:value-of select="enter_xpath_here" />
																		</out:otherwise>
																	</out:choose>
																</span>
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent expandWidth expandHeight">
												<div class="controlContainer labelLeft expandWidth expandHeight">
													<div class="controlRow">
														<span class="labelBackground labelControl header_label alignRight alignMiddle  expandHeight " id="output_initiatorName_label_container" style="width : 50px;">
															<label class="label " for="output_initiatorName" id="output_initiatorName_label">Initiator:</label>
														</span>
														<span class="defaultBackground outputControl header_value alignLeft alignMiddle  expandWidth expandHeight " id="output_initiatorName_container">
															<span class="controlBody">
																<span class="output " id="output_initiatorName">
																	<out:choose>
																		<out:when test="not(/mvc:eForm/mvc:Data/WorkitemContext/Process/InitiatorName) or (/mvc:eForm/mvc:Data/WorkitemContext/Process/InitiatorName = '')">
																			<out:text disable-output-escaping="yes">&amp;#160;</out:text>
																		</out:when>
																		<out:otherwise>
																			<out:value-of select="/mvc:eForm/mvc:Data/WorkitemContext/Process/InitiatorName" />
																		</out:otherwise>
																	</out:choose>
																</span>
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent expandWidth expandHeight">
												<div class="controlContainer labelLeft expandWidth expandHeight">
													<div class="controlRow">
														<span class="labelBackground labelControl header_label alignRight alignMiddle  expandHeight " id="output_requestStatus_label_container" style="width : 50px;">
															<label class="label " for="output_requestStatus" id="output_requestStatus_label">Current Status:</label>
														</span>
														<span class="defaultBackground outputControl header_value alignLeft alignMiddle  expandWidth expandHeight " id="output_requestStatus_container">
															<span class="controlBody">
																<span class="output " id="output_requestStatus">
																	<out:choose>
																		<out:when test="not(/mvc:eForm/mvc:Data/mvc:formData/mvc:output_requestStatus) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:output_requestStatus = '')">
																			<out:text disable-output-escaping="yes">&amp;#160;</out:text>
																		</out:when>
																		<out:otherwise>
																			<out:value-of select="/mvc:eForm/mvc:Data/mvc:formData/mvc:output_requestStatus" />
																		</out:otherwise>
																	</out:choose>
																</span>
															</span>
														</span>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>
							<div class="layoutContainerSep"></div>
							<div class="layoutContainerContent expandWidth">
								<div style="height: 5px; width: 150px;"></div>
							</div>
							<div class="layoutContainerSep"></div>
							<div class="layoutContainerContent  expandWidth">
								<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="bodySection">
									<div class="layoutContainerContent  expandWidth">
										<div class="tabContainer container  expandWidth alignLeft alignTop " id="tab_container_group">
											<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="tab_control_group">
												<div class="layoutContainerContent expandWidth">
													<div class="controlContainer labelLeft expandWidth">
														<div class="controlRow">
															<span class="defaultBackground tabsButtons  expandWidth " id="tab_control_container">
																<span class="controlBody">
																	<out:variable name="currentTabValue">
																		<out:choose>
																			<out:when test="/mvc:eForm/mvc:Data/mvc:formData/mvc:tab_control != ''">
																				<out:value-of select="/mvc:eForm/mvc:Data/mvc:formData/mvc:tab_control" />
																			</out:when>
																			<out:otherwise>tab1</out:otherwise>
																		</out:choose>
																	</out:variable>
																	<a class="unselectedTab" href="#tab_control__tab1__tab" id="tab_control_tab_tab1" onclick="return tab_controlTabChange('tab1');">
																		<out:if test="$currentTabValue = 'tab1'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">General</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab2__tab" id="tab_control_tab_tab2" onclick="return tab_controlTabChange('tab2');">
																		<out:if test="$currentTabValue = 'tab2'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Position</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab3__tab" id="tab_control_tab_tab3" onclick="return tab_controlTabChange('tab3');">
																		<out:if test="$currentTabValue = 'tab3'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Details</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab4__tab" id="tab_control_tab_tab4" onclick="return tab_controlTabChange('tab4');">
																		<out:if test="$currentTabValue = 'tab4'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Review</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab5__tab" id="tab_control_tab_tab5" onclick="return tab_controlTabChange('tab5');">
																		<out:if test="$currentTabValue = 'tab5'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Approvals</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab6__tab" id="tab_control_tab_tab6" onclick="return tab_controlTabChange('tab6');">
																		<out:if test="$currentTabValue = 'tab6'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Details</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab9__tab" id="tab_control_tab_tab9" onclick="return tab_controlTabChange('tab9');">
																		<out:if test="$currentTabValue = 'tab9'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Justification</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab7__tab" id="tab_control_tab_tab7" onclick="return tab_controlTabChange('tab7');">
																		<out:if test="$currentTabValue = 'tab7'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Review</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab8__tab" id="tab_control_tab_tab8" onclick="return tab_controlTabChange('tab8');">
																		<out:if test="$currentTabValue = 'tab8'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Approvals</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab10__tab" id="tab_control_tab_tab10" onclick="return tab_controlTabChange('tab10');">
																		<out:if test="$currentTabValue = 'tab10'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Details</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab11__tab" id="tab_control_tab_tab11" onclick="return tab_controlTabChange('tab11');">
																		<out:if test="$currentTabValue = 'tab11'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Justification</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab12__tab" id="tab_control_tab_tab12" onclick="return tab_controlTabChange('tab12');">
																		<out:if test="$currentTabValue = 'tab12'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Review</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab13__tab" id="tab_control_tab_tab13" onclick="return tab_controlTabChange('tab13');">
																		<out:if test="$currentTabValue = 'tab13'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Approvals</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab15__tab" id="tab_control_tab_tab15" onclick="return tab_controlTabChange('tab15');">
																		<out:if test="$currentTabValue = 'tab15'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Details</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab16__tab" id="tab_control_tab_tab16" onclick="return tab_controlTabChange('tab16');">
																		<out:if test="$currentTabValue = 'tab16'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Panel</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab17__tab" id="tab_control_tab_tab17" onclick="return tab_controlTabChange('tab17');">
																		<out:if test="$currentTabValue = 'tab17'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Review</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab18__tab" id="tab_control_tab_tab18" onclick="return tab_controlTabChange('tab18');">
																		<out:if test="$currentTabValue = 'tab18'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Approval</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab99__tab" id="tab_control_tab_tab99" onclick="return tab_controlTabChange('tab99');">
																		<out:if test="$currentTabValue = 'tab99'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Documents</span>
																		</span>
																	</a>
																	<a class="unselectedTab" href="#tab_control__tab90__tab" id="tab_control_tab_tab90" onclick="return tab_controlTabChange('tab90');">
																		<out:if test="$currentTabValue = 'tab90'">
																			<out:attribute name="class">selectedTab</out:attribute>
																		</out:if>
																		<span class="l">
																			<span class="r">Notes</span>
																		</span>
																	</a>
																	<input id="tab_control" name="tab_control" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:tab_control}">
																		<out:if test="not(/mvc:eForm/mvc:Data/mvc:formData/mvc:tab_control) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:tab_control = '')">
																			<out:attribute name="value">tab1</out:attribute>
																		</out:if>
																	</input>
																	<input name="tab_control_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:tab_control" />
																	<script type="text/javascript">
																		<out:text>function </out:text>
																		<out:text>tab_controlTabChange(value) {
                        hyf.util.setFieldValue('</out:text>
																		<out:text>tab_control', value);
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab1').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab2').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab3').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab4').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab5').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab6').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab9').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab7').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab8').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab10').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab11').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab12').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab13').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab15').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab16').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab17').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab18').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab99').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_tab90').className = 'unselectedTab';
                        </out:text>
																		<out:text>document.getElementById('tab_control_tab_' + value).className = 'selectedTab';
                        return false; }</out:text>
																	</script>
																</span>
															</span>
														</div>
													</div>
												</div>
											</div>
											<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="layout_group_4" style="margin-bottom:5px;border-top-style : ridge; "></div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab1__tab">
													<span class="l">
														<span class="r">General</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab1">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab1"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab2__tab">
													<span class="l">
														<span class="r">Position</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab2">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab2"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab3__tab">
													<span class="l">
														<span class="r">Details</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab3">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab3"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab4__tab">
													<span class="l">
														<span class="r">Review</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab4">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab4"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab5__tab">
													<span class="l">
														<span class="r">Approvals</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab5">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab5"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab6__tab">
													<span class="l">
														<span class="r">Details</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab6">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab6"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab9__tab">
													<span class="l">
														<span class="r">Justification</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab9">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab9"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab7__tab">
													<span class="l">
														<span class="r">Review</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab7">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab7"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab8__tab">
													<span class="l">
														<span class="r">Approvals</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab8">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab8"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab10__tab">
													<span class="l">
														<span class="r">Details</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab10">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab10"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab11__tab">
													<span class="l">
														<span class="r">Justification</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab11">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab11"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab12__tab">
													<span class="l">
														<span class="r">Review</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab12">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab12"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab13__tab">
													<span class="l">
														<span class="r">Approvals</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab13">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab13"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab14__tab">
													<span class="l">
														<span class="r"></span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab14">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab14"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab15__tab">
													<span class="l">
														<span class="r">Details</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab15">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab15"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab16__tab">
													<span class="l">
														<span class="r">Panel</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab16">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab16"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab17__tab">
													<span class="l">
														<span class="r">Review</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab17">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab17"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab18__tab">
													<span class="l">
														<span class="r">Approval</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab18">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab18"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab99__tab">
													<span class="l">
														<span class="r">Documents</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab99">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab99"></div>
											</div>
											<noscript>
												<a class="selectedTab" id="tab_control__tab90__tab">
													<span class="l">
														<span class="r">Notes</span>
													</span>
												</a>
											</noscript>
											<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="tab90">
												<div class="partialPageContainer container  expandWidth fitHeight alignLeft alignTop " id="partial_tab90"></div>
											</div>
											<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth " id="layout_TabPreviousNext" style="margin-bottom:5px;border-top-style : ridge; ">
												<div class="layoutContainerContent  expandWidth">
													<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="layout_group" style="margin-top:5px;">
														<div class="layoutContainerContent">
															<div class="controlContainer labelLeft">
																<div class="controlRow">
																	<span class="defaultBackground buttonControl " id="button_Previous_container">
																		<span class="controlBody">
																			<input class="button " id="button_Previous" name="button_Previous" type="button" value="Previous" />
																		</span>
																	</span>
																</div>
															</div>
														</div>
														<div class="layoutContainerSep"></div>
														<div class="layoutContainerContent">
															<div class="controlContainer labelLeft">
																<div class="controlRow">
																	<span class="defaultBackground buttonControl " id="button_Next_container">
																		<span class="controlBody">
																			<input class="button " id="button_Next" name="button_Next" type="button" value="Next" />
																		</span>
																	</span>
																</div>
															</div>
														</div>
													</div>
												</div>
												<div class="layoutContainerSep"></div>
												<div class="layoutContainerContent  expandWidth">
													<div class="layoutContainer alignVertical alignRight alignMiddle  expandWidth fitHeight " id="layout_group_2"></div>
												</div>
											</div>
											<div class="layoutContainer alignHorizontal alignCenter alignMiddle  expandWidth " id="main_buttons_layout_group">
												<div class="layoutContainerContent">
													<div class="layoutContainer alignHorizontal alignRight alignMiddle  fitHeight " id="action_buttons">
														<div class="layoutContainerContent">
															<div class="controlContainer labelLeft">
																<div class="controlRow">
																	<span class="defaultBackground buttonControl " id="button_ReturnForModification_container">
																		<span class="controlBody">
																			<input class="button hidden " id="button_ReturnForModification" name="button_ReturnForModification" title="Click to return the request for modifications" type="button" value="Return for Modification" />
																		</span>
																	</span>
																</div>
															</div>
														</div>
														<div class="layoutContainerSep"></div>
														<div class="layoutContainerContent">
															<div class="controlContainer labelLeft">
																<div class="controlRow">
																	<span class="defaultBackground buttonControl " id="button_SendTo1_container">
																		<span class="controlBody">
																			<input class="button hidden " id="button_SendTo1" name="button_SendTo1" title="Click to send to the HR Specialist" type="button" value="Send to HR" />
																		</span>
																	</span>
																</div>
															</div>
														</div>
														<div class="layoutContainerSep"></div>
														<div class="layoutContainerContent">
															<div class="controlContainer labelLeft">
																<div class="controlRow">
																	<span class="defaultBackground buttonControl " id="button_SubmitWorkitem_container">
																		<span class="controlBody">
																			<input class="button hidden " id="button_SubmitWorkitem" name="button_SubmitWorkitem" title="Move forward the incentives action to the next activity" type="button" value="Submit" />
																		</span>
																	</span>
																</div>
															</div>
														</div>
														<div class="layoutContainerSep"></div>
														<div class="layoutContainerContent">
															<div class="controlContainer labelLeft">
																<div class="controlRow">
																	<span class="defaultBackground buttonControl " id="button_SendTo2_container">
																		<span class="controlBody">
																			<input class="button hidden " id="button_SendTo2" name="button_SendTo2" title="Click to send to the HR Specialist" type="button" value="Send to HR" />
																		</span>
																	</span>
																</div>
															</div>
														</div>
														<div class="layoutContainerSep"></div>
														<div class="layoutContainerContent">
															<div class="controlContainer labelLeft">
																<div class="controlRow">
																	<span class="defaultBackground buttonControl " id="button_CancelWorkitem_container">
																		<span class="controlBody">
																			<input class="button hidden " id="button_CancelWorkitem" name="button_CancelWorkitem" title="Click to Cancel this Request" type="button" value="Cancel Request" />
																		</span>
																	</span>
																</div>
															</div>
														</div>
														<div class="layoutContainerSep"></div>
														<div class="layoutContainerContent">
															<div class="controlContainer labelLeft">
																<div class="controlRow">
																	<span class="defaultBackground buttonControl " id="button_SaveWorkitem_container">
																		<span class="controlBody">
																			<input accesskey="s" class="button hidden " id="button_SaveWorkitem" name="button_SaveWorkitem" title="Saves a draft of the request" type="button" value="Save" />
																		</span>
																	</span>
																</div>
															</div>
														</div>
														<div class="layoutContainerSep"></div>
														<div class="layoutContainerContent">
															<div class="controlContainer labelLeft">
																<div class="controlRow">
																	<span class="defaultBackground buttonControl " id="button_ExitWIH_container">
																		<span class="controlBody">
																			<input class="button hidden " id="button_ExitWIH" name="button_ExitWIH" title="Close out the page" type="button" value="Exit" />
																		</span>
																	</span>
																</div>
															</div>
														</div>
														<div class="layoutContainerSep"></div>
														<div class="layoutContainerContent">
															<div class="controlContainer labelLeft">
																<div class="controlRow">
																	<span class="defaultBackground buttonControl " id="button_PDF_container">
																		<span class="controlBody">
																			<input class="button hidden " id="button_PDF" name="button_PDF" title="Mark the Strategic Consultation Recruitment complete and submit for finance approval" type="button" value="Complete" />
																		</span>
																	</span>
																</div>
															</div>
														</div>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div class="adjacentGroupSep"></div>
				<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="layoutForResponse"></div>
				<div class="adjacentGroupSep"></div>
				<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="layoutForResponse2"></div>
				<div class="adjacentGroupSep"></div>
				<div class="hide layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="system">
					<div class="layoutContainerContent  expandWidth">
						<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="WIH_information">
							<div class="layoutContainerContent">
								<div class="controlContainer labelLeft">
									<div class="controlRow">
										<span class="hide " id="h_procid_container">
											<span class="controlBody">
												<input class="hide " id="h_procid" name="h_procid" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/Process/ID}" />
												<input name="h_procid_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_procid" />
											</span>
										</span>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="WIH_exit_requested_container">
									<span class="controlBody">
										<input class="hide " id="WIH_exit_requested" name="WIH_exit_requested" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_exit_requested}">
											<out:if test="not(/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_exit_requested) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_exit_requested = '')">
												<out:attribute name="value">false</out:attribute>
											</out:if>
										</input>
										<input name="WIH_exit_requested_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_exit_requested" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="WIH_save_requested_container">
									<span class="controlBody">
										<input class="hide " id="WIH_save_requested" name="WIH_save_requested" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_save_requested}">
											<out:if test="not(/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_save_requested) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_save_requested = '')">
												<out:attribute name="value">false</out:attribute>
											</out:if>
										</input>
										<input name="WIH_save_requested_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_save_requested" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="WIH_complete_requested_container">
									<span class="controlBody">
										<input class="hide " id="WIH_complete_requested" name="WIH_complete_requested" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_complete_requested}">
											<out:if test="not(/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_complete_requested) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_complete_requested = '')">
												<out:attribute name="value">false</out:attribute>
											</out:if>
										</input>
										<input name="WIH_complete_requested_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:WIH_complete_requested" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_formData_container">
									<span class="controlBody">
										<input class="hide " id="h_formData" name="h_formData" type="hidden" value="{/mvc:eForm/mvc:Data/FORM_DATA/FIELD_DATA_CLOB}" />
										<input name="h_formData_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_formData" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_activityName_container">
									<span class="controlBody">
										<input class="hide " id="h_activityName" name="h_activityName" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/Activity/Name}" />
										<input name="h_activityName_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_activityName" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_activitySeq_container">
									<span class="controlBody">
										<input class="hide " id="h_activitySeq" name="h_activitySeq" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/Activity/Sequence}" />
										<input name="h_activitySeq_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_activitySeq" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_witemParticipantID_container">
									<span class="controlBody">
										<input class="hide " id="h_witemParticipantID" name="h_witemParticipantID" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/Workitem/Participant}" />
										<input name="h_witemParticipantID_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_witemParticipantID" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_witemParticipantName_container">
									<span class="controlBody">
										<input class="hide " id="h_witemParticipantName" name="h_witemParticipantName" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/Workitem/ParticipantName}" />
										<input name="h_witemParticipantName_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_witemParticipantName" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_witemSeq_container">
									<span class="controlBody">
										<input class="hide " id="h_witemSeq" name="h_witemSeq" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/Workitem/Sequence}" />
										<input name="h_witemSeq_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_witemSeq" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_userGroups_container">
									<span class="controlBody">
										<input class="hide " id="h_userGroups" name="h_userGroups" type="hidden" value="{/mvc:eForm/mvc:Data/userGroups}" />
										<input name="h_userGroups_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_userGroups" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_userGroupMappingString_container">
									<span class="controlBody">
										<input class="hide " id="h_userGroupMappingString" name="h_userGroupMappingString" type="hidden" value="{/mvc:eForm/mvc:Data/userGroupMappingString}" />
										<input name="h_userGroupMappingString_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_userGroupMappingString" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_currentUserMemberID_container">
									<span class="controlBody">
										<input class="hide " id="h_currentUserMemberID" name="h_currentUserMemberID" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/User/MemberID}" />
										<input name="h_currentUserMemberID_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_currentUserMemberID" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_currentUserName_container">
									<span class="controlBody">
										<input class="hide " id="h_currentUserName" name="h_currentUserName" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/User/Name}" />
										<input name="h_currentUserName_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_currentUserName" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_creationdate_container">
									<span class="controlBody">
										<input class="hide " id="h_creationdate" name="h_creationdate" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/Process/CreationDateTime}" />
										<input name="h_creationdate_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_creationdate" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_lookupXMLString_container">
									<span class="controlBody">
										<input class="hide " id="h_lookupXMLString" name="h_lookupXMLString" type="hidden" value="{/mvc:eForm/mvc:Data/lookupString}" />
										<input name="h_lookupXMLString_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_lookupXMLString" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_sessioninfo_container">
									<span class="controlBody">
										<input class="hide " id="h_sessioninfo" name="h_sessioninfo" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/SessionInfoXML}" />
										<input name="h_sessioninfo_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_sessioninfo" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_definitionName_container">
									<span class="controlBody">
										<input class="hide " id="h_definitionName" name="h_definitionName" type="hidden" value="{/mvc:eForm/mvc:Data/WorkitemContext/Process/ProcessDefinitionName}" />
										<input name="h_definitionName_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_definitionName" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_readOnly_container">
									<span class="controlBody">
										<input class="hide " id="h_readOnly" name="h_readOnly" type="hidden" value="{/mvc:eForm/mvc:Control/mvc:readOnly
}" />
										<input name="h_readOnly_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_readOnly" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_currentTabID_container">
									<span class="controlBody">
										<input class="hide " id="h_currentTabID" name="h_currentTabID" type="hidden" value="{/mvc:eForm/mvc:Control/mvc:currentTabID}" />
										<input name="h_currentTabID_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_currentTabID" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="h_now_container">
									<span class="controlBody">
										<input class="hide " id="h_now" name="h_now" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:h_now}" />
										<input name="h_now_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:h_now" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="pv_returnFrom_container">
									<span class="controlBody">
										<input class="hide " id="pv_returnFrom" name="pv_returnFrom" type="hidden" value="{/mvc:eForm/mvc:Data/FORM_DATA/PV_RETURN_FROM}" />
										<input name="pv_returnFrom_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:pv_returnFrom" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="pv_disableIncentiveType_container">
									<span class="controlBody">
										<input class="hide " id="pv_disableIncentiveType" name="pv_disableIncentiveType" type="hidden" value="{/mvc:eForm/mvc:Data/FORM_DATA/PV_DISABLE_INCENTIVE_TYPE}" />
										<input name="pv_disableIncentiveType_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:pv_disableIncentiveType" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="pv_requestStatus_container">
									<span class="controlBody">
										<input class="hide " id="pv_requestStatus" name="pv_requestStatus" type="hidden" value="{/mvc:eForm/mvc:Data/FORM_DATA/PV_REQUEST_STATUS}" />
										<input name="pv_requestStatus_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:pv_requestStatus" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="hide " id="requestGenerated_container">
									<span class="controlBody">
										<input class="hide " id="requestGenerated" name="requestGenerated" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:requestGenerated}">
											<out:if test="not(/mvc:eForm/mvc:Data/mvc:formData/mvc:requestGenerated) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:requestGenerated = '')">
												<out:attribute name="value">No</out:attribute>
											</out:if>
										</input>
										<input name="requestGenerated_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:requestGenerated" />
									</span>
								</span>
							</div>
						</div>
					</div>
				</div>
			</form>
		</div>
</xform:xform>		<script type="text/javascript" xmlns="">
			<out:text disable-output-escaping="yes">

            /*
             * Do NOT edit or add to the following script.
             * It will be recreated each time the page is regenerated!
             * Instead use the Application Map screen to add an external
             * script file to your page, and place your code in there.
             */

            hyf.validation.config =
            {
                form: document.NewForm,
                errorDisplayMethod: 'bubble',
                errorDisplayShowAlerts: false,
                errorDisplayValidationMode: 'all',
                asYouType: true,
                mandatoryMarker: {
                    content: ' * ',
                    location: 'after_label',
                    className: 'mandatory',
                    style: ''
                    }
            }
        			</out:text>
<xsl:for-each select="." xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:xfact="http://www.hyfinity.com/xfactory">			<out:text>
            field = document.getElementById('</out:text>
			<out:text>formTitle</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>output_requestNumber</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>output_requestDate</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>output_incentiveType</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>output_initiatorName</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>output_requestStatus</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>tab_control</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>field = document.getElementById('</out:text>
			<out:text>tab1');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab1&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab1',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab1'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab2');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab2&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab2',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab2'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab3');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab3&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab3',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab3'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab4');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab4&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab4',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab4'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab5');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab5&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab5',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab5'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab6');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab6&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab6',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab6'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab9');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab9&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab9',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab9'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab7');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab7&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab7',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab7'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab8');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab8&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab8',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab8'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab10');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab10&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab10',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab10'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab11');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab11&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab11',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab11'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab12');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab12&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab12',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab12'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab13');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab13&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab13',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab13'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab14');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab14&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab14',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab14'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab15');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab15&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab15',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab15'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab16');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab16&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab16',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab16'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab17');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab17&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab17',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab17'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab18');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab18&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab18',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab18'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab99');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab99&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab99',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab99'}] }});</xsl:text>			<out:text>field = document.getElementById('</out:text>
			<out:text>tab90');</out:text>
			<out:text>field.setAttribute('_use', 'tabPane');field.setAttribute('_tabField', &quot;</out:text>
			<out:text>tab_control_tab_tab90&quot;);</out:text>hyf.util.conditionalDisplay.setup({type:'group', name: 'tab90',  invert: true, condition: <xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">{ type: 'check', funcName: 'hyf.FMCondition.checkFieldValue', values: [{name: 'FieldToCheck', option: 'PageField', value: 'tab_control'}, {name: 'Comparison', option: '==', value: ''}, {name: 'CheckValue', option: 'Static', value: 'tab90'}] }});</xsl:text>			<out:text>
            field = document.getElementById('</out:text>
			<out:text>button_Previous</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>button_Next</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>button_ReturnForModification</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>button_SendTo1</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>button_SubmitWorkitem</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>button_SendTo2</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>button_CancelWorkitem</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>button_SaveWorkitem</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>button_ExitWIH</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>button_PDF</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_procid</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>WIH_exit_requested</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>WIH_save_requested</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>WIH_complete_requested</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_formData</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_activityName</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_activitySeq</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_witemParticipantID</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_witemParticipantName</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_witemSeq</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_userGroups</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_userGroupMappingString</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_currentUserMemberID</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_currentUserName</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_creationdate</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_lookupXMLString</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_sessioninfo</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_definitionName</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_readOnly</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_currentTabID</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>h_now</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>pv_returnFrom</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>pv_disableIncentiveType</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>pv_requestStatus</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>requestGenerated</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
<xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
            function NewFormonbeforeload(e)
            {
                var evt = (window.event) ? window.event : e;
                var objEventSource = {name: 'EventSource', option: 'page', event: evt};
                    var objFunction = {name: 'Function', option: 'Static', value: 'require'};
                    var objParameters = {name: 'Parameters', option: 'Script', value: '[&quot;dijit/Dialog&quot;]'};
                    hyf.FMAction.handleFunctionCall(objFunction, objParameters, objEventSource);
            }
            NewFormonbeforeload();
                    hyf.hooks.contentInserted(document.body);</xsl:text></xsl:for-each>		</script>
	</out:template>
</out:stylesheet>
