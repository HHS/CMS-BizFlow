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
		<link href="css/webmaker_layout.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;!--[if lte IE 7]&gt;</out:text>
		<link href="css/webmaker_layout_ie_6_7.css?rev=20190613202429" rel="stylesheet" type="text/css" xmlns="" />
		<out:text disable-output-escaping="yes">&lt;![endif]--&gt;</out:text>
		<link href="custom/css/jquery-ui-1.9.2.custom.min.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="theme/bizflow_default/css/theme.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<out:text disable-output-escaping="yes">&lt;!--[if lte IE 8]&gt;</out:text>
		<link href="theme/bizflow_default/css/theme_ie8.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<out:text disable-output-escaping="yes">&lt;![endif]--&gt;</out:text>
		<link href="theme/bizflow_default/css/print_completed.css?rev=20190613202429" media="print" rel="stylesheet" type="text/css" />
		<link href="theme/bizflow_default/css/theme_mobile.css?rev=20190613202429" media="only screen and (max-width: 1024px)" rel="stylesheet" type="text/css" />
		<link href="../cms_common/js/angularjs/bower_components/bootstrap/dist/css/bootstrap.min.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="../cms_common/js/angularjs/bower_components/bootstrap/dist/css/bootstrap.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="../cms_common/js/angularjs/bower_components/angular-inform/dist/angular-inform.min.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="../cms_common/js/angularjs/bower_components/angular-ui-select/dist/select.min.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="../cms_common/js/angularjs/bower_components/angular-block-ui/dist/angular-block-ui.min.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="../cms_common/js/angularjs/bower_components/angular-ui-grid/ui-grid.min.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="../cms_common/js/angularjs/common/css/bootstrap-ext.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="../cms_common/js/angularjs/common/css/app.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="custom/css/form-main.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="../cms_common/custom/css/form-common.css?rev=20190613202429" rel="stylesheet" type="text/css" />
		<link href="../cms_common/custom/css/cmscomment.css?rev=20190613202429" rel="stylesheet" type="text/css" />
	</out:template>
	<out:template name="page_scripts">
		<script src="../cms_common/custom/js/removeamd.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/jquery/dist/jquery.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="custom/js/jquery-ui-1.9.2.custom.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/blockUI.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/bootstrap/dist/js/bootstrap.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular/angular.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-cookies/angular-cookies.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-inform/dist/angular-inform.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-animate/angular-animate.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-ui-select/dist/select.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-file-upload/dist/angular-file-upload.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-block-ui/dist/angular-block-ui.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-sanitize/angular-sanitize.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-messages/angular-messages.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/angular-ui-grid/ui-grid.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/bootbox/bootbox.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/bower_components/x2js/xml2json.js?rev=20190613202429 " type="text/javascript"></script>
		<script src="../cms_common/custom/js/lodash.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/redux.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/form-state.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/common/js/angular-ext.min.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/common/js/angular-bizflow.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/common/common.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/common/components/common.components.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/common/components/common.directive.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/common/components/attachment/attachment.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/form-log.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/form-require.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/form-utility.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/form-attachment.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/js/angularjs/common/components/comment/comment.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/cmscomment.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/form-auto-complete.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/lookup-manager.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/form-manager.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/form-usergroup.js?rev=20190613202429" type="text/javascript"></script>
		<script src="../cms_common/custom/js/form-section508.js?rev=20190613202429" type="text/javascript"></script>
		<script src="custom/js/form-main-common.js?rev=20190613202429" type="text/javascript"></script>
		<script src="custom/js/form-main.js?rev=20190618202429" type="text/javascript"></script>
	</out:template>
	<out:template name="section_body">
<xform:xform xmlns:xform="http://www.w3.org/2001/08/xforms" xmlns="" xmlns:fm="http://www.hyfinity.com/formmaker" xmlns:impl="http://handysoft.com/webservice/HWWorkitem" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:ns1="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns2="http://service.je.wf.bf.hs.com" xmlns:tns="http://handysoft.com/webservice/ServiceConstructor" xmlns:xg="http://www.hyfinity.com/xgate" >		<div class="form">
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
