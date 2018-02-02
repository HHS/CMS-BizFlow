package com.bizflow.ps.pdf.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

public class CMSProperties
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(CMSProperties.class);
	static private boolean initialized = false;
	static private Properties properties = null;

	static private void initialize() throws IOException
	{
		StopWatch watch = new StopWatch(CMSProperties.class, "initialize");
		if (logger.isDebugEnabled())
		{
			logger.debug("initialize START");
		}

		FileInputStream in = null;
		try
		{
			in = new FileInputStream(FileUtility.translatePath("/PDF_Configuration/cmspdf.properties"));
			properties = new Properties();
			properties.load(in);
			initialized = true;
		}
		catch (IOException e)
		{
			logger.error("IOException happend while initializing cmspdf.properties file.", e);
			throw e;
		}
		finally
		{
			if (in != null)
			{
				try
				{
					in.close();
				}
				catch(Exception e)
				{ // This exception can be ignored.
				}
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("initialize END");
		}
		watch.check();
	}

	public static String getStringValue(String key) throws IOException
	{
		StopWatch watch = new StopWatch(CMSUtility.class, "getStringValue");
		if (logger.isDebugEnabled())
		{
			logger.debug("getStringValue START");
			logger.debug(" - key [" + key + "]");
		}

		String foundValue = null;
		if (key != null && key.length() > 0)
		{
			if (!initialized)
			{
				initialize();
			}
			String translatedKey = key.trim();
			foundValue = properties.getProperty(translatedKey);

			if (logger.isDebugEnabled())
			{
				logger.debug("getStringValue END [" + foundValue + "]");
			}
			watch.check();
		}
		return foundValue;
	}
}
