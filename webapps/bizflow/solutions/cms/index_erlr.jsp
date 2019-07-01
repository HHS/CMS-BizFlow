<%@page import="com.hs.ja.security.SecurityUtil"%>
<%@ page import="com.hs.frmwk.web.locale.HWEncoder, com.hs.frmwk.web.util.StringUtility, java.util.*"%>
<%@ page import="com.hs.bf.web.session.security.SecuritySessionManager" %>
<%@ page import="com.hs.ja.web.servlet.Browser" %>
<%@ page import="com.hs.ja.web.servlet.BrowserDetector" %>
<%@ page import="com.hs.ja.web.servlet.ServletUtil" %>
<%@ page import="java.sql.*" %>

<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>
<%@ page import="javax.servlet.ServletException" %>
<%@ page import="javax.servlet.annotation.WebServlet" %>
<%@ page import="javax.servlet.http.HttpServlet" %>
<%@ page import="javax.servlet.http.HttpServletRequest" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>
<%@ page import="javax.sql.DataSource" %>

<!-- <%@ page import="java.sql.Timestamp" %> -->
<%@ page import="com.hs.frmwk.db.*" %>
<%@ taglib prefix="bf" uri="/WEB-INF/bizflow.tld" %>

<%! static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger("JSP.bizflow"); %>

<%
long startedTime = 0;
if (logger.isDebugEnabled()) startedTime = System.currentTimeMillis();
%>

<jsp:useBean id="res" class="com.hs.bf.web.xslt.resource.ResourceBag" scope="application"/>
<jsp:useBean id="bizflowProps" class="com.hs.bf.web.props.Properties" scope="application"/>
<jsp:useBean id="hwSessionFactory" class="com.hs.bf.web.beans.HWSessionFactory" scope="application"/>
<jsp:useBean id="hwSessionInfo" class="com.hs.bf.web.beans.HWSessionInfo" scope="session"/>
<jsp:useBean id="hwiniSystem" class="com.hs.frmwk.common.ini.IniFile" scope="application"/>

<bf:parameter id="CURUSERID" name="CURUSERID" value="" valuePattern="Alphabet"/>
<bf:parameter id="SESSION" name="SESSION" value="" valuePattern="Alphabet"/>
<bf:parameter id="CURUSERNAME" name="CURUSERNAME" value="" valuePattern="Alphabet"/>
<bf:parameter id="CURLOGINID" name="CURLOGINID" value="" valuePattern="Alphabet"/>
<bf:parameter id="REPORTNAME" name="REPORTNAME" value="" valuePattern="Alphabet"/>
<bf:parameter id="REPORTPATH" name="REPORTPATH" value="" valuePattern="Alphabet"/>
<bf:parameter id="OPTION" name="OPTION" value="" valuePattern="Alphabet"/>
<bf:parameter id="DATELABEL" name="DATELABEL" value="" valuePattern="Alphabet"/>
<bf:parameter id="DESCRIPTION" name="DESCRIPTION" value="" valuePattern="Alphabet"/>

<%!
private Connection getBizFlowDBConnection() throws Exception {
    Context initContext = new InitialContext();
    Context envContext = (Context)initContext.lookup("java:/comp/env");
    javax.sql.DataSource ds = (javax.sql.DataSource)envContext.lookup("jdbc/workflowdb");
    Connection conn = ds.getConnection();

    return conn;
}

