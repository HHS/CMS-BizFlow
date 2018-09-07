<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- Array definitions in BizFlow to create array elements (final dim) if deault data is not present. This stylesheet creates dim structures for all array elements.  -->
    <xsl:template match="/">
        <xsl:apply-templates select="/*" mode="copyWorkitemDetails"/>
    </xsl:template>

    <xsl:template match="ProcessVariables" mode="copyWorkitemDetails">
        <xsl:copy>
            <!-- Deal with 'normal' PV definitions, i.e. strings, top-level array definitions, etc. (array element name begin with # and end with some suffix numbers) -->
            <xsl:apply-templates select="ProcessVariable[substring(Name, 1, 1) != '#']"/>
        </xsl:copy>
    </xsl:template>

    <!-- Simply copy cross all simple type definitions. -->
    <xsl:template name="processSimpleTypes" match="ProcessVariable[substring(Name, 1, 1) != '#' and (ValueType='S' or ValueType='D' or ValueType='N' or ValueType='P' or ValueType='X' or ValueType='F' or ValueType='A')]">
        <xsl:apply-templates select="." mode="copyWorkitemDetails"/>
    </xsl:template>
    <!-- Process arrays. -->
    <xsl:template name="processArrays" match="ProcessVariable[substring(Name, 1, 1) != '#' and (ValueType='T' or ValueType='E' or ValueType='O' or ValueType='Q' or ValueType='Y' or ValueType='G' or ValueType='B')]">
            <!-- Copy across the main array definition header -->
            <xsl:copy-of select="."/>
            <!-- Deal with the rest of the # elements -->
            <xsl:call-template name="genArrayStructure">
            <xsl:with-param name="currentDimNum" select="1"/>
            <!-- Pass thorugh the dim number inside the opening and closing brackets -->
            <xsl:with-param name="remainingDimStr" select="substring-after(substring-before(Value, ')'), '(')"/>
            <xsl:with-param name="currentDimCount" select="1"/>
            <xsl:with-param name="suffix" select="''"/>
        </xsl:call-template>
    </xsl:template>
    <!-- Template to generate the BizFlow array in structure format -->
    <xsl:template name="genArrayStructure">
        <!-- currentDimNum is the number of the actual dimension of the array, e.g. 1,2,3,4,..,n -->
        <xsl:param name="currentDimNum"/>
        <!-- remainingDimStr is used to process the array dimension definition (e.g. (3,4,11)) from LtoR -->
        <xsl:param name="remainingDimStr"/>
        <!-- currentDimCount is used to count the number of elements in a single dimension, e.g. 0,..,n for dimension 1.-->
        <xsl:param name="currentDimCount"/>
        <!-- suffix is used to generate the #arrayName.n.m... format for BizFlow. The suffix represents the number at the end of the name -->
        <xsl:param name="suffix"/>
        <!-- Use currentDimMax to determine if all the elements in the current dimension have been counted. -->
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
            <!-- This condition processes elements in the current dimension -->
            <xsl:when test="$currentDimCount &lt; $currentDimMax">
                <!-- Recursive call the generate the suffix by processing the dimension definition LtoR starting from the current position within the dimension string -->
                <xsl:call-template name="genArrayStructure">
                    <xsl:with-param name="currentDimNum" select="$currentDimNum+1"/>
                    <xsl:with-param name="remainingDimStr" select="substring-after($remainingDimStr, ',')"/>
                    <xsl:with-param name="currentDimCount" select="1"/>
                    <xsl:with-param name="suffix" select="concat($suffix, '.', $currentDimCount)"/>
                </xsl:call-template>
                <!-- Recursive call to count all elements in the current dimension -->
                <xsl:call-template name="genArrayStructure">
                    <xsl:with-param name="currentDimNum" select="$currentDimNum"/>
                    <xsl:with-param name="remainingDimStr" select="$remainingDimStr"/>
                    <xsl:with-param name="currentDimCount" select="$currentDimCount+1"/>
                    <xsl:with-param name="suffix" select="$suffix"/>
                </xsl:call-template>
            </xsl:when>
            <!-- This condition handles the situation when a particular dimension has been fully counted and the proccessing needs to move to the next dimension -->
            <xsl:when test="$currentDimCount &gt;= $currentDimMax">
                <xsl:call-template name="genArrayStructure">
                    <xsl:with-param name="currentDimNum" select="$currentDimNum+1"/>
                    <xsl:with-param name="remainingDimStr" select="substring-after($remainingDimStr, ',')"/>
                    <xsl:with-param name="currentDimCount" select="1"/>
                    <xsl:with-param name="suffix" select="concat($suffix, '.', $currentDimCount)"/>
                </xsl:call-template>
            </xsl:when>
            <!-- This condition handles the situation when the final dimension has been reached, implying that the suffix length should now be complete -->
            <xsl:when test="string-length($remainingDimStr) = 0">
                <xsl:variable name="arrayData" select="//ProcessVariables/ProcessVariable[Name = concat('#', current()/Name, $suffix)]"/>
                <xsl:choose>
                    <!-- Simply output the array definition if it has already been defined by BizFlow. -->
                    <xsl:when test="$arrayData">
                        <xsl:apply-templates select="$arrayData" mode="copyWorkitemDetails"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <ProcessVariable>
                            <Name>
                                <xsl:value-of select="concat('#',Name, $suffix)"/>
                            </Name>
                            <ValueType>
                                <!-- Determine the type of the array elements. -->
                                <xsl:call-template name="FindPVTypeForArrayElement">
                                    <xsl:with-param name="valueType" select="ValueType"/>
                                </xsl:call-template>
                            </ValueType>
                            <Value>
                                <!--<xsl:value-of select="Value"/>-->
                            </Value>
                            <DisplayValue>
                                <!--<xsl:value-of select="DisplayValue"/>-->
                            </DisplayValue>
                            <Description>
                                <xsl:value-of select="Description"/>
                            </Description>
                            <Scope>
                                <xsl:value-of select="Scope"/>
                            </Scope>
                            <IsPublic>
                                <xsl:value-of select="IsPublic"/>
                            </IsPublic>
                        </ProcessVariable>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="FindPVTypeForArrayElement">
        <xsl:param name="valueType"/>
        <!-- valueType[.='S'] = String -->
        <!-- valueType[.='D'] = Date -->
        <!-- valueType[.='N'] = Numeric -->
        <!-- valueType[.='P'] = Participant -->
        <!-- valueType[.='X'] = Complex (XSD) -->
        <!-- valueType[.='F'] = File -->
        <!-- valueType[.='A'] = Application -->

        <!-- valueType[.='T'] = String Array -->
        <!-- valueType[.='E'] = Date Array -->
        <!-- valueType[.='O'] = Numeric Array -->
        <!-- valueType[.='Q'] = Participant Array -->
        <!-- valueType[.='Y'] = Complex Array -->
        <!-- valueType[.='G'] = File Array -->
        <!-- valueType[.='B'] = Application Array -->
        <xsl:choose>
            <xsl:when test="$valueType[.='Y']">
                <xsl:text>X</xsl:text>
            </xsl:when>
            <xsl:when test="$valueType[.='G']">
                <xsl:text>F</xsl:text>
            </xsl:when>
            <xsl:when test="$valueType[.='Q']">
                <xsl:text>P</xsl:text>
            </xsl:when>
            <xsl:when test="$valueType[.='T']">
                <xsl:text>S</xsl:text>
            </xsl:when>
            <xsl:when test="$valueType[.='E']">
                <xsl:text>D</xsl:text>
            </xsl:when>
            <xsl:when test="$valueType[.='O']">
                <xsl:text>N</xsl:text>
            </xsl:when>
            <xsl:when test="$valueType[.='B']">
                <xsl:text>A</xsl:text>
            </xsl:when>
            <xsl:otherwise>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="ProcessVariable[ValueType = 'D']/Value" mode="copyWorkitemDetails">
        <xsl:copy>
            <xsl:value-of select="translate(., '/ ', '-T')"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="CreationDateTime | CompleteDateTime | StartDateTime" mode="copyWorkitemDetails">
        <xsl:copy>
            <xsl:value-of select="translate(., '/ ', '-T')"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node() | @*" mode="copyWorkitemDetails">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="copyWorkitemDetails"/>
            <xsl:apply-templates mode="copyWorkitemDetails"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
