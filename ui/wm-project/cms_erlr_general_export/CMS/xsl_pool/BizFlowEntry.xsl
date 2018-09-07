<?xml version="1.0" encoding="UTF-8"?>
<out:stylesheet exclude-result-prefixes="fm" version="1.0" xmlns="http://www.hyfinity.com/xstore" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:out="http://www.w3.org/1999/XSL/Transform">
	<!--Some information has been retained from the existing file!-->
	<out:import href="demo_skin.xsl" />
	<out:output encoding="UTF-8" indent="yes" method="xml" />
	<out:template name="section_title">DummyStart</out:template>
	<out:template name="page_meta_tags">
		<!--Insert any required page specific meta tags in here-->
	</out:template>
	<out:template name="css_imports">
		<link href="css/webmaker_layout.css" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;!--[if lte IE 7]&gt;</out:text>
		<link href="css/webmaker_layout_ie_6_7.css" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;![endif]--&gt;</out:text>
		<link href="theme/bizflow_default/css/theme.css" rel="stylesheet" type="text/css" />
		<out:text disable-output-escaping="yes">&lt;!--[if lte IE 8]&gt;</out:text>
		<link href="theme/bizflow_default/css/theme_ie8.css" rel="stylesheet" type="text/css" />
		<out:text disable-output-escaping="yes">&lt;![endif]--&gt;</out:text>
		<link href="theme/bizflow_default/css/print_completed.css" media="print" rel="stylesheet" type="text/css" />
		<link href="theme/bizflow_default/css/theme_mobile.css" media="only screen and (max-width: 1024px)" rel="stylesheet" type="text/css" />
	</out:template>
	<out:template name="page_scripts" />
	<out:template name="section_body">
