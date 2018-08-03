package com.bizflow.ps.pdf.util;

import com.bizflow.ps.pdf.model.Grade;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import javax.xml.xpath.*;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class CMSUtility
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(CMSUtility.class);

	static public List<String> getPositionInformation(Node document)
	{
		StopWatch watch = new StopWatch(CMSUtility.class, "getPositionInformation");
		if (logger.isDebugEnabled())
		{
			logger.debug("getPositionInformation START");
			logger.debug(" - document [" + LogUtility.getNullCheckString(document) + "]");
		}

		List<String> positionInformation = new ArrayList<String>();

		XPathFactory xPathFactory = XPathFactory.newInstance();
		XPath xpath = xPathFactory.newXPath();

		String PCA = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/POS_INFORMATION/PD_PCA");
		if ("true".compareToIgnoreCase(PCA) == 0)
		{
			positionInformation.add("Physicians' Comparability Allowance (PCA)");
		}

		String PDP = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/POS_INFORMATION/PD_PDP");
		if ("true".compareToIgnoreCase(PDP) == 0)
		{
			positionInformation.add("Physician and Dentist Pay (PDP)");
		}

		String FTT = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/POS_INFORMATION/PD_FTT");
		if ("true".compareToIgnoreCase(FTT) == 0)
		{
			positionInformation.add("Full-Time Telework (FTT)");
		}

		String OUT = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/POS_INFORMATION/PD_OUTSTATION");
		if ("true".compareToIgnoreCase(OUT) == 0)
		{
			positionInformation.add("Outstation (position is located in a remote location)");
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getPositionInformation END [" + LogUtility.getString(positionInformation) + "]");
		}
		watch.check();
		return positionInformation;
	}

	static public String getLatestClassificationDate(List<Grade> grades, boolean isExempt)
	{
		StopWatch watch = new StopWatch(CMSUtility.class, "getLatestClassificationDate");
		if (logger.isDebugEnabled())
		{
			logger.debug("getLatestClassificationDate START");
			logger.debug(" - grades [" + LogUtility.getString(grades) + "]");
			logger.debug(" - isExempt [" + LogUtility.getString(isExempt) + "]");
		}

		Date latestDate = null;

		int gradeCount = grades.size();
		String targetExemptCode = "Non-exempt";

		if (isExempt == true) {
			targetExemptCode = "Exempt";
		}

		DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");

		for (int index = 0; index < gradeCount; index++)
		{
			Grade grade = (Grade)grades.get(index);

			if (targetExemptCode.compareToIgnoreCase(grade.exempt) == 0)
			{
				Date date;
				try
				{
					date = formatter.parse(grade.classificationDate);
				}
				catch(ParseException e)
				{
					logger.error("Invalid date found on classification date. [" + grade.classificationDate + "]. This can be ignored.");
					continue;
				}

				if (latestDate != null)
				{
					if (latestDate.getTime() < date.getTime())
					{
						latestDate = date;
					}
				}
				else
				{
					latestDate = date;
				}
			}
		}

		String formattedDate = "";
		if (latestDate != null)
		{
			SimpleDateFormat targetFormatter = new SimpleDateFormat("MM/dd/yyyy");
			formattedDate = targetFormatter.format(latestDate);
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getLatestClassificationDate END [" + formattedDate + "]");
		}
		watch.check();
		return formattedDate;
	}

	static public String getExemptJobCode(List<Grade> grades, boolean isExempt)
	{
		StopWatch watch = new StopWatch(CMSUtility.class, "getExemptJobCode");
		if (logger.isDebugEnabled())
		{
			logger.debug("getExemptJobCode START");
			logger.debug(" - grades [" + LogUtility.getString(grades) + "]");
			logger.debug(" - isExempt [" + LogUtility.getString(isExempt) + "]");
		}

		String jobCodes = "";
		int gradeCount = grades.size();
		String targetExemptCode = "Non-exempt";

		if (isExempt == true) {
			targetExemptCode = "Exempt";
		}

		for (int index = 0; index < gradeCount; index++)
		{
			Grade grade = (Grade)grades.get(index);

			if (targetExemptCode.compareToIgnoreCase(grade.exempt) == 0)
			{
				if (jobCodes.length() > 0) {
					jobCodes = jobCodes + "; ";
				}
				jobCodes = jobCodes + grade.jobCode;
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getExemptJobCode END [" + jobCodes + "]");
		}
		watch.check();
		return jobCodes;
	}

	static public String getGradeCodes(List<Grade> grades, boolean isExempt)
	{
		StopWatch watch = new StopWatch(CMSUtility.class, "getGradeCodes");
		if (logger.isDebugEnabled())
		{
			logger.debug("getGradeCodes START");
			logger.debug(" - grades [" + LogUtility.getString(grades) + "]");
			logger.debug(" - isExempt [" + LogUtility.getString(isExempt) + "]");
		}

		String codes = "";

		String targetExemptCode = "Non-exempt";
		if (isExempt == true)
		{
			targetExemptCode = "Exempt";
		}

		int gradeCount = grades.size();

		for (int index = 0; index < gradeCount; index++)
		{
			Grade grade = (Grade)grades.get(index);
			if (targetExemptCode.compareToIgnoreCase(grade.exempt) == 0)
			{
				if (grade.grade != 0)
				{
					if (codes.length() > 0)
					{
						codes = codes + "/";
					}
					codes = codes + Integer.toString(grade.grade);
				}
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getGradeCodes END [" + codes + "]");
		}
		watch.check();
		return codes;
	}

	static public List<Grade> getGrades(Node document)
	{
		StopWatch watch = new StopWatch(CMSUtility.class, "getGrades");
		if (logger.isDebugEnabled())
		{
			logger.debug("getGrades START");
			logger.debug(" - document [" + LogUtility.getNullCheckString(document) + "]");
		}

		List<Grade> grades = new ArrayList<>();
		XPathFactory xPathFactory = XPathFactory.newInstance();
		XPath xpath = xPathFactory.newXPath();

		for (int index = 1; index <= 5; index++)
		{
			String indexString = Integer.toString(index);

			String gradeString = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/CS_GR_ID_" + indexString);

			int gradeNumber = 0;
			if (gradeString != null && gradeString.length() > 0)
			{
				try
				{
					gradeNumber = Integer.parseInt(gradeString);

					String jobCode = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_" + indexString);
					String classificationDate = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_" + indexString);
					String exempt = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/CS_FLSA_DETERM_ID_" + indexString);

					Grade grade = new Grade(gradeNumber, jobCode, classificationDate, exempt);
					grades.add(grade);

				}
				catch (NumberFormatException e)
				{
					logger.info("Invalid grade number found. [" + gradeString + "]. This can be ignored.");
				}
			}
		}

		if (grades.size() == 0)
		{
			String jobCode = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/CS_PD_NUMBER_JOBCD_1");
			String classificationDate = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/CS_CLASSIFICATION_DT_1");
			String exempt = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/CS_FLSA_DETERM_ID_1");

			Grade grade = new Grade(0, jobCode, classificationDate, exempt);
			grades.add(grade);
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getGrades END [" + LogUtility.getString(grades) + "]");
		}
		watch.check();
		return grades;
	}

	static public String getFullPerformanceLevel(Node document)
	{
		StopWatch watch = new StopWatch(CMSUtility.class, "getFullPerformanceLevel");
		if (logger.isDebugEnabled())
		{
			logger.debug("getFullPerformanceLevel START");
			logger.debug(" - document [" + LogUtility.getNullCheckString(document) + "]");
		}

		XPathFactory xPathFactory = XPathFactory.newInstance();
		XPath xpath = xPathFactory.newXPath();
		String lsReturnVal = XMLUtility.getValue(xpath, document, "/FORM_DATA/DOCUMENT/GENERAL/CS_PERFORMANCE_LEVEL");
		if (lsReturnVal == null || lsReturnVal.length() == 0){
			lsReturnVal = "";
		}
		return (lsReturnVal.length() == 1 ? "0" + lsReturnVal : lsReturnVal);
	}

	static public List<String> getPositionStandards(Node document)
	{
		StopWatch watch = new StopWatch(CMSUtility.class, "getPositionStandards");
		if (logger.isDebugEnabled())
		{
			logger.debug("getPositionStandards START");
			logger.debug(" - document [" + LogUtility.getNullCheckString(document) + "]");
		}

		List<String> standards = new ArrayList<String>();

		try
		{
			// Classification form has 2 variations of PD_CLS_STANDARDS
			//
			// #1. Multiple Node with single value - Old version
			//      <PD_CLS_STANDARDS>565</PD_CLS_STANDARDS>
            //      <PD_CLS_STANDARDS>567</PD_CLS_STANDARDS>
			//
			// #2. Single Node with multiple values - New version
			//      <PD_CLS_STANDARDS>572,594,631</PD_CLS_STANDARDS>
			//

			XPathFactory xPathFactory = XPathFactory.newInstance();
			XPath xpath = xPathFactory.newXPath();

			XPathExpression expression = xpath.compile("/FORM_DATA/DOCUMENT/CLASSIFICATION_CODE/PD_CLS_STANDARDS");
			NodeList nodeSet = (NodeList) expression.evaluate(document, XPathConstants.NODESET);

			int nodeCount = nodeSet.getLength();

			for (int index = 0; index < nodeCount; index++) {
				Node node = nodeSet.item(index);
				String value = node.getTextContent();
				if (value != null && value.length() > 0) {
					if (value.contains(",") == true) {
						String[] tokens = value.split(",");
						int tokenCount = tokens.length;
						for (int tokenIndex = 0; tokenIndex < tokenCount; tokenIndex++) {
							String translatedValue = LookupUtility.getLabel(tokens[tokenIndex]); // LookupUtility.getMap().get(value).label;
							standards.add(translatedValue);
						}
					} else {
						String translatedValue = LookupUtility.getLabel(value); // LookupUtility.getMap().get(value).label;
						standards.add(translatedValue);
					}
				}
			}
		}
		catch(XPathExpressionException e)
		{
			logger.error("XPath expression exception", e);
			standards.clear();
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getPositionStandards END [" + LogUtility.getString(standards) + "]");
		}
		watch.check();
		return standards;
	}
}
