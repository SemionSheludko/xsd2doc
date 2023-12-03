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

<xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>

<xsl:param name="language"/>

<xsl:param name="useNamespaceInPath" select="'no'"/>
<xsl:include href="xsd2tree.xsl" />


<!--
     Prints out the html for every xsd elements and attributes, called from schema2tree templates (xsd2tree.xsl)
-->
<xsl:template match="xs:element | xs:attribute" mode="print">
	<xsl:param name="path"/>
	<xsl:param name="ref"/>
	<xsl:param name="options"/>
	<xsl:param name="simpleType"/>
	<xsl:param name="complexType"/>

	<li class="list-group-item">
		<h4 class="list-group-item-heading">
			<xsl:value-of select="@name"/> <xsl:value-of select="@ref"/>
			<small>(<xsl:value-of select="$path"/>)</small>
		</h4>
		<xsl:if test="xs:annotation">
			<i><xsl:apply-templates select="xs:annotation"/></i>
		</xsl:if>
		<xsl:if test="$ref and $ref/xs:annotation">
			<i><xsl:apply-templates select="$ref/xs:annotation"/></i>
		</xsl:if>
		<p class="list-group-item-text">
			<xsl:if test="substring-before(@type,':')='xs'">
				<xsl:apply-templates select="@type"/>
			</xsl:if>
			<xsl:if test="$complexType and $complexType/@mixed='true'">
				xs:string
			</xsl:if>
			<xsl:apply-templates select="." mode="printOccurs"/>
			<xsl:if test="$ref">
				<xsl:apply-templates select="$ref" mode="printOccurs"/>
			</xsl:if>
			<xsl:if test="$simpleType">
				<xsl:apply-templates select="$simpleType"/>
			</xsl:if>
		</p>
		<xsl:if test="$complexType">
			<ul class="list-group" style="margin-bottom:0">
				<!-- Dive into the tree -->
				<xsl:apply-templates select="$complexType">
					<xsl:with-param name="path" select="$path"/>
				</xsl:apply-templates>
			</ul>
		</xsl:if>
	</li>
</xsl:template>

<xsl:template match="xs:simpleType">
	<xsl:apply-templates select="xs:union/xs:simpleType"/>
	<xsl:apply-templates select="xs:restriction"/>
</xsl:template>

<xsl:template match="xs:element | xs:attribute" mode="printOccurs">
	<xsl:apply-templates select="@minOccurs"/>
	<xsl:apply-templates select="@maxOccurs"/>
	<xsl:apply-templates select="@use"/>
</xsl:template>

<xsl:template match="@minOccurs">
	<xsl:text> </xsl:text>required min <xsl:value-of select="."/> times
</xsl:template>
<xsl:template match="@minOccurs[.=1]">
	<xsl:text> </xsl:text>required
</xsl:template>
<xsl:template match="@minOccurs[.=0]">
	<xsl:text> </xsl:text>optional
</xsl:template>
<xsl:template match="@maxOccurs">
	maximum occurs <xsl:value-of select="."/>
</xsl:template>
<xsl:template match="@maxOccurs[.=1 and ../@minOccurs]">
</xsl:template>
<xsl:template match="@maxOccurs[.='unbounded']">
	unbounded
</xsl:template>
<xsl:template match="@use">
	<xsl:text> </xsl:text><xsl:value-of select="."/>
</xsl:template>

<xsl:template match="xs:simpleType/xs:restriction">
	<p class="list-group-item-text">Restriction of <xsl:value-of select="@base"/>
	<xsl:apply-templates select="xs:enumeration[1]"/>
	<xsl:apply-templates select="xs:minInclusive"/>
	<xsl:apply-templates select="xs:maxInclusive"/>
	<xsl:apply-templates select="xs:minExclusive"/>
	<xsl:apply-templates select="xs:maxExclusive"/>
	<xsl:apply-templates select="xs:pattern"/>
	<xsl:apply-templates select="xs:length"/>
	<xsl:apply-templates select="xs:fractionDigits"/>
	<xsl:apply-templates select="xs:maxLength"/>
	<xsl:apply-templates select="xs:minLength"/>
	</p>
</xsl:template>

<xsl:template match="xs:enumeration">
	Enumeration:
	<xsl:for-each select="../xs:enumeration"><xsl:value-of select="@value"/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>
</xsl:template>
<xsl:template match="xs:pattern">
	Pattern: <xsl:value-of select="@value"/>
</xsl:template>
<xsl:template match="xs:length">
	Length: <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:maxLength">
	Max length: <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:minLength">
	Min length: <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:fractionDigits">
	Fraction Digits: <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:minInclusive">
	&gt;= <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:maxInclusive">
	&lt;= <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:minExclusive">
	&gt; <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:maxExclusive">
	&lt; <xsl:value-of select="@value"/>	
</xsl:template>

</xsl:stylesheet>


