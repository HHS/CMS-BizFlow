<%
/**
 * disclaimer.jsp
 *
 * Company: BizFlow Corp
 *
 * Showing a disclaimer dialog when user logs into BizFlow 12.x
 *
 * @author Taeho Lee
 * @version 1.0
 * @created: June 21, 2013
 * @modification history
 * @modified: 
 */
%>

<%@ page import="java.io.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.sql.*, java.io.*, java.util.*, java.text.SimpleDateFormat" %>

<jsp:useBean id="disclaimerProp" class="java.util.Properties" scope="application"/>

<%!
	private void loadDisclaimerProperties(ServletContext application, java.util.Properties props, boolean reload) throws IOException
	{
		System.out.println("loadDisclaimerProperties... reload=" + reload);
		if (logger.isDebugEnabled()) logger.debug(">>loadDisclaimerProperties");
		if (props.isEmpty() || reload)
		{
			if (logger.isDebugEnabled()) logger.debug("loading properties file...");
			String propPath = application.getRealPath("/solutions/disclaimer/disclaimer.properties");
			props.load(new FileInputStream(propPath));
		}
		if (logger.isDebugEnabled()) logger.debug("<<loadDisclaimerProperties");
	}
%>

<%
	//Loading disclaimer properties
	boolean bLoadPropertiesEveryTime = false;
	loadDisclaimerProperties(application, disclaimerProp, bLoadPropertiesEveryTime);

	//Disclaimer dialog configuration
	String DISCLAIMER_BODY_CONTENT_RELOAD = disclaimerProp.getProperty("dicalaimer.body.content.reload");
	String DISCLAIMER_ENABLED = disclaimerProp.getProperty("disclaimer.enabled");
	String DISCLAIMER_DIALOG_WIDTH = disclaimerProp.getProperty("disclaimer.dialog.width");
	String DISCLAIMER_DIALOG_HEIGHT = disclaimerProp.getProperty("disclaimer.dialog.height");
	String DISCLAIMER_DIALOG_EFFECT = disclaimerProp.getProperty("disclaimer.dialog.effect");
	String DISCLAIMER_DIALOG_BUTTON_LABEL = disclaimerProp.getProperty("disclaimer.dialog.button.label");
	String DISCLAIMER_BODY_CONTENT_FILE_NAME = disclaimerProp.getProperty("dicalaimer.body.content.file.name");

	//loading disclaimer text from the file only once.
	String errorMessage = "";
	String disclaimerContent = (String)application.getAttribute("disclaimerContent");
	if (null == disclaimerContent || "".equals(disclaimerContent) || "ALWAYS".equalsIgnoreCase(DISCLAIMER_BODY_CONTENT_RELOAD))
	{
		//System.out.println("loading disclaimer content...");
		try 
		{
			disclaimerContent = "";
			File infile = new File(application.getRealPath("/solutions/disclaimer/" + DISCLAIMER_BODY_CONTENT_FILE_NAME));
			FileReader fr = new FileReader(infile); 
			BufferedReader br = new BufferedReader(fr); 
			String s; 
			while((s = br.readLine()) != null) { 
				disclaimerContent += s;
			} 
			fr.close(); 
		} catch (Exception e) {
			errorMessage = e.toString();
		} 

		application.setAttribute("disclaimerContent", disclaimerContent);		
	} else {
		//System.out.println("disclaimer content was loaded already.");
	}

	//Disclaimer dialog must be shown only once after user signs in.
	String wasDisclaimerDisplayed = (String)session.getAttribute("_WasDisclaimerDisplayed");
	if (null == wasDisclaimerDisplayed) wasDisclaimerDisplayed = "N";
%>

<!-- DISCLAIMER BODY MAIN //-->
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/js/jquery/ui/themes/start/jquery-ui-1.8.18.custom.css"/>
<bf:script src="/js/jquery/jquery-1.7.2.min.js" bridgetranslation="no" />
<bf:script src="/js/jquery/ui/jquery-ui-1.8.18.custom.js" bridgetranslation="no"/>
<style type="text/css">
.ui-dialog-buttonpane { text-align: center; }
.ui-dialog-buttonset { text-align: center !important; float:none !important;}
.ui-dialog-titlebar-close { visibility: hidden; }
.disclaimerButtonClass {
	width: 140px;
	/* margin-right: 230px !important; */
}

.ui-widget-overlay {
  opacity: 1.0 !important;
  filter: Alpha(Opacity=100) !important;
  background-color: black !important;
  background: black !important;
}

</style>
<div id="disclaimerMessage" title="Disclaimer">
<br/>
<div tabIndex="100" id="innerDisclaimerMessage">
<%=disclaimerContent%>
</div>
</div>

<!-- DISCLAIMER SCRIPT //-->
<script type="text/javascript">
<!--
	function markDisclaimerDisplayed()
	{
		var xmlhttp;
		if (window.XMLHttpRequest)
		{
			xmlhttp=new XMLHttpRequest();
		}
		else
		{// code for IE6, IE5
			xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
		}
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState==4 && xmlhttp.status==200)
			{
				//alert(xmlhttp.responseText); //for debugging
			}
		}
		xmlhttp.open("POST",'<%=request.getContextPath()%>/solutions/disclaimer/markdisclaimer.jsp?sinfo=<%=URLEncoder.encode(hwSessionInfo.toString(), "ISO-8859-1")%>',true);
		xmlhttp.send();
	}

	$( "#disclaimerMessage" ).dialog({ 
				autoOpen: false,
				modal: true,
				width: <%= DISCLAIMER_DIALOG_WIDTH %>,
				height: <%= DISCLAIMER_DIALOG_HEIGHT %>,
				resizable: false,
				closeOnEscape: false,
				open: function(event, ui) { $(".ui-dialog-titlebar-close", ui.dialog || ui).hide(); },

				buttons: [
					{
						text: "<%=DISCLAIMER_DIALOG_BUTTON_LABEL%>",
						"class": 'disclaimerButtonClass',
						click: function() {
							$( this ).dialog( "close" );
						}
					}
				],
				show: {
					effect: "<%=DISCLAIMER_DIALOG_EFFECT%>",
					duration: 1500
				},
				hide: {
					effect: "<%=DISCLAIMER_DIALOG_EFFECT%>",
					duration: 1000
				},
				close: function( event, ui ) {
					var abc = event;
					markDisclaimerDisplayed();				
				}				
			});

<% if (!"Y".equals(wasDisclaimerDisplayed) && "TRUE".equals(DISCLAIMER_ENABLED)) { %>

	$('button.disclaimerButtonClass').attr('tabIndex', '200');
	
	$('#innerDisclaimerMessage').off('focusout').on('focusout', function(e) {
		setTimeout(function() {$('button.disclaimerButtonClass').focus();}, 0);
	});
	
	$('button.disclaimerButtonClass').off('focusout').on('focusout', function(e) {
		setTimeout(function() {$('#innerDisclaimerMessage').focus();}, 0);
	});
	
	$( "#disclaimerMessage" ).dialog( "open" );
	$('#innerDisclaimerMessage').focus();
<%	} %>
//-->
</script>