<xform:xform xmlns:xform="http://www.w3.org/2001/08/xforms" xmlns="" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:impl="http://handysoft.com/webservice/HWWorkitem" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:ns1="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="http://service.je.wf.bf.hs.com" xmlns:tns="http://handysoft.com/webservice/ServiceConstructor" xmlns:xg="http://www.hyfinity.com/xgate" >		<xform:instance id="initial_response_xga_case_completedX" xmlns:xform="http://www.w3.org/2001/08/xforms">
			<eForm xmlns="http://www.hyfinity.com/mvc" xmlns:mvc="http://www.hyfinity.com/mvc">
				<Control>
					<Page />
					<Controller />
				</Control>
				<Data>
					<formData>
						<sessioninfo />
						<procid />
						<actseq />
						<workseq />
						<appseq />
						<isarchive />
						<readOnly />
						<secondary_specialist />
						<length_of_suspension_proposed />
						<suspension_days />
						<desc_of_final_action />
						<completed_dt />
						<dwc_specialist />
						<contact_info_auto />
						<emp_info_auto />
						<case_desc />
						<date_customer_contacted />
						<relatedCaseNumber />
						<case_type />
						<case_category />
						<cms_primary_rep />
						<investigation />
						<start_date />
						<std_conduct />
						<std_conduct_type />
						<end_date />
						<custContact />
						<empContact />
						<primary_rep />
						<non_cms_primary_last_name />
						<non_cms_primary_first_name />
						<non_cms_primary_middle_name />
						<non_cms_primary_email />
						<non_cms_primary_phone />
						<non_cms_primary_org />
						<non_cms_primary_mailing_addr />
						<primary_specialist />
						<related_to_case />
						<cat_1 />
						<cat_2 />
						<cat_3 />
						<selected_category />
						<case_status />
					</formData>
				</Data>
			</eForm>
		</xform:instance>
		<xform:instance id="conduct_issue" xmlns:xform="http://www.w3.org/2001/08/xforms">
			<eForm xmlns="http://www.hyfinity.com/mvc" xmlns:mvc="http://www.hyfinity.com/mvc">
				<Control>
					<Page />
					<Controller />
				</Control>
				<Data>
					<formData>
						<secondary_specialist />
						<length_of_suspension_proposed />
						<suspension_days />
						<desc_of_final_action />
						<completed_dt />
						<dwc_specialist />
						<contact_info_auto />
						<emp_info_auto />
						<case_desc />
						<date_customer_contacted />
						<relatedCaseNumber />
						<case_type />
						<case_category />
						<cms_primary_rep />
						<investigation />
						<start_date />
						<std_conduct />
						<std_conduct_type />
						<end_date />
						<custContact />
						<empContact />
						<primary_rep />
						<non_cms_primary_last_name />
						<non_cms_primary_first_name />
						<non_cms_primary_middle_name />
						<non_cms_primary_email />
						<non_cms_primary_phone />
						<non_cms_primary_org />
						<non_cms_primary_mailing_addr />
						<primary_specialist />
						<related_to_case />
						<cat_1 />
						<cat_2 />
						<cat_3 />
						<selected_category />
						<case_status />
					</formData>
				</Data>
			</eForm>
		</xform:instance>
		<xform:instance id="conduct_issue1" xmlns:xform="http://www.w3.org/2001/08/xforms">
			<eForm xmlns="http://www.hyfinity.com/mvc" xmlns:mvc="http://www.hyfinity.com/mvc">
				<Control>
					<Page />
					<Controller />
				</Control>
				<Data>
					<formData>
						<sessioninfo />
						<procid />
						<actseq />
						<workseq />
						<appseq />
						<isarchive />
						<readOnly />
						<dwc_specialist />
						<primary_specialist />
						<secondary_specialist />
						<contact_info_auto />
						<custContact />
						<emp_info_auto />
						<empContact />
						<case_desc />
						<case_status />
						<date_customer_contacted />
						<relatedCaseNumber />
						<related_to_case />
						<primary_rep />
						<non_cms_primary_last_name />
						<non_cms_primary_first_name />
						<non_cms_primary_middle_name />
						<cms_primary_rep />
						<non_cms_primary_email />
						<non_cms_primary_phone />
						<non_cms_primary_org />
						<non_cms_primary_mailing_addr />
						<case_type />
						<case_category />
						<cat_1 />
						<cat_2 />
						<cat_3 />
						<selected_category />
						<investigation />
						<start_date />
						<end_date />
						<std_conduct />
						<std_conduct_type />
						<contact />
						<emp_name />
						<org_assign />
						<doc_log />
						<desc_of_final_action />
						<length_of_suspension_proposed />
						<suspension_days />
						<completed_dt />
					</formData>
				</Data>
			</eForm>
		</xform:instance>
		<div class="form">
			<form action="process.do" method="post" name="BizFlowEntry">
				<out:if test="/mvc:eForm/mvc:Control/mvc:Language != ''">
					<input name="Language" type="hidden" value="{/mvc:eForm/mvc:Control/mvc:Language}" xmlns="" />
				</out:if>
				<input name="is_script_enabled" type="hidden" value="false" />
				<script type="text/javascript">
					<out:text>document.BizFlowEntry</out:text>
					<out:text>.is_script_enabled.value = 'true';</out:text>
				</script>
				<div class="controlContainer labelLeft">
					<div class="controlRow">
						<span class="defaultBackground hyperlinkControl " id="wicAdmin_container">
							<span class="controlBody">
								<a class="hyperlink " href="http://localhost:7080/WIC/getWICDetails.do" id="wicAdmin" name="wicAdmin">
									<span>
										<span>Workitem Context Administration ...</span>
									</span>
								</a>
							</span>
							<span class="hintIcon " id="wicAdmin_hint_container" onclick="hyf.tooltips.toggleTipMessage(event);" onmouseout="hyf.tooltips.hideTipMessage(event);" onmouseover="hyf.tooltips.showTipMessage(event);">
								<span class="tooltipContent" style="display: none;">
