package com.bizflow.ps.pdf.util;

import com.hs.bf.wf.jo.*;
import com.hs.bf.wf.jo.HWException;
import com.hs.bf.wf.jo.HWSession;
import com.hs.bf.wf.jo.HWSessionFactory;

import java.util.ArrayList;
import java.util.List;

public class BizFlowUtility
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(BizFlowUtility.class);

	private static final String[] documentMergeOrder = {
		"PD Coversheet",
		"OF 8",
		"New Position Description (PD)",
		"Proposed Position Description (PD)",
		"Existing Position Description (PD)",
		"New Position Designation Tool (PDT)",
		"FLSA",
		"FLSA Exempt",
		"FLSA Non-Exempt",
		"Office of the Administrator Approval",
		"Organization Chart",
		"Medical License",

		"Resume",
		"CFA Description of Assignment",
		"Ethics Clearance Email",
		"Transcripts",
		"Student Volunteer Agreement",
		"Operation Warfighter Intern Request Form",
		"VA Letter",
		"Schedule A Letter",
		"Statement of Work",
		"Operation Warfighter Placement Form",
		"DD-214",
		"Budget Authorization",
		"Management Checklist",
		"HHS 410",
		"Security Clearance Email",

		"Supporting Documents"
	};

	public static String getSessionString()
	{
		StopWatch watch = new StopWatch(BizFlowUtility.class, "getSessionString");
		if (logger.isDebugEnabled())
		{
			logger.debug("getSessionString START");
		}

		String sessionInfoXML = null;
		try
		{
			HWSessionFactory hwSessionFactory = new HWSessionFactory();
			HWSession hwSession = hwSessionFactory.newInstance();
			hwSession.setServerIP("cms.bizflow.com");
			hwSession.setServerPort(7201);
			sessionInfoXML = hwSession.login("plee", "1", true);
		}
		catch(HWException e)
		{
			logger.fatal("Failed to log on into BizFlow.", e);
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getSessionString END [" + sessionInfoXML + "]");
		}
		watch.check();
		return sessionInfoXML;
	}

	public static int getAttachmentIndex(HWAttachments attachments, String pdfKey)
	{
		StopWatch watch = new StopWatch(BizFlowUtility.class, "getAttachmentIndex");
		if (logger.isDebugEnabled())
		{
			logger.debug("getAttachmentIndex START");
			logger.debug(" - attachments [" + attachments + "]");
			logger.debug(" - pdfKey [" + pdfKey + "]");
		}

		int foundIndex = -1; // This is index, not ID.
		if (attachments != null && pdfKey != null && pdfKey.length() > 0)
		{
			int count = attachments.getCount();
			for (int index = 0; index < count; index++)
			{
				HWAttachment attachment = attachments.getItem(index);

				String etcInfo = attachment.getExtraInformation();

				if (pdfKey.compareToIgnoreCase(etcInfo) == 0) {
					foundIndex = index;
					break;
				}
			}
		}
		else if (attachments == null)
		{
			logger.error("Parameter attachments is null.");

		}
		else if (pdfKey == null || pdfKey.length() == 0)
		{
			logger.error("Parameter pdfGenerationType is null or empty.");
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getAttachmentIndex END [" + Integer.toString(foundIndex) + "]");
		}
		watch.check();
		return foundIndex;
	}

	public static String getPDFKey(String PDFType, int grade, boolean forOldVersion)
	{
		StopWatch watch = new StopWatch(BizFlowUtility.class, "getPDFKey");
		if (logger.isDebugEnabled())
		{
			logger.debug("getPDFKey START");
			logger.debug(" - PDFType [" + PDFType + "]");
			logger.debug(" - grade [" + Integer.toString(grade) + "]");
		}

		String PDFDocumentKey = null;

		if (PDFType != null && PDFType.length() > 0 && grade >= 0)
		{
			if (forOldVersion == true) {
				PDFDocumentKey = PDFType + "_" + Integer.toString(grade);
			} else {
				PDFDocumentKey = PDFType + "_" + (grade > 0 && grade < 10 ? "0" : "") + Integer.toString(grade);
			}
		}
		else if (PDFType == null || PDFType.length() == 0)
		{
			logger.error("Parameter PDFType is null or empty.");
		}
		else if (grade < 0)
		{
			logger.error("Parameter grade should be positive integer value.");
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getPDFKey END [" + PDFDocumentKey + "]");
		}
		watch.check();
		return PDFDocumentKey;
	}

	public static List<Integer> translateIDStringToList(String IDString)
	{
		StopWatch watch = new StopWatch(BizFlowUtility.class, "translateIDStringToList");
		if (logger.isDebugEnabled())
		{
			logger.debug("translateIDStringToList START");
			logger.debug(" - IDString [" + IDString + "]");
		}

		List<Integer> IDList = null;

		if (IDString != null && IDString.length() > 0)
		{
			logger.debug("IDString [" + IDString + "]");
			IDList = new ArrayList<>();

			String cleanedIDString = IDString.trim();
			String[] IDs = cleanedIDString.split(",");

			int count = IDs.length;
			for (int index = 0; index < count; index++)
			{
				try
				{
					int id = Integer.parseInt(IDs[index]);
					IDList.add(id);
				}
				catch (NumberFormatException e)
				{
					logger.error("Failed to convert [" + IDs[index] + "] to integer.", e);
					IDList = null;
					break;
				}
			}
		}
		else
		{
			logger.error("Parameter IDString is null or empty.");
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("translateIDStringToList END ["+ LogUtility.getString(IDList) + "]");
		}
		watch.check();
		return IDList;
	}

	private static List<Integer> adjustAttachmentOrder(HWAttachments attachments, List<Integer>IDs)
	{
		StopWatch watch = new StopWatch(BizFlowUtility.class, "adjustAttachmentOrder");
		if (logger.isDebugEnabled())
		{
			logger.debug("adjustAttachmentOrder START");
			logger.debug(" - attachments [" + attachments + "]");
			logger.debug(" - IDs [" + IDs + "]");
		}

		List<Integer> adjustedIDs = new ArrayList<Integer>();
		int count = IDs.size();
		int addedCount = 0;

		for (String documentType : documentMergeOrder)
		{
			for (int id : IDs)
			{
				HWAttachment attachment = attachments.getItem(Integer.toString(id));
				if (documentType.compareToIgnoreCase(attachment.getCategory()) == 0)
				{
					adjustedIDs.add(id);
					addedCount++;
					if (addedCount >= count)
					{
						break;
					}
				}
			}
			if (addedCount >= count)
			{
				break;
			}
		}

		if (count != adjustedIDs.size())
		{
			logger.fatal("Failed to translate IDs to adjustedIDs.");
			adjustedIDs = null;
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("adjustAttachmentOrder END [" + LogUtility.getString(adjustedIDs) + "]");
		}
		watch.check();
		return adjustedIDs;
	}

	public static List<String> downloadAttachments(HWAttachments attachments, List<Integer> IDs)
	{
		StopWatch watch = new StopWatch(BizFlowUtility.class, "downloadAttachments");
		if (logger.isDebugEnabled())
		{
			logger.debug("downloadAttachments START");
			logger.debug(" - attachments [" + attachments + "]");
			logger.debug(" - IDs [" + IDs + "]");
		}

		List<String> filePaths = null;

		if (attachments != null && attachments.getCount() > 0 && IDs != null && IDs.size() > 0)
		{
			filePaths = new ArrayList<String>();
			try
			{
				List<Integer> adjustedIDs = adjustAttachmentOrder(attachments, IDs);
				for (int id : adjustedIDs)
				{
					HWAttachment attachment = attachments.getItem(Integer.toString(id));
					String filePath = attachment.download();
					filePaths.add(filePath);
				}
			}
			catch(HWException e)
			{
				logger.error("Failed to download attachment file.", e);
				FileUtility.removeFiles(filePaths);
				filePaths = null;
			}

		}
		else if (attachments == null || attachments.getCount() == 0)
		{
			logger.error("Parameter attachments is null or empty.");
		}
		else if (IDs == null || IDs.size() == 0)
		{
			logger.error("Parameter IDs is null or empty.");
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("downloadAttachments END [" + LogUtility.getString(filePaths) + "]");
		}
		watch.check();
		return filePaths;
	}

	public static void removeAttachmentByGrade(HWAttachments attachments, String fileType, int grade)
	{
		String pdfKey = BizFlowUtility.getPDFKey(fileType, grade, false);
		int foundIndex = BizFlowUtility.getAttachmentIndex(attachments, pdfKey);
		if (foundIndex >= 0)
		{
			attachments.remove(foundIndex);
		}

		// Below code is for backward-compatibility.
		// Grade is now having 2 characters. In order to remove old version of documents,
		// Attachments should be searched with old grade (1 character) also.
		// This code can be removed when there is no more 1 character-long grade in bizflow.attach.ETCINFO table.
		String pdfOldVersionKey = BizFlowUtility.getPDFKey(fileType, grade, true);
		int foundOldVersionIndex = BizFlowUtility.getAttachmentIndex(attachments, pdfOldVersionKey);
		if (foundOldVersionIndex >= 0)
		{
			attachments.remove(foundOldVersionIndex);
		}
		// Above code is for backward-compatibility.
	}

	public static void removeAttachmentsByETCInfo(HWAttachments attachments, String documentType)
	{
		StopWatch watch = new StopWatch(BizFlowUtility.class, "removeAttachmentsByETCInfo");
		if (logger.isDebugEnabled())
		{
			logger.debug("removeAttachmentsByETCInfo START");
			logger.debug(" - attachments [" + attachments + "]");
			logger.debug(" - documentType [" + documentType + "]");
		}

		if (attachments != null && documentType != null)
		{
			int count = attachments.getCount();
			for (int index = count - 1; index >= 0; index--)
			{
				HWAttachment attachment = attachments.getItem(index);
				String etcInfo = attachment.getExtraInformation();
				if (etcInfo.startsWith(documentType) == true) {
					attachments.remove(index);
				}
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("removeAttachmentsByETCInfo END");
		}
		watch.check();
	}

	public static boolean removeAttachmentsByType(HWAttachments attachments, String documentType)
	{
		boolean removedAttachment = false;
		StopWatch watch = new StopWatch(BizFlowUtility.class, "removeAttachmentsByType");
		if (logger.isDebugEnabled())
		{
			logger.debug("removeAttachmentsByType START");
			logger.debug(" - attachments [" + attachments + "]");
			logger.debug(" - documentType [" + documentType + "]");
		}

		if (attachments != null && documentType != null)
		{
			int count = attachments.getCount();
			for (int index = count - 1; index >= 0; index--)
			{
				HWAttachment attachment = attachments.getItem(index);
				String category = attachment.getCategory();
				if (category.startsWith(documentType) == true) {
					attachments.remove(index);
					removedAttachment = true;
				}
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("removeAttachmentsByType END");
		}
		watch.check();
		return removedAttachment;
	}

	public static void addAttachment(HWAttachments attachments, String documentType, String fileName,
									 String filePath, String description, String fileType, int grade)
	{
		StopWatch watch = new StopWatch(BizFlowUtility.class, "addAttachment");
		if (logger.isDebugEnabled())
		{
			logger.debug("addAttachment START");
			logger.debug(" - attachments [" + attachments + "]");
			logger.debug(" - documentType [" + documentType + "]");
			logger.debug(" - fileName [" + fileName + "]");
			logger.debug(" - filePath [" + filePath + "]");
			logger.debug(" - description [" + description + "]");
			logger.debug(" - grade [" + Integer.toString(grade) + "]");
		}

		String pdfKey = BizFlowUtility.getPDFKey(fileType, grade, false);

		// Pre-existing documents will be removed before calling this function.
		//
		//		int foundIndex = BizFlowUtility.getAttachmentIndex(attachments, pdfKey);
		//		if (foundIndex >= 0)
		//		{
		//			attachments.remove(foundIndex);
		//		}
		//
		//		// Below code is for backward-compatibility.
		//		// Grade is now having 2 characters. In order to remove old version of documents,
		//		// Attachments should be searched with old grade (1 character) also.
		//		// This code can be removed when there is no more 1 character-long grade in bizflow.attach.ETCINFO table.
		//		String pdfOldVersionKey = BizFlowUtility.getPDFKey(fileType, grade, true);
		//		int foundOldVersionIndex = BizFlowUtility.getAttachmentIndex(attachments, pdfOldVersionKey);
		//		if (foundOldVersionIndex >= 0)
		//		{
		//			attachments.remove(foundOldVersionIndex);
		//		}
		//		// Above code is for backward-compatibility.

		HWAttachment newAttachment = attachments.add();
		newAttachment.setExtraInformation(pdfKey);
		newAttachment.setCategory(documentType);
		newAttachment.setFileName(fileName);
		newAttachment.setDescription(description);

		newAttachment.setFilePath(filePath);
		newAttachment.setType('G');
		newAttachment.setInType('C');
		newAttachment.setOutType('B');

		newAttachment.setDMReferenceType('N');

		if (logger.isDebugEnabled())
		{
			logger.debug("addAttachment END");
		}
		watch.check();
	}
}
