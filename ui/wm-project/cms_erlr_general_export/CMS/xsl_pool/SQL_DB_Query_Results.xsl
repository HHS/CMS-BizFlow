<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output indent="yes" method="xml"/>
	<xsl:template match="/">
		<xsl:element name="table">
			<xsl:for-each select="/table/record">
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
