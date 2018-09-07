<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mvc="http://www.hyfinity.com/mvc">
    <xsl:template match="/">
        <bizflow_details xmlns="">
            <SessionInfoXML>
                <xsl:value-of  select="/mvc:eForm/mvc:Control/mvc:sessioninfo" />
            </SessionInfoXML>
            <ProcID>
                <xsl:value-of select="/mvc:eForm/mvc:Control/mvc:procid" />
            </ProcID>
            <ActSeq>
                <xsl:value-of select="/mvc:eForm/mvc:Control/mvc:actseq" />
            </ActSeq>
            <WitemSeq>
                <xsl:value-of select="/mvc:eForm/mvc:Control/mvc:workseq" />
            </WitemSeq>
            <AppSeq>
                <xsl:value-of select="/mvc:eForm/mvc:Control/mvc:appseq" />
                <!--<xsl:text>0</xsl:text>-->
            </AppSeq>
            <archive>
                <xsl:value-of select="/mvc:eForm/mvc:Control/mvc:isarchive" />
            </archive>
            <xsl:if test="/mvc:eForm/mvc:Control/mvc:readOnly">
                <mvc:readOnly>
                    <xsl:value-of select="/mvc:eForm/mvc:Control/mvc:readOnly" />
                </mvc:readOnly>
            </xsl:if> 
        </bizflow_details>
    </xsl:template>
</xsl:stylesheet>