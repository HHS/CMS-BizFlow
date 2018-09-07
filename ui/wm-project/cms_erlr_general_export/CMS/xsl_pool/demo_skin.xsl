<?xml version="1.0" encoding="UTF-8"?>
<!--
/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */
-->
<xsl:stylesheet exclude-result-prefixes="mvc" version="1.0" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output encoding="ISO-8859-1" indent="yes" method="html" />
    <!--
        Generates the skeleton html for the screen, lays out the tables that make up the page calling appropriate templates to fill in page content.
    -->
    <xsl:template match="/" name="demo_skin">
        <html lang="en" xml:lang="en" xmlns="">
            <head>
                <!-- Fill in the contents of the <head> html element -->
                <xsl:call-template name="head_html" />
            </head>
            <xsl:call-template name="page" />
        </html>
    </xsl:template>
    <xsl:template name="page">
        <body class="soria" xmlns="">
            <xsl:call-template name="output-page-body-styling">
                <xsl:with-param name="baseClass">soria</xsl:with-param>
            </xsl:call-template>

            <!-- Test buttons for the Workitem Handler Actions -->
            <xsl:call-template name="output-test-mode-buttons" />
            <!-- Fill in the Header -->
            <xsl:call-template name="header" />

            <!-- Fill in the main body -->
            <xsl:call-template name="body" />

            <!-- Fill in the Footer -->
            <xsl:call-template name="footer" />


        </body>
    </xsl:template>
    <!--
        Provides the contents for the HTML <head> element
    -->
    <xsl:template name="head_html">
        <title xmlns="">WebMaker - Application</title>
        <!-- insert application wide meta tags.
             This template is implemented below -->
        <xsl:call-template name="global_meta_tags" />
        <!-- insert page meta tags.
             This template needs to be implemented by each page that requires custom meta tags -->
        <xsl:call-template name="page_meta_tags" />
        <!-- insert dojo css and script -->
        <xsl:call-template name="dojo_imports" />
        <!-- insert css -->
        <xsl:call-template name="css_imports" />
        <!-- Fill in the client side scripts -->
        <xsl:call-template name="global_scripts" />
        <xsl:call-template name="page_scripts" />
    </xsl:template>
    <!--
        Contains CSS or Script files that are needed for evey page of an application, in addition to the settings within FormMaker.
        This currently contains the dojo required files.
    -->
    <xsl:template name="dojo_imports">
        <link href="../_resources/dojo/dojo/resources/dojo.css" rel="stylesheet" type="text/css" xmlns="" />
        <link href="../_resources/dojo/dijit/themes/soria/soria.css" rel="stylesheet" type="text/css" xmlns="" />
        <script data-dojo-config="parseOnLoad:true, async:false, isDebug:false" src="../_resources/dojo/dojo/dojo.js" type="text/javascript" xmlns="">//import dojo main script</script>
    </xsl:template>
    <!--
        Placeholder for specifying application specific CSS files.
        This template will be overridden by each page to specify the required CSS imports using the
        information defined within FormMaker.
    -->
    <xsl:template name="css_imports"></xsl:template>
    <!-- Contains all the META tags that should be placed on every page of the application. -->
    <xsl:template name="global_meta_tags">
        <meta content="text/xml; charset=UTF-8" http-equiv="Content-Type" xmlns="" />
        <meta content="text/css" http-equiv="Content-Style-Type" xmlns="" />
        <meta content="index,follow" http-equiv="Robots" name="Robots" xmlns="" />
        <meta content="noarchive" name="robots" xmlns="" />
        <meta content="true" name="MSSmartTagsPreventParsing" xmlns="" />
        <meta content="no" name="publication" xmlns="" />
         <!-- Handheld device support -->
        <meta content="width=device-width, initial-scale=1.0, user-scalable=yes" name="viewport" />
        <meta content="yes" name="apple-mobile-web-app-capable" />
       <!--<meta content="http://localhost:7080/Example" name="DC.identifier" scheme="URI" xmlns="" />
        <meta content="Hyfinity Corporate Web Site" lang="en" name="DC.title" xmlns="" />
        <meta content="FormMaker by Hyfinity Limited" lang="en" name="DC.creator" xmlns="" />
        <meta content="Hyfinity MVC demonstration application" name="DC.description" xmlns="" />
        <meta content="FormMaker by Hyfinity Limited - info@hyfinity.com" lang="en" name="DC.publisher" xmlns="" />
        <meta content="2005-03-14" name="DC.date.created" scheme="W3CDTF" xmlns="" />
        <meta content="2005-03-14" name="DC.date.modified" scheme="W3CDTF" xmlns="" />
        <meta content="text/html" name="DC.format" scheme="IMT" xmlns="" />
        <meta content="FormMaker by Hyfinity Limited" name="DC.contributor" xmlns="" />
        <meta content="Hyfinity Limited - http://www.hyfinity.com" name="DC.rights.copyright" xmlns="" />
        <meta content="FormMaker by Hyfinity Limited" http-equiv="Author" name="Author" xmlns="" />
        <meta content="XML, SOA, Service Oriented Architecture, composite applications, xforms, xsd, transactional web sites, B2B integration" name="keywords" xmlns="" />
        <meta content="Hyfinity MVC demonstration application" name="description" xmlns="" />-->
    </xsl:template>
    <!-- Details all the page specific meta tags required.
         This template should be overridden by each page that requires custom meta tags. -->
    <xsl:template name="page_meta_tags" />
    <!-- Import the standard scripts required on every FormMaker page
         If you wish to add any additional script files to your particular project, this should be
         done using the options on the FormMaker Application Map screen. -->
    <xsl:template name="global_scripts">
        <script src="js/DisplayUtils.js" type="text/javascript" xmlns="">//handles hide/display operations</script>
        <script src="js/FormValidator.js" type="text/javascript" xmlns="">//main entry point for validating a form</script>
        <script src="js/NumberValidator.js" type="text/javascript" xmlns="">//provides number validation</script>
        <script src="js/StringValidator.js" type="text/javascript" xmlns="">//provides string validation</script>
        <script src="js/BooleanValidator.js" type="text/javascript" xmlns="">//provides boolean validation</script>
        <script src="js/ValidationError.js" type="text/javascript" xmlns="">//represents a valiadtion error</script>
        <script src="js/ErrorDisplay.js" type="text/javascript" xmlns="">//shows validation errors on the form </script>
        <script src="js/DisplayMessages.js" type="text/javascript" xmlns="">//provides a list of display messages for each error</script>
        <script src="js/DateValidator.js" type="text/javascript" xmlns="">//provides date validation functions</script>
        <script src="js/FMActions.js" type="text/javascript" xmlns="">//provides implementations of the FM inbuilt actions</script>
        <script src="js/ValueConverter.js" type="text/javascript" xmlns="">//provides value conversion functions</script>
        <script src="js/combobox.js" type="text/javascript" xmlns="">//script required for editable combo box entries</script>
        <script src="js/date.js" type="text/javascript" xmlns="">//provides date manipulation functions</script>
        <script src="js/CalendarPopup.js" type="text/javascript" xmlns="">//creates a calendar popup</script>
        <script src="js/basicwihactionclient.js" type="text/javascript" xmlns="">//Work Item Handler client</script>
    </xsl:template>
    <!--
        Place holder for page specific script includes.
        This will be overridden by each page XSL to include the files specified within FormMaker
    -->
    <xsl:template name="page_scripts" />

    <!--
        Builds the main body of the page.
    -->
    <xsl:template name="body">
        <!-- Fill in the main body -->
        <div class="main_body" xmlns="">
            <xsl:call-template name="output-main-body-styling">
                <xsl:with-param name="baseClass">main_body</xsl:with-param>
            </xsl:call-template>

            <xsl:if test="/mvc:eForm/mvc:Control/error">
                <div class="messageBox">
                    <xsl:for-each select="/mvc:eForm/mvc:Control/error">
                        <xsl:value-of select="./@desc" />
                        <br />
                    </xsl:for-each>
                </div>
            </xsl:if>
            <xsl:call-template name="section_body" />
        </div>
    </xsl:template>

    <!--
        Builds the section body within main body.
        This template will be overridden by each page to supply the main content
    -->
    <xsl:template name="section_body" />

    <!-- Work out whether the page is being displayed in test mode,
         and if so output buttons to allow testing of the Workitem Handler interface points.
         This currently supports the save, complete, exit, forward, and reply functions. -->
    <xsl:template name="output-test-mode-buttons">
        <xsl:if test="/mvc:eForm/mvc:Data/WorkitemContext/TestMode = 'IsolatedForm'">
            <!--should output the buttons -->
            <style type="text/css">
                .workitemTestBar {background-color:#0986B1; height: 30px; margin-top : 5px; margin-bottom: 10px; padding: 2px 6px; position: relative; }
                .workitemTestButton a {display:inline-block; border-radius: 3px; padding : 2px 2px 2px 24px; height : 24px; line-height : 24px; background-repeat : no-repeat; background-position: 2px center; color:#fff; font-size:11px; font-weight : bold; cursor : pointer;}
                .workitemTestButton a:hover {background-color : #84C959; }
                .workitemTestButton.wiComplete a {background-image: url(images/controls/complete.png);}
                .workitemTestButton.wiForward a {background-image: url(images/controls/forward.png);}
                .workitemTestButton.wiReply a {background-image: url(images/controls/reject.png);} /*Is this the right image? */
                .workitemTestButton.wiSave a {background-image: url(images/controls/save.png);}
                .workitemTestButton.wiExit a {background-image: url(images/controls/exit.png);}
                .workitemTestButton .bar  {border-left: 1px solid #1165C5; height: 14px; margin: 0 5px; width: 0px;}
                .workitemHelp {display:inline-block; vertical-align:middle; height:28px; width : 18px; padding-left: 10px; background-image: url(images/controls/help.png); background-repeat : no-repeat; background-position: center center;}
            </style>
            <div id="workitem_test_buttons" class="workitemTestBar">
                <span id="onWorkitemComplete_test_button" class="workitemTestButton wiComplete" title="Complete"><a onclick="onWorkitemComplete()" class="btn">Complete</a><span class="bar"/></span>
                <span id="onWorkitemForward_test_button" class="workitemTestButton wiForward" title="Forward"><a onclick="onWorkitemForward()" class="btn">Forward</a><span class="bar"/></span>
                <span id="onWorkitemReply_test_button" class="workitemTestButton wiReply" title="Reply"><a onclick="onWorkitemReply()" class="btn">Reply</a><span class="bar"/></span>
                <span id="onWorkitemSave_test_button" class="workitemTestButton wiSave" title="Save"><a onclick="onWorkitemSave()" class="btn">Save</a><span class="bar"/></span>
                <span id="onWorkitemExit_test_button" class="workitemTestButton wiExit" title="Exit"><a onclick="onWorkitemExit()" class="btn">Exit</a><span class="bar"/></span>
                <span id="onWorkitem_help_button" onclick="" class="workitemHelp" title="Workitem Handler test buttons will only appear here if a 'Workitem Handler Control' has been added to the page."></span>

                <script type="text/javascript">
                    hyf.attachEventHandler(window, 'onload', function(){
                        if (typeof(window.onWorkitemSave) != 'function')
                            document.getElementById('onWorkitemSave_test_button').style.display = 'none';
                        if (typeof(window.onWorkitemComplete) != 'function')
                            document.getElementById('onWorkitemComplete_test_button').style.display = 'none';
                        if (typeof(window.onWorkitemExit) != 'function')
                            document.getElementById('onWorkitemExit_test_button').style.display = 'none';
                        if (typeof(window.onWorkitemForward) != 'function')
                            document.getElementById('onWorkitemForward_test_button').style.display = 'none';
                        if (typeof(window.onWorkitemReply) != 'function')
                            document.getElementById('onWorkitemReply_test_button').style.display = 'none';

                        });
                </script>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- This template outputs any needed styling attributes ('class' or 'style') for the body tag of the
         resulting HTML document.  This template will be overridden by each page that
         has specific body styling defined.
         The baseClass param contains the values that must be included on the class attribute-->
    <xsl:template name="output-page-body-styling">
        <xsl:param name="baseClass"/>
        <xsl:attribute name="class">
            <xsl:value-of select="$baseClass"/>
        </xsl:attribute>
    </xsl:template>

    <!-- This template outputs any needed styling attributes ('class' or 'style') for the main_body div
         in the resulting HTML document.  This template will be overridden by each page that
         has specific styling defined for this page container element.
         The baseClass param contains the values that must be included on the class attribute-->
    <xsl:template name="output-main-body-styling">
        <xsl:param name="baseClass"/>
        <xsl:attribute name="class">
            <xsl:value-of select="$baseClass"/>
        </xsl:attribute>
    </xsl:template>

    <!--
        ********** Header **********
    -->
    <xsl:template name="header">
        <xsl:for-each select="/mvc:eForm/mvc:Data/mvc:headerData/node()">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" mode="header_footer"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>

    <!--
        ********** Footer **********
    -->
    <xsl:template name="footer">
        <xsl:for-each select="/mvc:eForm/mvc:Data/mvc:footerData/node()">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" mode="header_footer"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="mvc:menu" mode="header_footer">
        <xsl:element name="div">
            <xsl:apply-templates select="mvc:event" mode="header_footer"/>
            <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
            <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
            <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
            <xsl:apply-templates select="mvc:item" mode="header_footer"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mvc:item" mode="header_footer">
        <xsl:element name="span">
            <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="@hint"/></xsl:attribute>
            <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
                <xsl:element name="a">
                    <xsl:apply-templates select="mvc:event" mode="header_footer"/>
                    <xsl:value-of select="@value"/>
                </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mvc:event" mode="header_footer">
        <xsl:attribute name="{@name}"><xsl:value-of select="@action"/></xsl:attribute>
    </xsl:template>

    <xsl:template match="@*|node()" mode="header_footer">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="header_footer"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>