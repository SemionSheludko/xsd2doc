<?xml version="1.0" encoding="UTF-8"?>
<!--
	MIT License
	Copyright (c) 2017 Semion Sheludko ssn@artensberne.com

	File:
		xsd2tree.xsl
	Description:
		Templates for displaying the XML node tree of the XML schema
	Assumptions:
     -Assumed that XSD document conforms to the XSD recommendation.
      No validity checking is done.
	How to use:
	  1.Apply templates:
		<xsl:apply-templates select="/xs:schema/xs:element[1]"/>
	  2.Define template for print out:
		<xsl:template match="xs:element | xs:attribute" mode="print">
			<xsl:param name="path"/>
			<xsl:param name="parentType"/>
			<li><xsl:value-of select="@name"/></li>
			<xsl:if test="key('complexType',@type) | xs:complexType">
				<ul>
					<xsl:apply-templates select="key('complexType',@type) | xs:complexType">
						<xsl:with-param name="path" select="$path"/>
						<xsl:with-param name="parentType" select="$parentType"/>
					</xsl:apply-templates>
				</ul>
			</xsl:if>
		</xsl:template>
		'path' parameter contains full path to node without namespaces, lile /rootElements/secondElement/@attribute. 
			If @useNamespaceInPath param='yes' namespace included in path
		'parentType' paramenter contains named complexType node of parent element
	Not supported:
	- XML schema 'redefine' element
	- simpleContent/extension reffered to complexType (simpleType only) 
	- simpleType/union/@memberTypes
	- simpleType/restriction/whiteSpace
	- choice minOccurs maxOccurs
-->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:conv="urn:ab:xsdTypeToInputTypeMapping"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:exslt="http://exslt.org/common"
	exclude-result-prefixes="xsl xs"
	version="1.0">

<!-- ******** Global variables and keys ******** -->
<!--xsl:param name="language"/-->
<!--xsl:param name="useNamespaceInPath" select="'no'"/-->

<xsl:variable name="xsdPrefix" select="local-name(/xs:schema/namespace::*[.='http://www.w3.org/2001/XMLSchema'])"/>
<xsl:variable name="xsdPrefixC" select="concat($xsdPrefix,':')"/>
<xsl:variable name="targetNamespace" select="normalize-space(/xs:schema/@targetNamespace)"/>
<xsl:variable name="prefix">
	<xsl:choose>
		<xsl:when test="/xs:schema/namespace::*[local-name(.)!='' and .=$targetNamespace]">
			<xsl:value-of select="local-name(/xs:schema/namespace::*[local-name(.)!='' and .=$targetNamespace])"/>
		</xsl:when>
		<xsl:otherwise>ns</xsl:otherwise>
	</xsl:choose>
</xsl:variable>
<xsl:variable name="ns">
	<xsl:if test="$useNamespaceInPath='yes'"><xsl:value-of select="$prefix"/>:</xsl:if>
</xsl:variable>

<xsl:key name="complexType" match="/xs:schema/xs:complexType" use="@name" />
<xsl:key name="simpleType" match="/xs:schema/xs:simpleType" use="@name" />
<xsl:key name="element" match="/xs:schema//xs:element" use="@name" />
<xsl:key name="attributeGroup" match="/xs:schema/xs:attributeGroup" use="@name" />
<xsl:key name="group" match="/xs:schema/xs:group" use="@name" />
<xsl:key name="attribute" match="/xs:schema/xs:attribute" use="@name" />

<!-- ******** 
	Xml Schema Hierarchy templates.  
	******** -->