private String getCMSUserGroups() throws Exception
{
    String query = "select c.memberid as grpid, c.name as grpname, a.memberid, a.name from bizflow.member a " + 
                    "join bizflow.usrgrpprtcp b on b.prtcp = a.memberid " + 
                    "join bizflow.member c on c.memberid = b.usrgrpid " + 
                    "join bizflow.member d on c.deptid = d.memberid and d.name = 'CMS' and d.type = 'H'";

    Connection conn = getBizFlowDBConnection();
    Statement stmt = null;
    StringBuilder sb = new StringBuilder();

    try {
        stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(query);

        sb.append("{\"groups\": [");
        boolean isFirst = true;
        
        while (rs.next()) {
            if (isFirst == false) {
                sb.append(",");
            }
            
            String grpid = rs.getString("grpid");
            String grpname = rs.getString("grpname");
            grpname = grpname.replaceAll("'","\\\\'");
            String memberid = rs.getString("memberid");
            String name = rs.getString("name");
            name = name.replaceAll("'","\\\\'");

            sb.append("{");
            sb.append("\"grpid\":\"").append(grpid).append("\",");
            sb.append("\"grpname\":\"").append(grpname).append("\",");
            sb.append("\"memberid\":\"").append(memberid).append("\",");
            sb.append("\"name\":\"").append(name).append("\"");
            sb.append("}");
            isFirst = false;
        }

        sb.append("]}");

    } catch (SQLException e) {
        e.printStackTrace();
        throw e;
    } finally {
        if (stmt != null) {
            stmt.close();
        }
        if (conn != null) {
            conn.close();
        }
    }

    return sb.toString();
}

private String getERLRStatus() throws Exception
{
    String query = "SELECT TBL_LABEL FROM HHS_CMS_HR.TBL_LOOKUP WHERE TBL_LTYPE = 'ERLRInitialResponseCasesStatus' AND TBL_ACTIVE = 1 ORDER BY TBL_NAME ";

    Connection conn = getBizFlowDBConnection();
    Statement stmt = null;
    StringBuilder sb = new StringBuilder();

    try {
        stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(query);

        sb.append("[");
        boolean isFirst = true;
        
        while (rs.next()) {
            if (isFirst == false) {
                sb.append(",");
            }
            
            String label = rs.getString("TBL_LABEL");

            sb.append("\"").append(label).append("\"");
            isFirst = false;
        }

        sb.append("]");

    } catch (SQLException e) {
        e.printStackTrace();
        throw e;
    } finally {
        if (stmt != null) {
            stmt.close();
        }
        if (conn != null) {
            conn.close();
        }
    }

    return sb.toString();
}

private String getERLRTypes() throws Exception
{
    String query = "SELECT P.TBL_NAME PARENTNAME, T.TBL_ID ID, T.TBL_PARENT_ID PARENTID, T.TBL_LTYPE TYPE, T.TBL_NAME NAME " +
                   "FROM HHS_CMS_HR.TBL_LOOKUP T " +
                   "INNER JOIN HHS_CMS_HR.TBL_LOOKUP P ON T.TBL_PARENT_ID = P.TBL_ID AND P.TBL_LTYPE = 'ERLRInitialResponseCaseType' AND P.TBL_ACTIVE = '1' " +
                   "WHERE T.TBL_LTYPE in ('ERLRCasesCompletedFinalAction','ERLRCaseCategory') " +
                   "AND NOT(T.TBL_LTYPE = 'ERLRCasesCompletedFinalAction' AND P.TBL_NAME = 'Third Party Hearing') " +
                   "AND T.TBL_ACTIVE = '1' " +
                   "AND T.TBL_CATEGORY = 'ERLR' " +
                   "UNION ALL " +
                   "SELECT  distinct P2.TBL_NAME PARENTNAME, 0 ID, P2.TBL_ID PARENTID, T.TBL_LTYPE TYPE, T.TBL_NAME NAME " +
                   "FROM HHS_CMS_HR.TBL_LOOKUP T " +
                   "INNER JOIN HHS_CMS_HR.TBL_LOOKUP P1 ON T.TBL_PARENT_ID = P1.TBL_ID AND P1.TBL_ACTIVE = '1' " +
                   "INNER JOIN HHS_CMS_HR.TBL_LOOKUP P2 ON P1.TBL_PARENT_ID = P2.TBL_ID AND P2.TBL_ACTIVE = '1' " +
                   "WHERE T.TBL_LTYPE = 'ERLRCasesCompletedFinalAction' " +
                   "AND P1.TBL_LTYPE = 'ERLRCasesCompletedFinalAction' " +
                   "AND P2.TBL_LTYPE = 'ERLRInitialResponseCaseType' " +
                   "AND P2.TBL_NAME = 'Third Party Hearing' " +
                   "AND T.TBL_ACTIVE = '1' " +
                   "AND T.TBL_CATEGORY = 'ERLR' ";

    Connection conn = getBizFlowDBConnection();
    Statement stmt = null;
    StringBuilder sb = new StringBuilder();

    try {
        stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(query);

        sb.append("{\"erlrType\": [");
        boolean isFirst = true;
        
        while (rs.next()) {
            if (isFirst == false) {
                sb.append(",");
            }
            
            String pName = rs.getString("PARENTNAME");
            String ID = rs.getString("ID");
            String pID = rs.getString("PARENTID");
            String type = rs.getString("TYPE");
            String name = rs.getString("NAME");
            name = name.replaceAll("'","\\\\'");

            sb.append("{");
            sb.append("\"PNAME\":\"").append(pName).append("\",");
            sb.append("\"PID\":\"").append(pID).append("\",");
            sb.append("\"ID\":\"").append(ID).append("\",");
            sb.append("\"TYPE\":\"").append(type).append("\",");
            sb.append("\"NAME\":\"").append(name).append("\"");
            sb.append("}");
            isFirst = false;
        }

        sb.append("]}");

    } catch (SQLException e) {
        e.printStackTrace();
        throw e;
    } finally {
        if (stmt != null) {
            stmt.close();
        }
        if (conn != null) {
            conn.close();
        }
    }

    return sb.toString();
}

