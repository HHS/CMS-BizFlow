package com.bizflow.ps.pdf.model;

public class Grade
{
	public String jobCode;
	public String classificationDate;
	public int grade;
	public String exempt;

	public Grade(int _grade, String _jobCode, String _classificationDate, String _exempt)
	{
		jobCode = _jobCode;
		classificationDate = _classificationDate;
		grade = _grade;
		exempt = _exempt;
	}

	public String toString()
	{
		return "Grade [grade = " + grade + ", jobCode = " + jobCode + ", classificationDate = " + classificationDate + ", exempt = " + exempt + "]";
	}
}
