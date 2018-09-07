<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:mvc="http://www.hyfinity.com/mvc" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Header>
                <serviceConstructor xmlns="http://handysoft.com/webservice/ServiceConstructor">
                    <sessionInfoXML xmlns="">
                        <xsl:value-of select="/WorkitemContext/SessionInfoXML"/>
                    </sessionInfoXML>
                    <serverId xmlns="">
                        <xsl:value-of select="substring(substring-after(/WorkitemContext/SessionInfoXML, 'SERVERID'), 3, 10)"/>
                    </serverId>
                    <id xmlns="">
                        <xsl:value-of select="/WorkitemContext/Process/ID"/>
                    </id>
                    <archive xmlns="">false</archive>
                </serviceConstructor>
            </soap:Header>
            <soap:Body>
                <updateProcessVariables xmlns="http://service.je.wf.bf.hs.com">
                    <xsl:apply-templates select="/WorkitemContext/Process/ProcessVariables"/>
                </updateProcessVariables>
            </soap:Body>
        </soap:Envelope>
    </xsl:template>
    <xsl:template match="ProcessVariables">
        <variables xmlns="">
            <xsl:apply-templates select="ProcessVariable[not(Value/@unchanged_on_screen)]"/>
            <xsl:apply-templates select="*[local-name() != 'ProcessVariable']" mode="ProcessVariable"/>
            <!-- Block non-simple types for now to prevent BizFlow update issue -->
            <!--<xsl:apply-templates select="ProcessVariable[substring(Name, 1, 1) != '#' and (ValueType='S' or ValueType='X' or ValueType='A' or ValueType='P' or ValueType='D' or ValueType='F' or ValueType='N')]"/>-->
            <!--<xsl:apply-templates select="*[local-name() != 'ProcessVariable' and not(*)]" mode="ProcessVariable"/>-->
        </variables>
    </xsl:template>
    <xsl:template match="ProcessVariable">
        <item xmlns="http://handysoft.com/webservice/HWProcess">
            <!--<dirtyFlag xmlns="">Y</dirtyFlag>-->
            <!--<description xmlns="">
                <xsl:value-of select="Description"/>
            </description>-->
            <!--<displayValue xmlns="">
                <xsl:value-of select="DisplayValue"/>
            </displayValue>-->
            <!--<existDataFile xmlns=""/>-->
            <!--<isPublic xmlns="">
                <xsl:choose>
                    <xsl:when test="isPublic[.='N']">
                        <xsl:text>false</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>true</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </isPublic>-->
            <name xmlns="">
                <xsl:value-of select="Name"/>
            </name>
            <!--<processId xmlns="">
                <xsl:value-of select="/mvc:eForm/mvc:Data/SaveWorkitemContext/WorkitemContext/Process/ID"/>
            </processId>-->
            <!--<scope xmlns="">
                <xsl:value-of select="Scope"/>
            </scope>-->
            <!--<sequence xmlns="">9</sequence>-->
            <!--<serverId xmlns=""/>-->
            <value xmlns="">
                <xsl:choose>
                    <xsl:when test="ValueType = 'D'">
                        <xsl:value-of select="translate(Value, 'T-', ' /')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="Value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </value>
            <!--<valueType xmlns="">
                <xsl:value-of select="ValueType"/>
            </valueType>-->
        </item>
    </xsl:template>

    <xsl:template match="*" mode="ProcessVariable">
        <item xmlns="http://handysoft.com/webservice/HWProcess">
            <name xmlns="">
                <xsl:value-of select="local-name()"/>
            </name>
            <value xmlns="">
                <xsl:value-of select="."/>
            </value>
        </item>
    </xsl:template>
</xsl:stylesheet>
