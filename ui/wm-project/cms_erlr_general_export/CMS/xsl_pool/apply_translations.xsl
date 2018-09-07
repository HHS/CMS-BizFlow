<?xml version="1.0"?>
<!--
/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on ‘How do I override or clone Hyfinity webapp files such as CSS & javascript?’, please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index.php?solution_id=1113
==================================================================================================== */
/*-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:trans="http://www.hyfinity.com/translate" exclude-result-prefixes="mvc trans java-file exsl java-baseuri" xmlns:java-file="xalan://java.io.File" xmlns:java-baseuri="xalan://com.hyfinity.xgate.SetLocalePlugin" xmlns:exsl="http://exslt.org/common" >
    <xsl:import href="conversions.xsl" />

    <xsl:output method="html" indent="yes"/>

    <xsl:variable name="htmlContent" select="/mvc:eForm/*[local-name() != 'Control'][1]"/>
    <xsl:variable name="pageName" select="substring-before(/mvc:eForm/mvc:Control/mvc:Page, '.xsl')"/>

    <xsl:variable name="dictionaryName">
        <xsl:call-template name="find-valid-dictionary">
            <xsl:with-param name="name" select="/mvc:eForm/mvc:Control/mvc:Language"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="baseDir" select="java-baseuri:getBaseURI(document(''))"/>

    <xsl:template name="find-valid-dictionary">
        <xsl:param name="name" />

        <xsl:variable name="testFilename" select="concat($baseDir, '/dictionary_', $name, '.xml')"/>

        <xsl:choose>
            <xsl:when test="$name = ''">
                <xsl:text>NONE</xsl:text>
            </xsl:when>
            <xsl:when test="java-file:exists(java-file:new($testFilename))">
                <xsl:value-of select="$testFilename" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="find-valid-dictionary">
                    <xsl:with-param name="name">
                        <xsl:call-template name="substring-before-last">
                            <xsl:with-param name="string" select="$name"/>
                            <xsl:with-param name="seperator" select="'-'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:variable name="tempTransFile">
        <xsl:if test="$dictionaryName != 'NONE'">
            <xsl:copy-of select="document($dictionaryName)"/>
        </xsl:if>
    </xsl:variable>

    <xsl:variable name="translationFile" select="exsl:node-set($tempTransFile)"/>

    <xsl:variable name="translationItems" select="$translationFile/trans:translations/*[local-name() = 'global' or @id = $pageName]" />


    <xsl:template match="/">
        <!-- Check if we actually have any translations to do.
             If not then there is no point checking each field. -->
        <xsl:choose>
            <xsl:when test="($dictionaryName = 'NONE') or (count($translationItems/trans:translation_item) = 0)">
                <!--<xsl:copy-of select="$htmlContent" />-->
                <xsl:apply-templates select="$htmlContent" mode="no_translations"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$htmlContent"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- generic copy templates to handle the case where no translations exist.
         Unfortunately we cant just use xsl:copy-of as this copies across unwanted namespaces.-->
    <xsl:template match="*" mode="no_translations">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="no_translations"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="text() | comment() | processing-instruction()" mode="no_translations">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="xform:instance" xmlns:xform="http://www.w3.org/2001/08/xforms" mode="no_translations">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="xform:xform" xmlns:xform="http://www.w3.org/2001/08/xforms" mode="no_translations">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="no_translations"/>
        </xsl:copy>
    </xsl:template>



    <!-- Match the top HTML tag to make sure the lang attributes are correctly updated -->
    <xsl:template match="html">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
            </xsl:apply-templates>

            <xsl:if test="$translationFile/trans:translations/@language_code[. != '']" >

                <xsl:attribute name="lang">
                    <xsl:value-of select="$translationFile/trans:translations/@language_code"/>
                </xsl:attribute>
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="$translationFile/trans:translations/@language_code"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates select="node()">
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <!-- Match the head container to see if we need to output a direction style.
         If the translation file specifies a direction, then we output a new style block with a single rule
         to apply this direction to all the applicable components. -->
    <xsl:template match="head">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
            </xsl:apply-templates>
            <xsl:apply-templates select="node()">
            </xsl:apply-templates>

            <xsl:if test="$translationFile/trans:translations/@direction[. != '']" >
                <style type="text/css">
                    <xsl:text>
* {
    direction : </xsl:text>
                    <xsl:value-of select="$translationFile/trans:translations/@direction" />
                    <xsl:text>;
}
</xsl:text>
                </style>
            </xsl:if>

        </xsl:element>
    </xsl:template>


    <!-- Pick up the body to add a class indicating the direction option chosen in the dictionary file in use
         This can be used by themes to adjust the position of components (eg placeholder icons) for rtl languges for example.-->
    <xsl:template match="body">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">

            <xsl:apply-templates select="@*"/>

            <xsl:if test="$translationFile/trans:translations/@direction[. != '']" >
                <xsl:attribute name="class">
                    <xsl:if test="@class != ''">
                        <xsl:value-of select="@class"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:text>direction_</xsl:text>
                    <xsl:value-of select="$translationFile/trans:translations/@direction"/>
                </xsl:attribute>
                <xsl:attribute name="dir">
                    <xsl:value-of select="$translationFile/trans:translations/@direction"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates/>

        </xsl:element>
    </xsl:template>



    <!-- Match any container signifying the start of a repeat so that we can get the repeat ID
        NOTE: This is depenedant on the repeat class being applied to the container.  Although this is the default,
        this can be changed by the user in the studio, so may need to consider alternatives. -->
    <xsl:template match="*[contains(concat(' ', @class, ' '), ' repeat ')]">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <xsl:variable name="newRepeatName">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="@id"/>
            </xsl:call-template>
        </xsl:variable>


        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="@id"/>
                <xsl:with-param name="currentRepeatName" select="$newRepeatName"/>
            </xsl:apply-templates>

            <xsl:for-each select="node()" >
                <!-- Special handling for the new row content of the editable table control to make sure that
                      fields in this row get correctly translated. -->
                <xsl:choose>
                    <xsl:when test="@id = concat(../@id, '_newRowContent')" >
                        <xsl:apply-templates select=".">
                            <xsl:with-param name="currentRepeatID" select="concat(../@id, 'BlankEntry')"/>
                            <xsl:with-param name="currentRepeatName" select="$newRepeatName"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select=".">
                            <xsl:with-param name="currentRepeatID" select="../@id"/>
                            <xsl:with-param name="currentRepeatName" select="$newRepeatName"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <!-- Match each TD displayed in the situations where a repeating table has no content
         This relies on the 'noRepeatData' class name which is currently defined in the HTMLGeneration.xsl process.-->
    <xsl:template match="td[@class = 'noRepeatData']">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <!-- find the id of the repeat that this entry is for -->
        <xsl:variable name="elementName" select="$currentRepeatName" />

        <!-- Check if there is a translation for this empty repeat -->
        <xsl:choose>
            <xsl:when test="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'repeat_no_data']" >
                <xsl:element name="{name()}" namespace="{namespace-uri()}">
                    <xsl:apply-templates select="@*">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>

                    <!-- check for dynamic values -->
                    <xsl:choose>
                        <xsl:when test="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'repeat_no_data' and not(@dynamic_value)]">
                            <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'repeat_no_data']/@value" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="currentValue" select="normalize-space(.)"/>
                            <xsl:choose>
                                <xsl:when test="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'repeat_no_data' and @dynamic_value = $currentValue]" >
                                    <!-- output the matched translation -->
                                    <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'repeat_no_data' and @dynamic_value = $currentValue]/@value"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- no match, so just output the value from the data -->
                                    <xsl:value-of select="$currentValue"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{name()}" namespace="{namespace-uri()}">
                    <xsl:apply-templates select="@*">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="node()">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- Find any labels to see if they need translating -->
    <xsl:template match="*[substring(@id, string-length(@id) - 5) = '_label']">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <xsl:variable name="elementName">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="substring(@id, 1, string-length(@id) - 6)"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- check if we have a translation for this elements label -->
        <xsl:choose>
            <xsl:when test="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'label']" >
                <xsl:element name="{name()}" namespace="{namespace-uri()}">
                    <xsl:apply-templates select="@*">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>

                    <xsl:for-each select="node()">
                        <xsl:choose>
                            <xsl:when test="self::text()" >
                                <!-- check for dynamic values -->
                                <xsl:choose>
                                    <xsl:when test="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'label' and not(@dynamic_value)]">
                                        <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'label']/@value" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:variable name="currentValue" select="normalize-space(.)"/>
                                        <xsl:choose>
                                            <xsl:when test="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'label' and @dynamic_value = $currentValue]" >
                                                <!-- output the matched translation -->
                                                <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'label' and @dynamic_value = $currentValue]/@value"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <!-- no match, so just output the value form the data -->
                                                <xsl:value-of select="$currentValue"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select=".">
                                    <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                                    <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{name()}" namespace="{namespace-uri()}">
                    <xsl:apply-templates select="@*">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="node()">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- Match all the possible HTML tags that could be used for types of button to check for caption changes
        Also check spans as this should handle changing static output fields -->
    <xsl:template match="a[@id]/span/span | input[@type = 'button'] | span[@id and not(substring(@id, string-length(@id) - 5) = '_label')]">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>


        <!-- check if this is actually a tab button, in which case it needs to be handled separately -->
        <xsl:choose>
            <xsl:when test="../parent::a[contains(@id, '_tab_') and contains(@onclick, 'TabChange')]">
                <xsl:call-template name="translate-tab-text">
                    <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                    <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    <xsl:with-param name="container" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>

                <!-- Need to allow for the repeat info possiblly being at the start of each ID -->
                <xsl:variable name="elementName">
                    <xsl:call-template name="find-component-id">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                        <xsl:with-param name="fieldID">
                            <xsl:choose>
                                <xsl:when test="../parent::a/@id">
                                    <xsl:value-of select="../parent::a/@id" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@id" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>

                <!-- check if we have a translation for this elements caption -->
                <xsl:choose>
                    <xsl:when test="$translationItems/trans:translation_item[@id = $elementName]/trans:part" >

                        <xsl:element name="{name()}" namespace="{namespace-uri()}">
                            <xsl:apply-templates select="@*">
                                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                            </xsl:apply-templates>

                            <xsl:variable name="currentValue">
                                <xsl:choose>
                                    <xsl:when test="local-name() = 'input'">
                                        <xsl:value-of select="@value"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>

                            <xsl:variable name="newValue">
                                <!-- check if a dynamic value has been specifed, or whether we should always use this value -->
                                <xsl:choose>
                                    <xsl:when test="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'caption' and not(@dynamic_value)]">
                                        <!-- no dynamic value so always output the specified value -->
                                        <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'caption']/@value" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- check if we have a dynamic value match -->
                                        <xsl:choose>
                                            <xsl:when test="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'caption' and @dynamic_value = $currentValue]" >
                                                <!-- output the matched translation -->
                                                <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'caption' and @dynamic_value = $currentValue]/@value" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <!-- no translation value to use, but check for date conversion needs -->
                                                <xsl:call-template name="check-date-conversion">
                                                    <xsl:with-param name="fieldID" select="$elementName"/>
                                                    <xsl:with-param name="currentValue" select="$currentValue"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>


                            <!-- Now output the new value if we have one -->
                            <xsl:choose>
                                <xsl:when test="$newValue != ''">
                                    <xsl:choose>
                                        <xsl:when test="local-name() = 'input'">
                                            <xsl:attribute name="value">
                                                <xsl:value-of select="$newValue" />
                                            </xsl:attribute>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$newValue" />
                                        </xsl:otherwise>
                                    </xsl:choose>

                                    <xsl:apply-templates select="*">
                                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="node()">
                                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                                    </xsl:apply-templates>
                                </xsl:otherwise>
                            </xsl:choose>


                        </xsl:element>

                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="{name()}" namespace="{namespace-uri()}">
                            <xsl:apply-templates select="@*">
                                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                            </xsl:apply-templates>
                            <xsl:apply-templates select="node()">
                                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                            </xsl:apply-templates>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- Check if we have a translation for the tab specified in the container.
          This container should actually be the lowest span in the a tag, so we can work up to find the container a
          which has all the id details etc. -->
    <xsl:template name="translate-tab-text">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>
        <xsl:param name="container"/>

        <xsl:variable name="tabId">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="$container/ancestor::a[1]/@id"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="controlName" select="substring-before($tabId, '_tab_')"/>

        <xsl:choose>
            <!-- Check if we have translations for this control -->
            <xsl:when test="$translationItems/trans:translation_item[@id = $controlName]/trans:part[@type = 'select_option']">
                <xsl:variable name="dataValue" select="substring-after($tabId, '_tab_')"/>

                <xsl:element name="{name($container)}" namespace="{namespace-uri($container)}">
                    <xsl:apply-templates select="$container/@*">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>

                    <xsl:choose>
                        <xsl:when test="$translationItems/trans:translation_item[@id = $controlName]/trans:part[(@type = 'select_option') and (@data_value = $dataValue)]" >
                            <xsl:value-of select="$translationItems/trans:translation_item[@id = $controlName]/trans:part[(@type = 'select_option') and (@data_value = $dataValue)]/@value" />
                        </xsl:when>
                        <xsl:when test="$translationItems/trans:translation_item[@id = $controlName]/trans:part[(@type = 'select_option') and (@dynamic_value = $container)]" >
                            <xsl:value-of select="$translationItems/trans:translation_item[@id = $controlName]/trans:part[(@type = 'select_option') and (@dynamic_value = $container)]/@value" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$container" />
                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:element>

            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{name($container)}" namespace="{namespace-uri($container)}">
                    <xsl:apply-templates select="$container/@*">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="$container/node()">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- Check text boxes to see if they have any date conversions specified -->
    <xsl:template match="input[@type = 'text']">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>

            <xsl:variable name="convertedValue">
                <xsl:call-template name="check-date-conversion">
                    <xsl:with-param name="fieldID">
                        <xsl:call-template name="find-component-id">
                            <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                            <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                            <xsl:with-param name="fieldID" select="@id"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="currentValue" select="@value"/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:if test="$convertedValue != ''">
                <xsl:attribute name="value">
                    <xsl:value-of select="$convertedValue" />
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates select="node()">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>


    <!-- This checks if the field with the given ID has a date conversion translation defined, and if so
         returns the translated value that should be used.-->
    <xsl:template name="check-date-conversion">
        <xsl:param name="fieldID" />
        <xsl:param name="currentValue" />

        <xsl:if test="$translationItems/trans:translation_item[@id = $fieldID]/trans:part[@type = 'date_format' and @dynamic_value]" >
            <xsl:if test="(normalize-space($currentValue) != '') and ($currentValue != '&amp;#160;')" >
                <xsl:call-template name="parse-format-date">
                    <xsl:with-param name="source_string" select="$currentValue" />
                    <xsl:with-param name="source_pattern" select="$translationItems/trans:translation_item[@id = $fieldID]/trans:part[@type = 'date_format']/@dynamic_value"/>
                    <xsl:with-param name="target_pattern" select="$translationItems/trans:translation_item[@id = $fieldID]/trans:part[@type = 'date_format']/@value"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>

    </xsl:template>

    <!-- Match any hidden input fields for storing the date format conversion to use on future submits.
         We check each one to see if it is for a field that has a different format defined for this
         language, and if so update the field value accordingly. -->
    <xsl:template match="input[(@type = 'hidden') and (substring(@name, string-length(@name) - 21) = '_date_conversion_input')]">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <xsl:variable name="elementName">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="substring-before(@name, '_date_conversion_input')"/>
            </xsl:call-template>
        </xsl:variable>


        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>


            <xsl:if test="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'date_format' and @dynamic_value]">
                <xsl:attribute name="value">
                    <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'date_format']/@value" />
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates select="node()">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>



    <!-- Match any hint containers to see if we have a translation for the hint -->
    <xsl:template match="span[substring(@id, string-length(@id) - 14) = '_hint_container']">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <xsl:variable name="elementName">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="substring-before(@id, '_hint_container')"/>
            </xsl:call-template>
        </xsl:variable>


        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>


            <xsl:choose>
                <xsl:when test="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'hint']">
                    <!-- Check if this is using the tooltip or text hint display method -->
                    <xsl:choose>
                        <xsl:when test="span[@class='tooltipContent']">
                            <span>
                                <xsl:apply-templates select="span[@class='tooltipContent']/@*">
                                    <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                                    <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                                </xsl:apply-templates>

                                <!-- Check if we have a translated string value or an HTML fragment -->
                                <xsl:choose>
                                    <xsl:when test="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'hint']/@value">
                                        <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'hint']/@value"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'hint']/node()" mode="no_translations">
                                            <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                                            <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                                        </xsl:apply-templates>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Check if we have a translated string value or an HTML fragment -->
                            <xsl:choose>
                                <xsl:when test="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'hint']/@value">
                                    <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'hint']/@value"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'hint']/node()" mode="no_translations">
                                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                                    </xsl:apply-templates>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:element>
    </xsl:template>


    <!-- Match any placeholder attributes to see if we have a translation -->
    <xsl:template match="@placeholder">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <xsl:variable name="elementName">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="../@id"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:attribute name="placeholder">
            <xsl:choose>
                <xsl:when test="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'placeholder']">
                    <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'placeholder']/@value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>

    </xsl:template>


    <!-- Match the very last script tag so that we can ouput our own scripts if needed, and be sure that they
         will override any of the initial scripts.
         This is needed to set the _display_date_format attribute for elements whose date format has been translated,
         and also to translate any custom attributes where translations have been provided. -->
    <xsl:template match="script[not(following::script)]">
        <xsl:copy-of select="."/>

        <script type="text/javascript">

            <xsl:for-each select="$translationItems/trans:translation_item[trans:part[@type = 'date_format'] or trans:part[@type = 'custom_attribute']]">
                <xsl:call-template name="output-translation-item-script">
                    <xsl:with-param name="translationItem" select="."/>
                </xsl:call-template>

            </xsl:for-each>
        </script>

    </xsl:template>

    <xsl:template name="output-translation-item-script">
        <xsl:param name="translationItem"/>

        <xsl:choose>
            <xsl:when test="$htmlContent//*[@id = $translationItem/@id]">
                <!-- Field is not under a repeat, so just ouput the single script line -->
                <xsl:call-template name="output-translation-item-script-for-field" >
                    <xsl:with-param name="fieldId" select="$translationItem/@id"/>
                    <xsl:with-param name="translationItem" select="$translationItem"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="check-repeat-for-translation-item-script">
                    <xsl:with-param name="translationItem" select="$translationItem"/>
                    <xsl:with-param name="context" select="$htmlContent"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="check-repeat-for-translation-item-script">
        <xsl:param name="translationItem"/>
        <xsl:param name="context"/>

        <xsl:for-each select="$context//*[contains(concat(' ', @class, ' '), ' repeat ') and not(ancestor::*[contains(concat(' ', @class, ' '), ' repeat ') and ancestor::*[generate-id() = generate-id($context)]])]">

            <xsl:variable name="repeatEntry" select="."/>

            <xsl:choose>
                <xsl:when test="$repeatEntry//*[@id = concat($repeatEntry/@id, '1', $translationItem/@id)]" >
                    <!-- Field seems to be under this repeat, so ouput a script line
                         for each field-->
                    <xsl:call-template name="ouput-field-in-repeat-translation-item-script">
                        <xsl:with-param name="translationItem" select="$translationItem"/>
                        <xsl:with-param name="repeatEntry" select="$repeatEntry"/>
                        <xsl:with-param name="repeatCount">1</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <!-- Check for a completely blank editable row control where there is no existing data, but there is a blank row to translate -->
                <xsl:when test="$repeatEntry//*[@id = concat($repeatEntry/@id, 'BlankEntry', $translationItem/@id)]" >
                    <xsl:call-template name="output-translation-item-script-for-field" >
                        <xsl:with-param name="fieldId" select="concat($repeatEntry/@id, 'BlankEntry', $translationItem/@id)"/>
                        <xsl:with-param name="translationItem" select="$translationItem"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Field is not under this repeat, so check for any child repeats that
                         may contain it -->
                    <xsl:call-template name="check-repeat-for-translation-item-script">
                        <xsl:with-param name="translationItem" select="$translationItem"/>
                        <xsl:with-param name="context" select="$repeatEntry"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="ouput-field-in-repeat-translation-item-script">
        <xsl:param name="translationItem"/>
        <xsl:param name="repeatEntry"/>
        <xsl:param name="repeatCount"/>

        <xsl:call-template name="output-translation-item-script-for-field" >
            <xsl:with-param name="fieldId" select="concat($repeatEntry/@id, $repeatCount, $translationItem/@id)"/>
            <xsl:with-param name="translationItem" select="$translationItem"/>
        </xsl:call-template>

        <!-- Check for other entries within this repeat -->
        <xsl:choose>
            <xsl:when test="$repeatEntry//*[@id = concat($repeatEntry/@id, ($repeatCount + 1), $translationItem/@id)]" >
                <xsl:call-template name="ouput-field-in-repeat-translation-item-script">
                    <xsl:with-param name="translationItem" select="$translationItem"/>
                    <xsl:with-param name="repeatEntry" select="$repeatEntry"/>
                    <xsl:with-param name="repeatCount" select="$repeatCount + 1"/>
                </xsl:call-template>
            </xsl:when>
            <!-- When all the rows of data have been processed, check if there is an editable table blank row to translate -->
            <xsl:when test="$repeatEntry//*[@id = concat($repeatEntry/@id, 'BlankEntry', $translationItem/@id)]" >
                <xsl:call-template name="output-translation-item-script-for-field" >
                    <xsl:with-param name="fieldId" select="concat($repeatEntry/@id, 'BlankEntry', $translationItem/@id)"/>
                    <xsl:with-param name="translationItem" select="$translationItem"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="output-translation-item-script-for-field">
        <xsl:param name="fieldId"/>
        <xsl:param name="translationItem"/>

        <xsl:text>field = document.getElementById('</xsl:text>
        <xsl:value-of select="$fieldId" />
        <xsl:text>');</xsl:text>

        <xsl:if test="$translationItem/trans:part[@type = 'date_format']" >
            <xsl:text>field.setAttribute('_display_date_format','</xsl:text>
            <xsl:value-of select="$translationItem/trans:part[@type = 'date_format']/@value" />
            <xsl:text>');</xsl:text>
        </xsl:if>

        <xsl:for-each select="$translationItem/trans:part[@type = 'custom_attribute']">
            <xsl:text>field.setAttribute('</xsl:text>
            <xsl:value-of select="@data_value" />
            <xsl:text>', '</xsl:text>
            <xsl:value-of select="@value" />
            <xsl:text>');</xsl:text>
        </xsl:for-each>

    </xsl:template>



    <!-- Match title and alt attributes to look if the field tip strings need converting. -->
    <xsl:template match="@title | @alt">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <!-- Need to allow for the repeat info possiblly being at the start of each ID -->
        <xsl:variable name="elementName">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="../@id"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- check if we have a translation for this elements field tip -->
        <xsl:choose>
            <xsl:when test="$translationItems/trans:translation_item[@id = $elementName and @action = 'replace']/trans:part[@type = 'field_tip']" >
                <xsl:attribute name="{name()}">
                    <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'field_tip']/@value" />
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- match select boxes to look at changing option values -->
    <xsl:template match="select">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <!-- Need to allow for the repeat info possiblly being at the start of each ID -->
        <xsl:variable name="elementName">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="@id"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="node()">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="optionTranslations" select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'select_option']"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="select/option">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>
        <xsl:param name="optionTranslations"/>

        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>

            <!-- Check the dynamic_value against the displayed text, and the data_value against the actual data.
                 If either mataches then show the appropriate translated value. -->
            <xsl:choose>
                <xsl:when test="$optionTranslations[@dynamic_value = current()]">
                    <xsl:value-of select="$optionTranslations[@dynamic_value = current()]/@value"/>
                </xsl:when>
                <xsl:when test="$optionTranslations[@data_value = current()/@value]">
                    <xsl:value-of select="$optionTranslations[@data_value = current()/@value]/@value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>

    </xsl:template>


    <!-- In order to translate the displayed values for radio and multiple checkbox controls, we match on the
         'selectBooleanCaption' class as this cant be changed by the user.
         From here we can find the label tag, and then work back to find the actual control.
         If we ever change the gen process to allow the user to set these classes, then we will need to update this process. -->
    <xsl:template match="*[contains(concat(' ', @class, ' '), ' selectBooleanCaption ')]">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <!-- Find the label tag for the value.  Depedning on how the options are being generated, this may
             be the element with the selectBooleanCaption class applied to it, or it may be a child of this.-->
        <xsl:variable name="label" select="descendant-or-self::label"/>

        <xsl:variable name="control" select="ancestor::*[contains(@id, '_container')][1]//input[@id = $label/@for]"/>


        <xsl:variable name="elementName">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="$control/@name" />
            </xsl:call-template>
        </xsl:variable>



        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>

            <xsl:variable name="optionTranslations" select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'select_option']"/>

            <xsl:variable name="newLabelValue">
                <!-- Check the dynamic_value against the displayed text, and the data_value against the actual data.
                 If either mataches then use the appropriate translated value, otherwise just keep the current value -->
                <xsl:choose>
                    <xsl:when test="$optionTranslations[@dynamic_value = $label]">
                        <xsl:value-of select="$optionTranslations[@dynamic_value = $label]/@value"/>
                    </xsl:when>
                    <xsl:when test="$optionTranslations[@data_value = $control/@value]">
                        <xsl:value-of select="$optionTranslations[@data_value = $control/@value]/@value"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$label" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>


            <xsl:choose>
                <xsl:when test="generate-id(current()) = generate-id($label)">
                    <!-- Have outputted all the requried HTML content, so just output the new label value -->
                    <xsl:value-of select="$newLabelValue" />
                </xsl:when>
                <xsl:otherwise>
                    <!--Have only output the container HTML so far, so need to output the label HTML, and then the new value-->
                    <xsl:element name="{name($label)}" namespace="{namespace-uri($label)}">
                        <xsl:apply-templates select="$label/@*">
                            <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                            <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                        </xsl:apply-templates>
                        <xsl:value-of select="$newLabelValue" />
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:element>
    </xsl:template>


    <!-- Match the container elements placed around paragraph control content, so we can replace the content
         with that from the translations file if required.
         This requires the gen process to be creating this content, so on earlier product versions this will need to be added
         manually by editting the HTML for the paragraph in FM. -->
    <xsl:template match="div[@class = 'paragraph']|td[@class = 'paragraph']|li[@class = 'paragraph']">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <xsl:variable name="pName">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="@id" />
            </xsl:call-template>
        </xsl:variable>

        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>

            <xsl:choose>
                <xsl:when test="$translationItems/trans:translation_item[@id = $pName]/trans:part[@type = 'paragraph']" >
                    <xsl:apply-templates select="$translationItems/trans:translation_item[@id = $pName]/trans:part[@type = 'paragraph']/node()" mode="no_translations">
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates>
                        <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                        <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:element>

    </xsl:template>


    <!-- Check for any display variable fields, and see if we have any translations for it -->
    <xsl:template match="input[(@type = 'hidden') and starts-with(@id, 'hyf_display_variable_')]">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <xsl:variable name="dvName" select="substring-after(@id, 'hyf_display_variable_')"/>

        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>

            <xsl:if test="$translationItems/trans:translation_item[@id = 'display_variables']/trans:part[@type = $dvName]" >
                <xsl:attribute name="value">
                    <xsl:value-of select="$translationItems/trans:translation_item[@id = 'display_variables']/trans:part[@type = $dvName]/@value" />
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates select="node()">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>

        </xsl:element>

    </xsl:template>


    <!-- Output hidden fields for each default error message for which a translation has been provided -->
    <xsl:template match="div[(@class = 'form') and form]">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>

        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="node()">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>

            <xsl:for-each select="$translationItems/trans:translation_item[@id = 'default_error_messages']/trans:part" >
                <input type="hidden" disabled="disabled" id="hyf_default_error_message_{@type}" value="{@value}"/>
            </xsl:for-each>


        </xsl:element>

    </xsl:template>



    <!-- Check for field level custom error messages to see if we have a translation for them -->
    <xsl:template match="@data-wm-error-msg">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>


        <!-- Need to allow for the repeat info possiblly being at the start of each ID -->
        <xsl:variable name="elementName">
            <xsl:call-template name="find-component-id">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
                <xsl:with-param name="fieldID" select="../@id"/>
            </xsl:call-template>
        </xsl:variable>


        <xsl:choose>
            <xsl:when test="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'error_message']">
                <xsl:attribute name="data-wm-error-msg">
                    <xsl:value-of select="$translationItems/trans:translation_item[@id = $elementName]/trans:part[@type = 'error_message']/@value"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>





    <!-- Returns the actual ID to check in the dictionary file for the component with an id attribute of fieldID
         This checks to see if it starts with the given repeat ID, and if so removes this and the repeat entry number-->
    <xsl:template name="find-component-id">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>
        <xsl:param name="fieldID"/>

        <xsl:choose>
            <xsl:when test="$currentRepeatID != '' and starts-with($fieldID, $currentRepeatID)" >
                <xsl:call-template name="remove-starting-numbers">
                    <xsl:with-param name="string" select="substring-after($fieldID, $currentRepeatID)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$fieldID"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:variable name="digits">1234567890</xsl:variable>

    <!-- removes any numbers from the start of the given string -->
    <xsl:template name="remove-starting-numbers">
        <xsl:param name="string"/>

        <xsl:choose>
            <xsl:when test="contains($digits, substring($string, 1, 1))">
                <xsl:call-template name="remove-starting-numbers">
                    <xsl:with-param name="string" select="substring($string, 2)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- returns the contents of 'string' after the very last occurrence of
         the 'seperator' string. -->
    <xsl:template name="substring-after-last">
        <xsl:param name="string"/>
        <xsl:param name="seperator"/>
        <xsl:variable name="after" select="substring-after($string, $seperator)"/>
        <xsl:choose>
            <xsl:when test="contains($after, $seperator)">
                <xsl:call-template name="substring-after-last">
                    <xsl:with-param name="string" select="$after"/>
                    <xsl:with-param name="seperator" select="$seperator"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$after"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- returns the contents of 'string' before the very last occurrence of
         the 'seperator' string. -->
    <xsl:template name="substring-before-last">
        <xsl:param name="string"/>
        <xsl:param name="seperator"/>
        <xsl:value-of select="substring-before($string, $seperator)"/>
        <xsl:variable name="after" select="substring-after($string, $seperator)"/>
        <xsl:if test="contains($after, $seperator)">
            <xsl:value-of select="$seperator"/>
            <xsl:call-template name="substring-before-last">
                <xsl:with-param name="string" select="$after"/>
                <xsl:with-param name="seperator" select="$seperator"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- Generic template that will match any node or attribute, and just copy it to the ouput -->
    <xsl:template match="*">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="node()">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="xform:instance" xmlns:xform="http://www.w3.org/2001/08/xforms">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="text() | comment() | processing-instruction() | @* | xform:xform" xmlns:xform="http://www.w3.org/2001/08/xforms">
        <xsl:param name="currentRepeatID"/>
        <xsl:param name="currentRepeatName"/>
        <xsl:copy>
            <xsl:apply-templates select="@*">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="node()">
                <xsl:with-param name="currentRepeatID" select="$currentRepeatID"/>
                <xsl:with-param name="currentRepeatName" select="$currentRepeatName"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