This link allows the user to launch a maintenance screen in a separate Browser Tab to change example data for Workitem Context values before calling the WebMaker Application in local test mode.   								</span>
							</span>
						</span>
					</div>
				</div>
				<div class="groupLabelBackground groupLabelOutside " id="incomingBizFlowParams_label_container">
					<h2 class="label " id="incomingBizFlowParams_label">BizFlow to WebMaker Application Workitem Context Parameters</h2>
				</div>
				<div class="adjacentGroupSep"></div>
				<div class="borderedGroup layoutContainer alignVertical alignLeft alignTop groupLabelOutside " id="incomingBizFlowParams">
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="labelBackground labelControl " id="sessioninfo_label_container">
									<label class="label " for="sessioninfo" id="sessioninfo_label">Session Info - XML</label>
								</span>
								<span class="defaultBackground textboxControl " id="sessioninfo_container">
									<span class="controlBody isMandatory">
										<input class="textbox " id="sessioninfo" name="sessioninfo" size="100" type="text" value="{/mvc:eForm/mvc:Control/mvc:session_string}">
											<out:if test="not(/mvc:eForm/mvc:Control/mvc:session_string) or (/mvc:eForm/mvc:Control/mvc:session_string = '')">
												<out:attribute name="value">&lt;SESSIONINFO KEY=&quot;1234_1234567890&quot; USERID=&quot;0000000101&quot; SERVERID=&quot;0000001001&quot; IP=&quot;192.168.0.100&quot; PORT=&quot;7201&quot; DEPTID=&quot;9000000000&quot; USERTYPE=&quot;U&quot; /&gt;</out:attribute>
											</out:if>
										</input>
										<input name="sessioninfo_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:sessioninfo" xmlns="" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="labelBackground labelControl " id="procid_label_container">
									<label class="label " for="procid" id="procid_label">Process Id</label>
								</span>
								<span class="defaultBackground textboxControl " id="procid_container">
									<span class="controlBody isMandatory">
										<input class="textbox " id="procid" name="procid" type="text" value="1001" />
										<input name="procid_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:procid" xmlns="" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="labelBackground labelControl " id="actseq_label_container">
									<label class="label " for="actseq" id="actseq_label">Activity Sequence</label>
								</span>
								<span class="defaultBackground textboxControl " id="actseq_container">
									<span class="controlBody isMandatory">
										<input class="textbox " id="actseq" name="actseq" type="text" value="101" />
										<input name="actseq_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:actseq" xmlns="" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="labelBackground labelControl " id="workseq_label_container">
									<label class="label " for="workseq" id="workseq_label">Workitem Sequence</label>
								</span>
								<span class="defaultBackground textboxControl " id="workseq_container">
									<span class="controlBody isMandatory">
										<input class="textbox " id="workseq" name="workseq" type="text" value="101" />
										<input name="workseq_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:workseq" xmlns="" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="labelBackground labelControl " id="appseq_label_container">
									<label class="label " for="appseq" id="appseq_label">Application Sequence</label>
								</span>
								<span class="defaultBackground textboxControl " id="appseq_container">
									<span class="controlBody">
										<input class="textbox " id="appseq" name="appseq" type="text" value="0" />
										<input name="appseq_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:appseq" xmlns="" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="labelBackground labelControl " id="isarchive_label_container">
									<label class="label " for="isarchive" id="isarchive_label">Archive</label>
								</span>
								<span class="defaultBackground checkboxControl " id="isarchive_container">
									<span class="controlBody isMandatory">
										<input class="checkbox " id="isarchive" name="isarchive" type="checkbox" value="true">
											<out:if test="'true' = /mvc:eForm/mvc:Data/mvc:formData/mvc:isarchive">
												<out:attribute name="checked">checked</out:attribute>
											</out:if>
											<out:if test="not(/mvc:eForm/mvc:Data/mvc:formData/mvc:isarchive) or (/mvc:eForm/mvc:Data/mvc:formData/mvc:isarchive = '')" />
										</input>
										<input name="isarchive_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:isarchive" xmlns="" />
										<input id="isarchive_value_if_not_submitted" name="isarchive_value_if_not_submitted" type="hidden" value="false" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="labelBackground labelControl " id="readOnly_label_container">
									<label class="label " for="readOnly" id="readOnly_label">Read Only</label>
								</span>
								<span class="defaultBackground checkboxControl " id="readOnly_container">
									<span class="controlBody isMandatory">
										<input class="checkbox " id="readOnly" name="readOnly" type="checkbox" value="true">
											<out:if test="'true' = /mvc:eForm/mvc:Control/mvc:readOnly">
												<out:attribute name="checked">checked</out:attribute>
											</out:if>
											<out:if test="not(/mvc:eForm/mvc:Control/mvc:readOnly) or (/mvc:eForm/mvc:Control/mvc:readOnly = '')" />
										</input>
										<input name="readOnly_xpath" type="hidden" value="/mvc:eForm/mvc:Data/mvc:formData/mvc:readOnly" xmlns="" />
										<input id="readOnly_value_if_not_submitted" name="readOnly_value_if_not_submitted" type="hidden" value="false" />
									</span>
								</span>
							</div>
						</div>
					</div>
					<div class="layoutContainerSep"></div>
					<div class="layoutContainerContent">
						<div class="controlContainer labelLeft">
							<div class="controlRow">
								<span class="defaultBackground buttonControl " id="showWebMakerApp_container">
									<span class="controlBody">
										<input id="showWebMakerApp_submit_button" name="xgate_action_bizflowEntry" type="submit" value="Call WebMaker Application" xmlns="" />
										<span id="showWebMakerApp_temp_container" style="display:none; visibility:hidden;" xmlns="">
											<input class="button " id="showWebMakerApp" name="showWebMakerApp" onclick="return showWebMakerApponclick((typeof(event) != 'undefined') ? event : arguments[0]);" type="button" value="Call WebMaker Application" />
										</span>
										<script type="text/javascript" xmlns="">
											<out:text disable-output-escaping="yes">document.getElementById('</out:text>
											<out:text disable-output-escaping="yes">showWebMakerApp_submit_button').parentNode.innerHTML=document.getElementById('</out:text>
											<out:text disable-output-escaping="yes">showWebMakerApp_temp_container').innerHTML;</out:text>
										</script>
									</span>
									<span class="hintIcon " id="showWebMakerApp_hint_container" onclick="hyf.tooltips.toggleTipMessage(event);" onmouseout="hyf.tooltips.hideTipMessage(event);" onmouseover="hyf.tooltips.showTipMessage(event);">
										<span class="tooltipContent" style="display: none;">
This button will activate a call to the WebMaker Application in local test mode. It will be presented based on the Process / Workitem key details specified above, and example data defined via the Workitem Context Adminstration screen. This screen is not seen at runtime on BizFlow, as the details above are passed from BizFlow directly.  										</span>
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
                form: document.BizFlowEntry,
                errorDisplayMethod: 'tooltip',
                errorDisplayShowAlerts: true,
                errorDisplayValidationMode: 'all'
            }
        			</out:text>
