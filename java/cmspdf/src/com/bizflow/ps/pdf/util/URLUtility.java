package com.bizflow.ps.pdf.util;

import java.io.*;
import com.hs.frmwk.util.StringUtils;

public class URLUtility
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(PDFUtility.class);
	private static String urlString = "{REPORTSERVERURL}/rest_v2/reports{PATH}.pdf?j_memberid={MEMBERID}&j_username={LOGINID}&REQ_NUM={REQNUM}&GRADE={GRADE}";

	public static File downloadOF8(String memberID, String loginID, String requestNumber, String grade) {
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
			String url = urlString;
			String reportServerURL = CMSProperties.getStringValue("ReportServer.URL");
			String of8ReportPath = CMSProperties.getStringValue("ReportPath.OF8");

			url = StringUtils.replace(url, "{REPORTSERVERURL}", reportServerURL);
			url = StringUtils.replace(url, "{PATH}", of8ReportPath);
			url = StringUtils.replace(url, "{MEMBERID}", memberID);
			url = StringUtils.replace(url, "{LOGINID}", loginID);
			url = StringUtils.replace(url, "{REQNUM}", requestNumber);
			url = StringUtils.replace(url, "{GRADE}", grade);

			if (logger.isDebugEnabled()) {
				logger.debug("OF 8 URL: [" + url + "]");
			}

			java.net.URL agent = new java.net.URL(url);

			InputStream inputStream = null;
			FileOutputStream fos = null;
			fp = File.createTempFile("cms", ".pdf");

			try
			{
				inputStream = new BufferedInputStream(agent.openStream());
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
				logger.error("Error during the downloading OF 8 report file. (url=" + url + ")", e);
				fp = null;
			}
			finally
			{
				if (inputStream != null) {
					try
					{
						inputStream.close();
					}
					catch (Exception be)
					{
					}
				}

				if (fos != null) {
					try
					{
						fos.close();
					}
					catch (Exception we)
					{
					}
				}
			}
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
}
