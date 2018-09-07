<!--
/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project. 
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product. 
* For guidance on ‘How do I override or clone Hyfinity webapp files such as CSS & javascript?’, please read the following relevant FAQ entry: 
* http://www.hyfinity.net/faq/index.php?solution_id=1113
==================================================================================================== */
/*-->
<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="UTF-8" indent="yes" method="xml" version="1.0"></xsl:output>
	<xsl:template match="/">
		<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
			<xsl:element name="soap:Body">
				<xsl:copy-of select="/"></xsl:copy-of>
			</xsl:element>
		</soap:Envelope>
	</xsl:template>
</xsl:stylesheet>