<xsl:for-each select="." xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:impl="http://handysoft.com/webservice/HWWorkitem" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:ns1="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="http://service.je.wf.bf.hs.com" xmlns:tns="http://handysoft.com/webservice/ServiceConstructor" xmlns:xg="http://www.hyfinity.com/xgate">			<out:text>
            field = document.getElementById('</out:text>
			<out:text>wicAdmin</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('target', '_blank');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>sessioninfo</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>procid</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','number');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>actseq</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','number');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>workseq</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>appseq</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>isarchive</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','boolean');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>readOnly</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','true');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','boolean');</out:text>
			<out:text>
            field = document.getElementById('</out:text>
			<out:text>showWebMakerApp</out:text>
			<out:text>');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_required','false');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_type','string');</out:text>
			<out:text disable-output-escaping="yes">field.setAttribute('_validate', 'false');</out:text>
<xsl:text disable-output-escaping="yes" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                    hyf.hooks.contentInserted(document.body);
            function showWebMakerApponclick(e)
            {
                var evt = (window.event) ? window.event : e;
                var sourceComponent = null;
                if ((evt != null) &amp;&amp; (typeof(evt) != 'undefined'))
                {
                    sourceComponent = (evt.target) ? evt.target : evt.srcElement;
                    if ((sourceComponent != null) &amp;&amp; (sourceComponent.nodeType == 3)) // defeat Safari bug
                        sourceComponent = sourceComponent.parentNode;
                }
                var objEventSource = {name: 'EventSource', option: 'field', event: evt, component: sourceComponent, value: 'showWebMakerApp', field: document.getElementById('showWebMakerApp')};

                return dojo.hitch(objEventSource.field, function(){
                    var objAction = {name: 'Action', option: 'Action', value: 'bizflowEntry'};
                    var objValidate = {name: 'Validate', option: 'Static', value: 'false'};
                    hyf.FMAction.handleFormSubmission(objAction, objValidate, objEventSource);
                    })();
            }
            </xsl:text></xsl:for-each>		</script>
	</out:template>
</out:stylesheet>
