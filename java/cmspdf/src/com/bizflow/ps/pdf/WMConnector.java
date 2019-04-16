package com.bizflow.ps.pdf;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import com.bizflow.ps.pdf.model.Grade;
import com.bizflow.ps.pdf.util.*;
import com.hs.bf.web.beans.HWSessionInfo;
import com.hs.bf.wf.jo.HWAttachments;
import com.hs.bf.wf.jo.HWAttachmentsImpl;
import org.w3c.dom.*;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

public class WMConnector
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(WMConnector.class);

	// HRB-1763
	static public void cleanUpAttachmentsForEligibilityProcess(String sessionInfoXML, int processID)
	{
		StopWatch watch = new StopWatch(WMConnector.class, "cleanUpAttachments");
		logger.info("cleanUpAttachments START");
		if (logger.isDebugEnabled())
		{
			logger.debug(" - sessionInfoXML [" + sessionInfoXML + "]");
			logger.debug(" - processID [" + Integer.toString(processID) + "]");
		}

		try
		{
			HWAttachments attachments = new HWAttachmentsImpl(sessionInfoXML, processID);

			// Should remove existing documents before generating new one.
			boolean removedAnyAttachment = false;

			for (int index = 1; index < 300; index++) {
				String targetType = CMSProperties.getStringValue("Eligibility.removeAttachment" + Integer.toString(index));
				if (targetType == null) {
					break;
				}
				if (logger.isDebugEnabled())
				{
					logger.debug("Document type to be deleted [" + targetType + "]");
				}
				if (BizFlowUtility.removeAttachmentsByType(attachments, targetType) == true)
				{
					removedAnyAttachment = true;
				}
			}

			watch.checkPoint("Before attachment update");
			if (removedAnyAttachment == true)
			{
				if (logger.isDebugEnabled())
				{
					logger.debug("Updating attachments in BizFlow Server");
				}
				attachments.update();
			}
			watch.checkPoint("After attachment update");
		}
		catch(Exception e)
		{
			logger.error("Unhandled exception occurred.", e);
		}
		logger.info("cleanUpAttachments END");
		watch.check();
	}

	static public void generatePackage(String sessionInfoXML, int processID, int grade, String fileName, String IDs)
	{
		StopWatch watch = new StopWatch(WMConnector.class, "generatePackage");
		logger.info("generatePackage START");
		if (logger.isDebugEnabled())
		{
			logger.debug(" - sessionInfoXML [" + sessionInfoXML + "]");
			logger.debug(" - processID [" + Integer.toString(processID) + "]");
			logger.debug(" - grade [" + Integer.toString(grade) + "]");
			logger.debug(" - fileName [" + fileName + "]");
			logger.debug(" - IDs [" + IDs + "]");
		}

		try
		{
			PDFTool pdfUtility = new PDFTool();
			pdfUtility.generatePackagePDF(sessionInfoXML, processID, grade, fileName, IDs);

		}
		catch(Exception e)
		{
			logger.error("Unhandled exception occurred.", e);
		}

		logger.info("generatePackage END");
		watch.check();
	}

	static public void generatePDFDocuments(String sessionInfoXML, int processID, Node document, Node witemDocument) throws Exception
	{
		StopWatch watch = new StopWatch(WMConnector.class, "generatePDFDocuments");
		logger.info("generatePDFDocuments START");
		if (logger.isDebugEnabled())
		{
			logger.debug(" - sessionInfoXML [" + sessionInfoXML + "]");
			logger.debug(" - processID [" + Integer.toString(processID) + "]");
			logger.debug(" - document [" + LogUtility.getString(document) + "]");
			logger.debug(" - witemDocument [" + LogUtility.getString(witemDocument) + "]");
		}

		try
		{
			WMConnector.generateFLSA(sessionInfoXML, processID, document);
		}
		catch(Exception e)
		{
			logger.error("Failed to generate FLSA.", e);
		}

		try
		{
			WMConnector.generatePDCoversheet(sessionInfoXML, processID, document, witemDocument);
		}
		catch(Exception e)
		{
			logger.error("Failed to generate PD Coversheet.", e);
		}

		logger.info("generatePDFDocuments END");
		watch.check();
	}

	static private void generateOF8(String sessionInfoXML, int processID, Node document, Node witemDocument) throws Exception
	{
		StopWatch watch = new StopWatch(WMConnector.class, "generatePDCoversheet");
		logger.info("generateOF8 START");
		if (logger.isDebugEnabled())
		{
			logger.debug(" - sessionInfoXML [" + sessionInfoXML + "]");
			logger.debug(" - processID [" + Integer.toString(processID) + "]");
			logger.debug(" - documentXMLString [" + LogUtility.getString(document) + "]");
			logger.debug(" - witemDocument [" + LogUtility.getString(witemDocument) + "]");
		}

		List<String> toBeDeletedFiles = new ArrayList<String>();

		try
		{
			HWAttachments attachments = new HWAttachmentsImpl(sessionInfoXML, processID);

			// Should remove existing documents before generating new one.
			BizFlowUtility.removeAttachmentsByETCInfo(attachments, "OF 8");

			String memberID = CMSUtility.getValue(witemDocument, "/WorkitemContext/User/MemberID");
			String loginID = CMSUtility.getValue(witemDocument, "/WorkitemContext/User/LoginID");
			String requestNumber = CMSUtility.getValue(witemDocument, "/WorkitemContext/Process/ProcessVariables/requestNum");

			List<Grade> grades = CMSUtility.getGrades(document);
			int gradeCount = grades.size();

			for (int index = 0; index < gradeCount; index++)
			{
				Grade grade = grades.get(index);
				String gradeString = (grade.grade >= 0 && grade.grade < 10 ? "0" : "") + Integer.toString(grade.grade);
				String filename = "OF 8 Grade " + gradeString + ".pdf";

				File of8File = URLUtility.downloadOF8(memberID, loginID, requestNumber, gradeString);

				if (of8File != null) {
					String filePath = of8File.getPath();
					toBeDeletedFiles.add(filePath);

					BizFlowUtility.addAttachment(attachments, "OF 8", filename, filePath, "Grade " + gradeString, PDFTool.CMS_PDFTYPE_OF_8, 0);

				} else {
					logger.error("Failed to download OF 8 form. Process ID [" + processID + "] Request Number [" + requestNumber + "] Grade [" + gradeString + "]");
				}
			}

			watch.checkPoint("Before attachment update");
			attachments.update();
			watch.checkPoint("After attachment update");
		}
		finally
		{
			FileUtility.removeFiles(toBeDeletedFiles);
		}

		logger.info("generateOF8 END");
		watch.check();
	}

	static private void generateCoversheet(String sessionInfoXML, int processID, Node document) throws Exception
	{
		StopWatch watch = new StopWatch(WMConnector.class, "generateCoversheet");
		logger.info("generatePDCoversheet START");

		List<String> toBeDeletedFiles = new ArrayList<String>();

		try
		{
			HWAttachments attachments = new HWAttachmentsImpl(sessionInfoXML, processID);
			Map<String, String> valueMap = XMLUtility.generateValueMap(FileUtility.translatePath("/PDF_Configuration/map/PDF_PDCoversheet_MAP.xml"), document);

			// Should remove existing documents before generating new one.
			BizFlowUtility.removeAttachmentsByETCInfo(attachments, "PDCOVERSHEET");

			// POS_INFORMATION
			List<String> positionInformation = CMSUtility.getPositionInformation(document);
			int positionCount = positionInformation.size();
			for (int index = 0; index < 4; index++)
			{
				if (index < positionCount)
				{
					valueMap.put("#POS_INFORMATION_" + Integer.toString(index + 1), positionInformation.get(index));
					if(logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Position added - [#POS_INFORMATION_" + Integer.toString(index + 1) + "] ==> [" + positionInformation.get(index) + "]");
					}
				}
				else
				{
					valueMap.put("#POS_INFORMATION_" + Integer.toString(index + 1), "");
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Position added - [#POS_INFORMATION_" + Integer.toString(index + 1) + "] ==> []");
					}
				}
			}

			// Position Standard
			List<String> standards = CMSUtility.getPositionStandards(document);
			int stadardCount = standards.size();
			for (int index = 0; index < 7; index++)
			{
				if (index < stadardCount)
				{
					valueMap.put("#PD_CLS_STANDARDS_" + Integer.toString(index + 1), standards.get(index));
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Position standard added - [#PD_CLS_STANDARDS_" + Integer.toString(index + 1) +"] ==> [" + standards.get(index) + "]");
					}
				}
				else
				{
					valueMap.put("#PD_CLS_STANDARDS_" + Integer.toString(index + 1), "");
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Position standard added [#PD_CLS_STANDARDS_" + Integer.toString(index + 1) + "] ==> []");
					}
				}
			}

			// Full Perfomance Level
			valueMap.put("#CS_PERFORMANCE_LEVEL", CMSUtility.getFullPerformanceLevel(document));


			List<Grade> grades = CMSUtility.getGrades(document);
			int gradeCount = grades.size();

			for (int index = 0; index < gradeCount; index++)
			{
				Grade grade = grades.get(index);
				valueMap.put("#CS_PD_NUMBER_JOBCO", grade.jobCode);
				logger.debug("New Item in ValueMap: PD Number/Job Code added - [#CS_PD_NUMBER_JOBCO] ==> [" + grade.jobCode + "]");
				if (grade.grade == 0)
				{
					valueMap.put("#CS_GR_ID", "");
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Grade added - [#CS_GR_ID] ==> []");
					}
				}
				else
				{
					valueMap.put("#CS_GR_ID", (grade.grade > 9 ? "" : "0") + Integer.toString(grade.grade));
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Grade added - [#CS_GR_ID] ==> [" + Integer.toString(grade.grade) + "]");
					}
				}

				valueMap.put("#CS_FLSA_DETERM_ID", grade.exempt);
				if (logger.isDebugEnabled())
				{
					logger.debug("New Item in ValueMap: FLSA Exempt added - [#CS_FLSA_DETERM_ID] ==> [" + grade.exempt + "]");
				}

				PDFTool pdfUtility = new PDFTool();

				List<String> files = pdfUtility.generate(valueMap, FileUtility.translatePath("/PDF_Configuration/map/PDF_PDCoversheet.xml"));
				if (files.size() > 0)
				{
					String filePath = FileUtility.getTempFileName();
					pdfUtility.merge(files, filePath, true);
					toBeDeletedFiles.add(filePath);
					String gradeString = (grade.grade >= 0 && grade.grade < 10 ? "0" : "") + Integer.toString(grade.grade);
					BizFlowUtility.addAttachment(attachments, "PD Coversheet", "PD Coversheet Grade " + gradeString + ".pdf", filePath, "Grade " + gradeString, PDFTool.CMS_PDFTYPE_PD_COVERSHEET, grade.grade);
				}
				else
				{
					logger.info("No FLSA(Exempt) PDF files generated.");
				}
			}

			watch.checkPoint("Before attachment update");
			attachments.update();
			watch.checkPoint("After attachment update");
		}
		finally
		{
			FileUtility.removeFiles(toBeDeletedFiles);
		}

		logger.info("generateCoversheet END");
		watch.check();
	}

	static public void generatePDCoversheet(String sessionInfoXML, int processID, Node document, Node witemDocument) throws Exception
	{
		WMConnector.generateCoversheet(sessionInfoXML, processID, document);
		WMConnector.generateOF8(sessionInfoXML, processID, document, witemDocument);
	}

	static public void generateFLSA(String sessionInfoXML, int processID, Node document) throws Exception
	{
		StopWatch watch = new StopWatch(WMConnector.class, "generateFLSA");
		logger.info("generateFLSA START");

		List<String> toBeDeletedFiles = new ArrayList<String>();

		try
		{
			HWAttachments attachments = new HWAttachmentsImpl(sessionInfoXML, processID);
			List<Grade> grades = CMSUtility.getGrades(document);

			// Should remove existing documents before generating new one.
			BizFlowUtility.removeAttachmentsByETCInfo(attachments, "FLSANONEXEMPT");
			BizFlowUtility.removeAttachmentsByETCInfo(attachments, "FLSAEXEMPT");

			String exemptJobCode = CMSUtility.getExemptJobCode(grades, true);
			if (exemptJobCode != null && exemptJobCode.length() > 0)
			{
				Map<String, String> valueMap = XMLUtility.generateValueMap(FileUtility.translatePath("/PDF_Configuration/map/PDF_FLSA_EXEMPT_MAP.xml"), document);
				valueMap.put("#JOB_CODE", exemptJobCode);
				if (logger.isDebugEnabled())
				{
					logger.debug("New Item in ValueMap: ob Code added - [#JOB_CODE] ==> [" + exemptJobCode + "]");
				}

				//#PAYPLAN_SERIES
				String payPlanSeries = valueMap.get("#PAYPLAN_SERIES");
				String codes = CMSUtility.getGradeCodes(grades, true);
				if (codes.length() > 0)
				{
					valueMap.put("#PAYPLAN_SERIES_GRADE", payPlanSeries + "-" + codes);
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Payplan/Series added - [#PAYPLAN_SERIES_GRADE] ==> [" + payPlanSeries + "-" + codes + "]");
					}
				}
				else
				{
					valueMap.put("#PAYPLAN_SERIES_GRADE", payPlanSeries);
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Payplan/Series added - [#PAYPLAN_SERIES_GRADE] ==> [" + payPlanSeries + "]");
					}
				}

				//3rd level organization - #OFFICE_ORGANIZATION
				String orgName = CMSUtility.getOrganizationName(document);
				valueMap.put("#OFFICE_ORGANIZATION", orgName);

				// Classification Date
				String classificationDate = CMSUtility.getLatestClassificationDate(grades, true);
				if (classificationDate != null && classificationDate.length() > 0)
				{
					valueMap.put("#PD_CLS_SPEC_DT", classificationDate);
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Classification Date added - [#PD_CLS_SPEC_DT] ==> [" + classificationDate + "]");
					}
				}

				PDFTool pdfUtility = new PDFTool();

				List<String> files = pdfUtility.generate(valueMap, FileUtility.translatePath("/PDF_Configuration/map/PDF_FLSA_EXEMPT.xml"));
				if (files.size() > 0)
				{
					String filePath = FileUtility.getTempFileName();
					pdfUtility.merge(files, filePath, true);
					BizFlowUtility.addAttachment(attachments, "FLSA Exempt", "FLSA Exempt.pdf", filePath, "FLSA Exempt Checklist", PDFTool.CMS_PDFTYPE_FLSA_EXEMPT, 0);
				}
				else
				{
					logger.info("No FLSA(Exempt) PDF files generated.");
				}

			}
			else
			{
				logger.info("exemptJobCode is null.");
			}

			String nonExemptJobCode = CMSUtility.getExemptJobCode(grades, false);
			if (nonExemptJobCode != null && nonExemptJobCode.length() > 0)
			{
				Map<String, String> valueMap = XMLUtility.generateValueMap(FileUtility.translatePath("/PDF_Configuration/map/PDF_FLSA_NONEXEMPT_MAP.xml"), document);

				valueMap.put("#JOB_CODE", nonExemptJobCode);
				if (logger.isDebugEnabled())
				{
					logger.debug("New Item in ValueMap: Job Code added - [#JOB_CODE] ==> [" + nonExemptJobCode + "]");
				}

				//#PAYPLAN_SERIES
				String payPlanSeries = valueMap.get("#PAYPLAN_SERIES");
				String codes = CMSUtility.getGradeCodes(grades, false);
				if (codes.length() > 0)
				{
					valueMap.put("#PAYPLAN_SERIES_GRADE", payPlanSeries + "-" + codes);
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Payplan/Series added - [#PAYPLAN_SERIES_GRADE] ==> [" + payPlanSeries + "-" + codes + "]");
					}
				}
				else
				{
					valueMap.put("#PAYPLAN_SERIES_GRADE", payPlanSeries);
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Payplan/Series added - [#PAYPLAN_SERIES_GRADE] ==> [" + payPlanSeries + "]");
					}
				}

				//3rd level organization - #OFFICE_ORGANIZATION
				String orgName = CMSUtility.getOrganizationName(document);
				valueMap.put("#OFFICE_ORGANIZATION", orgName);


				// Classification Date
				String classificationDate = CMSUtility.getLatestClassificationDate(grades, false);
				if (classificationDate != null && classificationDate.length() > 0)
				{
					valueMap.put("#PD_CLS_SPEC_DT", classificationDate);
					if (logger.isDebugEnabled())
					{
						logger.debug("New Item in ValueMap: Classification Date added - [#PD_CLS_SPEC_DT] ==> [" + classificationDate + "]");
					}
				}

				PDFTool pdfUtility = new PDFTool();
				List<String> files = pdfUtility.generate(valueMap, FileUtility.translatePath("/PDF_Configuration/map/PDF_FLSA_NONEXEMPT.xml"));
				if (files.size() > 0)
				{
					String filePath = FileUtility.getTempFileName();
					pdfUtility.merge(files, filePath, true);
					BizFlowUtility.addAttachment(attachments, "FLSA Non-Exempt", "FLSA Nonexempt.pdf", filePath, "FLSA Non-Exempt Checklist", PDFTool.CMS_PDFTYPE_FLSA_NONEXEMPT, 0);
				}
				else
				{
					logger.info("No FLSA(NonExempt) PDF files generated.");
				}
			}
			else
			{
				logger.info("nonExemptJobCode is null.");
			}

			watch.checkPoint("Before attachment update");
			attachments.update();
			watch.checkPoint("After attachment update");
		}
		finally
		{
			FileUtility.removeFiles(toBeDeletedFiles);
		}

		logger.info("generateFLSA END");
		watch.check();
	}


	public static void main(String[] args) throws IOException, Exception
	{
//		File xmlFile = new File("/Users/jolinhama/repo/CMS-BizFlow/java/cmspdf/PDF_Configuration/map/TEST_DATA.xml");
//		DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
//		DocumentBuilder builder = dbFactory.newDocumentBuilder();
//		Document document = builder.parse(xmlFile);
//		document.getDocumentElement().normalize();
//
//		File xmlFile2 = new File("/Users/jolinhama/repo/CMS-BizFlow/java/cmspdf/PDF_Configuration/map/TEST_LOOKUP.xml");
//		DocumentBuilderFactory dbFactory2 = DocumentBuilderFactory.newInstance();
//		DocumentBuilder builder2 = dbFactory2.newDocumentBuilder();
//		Document document2 = builder2.parse(xmlFile2);
//		document2.getDocumentElement().normalize();
//
//		LookupUtility.initialize(document2);
//
//		String sessionInfoXML = BizFlowUtility.getSessionString();
//		//WMConnector.generateFLSA(sessionInfoXML, 219, document);
//		WMConnector.generatePDFDocuments(sessionInfoXML, 753, document, "HELLO");
//
//		StopWatch.printArchive();
	}
/*

	public static void main2(String[] args) throws IOException, Exception
	{
		System.out.println(WMConnector.class.getCanonicalName());
		System.out.println(WMConnector.class.getSimpleName());
	}

	public static void main4(String[] args)
	{
		System.out.println("1 ==> " + CMSProperties.getStringValue("Eligibility.removeAttachment1 "));
		System.out.println("2 ==> " + CMSProperties.getStringValue("Eligibility.removeAttachment2"));
		System.out.println("3 ==> " + CMSProperties.getStringValue("Eligibility.removeAttachment3"));
		System.out.println("4 ==> " + CMSProperties.getStringValue("Eligibility.removeAttachment4"));
		System.out.println("5 ==> " + CMSProperties.getStringValue("Eligibility.removeAttachment5"));
		System.out.println("6 ==> " + CMSProperties.getStringValue(" Eligibility.removeAttachment6"));
		System.out.println("7 ==> " + CMSProperties.getStringValue("Eligibility.removeAttachment7"));
	}

	public static void main(String[] args)
	{
		String sessionInfoXML = BizFlowUtility.getSessionString();
		WMConnector.cleanUpAttachmentsForEligibilityProcess(sessionInfoXML, 1814);
	}
*/
}
