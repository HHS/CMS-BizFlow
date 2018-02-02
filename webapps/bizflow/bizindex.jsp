<%@page import="com.hs.ja.security.SecurityUtil"%>
<%@ page import="java.util.*, java.io.*, 
                 com.hs.frmwk.algorithm.*, 
                 com.hs.bf.web.beans.*, 
                 com.hs.bf.web.xmlrs.*, 
                 com.hs.frmwk.xml.dom.*, 
                 com.hs.frmwk.xml.dom.util.*, 
                 com.hs.frmwk.web.util.*" %>
<%@ page import="com.hs.bf.web.theme.ThemeUtil" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/bizflow.tld" prefix="bf" %>

<%! static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger("JSP.bizflow"); %>

<%
    long startedTime = 0;
    if (logger.isDebugEnabled())
        startedTime = System.currentTimeMillis();
%>

<%!
    final static int AUTHID_FOLDER_VIEW = 0x1;
    final static int AUTHID_VIEW_BIZCOVES = 0x00400000;
    final static int AUTHID_VIEW_TABULAR = 0x00800000;
    final static String PROCESS_DEFINITION_MENU_ID = "124";
    final static String WORKAREA_MENU_ID = "118";

    private int getWorkAreaAuthorityValue(Element menuGroups)
    {
        int authValue = 0;

        try
        {
            int menuGroupCount = menuGroups.getChildCount();

            for (int i = 0; i != menuGroupCount; ++i)
            {
                Element menuGroup = menuGroups.childAt(i);
                Element menu = XPathUtil.selectSingleElement(menuGroup, "menu[@fid='" + WORKAREA_MENU_ID + "']");

                if (null != menu && !"false".equalsIgnoreCase(menu.getAttribute("visibility")))
                {
                    authValue = menu.getIntAttribute("auth");
                    break;
                }
            }
        }
        catch (Exception e)
        {
        }

        return authValue;
    }

    private static Element getOtherAvailMenu(Element menuGroups)
    {
        Element candidate = null;

        try
        {
            int groupCount = menuGroups.getChildCount();

            for (int i = 0; i != groupCount; ++i)
            {
                Element group = menuGroups.childAt(i);
                int menuCount = group.getChildCount();

                for (int j = 0; j != menuCount; ++j)
                {
                    Element menu = (Element) group.childAt(j);
                    String folderId = menu.getAttribute("fid");
                    boolean isNonAdmin = !"yes".equals(menu.getAttribute("inadmin"));
                    boolean visibility = !"false".equals(menu.getAttribute("visibility"));

                    if (menu.getBooleanAttribute("display") && isNonAdmin && visibility)
                    {
                        if (PROCESS_DEFINITION_MENU_ID.equals(folderId) || WORKAREA_MENU_ID.equals(folderId))
                        {
                            int auth = menu.getIntAttribute("auth");

                            if (AUTHID_VIEW_TABULAR == (AUTHID_VIEW_TABULAR & auth))
                            {
                                candidate = menu;
                                return candidate;
                            }
                        }
                        else
                        {
                            int auth = menu.getIntAttribute("auth");

                            if (menu.getBooleanAttribute("display") && "no".equals(menu.getAttribute("inadmin")))
                            {
                                if (AUTHID_FOLDER_VIEW == (AUTHID_FOLDER_VIEW & auth))
                                {
                                    candidate = menu;
                                    return candidate;
                                }
                            }
                        }
                    }
                }
            }
        }
        catch (Exception e)
        {
        }

        return candidate;
    }

    private void setWorkAreaPageUrl(Element menuGroups, String workAreaPageUri)
    {
        int groupCount = menuGroups.getChildCount();
        for (int i = 0; i != groupCount; ++i)
        {
            Element menuGroup = menuGroups.childAt(i);
            int menuCount = menuGroup.getChildCount();

            for (int j = 0; j != menuCount; ++j)
            {
                Element menu = menuGroup.childAt(j);

                if (WORKAREA_MENU_ID.equals(menu.getAttribute("fid")))
                {
                    menu.setAttribute("href", workAreaPageUri);
                }
            }
        }
    }
