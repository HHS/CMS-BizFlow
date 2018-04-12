<%@ page import="com.hs.bf.web.xmlrs.XMLResultSet, com.hs.bf.web.xmlrs.XMLResultSetImpl, com.hs.bf.wf.Attachment, com.hs.frmwk.util.StringUtils,  com.hs.frmwk.web.upload.MultipartRequest,java.io.File" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.hs.frmwk.json.JSONArray" %>
<%@ page import="com.hs.ja.file.FileIOUtil" %>
<%@ page import="com.hs.bf.web.util.ParamUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="com.hs.bf.hwsa.HWConstants" %>
<%@ page import="com.hs.frmwk.json.JSONObject" %>
<%@ page import="com.hs.frmwk.json.JSONException" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.hs.bf.web.beans.*" %>
<%@ page import="java.io.IOException" %>
<%@ page import="com.hs.bf.web.wih.BasicHandler" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic"%>
<%@ taglib uri="/WEB-INF/bizflow.tld" prefix="bf" %>
<jsp:useBean id="attachmentSecurity" class="com.hs.bf.web.attach.AttachmentSecurity" scope="application"/>
<jsp:useBean id="res" class="com.hs.bf.web.xslt.resource.ResourceBag" scope="application"/>
<jsp:useBean id="hwSessionInfo" class="com.hs.bf.web.beans.HWSessionInfo" scope="session"/>
<jsp:useBean id="hwiniSystem" class="com.hs.frmwk.common.ini.IniFile" scope="application"/>
<jsp:useBean id="hwSessionFactory" class="com.hs.bf.web.beans.HWSessionFactory" scope="application"/>
<jsp:useBean id="dateFormat" class="com.hs.frmwk.web.util.DateFormatUtil" scope="session"/>
<bf:parameter id="basicWihReadOnly" name="basicWihReadOnly" value="n" valuePattern="Alphabet"/>
<bf:parameter id="isForcedModal" name="isForcedModal" value="false" valuePattern="Boolean"/>
<%!
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger("JSP.bizflow.bizcoves.wih");
    private final static String sStringTable = "stringtable";
    private final static String ACTION_ADD = "add";
    private final static String ACTION_UPDATE = "update";

    public void deleteAttachmentFromProcess(HWSession hwSession, HWSessionInfo hwSessionInfo, int processId, String attId) throws HWException, IOException
    {
        HWFilter filter = new HWFilter();
        filter.addFilter("SERVERID", "E", hwSessionInfo.get("SERVERID"));
        filter.addFilter("PROCESSID", "E", Integer.toString(processId));
        InputStream is = hwSession.getAttachments(hwSessionInfo.toString(), filter.toByteArray());
        XMLResultSet xrs = new XMLResultSetImpl();
        xrs.setLookupField("ID");
        xrs.parse(is);
        is.close();

        int r = xrs.lookupField("ID", attId);

        if (r > -1) {
            xrs.remove(r);
            xrs.setFilter(XMLResultSet.FILTER_DELETED);
            hwSession.updateAttachments(hwSessionInfo.toString(),
                    hwSessionInfo.get("SERVERID"),
                    processId,
                    0,
                    xrs.toByteArray(),
                    null);
        }
    }
	public String saveEdmsMetadata(String jsonStr) throws Exception
	{
		if(jsonStr == null || jsonStr.length() < 5) {
			return null;
		}

		try {
			String propertyName = null;
            JSONArray ja = new JSONArray(jsonStr);

			XMLResultSet xrs = new XMLResultSetImpl();
			xrs.createResultSet("HWMetadata", "HWMETADATA");
            xrs.addField("NAME");
            xrs.addField("VALUE");
            xrs.addField("TYPE");
            xrs.addField("DISPLAYNAME");
            for(int i=0; i < ja.length(); i++) {
                JSONObject jo = ja.getJSONObject(i);
                int index = xrs.add();

                if(jo.has("name")) {
                    xrs.setFieldValueAt(index, "NAME", jo.getString("name"));
                    xrs.setFieldDirty(index, "NAME", XMLResultSet.FIELD_DIRTY_NORMAL);
                } else {
                    throw new RuntimeException("The name attribute not found in metadata object. Object = " + jo.toString());
                }
                if(jo.has("value")) {
                    xrs.setFieldValueAt(index, "VALUE", jo.getString("value"));
                    xrs.setFieldDirty(index, "VALUE", XMLResultSet.FIELD_DIRTY_NORMAL);
                } else {
                    throw new RuntimeException("The value attribute not found in metadata object. Object = " + jo.toString());
                }
                if(jo.has("type")) {
                    xrs.setFieldValueAt(index, "TYPE", jo.getString("type"));
                } else {
                    xrs.setFieldValueAt(index, "TYPE", "Text");
                }

                xrs.setFieldDirty(index, "TYPE", XMLResultSet.FIELD_DIRTY_NORMAL);

                if(jo.has("displayName")) {
                    xrs.setFieldValueAt(index, "DISPLAYNAME", jo.getString("displayName"));
                } else {
                    xrs.setFieldValueAt(index, "DISPLAYNAME", jo.getString("name"));
                }
                xrs.setFieldDirty(index, "DISPLAYNAME", XMLResultSet.FIELD_DIRTY_NORMAL);
                xrs.setRowDirty(index, XMLResultSet.ROW_DIRTY_NORMAL);
            }
			File mf = File.createTempFile("_metadata", ".xml", new File(System.getProperty("java.io.tmpdir")));
			FileIOUtil.write(mf,  xrs.toByteArray());
			return mf.getPath();
		} catch(JSONException je) {
			logger.error("saveMetadata(jsonStr = " + jsonStr + ")" ,je);
            throw je;
		}
	}
    // prior 12.3 version
    public String saveEdmsMetadataOld(String jsonStr)
    {
        if(jsonStr == null || jsonStr.length() < 2) {
            return null;
        }

        try {
            String property = null;
            JSONObject jo = new JSONObject(jsonStr);

            XMLResultSet xrs = new XMLResultSetImpl();
            xrs.createResultSet("HWMetadatas", "HWMETADATA");
            for(Iterator itr = jo.keys(); itr.hasNext();) {
                property = (String)itr.next();
                xrs.addField(property);
            }
            int r = xrs.add();
            for(Iterator itr = jo.keys(); itr.hasNext();) {
                property = (String)itr.next();
                xrs.setFieldValueAt(r, property, (String)jo.get(property));
            }

            File mf = File.createTempFile("_metadata", ".xml", new File(System.getProperty("java.io.tmpdir")));
            FileIOUtil.write(mf,  xrs.toByteArray());
            return mf.getPath();
        } catch(JSONException jo) {
            logger.error("saveMetadata(jsonStr = " + jsonStr + ")" ,jo);
        } catch (Exception e) {

        }
        return null;
    }
