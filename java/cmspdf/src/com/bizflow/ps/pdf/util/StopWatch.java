package com.bizflow.ps.pdf.util;

import com.bizflow.ps.pdf.model.StopWatchItem;

import java.util.HashMap;
import java.util.Map;

public class StopWatch
{
	// This logger will be activated only if log level is DEBUG.
	static org.apache.log4j.Logger logger = org.apache.log4j.Logger.getLogger(StopWatch.class);
	static Map<String, StopWatchItem> archivedResult = new HashMap<String, StopWatchItem>();

	Class sourceClass;
	String functionName;
	long start;
	long check;
	static boolean useNanoSecond = true;

	private synchronized void archive(long from, long to, String message)
	{
		if (logger.isDebugEnabled())
		{
			String keyString = sourceClass.getCanonicalName() + "." + functionName + (message != null ? " " + message : "");
			StopWatchItem item = (StopWatchItem) archivedResult.get(keyString);
			if (item != null)
			{
				item.add(to - from);
			}
			else
			{
				StopWatchItem newItem = new StopWatchItem(to - from);
				archivedResult.put(keyString, newItem);
			}
		}
	}

	static public void printArchive()
	{
		if (logger.isDebugEnabled())
		{
			logger.debug("");
			logger.debug("Archived measured items");
			logger.debug("--------------------------------");
			int count = archivedResult.size();
			if (count > 0)
			{
				for (Map.Entry<String, StopWatchItem> entry : archivedResult.entrySet())
				{
					String key = entry.getKey();
					StopWatchItem item = entry.getValue();

					double total = 1.0 * item.getTotalElappsedTime();
					long callCount = item.getCount();
					double min = 1.0 * item.getMinElappsedTime();
					double max = 1.0 * item.getMaxElappsedTime();
					double avg = total / callCount;

					if (useNanoSecond)
					{
						total /= 1000000;
						min /= 1000000;
						max /= 1000000;
						avg /= 1000000;
					}

					// Count / Total / Avg / Min / Max / Key
					String itemArchived = String.format("Count:[%10d] Total:[%10.3f ms] Avg:[%10.3f ms] Max:[%10.3f ms] Min:[%10.3f ms] %s", callCount, total, avg, max, min, key);
					logger.debug(itemArchived);
				}
			}
			else
			{
				logger.debug("No entry found.");
			}
		}
	}

	private long getSecond() {
		long now = 0;
		if (useNanoSecond == true)
		{
			now = System.nanoTime();
		}
		else
		{
			now = System.currentTimeMillis();
		}
		return now;
	}

	private String getElappsedTimeString(long from, long to)
	{
		String diffString;
		if (useNanoSecond)
		{
			double nanoDiff = (to - from) * 1.0 / 1000000;
			diffString = Double.toString(nanoDiff);
		}
		else
		{
			diffString = Long.toString(to - from);
		}

		return diffString;
	}


	public StopWatch(Class _sourceClass, String _functionName)
	{
		if (logger.isDebugEnabled())
		{
			sourceClass = _sourceClass;
			functionName = _functionName;
			start = getSecond();
			check = start;

			logger.debug(sourceClass.getCanonicalName() + "." + functionName + " START");
		}
	}

	public void check()
	{
		if (logger.isDebugEnabled())
		{
			long checkNow = getSecond();
			StringBuffer sb = new StringBuffer();
			sb.append(sourceClass.getCanonicalName()).append(".").append(functionName).append(" END");
			sb.append(" [").append(getElappsedTimeString(start, checkNow)).append(" ms]");
			logger.debug(sb.toString());

			archive(start, checkNow, null);
		}
	}

	public void checkPoint(String message)
	{
		if (logger.isDebugEnabled())
		{
			long checkNow = getSecond();

			StringBuffer sb = new StringBuffer();
			sb.append(sourceClass.getCanonicalName()).append(".").append(functionName).append(" ").append(message).append(" END");
			sb.append(" [").append(getElappsedTimeString(check, checkNow)).append(" ms]");
			logger.debug(sb.toString());

			archive(check, checkNow, message);

			check = checkNow;
		}
	}
}
