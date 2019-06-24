<%@ taglib prefix="t" uri="http://tiles.apache.org/tags-tiles" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="authz"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib uri="/spring" prefix="spring"%>

<%@page import="java.util.*" %>
<!-- SECTION 508 CMS BEGIN //-->
<script language="javascript">
<!--
<%
	String _paramBf508Enbabled = request.getParameter("_bf508");
	String _paramBfUserTimezone = request.getParameter("_bfUserTimezone");
	String _paramReportUnit = request.getParameter("reportUnit");
	if (null == _paramBf508Enbabled) _paramBf508Enbabled = "";
	if (null == _paramBfUserTimezone) _paramBfUserTimezone = "";
	if (null == _paramReportUnit) _paramReportUnit = "";
%>
	var _bf508Enbabled = "<%=_paramBf508Enbabled%>".toLowerCase();
	var _bfUserTimezone = "<%=_paramBfUserTimezone%>";
	var _bfReportUnit = "<%=_paramReportUnit%>";
//-->
</script>
<!-- SECTION 508 CMS END //-->
<t:insertTemplate template="/WEB-INF/jsp/templates/page.jsp">
    <t:putAttribute name="pageTitle"><spring:message code='ADH_700_DASHBOARD_VIEWER_TITLE'/></t:putAttribute>

    <t:putAttribute name="bodyID">dashboard</t:putAttribute>
    <t:putAttribute name="bodyClass" value="oneColumn dashboardViewer"/>

    <c:if test='${!empty param.viewAsDashboardFrame && param.viewAsDashboardFrame != "false"}'>
        <t:putAttribute name="moduleName" value="dashboardViewerBarePage"/>
    </c:if>
    <c:if test='${empty param.viewAsDashboardFrame || param.viewAsDashboardFrame == "false"}'>
        <t:putAttribute name="moduleName" value="dashboardViewerPage"/>
    </c:if>

    <t:putAttribute name="headerContent">
        <c:if test='${!empty param.viewAsDashboardFrame && param.viewAsDashboardFrame != "false"}'>
            <!--in case of frame decorators do not work, so need to load config manually-->
            <jsp:include page="/WEB-INF/jsp/modules/common/jrsConfigs.jsp"/>
			
            <link rel="stylesheet" href="${pageContext.request.contextPath}/themes/reset.css" type="text/css" media="screen">

            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="theme.css"/>" type="text/css" media="screen,print"/>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="pages.css"/>" type="text/css" media="screen,print"/>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="containers.css"/>" type="text/css" media="screen,print"/>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="dialog.css"/>" type="text/css" media="screen,print"/>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="buttons.css"/>" type="text/css" media="screen,print"/>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="lists.css"/>" type="text/css" media="screen,print"/>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="controls.css"/>" type="text/css" media="screen,print"/>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="dataDisplays.css"/>" type="text/css" media="screen,print"/>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="pageSpecific.css"/>" type="text/css" media="screen,print"/>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="dialogSpecific.css"/>" type="text/css" media="screen,print"/>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="forPrint.css"/>" type="text/css" media="print"/>

            <!--[if IE 7.0]>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="overrides_ie7.css"/>" type="text/css" media="screen"/>
            <![endif]-->

            <!--[if IE 8.0]>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="overrides_ie8.css"/>" type="text/css" media="screen"/>
            <![endif]-->

            <!--[if IE]>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="overrides_ie.css"/>" type="text/css" media="screen"/>
            <![endif]-->
            <link rel="stylesheet" href="${pageContext.request.contextPath}/<spring:theme code="overrides_custom.css"/>" type="text/css" media="screen"/>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/scripts/bower_components/jquery-ui/themes/redmond/jquery-ui-1.10.4-custom.css" type="text/css" media="screen">

            <style type="text/css">
                body {background:#fff;}
                .hidden {display:none;}
                .column.decorated.primary {border:none;border-radius:0;}
                .column.decorated.primary>.corner,
                .column.decorated.primary>.edge,
                /*.column.decorated.primary>.content>.header,*/
                .column.decorated.primary>.content .title,
                .column.decorated.primary>.content>.footer {
                    display:none !important;
                }

                .column.decorated.primary,
                .column.decorated.primary>.content,
                .column.decorated.primary>.content>.body {
                    top:0;
                    bottom:0;
                    left:0;
                    right:0;
                    margin:0;
                }

                .filterRow > .inputControlWrapper > div {
                    height: auto !important;
                }
            </style>
					
        </c:if>

	</t:putAttribute>

    <t:putAttribute name="bodyContent">
    </t:putAttribute>
</t:insertTemplate>

