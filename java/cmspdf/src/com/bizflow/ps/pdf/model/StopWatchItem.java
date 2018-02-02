package com.bizflow.ps.pdf.model;

/**
 * Created by jolinhama on 5/11/17.
 */
public class StopWatchItem
{
	private long count;
	private long totalElappsedTime = 0;
	private long minElappsedTime = 0;
	private long maxElappsedTime = 0;

	public StopWatchItem(long _elappsedTime)
	{
		count = 1;
		totalElappsedTime = _elappsedTime;
		minElappsedTime = _elappsedTime;
		maxElappsedTime = _elappsedTime;
	}

	public synchronized void add(long _elappsedTime)
	{
		count++;
		totalElappsedTime += _elappsedTime;
		if (minElappsedTime > _elappsedTime)
		{
			minElappsedTime = _elappsedTime;
		}
		if (maxElappsedTime < _elappsedTime)
		{
			maxElappsedTime = _elappsedTime;
		}
	}

	public long getCount()
	{
		return count;
	}
	public long getTotalElappsedTime()
	{
		return totalElappsedTime;
	}
	public long getMinElappsedTime()
	{
		return minElappsedTime;
	}
	public long getMaxElappsedTime()
	{
		return maxElappsedTime;
	}
}
