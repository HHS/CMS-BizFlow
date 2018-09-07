<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet extension-element-prefixes="date" version="1.0" xmlns:date="http://exslt.org/dates-and-times" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<mvc:CurrentDate>
			<xsl:value-of select="date:date-time()" />
		</mvc:CurrentDate>
	</xsl:template>
</xsl:stylesheet>
