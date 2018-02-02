package com.bizflow.ps.pdf.util;

import com.bizflow.ps.pdf.model.Grade;
import org.w3c.dom.Node;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.StringWriter;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Created by jolinhama on 5/11/17.
 */
public class LogUtility
{
	static public String getString(List items)
	{
		StringBuffer sb = new StringBuffer();

		if (items != null && items.size() > 0)
		{
			Iterator iterator = items.iterator();

			while (iterator.hasNext())
			{
				Object item = iterator.next();
				if (item instanceof String)
				{
					String finalItem = (String)item;
					sb.append("[").append(finalItem).append("]");
				}
				else if (item instanceof Grade)
				{
					Grade finalItem = (Grade)item;
					sb.append("[").append(finalItem.toString()).append("]");
				}
				else if (item instanceof Integer)
				{
					Integer finalItem = (Integer)item;
					sb.append("[").append(finalItem.toString()).append("]");
				}
			}
		}

		return sb.toString();
	}

	static public String getString(boolean value)
	{
		String translated = "true";
		if (value != true)
		{
			translated = "false";
		}
		return translated;
	}

	static public String getNullCheckString(Object object)
	{
		String translated = "NOT NULL";
		if (object == null)
		{
			translated = "NULL";
		}
		return translated;
	}

	static public String getString(Map<String, String> map)
	{
		StringBuffer sb = new StringBuffer();

		sb.append("[");
		for (Map.Entry<String, String> entry : map.entrySet())
		{
			String key = entry.getKey();
			String value = entry.getValue();
			sb.append("(").append(key).append("=>").append(value).append(")");
		}
		sb.append("]");
		return sb.toString();
	}

	static public String getString(Node node)
	{
		StringWriter sw = new StringWriter();
		try
		{
			if (node != null)
			{
				Transformer t = TransformerFactory.newInstance().newTransformer();
				t.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
				t.setOutputProperty(OutputKeys.INDENT, "yes");
				t.transform(new DOMSource(node), new StreamResult(sw));
			}
		}
		catch (Exception e)
		{
		}
		return sw.toString();
	}
}