<xsl:template match="xs:element">
	<xsl:param name="path"/>
	<xsl:param name="ref"/>
	<xsl:param name="parentType"/>
	<xsl:variable name="type"><xsl:apply-templates select="@type"/></xsl:variable>
	<xsl:apply-templates select="." mode="print">
		<xsl:with-param name="path" select="concat($path,'/',$ns,@name)"/>
		<xsl:with-param name="ref" select="$ref"/>
		<xsl:with-param name="parentType" select="$parentType"/>
		<xsl:with-param name="simpleType" select="key('simpleType',$type) | xs:simpleType"/>
		<xsl:with-param name="complexType" select="key('complexType',$type) | xs:complexType"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:element[@ref]">
	<xsl:param name="path"/>
	<xsl:param name="parentType"/>
	<xsl:apply-templates select="key('element',@ref) | key('element',substring-after(@ref,':'))">
		<xsl:with-param name="path" select="$path"/>
		<xsl:with-param name="ref" select="."/>
		<xsl:with-param name="parentType" select="$parentType"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:attribute">
	<xsl:param name="path"/>
	<xsl:param name="ref"/>
	<xsl:param name="parentType"/>
	<xsl:variable name="type"><xsl:apply-templates select="@type"/></xsl:variable>
	<xsl:apply-templates select="." mode="print">
		<xsl:with-param name="path" select="concat($path,'/@',@name)"/>
		<xsl:with-param name="ref" select="$ref"/>
		<xsl:with-param name="parentType" select="$parentType"/>
		<xsl:with-param name="simpleType" select="key('simpleType',$type) | xs:simpleType"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:attribute[@ref and @ref='xml:lang']">
	<xsl:param name="path"/>
	<xsl:param name="parentType"/>
	<xsl:apply-templates select="." mode="print">
		<xsl:with-param name="path" select="concat($path,'/@',@ref)"/>
		<xsl:with-param name="parentType" select="$parentType"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:attribute[@ref and @ref!='xml:lang']">
	<xsl:param name="path"/>
	<xsl:param name="parentType"/>
	<xsl:apply-templates select="key('attribute',@ref) | key('attribute',substring-after(@ref,':'))">
		<xsl:with-param name="path" select="$path"/>
		<xsl:with-param name="ref" select="."/>
		<xsl:with-param name="parentType" select="$parentType"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:complexType">
	<xsl:param name="path"/>
	<xsl:param name="parentType"/>
	<xsl:choose>
		<xsl:when test="@name and not(xs:complexContent/xs:restriction)">
			<xsl:apply-templates select="xs:attribute|xs:attributeGroup"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="."/></xsl:apply-templates>
			<xsl:apply-templates select="xs:simpleContent|xs:complexContent"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="."/></xsl:apply-templates>
			<xsl:apply-templates select="(xs:sequence|xs:all|xs:choice|xs:sequence/xs:choice|xs:sequence/xs:choice/xs:sequence)/xs:element|xs:group|./*/xs:group"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="."/></xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="xs:attribute|xs:attributeGroup"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$parentType"/></xsl:apply-templates>
			<xsl:apply-templates select="xs:simpleContent|xs:complexContent"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$parentType"/></xsl:apply-templates>
			<xsl:apply-templates select="(xs:sequence|xs:all|xs:choice|xs:sequence/xs:choice|xs:sequence/xs:choice/xs:sequence)/xs:element|xs:group|./*/xs:group"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$parentType"/></xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xs:group[@name]">
	<xsl:param name="path"/>
	<xsl:param name="parentType"/>
	<xsl:param name="ref"/>
	<xsl:apply-templates select="(xs:sequence|xs:all|xs:choice)/xs:element">
		<xsl:with-param name="path" select="$path"/>
		<xsl:with-param name="ref" select="$ref"/>
		<xsl:with-param name="parentType" select="$parentType"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:group[@ref]">
	<xsl:param name="path"/>
	<xsl:param name="parentType"/>
	<xsl:apply-templates select="key('group',@ref)">
		<xsl:with-param name="path" select="$path"/>
		<xsl:with-param name="ref" select="."/>
		<xsl:with-param name="parentType" select="$parentType"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:attributeGroup">
	<xsl:param name="path"/>
	<xsl:param name="parentType"/>
	<xsl:variable name="ag" select="key('attributeGroup',@ref)"/>
	<xsl:apply-templates select="$ag/xs:attribute"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$ag"/></xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:complexContent">
	<xsl:param name="path"/>
	<xsl:param name="parentType"/>
	<xsl:apply-templates select="xs:extension/xs:attribute|xs:extension/xs:attributeGroup"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$parentType"/></xsl:apply-templates>
	<xsl:apply-templates select="xs:extension/*/xs:element"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$parentType"/></xsl:apply-templates>
	<xsl:variable name="base">
		<xsl:apply-templates select="xs:extension/@base"/>
	</xsl:variable>
	<xsl:apply-templates select="key('complexType',$base)"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$parentType"/></xsl:apply-templates>
	<xsl:apply-templates select="xs:restriction"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$parentType"/></xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:complexContent/xs:restriction">
	<xsl:param name="path"/>
	<xsl:param name="parentType"/>
	<xsl:variable name="base">
		<xsl:apply-templates select="@base"/>
	</xsl:variable>
	<xsl:variable name="complexType" select="key('complexType',$base)"/>
	<xsl:apply-templates select="$complexType/xs:attribute[@name=current()/xs:attribute/@name]"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$complexType"/></xsl:apply-templates>
	<xsl:apply-templates select="$complexType/xs:attributeGroup[@ref=current()/attributeGroup/@ref]"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$complexType"/></xsl:apply-templates>
	<xsl:apply-templates select="$complexType/*/xs:element[@name=current()/*/xs:element[not(@type)]/@name]"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$complexType"/></xsl:apply-templates>
	<xsl:apply-templates select="./*/xs:element[@type]"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$complexType"/></xsl:apply-templates>
	<xsl:apply-templates select="key('group',$complexType/xs:group/@ref)/*/xs:element[@name=current()/*/xs:element/@name]"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$complexType"/></xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:simpleContent">
	<xsl:param name="path"/>
	<xsl:param name="parentType"/>
	<xsl:apply-templates select="(xs:extension|xs:restriction)/xs:attribute|(xs:extension|xs:restriction)/xs:attributeGroup"><xsl:with-param name="path" select="$path"/><xsl:with-param name="parentType" select="$parentType"/></xsl:apply-templates>
</xsl:template>

<xsl:template match="xs:annotation">
	<xsl:choose>
		<xsl:when test="not($language = '') and xs:documentation[@xml:lang=$language]">
			<xsl:value-of select="xs:documentation[@xml:lang=$language]" />
		</xsl:when>
		<xsl:when test="not($language = '') and xs:documentation[not(@xml:lang)]">
			<xsl:value-of select="xs:documentation[not(@xml:lang)]" />
		</xsl:when>
		<xsl:when test="$language = '' and xs:documentation">
			<xsl:value-of select="xs:documentation[1]" />
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="@type | @base">
	<xsl:choose>
		<xsl:when test="starts-with(.,$xsdPrefixC)"><xsl:value-of select="."/></xsl:when>
		<xsl:when test="contains(.,':')"><xsl:value-of select="substring-after(.,':')"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>

