<jsp:useBean id="hwSessionInfo" class="com.hs.bf.web.beans.HWSessionInfo" scope="session"/>
<%
	//In order to show the disclaimer only once, mark diclamier as showed
	String sinfo = (String)request.getParameter("sinfo");
	String returnMessage = "";
	if (null == sinfo) sinfo = "";
	if (sinfo.equalsIgnoreCase(hwSessionInfo.toString())) {
		session.setAttribute("_WasDisclaimerDisplayed", "Y");
		returnMessage = "OK";
	} else {
		returnMessage = "Invalid request. you are not authorize to call this page.";
	}
%>
<%=returnMessage%>