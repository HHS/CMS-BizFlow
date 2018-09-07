<?xml version="1.0" encoding="UTF-8"?>
<out:stylesheet exclude-result-prefixes="fm" version="1.0" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:out="http://www.w3.org/1999/XSL/Transform">
	<!--Some information has been retained from the existing file!-->
	<out:import href="conversions.xsl" />
	<out:output encoding="UTF-8" indent="yes" method="xml" />
	<out:template name="section_title">Case_Completed</out:template>
	<out:template name="page_meta_tags">
		<!--Insert any required page specific meta tags in here-->
	</out:template>
	<out:template match="/">
		<div class="subsection_container" id="subsection_Case_Completed" xmlns="">
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
							<table border="0" cellpadding="0" cellspacing="0" class="grid  expandWidth fitHeight " id="one_column_grid" summary="">
								<tr>
									<td class="layoutContainerWrapper  fitHeight " id="one_column_1" style="width:100%;">
										<div class="layoutContainer alignVertical alignLeft alignTop ">
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl " id="casefile_num_label_container">
															<label class="label " for="casefile_num" id="casefile_num_label">EWITS Casefile Number:</label>
														</span>
														<span class="defaultBackground outputControl " id="casefile_num_container">
															<span class="controlBody">
																<span class="output " id="casefile_num">12345</span>
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl alignLeft alignMiddle " id="contact_label_container">
															<label class="label " for="contact" id="contact_label">Contact Name: </label>
														</span>
														<span class="defaultBackground textboxControl " id="contact_container">
															<span class="controlBody">
																<input class="textbox " id="contact" name="contact" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:contact}" />
																<input name="contact_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:contact" />
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl alignLeft alignMiddle " id="emp_name_label_container">
															<label class="label " for="emp_name" id="emp_name_label">Employee Name:</label>
														</span>
														<span class="defaultBackground textboxControl " id="emp_name_container">
															<span class="controlBody">
																<input class="textbox " id="emp_name" name="emp_name" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:emp_name}" />
																<input name="emp_name_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:emp_name" />
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl alignLeft alignMiddle " id="org_assign_label_container">
															<label class="label " for="org_assign" id="org_assign_label">Organization Assignment:</label>
														</span>
														<span class="defaultBackground selectControl " id="org_assign_container">
															<span class="controlBody">
																<select class="select " id="org_assign" name="org_assign">
																	<option value="ListItem1">
																		<out:if test="'ListItem1' = /mvc:eForm/mvc:Data/mvc:formData/mvc:org_assign">
																			<out:attribute name="selected">selected</out:attribute>
																		</out:if>
																		<out:text>List Item 1</out:text>
																	</option>
																	<option value="ListItem2">
																		<out:if test="'ListItem2' = /mvc:eForm/mvc:Data/mvc:formData/mvc:org_assign">
																			<out:attribute name="selected">selected</out:attribute>
																		</out:if>
																		<out:text>List Item 2</out:text>
																	</option>
																	<option value="ListItem3">
																		<out:if test="'ListItem3' = /mvc:eForm/mvc:Data/mvc:formData/mvc:org_assign">
																			<out:attribute name="selected">selected</out:attribute>
																		</out:if>
																		<out:text>List Item 3</out:text>
																	</option>
																</select>
																<input name="org_assign_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:org_assign" />
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl alignLeft alignMiddle " id="case_desc_label_container">
															<label class="label " for="case_desc" id="case_desc_label">Case Description:</label>
														</span>
														<span class="defaultBackground textareaControl " id="case_desc_container">
															<span class="controlBody">
																<textarea class="textbox " cols="40" id="case_desc" name="case_desc" onkeyup="hyf.textarea.adjustHeight(event, this, 2, 10);;" rows="">
																	<out:value-of select="/mvc:eForm/mvc:Data/mvc:formData/mvc:case_desc" />
																</textarea>
																<input name="case_desc_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:case_desc" />
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl alignLeft alignMiddle " id="doc_log_label_container">
															<label class="label " for="doc_log" id="doc_log_label">Document Log</label>
														</span>
														<span class="defaultBackground textareaControl " id="doc_log_container">
															<span class="controlBody">
																<textarea class="textbox " cols="40" id="doc_log" name="doc_log" onkeyup="hyf.textarea.adjustHeight(event, this, 2, 10);;" rows="">
																	<out:value-of select="/mvc:eForm/mvc:Data/mvc:formData/mvc:doc_log" />
																</textarea>
																<input name="doc_log_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:doc_log" />
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl " id="case_status_label_container">
															<label class="label " for="case_status" id="case_status_label">Case Status: </label>
														</span>
														<span class="defaultBackground textboxControl " id="case_status_container">
															<span class="controlBody">
																<input class="textbox " id="case_status" name="case_status" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:case_status}" />
																<input name="case_status_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:case_status" />
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl " id="desc_of_final_action_label_container">
															<label class="label " for="desc_of_final_action" id="desc_of_final_action_label">Description of Final action:</label>
														</span>
														<span class="defaultBackground selectControl " id="desc_of_final_action_container">
															<span class="controlBody">
																<select class="select " id="desc_of_final_action" name="desc_of_final_action">
																	<option value="ListItem1">
																		<out:if test="'ListItem1' = /mvc:eForm/mvc:Data/mvc:formData/mvc:desc_of_final_action">
																			<out:attribute name="selected">selected</out:attribute>
																		</out:if>
																		<out:text>List Item 1</out:text>
																	</option>
																	<option value="ListItem2">
																		<out:if test="'ListItem2' = /mvc:eForm/mvc:Data/mvc:formData/mvc:desc_of_final_action">
																			<out:attribute name="selected">selected</out:attribute>
																		</out:if>
																		<out:text>List Item 2</out:text>
																	</option>
																	<option value="ListItem3">
																		<out:if test="'ListItem3' = /mvc:eForm/mvc:Data/mvc:formData/mvc:desc_of_final_action">
																			<out:attribute name="selected">selected</out:attribute>
																		</out:if>
																		<out:text>List Item 3</out:text>
																	</option>
																</select>
																<input name="desc_of_final_action_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:desc_of_final_action" />
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl " id="length_of_suspension_proposed_label_container">
															<label class="label " for="length_of_suspension_proposed" id="length_of_suspension_proposed_label">Propose length of suspension in Days: </label>
														</span>
														<span class="defaultBackground textboxControl " id="length_of_suspension_proposed_container">
															<span class="controlBody">
																<input class="textbox " id="length_of_suspension_proposed" name="length_of_suspension_proposed" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:length_of_suspension_proposed}" />
																<input name="length_of_suspension_proposed_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:length_of_suspension_proposed" />
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl " id="suspension_days_label_container">
															<label class="label " for="suspension_days" id="suspension_days_label">Length of Suspension in Days:</label>
														</span>
														<span class="defaultBackground textboxControl " id="suspension_days_container">
															<span class="controlBody">
																<input class="textbox " id="suspension_days" name="suspension_days" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:suspension_days}" />
																<input name="suspension_days_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:suspension_days" />
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl " id="completed_dt_label_container">
															<label class="label " for="completed_dt" id="completed_dt_label">Date Case completed: </label>
														</span>
														<span class="defaultBackground dateControl " id="completed_dt_container">
															<span class="controlBody">
																<input class="textbox " id="completed_dt" name="completed_dt" size="10" type="text" value="{/mvc:eForm/mvc:Data/mvc:formData/mvc:completed_dt}">
																	<out:attribute name="value">
																		<out:if test="(/mvc:eForm/mvc:Data/mvc:formData/mvc:completed_dt != '')">
																			<out:call-template name="parse-format-date">
																				<out:with-param name="source_string" select="/mvc:eForm/mvc:Data/mvc:formData/mvc:completed_dt" />
																				<out:with-param name="source_pattern">yyyy-MM-dd</out:with-param>
																				<out:with-param name="target_pattern">MM/dd/yyyy</out:with-param>
																			</out:call-template>
																		</out:if>
																	</out:attribute>
																</input>
																<input name="completed_dt_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:completed_dt" />
																<script type="text/javascript">hyf.calendar.config['completed_dt'] = {type: 'normal', isSplitControl: false, dataFormat: 'yyyy-MM-dd', displayFormat: 'MM/dd/yyyy', hasDate: true, hasTime: false};</script>
																<a class="datePickerIcon" href="#" id="completed_dt_calendar_anchor" name="completed_dt_calendar_anchor" onclick="hyf.calendar.showCalendar('completed_dt');return false;"></a>
																<input name="completed_dt_date_conversion_input" type="hidden" value="MM/dd/yyyy" />
																<input name="completed_dt_date_conversion_output" type="hidden" value="yyyy-MM-dd" />
															</span>
														</span>
													</div>
												</div>
											</div>
											<div class="layoutContainerSep"></div>
											<div class="layoutContainerContent">
												<div class="controlContainer labelLeft">
													<div class="controlRow">
														<span class="labelBackground labelControl " id="note_txt_label_container">
															<label class="label " for="note_txt" id="note_txt_label">PLEASE NOTE:</label>
														</span>
														<span class="defaultBackground outputControl " id="note_txt_container">
															<span class="controlBody">
																<span class="output " id="note_txt">This is the last step for this case. After this step is completed the case will be moved to archive and no further modification will be possible. Are you sure?</span>
															</span>
														</span>
													</div>
												</div>
											</div>
										</div>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
</xform:xform>		<script type="text/javascript" xmlns="">
<xsl:for-each select="." xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:mvc="http://www.hyfinity.com/mvc">			<out:text>
            field = document.getElementById('</out:text>
			<out:text>casefile_num</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>contact</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>emp_name</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>org_assign</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>case_desc</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>field.onkeyup();</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>doc_log</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>field.onkeyup();</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>case_status</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>desc_of_final_action</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>length_of_suspension_proposed</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>suspension_days</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>completed_dt</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_data_date_format','yyyy-MM-dd');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_display_date_format','MM/dd/yyyy');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','date');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>note_txt</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_use','output');</out:text>
<xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">if (!document.getElementById('calendarDiv')) { var calendarDiv = document.createElement('div');calendarDiv.setAttribute('id', 'calendarDiv');document.body.appendChild(calendarDiv); } </xsl:text></xsl:for-each>		</script>
	</out:template>
</out:stylesheet>
