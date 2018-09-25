<%@ page import="com.hs.bf.wf.jo.HWAttachments" %>
<%@ page import="com.hs.bf.wf.jo.HWAttachmentsImpl" %>
<%@ page import="com.hs.frmwk.json.JSONObject" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="/WEB-INF/bizflow.tld" prefix="bf" %>

<jsp:useBean id="bizflowProps" class="com.hs.bf.web.props.Properties" scope="application"/>
<jsp:useBean id="hwSessionFactory" class="com.hs.bf.web.beans.HWSessionFactory" scope="application"/>
<jsp:useBean id="hwSessionInfo" class="com.hs.bf.web.beans.HWSessionInfo" scope="session"/>
<jsp:useBean id="hwiniSystem" class="com.hs.frmwk.common.ini.IniFile" scope="application"/>

<bf:parameter id="processid" name="pid" value="" valuePattern="NoRiskyValue"/><%--madatory--%>

<%@ include file="./sslinit.jsp" %>
<%!
    static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger("JSP");
%>

<%
    String errorMsg = null;
    JSONObject ret = new JSONObject();

    try {
        int nProcessId = Integer.parseInt(processid);
        HWAttachments attachments = new HWAttachmentsImpl(hwSessionInfo.toString(), nProcessId, true);
        int count = attachments.getCount();
        if (count > 0) {
            for (int i = count - 1; i >= 0; i--) {
                attachments.remove(i);
            }

            attachments.update();
        }
    } catch (Exception e) {
        log.error(e);
        errorMsg = getOriginalExceptionMessage(e);
    }

    if (errorMsg != null) {
        ret.put("success", false);
        ret.put("message", errorMsg);
    } else {
        ret.put("success", true);
    }

    out.clear();
    response.setContentType("application/json; charset=UTF-8");
    out.write(ret.toString());
%>