%>

<bf:sessioncheck errorpage="/common/gotohome.jsp"/>
<% if (null != request.getAttribute("sessionExpired"))
    return; %>

<jsp:useBean id="res" class="com.hs.bf.web.xslt.resource.ResourceBag" scope="application"/>
<jsp:useBean id="hwSessionInfo" class="com.hs.bf.web.beans.HWSessionInfo" scope="session"/>
<jsp:useBean id="hwSessionFactory" class="com.hs.bf.web.beans.HWSessionFactory" scope="application"/>
<jsp:useBean id="hwini" class="com.hs.frmwk.common.ini.IniFile" scope="session"/>
<jsp:useBean id="hwiniSystem" class="com.hs.frmwk.common.ini.IniFile" scope="application"/>
<jsp:useBean id="bizflowProps" class="com.hs.bf.web.props.Properties" scope="application"/>
<jsp:useBean id="themeManager" class="com.hs.bf.web.theme.ThemeManager" scope="application"/>

<bf:parameter id="mode" name="mode" value="wa"/>
<bf:parameter id="menuFolderId" name="mfid" value="118" valuePattern="Numeric"/>
<bf:parameter id="patchModuleType" name="patchModuleType" value="" valuePattern="WordHyphen"/>

<%@ include file="/bizcoves/common/menuinfo.inc" %> 
<%@ include file="/bizcoves/common/workarea.inc" %>

<bf:parameter id="browserWidth" name="browserWidth" value="0" valuePattern="Numeric"/>
<bf:parameter id="browserHeight" name="browserHeight" value="0" valuePattern="Numeric"/>
<bf:parameter id="unitHeight" name="unitHeight" value="0" valuePattern="Numeric"/>
<bf:parameter id="targetUrl" name="targetUrl" value="" valuePattern="{{PostEncoded}},{{NoHtmlTag}}"/>
<bf:parameter id="XUACompatible" name="XUACompatible" value="" valuePattern="[^\\w=]"/>

<%
boolean useAccessibility = false;
// Get ssoTargetUrl when this is redirected with targetUrl via bizflowsso
String ssoTargetUrl = null;
Cookie[] ssoCookies = request.getCookies();
if(null != ssoCookies) {
    for(int i=0; i < ssoCookies.length; i++) {
        if(ssoCookies[i].getName().equals(com.hs.bf.web.session.filter.SessionMonitoringFilterImpl.targetUrlKey)) {
            ssoTargetUrl = ssoCookies[i].getValue();
            if(null != ssoTargetUrl && ssoTargetUrl.length() > 0) {
                ssoCookies[i].setValue(null);
                ssoCookies[i].setMaxAge(0);
                response.addCookie(ssoCookies[i]);
            }
        }
    }
}

