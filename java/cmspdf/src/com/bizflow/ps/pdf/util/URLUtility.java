package com.bizflow.ps.pdf.util;

import java.io.*;
import com.hs.frmwk.util.StringUtils;

import javax.net.ssl.*;

public class URLUtility
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(PDFUtility.class);
	private static final String OF8_REPORT_URL = "{REPORTSERVERURL}/rest_v2/reports{PATH}.pdf?j_memberid={MEMBERID}&j_username={LOGINID}&REQ_NUM={REQNUM}&GRADE={GRADE}";

	public URLUtility() {
	}

	private String makeURLString(String memberID, String loginID, String requestNumber, String grade) throws Exception {
		String url = URLUtility.OF8_REPORT_URL;
		String reportServerURL = CMSProperties.getStringValue("ReportServer.URL");
		String of8ReportPath = CMSProperties.getStringValue("ReportPath.OF8");

		url = StringUtils.replace(url, "{REPORTSERVERURL}", reportServerURL);
		url = StringUtils.replace(url, "{PATH}", of8ReportPath);
		url = StringUtils.replace(url, "{MEMBERID}", memberID);
		url = StringUtils.replace(url, "{LOGINID}", loginID);
		url = StringUtils.replace(url, "{REQNUM}", requestNumber);
		url = StringUtils.replace(url, "{GRADE}", grade);

		if (logger.isDebugEnabled())
		{
			logger.debug("The URL of OF 8 form [" + url + "]");
		}
		return url;
	}

	private InputStream getInputStreamFromURL(String url) throws Exception {
		InputStream is = null;
		java.net.URL urlObject = new java.net.URL(url);

		if (url.startsWith("https")) {
			HttpsURLConnection sslConnection = (HttpsURLConnection)urlObject.openConnection();

			SSLContext sc = SSLContext.getInstance("SSL");
			sc.init(null, new TrustManager[] { new TrustAnyTrustManager()}, new java.security.SecureRandom());
			sslConnection.setSSLSocketFactory(sc.getSocketFactory());

			HostnameVerifier allHostsValid = new HostnameVerifier() {
				public boolean verify(String hostname, SSLSession session) {
					return true;
				}
			};
			sslConnection.setDefaultHostnameVerifier(allHostsValid);

			java.lang.System.setProperty("https.protocols", "TLSv1,TLSv1.2");

			is = sslConnection.getInputStream();
		} else {
			is = urlObject.openStream();
		}

		return is;
	}

	private File download(InputStream is, String prefix, String suffix) throws Exception {
		InputStream inputStream = null;
		FileOutputStream fos = null;
		File fp = File.createTempFile(prefix, suffix);

		try
		{
			inputStream = new BufferedInputStream(is);
			fos = new FileOutputStream(fp);
			byte[] buffer = new byte[4096];
			int len = 0;
			while ((len = inputStream.read(buffer)) != -1)
			{
				fos.write(buffer, 0, len);
			}
		}
		catch (IOException e)
		{
			logger.error("Failed to read data from input stream", e);
			fp = null;
		}
		finally
		{
			if (inputStream != null) {
				try {
					inputStream.close();
				} catch (Exception be) {
				}
			}

			if (fos != null) {
				try {
					fos.close();
				} catch (Exception we) {
				}
			}
		}

		return fp;
	}

	public File downloadOF8(String memberID, String loginID, String requestNumber, String grade) {
		StopWatch watch = new StopWatch(URLUtility.class, "downloadOF8");
		if (logger.isDebugEnabled())
		{
			logger.debug("downloadOF8 START");
			logger.debug(" - memberID [" + memberID + "]");
			logger.debug(" - loginID [" + loginID + "]");
			logger.debug(" - requestNumber [" + requestNumber + "]");
		}

		if (Utility.isValidStringParameter(memberID) == false) {
			logger.error("Parameter memberID is invalid.");
			return null;
		}
		if (Utility.isValidStringParameter(loginID) == false) {
			logger.error("Parameter loginID is invalid.");
			return null;
		}
		if (Utility.isValidStringParameter(requestNumber) == false) {
			logger.error("Parameter memberID is requestNumber.");
			return null;
		}

		File fp = null;
		try
		{
			String url = makeURLString(memberID, loginID, requestNumber, grade);
			InputStream is = getInputStreamFromURL(url);
			fp = download(is, "cms", ".pdf");
		} catch (Exception e) {
			fp = null;
			logger.error(e);
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("downloadOF8 END [" + (fp == null ? "NULL" : "NOT NULL") + "]");
		}
		watch.check();

		return fp;
	}

	public void get(String urlString) {
		File fp = null;
		InputStream is = null;
		try
		{
			if (logger.isDebugEnabled()) {
				logger.debug("URL: [" + urlString + "]");
				if (urlString.startsWith("https")) {
					logger.debug("HTTPS detected [" + urlString + "]");
				} else {
					logger.debug("HTTP detected [" + urlString + "]");
				}
			}

			is = getInputStreamFromURL(urlString);
			fp = download(is, "test", "html");
		} catch (Exception e) {
			fp = null;
			logger.error(e);
		} finally {
			try  {
				if (is != null)  {
					is.close();
				}
			} catch (Exception e) {
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("downloadOF8 END [" + (fp == null ? "NULL" : "NOT NULL") + "]");
		}

		System.out.println("File Path: [" + fp.getPath() + "]");
	}
}
