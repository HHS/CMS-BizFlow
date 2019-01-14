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
<bf:parameter id="param1" name="p1" value="" valuePattern="NoRiskyValue"/><%--madatory--%>
<bf:parameter id="overwrite" name="ow" value="true" valuePattern="NoRiskyValue"/><%--madatory--%>

<%@ include file="./sslinit.jsp" %>

<%!
    static final String DEFAULT_DOCUMENT_TYPE = "Leave Enhancement Service Agreement";
    static final String DEFAULT_FILE_NAME = "LE Service Agreement.pdf";
    static final String RUNNING_PROCESS_STATE = "R";
    static Properties properties = null;

    static final String REPORT_URL = "{REPORTSERVERURL}/rest_v2/reports{PATH}.{FILEFORMAT}?j_memberid={J_MEMBERID}&j_username={J_USERNAME}&caseID={PARAM1}";

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

    File downloadWorksheet(HttpServletRequest request, String reportServerURL, String path, String fileFormat, String jMemberId, String jUserName, String param1) {
        File fp = null;
        try {
            initSSLEx(request, reportServerURL);

            String url = REPORT_URL;
            url = StringUtils.replace(url, "{REPORTSERVERURL}", reportServerURL);
            url = StringUtils.replace(url, "{PATH}", path);
            url = StringUtils.replace(url, "{FILEFORMAT}", fileFormat);
            url = StringUtils.replace(url, "{J_MEMBERID}", jMemberId);
            url = StringUtils.replace(url, "{J_USERNAME}", jUserName);
            url = StringUtils.replace(url, "{PARAM1}", param1);

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

    public String getReportServerUrl(HWSession hwSession, HWSessionInfo hwSessionInfo, HttpServletRequest request) {
        InputStream is = null;
        StringBuilder sbUrl = new StringBuilder(50);
        try {
            String requestUrl = request.getRequestURL().toString();
            String requestUri = request.getRequestURI();

            HttpSession session = request.getSession();
            is = hwSession.getExtServers(hwSessionInfo.toString(), "REPORT");

            XMLResultSetImpl xrsReportServerList = new XMLResultSetImpl();
            xrsReportServerList.setLookupField("NAME");
            xrsReportServerList.parse(is);

            int r = xrsReportServerList.lookupField("NAME", "BizFlow Advanced Report Server");
            String url = "/bizflowadvreport";
            if(-1 != r) {
                url = xrsReportServerList.getFieldValueAt(r, "URL");
            }
            if (url.startsWith("http")) {
                sbUrl.append(url);
            } else if (url.startsWith("/")) {
                sbUrl.append(com.hs.frmwk.web.util.StringUtility.replaceAll(requestUrl, requestUri, ""));
                sbUrl.append(url);
            } else {
                sbUrl.append(com.hs.frmwk.web.util.StringUtility.replaceAll(requestUrl, requestUri, ""));
                sbUrl.append("/" + url);
            }
        } catch (Exception e) {
            log.error(e);
        }
        finally {
            if(null != is) {
                try {
                    is.close();
                } catch(Exception ex) {
                    // ignore
                }
            }
        }
        return sbUrl.toString();
    }
%>
<%
    String errorMsg = null;
    JSONObject ret = new JSONObject();
    HWSession hwSession = hwSessionFactory.newInstance();
    XMLResultSet loginUser = null;
    int nProcessId = -1;
    int nActivityId = -1;
    String documentType = null;
    String fileName = null;
    String reportPath = null;
    String fileFormat = "pdf";
    String reportServerURL = getReportServerUrl(hwSession, hwSessionInfo, request);
    boolean isOverwrite = !"false".equalsIgnoreCase(overwrite);

    try {
        loadProperties(application);

        // Validation
        loginUser = (XMLResultSet) session.getAttribute("LoginUser");
        nProcessId = Integer.parseInt(processid);
        nActivityId = Integer.parseInt(activityid);
        //reportServerURL = properties.getProperty("report.server.url", reportServerURL);
        documentType = properties.getProperty("report.LEServiceAgreement.documentType", DEFAULT_DOCUMENT_TYPE);
        fileName = properties.getProperty("report.LEServiceAgreement.fileName", DEFAULT_FILE_NAME);
        reportPath = properties.getProperty("report.LEServiceAgreement.path");

        XMLResultSet xrsProcess = getProcess(hwSession, hwSessionInfo, nProcessId);
        int cnt = xrsProcess.getRowCount();
        if (cnt == 0 || !RUNNING_PROCESS_STATE.equals(xrsProcess.getFieldValueAt(0, "STATE"))) {
            errorMsg = "Invalid Request.";
        }

        if (null == errorMsg) {
            HWAttachments attachments = new HWAttachmentsImpl(hwSessionInfo.toString(), nProcessId, false);
            int count = attachments.getCount();
            for (int i = 0; i < count; i++) {
                HWAttachment attachment = attachments.getItem(i);
                if (documentType.equalsIgnoreCase(attachment.getCategory())) {
                    if (isOverwrite) {
                        attachments.remove(i);
                        attachments.update();
                    } else {
                        errorMsg = "Requested document type (" + documentType + ") has already been attached.";
                    }
                    break;
                }
            }
        }
    } catch (Exception e) {
        log.error(e);
        errorMsg = getOriginalExceptionMessage(e);
    }

    if (null == errorMsg) {
        try {
            // download Worksheet report file
            String jMemberID = loginUser.getFieldValueAt(0, "ID");
            String jUserName = loginUser.getFieldValueAt(0, "LOGINID");
            File worksheetFile = downloadWorksheet(request, reportServerURL, reportPath, fileFormat, jMemberID, jUserName, param1);
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
                errorMsg = "[Internal Error] Cannot create a LE Service Agreement.";
            }

        } catch (Exception e) {
            log.error(e);
            errorMsg = getOriginalExceptionMessage(e);
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