if(!"0".equals(browserWidth))
{
    session.setAttribute("browserWidth", browserWidth);
}
if(!"0".equals(browserHeight))
{
    session.setAttribute("browserHeight", browserHeight);
}
if(!"0".equals(unitHeight))
{
    session.setAttribute("unitHeight", unitHeight);
}

	try
	{
		String userAgent = request.getHeader("user-agent");
		if(!hwiniSystem.getBoolValue("WORK_AREA_DEFAULT", "PURE_THIN_CLIENT_MODE", true))
		{
//			The desktop Workitem use VBScript. IE11 does not support VBScript. In order to support IE11 we change IE browser mode to IE10 via X-UA-Compatible tag

			if(!(0<userAgent.indexOf("MSIE 10") || 0<userAgent.indexOf("MSIE 9") || 0<userAgent.indexOf("MSIE 8")))
			{
				XUACompatible = "IE=10";
			}
		}
		else // if(0<userAgent.indexOf("MSIE 10"))
		{
			XUACompatible = "IE=Edge";
		}
	}
	catch(Exception e)
	{
	}

    Element menuGroups = (Element) session.getAttribute("menu-groups");
    String contextPath = request.getContextPath();
    String lang = (String) session.getAttribute("Language");
	lang = (lang == null || lang == "") ? "en" : lang;
    String charSet = (String) session.getAttribute("LangCharSet");
    String action = request.getParameter("action");
    int errorNumber = 0;
    String msgError = "";
    String workAreaPageUri = "";

    response.setContentType("text/html;charset=" + charSet);
    themeManager.setResponseHeaders(request, response, XUACompatible);
    response.setHeader("Cache-Control", "no-cache"); //HTTP 1.1
    response.setHeader("Pragma", "no-cache"); //HTTP 1.0
    response.setDateHeader("Expires", 0); //prevents caching at the proxy server

    try
    {
        String mid = request.getParameter("mid");
        if (useConfigurableMenu && null == mid)
        {
            mid = hwini.getValue("menu", "MenuID");
        }

        if ((null != mid && mid.trim().length() > 0) || (null == menuGroups))
        {
            if (null != menuGroups)
            {
                session.removeAttribute("menu-groups");
                menuGroups = null;
            }

            String _cm = request.getParameter("_configMenu");   // for instance menu changing
            if (null != _cm)
            {
                useConfigurableMenu = "true".equalsIgnoreCase(_cm);	            
            }

            if(useConfigurableMenu && myMenus.getRowCount() == 0)
            {
                session.setAttribute("useConfigurableMenu", "true");
                getMyMenus(hwSessionInfo, myMenus);    
            }

            session.setAttribute("currentMenuId", mid);
            menuGroups = getMenus(out, hwSessionFactory, hwSessionInfo, useConfigurableMenu, request, myMenus);
            int idx = myMenus.lookupField("ID", mid);
            if (idx == -1) // this menu may have been deleted.
            {
                // look up default menu.
                mid = "1000004";
                idx = myMenus.lookupField("ID", mid);
                if (idx == -1) // if there is no default menu.
                {
                    if (myMenus.getRowCount() == 0)
                        throw new RuntimeException("Invalid case - There must be at least one menu.");
                    else
                    {
                        idx = 0;
                        mid = myMenus.getFieldValueAt(idx, "ID");
                    }
                }
            }
            hwini.setValue("menu", "MenuID", mid);
	        session.setAttribute("currentMenuName", myMenus.getFieldValueAt(idx, "NAME"));
            session.setAttribute("menu-groups", menuGroups);
        }
        else
        {
            request.getSession().setAttribute("useConfigurableMenu", Boolean.toString(useConfigurableMenu));
            // begin of cs18125
            if (useConfigurableMenu)
            {
                getMyMenus(hwSessionInfo, myMenus);
                menuGroups = getMenus(out, hwSessionFactory, hwSessionInfo, useConfigurableMenu, request, myMenus);
                if (menuGroups != null)
                {
                    if (myMenus.getRowCount() > 0)
                    {
                        mid = myMenus.getFieldValueAt(0, "ID");
                        hwini.setValue("menu", "MenuID", mid);
                        session.setAttribute("currentMenuId", mid);
                        session.setAttribute("currentMenuName", myMenus.getFieldValueAt(0, "NAME"));
                        session.setAttribute("menu-groups", menuGroups);
                    }
                }
            }
            // end of cs18125
        }

        if (0 == menuGroups.getIntAttribute("nonadminmenus"))
        {
            if (0 != menuGroups.getIntAttribute("adminmenus"))
            {
                response.sendRedirect("portal/common/index.jsp");
                return;
            }
        }else
        {
            // Bug 18379 Inertia-R-11 Single Login and UI Link From BF to OE
            String licenseGroupCount = menuGroups.getAttribute("licenseGroupCount");
            if ("1".equalsIgnoreCase(licenseGroupCount) && !useConfigurableMenu)
            {
                String officeEngine = menuGroups.getAttribute("OfficeEngine");
                if ("true".equalsIgnoreCase(officeEngine))
                {
                    String oeUrl = com.hs.solutions.tasktracker117.util.TaskSystemUtil.getOfficeEngineURL()
                    		       + "/tasktracker.jsp";
                    response.sendRedirect(SecurityUtil.removeCRLF(oeUrl.substring(1)));
                    return;
                }
            }
        }


        int workAreaAuthValue = getWorkAreaAuthorityValue(menuGroups);
        boolean workAreaEnabled = (AUTHID_VIEW_BIZCOVES == (AUTHID_VIEW_BIZCOVES & workAreaAuthValue))
                || (AUTHID_VIEW_TABULAR == (AUTHID_VIEW_TABULAR & workAreaAuthValue));
        long t = System.currentTimeMillis();
        boolean isBizCoveWorkAreaStyle = "bizcove".equals(session.getAttribute("BizCoveWorkAreaStyle"));

        if (!isBizCoveWorkAreaStyle)
        {
            if (AUTHID_VIEW_BIZCOVES == (AUTHID_VIEW_BIZCOVES & workAreaAuthValue))
            {
                if (AUTHID_VIEW_TABULAR != (AUTHID_VIEW_TABULAR & workAreaAuthValue))
                {
                    isBizCoveWorkAreaStyle = hwiniSystem.getBoolValue("BIZCOVE", "ENABLED");
                }
            }
        }
        else
        {
            isBizCoveWorkAreaStyle = (AUTHID_VIEW_BIZCOVES == (AUTHID_VIEW_BIZCOVES & workAreaAuthValue));
        }

        if(null != targetUrl && !"".equals(targetUrl))
        {
            workAreaPageUri = URLDecoder.decode(targetUrl, "UTF-8");
	    if (com.hs.bf.web.util.ParamUtil.testString(workAreaPageUri,  "^((https?:/)?(/%[0-9A-Fa-f]{2}|[-()_.!~*';/?:@&=+$,A-Za-z0-9])+)([).!';/?:,][[:blank:]])?$", pageContext, "workAreaPageUri") > 0)
            {
                response.sendError(HttpServletResponse.SC_NOT_ACCEPTABLE, "Not acceptable URL");
                return;
            }
        }
        else if (isBizCoveWorkAreaStyle && workAreaEnabled)
        {
            clearWorkAreas(request);
            Element workAreas = getWorkAreas(request, hwSessionFactory, hwSessionInfo);
            try
            {
                // begin cs11135 - display DEPT workarea page first.
                workAreaPageUri = workAreas.childAt(0).getText() + "?mfid=" + WORKAREA_MENU_ID;
                // begin of cs14903.
                if (workAreas.getChildCount() > 1)
                {
                    for (int i = 0; i < workAreas.getChildCount(); i++)
                    {
	                    if (!"".equals(workAreas.childAt(i).getText()))
	                    {
	                    	if ("LastViewed".equals(hwini.getValue("GENERAL", "InitialBizCoveView")) ||
	                    		"".equals(hwini.getValue("GENERAL", "InitialBizCoveView")))
	                    	{
	                    		if (hwini.getValue("GENERAL", "LastBizCoveView").equals(workAreas.childAt(i).getAttribute("id")))
	                    		{
			                        workAreaPageUri = workAreas.childAt(i).getText() + "?mfid=" + WORKAREA_MENU_ID;
			                        break;
	                    		}
	                    	}
	                    	else
	                    	{
	                    		if (("DEFAULT".equals(hwini.getValue("GENERAL", "InitialBizCoveView")) ||
	                    			"".equals(hwini.getValue("GENERAL", "InitialBizCoveView")))
	                    			&& (i == 0))
	                    		{
			                        workAreaPageUri = workAreas.childAt(i).getText() + "?mfid=" + WORKAREA_MENU_ID;
			                        break;
	                    		}
	                    		else if (hwini.getValue("GENERAL", "InitialBizCoveView").equals(workAreas.childAt(i).getAttribute("id")))
	                    		{
			                        workAreaPageUri = workAreas.childAt(i).getText() + "?mfid=" + WORKAREA_MENU_ID;
			                        break;
	                    		}
	                    	}
	                    }
                    }
                }
                // end of cs14903

                if (-1 == workAreaPageUri.indexOf("_rfall="))
                    workAreaPageUri += "&_rfall=y";
            }
            catch (Exception e)
            {
            }

            setWorkAreaPageUrl(menuGroups, workAreaPageUri);
        }
        else
        {
            if (workAreaEnabled)
            {
                workAreaPageUri = "/portal/user/worklistbody.jsp?action=refresh";
                setWorkAreaPageUrl(menuGroups, workAreaPageUri);
            }
            else
            {
                if (0 == menuGroups.getIntAttribute("availmenus"))
                {
                    workAreaPageUri = "/nopages.jsp";
                }
                else if (0 == menuGroups.getIntAttribute("nonadminmenus") && 0 < menuGroups.getIntAttribute("adminmenus"))
                {
                    response.sendRedirect("portal/common/index.jsp");
                    return;
                }
                else
                {
                    workAreaPageUri = "/nopages.jsp";
                    Element candidate = getOtherAvailMenu(menuGroups);

                    if (null != candidate)
                    {
                        workAreaPageUri = candidate.getAttribute("href");
                    }
                    else if (0 < menuGroups.getIntAttribute("adminmenus"))
                    {
                        response.sendRedirect("portal/common/index.jsp");
                        return;
                    }
                }
            }
        }

        if (-1 == workAreaPageUri.indexOf('?'))
        {
            workAreaPageUri = new StringBuffer(workAreaPageUri).append("?t=").append(Long.toString(t)).toString();
        }
        else
        {
            workAreaPageUri = new StringBuffer(workAreaPageUri).append("&t=").append(Long.toString(t)).toString();
        }

        if (hwini.containsKey("GENERAL", "ACCESSIBILITY"))
        {
            useAccessibility = hwini.getBoolValue("GENERAL", "ACCESSIBILITY");
        }
        else
        {
            if (hwiniSystem.containsKey("WORK_AREA_DEFAULT", "DEFAULT_ACCESSIBILITY"))
            {
                useAccessibility = hwiniSystem.getBoolValue("WORK_AREA_DEFAULT", "DEFAULT_ACCESSIBILITY");
            }
        }
        session.setAttribute("ACCESSIBILITY", String.valueOf(useAccessibility));
        new com.hs.frmwk.web.resource.ResourceBag(useAccessibility);
    }
    catch (HWException e)
    {
        errorNumber = e.getNumber();
        msgError = e.getMessage();
    }
