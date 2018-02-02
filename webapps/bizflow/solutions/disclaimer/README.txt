/**
 * BizFlow 12 Disclaimer custom add on
 *
 * Company: BizFlow Corp
 *
 * Showing a disclaimer dialog when user logs into BizFlow 12.x
 *
 * @author Taeho Lee (thlee@bizflow.com)
 * @version 1.0
 * @created: June 21, 2013
 * @modification history
 * @modified: 
 */
How to use disclaimer addon in BizFlow 12.

This BizFlow custom addon provides a way to show disclaimer when user logs into BizFlow.

--------------------------------------------------
# Features
--------------------------------------------------
	1. showing disclaimer only once after logged in.
	2. user must clicks on the OK button in the disclaimer before using BizFlow system.
	3. disclaimer body text is configurable in a separate text file.


--------------------------------------------------
# Deployment
--------------------------------------------------

	Generally speaking, what you need to do is changing 2 jsp files in BizFlow 12.x.

	Note: since this requires changing BizFlow product code, you must make sure to re-apply the changes again after BizFlow 12 patch applied.

	1. Deploy the custom addon
		1.1 Download the disclaimer custom addon from the SVN server.
		1.2 Unzip the file
		1.3 Copy the disclaimer folder to webapps\bizflow\solutions folder.
			i.e. webapps\bizflow\solutions\disclaimer

	2. Modify login.jsp
		2.1 open login.jsp in webapps\bizflow folder by using any text editor.

		2.2 Search code lines below in the file.
			boolean useParameterFilter =  "ON".equalsIgnoreCase(bizflowProps.getProperty("com.hs.bf.web.parameterFilter"));
			session.setAttribute("excel.maxrecordcount", bizflowProps.getProperty("com.hs.bf.web.bizcove.excel.maxrecordcount"));

		2.3 Add lines below right before the code above 
			//DISCLAIMEER CUSTOMIZATION by TAEHO - BEGIN
			session.setAttribute("_WasDisclaimerDisplayed", "N"); //Initializing Disclaimer
			//DISCLAIMEER CUSTOMIZATION by TAEHO - END

			Result should be like below.
			<%
			//DISCLAIMEER CUSTOMIZATION by TAEHO - BEGIN
			session.setAttribute("_WasDisclaimerDisplayed", "N"); //Initializing Disclaimer
			//DISCLAIMEER CUSTOMIZATION by TAEHO - END

			boolean useParameterFilter =  "ON".equalsIgnoreCase(bizflowProps.getProperty("com.hs.bf.web.parameterFilter"));
			session.setAttribute("excel.maxrecordcount", bizflowProps.getProperty("com.hs.bf.web.bizcove.excel.maxrecordcount"));

	3. Modify bizindex.jsp

		3.1 open bizindex.jsp in webapps\bizflow folder by using any text editor.

		2.2 Search code lines below in the file.
			</body>
			</html>

		2.3 Add lines below right before the code above 
			<!-- DISCLAIMEER CUSTOMIZATION by TAEHO - BEGIN //-->
			<%@ include file="solutions/disclaimer/disclaimer.jsp" %>
			<!-- DISCLAIMEER CUSTOMIZATION by TAEHO - END //-->

			Result should be like below.
			<!-- DISCLAIMEER CUSTOMIZATION by TAEHO - BEGIN //-->
			<%@ include file="solutions/disclaimer/disclaimer.jsp" %>
			<!-- DISCLAIMEER CUSTOMIZATION by TAEHO - END //-->

			</body>
			</html>

--------------------------------------------------
# Configuration of Disclaimer dialog
--------------------------------------------------

Configuration file of the disclaimer custom addon is a java properties file which is located in the same folder.

	webapps\bizflow\solutions\discalimer\disclaimer.properties.


	disclaimer.enabled
		[ TRUE | FALSE ] //TRUE: enable disclaimer, FALSE: disable disclaimer
	disclaimer.dialog.width
		the width of the disclaimer dialog (default 700)
	disclaimer.dialog.height
		the height of the disclaimer dialog (default 500)
	disclaimer.dialog.effect
		the effect of showing/hiding dialog effect (default fade)
	disclaimer.dialog.button.label
		button label of the disclaimer dialog. (default OK)
	dicalaimer.body.content.file.name
		file name having the disclaimer test (default disclaimer.html)
		the file must be in the same folder.
	dicalaimer.body.content.reload=ALWAYS
		[ ONCE | ALWAYS ]
		ONCE: load disclaimer text from the file only once for better performance (default value)
		ALWAYS: load the text from the file everty time.



--------------------------------------------------
# How to change disclaimer text
--------------------------------------------------

	1. Open the file configured "dicalaimer.body.content.file.name" by using any text editor
		default file name is disclaimer.html
	2. The content support both html and text format.
		for better style, use html.
	

--------------------------------------------------
# Moudules
--------------------------------------------------

	1. README.txt
		This file
	2. logo_smaill.png
		sample image of the customer.
	3. markdisclaimer.jsp
		a small module called from disclaimer.jsp thru ajax call to make sure the disclaimer dialog showing only once after user logs in.
	4. disclaimer.jsp
		jsp file having the disclaimer logic which must be included in bizindex.jsp
	5. disclaimer.properties
		configuration file of the disclaimer dialog. most of cases, you do not need to change it unless changing size of the dialog.
	6. disclaimer.html
		disclaimer body text. you will need to change this file.

