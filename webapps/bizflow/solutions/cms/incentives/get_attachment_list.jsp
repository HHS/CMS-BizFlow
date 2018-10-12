<%@ page import="com.hs.bf.wf.jo.HWAttachment" %>
<%@ page import="com.hs.bf.wf.jo.HWAttachments" %>
<%@ page import="com.hs.bf.wf.jo.HWAttachmentsImpl" %>
<%@ page import="com.hs.frmwk.json.JSONArray" %>
<%@ page import="com.hs.frmwk.json.JSONObject" %>
<%@ page import="java.util.Date" %>
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
    JSONArray jsonArray = new JSONArray();

    try {
        int nProcessId = Integer.parseInt(processid);
        HWAttachments attachments = new HWAttachmentsImpl(hwSessionInfo.toString(), nProcessId, true);
        int count = attachments.getCount();
        for (int i = 0; i < count; i++) {
            HWAttachment hwAttachment = attachments.getItem(i);
            Date creationDate = hwAttachment.getCreationDate();
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("ID", hwAttachment.getID());
            jsonObject.put("SERVERID", hwAttachment.getServerID());
            jsonObject.put("TYPE", hwAttachment.getType());
            jsonObject.put("PROCESSID", hwAttachment.getProcessID());
            jsonObject.put("FILENAME", hwAttachment.getFileName());
            jsonObject.put("DISPLAYNAME", hwAttachment.getDisplayName());
            jsonObject.put("CATEGORY", hwAttachment.getCategory());
            jsonObject.put("_creationDate", null != creationDate ? creationDate.getTime() : 0);
            jsonObject.put("CREATORNAME", hwAttachment.getCreatorName());
            jsonObject.put("DESCRIPTION", hwAttachment.getDescription());
            jsonArray.put(jsonObject);
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
        ret.put("attachments", jsonArray);
    }

    out.clear();
    response.setContentType("application/json; charset=UTF-8");
    out.write(ret.toString());
%>