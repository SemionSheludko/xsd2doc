<?xml version="1.0" encoding="UTF-8"?>
<!--
Not supported:
- simpleContent/extension reffered to complexType (simpleType only) 
- simpleType/union/@memberTypes
- simpleType/restriction/whiteSpace
-->
<xsl:stylesheet 
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xsl xs"
	version="1.0">

<xsl:output method="xml" indent="yes"/>

<xsl:param name="language"/>
<xsl:param name="useNamespaceInPath" select="'no'"/>
<xsl:include href="xsd2tree.xsl" />

<xsl:template match="/">
	<xsl:apply-templates select="/xs:schema/xs:element[1]" />
</xsl:template> 

<xsl:template match="xs:attribute" mode="print">
	<xsl:param name="path"/>
	<xsl:param name="ref"/>
	<xsl:param name="options"/>
	<xsl:param name="simpleType"/>
	<xsl:param name="complexType"/>

	<xsl:attribute name="{@name}"></xsl:attribute>
</xsl:template>

<xsl:template match="xs:element" mode="print">
	<xsl:param name="path"/>
	<xsl:param name="ref"/>
	<xsl:param name="options"/>
	<xsl:param name="simpleType"/>
	<xsl:param name="complexType"/>

	<xsl:element name="{@name}" namespace="{$targetNamespace}">
		<xsl:if test="$complexType">
			<xsl:apply-templates select="$complexType">
				<xsl:with-param name="path" select="$path"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:element>
</xsl:template>

</xsl:stylesheet>


