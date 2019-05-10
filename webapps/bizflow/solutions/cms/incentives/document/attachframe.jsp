<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/bizflow.tld" prefix="bf" %>

<bf:sessioncheck errorpage="/common/gotohome.jsp"/>
<% if (null != request.getAttribute("sessionExpired")) return; %>
<%@ include file="../../../tasktracker117/common/common.jsp" %>
<%@ include file="../../../tasktracker117/common/util.jsp" %>

<bf:parameter name="PROCESSID" id="ProcessID" value="" valuePattern="Numeric"/>
<bf:parameter name="TYPE" id="type" value="" valuePattern="Alphabet"/>
<bf:parameter name="monitor" id="monitor" value="" valuePattern="Alphabet"/>
<bf:parameter name="passwordflag" id="passwordflag" value="" valuePattern="Alphabet"/>

<jsp:useBean id="res" class="com.hs.bf.web.xslt.resource.ResourceBag" scope="application"/>
<%
    response.setContentType("text/html;charset=" +charSet);
    String serverID = "0000001001";

    ModuleHelperUtil.setCurrentModuleName("solutions/tasktracker117");
    SQLParameterizedQuery query = new SQLParameterizedQuery("SELECT HHS_FN_AUTHORITY_SAM_DOCUMENTS(?, ?) AS CNT FROM DUAL");
    query.declareStringParameter("memberid", hwSessionInfo.get("USERID"));
    query.declareIntParameter("procid", Integer.parseInt(ProcessID));
    int count = query.executeForInt();
    if(0==count)
    {
        out.print("<div style='margin:2em 0 0 2em;'>Attached Salary Above Minimum Documentation is Restricted.</div>");
        return;
    }
%>

<HTML lang="<%=language%>">
<head>
    <META http-equiv="Content-Type" content="text/html; charset=<%=(String)session.getAttribute("LangCharSet")%>">
    <title><%=res.getString(language,"stringtable","TTL_PATT")%></title>
</head>
<body style="margin:0;padding:0;">
<% String titleHeight = "0";
    if(monitor.equals("yes")) {
        titleHeight = "0";
    }else if(monitor.equals("no")) {
        titleHeight = "22";
    } %>
<div>
    <% if(type.equals("instance") || type.equals("cpinstance")){ %>
    <iframe TITLE="frameTitle" NAME="frameTitle" SRC="/bizflow/instance/piattachtitle.jsp?PROCESSID=<%=ProcessID %>&monitor=<%=monitor%>" MARGINHEIGHT="0" MARGINWIDTH="0" border="0" scrolling = "no" frameborder="0" framespacing="0" NORESIZE width="100%" height="<%=titleHeight%>px" style="z-index: 2;position:relative"></iframe>
    <iframe name="frameHidden" src="/bizflow/instance/pihiddenframe.jsp" title="No user content" aria-hidden="true" width="0" height="0" style="display:none;"></iframe>
    <iframe TITLE="frameDown" NAME="frameDown" SRC="/bizflow/instance/attach.jsp?serverid=<%=serverID%>&PROCESSID=<%= ProcessID %>&TYPE=<%=type%>&passwordflag=<%=passwordflag%>&monitor=<%=monitor%>" MARGINHEIGHT="0" MARGINWIDTH="0" border="0" scrolling = "yes" frameborder="0" framespacing="0" NORESIZE width="100%" height="100%" style="height:100%;padding-top: <%=titleHeight%>px;margin-top: -<%=titleHeight%>px;box-sizing:border-box;z-index: 1;position:relative"></iframe>
    <% } if(type.equals("archive") || type.equals("cparchive")){ %>
    <iframe TITLE="frameTitle" NAME="frameTitle" SRC="/bizflow/archive/paattachtitle.jsp?PROCESSID=<%=ProcessID %>&monitor=<%=monitor%>" MARGINHEIGHT="0" MARGINWIDTH="0" border="0" scrolling = "no" frameborder="0" framespacing="0" NORESIZE width="100%" height="<%=titleHeight%>px" style="z-index: 2;position:relative"></iframe>
    <iframe name="frameHidden" src="/bizflow/archive/pahiddenframe.jsp" title="No user content" aria-hidden="true" width="0" height="0" style="display:none;"></iframe>
    <iframe TITLE="frameDown" NAME="frameDown" SRC="/bizflow/instance/attach.jsp?serverid=<%=serverID%>&PROCESSID=<%= ProcessID %>&TYPE=<%=type%>&passwordflag=<%=passwordflag%>&monitor=<%=monitor%>" MARGINHEIGHT="0" MARGINWIDTH="0" border="0" scrolling = "yes" frameborder="0" framespacing="0" NORESIZE width="100%" height="100%" style="height:100%;padding-top: <%=titleHeight%>px;margin-top: -<%=titleHeight%>px;box-sizing:border-box;z-index: 1;position:relative"></iframe>
    <% } if(ProcessID.equals("null")) {%>
    <iframe TITLE="frameTitle" NAME="frameTitle" SRC="/bizflow/instance/piattachtitle.jsp?PROCESSID=<%=ProcessID %>&monitor=<%=monitor%>" MARGINHEIGHT="0" MARGINWIDTH="0" border="0" scrolling = "no" frameborder="0" framespacing="0" NORESIZE width="100%" height="<%=titleHeight%>px" style="z-index: 2;position:relative"></iframe>
    <iframe name="frameHidden" src="/bizflow/instance/pihiddenframe.jsp" title="No user content" aria-hidden="true" width="0" height="0" style="display:none;"></iframe>
    <iframe TITLE="frameDown" NAME="frameDown" SRC="/bizflow/instance/attach.jsp?serverid=<%=serverID%>&PROCESSID=<%= ProcessID %>&TYPE=<%=type%>&passwordflag=<%=passwordflag%>&monitor=<%=monitor%>" MARGINHEIGHT="0" MARGINWIDTH="0" border="0" scrolling = "yes" frameborder="0" framespacing="0" NORESIZE width="100%" height="100%" style="height:100%;padding-top: <%=titleHeight%>px;margin-top: -<%=titleHeight%>px;box-sizing:border-box;z-index: 1;position:relative"></iframe>
    <% } %>
</div>
</body>
</html>
