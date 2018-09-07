<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <WorkitemContext xmlns="">
            <!-- Work through the cached Workitem Context (WIC) because this resembles the BizFlow format -->
            <xsl:apply-templates select="/mvc:eForm/mvc:Data/cached_wic/WorkitemContext">
                <!-- Reference the incoming WIC (user completed) and extract elements that have values -->
                <xsl:with-param name="incomingWIC" select="/mvc:eForm/mvc:Data/WorkitemContext"/>
            </xsl:apply-templates>
        </WorkitemContext>
    </xsl:template>
    <!-- Copy across all elements in preparation for save. Ensure transformation of Process Variables to match BizFlow format -->
    <xsl:template match="*">
        <xsl:param name="incomingWIC"/>
        <xsl:for-each select="*">
            <xsl:copy>
                <xsl:variable name="cachedCurrentNode" select="."/>
                <!-- Interested in fields that have the same name at the same level between the cached WIC and incoming WIC -->
                <xsl:variable name="incomingMatchedNode" select="$incomingWIC/*[local-name(.)=local-name($cachedCurrentNode) and (count(preceding-sibling::*[local-name(.) = local-name($cachedCurrentNode)]) = count($cachedCurrentNode/preceding-sibling::*[local-name(.) = local-name($cachedCurrentNode)]))]"/>
                <xsl:choose>
                    <!-- Only interested in incoming elements that have values -->
                    <xsl:when test="normalize-space($incomingMatchedNode/text()) != ''">
                        <xsl:value-of select="$incomingMatchedNode/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Otherwise assume these elements have not changed and use the cached version instead -->
                        <xsl:value-of select="$cachedCurrentNode/text()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- Process child elements of this elements -->
                <xsl:apply-templates select=".">
                    <xsl:with-param name="incomingWIC" select="$incomingMatchedNode"/>
                </xsl:apply-templates>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="ProcessVariables">
        <xsl:param name="incomingWIC"/>
        <xsl:apply-templates select="*">
            <xsl:with-param name="incomingWIC" select="$incomingWIC"/>
        </xsl:apply-templates>
    </xsl:template>
    <!-- Need to specifically handle process variables because these are formatted differently between BizFlow and WebMaker to enable easier development within FormMaker -->
    <xsl:template name="processSimpleTypes" match="ProcessVariable[substring(Name, 1, 1) != '#']">
        <xsl:param name="incomingWIC"/>
        <!-- Copy the containing ProcessVariable tag from the cached version of the WIC because these are lost when the WebMaker version is created -->
        <xsl:copy>
            <!-- Work through the elements within each ProcessVariable -->
            <xsl:for-each select="*">
                <xsl:variable name="cachedCurrentNode" select="."/>
                <xsl:copy>
                    <!-- Copy across each of the ProcessVariable 'properties', including Name and Value -->
                    <xsl:choose>
                        <xsl:when test="local-name(.) = 'Value'">
                            <!-- Interested in the Value element because this is the key field containing data.
                                    The Name element value within the cached WIC will match the element name within the incoming WIC,
                                    i.e. <Name>MyPV</Name> should match <MyPV>NewValue</MyPV>. NewValue is then assigned to the Value element within the cached WIC -->
                            <xsl:variable name="incomingMatchedNode" select="$incomingWIC/*[local-name(.) = $cachedCurrentNode/../Name]"/>
                            <xsl:choose>
                                <xsl:when test="(normalize-space($incomingMatchedNode/text()) != '') or $incomingMatchedNode/@xg:bound[. = 'true']" xmlns:xg="http://www.hyfinity.com/xgate">                                    
                                    <xsl:value-of select="$incomingMatchedNode/text()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="unchanged_on_screen"></xsl:attribute>
                                    <xsl:value-of select="$cachedCurrentNode/text()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$cachedCurrentNode/text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <!-- Need to deal with BizFlow arrays. -->
    <xsl:template name="processStructuredTypes" match="ProcessVariable[substring(Name, 1, 1) = '#']">
        <xsl:param name="incomingWIC"/>
        <!-- Copy the containing ProcessVariable tag from the cached version of the WIC because these are lost when the WebMaker version is created -->
        <xsl:copy>
            <!-- Work through the elements within each ProcessVariable -->
            <xsl:for-each select="*">
                <xsl:variable name="cachedCurrentNode" select="."/>
                <xsl:copy>
                    <!-- Copy across each of the ProcessVariable 'properties', including Name and Value -->
                    <xsl:choose>
                        <xsl:when test="local-name(.) = 'Value'">
                            <!-- Interested in the Value element because this is the key field containing data.
                                    The Name element value within the cached WIC will match the element name within the incoming WIC, but need to cater for leading #.
                                    i.e. <Name>#MyPV</Name> should match <MyPV><dim1><dim2>NewValue</dim2></dim1></MyPV>. NewValue is then assigned to the Value element within the cached WIC -->
                            <xsl:variable name="matchedNodeName" select="substring-after(substring-before($cachedCurrentNode/../Name, '.'),'#')"/>
                            <xsl:variable name="incomingMatchedNode" select="$incomingWIC/*[local-name(.) = $matchedNodeName]"/>
                            <!-- Extract the suffix from the BizFlow array name format. Allow for 3 characters (Start counting after allowing for '#' at the begining and the first '.' after the main array name before the suffix starts -->
                            <xsl:variable name="suffix" select="substring($cachedCurrentNode/../Name, string-length(local-name($incomingMatchedNode))+3)"/>
                            <!-- Start by looking at the first dimension in the array definition -->
                            <xsl:variable name="firstDimPos">
                                <xsl:choose>
                                    <xsl:when test="contains($suffix, '.')">
                                        <xsl:value-of select="substring-before($suffix, '.')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$suffix"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <!-- Call separate template to copy across the incoming value from the page -->
                            <xsl:call-template name="findChangedIncomingValue">
                                <xsl:with-param name="suffix" select="substring-after($suffix, '.')"/>
                                <!-- Match the first dim in the incoming data using the first part of the suffix. -->
                                <xsl:with-param name="currentIncomingDim" select="$incomingMatchedNode/*[position() = $firstDimPos]"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$cachedCurrentNode/text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <!-- This template works by isolating a dim at a time from the incoming data, based on the dimension numbers at the end of the particular array definition. -->
    <xsl:template name="findChangedIncomingValue">
        <!-- suffix represents the remaining array dimension information contained at the end of the array element name -->
        <xsl:param name="suffix"/>
        <!-- currentIncomingDim	represents the dim isolated so far the contains the data of interest -->
        <xsl:param name="currentIncomingDim"/>
        <xsl:choose>
            <xsl:when test="$suffix = ''" >
                <xsl:choose>
                    <!-- Only interested if the data had been modified -->
                    <xsl:when test="(normalize-space($currentIncomingDim/text()) != '') or $currentIncomingDim/@xg:bound[. = 'true']" xmlns:xg="http://www.hyfinity.com/xgate">
                        <xsl:value-of select="$currentIncomingDim/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="unchanged_on_screen"></xsl:attribute>
                        <!-- No data was input on the screen, so use the original BizFlow supplied value -->
                        <xsl:value-of select="./text()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- Move on to the next dimension -->
                <xsl:variable name="nextDimPos">
                    <xsl:choose>
                        <xsl:when test="contains($suffix, '.')">
                            <xsl:value-of select="substring-before($suffix, '.')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$suffix"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="findChangedIncomingValue">
                    <xsl:with-param name="suffix" select="substring-after($suffix, '.')"/>
                    <xsl:with-param name="currentIncomingDim" select="$currentIncomingDim/*[position() = $nextDimPos]"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
