package com.bizflow.ps.pdf.model;

import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class Lookup
{
	public int ID;
	public int parentID;
	public String lType;
	public String label;
	public String active;
	public String dispOrder;
	public String name;

	public Lookup(int _ID, int _ParentID, String _LType, String _Label, String _Active, String _DispOrder)
	{
		ID = _ID;
		parentID = _ParentID;
		lType = _LType;
		active = _Active;
		dispOrder = _DispOrder;
	}

	public Lookup(Node lookupNode) throws NumberFormatException
	{
		NodeList nodeList = lookupNode.getChildNodes();

		int nodeCount = nodeList.getLength();

		for (int index = 0; index < nodeCount; index++)
		{
			Node node = nodeList.item(index);
			String nodeName = node.getNodeName();
			String value = node.getTextContent();

			if ("ID".compareToIgnoreCase(nodeName) == 0)
			{
				try
				{
					ID = Integer.parseInt(value);
				}
				catch(NumberFormatException e)
				{
					throw e;
				}
			}
			else if ("PARENTID".compareToIgnoreCase(nodeName) == 0)
			{
				try
				{
					parentID = Integer.parseInt(value);
				}
				catch(NumberFormatException e)
				{
					// can be ignored
				}
			}
			else if ("LTYPE".compareToIgnoreCase(nodeName) == 0)
			{
				lType = value;
			}
			else if ("ACTIVE".compareToIgnoreCase(nodeName) == 0)
			{
				active = value;
			}
			else if ("DISPORDER".compareToIgnoreCase(nodeName) == 0)
			{
				dispOrder = value;
			}
			else if ("LABEL".compareToIgnoreCase(nodeName) == 0)
			{
				label = value;
			}
			else if ("NAME".compareToIgnoreCase(nodeName) == 0)
			{
				name = value;
			}
		}
	}
}
