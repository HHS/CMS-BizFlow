package com.bizflow.ps.pdf.util;

/**
 * Created by jolinhama on 4/15/19.
 */
public class Utility
{
	static public boolean isValidStringParameter(String paramValue) {
		if (paramValue != null && paramValue.length() > 0) {
			return true;
		} else {
			return false;
		}
	}
}
