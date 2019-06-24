<%@page import="java.util.*" %>
<jsp:useBean id="hwini" class="com.hs.frmwk.common.ini.IniFile" scope="session"/>
<% 
	Enumeration en = request.getParameterNames();
	String params = "";
	while (en.hasMoreElements()) {
		String parameterName = (String) en.nextElement();
		String parameterValue = request.getParameter(parameterName);
		params += "&" + parameterName + "=" + parameterValue;
	}

	boolean useAccessibility = hwini.getBoolValue("GENERAL", "ACCESSIBILITY", false);
	String userTimeZone = (String)session.getAttribute("TIMEZONE");
	String section508Enabled = (useAccessibility? "y" : "n");
	String reportURL = "/bizflowadvreport/flow.html?_bf508=" + section508Enabled + "&_bfUserTimezone=" + userTimeZone + params;
%>
<html>
<body>
<h2>loading the report...</h2>
</body>
</html>
<script language="javascript">
<!--
	document.location.href = "<%= reportURL%>";
//-->
</script>
