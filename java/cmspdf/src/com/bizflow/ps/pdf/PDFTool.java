package com.bizflow.ps.pdf;

import com.bizflow.ps.pdf.model.PDFOverlay;
import com.bizflow.ps.pdf.util.*;
import org.apache.pdfbox.io.MemoryUsageSetting;
import org.apache.pdfbox.multipdf.PDFMergerUtility;
import org.w3c.dom.*;
import org.xml.sax.SAXException;
import javax.xml.parsers.*;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import com.hs.bf.wf.jo.*;
import com.hs.bf.web.beans.HWException;

public class PDFTool
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(PDFTool.class);

	public static final String CMS_PDFTYPE_FLSA_EXEMPT 		= "FLSAEXEMPT";
	public static final String CMS_PDFTYPE_FLSA_NONEXEMPT	= "FLSANONEXEMPT";
	public static final String CMS_PDFTYPE_PD_COVERSHEET	= "PDCOVERSHEET";
	public static final String CMS_PDFTYPE_FINAL_PACKAGE	= "PACKAGE";

	private ArrayList<PDFOverlay> overlays = new ArrayList<PDFOverlay>();

	public PDFTool()
	{
		logger.debug("PDFTool initiated");
	}

	private void parse(String configurationFilePath) throws ParserConfigurationException, IOException, SAXException, Exception
	{
		StopWatch watch = new StopWatch(PDFTool.class, "parse");
		if (logger.isDebugEnabled())
		{
			logger.debug("parse START");
			logger.debug(" - configurationFilePath [" + configurationFilePath + "]");
		}

		overlays.clear();

		File xmlFile = new File(configurationFilePath);
		DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder builder = dbFactory.newDocumentBuilder();
		Document document = builder.parse(xmlFile);

		document.getDocumentElement().normalize();

		int gridSize = XMLUtility.getIntAttribute(document.getDocumentElement(), "gridSize", 0);

		NodeList nodes = document.getElementsByTagName("overlay");

		for (int index = 0; index < nodes.getLength(); index++) {
			Element node = (Element)nodes.item(index);
			PDFOverlay overlay = new PDFOverlay(node, gridSize);
			overlays.add(overlay);
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("parse END");
		}
		watch.check();
	}

	public List<String> generate(Map<String, String> valueMap, String configurationFilePath) throws Exception
	{
		StopWatch watch = new StopWatch(PDFTool.class, "generate");
		if (logger.isDebugEnabled())
		{
			logger.debug("generate START");
			logger.debug(" - valueMap [" + LogUtility.getString(valueMap) + "]");
			logger.debug(" - configurationFilePath [" + configurationFilePath + "]");
		}

		List<String> filePaths = new ArrayList<String>();

		try
		{
			// Checking file existence
			boolean foundFile = FileUtility.fileExist(configurationFilePath);

			if (foundFile == true)
			{
				parse(configurationFilePath);

				for (int index = 0; index < overlays.size(); index++)
				{
					PDFOverlay overlay = overlays.get(index);
					String path = overlay.generate(valueMap);
					if (logger.isDebugEnabled())
					{
						logger.debug("	PDF File [" + path + "] generated.");
					}

					if (path == null)
					{
						throw new Exception("	Failed to generate PDF.");
					}
					filePaths.add(path);
				}
			}
			else
			{
				logger.error("Cannot find configuration file [" + configurationFilePath + "]");
			}
		}
		catch(SAXException | IOException | ParserConfigurationException e)
		{
			logger.fatal("Exception happened while generating pdf file", e);
			FileUtility.removeFiles(filePaths);
			filePaths.clear();
		}
		catch(Exception e)
		{
			logger.fatal("Exception happened while generating pdf file", e);
			FileUtility.removeFiles(filePaths);
			filePaths.clear();
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("generate END [" + Integer.toString(filePaths.size()) + "]");
		}
		watch.check();
		return filePaths;
	}

	public void merge(List<String> filePaths, String outputFilePath, boolean deleteInputFile) throws IOException
	{
		StopWatch watch = new StopWatch(PDFTool.class, "merge");
		if (logger.isDebugEnabled())
		{
			logger.debug("merge START");
			logger.debug(" - filePaths [" + LogUtility.getString(filePaths) + "]");
			logger.debug(" - outputFilePath [" + outputFilePath + "]");
			logger.debug(" - deleteInputFile [" + LogUtility.getString(deleteInputFile) + "]");
		}

		PDFMergerUtility ut = new PDFMergerUtility();

		int count = filePaths.size();
		if (count > 0)
		{
			for (int index = 0; index < count; index++)
			{
				String filePath = filePaths.get(index);
				ut.addSource(filePath);

				if (logger.isDebugEnabled())
				{
					logger.debug("	File [" + filePath + "] is added to merge-list.");
				}
			}

			ut.setDestinationFileName(outputFilePath);
			ut.mergeDocuments(MemoryUsageSetting.setupMainMemoryOnly());

			if (logger.isDebugEnabled())
			{
				logger.debug("	Created merged file [" + outputFilePath + "]");
			}
		}
		else if (count == 1)
		{
			FileUtility.copy(filePaths.get(0), outputFilePath);
		}
		else
		{
			if (logger.isDebugEnabled())
			{
				logger.debug("No merge file specified. Ignore this request.");
			}
		}

		if (deleteInputFile == true)
		{
			for (int index = 0; index < filePaths.size(); index++)
			{
				String path = filePaths.get(index);
				File file = new File(path);
				file.delete();
				if (logger.isDebugEnabled())
				{
					logger.debug("	File [" + path + "] deleted with deleteInputFile flag.");
				}
			}
			filePaths.clear();
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("merge END");
		}
		watch.check();
	}

	public void generatePackagePDF(String sessionInfoXML, int processID, int grade, String targetFileName, String IDs)
	{
		StopWatch watch = new StopWatch(PDFTool.class, "generatePackagePDF");
		if (logger.isDebugEnabled())
		{
			logger.debug("generatePackagePDF START");
			logger.debug(" - sessionInfoXML [" + sessionInfoXML + "]");
			logger.debug(" - processID [" + Integer.toString(processID) + "]");
			logger.debug(" - grade [" + Integer.toString(grade) + "]");
			logger.debug(" - filename [" + targetFileName + "]");
			logger.debug(" - IDs [" + IDs + "]");
		}

		if (sessionInfoXML != null && sessionInfoXML.length() > 0
				&& processID > 0 && grade >= 0
				&& targetFileName != null && targetFileName.length() > 0
				&& IDs != null && IDs.length() > 0)
		{
			String targetTempFileName = null;
			try
			{
				HWAttachments attachments = new HWAttachmentsImpl(sessionInfoXML, processID);
				BizFlowUtility.removeAttachmentByGrade(attachments, CMS_PDFTYPE_FINAL_PACKAGE, grade);

				List<Integer> selectedAttachmentIDs = BizFlowUtility.translateIDStringToList(IDs);

				if (selectedAttachmentIDs != null)
				{
					targetTempFileName = FileUtility.getTempFileName();

					List<String> downloadedFiles = BizFlowUtility.downloadAttachments(attachments, selectedAttachmentIDs);

					// downloadedFiles will be deleted from merge API below.
					merge(downloadedFiles, targetTempFileName, true);

					BizFlowUtility.addAttachment(attachments, "Final Package", targetFileName, targetTempFileName, "Grade " + (grade > 0 && grade < 10 ? "0" : "") + Integer.toString(grade), CMS_PDFTYPE_FINAL_PACKAGE, grade);

					attachments.update();
				}
				else
				{
					logger.error("Failed to generate final package.");
				}
			}
			catch (HWException | IOException e)
			{
				logger.error("Failed to generate final package.", e);
			}
			finally
			{
				try
				{
					if (targetTempFileName != null && targetTempFileName.length() > 0)
					{
						File toBeDeleted = new File(targetTempFileName);
						toBeDeleted.delete();
					}
				}
				catch (Exception e)
				{
					//Ignore
				}
			}
		}
		else
		{
			if (sessionInfoXML == null || sessionInfoXML.length() == 0) {
				logger.error("Invalid parameter. Parameter sessionInfoXML is null or empty.");
			}
			if (processID <= 0)
			{
				logger.error("Invalid parameter. Parameter processID should be positive integer number. [" + Integer.toString(processID) + "]");
			}
			if (grade < 0)
			{
				logger.error("Invalid parameter. Parameter grade should be positive integer number. [" + Integer.toString(grade) + "]");
			}
			if (targetFileName == null || targetFileName.length() == 0)
			{
				logger.error("Invalid parameter. Parameter filename is null or empty");
			}
			if (IDs == null || IDs.length() == 0)
			{
				logger.error("Invalid parameter. Parameter IDs is null or empty.");
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("generatePackagePDF END");
		}
		watch.check();
	}
}

