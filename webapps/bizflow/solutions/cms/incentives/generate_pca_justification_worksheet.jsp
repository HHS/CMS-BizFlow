<%@ page import="com.hs.bf.web.beans.HWFilter" %>
<%@ page import="com.hs.bf.web.beans.HWSession" %>
<%@ page import="com.hs.bf.web.beans.HWSessionInfo" %>
<%@ page import="com.hs.bf.web.xmlrs.XMLResultSet" %>
<%@ page import="com.hs.bf.web.xmlrs.XMLResultSetImpl" %>
<%@ page import="com.hs.bf.wf.jo.HWAttachment" %>
<%@ page import="com.hs.bf.wf.jo.HWAttachments" %>
<%@ page import="com.hs.bf.wf.jo.HWAttachmentsImpl" %>
<%@ page import="com.hs.frmwk.json.JSONObject" %>
<%@ page import="com.hs.ja.web.servlet.ServletUtil" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.Properties" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="/WEB-INF/bizflow.tld" prefix="bf" %>

<jsp:useBean id="bizflowProps" class="com.hs.bf.web.props.Properties" scope="application"/>
<jsp:useBean id="hwSessionFactory" class="com.hs.bf.web.beans.HWSessionFactory" scope="application"/>
<jsp:useBean id="hwSessionInfo" class="com.hs.bf.web.beans.HWSessionInfo" scope="session"/>
<jsp:useBean id="hwiniSystem" class="com.hs.frmwk.common.ini.IniFile" scope="application"/>

<bf:parameter id="processid" name="pid" value="" valuePattern="NoRiskyValue"/><%--madatory--%>
<bf:parameter id="activityid" name="aseq" value="" valuePattern="NoRiskyValue"/><%--madatory--%>
<bf:parameter id="workitemseq" name="wseq" value="" valuePattern="NoRiskyValue"/><%--madatory--%>
<bf:parameter id="reqNum" name="rn" value="" valuePattern="NoRiskyValue"/><%--madatory--%>

<%@ include file="./sslinit.jsp" %>

<%!
    static final String DEFAULT_DOCUMENT_TYPE = "PD Coversheet/OF-8";
    static final String DEFAULT_FILE_NAME = "PCA Justification Worksheet.pdf";
    static final String RUNNING_PROCESS_STATE = "R";
    static Properties properties = null;

    static final String REPORT_URL = "{REPORTSERVERURL}/rest_v2/reports{PATH}.{FILEFORMAT}?j_memberid={J_MEMBERID}&j_username={J_USERNAME}&reqNum={REQ_NUM}";

    static org.apache.log4j.Logger log = org.apache.log4j.Logger.getLogger("JSP");

    void loadProperties(ServletContext application) {
        try {
            if (null == properties) {
                properties = new Properties();
                properties.load(new FileInputStream(ServletUtil.getRealPath(application, "/solutions/cms/incentives/incentives.properties")));
            }
        } catch (Exception e) {
        }
    }

    File downloadWorksheet(HttpServletRequest request, String reportServerURL, String path, String fileFormat, String jMemberId, String jUserName, String reqNum) {
        File fp = null;
        try {
            initSSLEx(request, reportServerURL);

            String url = REPORT_URL;
            url = StringUtils.replace(url, "{REPORTSERVERURL}", reportServerURL);
            url = StringUtils.replace(url, "{PATH}", path);
            url = StringUtils.replace(url, "{FILEFORMAT}", fileFormat);
            url = StringUtils.replace(url, "{J_MEMBERID}", jMemberId);
            url = StringUtils.replace(url, "{J_USERNAME}", jUserName);
            url = StringUtils.replace(url, "{REQ_NUM}", reqNum);

            java.net.URL agent = new java.net.URL(url);

            InputStream inputStream = null;
            FileOutputStream fos = null;
            fp = File.createTempFile("ihs_", ".pdf");

            try {
                inputStream = new BufferedInputStream(agent.openStream());
                fos = new FileOutputStream(fp);
                byte[] buffer = new byte[1024];
                int len = 0;
                while ((len = inputStream.read(buffer)) != -1) {
                    fos.write(buffer, 0, len);
                }
            } catch (IOException e) {
                log.error("Error during the downloading the Worksheet report file. (url=" + url + ")", e);
                fp = null;
            } finally {
                if (inputStream != null) try {
                    inputStream.close();
                } catch (Exception be) {
                }
                ;
                if (fos != null) try {
                    fos.close();
                } catch (Exception we) {
                }
                ;
            }
        } catch (Exception e) {
            log.error(e);
        }

        return fp;
    }

    XMLResultSet getProcess(HWSession hwSession, HWSessionInfo hwSessionInfo, int processId) throws Exception {
        HWFilter filter = new HWFilter();
        filter.setName("HWProcess");
        filter.addFilter("ServerID", "E", hwSessionInfo.getServerID());
        filter.addFilter("ID", "E", Integer.toString(processId));
        XMLResultSet xrs = new XMLResultSetImpl();
        xrs.parse(hwSession.getProcesses(hwSessionInfo.toString(), filter.toByteArray()));
        return xrs;
    }
