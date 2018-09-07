<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="input | select | textarea">
        <xsl:copy>

            <xsl:variable name="doDisable">
                <xsl:call-template name="is-field-disabled">
                    <xsl:with-param name="field" select="."/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="$doDisable = 'false'">
                    <xsl:apply-templates select="@*" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*" />
                    <xsl:choose>
                        <xsl:when test="(@type[. = 'text' or . = 'password']) or (local-name() = 'textarea')">
                            <xsl:attribute name="readonly">readonly</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="disabled">disabled</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="class">
                        <xsl:value-of select="@class"/>
                        <xsl:text> disabled</xsl:text>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
    <xsl:template match="a">
        <xsl:copy>

            <xsl:variable name="doDisable">
                <xsl:call-template name="is-field-disabled">
                    <xsl:with-param name="field" select="."/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="$doDisable = 'false'">
                    <xsl:apply-templates select="@*" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*[(local-name() != 'href') and not(starts-with(local-name(), 'on'))]" />
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:value-of select="@class"/>
                        <xsl:text> disabled</xsl:text>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>

    <!-- add the isDisabled class to controlBody elements -->
    <xsl:template match="*[contains(@class, 'controlBody')]">
        <xsl:copy>
            <xsl:apply-templates select="@*" />

            <xsl:variable name="doDisable">
                <xsl:call-template name="is-field-disabled">
                    <xsl:with-param name="field" select="(input[@type != 'hidden'] | textarea | select | a)[1]"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$doDisable = 'true'">
                <xsl:attribute name="class">
                    <xsl:value-of select="@class"/>
                    <xsl:text> isDisabled</xsl:text>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>

    <!-- add the isDisabled class to label container elements -->
    <xsl:template match="*[substring(@id, string-length(@id) - string-length('_label_container') + 1) = '_label_container']">
        <xsl:copy>
            <xsl:apply-templates select="@*" />

            <xsl:variable name="doDisable">
                <xsl:call-template name="is-field-disabled">
                    <xsl:with-param name="field" select="../../..//*[@id = current()//label/@for]"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$doDisable = 'true'">
                <xsl:attribute name="class">
                    <xsl:value-of select="@class"/>
                    <xsl:text> isDisabled</xsl:text>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>


    <xsl:template name="is-field-disabled">
        <xsl:param name="field"/>

        <xsl:choose>
            <xsl:when test="local-name($field) = 'a'">
                 <xsl:choose>
                <!-- If it is a tab, then we will not try and disable it -->
                <xsl:when test="contains($field/@class, 'selectedTab') or contains($field/@class, 'unselectedTab')">false</xsl:when>
                <!-- If it is a collapsible section, then we will not try and disable it -->
                <xsl:when test="contains($field/@class, 'toggleHidden') or contains($field/@class, 'toggleVisible')">false</xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <!-- If it is a tab control hidden field, then we will not try and disable it -->
                    <xsl:when test="$field/@type = 'hidden' and (contains($field/@id, 'tab_control') or contains($field/../../../@class, 'tabContainer'))">false</xsl:when>
                    <xsl:otherwise>true</xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Ensure that we never disable controls or group contents that have the neverReadOnly class applied to them -->
    <!-- The class can be added to a Group, a Control Background if you don't want to disable all parts of the control e.g. Calendar or hidden xpath fields, or just the actual Field Control. -->
    <xsl:template match="*[contains(@class, 'neverReadOnly')]" priority="10">
        <xsl:copy-of select=".">
        </xsl:copy-of>
    </xsl:template>
    <!-- This Template will ensure that the Save and Complete WIH buttons have no effect, by overriding the standard function processing with nothing if the Application is in ReadOnly mode -->
    <xsl:template match="html/body">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates />
            <script>
            function onWorkitemComplete()
            {
            }
            function onWorkitemSave()
            {
            }
            function onWorkitemForward()
            {
            }
            function onWorkitemReply()
            {
            }
            </script>
        </xsl:copy>
    </xsl:template>
    <!-- Catchall to ensure all other content is copied across -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