%>
<!DOCTYPE html>
<HTML lang="<%=lang%>">
<head>
    <% if(null != XUACompatible && XUACompatible.length() > 0) {%>
    <meta http-equiv="X-UA-Compatible" content="<%=XUACompatible%>"/>
    <%}%>
    <META http-equiv="Content-Type" content="text/html; charset=<%=charSet%>">
    <meta http-equiv="Expires" CONTENT="0">
    <meta http-equiv="Cache-Control" CONTENT="no-cache">
    <meta http-equiv="Pragma" CONTENT="no-cache">
	<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
    <title>
        <%=res.getString(lang, StringUtility.STRINGTABLE, "TTL_CMM_WELCOME_BIZFLOW2000")%>
    </title>
    <%
        if (targetUrl.length() == 0 && "ON".equalsIgnoreCase(bizflowProps.getProperty("com.hs.bf.web.parameterFilter"))
                && !"OFF".equalsIgnoreCase(bizflowProps.getProperty("com.hs.bf.web.parameterFilter.precheck"))) {
    %>
    <script language="javascript">
        try {
            if (top.frames.length!=0) {
                top.location=self.document.location;
            }
        }catch(e) {
        }
    </script>
    <%
        }
    %>
    <bf:theme.link href="common.css" rel="stylesheet" type="text/css"/>
	<%
	boolean showError = true;
	if (errorNumber == 3103)
	{
	    String loginType = hwiniSystem.getValue("AUTHENTICATION", "SSO");
	    if ("SPNEGO".equals(loginType) || "BIZFLOWSSO".equals(loginType))
	    {
	        // Don't show error 3103 if SPNEGO is enabled. Just log in.
	        showError = false;
	    }
	}
    String contextURI = contextPath + workAreaPageUri;
    if(null != ssoTargetUrl && ssoTargetUrl.length() > 0) {
        if(ssoTargetUrl.startsWith("/")) {
            contextURI = ssoTargetUrl;
        } else {
            contextURI = contextPath + "/" + ssoTargetUrl;
        }
    }
	%>

	<% if (showError) { %>
	<bf:hwerror lang="<%=lang%>" number="<%=errorNumber%>" message="<%=msgError%>" errorpage="/common/gotoindex.jsp"/>
	<% } %>
    <bf:script src="/includes/bfcommon.js"/>
    <bf:script src="/js/jquery/jquery-1.7.2.min.js"/>
	<script type="text/javascript">
	
		var currentMemberID = '<%=hwSessionInfo.get("USERID")%>';	//parameter for BizCove custom actions

        function refreshPage() {
            _reload();
        }
		
		function _reload()
		{
			disableForceLogOutOnExit();
			this.location.href = this.location.href; //bug17724
		}

        var forceLogOutOnExit = true;
        function disableForceLogOutOnExit() {
            forceLogOutOnExit = false;
        }

        function forceLogOut(){
            if(forceLogOutOnExit)
            {
                forceLogOutOnExit = false;
                var w = 1;
                var h = 1;
                var l = screen.width * 2;
                var t = screen.height * 2;
                var win = window.open("<%=contextPath%>/forcelogout.jsp?t=" + (new Date()).getTime(), "forcelogout",
                        "_menubar=no,_status=no,_toolbar=no,_resizable=no,_scrollbars=no,left=" + l + ",top=" + t + ",width=" + w + ",height=" + h);
//				if(window.localStorage){localStorage.removeItem('<%=hwSessionInfo.get("UserID")%>.WIH.lastUpdatedTime');}
            }
        }

        function setWorkAreaSize() {
            $("#workAreaFrame").height($(window).height());
        }
        var currentHeight;
        $(document).ready(function () {
            init();
            $(window).resize(function () { // The resize event with IE8 is fired again and again and again (infinite loop)!
                var windowHeight = $(window).height();
                if(currentHeight == undefined || currentHeight != windowHeight) {
                    modalWindowOnResize();
                    setWorkAreaSize();
                    currentHeight = windowHeight;
                }
            });
        });

		function init()
		{
			<%if(useAccessibility){%>
                enableAccessibility();
			<%}%>

			if(window.sessionStorage)
			{
				if(!sessionStorage.getItem('HWSESSIONINFO'))
				{
					forceLogOutOnExit = false;
					alert('<%=res.getString(lang, "stringtable", "MSG_MULTIPLE_OPEN_BIZFLOW")%>');
					window.close();
					document.write('<%=res.getString(lang, "stringtable", "MSG_CLOSE_THIS_WINDOW")%>');
				}
			}
			setWorkAreaSize();
		}
    </script>
</head>
<body style="margin:0;padding:0;overflow:hidden;" onunload="forceLogOut();">
<table id="workAreaContainer" cellpadding="0" cellspacing="0" board="0" width="100%" height="100%">
    <tr>
        <td>
            <iframe id="workAreaFrame" NAME="fralist" TITLE="Work Area" SRC="<%=contextURI%>"
                    marginheight="0" marginwidth="0" scrolling="auto" border="0" width="100%" height="100%" frameborder="0" framespacing="0" NORESIZE></iframe>
            <iframe NAME="fraHidden" TITLE="No user content" SRC="<%=contextPath%>/hidden.jsp?patchModuleType=<%=patchModuleType%>&clearTemp=y" style="display:none"
                    marginheight="0" marginwidth="0" scrolling="no" border="0" width="0" height="0" frameborder="0" framespacing="0" NORESIZE aria-hidden="true"></iframe>
            </td>
        </tr>
</table>

<%@ include file="includes/modalpopup/modalpopupmaxes.jsp" %>
<%@ include file="solutions/disclaimer/disclaimer.jsp" %>

</body>
</html>

<% if (logger.isDebugEnabled()) logger.debug(request.getRequestURI() + " " + (System.currentTimeMillis() - startedTime) + " ms"); %>
