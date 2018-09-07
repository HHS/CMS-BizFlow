<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <ProcessVariables>
            <xsl:apply-templates select="//ProcessVariables/ProcessVariable[substring(Name, 1, 1) != '#']"/>
        </ProcessVariables>
    </xsl:template>
    <!-- Repurpose the BizFlow Process Variables to create name/value pair format that match the format created during design in the page structure tab -->
    <xsl:template name="processSimpleTypes" match="ProcessVariable[substring(Name, 1, 1) != '#' and (ValueType='S' or ValueType='X' or ValueType='A' or ValueType='P' or ValueType='D' or ValueType='F' or ValueType='N')]">
        <!-- Deal with simple PVs. -->
        <xsl:element name="{Name}">
            <xsl:value-of select="Value"/>
        </xsl:element>
    </xsl:template>
    <!-- Arrays need special processing to create placeholders for all elements to enable WebMaker to bind data. -->
    <xsl:template name="processArrays" match="ProcessVariable[substring(Name, 1, 1) != '#' and (ValueType='B' or ValueType='O' or ValueType='T' or ValueType='Q' or ValueType='G' or ValueType='Y' or ValueType='E')]">
        <!-- Start processing each dimension of the PV. -->
        <xsl:element name="{Name}">
            <xsl:call-template name="genArrayStructure">
                <!-- Count the number of dimensions in the dimension string -->
                <xsl:with-param name="currentDimNum" select="1"/>
                <!-- Pass thorugh the dim string inside the opening and closing brackets -->
                <xsl:with-param name="remainingDimStr" select="substring-after(substring-before(Value, ')'), '(')"/>
                <!-- Count each element in the current dimension -->
                <xsl:with-param name="currentDimCount" select="1"/>
                <!-- Incrementally collate the suffix for each array element -->
                <xsl:with-param name="suffix" select="''"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    <xsl:template name="genArrayStructure">
        <xsl:param name="currentDimNum"/>
        <xsl:param name="remainingDimStr"/>
        <xsl:param name="currentDimCount"/>
        <xsl:param name="suffix"/>
        <!-- Use currentDimMax to ensure all elements within each dimension are handled -->
        <xsl:variable name="currentDimMax">
            <xsl:choose>
                <xsl:when test="string-length(substring-before($remainingDimStr, ',')) &gt; 0">
                    <!-- Find the next dim definition before the ','  - start processing left-to-right -->
                    <xsl:value-of select="substring-before($remainingDimStr, ',')"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Handle the situation where the only remaining dim is the last number -->
                    <xsl:value-of select="$remainingDimStr"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$currentDimCount &lt; $currentDimMax">
                <xsl:element name="{concat('dim', $currentDimNum)}">
                    <!-- Create new element for each suffix change. -->
                    <xsl:call-template name="genArrayStructure">
                        <xsl:with-param name="currentDimNum" select="$currentDimNum+1"/>
                        <xsl:with-param name="remainingDimStr" select="substring-after($remainingDimStr, ',')"/>
                        <xsl:with-param name="currentDimCount" select="1"/>
                        <xsl:with-param name="suffix" select="concat($suffix, '.', $currentDimCount)"/>
                    </xsl:call-template>
                </xsl:element>
                <!-- No suffix change, therefore no element definition. -->
                <xsl:call-template name="genArrayStructure">
                    <xsl:with-param name="currentDimNum" select="$currentDimNum"/>
                    <xsl:with-param name="remainingDimStr" select="$remainingDimStr"/>
                    <xsl:with-param name="currentDimCount" select="$currentDimCount+1"/>
                    <xsl:with-param name="suffix" select="$suffix"/>
                </xsl:call-template>
            </xsl:when>
            <!-- Dimension has changed. Create new element. -->
            <xsl:when test="$currentDimCount &gt;= $currentDimMax">
                <xsl:element name="{concat('dim', $currentDimNum)}">
                    <xsl:call-template name="genArrayStructure">
                        <xsl:with-param name="currentDimNum" select="$currentDimNum+1"/>
                        <xsl:with-param name="remainingDimStr" select="substring-after($remainingDimStr, ',')"/>
                        <xsl:with-param name="currentDimCount" select="1"/>
                        <xsl:with-param name="suffix" select="concat($suffix, '.', $currentDimCount)"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:when>
            <!-- Dimension string processing has completed, i.e. full suffix length. Copy across any existing BizFlow data to the final dimension elements. -->
            <xsl:when test="string-length($remainingDimStr) = 0">
                <xsl:variable name="arrayData" select="//ProcessVariables/ProcessVariable[Name = concat('#',current()/Name, $suffix)]"/>
                <xsl:choose>
                    <xsl:when test="$arrayData">
                        <xsl:value-of select="$arrayData/Value"/>
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
