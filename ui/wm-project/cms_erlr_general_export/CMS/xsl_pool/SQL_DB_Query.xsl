<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:strip-space elements="*"/>
	<xsl:output indent="yes" method="xml"/>
	<xsl:template match="/">
		<xsl:text>select * from TABLE where ROW = VALUE</xsl:text>
	</xsl:template>
</xsl:stylesheet>
