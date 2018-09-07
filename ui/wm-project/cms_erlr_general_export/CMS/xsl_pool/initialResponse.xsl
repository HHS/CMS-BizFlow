<?xml version="1.0" encoding="UTF-8"?>
<out:stylesheet exclude-result-prefixes="fm" version="1.0" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:out="http://www.w3.org/1999/XSL/Transform">
	<!--Some information has been retained from the existing file!-->
	<out:output encoding="UTF-8" indent="yes" method="xml" />
	<out:template name="section_title">initialResponse</out:template>
	<out:template name="page_meta_tags">
		<!--Insert any required page specific meta tags in here-->
	</out:template>
	<out:template match="/">
		<div class="subsection_container" id="subsection_initialResponse" xmlns="">
			<out:call-template name="section_body" />
		</div>
	</out:template>
	<out:template name="css_imports">
		<link href="css/webmaker_layout.css" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;!--[if lte IE 7]&gt;</out:text>
		<link href="css/webmaker_layout_ie_6_7.css" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;![endif]--&gt;</out:text>
		<link href="theme/bizflow_default/css/theme.css" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;!--[if lte IE 8]&gt;</out:text>
		<link href="theme/bizflow_default/css/theme_ie8.css" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;![endif]--&gt;</out:text>
		<link href="theme/bizflow_default/css/print_completed.css" media="print" rel="stylesheet" type="text/css" xmlns="" />
		<link href="theme/bizflow_default/css/theme_mobile.css" media="only screen and (max-width: 1024px)" rel="stylesheet" type="text/css" xmlns="" />
	</out:template>
	<out:template name="page_scripts" />
	<out:template name="section_body">