%>
<%@ include file="/bizcoves/wih/wih_common.jsp"%>
<%
String language = (String) session.getAttribute("Language");
String charSet = (String) session.getAttribute("LangCharSet");
response.setContentType("text/html;charset=" + charSet);
boolean addFailed = false;
long fileSize = -1;
Attachment att = null;
String attachmentJSONString = "";
int MAX_FILE_SIZE = 50 * 1024 * 1024;
BasicHandler basicWih = getBasicHandler(request, "y".equals(basicWihReadOnly));
String id = "";
String responseType = ""; // empty or "JSON"
String errorMessage = null;
%>
<%
try
{
    HWSession hwSession = hwSessionFactory.newInstance();
    int procId = basicWih.getProcessId();
    int actseq = basicWih.getActivityId();
	int workseq = basicWih.getWorkId();
    String tmpPath = System.getProperty("java.io.tmpdir");
    File lf = new File(tmpPath);
    if (hwiniSystem.containsKey("SYSTEM", "AttachmentMaxSize")) {
        MAX_FILE_SIZE = hwiniSystem.getIntValue("SYSTEM", "AttachmentMaxSize");
    }

    MultipartRequest multi = new MultipartRequest(request, tmpPath, MAX_FILE_SIZE, true, charSet);//hwSessionFactory.getEncodingType());
    id = multi.getParameter("id");

    if (!"".equals(id)) {
        deleteAttachmentFromProcess(hwSession, hwSessionInfo, procId, id);
    }

    XMLResultSet xrs = new XMLResultSetImpl(new XMLStringEncoder() {
        public String encodeXMLString(String source) {
            return defaultEncodeXMLString(source);
        }

        public String encodeXMLStringWithCR(String source) {
            return null;
        }
    });

    responseType = multi.getParameter("responseType");
    String _attachType = multi.getParameter("attachType");

    String attachSeq = multi.getParameter("attachSeq");
    if (StringUtils.isEmpty(attachSeq)) {
        attachSeq = "";
    }

    String description = multi.getParameter("description");
    if (StringUtils.isEmpty(description)) {
        description = "";
    }

    String category = multi.getParameter("category");
    if (StringUtils.isEmpty(category)) {
        category = "";
    }

    String etcInfo = multi.getParameter("etcInfo");
    if (StringUtils.isEmpty(etcInfo)) {
        etcInfo = "";
    }

    String action = multi.getParameter("action"); // action: null, "add", "update"
    if(StringUtils.isEmpty(action)) {
        action = ACTION_ADD;
    } else if(ACTION_UPDATE.equals(action)) {
        if (StringUtils.isEmpty(attachSeq)) {
            // exception
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            if ("JSON".equalsIgnoreCase(responseType)) {
                JSONObject ret = new JSONObject();
                ret.put("success", false);
                ret.put("message", res.getString(language, "exception", "HTTP_400_TEXT"));
                out.clear();
                response.setContentType("text/xml;charset=UTF-8");
                out.write(ret.toString());
            }
            return;
        }
    }

    File f = null;
    String attUrl = null;
    if ("url".equalsIgnoreCase(_attachType)) {
        attUrl = multi.getParameter("attachUrl");
        f = File.createTempFile("_hwmr", ".url", lf);
        String content = "[InternetShortcut]\r\n" + "URL=" + attUrl + "\r\n";
        FileIOUtil.write(f, content.getBytes());
    } else {
        f = multi.getFile(0);
        String attachFileName = f.getName();
        int x = attachFileName.lastIndexOf(".");
        if (x != -1) {
	        String ext = attachFileName.substring(x).toLowerCase();
	        if(!attachmentSecurity.isAllowAttachmentFileType(hwiniSystem, ext)) {
		        throw new RuntimeException("NOT ALLOWED ATTACHMENT FILE TYPE");
	        }
        }
    }

    fileSize = f.length();
    int r = 0;
    if ((null != f) && (fileSize > 0) && (fileSize <= MAX_FILE_SIZE)) {
        if (ACTION_ADD.equals(action)) {
            xrs.createResultSet("HWAttachments", "HWATTACHMENT");
		    r = xrs.add();
            xrs.setFieldValueAt(r, "SERVERID", hwSessionInfo.get("SERVERID"));
            xrs.setFieldValueAt(r, "PROCESSID", Integer.toString(procId));
            xrs.setFieldValueAt(r, "ID", String.valueOf(r));
            xrs.setFieldValueAt(r, "WORKITEMSEQUENCE", workseq);
            xrs.setFieldValueAt(r, "TYPE", "G");
            xrs.setFieldValueAt(r, "OUTTYPE", "B");
            xrs.setFieldValueAt(r, "INTYPE", "C");
            xrs.setFieldValueAt(r, "DIGITALSIGNATURE", "N");
            xrs.setFieldValueAt(r, "MAPID", String.valueOf(r));
            xrs.setFieldValueAt(r, "DMDOCRTYPE", "N");
        } else {
            HWFilter filter = new HWFilter();
            filter.addFilter("SERVERID", "E", hwSessionInfo.get("SERVERID"));
            filter.addFilter("PROCESSID", "E", Integer.toString(procId));
            InputStream is = hwSession.getAttachments(hwSessionInfo.toString(), filter.toByteArray());
            xrs.setLookupField("ID");
            xrs.parse(is);
            is.close();

            r = xrs.lookupField("ID", attachSeq);

            xrs.setFieldValueAt(r, "CREATIONDATE", dateFormat.formatToServer(new java.util.Date()));
            xrs.setFieldValueAt(r, "CREATOR", hwSessionInfo.get("UserID"));
            xrs.setFieldValueAt(r, "CREATORNAME", (String)session.getAttribute("UserName"));
        }

        String tempfilepath = null;
        String attachFileName = null;
        String displayFileName = null;
        if ("url".equalsIgnoreCase(_attachType)) {
            tempfilepath = f.getAbsolutePath();
            displayFileName = multi.getParameter("attachUrlName");
            attachFileName = displayFileName + ".url";
        } else {
            tempfilepath = lf.getCanonicalPath() + File.separator + multi.getPhysicalFileName(0);
            attachFileName = ParamUtil.getParameter(multi.getParameter("hAttachFileName"), "NoRiskyValue", application, pageContext, "hAttachFileName");
            if(null != attachFileName && attachFileName.length() > 0) {
                attachFileName = attachFileName.replaceAll("&euro;", "\u20ac");
            } else {
                attachFileName = multi.getFilesystemName(0);
            }
            int dotIndex = attachFileName.lastIndexOf(".");
            displayFileName = attachFileName;
            if (-1 != dotIndex) {
                displayFileName = attachFileName.substring(0, dotIndex);
            }
        }

        if (null != attUrl) {
            xrs.setFieldValueAt(r, "DMDOCUMENTID", attUrl);
        }
        xrs.setFieldValueAt(r, "SIZE", String.valueOf(fileSize));
        xrs.setFieldValueAt(r, "DISPLAYNAME", displayFileName);
        xrs.setFieldValueAt(r, "FILENAME", attachFileName);
        xrs.setFieldValueAt(r, "DESCRIPTION", description);
	    xrs.setFieldValueAt(r, "CATEGORY", category);
        xrs.setFieldValueAt(r, "ETCINFO", etcInfo);

        String metadataFilePath = null;
        String[] attachFiles = {tempfilepath};

        String edmsMetadata = multi.getParameter("edmsMetadata");
        metadataFilePath = saveEdmsMetadata(edmsMetadata);
        if(metadataFilePath != null) {
            xrs.setFieldValueAt(r, "DMDOCRTYPE", String.valueOf(HWConstants.ID_DM_DOC_NORMAL_META_FILE));
            attachFiles = new String[]{tempfilepath, metadataFilePath};
        }

        hwSession.updateAttachments(hwSessionInfo.toString(),
                hwSessionInfo.get("SERVERID"),
                procId,
                actseq,
                xrs.toByteArray(),
                attachFiles);

        // removing temporary files
        if((null != attachFiles) && (attachFiles.length > 0)) {
            int fileCnt = attachFiles.length;
            for(int i = 0; i < fileCnt; i++) {
                try {
                    File tmpAttachFile = new File(attachFiles[i]);
                    if((null != tmpAttachFile) && (tmpAttachFile.exists())) {
                        tmpAttachFile.delete();
                    }
                } catch(Exception ex) {
                    //ex.printStackTrace();
                }
            }
        }

        basicWih.reloadAttachment();

    } else {
        if (f.length() > MAX_FILE_SIZE) {
            fileSize = -1;
        }

        addFailed = true;
    }
} catch (Exception e) {
    errorMessage = e.getMessage();
	addFailed = true;
	logger.trace(e);
}

