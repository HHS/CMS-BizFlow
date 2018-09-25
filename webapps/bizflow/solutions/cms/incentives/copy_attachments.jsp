<%@ page import="com.hs.bf.web.beans.HWSession" %>
<%@ page import="com.hs.bf.web.xmlrs.XMLResultSet" %>
<%@ page import="com.hs.bf.web.xmlrs.XMLResultSetImpl" %>
<%@ page import="com.hs.bf.wf.jo.HWAttachment" %>
<%@ page import="com.hs.bf.wf.jo.HWAttachments" %>
<%@ page import="com.hs.bf.wf.jo.HWAttachmentsImpl" %>
<%@ page import="com.hs.frmwk.json.JSONArray" %>
<%@ page import="com.hs.frmwk.json.JSONObject" %>
<%@ page import="com.hs.ja.number.NumberUtil" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="/WEB-INF/bizflow.tld" prefix="bf" %>

<jsp:useBean id="bizflowProps" class="com.hs.bf.web.props.Properties" scope="application"/>
<jsp:useBean id="hwSessionFactory" class="com.hs.bf.web.beans.HWSessionFactory" scope="application"/>
<jsp:useBean id="hwSessionInfo" class="com.hs.bf.web.beans.HWSessionInfo" scope="session"/>
<jsp:useBean id="hwiniSystem" class="com.hs.frmwk.common.ini.IniFile" scope="application"/>

<bf:parameter id="srcprocessid" name="spid" value="" valuePattern="NoRiskyValue"/><%--madatory--%>
<bf:parameter id="processid" name="pid" value="" valuePattern="NoRiskyValue"/><%--madatory--%>
<bf:parameter id="activityid" name="aseq" value="" valuePattern="NoRiskyValue"/><%--madatory--%>
<bf:parameter id="workitemseq" name="wseq" value="" valuePattern="NoRiskyValue"/><%--madatory--%>
<bf:parameter id="deleteall" name="da" value="false" valuePattern="NoRiskyValue"/><%--madatory--%>
<bf:parameter id="param" name="param" value="" valuePattern="NoRiskyValue"/><%--madatory--%>

<%@ include file="./sslinit.jsp" %>
<%!
    static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger("JSP");
%>

<%
    String errorMsg = null;
    JSONObject ret = new JSONObject();
    HWSession hwSession = hwSessionFactory.newInstance();
    int nSourceProcessId = -1;
    int nProcessId = -1;
    int nActivityId = -1;
    Map<String, HWAttachment> attachMap = new HashMap();
    String[] attachFiles = null;
    boolean bDeleteAll = "true".equalsIgnoreCase(deleteall);

    try {
        nSourceProcessId = NumberUtil.parseInt(srcprocessid, -1);
        if (nSourceProcessId > -1) {
            nProcessId = Integer.parseInt(processid);
            nActivityId = Integer.parseInt(activityid);
            JSONObject jsonObject = new JSONObject(param);

            JSONArray categories = jsonObject.getJSONArray("categories");
            Map<String, String> categoryMap = new HashMap();
            for (int i = categories.length() - 1; i >= 0; i--) {
                JSONObject category = categories.getJSONObject(i);
                categoryMap.put(category.getString("from"), category.getString("to"));
            }

            {
                HWAttachments attachments = new HWAttachmentsImpl(hwSessionInfo.toString(), nSourceProcessId, false);
                int count = attachments.getCount();
                for (int i = 0; i < count; i++) {
                    HWAttachment attachment = attachments.getItem(i);
                    String toCategory = categoryMap.get(attachment.getCategory());
                    if (null != toCategory) {
                        attachMap.put(toCategory, attachment);
                    }
                }
            }

            if (bDeleteAll) {   // delete all existing attachments
                HWAttachments attachments = new HWAttachmentsImpl(hwSessionInfo.toString(), nProcessId, true);
                int count = attachments.getCount();
                if (count > 0) {
                    for (int i = count - 1; i >= 0; i--) {
                        attachments.remove(i);
                    }

                    attachments.update();
                }
            } else if (attachMap.size() > 0) {  // delete existing category attachments
                boolean deleted = false;
                HWAttachments attachments = new HWAttachmentsImpl(hwSessionInfo.toString(), nProcessId, true);
                int count = attachments.getCount();
                for (int i = count - 1; i >= 0; i--) {
                    HWAttachment attachment = attachments.getItem(i);
                    if (attachMap.containsKey(attachment.getCategory())) {
                        attachments.remove(i);
                        deleted = true;
                    }
                }

                if (deleted) {
                    attachments.update();
                }
            }
        }
    } catch (Exception e) {
        log.error(e);
        errorMsg = getOriginalExceptionMessage(e);
    }

    if (null == errorMsg && attachMap.size() > 0) {
        try {
            Iterator<String> iterator = attachMap.keySet().iterator();

            XMLResultSet xrs = new XMLResultSetImpl();
            xrs.createResultSet("HWAttachments", "HWATTACHMENT");
            List<String> fileList = new ArrayList();

            while (iterator.hasNext()) {
                String category = iterator.next();
                HWAttachment attachment = attachMap.get(category);
                attachment.download();

                int r = xrs.add();
                xrs.setFieldValueAt(r, "SERVERID", hwSessionInfo.getServerID());
                xrs.setFieldValueAt(r, "PROCESSID", processid);
                xrs.setFieldValueAt(r, "ACTIVITYSEQUENCE", activityid);
                xrs.setFieldValueAt(r, "ID", String.valueOf(r));
                xrs.setFieldValueAt(r, "WORKITEMSEQUENCE", workitemseq);
                xrs.setFieldValueAt(r, "TYPE", "G");
                xrs.setFieldValueAt(r, "OUTTYPE", "B");
                xrs.setFieldValueAt(r, "INTYPE", "C");
                xrs.setFieldValueAt(r, "DIGITALSIGNATURE", "N");
                xrs.setFieldValueAt(r, "MAPID", String.valueOf(r));
                xrs.setFieldValueAt(r, "DMDOCRTYPE", "N");
                xrs.setFieldValueAt(r, "CATEGORY", category);
                xrs.setFieldValueAt(r, "DISPLAYNAME", attachment.getDisplayName());
                xrs.setFieldValueAt(r, "FILENAME", attachment.getFileName());
                xrs.setFieldValueAt(r, "SIZE", String.valueOf(attachment.getSize()));

                fileList.add(attachment.getFilePath());
            }

            attachFiles = fileList.toArray(new String[fileList.size()]);

            hwSession.updateAttachments(hwSessionInfo.toString(),
                    hwSessionInfo.getServerID(),
                    nProcessId,
                    nActivityId,
                    xrs.toByteArray(),
                    attachFiles);

        } catch (Exception e) {
            log.error(e);
            errorMsg = getOriginalExceptionMessage(e);
        } finally {
            if (null != attachFiles) {
                for (String filePath : attachFiles) {
                    File file = new File(filePath);
                    file.delete();
                }
            }
        }
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