<xform:xform xmlns:xform="http://www.w3.org/2001/08/xforms" xmlns="" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:mvc="http://www.hyfinity.com/mvc" >		<div xmlns="">
			<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="erlr_initial_response_body">
				<div class="layoutContainerContent  expandWidth">
					<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="common_fields_group">
						<div class="layoutContainerContent  expandWidth">
							<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth " id="specialist_group" style="height : 71px;">
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl " id="GEN_DWC_SPECIALIST_label_container">
												<label class="label " for="GEN_DWC_SPECIALIST" id="GEN_DWC_SPECIALIST_label">Primary Specialist:<span class="mandatory" id="GEN_DWC_SPECIALIST_marker" style="" title="Mandatory field"> * </span>
												</label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground selectControl " id="GEN_DWC_SPECIALIST_container">
												<span class="controlBody isMandatory">
													<select class="select " id="GEN_DWC_SPECIALIST" name="GEN_DWC_SPECIALIST">
														<option value="">
															<out:text>Select One</out:text>
														</option>
														<out:variable name="checkDefault" select="(not(/mvc:eForm/mvc:Data/WorkitemContext/Process/ProcessVariables/primaryDWCSpecialist) or (/mvc:eForm/mvc:Data/WorkitemContext/Process/ProcessVariables/primaryDWCSpecialist = ''))" />
														<out:for-each select="/mvc:eForm/mvc:Data/DWC/record">
															<option value="{concat('[U]', MEMBERID)}">
																<out:if test="concat('[U]', MEMBERID) = /mvc:eForm/mvc:Data/WorkitemContext/Process/ProcessVariables/primaryDWCSpecialist">
																	<out:attribute name="selected">selected</out:attribute>
																</out:if>
																<out:if test="$checkDefault and (concat('[U]', MEMBERID) = 'default')">
																	<out:attribute name="selected">selected</out:attribute>
																</out:if>
																<out:value-of select="concat(NAME, ' (', EMAIL, ')')" />
															</option>
														</out:for-each>
													</select>
													<input name="GEN_DWC_SPECIALIST_xpath" type="hidden" value="/mvc:eForm/mvc:Data/WorkitemContext/Process/ProcessVariables/primaryDWCSpecialist" />
												</span>
											</span>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent">
									<div class="controlContainer labelLeft">
										<div class="controlRow">
											<span class="hide " id="GEN_PRIMARY_SPECIALIST_container">
												<span class="controlBody">
													<input class="hide " id="GEN_PRIMARY_SPECIALIST" name="GEN_PRIMARY_SPECIALIST" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_PRIMARY_SPECIALIST}" />
													<input name="GEN_PRIMARY_SPECIALIST_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_PRIMARY_SPECIALIST" />
												</span>
											</span>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent expandHeight">
									<div style="height: 21px; width: 150px;" xmlns="http://www.hyfinity.com/xfactory"></div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl " id="GEN_SECONDARY_SPECIALIST_label_container">
												<label class="label " for="GEN_SECONDARY_SPECIALIST" id="GEN_SECONDARY_SPECIALIST_label">Secondary Specialist: </label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground selectControl " id="GEN_SECONDARY_SPECIALIST_container">
												<span class="controlBody">
													<select class="select " id="GEN_SECONDARY_SPECIALIST" name="GEN_SECONDARY_SPECIALIST">
														<option value="">
															<out:text>Select One</out:text>
														</option>
														<out:variable name="checkDefault" select="(not(/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_SECONDARY_SPECIALIST) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_SECONDARY_SPECIALIST = ''))" />
														<out:for-each select="/mvc:eForm/mvc:Data/DWC/record">
															<option value="{concat('[U]', MEMBERID)}">
																<out:if test="concat('[U]', MEMBERID) = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_SECONDARY_SPECIALIST">
																	<out:attribute name="selected">selected</out:attribute>
																</out:if>
																<out:if test="$checkDefault and (concat('[U]', MEMBERID) = 'default')">
																	<out:attribute name="selected">selected</out:attribute>
																</out:if>
																<out:value-of select="concat(NAME, ' (', EMAIL, ')')" />
															</option>
														</out:for-each>
													</select>
													<input name="GEN_SECONDARY_SPECIALIST_xpath" type="hidden" value="/mvc:eForm/mvc:Data/WorkitemContext/Process/ProcessVariables/secondaryDWCSpecialist" />
												</span>
											</span>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="layoutContainerSep"></div>
						<div class="layoutContainerContent  expandWidth">
							<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="customer_info_group">
								<div class="layoutContainerContent  expandWidth">
									<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="layout_group">
										<div class="layoutContainerContent">
											<div class="controlContainer labelAbove">
												<div class="controlRow">
													<span class="labelBackground labelControl  " id="GEN_CONTACT_INFO_AUTO_label_container">
														<label class="label " for="GEN_CONTACT_INFO_AUTO" id="GEN_CONTACT_INFO_AUTO_label" style="width:248px !important;">Customer Contact Information:<span class="mandatory" id="GEN_CONTACT_INFO_AUTO_marker" style="" title="Mandatory field"> * </span>
														</label>
													</span>
												</div>
												<div class="controlRow">
													<span class="defaultBackground textboxControl  " id="GEN_CONTACT_INFO_AUTO_container">
														<span class="controlBody isMandatory">
															<input class="textbox " id="GEN_CONTACT_INFO_AUTO" name="GEN_CONTACT_INFO_AUTO" style="width : 225px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CONTACT_INFO_AUTO}" />
															<input name="GEN_CONTACT_INFO_AUTO_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CONTACT_INFO_AUTO" />
														</span>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent">
											<div class="controlContainer labelLeft">
												<div class="controlRow">
													<span class="defaultBackground buttonControl " id="delete_cust_container">
														<span class="controlBody">
															<input class="button " id="delete_cust" name="delete_cust" style="margin-top:25px; !important;" type="button" value="Clear" />
														</span>
													</span>
												</div>
											</div>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent  expandWidth">
									<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="contactInfo">
										<div class="layoutContainerContent">
											<div class="controlContainer labelAbove">
												<div class="controlRow">
													<span class="labelBackground labelControl  " id="GEN_CONTACTNAME_label_container" style="width : 215px">
														<label class="label " for="GEN_CONTACTNAME" id="GEN_CONTACTNAME_label">Contact Name</label>
													</span>
												</div>
												<div class="controlRow">
													<span class="defaultBackground outputControl  " id="GEN_CONTACTNAME_container" style="width : 297px;">
														<span class="controlBody">
															<span class="output " id="GEN_CONTACTNAME"></span>
														</span>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent">
											<div class="controlContainer labelLeft">
												<div class="controlRow">
													<span class="hide " id="GEN_CUSTCONTACT_container">
														<span class="controlBody">
															<input class="hide " id="GEN_CUSTCONTACT" name="GEN_CUSTCONTACT" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CUSTCONTACT}" />
														</span>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent">
											<div class="controlContainer labelAbove">
												<div class="controlRow">
													<span class="labelBackground labelControl alignLeft alignMiddle  " id="GEN_PHONE1_label_container">
														<label class="label " for="GEN_PHONE1" id="GEN_PHONE1_label" style="width : 325px !important;">Phone Number</label>
													</span>
												</div>
												<div class="controlRow">
													<span class="defaultBackground textboxControl  " id="GEN_PHONE1_container">
														<span class="controlBody">
															<input class="textbox " id="GEN_PHONE1" name="GEN_PHONE1" style="width : 200px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_PHONE1}" />
														</span>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent">
											<div class="controlContainer labelAbove">
												<div class="controlRow">
													<span class="labelBackground labelControl  " id="GEN_ADMIN_CODE1_label_container">
														<label class="label " for="GEN_ADMIN_CODE1" id="GEN_ADMIN_CODE1_label" style="width : 290px !important;">Admin Code</label>
													</span>
												</div>
												<div class="controlRow">
													<span class="defaultBackground outputControl  " id="GEN_ADMIN_CODE1_container" style="width : 301px;">
														<span class="controlBody">
															<span class="output " id="GEN_ADMIN_CODE1"></span>
														</span>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent">
											<div class="controlContainer labelAbove">
												<div class="controlRow">
													<span class="labelBackground labelControl " id="GEN_CUST_ORG_label_container">
														<label class="label " for="GEN_CUST_ORG" id="GEN_CUST_ORG_label">Organization</label>
													</span>
												</div>
												<div class="controlRow">
													<span class="defaultBackground outputControl " id="GEN_CUST_ORG_container">
														<span class="controlBody">
															<span class="output " id="GEN_CUST_ORG">
																<out:choose>
																	<out:when test="not(/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CUST_ORG) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CUST_ORG = '')">
																		<out:text disable-output-escaping="yes">&amp;#160;</out:text>
																	</out:when>
																	<out:otherwise>
																		<out:value-of select="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CUST_ORG" />
																	</out:otherwise>
																</out:choose>
															</span>
														</span>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent expandHeight">
											<div style="background-color:background-color:rgb(255, 165, 0);" xmlns="http://www.hyfinity.com/xfactory">
												<i class="fas fa-info-circle" />
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="layoutContainerSep"></div>
						<div class="layoutContainerContent  expandWidth">
							<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="emp_info_group">
								<div class="layoutContainerContent  expandWidth">
									<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="layout_group_3">
										<div class="layoutContainerContent">
											<div class="controlContainer labelAbove">
												<div class="controlRow">
													<span class="labelBackground labelControl  " id="GEN_EMP_INFO_AUTO_label_container">
														<label class="label " for="GEN_EMP_INFO_AUTO" id="GEN_EMP_INFO_AUTO_label">Employee Information:</label>
													</span>
												</div>
												<div class="controlRow">
													<span class="defaultBackground textboxControl " id="GEN_EMP_INFO_AUTO_container">
														<span class="controlBody">
															<input class="textbox " id="GEN_EMP_INFO_AUTO" name="GEN_EMP_INFO_AUTO" style="width : 225px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_EMP_INFO_AUTO}" />
															<input name="GEN_EMP_INFO_AUTO_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_EMP_INFO_AUTO" />
														</span>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent">
											<div class="controlContainer labelLeft">
												<div class="controlRow">
													<span class="defaultBackground buttonControl " id="delete_emp_container">
														<span class="controlBody">
															<input class="button " id="delete_emp" name="delete_emp" style="margin-top:25px;" type="button" value="Clear" />
														</span>
													</span>
												</div>
											</div>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent  expandWidth">
									<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="gen_emp_group">
										<div class="layoutContainerContent  expandWidth">
											<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="emp_info">
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl  " id="GEN_EMPNAME_label_container" style="width : 215px">
																<label class="label " for="GEN_EMPNAME" id="GEN_EMPNAME_label">Employee Name</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground outputControl  " id="GEN_EMPNAME_container" style="width : 297px;">
																<span class="controlBody">
																	<span class="output " id="GEN_EMPNAME"></span>
																</span>
															</span>
														</div>
													</div>
												</div>
												<div class="layoutContainerSep"></div>
												<div class="layoutContainerContent">
													<div class="controlContainer labelLeft">
														<div class="controlRow">
															<span class="hide " id="GEN_EMPCONTACT_container">
																<span class="controlBody">
																	<input class="hide " id="GEN_EMPCONTACT" name="GEN_EMPCONTACT" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_EMPCONTACT}" />
																	<input name="GEN_EMPCONTACT_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_EMPCONTACT" />
																</span>
															</span>
														</div>
													</div>
												</div>
												<div class="layoutContainerSep"></div>
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl alignLeft alignMiddle  " id="GEN_PHONE_2_label_container">
																<label class="label " for="GEN_PHONE_2" id="GEN_PHONE_2_label" style="width : 325px !important;">Phone Number</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground textboxControl  " id="GEN_PHONE_2_container">
																<span class="controlBody">
																	<input class="textbox " id="GEN_PHONE_2" name="GEN_PHONE_2" style="width : 200px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_PHONE_2}" />
																	<input name="GEN_PHONE_2_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_PHONE_2" />
																</span>
															</span>
														</div>
													</div>
												</div>
												<div class="layoutContainerSep"></div>
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl  " id="GEN_ADMIN_CONDE2_label_container">
																<label class="label " for="GEN_ADMIN_CONDE2" id="GEN_ADMIN_CONDE2_label" style="width : 290px !important;">Admin Code</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground outputControl  " id="GEN_ADMIN_CONDE2_container" style="width : 182px;">
																<span class="controlBody">
																	<span class="output " id="GEN_ADMIN_CONDE2"></span>
																</span>
															</span>
														</div>
													</div>
												</div>
												<div class="layoutContainerSep"></div>
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl " id="GEN_EMP_ORG_label_container">
																<label class="label " for="GEN_EMP_ORG" id="GEN_EMP_ORG_label">Organization</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground outputControl " id="GEN_EMP_ORG_container">
																<span class="controlBody">
																	<span class="output " id="GEN_EMP_ORG">
																		<out:choose>
																			<out:when test="not(/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_EMP_ORG) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_EMP_ORG = '')">
																				<out:text disable-output-escaping="yes">&amp;#160;</out:text>
																			</out:when>
																			<out:otherwise>
																				<out:value-of select="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_EMP_ORG" />
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
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent expandHeight">
											<div style="background-color:rgb(255, 165, 0);" xmlns="http://www.hyfinity.com/xfactory">
												<i class="fas fa-info-circle" />
											</div>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent  expandWidth">
									<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="admin_code_group">
										<div class="layoutContainerContent">
											<div class="controlContainer labelAbove">
												<div class="controlRow">
													<span class="labelBackground labelControl " id="GEN_CASE_DESC_label_container">
														<label class="label " for="GEN_CASE_DESC" id="GEN_CASE_DESC_label">Case Description<span class="mandatory" id="GEN_CASE_DESC_marker" style="" title="Mandatory field"> * </span>
														</label>
													</span>
												</div>
												<div class="controlRow">
													<span class="defaultBackground textareaControl " id="GEN_CASE_DESC_container">
														<span class="controlBody isMandatory">
															<textarea class="textbox " cols="100" id="GEN_CASE_DESC" name="GEN_CASE_DESC" onkeyup="hyf.textarea.adjustHeight(event, this, 2, 10);;" rows="" style="width : 855px;">
																<out:value-of select="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_DESC" />
															</textarea>
															<input name="GEN_CASE_DESC_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_DESC" />
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
							<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="case_desc_group">
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl  " id="GEN_CASE_STATUS_label_container">
												<label class="label " for="GEN_CASE_STATUS" id="GEN_CASE_STATUS_label" style="width : 242px !important;">Case Status</label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground selectControl  " id="GEN_CASE_STATUS_container" style="width : 188px;">
												<span class="controlBody">
													<select class="select " id="GEN_CASE_STATUS" name="GEN_CASE_STATUS">
														<option value="">
															<out:text>Select One</out:text>
														</option>
														<out:variable name="checkDefault" select="(not(/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_STATUS) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_STATUS = ''))" />
														<out:for-each select="/mvc:eForm/mvc:Data/lookup/record[LTYPE='ERLRInitialResponseCasesStatus' and ACTIVE='1']">
															<option value="{NAME}">
																<out:if test="NAME = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_STATUS">
																	<out:attribute name="selected">selected</out:attribute>
																</out:if>
																<out:if test="$checkDefault and (NAME = 'default')">
																	<out:attribute name="selected">selected</out:attribute>
																</out:if>
																<out:value-of select="LABEL" />
															</option>
														</out:for-each>
													</select>
													<input name="GEN_CASE_STATUS_xpath" type="hidden" value="/mvc:eForm/mvc:Data/WorkitemContext/Process/ProcessVariables/caseStatus" />
												</span>
											</span>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent expandHeight">
									<div style="height: 21px; width: 150px;"></div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl  " id="GEN_CUST_INITIAL_CONTACT_label_container">
												<label class="label " for="GEN_CUST_INITIAL_CONTACT" id="GEN_CUST_INITIAL_CONTACT_label" style="width : 318px;">Initial Contact Date<span class="mandatory" id="GEN_CUST_INITIAL_CONTACT_marker" style="" title="Mandatory field"> * </span>
												</label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground dateControl  " id="GEN_CUST_INITIAL_CONTACT_container" style="width : 309px;">
												<span class="controlBody isMandatory">
													<input class="textbox " id="GEN_CUST_INITIAL_CONTACT" name="GEN_CUST_INITIAL_CONTACT" size="10" style="width : 221px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CUST_INITIAL_CONTACT}" />
													<input name="GEN_CUST_INITIAL_CONTACT_xpath" type="hidden" value="/mvc:eForm/mvc:Data/WorkitemContext/Process/ProcessVariables/initialContactDate" />
													<script type="text/javascript">hyf.calendar.config['GEN_CUST_INITIAL_CONTACT'] = {type: 'normal', isSplitControl: false, dataFormat: 'MM/dd/yyyy', displayFormat: 'MM/dd/yyyy', hasDate: true, hasTime: false};</script>
													<a class="datePickerIcon" href="#" id="GEN_CUST_INITIAL_CONTACT_calendar_anchor" name="GEN_CUST_INITIAL_CONTACT_calendar_anchor" onclick="hyf.calendar.showCalendar('GEN_CUST_INITIAL_CONTACT');return false;"></a>
												</span>
											</span>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent  expandWidth">
									<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="layout_group_5">
										<div class="layoutContainerContent">
											<div class="controlContainer labelAbove">
												<div class="controlRow">
													<span class="labelBackground labelControl  " id="GEN_RELATEDCASENUMBER_label_container" style="width : 240px;">
														<label class="label " for="GEN_RELATEDCASENUMBER" id="GEN_RELATEDCASENUMBER_label">Add Additional Cases</label>
													</span>
												</div>
												<div class="controlRow">
													<span class="defaultBackground textboxControl  " id="GEN_RELATEDCASENUMBER_container" style="width : 240px;">
														<span class="controlBody">
															<input class="textbox " id="GEN_RELATEDCASENUMBER" maxLength="20" name="GEN_RELATEDCASENUMBER" style="width : 226px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_RELATEDCASENUMBER}" />
															<input name="GEN_RELATEDCASENUMBER_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_RELATEDCASENUMBER" />
														</span>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent expandHeight">
											<div style="font-size:14px;font-family:arial,helvetica,sans-serif;font-weight:bold;">
												<span>Related Cases</span>
												<div id="related_case"></div>
											</div>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent">
									<div class="controlContainer labelLeft">
										<div class="controlRow">
											<span class="hide " id="GEN_RELATED_TO_CASE_container">
												<span class="controlBody">
													<input class="hide " id="GEN_RELATED_TO_CASE" name="GEN_RELATED_TO_CASE" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_RELATED_TO_CASE}" />
													<input name="GEN_RELATED_TO_CASE_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_RELATED_TO_CASE" />
												</span>
											</span>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="layoutContainerSep"></div>
						<div class="layoutContainerContent  expandWidth">
							<div class="layoutContainer alignHorizontal alignLeft alignMiddle  expandWidth fitHeight " id="reps_group">
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl  " id="GEN_PRIMARY_REP_label_container" style="width : 298px;">
												<label class="label " for="GEN_PRIMARY_REP" id="GEN_PRIMARY_REP_label">Primary Representative</label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground selectControl  " id="GEN_PRIMARY_REP_container" style="width : 297px;">
												<span class="controlBody">
													<select class="select " id="GEN_PRIMARY_REP" name="GEN_PRIMARY_REP" style="width : 247px;">
														<option value="">
															<out:text>Select One</out:text>
														</option>
														<option value="cms">
															<out:if test="'cms' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_PRIMARY_REP">
																<out:attribute name="selected">selected</out:attribute>
															</out:if>
															<out:text>CMS</out:text>
														</option>
														<option value="non_cms">
															<out:if test="'non_cms' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_PRIMARY_REP">
																<out:attribute name="selected">selected</out:attribute>
															</out:if>
															<out:text>NON-CMS</out:text>
														</option>
													</select>
													<input name="GEN_PRIMARY_REP_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_PRIMARY_REP" />
												</span>
											</span>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent  expandWidth">
									<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="layout_group_4">
										<div class="layoutContainerContent  expandWidth">
											<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="non_cms_primary_group">
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl  " id="GEN_NON_CMS_PRIMARY_LNAME_label_container">
																<label class="label " for="GEN_NON_CMS_PRIMARY_LNAME" id="GEN_NON_CMS_PRIMARY_LNAME_label" style="width : 318px;">Last Name</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground textboxControl  " id="GEN_NON_CMS_PRIMARY_LNAME_container" style="width : 318px;">
																<span class="controlBody">
																	<input class="textbox " id="GEN_NON_CMS_PRIMARY_LNAME" maxLength="50" name="GEN_NON_CMS_PRIMARY_LNAME" style="width : 281px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_LNAME}" />
																	<input name="GEN_NON_CMS_PRIMARY_LNAME_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_LNAME" />
																</span>
															</span>
														</div>
													</div>
												</div>
												<div class="layoutContainerSep"></div>
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl  " id="GEN_NON_CMS_PRIMARY_fNAME_label_container" style="width : 271px;">
																<label class="label " for="GEN_NON_CMS_PRIMARY_fNAME" id="GEN_NON_CMS_PRIMARY_fNAME_label">First Name</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground textboxControl  " id="GEN_NON_CMS_PRIMARY_fNAME_container" style="width : 271px;">
																<span class="controlBody">
																	<input class="textbox " id="GEN_NON_CMS_PRIMARY_fNAME" name="GEN_NON_CMS_PRIMARY_fNAME" style="width : 223px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_fNAME}" />
																	<input name="GEN_NON_CMS_PRIMARY_fNAME_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_fNAME" />
																</span>
															</span>
														</div>
													</div>
												</div>
												<div class="layoutContainerSep"></div>
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl " id="GEN_NON_CMS_PRIMARY_MNAME_label_container">
																<label class="label " for="GEN_NON_CMS_PRIMARY_MNAME" id="GEN_NON_CMS_PRIMARY_MNAME_label">Middle Name</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground textboxControl " id="GEN_NON_CMS_PRIMARY_MNAME_container">
																<span class="controlBody">
																	<input class="textbox " id="GEN_NON_CMS_PRIMARY_MNAME" maxLength="50" name="GEN_NON_CMS_PRIMARY_MNAME" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_MNAME}" />
																	<input name="GEN_NON_CMS_PRIMARY_MNAME_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_MNAME" />
																</span>
															</span>
														</div>
													</div>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent  expandWidth">
											<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="cms_rep_name_group">
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl  " id="GEN_CMS_PRIMARY_REP_label_container" style="width : 633px;">
																<label class="label " for="GEN_CMS_PRIMARY_REP" id="GEN_CMS_PRIMARY_REP_label">Primary Representative Name</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground textboxControl  " id="GEN_CMS_PRIMARY_REP_container" style="height : 30px; width : 571px;">
																<span class="controlBody">
																	<input class="textbox " id="GEN_CMS_PRIMARY_REP" name="GEN_CMS_PRIMARY_REP" style="width : 555px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CMS_PRIMARY_REP}" />
																	<input name="GEN_CMS_PRIMARY_REP_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CMS_PRIMARY_REP" />
																</span>
															</span>
														</div>
													</div>
												</div>
												<div class="layoutContainerSep"></div>
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl " id="GEN_PRIMARY_REP_PHONE_label_container">
																<label class="label " for="GEN_PRIMARY_REP_PHONE" id="GEN_PRIMARY_REP_PHONE_label">Phone</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground textboxControl " id="GEN_PRIMARY_REP_PHONE_container">
																<span class="controlBody">
																	<input class="textbox " id="GEN_PRIMARY_REP_PHONE" name="GEN_PRIMARY_REP_PHONE" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_PRIMARY_REP_PHONE}" />
																	<input name="GEN_PRIMARY_REP_PHONE_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_PRIMARY_REP_PHONE" />
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
						<div class="layoutContainerSep"></div>
						<div class="layoutContainerContent  expandWidth">
							<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="non_cms_primary_group2">
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl  " id="GEN_NON_CMS_PRIMARY_EMAIL_label_container" style="width : 298px;">
												<label class="label " for="GEN_NON_CMS_PRIMARY_EMAIL" id="GEN_NON_CMS_PRIMARY_EMAIL_label">Email Address</label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground textboxControl  " id="GEN_NON_CMS_PRIMARY_EMAIL_container" style="width : 295px;">
												<span class="controlBody">
													<input class="textbox " id="GEN_NON_CMS_PRIMARY_EMAIL" maxLength="100" name="GEN_NON_CMS_PRIMARY_EMAIL" style="width : 258px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_EMAIL}" />
													<input name="GEN_NON_CMS_PRIMARY_EMAIL_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_EMAIL" />
												</span>
											</span>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl  " id="GEN_NON_CMS_PRIMARY_PHONE_label_container">
												<label class="label " for="GEN_NON_CMS_PRIMARY_PHONE" id="GEN_NON_CMS_PRIMARY_PHONE_label" style="width : 300px;">Phone Number</label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground textboxControl  " id="GEN_NON_CMS_PRIMARY_PHONE_container" style="width : 341px;">
												<span class="controlBody">
													<input class="textbox " id="GEN_NON_CMS_PRIMARY_PHONE" maxLength="50" name="GEN_NON_CMS_PRIMARY_PHONE" style="width : 280px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_PHONE}" />
													<input name="GEN_NON_CMS_PRIMARY_PHONE_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_PHONE" />
												</span>
											</span>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl  " id="GEN_NON_CMS_PRIMARY_ORG_label_container" style="width : 271px;">
												<label class="label " for="GEN_NON_CMS_PRIMARY_ORG" id="GEN_NON_CMS_PRIMARY_ORG_label">Organization Affiliation</label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground textboxControl  " id="GEN_NON_CMS_PRIMARY_ORG_container" style="width : 270px;">
												<span class="controlBody">
													<input class="textbox " id="GEN_NON_CMS_PRIMARY_ORG" maxLength="100" name="GEN_NON_CMS_PRIMARY_ORG" style="width : 224px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_ORG}" />
													<input name="GEN_NON_CMS_PRIMARY_ORG_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_ORG" />
												</span>
											</span>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl " id="GEN_NON_CMS_PRIMARY_ADDR_label_container">
												<label class="label " for="GEN_NON_CMS_PRIMARY_ADDR" id="GEN_NON_CMS_PRIMARY_ADDR_label">Mailing Address</label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground textboxControl " id="GEN_NON_CMS_PRIMARY_ADDR_container">
												<span class="controlBody">
													<input class="textbox " id="GEN_NON_CMS_PRIMARY_ADDR" maxLength="250" name="GEN_NON_CMS_PRIMARY_ADDR" style="width : 217px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_ADDR}" />
													<input name="GEN_NON_CMS_PRIMARY_ADDR_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_NON_CMS_PRIMARY_ADDR" />
												</span>
											</span>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div class="layoutContainerSep"></div>
						<div class="layoutContainerContent  expandWidth">
							<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="related_case_group">
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl  " id="GEN_CASE_TYPE_label_container" style="width : 298px;">
												<label class="label " for="GEN_CASE_TYPE" id="GEN_CASE_TYPE_label">Case Type</label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground selectControl  " id="GEN_CASE_TYPE_container" style="width : 297px;">
												<span class="controlBody">
													<select class="select CompleteCase_dynamic_require " id="GEN_CASE_TYPE" name="GEN_CASE_TYPE" style="width : 247px;">
														<option value="">
															<out:text>Select One</out:text>
														</option>
														<out:variable name="checkDefault" select="(not(/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_TYPE) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_TYPE = ''))" />
														<out:for-each select="/mvc:eForm/mvc:Data/lookup/record[LTYPE='ERLRInitialResponseCaseTpe' and ACTIVE='1']">
															<option value="{NAME}">
																<out:if test="NAME = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_TYPE">
																	<out:attribute name="selected">selected</out:attribute>
																</out:if>
																<out:if test="$checkDefault and (NAME = 'default')">
																	<out:attribute name="selected">selected</out:attribute>
																</out:if>
																<out:value-of select="LABEL" />
															</option>
														</out:for-each>
													</select>
													<input name="GEN_CASE_TYPE_xpath" type="hidden" value="/mvc:eForm/mvc:Data/WorkitemContext/Process/ProcessVariables/caseType" />
												</span>
											</span>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent">
									<div class="controlContainer labelAbove">
										<div class="controlRow">
											<span class="labelBackground labelControl  " id="GEN_CASE_CATEGORY_label_container" style="width : 297px;">
												<label class="label " for="GEN_CASE_CATEGORY" id="GEN_CASE_CATEGORY_label">Case Category</label>
											</span>
										</div>
										<div class="controlRow">
											<span class="defaultBackground selectControl  " id="GEN_CASE_CATEGORY_container" style="width : 297px;">
												<span class="controlBody">
													<select class="select CompleteCase_dynamic_require " id="GEN_CASE_CATEGORY" name="GEN_CASE_CATEGORY" style="width : 287px;">
														<option value="">
															<out:text>Select One</out:text>
														</option>
														<option value="cat_1">
															<out:if test="'cat_1' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_CATEGORY">
																<out:attribute name="selected">selected</out:attribute>
															</out:if>
															<out:text>Category 1</out:text>
														</option>
														<option value="cat_2">
															<out:if test="'cat_2' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_CATEGORY">
																<out:attribute name="selected">selected</out:attribute>
															</out:if>
															<out:text>Category 2</out:text>
														</option>
														<option value="cat_3">
															<out:if test="'cat_3' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_CATEGORY">
																<out:attribute name="selected">selected</out:attribute>
															</out:if>
															<out:text>Category 3</out:text>
														</option>
													</select>
													<input name="GEN_CASE_CATEGORY_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_CASE_CATEGORY" />
												</span>
											</span>
										</div>
									</div>
								</div>
								<div class="layoutContainerSep"></div>
								<div class="layoutContainerContent  expandWidth">
									<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="selected_case_cats">
										<div class="layoutContainerContent expandWidth">
											<div class="customControl" id="case_cat_selection" xmlns="http://www.hyfinity.com/xfactory">
												<label>Selected Items</label>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent">
											<div class="controlContainer labelRight">
												<div class="controlRow">
													<span class="defaultBackground checkboxControl " id="cat_1_container">
														<span class="controlBody">
															<input class="checkbox " id="cat_1" name="cat_1" type="checkbox" value="true">
																<out:if test="'true' = /mvc:eForm/mvc:Data/mvc:formData/mvc:cat_1">
																	<out:attribute name="checked">checked</out:attribute>
																</out:if>
															</input>
															<input name="cat_1_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:cat_1" />
															<input id="cat_1_value_if_not_submitted" name="cat_1_value_if_not_submitted" type="hidden" value="false" />
														</span>
													</span>
													<span class="labelBackground labelControl " id="cat_1_label_container">
														<label class="label " for="cat_1" id="cat_1_label">Category 1</label>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent">
											<div class="controlContainer labelRight">
												<div class="controlRow">
													<span class="defaultBackground checkboxControl " id="cat_2_container">
														<span class="controlBody">
															<input class="checkbox " id="cat_2" name="cat_2" type="checkbox" value="true">
																<out:if test="'true' = /mvc:eForm/mvc:Data/mvc:formData/mvc:cat_2">
																	<out:attribute name="checked">checked</out:attribute>
																</out:if>
															</input>
															<input name="cat_2_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:cat_2" />
															<input id="cat_2_value_if_not_submitted" name="cat_2_value_if_not_submitted" type="hidden" value="false" />
														</span>
													</span>
													<span class="labelBackground labelControl " id="cat_2_label_container">
														<label class="label " for="cat_2" id="cat_2_label">Category 2</label>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent">
											<div class="controlContainer labelRight">
												<div class="controlRow">
													<span class="defaultBackground checkboxControl " id="cat_3_container">
														<span class="controlBody">
															<input class="checkbox " id="cat_3" name="cat_3" type="checkbox" value="true">
																<out:if test="'true' = /mvc:eForm/mvc:Data/mvc:formData/mvc:cat_3">
																	<out:attribute name="checked">checked</out:attribute>
																</out:if>
															</input>
															<input name="cat_3_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:cat_3" />
															<input id="cat_3_value_if_not_submitted" name="cat_3_value_if_not_submitted" type="hidden" value="false" />
														</span>
													</span>
													<span class="labelBackground labelControl " id="cat_3_label_container">
														<label class="label " for="cat_3" id="cat_3_label">Category 3</label>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent">
											<div class="controlContainer labelLeft">
												<div class="controlRow">
													<span class="hide " id="selected_category_container">
														<span class="controlBody">
															<input class="hide " id="selected_category" name="selected_category" type="hidden" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:selected_category}" />
															<input name="selected_category_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:selected_category" />
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
							<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="caseTypeHidden">
								<div class="layoutContainerContent  expandWidth">
									<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="investigation_group">
										<div class="layoutContainerContent">
											<div class="controlContainer labelAbove">
												<div class="controlRow">
													<span class="labelBackground labelControl  " id="GEN_INVESTIGATION_label_container" style="width : 298px;">
														<label class="label " for="GEN_INVESTIGATION" id="GEN_INVESTIGATION_label">Investigation Conducted?</label>
													</span>
												</div>
												<div class="controlRow">
													<span class="defaultBackground selectControl  " id="GEN_INVESTIGATION_container" style="width : 297px;">
														<span class="controlBody">
															<select class="select " id="GEN_INVESTIGATION" name="GEN_INVESTIGATION" style="width : 247px;">
																<option value="">
																	<out:text>Select One</out:text>
																</option>
																<option value="Y">
																	<out:if test="'Y' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_INVESTIGATION">
																		<out:attribute name="selected">selected</out:attribute>
																	</out:if>
																	<out:text>Yes</out:text>
																</option>
																<option value="N">
																	<out:if test="'N' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_INVESTIGATION">
																		<out:attribute name="selected">selected</out:attribute>
																	</out:if>
																	<out:text>No</out:text>
																</option>
															</select>
															<input name="GEN_INVESTIGATION_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_INVESTIGATION" />
														</span>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent  expandWidth">
											<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="primary_start_end_date">
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl  " id="GEN_START_DT_label_container" style="width : 298px;">
																<label class="label " for="GEN_START_DT" id="GEN_START_DT_label" style="width:180px">Start Date<span class="mandatory" id="GEN_START_DT_marker" style="" title="Mandatory field"> * </span>
																</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground dateControl  " id="GEN_START_DT_container" style="width : 338px;">
																<span class="controlBody isMandatory">
																	<input class="textbox " id="GEN_START_DT" name="GEN_START_DT" size="10" style="width : 279px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_START_DT}" />
																	<input name="GEN_START_DT_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_START_DT" />
																	<script type="text/javascript">hyf.calendar.config['GEN_START_DT'] = {type: 'normal', isSplitControl: false, dataFormat: 'MM/dd/yyyy', displayFormat: 'MM/dd/yyyy', hasDate: true, hasTime: false};</script>
																	<a class="datePickerIcon" href="#" id="GEN_START_DT_calendar_anchor" name="GEN_START_DT_calendar_anchor" onclick="hyf.calendar.showCalendar('GEN_START_DT');return false;"></a>
																</span>
															</span>
														</div>
													</div>
												</div>
												<div class="layoutContainerSep"></div>
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl " id="GEN_END_DT_label_container">
																<label class="label " for="GEN_END_DT" id="GEN_END_DT_label" style="width:290px">End Date</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground dateControl " id="GEN_END_DT_container">
																<span class="controlBody">
																	<input class="textbox " id="GEN_END_DT" name="GEN_END_DT" size="10" style="width : 184px;" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_END_DT}" />
																	<input name="GEN_END_DT_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_END_DT" />
																	<script type="text/javascript">hyf.calendar.config['GEN_END_DT'] = {type: 'normal', isSplitControl: false, dataFormat: 'MM/dd/yyyy', displayFormat: 'MM/dd/yyyy', hasDate: true, hasTime: false};</script>
																	<a class="datePickerIcon" href="#" id="GEN_END_DT_calendar_anchor" name="GEN_END_DT_calendar_anchor" onclick="hyf.calendar.showCalendar('GEN_END_DT');return false;"></a>
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
									<div class="layoutContainer alignHorizontal alignLeft alignTop  expandWidth fitHeight " id="stdConduct">
										<div class="layoutContainerContent">
											<div class="controlContainer labelAbove">
												<div class="controlRow">
													<span class="labelBackground labelControl  " id="GEN_STD_CONDUCT_label_container" style="width : 298px;">
														<label class="label " for="GEN_STD_CONDUCT" id="GEN_STD_CONDUCT_label">Involves a Standards of Conduct?</label>
													</span>
												</div>
												<div class="controlRow">
													<span class="defaultBackground selectControl  " id="GEN_STD_CONDUCT_container" style="width : 297px;">
														<span class="controlBody">
															<select class="select " id="GEN_STD_CONDUCT" name="GEN_STD_CONDUCT" style="width : 247px;">
																<option value="">
																	<out:text>Select One</out:text>
																</option>
																<option value="Y">
																	<out:if test="'Y' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT">
																		<out:attribute name="selected">selected</out:attribute>
																	</out:if>
																	<out:text>Yes</out:text>
																</option>
																<option value="N">
																	<out:if test="'N' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT">
																		<out:attribute name="selected">selected</out:attribute>
																	</out:if>
																	<out:text>No</out:text>
																</option>
															</select>
															<input name="GEN_STD_CONDUCT_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT" />
														</span>
													</span>
												</div>
											</div>
										</div>
										<div class="layoutContainerSep"></div>
										<div class="layoutContainerContent  expandWidth">
											<div class="layoutContainer alignVertical alignLeft alignTop  expandWidth fitHeight " id="conduct_type_group">
												<div class="layoutContainerContent">
													<div class="controlContainer labelAbove">
														<div class="controlRow">
															<span class="labelBackground labelControl  " id="GEN_STD_CONDUCT_TYPE_label_container" style="width : 308px;">
																<label class="label " for="GEN_STD_CONDUCT_TYPE" id="GEN_STD_CONDUCT_TYPE_label">Standards of Conduct Type<span class="mandatory" id="GEN_STD_CONDUCT_TYPE_marker" style="" title="Mandatory field"> * </span>
																</label>
															</span>
														</div>
														<div class="controlRow">
															<span class="defaultBackground selectControl  " id="GEN_STD_CONDUCT_TYPE_container" style="width : 308px;">
																<span class="controlBody isMandatory">
																	<select class="select " id="GEN_STD_CONDUCT_TYPE" name="GEN_STD_CONDUCT_TYPE" style="width : 290px;">
																		<option value="">
																			<out:text>Select One</out:text>
																		</option>
																		<option value="alcohol">
																			<out:if test="'alcohol' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Alcohol/Drugs</out:text>
																		</option>
																		<option value="conflict_of_interest">
																			<out:if test="'conflict_of_interest' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Conflict of Interest</out:text>
																		</option>
																		<option value="disclosure">
																			<out:if test="'disclosure' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Disclosure of Confidential Information</out:text>
																		</option>
																		<option value="no_public_info">
																			<out:if test="'no_public_info' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Disclosure of Non-Public Information</out:text>
																		</option>
																		<option value="impartiality">
																			<out:if test="'impartiality' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Failure to Maintain Impartiality</out:text>
																		</option>
																		<option value="pay_debt">
																			<out:if test="'pay_debt' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Failure to Timely Pay Debts</out:text>
																		</option>
																		<option value="Gifts">
																			<out:if test="'Gifts' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Gifts</out:text>
																		</option>
																		<option value="Hatch_Act_Violation">
																			<out:if test="'Hatch_Act_Violation' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Hatch Act Violation</out:text>
																		</option>
																		<option value="lack_of_courtesy">
																			<out:if test="'lack_of_courtesy' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Lack of Courtesy/Disrespect</out:text>
																		</option>
																		<option value="misuse">
																			<out:if test="'misuse' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Misuse of Gov't Position</out:text>
																		</option>
																		<option value="misuse_gov_propert">
																			<out:if test="'misuse_gov_propert' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Misuse of Gov't Property</out:text>
																		</option>
																		<option value="misuse_gov_time">
																			<out:if test="'misuse_gov_time' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Misuse of Gov't Time</out:text>
																		</option>
																		<option value="Outside_Activity">
																			<out:if test="'Outside_Activity' = /mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE">
																				<out:attribute name="selected">selected</out:attribute>
																			</out:if>
																			<out:text>Outside Activity</out:text>
																		</option>
																	</select>
																	<input name="GEN_STD_CONDUCT_TYPE_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:GEN_STD_CONDUCT_TYPE" />
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
</xform:xform>		<script type="text/javascript" xmlns="">
<xsl:for-each select="." xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:mvc="http://www.hyfinity.com/mvc">			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_DWC_SPECIALIST</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_PRIMARY_SPECIALIST</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_SECONDARY_SPECIALIST</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_CONTACT_INFO_AUTO</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>delete_cust</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_CONTACTNAME</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_CUSTCONTACT</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_PHONE1</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_ADMIN_CODE1</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_CUST_ORG</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_EMP_INFO_AUTO</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>delete_emp</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_EMPNAME</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_EMPCONTACT</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_PHONE_2</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_ADMIN_CONDE2</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_EMP_ORG</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_CASE_DESC</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_maxLength','500');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_minLength','1');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('maxLength', '500');</out:text>
			<out:text>field.onkeyup();</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_CASE_STATUS</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_CUST_INITIAL_CONTACT</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_data_date_format','MM/dd/yyyy');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_display_date_format','MM/dd/yyyy');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','date');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_RELATEDCASENUMBER</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_maxLength','20');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_RELATED_TO_CASE</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_PRIMARY_REP</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_NON_CMS_PRIMARY_LNAME</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_maxLength','50');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_NON_CMS_PRIMARY_fNAME</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_NON_CMS_PRIMARY_MNAME</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_maxLength','50');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_CMS_PRIMARY_REP</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_PRIMARY_REP_PHONE</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_NON_CMS_PRIMARY_EMAIL</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_maxLength','100');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_NON_CMS_PRIMARY_PHONE</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_maxLength','50');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_NON_CMS_PRIMARY_ORG</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_maxLength','100');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_NON_CMS_PRIMARY_ADDR</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_maxLength','250');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_CASE_TYPE</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('completeCase_dynamic_require', 'true');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_CASE_CATEGORY</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('completeCase_dynamic_require', 'true');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>cat_1</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>cat_2</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>cat_3</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>selected_category</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_INVESTIGATION</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_START_DT</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_data_date_format','MM/dd/yyyy');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_display_date_format','MM/dd/yyyy');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','date');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_END_DT</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_data_date_format','MM/dd/yyyy');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_display_date_format','MM/dd/yyyy');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','date');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_STD_CONDUCT</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>GEN_STD_CONDUCT_TYPE</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
<xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">if (!document.getElementById('calendarDiv')) { var calendarDiv = document.createElement('div');calendarDiv.setAttribute('id', 'calendarDiv');document.body.appendChild(calendarDiv); } </xsl:text></xsl:for-each>		</script>
	</out:template>
</out:stylesheet>