%>

<%
    String groupResult = bizflowProps.getProperty("cms.userGroup");
    if (groupResult == null || groupResult.length() <= 0) {
        System.out.println("cms.userGroup is null or empty");
        groupResult = getCMSUserGroups();
        bizflowProps.setProperty("cms.userGroup", groupResult);
    } else {
        System.out.println("Using cached cms.userGroup");
    }


    String erlrType = bizflowProps.getProperty("cms.erlrType");
    if (erlrType == null || erlrType.length() == 0) {
        System.out.println("cms.erlrType is null or empty");
        erlrType = getERLRTypes();
        bizflowProps.setProperty("cms.erlrType", erlrType);
    } else {
        System.out.println("Using cached cms.erlrType");
    }

    String erlrCaseStatus = bizflowProps.getProperty("cms.erlrCaseStatus");
    if (erlrCaseStatus == null || erlrCaseStatus.length() == 0) {
        System.out.println("cms.erlrCaseStatus is null or empty");
        erlrCaseStatus = getERLRStatus();
        bizflowProps.setProperty("cms.erlrCaseStatus", erlrCaseStatus);
    } else {
        System.out.println("Using cached cms.erlrCaseStatus");
    }

%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CMS Report Filter</title>
    <script>document.write('<base href="' + document.location + '" />');</script>
    <link rel="stylesheet" href="./bower_components/bootstrap/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="./bower_components/angular-inform/dist/angular-inform.min.css">
    <link rel="stylesheet" href="./bower_components/angular-ui-select/dist/select.css">
    <link rel="stylesheet" href="./bower_components/angular-block-ui/dist/angular-block-ui.min.css">
    <link rel="stylesheet" href="./bower_components/angular-ui-grid/ui-grid.css">
    <link rel="stylesheet" href="./bower_components/json-formatter/dist/json-formatter.min.css">
    <!-- <link rel="stylesheet" href="./bower_components/jstree/dist/themes/default/style.min.css"> -->
    <link rel="stylesheet" href="./bower_components/selectize/dist/css/selectize.bootstrap3.css ">

    <link rel="stylesheet" href="common/css/bootstrap-ext.css">
    <link rel="stylesheet" href="common/css/app.css">


    <script src="./bower_components/jquery/dist/jquery.min.js"></script>
    <script src="./bower_components/jquery-ui/jquery-ui.min.js"></script>
    <script src="./bower_components/lodash/dist/lodash.min.js"></script>
    <script src="./bower_components/microplugin/src/microplugin.js"></script>
    
    <script src="./bower_components/bootstrap/dist/js/bootstrap.min.js"></script>
    <script src="./bower_components/sifter/sifter.js"></script>
    <script src="./bower_components/selectize/dist/js/selectize.js"></script>
    <script src="./bower_components/angular/angular.min.js"></script>
    <script src="./bower_components/angular-selectize2/dist/angular-selectize.js"></script>
    <!-- <script src="./bower_components/angular-aria/angular-aria.min.js"></script> -->
    <script src="./bower_components/angular-route/angular-route.min.js"></script>
    <script src="./bower_components/angular-cookies/angular-cookies.min.js"></script>
    <script src="./bower_components/angular-inform/dist/angular-inform.min.js"></script>
    <script src="./bower_components/angular-animate/angular-animate.min.js"></script>
    <script src="./bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js"></script>
    <script src="./bower_components/angular-ui-select/dist/select.min.js"></script>
    <script src="./bower_components/angular-file-upload/dist/angular-file-upload.min.js"></script>
    <script src="./bower_components/angular-block-ui/dist/angular-block-ui.min.js"></script>
    <script src="./bower_components/angular-sanitize/angular-sanitize.min.js"></script>
    <script src="./bower_components/angular-messages/angular-messages.min.js"></script>
    <script src="./bower_components/x2js/xml2json.min.js"></script>
    <!-- <script src="./bower_components/json-formatter/dist/json-formatter.min.js"></script> -->
    <script src="./bower_components/angular-ui-grid/ui-grid.min.js"></script>
    <script src="./bower_components/bootbox/bootbox.js"></script>
    <!-- <script src="./bower_components/jstree/dist/jstree.min.js"></script> -->

    <script src="./common/common.js"></script>
    <script src="./common/js/angular-ext.js"></script>
    <script src="./common/js/angular-bizflow.js"></script>
    <script src="./common/js/basicwihactionclient.js"></script>

    <script src="./common/services/angular-bizflow-service.js"></script>

    <script src="./common/components/common.components.js"></script>
    <script src="./common/components/common.directive.js"></script>
    <script src="./common/components/calendar/directive-calendar.js"></script>
    <script src="./common/components/attachment/attachment.js"></script>
    <script src="./common/components/titlebar/directive-titlebar.js"></script>
    <script src="./common/components/infobar/directive-infobar.js"></script>
    <script src="./common/components/csvtodata/directive-csvtodata.js"></script>
    <script src="section508.js"></script>
    <script src="app.main.js"></script>
    <script src="features/reportFilter/report-filter-erlr.js"></script>