if(addFailed) {
    if(errorMessage != null) {
        if(-1 == fileSize) {
            String tmpErrMsg = res.getString(language, "stringtable", "MSG_CMM_INVALID_FILE_SIZE");
            double maxSizeInM = ((double)MAX_FILE_SIZE) / (1024*1024);
            DecimalFormat df = new DecimalFormat("#.##");
            tmpErrMsg.replaceAll("\\{0\\}", df.format(maxSizeInM));
            errorMessage = StringUtils.replace(tmpErrMsg, "{0}", df.format(maxSizeInM));
        } else {
            errorMessage = res.getString(language, "stringtable", "MSG_CMM_INVALID_FILE");
        }
    }
}
%>
<%if("JSON".equalsIgnoreCase(responseType)){
    JSONObject ret = new JSONObject();
    if(errorMessage != null) {
        ret.put("success", false);
        ret.put("message", errorMessage);
    } else {
        ret.put("success", true);
    }
    out.clear();
    response.setContentType("text/xml;charset=UTF-8");
    out.write(ret.toString());
}else{%>
    <HTML lang="<%=language%>">
    <head>
	<title></title>
    <bf:script src="/includes/bfcommon.js"/>
    <script language="javascript">
        var isModified = <%=id != null && 0<id.length()%>;
    <%if (errorMessage != null) { %>
        alert("<%=errorMessage%>");
        parent.$("#uploadBtn").attr("disabled", false);
    <%} else { %>
        var attachmentJSONString = '<%=attachmentJSONString %>';

<%
	if(null != isForcedModal && "true".equals(isForcedModal.toLowerCase())) {
%>
		var _top = getModalTop();
		var caller = _top.getModalPopupCaller();
<%
	}
	else {
%>
		var caller = getModalCaller();
<%
	}
%>

        if(typeof(caller.loadAttachments) != 'undefined') {
            caller.loadAttachments({event: isModified ? "MODIFIED":"ADDED"});
        }

        if(typeof(caller.onAfterAttach) != 'undefined') {
            caller.onAfterAttach();
        }
<%
	if(null != isForcedModal && "true".equals(isForcedModal.toLowerCase())) {
%>
		_top.closeModalPopupWindow();
<%
	}
	else {
%>
        closeWindow();
<%
	}
%>
    <%}%>
    </script>
    </head>
    </html>
<%}%>
