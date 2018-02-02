package com.bizflow.ps.pdf.util;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.List;

public class FileUtility
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(FileUtility.class);
	static private String CATALINA_HOME = null;

	public static String getTempFileName() throws IOException
	{
		StopWatch watch = new StopWatch(FileUtility.class, "getTempFileName");
		if (logger.isDebugEnabled())
		{
			logger.debug("getTempFileName START");
		}

		File temp = File.createTempFile("CMSPDF", ".pdf");
		String tempPath = temp.getAbsolutePath();

		if (logger.isDebugEnabled())
		{
			logger.debug("getTempFileName END [" + tempPath + "]");
		}
		watch.check();
		return tempPath;
	}

	public static void copy(String sourcePath, String targetPath) throws IOException
	{
		StopWatch watch = new StopWatch(FileUtility.class, "copy");
		if (logger.isDebugEnabled())
		{
			logger.debug("copy START");
			logger.debug(" - sourcePath [" + sourcePath + "]");
			logger.debug(" - targetPath [" + targetPath + "]");
		}

		File source = new File(sourcePath);
		File target = new File(targetPath);
		Files.copy(source.toPath(), target.toPath());

		if (logger.isDebugEnabled())
		{
			logger.debug("copy END");
		}
		watch.check();
	}

	// This function should be called when the exception happens and wants to clear downloaded file.
	public static void removeFiles(List<String> filePaths)
	{
		StopWatch watch = new StopWatch(FileUtility.class, "removeFiles");
		if (logger.isDebugEnabled())
		{
			logger.debug("removeFiles START");
			logger.debug(" - filePaths [" + LogUtility.getString(filePaths) + "]");
		}

		try
		{
			if (filePaths != null && filePaths.size() > 0)
			{
				for (String path : filePaths)
				{
					File tempFile = new File(path);
					tempFile.delete();
					logger.debug("Deleted file from [" + path + "]");
				}
			}
		}
		catch(Exception e)
		{
			// This function will be called when exception happens.
			// Ignore any exception while removing files.
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("removeFiles END");
		}
		watch.check();
	}

	public static boolean fileExist(String filePath)
	{
		StopWatch watch = new StopWatch(FileUtility.class, "fileExist");
		if (logger.isDebugEnabled())
		{
			logger.debug("fileExist START");
			logger.debug(" - filePath [" + filePath + "]");
		}

		boolean foundFile = false;
		// Checking file existence
		File testFile = new File(filePath);
		if (testFile.exists() == true) {
			logger.debug("File [" + filePath + "] exists.");
			foundFile = true;
		} else {
			logger.debug("File [" + filePath + "] doesn't exist.");
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("fileExist END [" + LogUtility.getString(foundFile) + "]");
		}
		watch.check();
		return foundFile;
	}

	public static void removeFile(String filePath)
	{
		StopWatch watch = new StopWatch(FileUtility.class, "removeFile");
		if (logger.isDebugEnabled())
		{
			logger.debug("removeFile START");
			logger.debug(" - filePath [" + filePath + "]");
		}

		try
		{
			if (logger.isDebugEnabled())
			{
				logger.debug("Deleting file [" + filePath + "]...");
			}
			File file = new File(filePath);
			if (file.exists() == true)
			{
				file.delete();
				if (logger.isDebugEnabled())
				{
					logger.debug("File [" + filePath + "] deleted.");
				}
			}
		}
		catch(Exception e)
		{
			//Ignore any error.
			if (logger.isDebugEnabled())
			{
				logger.debug("Failed to delete file [" + filePath + "]. This error can be ignored.", e);
			}
		}
		if (logger.isDebugEnabled())
		{
			logger.debug("removeFile END");
		}
		watch.check();
	}

	private static String getCatalinaHome()
	{
		if (CATALINA_HOME == null)
		{
			CATALINA_HOME = System.getenv("CATALINA_HOME");
			if (CATALINA_HOME == null)
			{
				CATALINA_HOME = System.getProperty("catalina.home");
				if (CATALINA_HOME == null)
				{
					logger.fatal("CATALINA_HOME is not set.");
				}
				else
				{
					logger.info("CATALINA_HOME from property [" + CATALINA_HOME + "]");
				}
			}
			else
			{
				logger.info("CATALINA_HOME from environemnt [" + CATALINA_HOME + "]");
			}
		}

		return CATALINA_HOME;
	}

	// mode
	//		0 : test - local path
	// 		1 : product - real path (WebApp)
	public static String translatePath(String relativePath)
	{
		StopWatch watch = new StopWatch(FileUtility.class, "translatePath");
		if (logger.isDebugEnabled())
		{
			logger.debug("translatePath START");
			logger.debug(" - relativePath [" + relativePath + "]");
		}

		String translatedPath = null;
		String catalina_home = FileUtility.getCatalinaHome();
		if (catalina_home != null)
		{

			if (relativePath != null && relativePath.length() > 0)
			{
				boolean endsWithSlash = catalina_home.endsWith("/");
				boolean startsWithSlash = relativePath.startsWith("/");
				translatedPath = catalina_home + (endsWithSlash ? "" : "/") + "webapps/bizflowwebmaker/WEB-INF" + (startsWithSlash ? "" : "/") + relativePath;
			}

			if (logger.isDebugEnabled())
			{
				logger.debug("translatePath END [" + translatedPath + "]");
			}
		}
		watch.check();
		return translatedPath;
	}

}