</head>
<script language="javascript">
<!--
CMS_REPORT_FILTER = {};
CMS_REPORT_FILTER.CURUSERID = "<%= CURUSERID %>";
CMS_REPORT_FILTER.CURUSERNAME = "<%= CURUSERNAME %>";
CMS_REPORT_FILTER.CURLOGINID = "<%= CURLOGINID %>";
CMS_REPORT_FILTER.SESSION = '<%= SESSION %>';    
CMS_REPORT_FILTER.REPORTNAME = '<%= REPORTNAME %>';
CMS_REPORT_FILTER.GROUPS = '<%= groupResult %>';
CMS_REPORT_FILTER.REPORTPATH = '<%= REPORTPATH %>';
CMS_REPORT_FILTER.DESCRIPTION = '<%= DESCRIPTION %>';

CMS_REPORT_FILTER.LABEL = {};
CMS_REPORT_FILTER.LABEL.DATE = '<%= DATELABEL %>';

CMS_REPORT_FILTER.ERLRTYPE = '<%= erlrType %>';

CMS_REPORT_FILTER.ERLRCASESTATUS = '<%= erlrCaseStatus %>';

-->    
</script>

<body ng-app="bizflow.app" ng-controller="CtrlAppMain">

<ng-view></ng-view>

<div block-ui="main" class="block-ui-main"></div>
<div inform class="inform-fixed inform-shadow inform-animate"></div>
</body>

</html>
