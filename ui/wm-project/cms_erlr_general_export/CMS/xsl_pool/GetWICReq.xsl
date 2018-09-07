<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mvc="http://www.hyfinity.com/mvc">
	<xsl:template match="/">
		<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
			<soap:Header>
				<serviceConstructor xmlns="http://handysoft.com/webservice/ServiceConstructor">
					<sessionInfoXML xmlns="">
						<xsl:copy-of select="/mvc:eForm/mvc:Data/bizflow_details/SessionInfoXML/SESSIONINFO" />
					</sessionInfoXML>
					<serverId xmlns="">
						<xsl:value-of select="/mvc:eForm/mvc:Data/bizflow_details/SessionInfoXML/SESSIONINFO/@SERVERID" />
					</serverId>
					<processId xmlns="">
						<xsl:value-of select="/mvc:eForm/mvc:Data/bizflow_details/ProcID" />
					</processId>
					<workitemSequence xmlns="">
						<xsl:value-of select="/mvc:eForm/mvc:Data/bizflow_details/WitemSeq" />
					</workitemSequence>
					<archive xmlns="">
						<xsl:value-of select="/mvc:eForm/mvc:Data/bizflow_details/archive" />
					</archive>
				</serviceConstructor>
			</soap:Header>
			<soap:Body>
				<getWorkitemContext xmlns="http://service.je.wf.bf.hs.com">
					<applicationSequence xmlns="">
						<xsl:value-of select="/mvc:eForm/mvc:Data/bizflow_details/AppSeq" />
					</applicationSequence>
				</getWorkitemContext>
			</soap:Body>
		</soap:Envelope>
	</xsl:template>
</xsl:stylesheet>
