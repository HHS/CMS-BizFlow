package com.bizflow.ps.pdf.util;

import com.bizflow.ps.pdf.model.Lookup;
import org.w3c.dom.*;
import org.xml.sax.SAXException;
import javax.xml.parsers.*;
import javax.xml.xpath.*;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class XMLUtility
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(XMLUtility.class);

	public static int getIntAttribute(Element element, String attributeName) throws Exception
	{
		if (logger.isDebugEnabled())
		{
			logger.debug("getIntAttribute START");
			logger.debug(" - element [" + LogUtility.getNullCheckString(element) + "]");
			logger.debug(" - attributeName [" + attributeName + "]");
		}

		StopWatch watch = new StopWatch(XMLUtility.class, "getIntAttribute");
		if (element != null && attributeName != null && attributeName.length() > 0)
		{
			String valueString = element.getAttribute(attributeName);
			int valueInt = Integer.parseInt(valueString);

			if (logger.isDebugEnabled())
			{
				logger.debug("getIntAttribute END [" + Integer.toString(valueInt) + "]");
			}
			watch.check();
			return valueInt;
		}
		else
		{
			if (element == null)
			{
				logger.error("element is null.");
			}
			if (attributeName == null || attributeName.length() == 0)
			{
				logger.error("attributeName is null or empty.");
			}
			watch.check();
			throw new Exception("Failed Parameter validation. element of attributeName is null.");
		}
	}

	public static int getIntAttribute(Element element, String attributeName, int defaultValue) throws Exception
	{
		int result = 0;
		try
		{
			result = getIntAttribute(element, attributeName);
		}
		catch (NumberFormatException e)
		{
			result = defaultValue;
		}
		return result;
	}

	public static float getFloatAttribute(Element element, String attributeName) throws Exception
	{
		if (element != null && attributeName != null && attributeName.length() > 0)
		{
			String valueString = element.getAttribute(attributeName);
			if (valueString != null && valueString.length() > 0)
			{
				float valueFloat = Float.parseFloat(valueString);
				return valueFloat;
			}
			else
			{
				return 0;
			}
		}
		else
		{
			throw new Exception("Failed Parameter validation. element of attributeName is null.");
		}
	}

	public static float getFloatAttribute(Element element, String attributeName, float defaultValue) throws Exception
	{
		float result = 0;
		try
		{
			result = getFloatAttribute(element, attributeName);
		}
		catch (NumberFormatException e)
		{
			result = defaultValue;
		}
		return result;
	}

	private static String translateValue(Element element, String value)
	{
		StopWatch watch = new StopWatch(XMLUtility.class, "translateValue");
		if (logger.isDebugEnabled())
		{
			logger.debug("translateValue START");
			logger.debug(" - element [" + LogUtility.getNullCheckString(element) + "]");
			logger.debug(" - value [" + value + "]");
		}

		String translatedValue = value;
		if ("Select One".compareToIgnoreCase(value) == 0)
		{
			translatedValue = "";
		}

		String lookup = element.getAttribute("lookup");
		String displayValues = element.getAttribute("displayValues");
		if ("true".compareToIgnoreCase(lookup) == 0)
		{
			String lookupField = element.getAttribute("lookupField");
			int lookupID;
			try
			{
				lookupID = Integer.parseInt(value);
			}
			catch(NumberFormatException e)
			{
				lookupID = 0;
			}
			Lookup lookupItem = LookupUtility.getMap().get(lookupID);
			if (lookupItem != null)
			{
				if (lookupField != null && lookupField.compareToIgnoreCase("name") == 0)
				{
					translatedValue = lookupItem.name;
				}
				else
				{
					translatedValue = lookupItem.label;
				}
			}
		}
		else if (displayValues != null && displayValues.length() > 0)
		{
			String whenValueIs = element.getAttribute("whenValueIs");
			String whenValueIsNot = element.getAttribute("whenValueIsNot");
			String[] valueToken = displayValues.split("\\|");

			if (whenValueIs != null && whenValueIs.length() > 0)
			{
				if (whenValueIs.compareToIgnoreCase(value) == 0)
				{
					translatedValue = valueToken[0];
				}
				else
				{
					if (valueToken.length > 1)
					{
						translatedValue = valueToken[1];
					}
					else
					{
						translatedValue = "";
					}
				}
			}
			else if (whenValueIsNot != null && whenValueIsNot.length() > 0)
			{
				if (whenValueIsNot.compareToIgnoreCase(value) != 0)
				{
					translatedValue = valueToken[0];
				}
				else
				{
					if (valueToken.length > 1)
					{
						translatedValue = valueToken[1];
					}
					else
					{
						translatedValue = "";
					}
				}
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("translateValue END [" + translatedValue + "]");
		}
		watch.check();
		return translatedValue;
	}

	public static Map<String, String> generateValueMap(String mapFile, Node documentData)
	{
		StopWatch watch = new StopWatch(XMLUtility.class, "generateValueMap");
		if (logger.isDebugEnabled())
		{
			logger.debug("generateValueMap START");
			logger.debug("- mapFile [" + mapFile + "]");
			logger.debug("- documentData [" + LogUtility.getNullCheckString(documentData) + "]");
		}

		Map<String, String> map = new HashMap<String, String>();

		try
		{
			File xmlFile = new File(mapFile);

			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = dbFactory.newDocumentBuilder();
			Document document = builder.parse(xmlFile);
			document.getDocumentElement().normalize();
			NodeList nodes = document.getElementsByTagName("item");

			XPathFactory xPathFactory = XPathFactory.newInstance();
			XPath xpath = xPathFactory.newXPath();
			int count = nodes.getLength();

			for (int index = 0; index < count; index++)
			{
				String key, value, realValue = "";

				Element item = (Element) nodes.item(index);

				NodeList keys = item.getElementsByTagName("key");
				int keyCount = keys.getLength();
				if (keyCount == 1)
				{
					key = keys.item(0).getTextContent();
					NodeList values = item.getElementsByTagName("value");
					int valueCount = values.getLength();
					if (valueCount == 1)
					{
						Element element = (Element) values.item(0);
						value = element.getTextContent();

						if (value != null && value.length() > 0)
						{
							XPathExpression expression = xpath.compile(value);
							realValue = (String) expression.evaluate(documentData, XPathConstants.STRING);
							realValue = XMLUtility.translateValue(element, realValue);
						}
						map.put(key, realValue);
					}
				}
			}
		}
		catch(ParserConfigurationException | IOException | SAXException | XPathExpressionException e)
		{
			logger.error("Failed to generate lookup manager", e);
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("generateValueMap END [" + LogUtility.getString(map) + "]");
		}
		watch.check();
		return map;
	}

	static public String getValue(XPath xpath, Node document, String xpathExprStr)
	{
		StopWatch watch = new StopWatch(XMLUtility.class, "getValue");

		if (logger.isDebugEnabled())
		{
			logger.debug("getValue START");
			logger.debug(" - xpath [" + LogUtility.getNullCheckString(xpath) + "]");
			logger.debug(" - document [" + LogUtility.getNullCheckString(document) + "]");
			logger.debug(" - xpathExprStr [" + xpathExprStr + "]");
		}

		String value = null;
		try
		{
			XPathExpression expression = xpath.compile(xpathExprStr);
			value = (String) expression.evaluate(document, XPathConstants.STRING);
		}
		catch(XPathExpressionException e)
		{
			logger.error("Invalid xpath expression.", e);
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getValue END [" + value + "]");
		}
		watch.check();
		return value;
	}
}
