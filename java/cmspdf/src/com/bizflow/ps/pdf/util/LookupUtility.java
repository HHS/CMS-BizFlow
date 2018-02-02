package com.bizflow.ps.pdf.util;

import com.bizflow.ps.pdf.model.Lookup;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.util.HashMap;
import java.util.Map;

public class LookupUtility
{
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(LookupUtility.class);

	static private boolean initialized = false;
	static private Map<Integer, Lookup> map = new HashMap<Integer, Lookup>();

	static public void initialize(Node lookup)
	{
		StopWatch watch = new StopWatch(LookupUtility.class, "initialize");
		if (logger.isDebugEnabled())
		{
			logger.debug("initialize START");
			logger.debug(" - lookup [" + LogUtility.getNullCheckString(lookup) + "]");
		}

		if (initialized != true)
		{
			Document element = (Document) lookup;
			NodeList lookups = element.getElementsByTagName("record");
			int lookupCount = lookups.getLength();

			for (int index = 0; index < lookupCount; index++)
			{
				Node node = lookups.item(index);
				Lookup lookupItem = new Lookup(node);
				map.put(lookupItem.ID, lookupItem);
			}

			initialized = true;
			logger.info("LookupUtility is initialized.");
		}
		else
		{
			if (logger.isDebugEnabled())
			{
				logger.debug("LookupUtility is already initialized.");
			}
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("initialize END");
		}
		watch.check();
	}

	static public Map<Integer, Lookup> getMap()
	{
		StopWatch watch = new StopWatch(LookupUtility.class, "getMap");
		if (logger.isDebugEnabled())
		{
			logger.debug("getMap START");
		}

		Map<Integer, Lookup> mapInstance = null;
		if (initialized != false)
		{
			mapInstance = map;
		}
		else
		{
			logger.error("LookupUtility is not initialized yet.");
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getMap END [" + LogUtility.getNullCheckString(mapInstance) + "]");
		}
		watch.check();
		return mapInstance;
	}

	static public String getLabel(String key)
	{
		StopWatch watch = new StopWatch(LookupUtility.class, "getLabel(String)");
		if (logger.isDebugEnabled())
		{
			logger.debug("getLabel(String) START");
			logger.debug(" - key [" + key + "]");
		}

		String foundLabel = null;
		try
		{
			int keyNumber = Integer.parseInt(key);
			foundLabel = LookupUtility.getLabel(keyNumber);
		}
		catch(NumberFormatException e)
		{
			logger.error("Cannot find the label for [" + key + "]");
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getLabel(String) END [" + foundLabel + "]");
		}
		watch.check();
		return foundLabel;
	}

	static public String getLabel(int key)
	{
		StopWatch watch = new StopWatch(LookupUtility.class, "getLabel(Int)");
		if (logger.isDebugEnabled())
		{
			logger.debug("getLabel(int) START");
			logger.debug(" - key [" + Integer.toString(key) + "]");
		}

		String foundResult = null;

		if (initialized != false)
		{
			Lookup foundLookup = (Lookup)map.get(key);
			if (foundLookup != null)
			{
				foundResult = foundLookup.label;
			}
			else
			{
				logger.error("Cannot find the item for [" + Integer.toString(key) + "]");
			}
		}
		else
		{
			logger.error("LookupUtility is not initialized yet.");
		}

		if (logger.isDebugEnabled())
		{
			logger.debug("getLabel(int) END [" + foundResult + "]");
		}
		watch.check();
		return foundResult;
	}
}
