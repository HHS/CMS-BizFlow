package com.bizflow.ps.pdf.model;

import com.bizflow.ps.pdf.util.XMLUtility;
import org.w3c.dom.*;

public class PDFOverlayItem
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(PDFOverlayItem.class);

	String font;
	float fontSize;
	float x;
	float y;
	String text;
	String type;
	//String value;
	String multipleLine;
	float width = -1;
	float height;
	float maxFontSize = -1;

	public PDFOverlayItem(Element element) throws Exception
	{
		font = element.getAttribute("font");
		fontSize = XMLUtility.getFloatAttribute(element, "fontSize");
		x = XMLUtility.getFloatAttribute(element, "x");
		y = XMLUtility.getFloatAttribute(element, "y");
		type = element.getAttribute("type");
		text = element.getTextContent();
		multipleLine = element.getAttribute("multipleLine");
		width = XMLUtility.getFloatAttribute(element, "width");
		height = XMLUtility.getFloatAttribute(element, "height");
		maxFontSize = XMLUtility.getFloatAttribute(element, "maxFontSize");
	}

	public String toString()
	{
		return "PDFOverlayItem [font:" + font + ", fontSize:" + Float.toString(fontSize) + ", x:" + Float.toString(x)
				+ ", y:" + Float.toString(y) + ", type:" + type +", text:"+ text + "]";
	}
}