%>
<%
    String errorMsg = null;
    JSONObject ret = new JSONObject();
    HWSession hwSession = hwSessionFactory.newInstance();
    XMLResultSet loginUser = null;
    int nProcessId = -1;
    int nActivityId = -1;
    boolean success = true;
    String documentType = null;
    String fileName = null;
    String reportPath = null;
    String fileFormat = "pdf";
    String reportServerURL = null;
    boolean overwrite = !"false".equalsIgnoreCase(request.getParameter("ow"));

    try {
        loadProperties(application);

        // Validation
        loginUser = (XMLResultSet) session.getAttribute("LoginUser");
        nProcessId = Integer.parseInt(processid);
        nActivityId = Integer.parseInt(activityid);
        reportServerURL = properties.getProperty("report.server.url", "https://localhost/bizflowadvreport");
        documentType = properties.getProperty("report.PCAJustificationWorksheet.documentType", DEFAULT_DOCUMENT_TYPE);
        fileName = properties.getProperty("report.PCAJustificationWorksheet.fileName", DEFAULT_FILE_NAME);
        reportPath = properties.getProperty("report.PCAJustificationWorksheet.path");

        XMLResultSet xrsProcess = getProcess(hwSession, hwSessionInfo, nProcessId);
        int cnt = xrsProcess.getRowCount();
        if (cnt == 0 || !RUNNING_PROCESS_STATE.equals(xrsProcess.getFieldValueAt(0, "STATE"))) {
            success = false;
            errorMsg = "Invalid Request.";
        }

        if (success) {
            HWAttachments attachments = new HWAttachmentsImpl(hwSessionInfo.toString(), nProcessId, false);
            int count = attachments.getCount();
            for (int i = 0; i < count; i++) {
                HWAttachment attachment = attachments.getItem(i);
                if (documentType.equalsIgnoreCase(attachment.getCategory())) {
                    if (overwrite) {
                        attachments.remove(i);
                        attachments.update();
                    } else {
                        errorMsg = "Requested document type (" + documentType + ") has already been attached.";
                        success = false;
                    }
                    break;
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        log.error(e);
        errorMsg = "Invalid parameters.";
        success = false;
    }

    if (success) {
        try {
            // download Worksheet report file
            String jMemberID = loginUser.getFieldValueAt(0, "ID");
            String jUserName = loginUser.getFieldValueAt(0, "LOGINID");
            File worksheetFile = downloadWorksheet(request, reportServerURL, reportPath, fileFormat, jMemberID, jUserName, reqNum);
            if (worksheetFile != null && 0 < worksheetFile.length()) {
                // Attach to process
                XMLResultSet xrs = new XMLResultSetImpl();
                xrs.createResultSet("HWAttachments", "HWATTACHMENT");
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
                xrs.setFieldValueAt(r, "CATEGORY", documentType);
                xrs.setFieldValueAt(r, "DISPLAYNAME", fileName);
                xrs.setFieldValueAt(r, "FILENAME", fileName);
                xrs.setFieldValueAt(r, "SIZE", String.valueOf(worksheetFile.length()));

                String[] attachFiles = {worksheetFile.getPath()};
                hwSession.updateAttachments(hwSessionInfo.toString(),
                        hwSessionInfo.getServerID(),
                        nProcessId,
                        nActivityId,
                        xrs.toByteArray(),
                        attachFiles);

                worksheetFile.delete();
            } else {
                errorMsg = "[Internal Error] Cannot create an PCA Justification Worksheet.";
            }

        } catch (Exception e) {
            errorMsg = "[Internal Error] " + e.getMessage();
            log.error(e);
        }
    }

    if (errorMsg != null) {
        ret.put("success", false);
        ret.put("message", errorMsg);
    } else {
        ret.put("success", true);
        ret.put("fileName", fileName);
    }
    out.clear();
    response.setContentType("application/json; charset=UTF-8");
    out.write(ret.toString());
%>