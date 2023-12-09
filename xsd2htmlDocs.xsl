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
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	exclude-result-prefixes="xsl xs msxsl"
	version="1.0">

<xsl:include href="xsd2tree.xsl" />

<xsl:param name="useNamespaceInPath" select="'no'"/>
<xsl:param name="language"/>

<!--
     Prints out the html for every xsd attributes, called from schema2tree templates (xsd2tree.xsl)
-->
<xsl:template match="xs:attribute" mode="print">
	<xsl:param name="path"/>
	<xsl:param name="ref"/>
	<xsl:param name="parentType"/>
	<xsl:param name="simpleType"/>
	<xsl:param name="complexType"/>
		<xsl:text> </xsl:text>
		<xsl:variable name="st">
			<xsl:apply-templates select="$simpleType"/>
		</xsl:variable>
		<span class="at"><xsl:value-of select="@name"/><xsl:value-of select="@ref"/></span><span class="av">="</span><span class="atv">
		<xsl:value-of select="substring-after(@type,$xsdPrefixC)"/>
		<xsl:choose>
			<xsl:when test="string-length($st) &lt; 68">
				<xsl:value-of select="$st"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring($st,1,67)"/><xsl:text>...</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="@ref"/>
		<xsl:apply-templates select="@use"/>"</span>
</xsl:template>

<!--
     Prints out the html for every xsd elements, called from schema2tree templates (xsd2tree.xsl)
-->
<xsl:template match="xs:element" mode="print">
	<xsl:param name="path"/>
	<xsl:param name="ref"/>
	<xsl:param name="parentType"/>
	<xsl:param name="simpleType"/>
	<xsl:param name="complexType"/>
	<xsl:variable name="ins">
		<xsl:choose>
			<xsl:when test="ancestor::msxsl:import/@ns"><xsl:value-of select="ancestor::msxsl:import/@ns"/></xsl:when>
			<xsl:when test="$complexType and $complexType/ancestor::msxsl:import/@ns"><xsl:value-of select="$complexType/ancestor::msxsl:import/@ns"/></xsl:when>
		</xsl:choose>
	</xsl:variable>

	<!-- calculate indent -->
	<xsl:variable name="indent">
		<xsl:variable name="pt" select="translate($path,'/','')"/>
		<xsl:value-of select="string-length($path) - string-length($pt)"/>
	</xsl:variable>
	
	<!-- close previous tag, if it is not root element  -->
	<xsl:if test="$indent!=1"><span class="lt">&gt;</span><br/></xsl:if>
	<!-- print comment above element, if it is not simpleType. Simple types will comment inline  -->
	<xsl:if test="not(substring-before(@type,':')=$xsdPrefix or $simpleType)">
		<xsl:call-template name="printElementComment">
			<xsl:with-param name="indent" select="$indent"/>
			<xsl:with-param name="ref" select="$ref"/>
			<xsl:with-param name="path" select="$path"/>
		</xsl:call-template>
	</xsl:if>
	<xsl:if test="(parent::xs:choice or parent::xs:sequence/parent::xs:choice) and not(preceding-sibling::*)">
		<span class="i{$indent} lt"><span class="comment"><b><xsl:text>&lt;-- One of the possible options --&gt;</xsl:text></b></span></span><br/>
	</xsl:if>
	<!--xsl:if test="$parentType">
	<span class="i{$indent} lt"><span class="comment"><xsl:text>&lt;/// </xsl:text><xsl:value-of select="$parentType/@name"/><xsl:text> //&gt;</xsl:text></span></span><br/>
	</xsl:if-->
	<!-- open element tag  -->
	<span class="i{$indent} lt">&lt;</span><span class="tn"><xsl:value-of select="concat($ins,@name)"/></span>
	<!-- print namespaces for root element  -->
	<xsl:if test="$indent=1">
		<span class="at">xmlns="<xsl:value-of select="$targetNamespace"/>"</span>
		<!--xsl:for-each select="$importedTypes/xs:schema/msxsl:import">
			<span class="at">xmlns:<xsl:value-of select="substring-before(@ns,':')"/>="<xsl:value-of select="@ref"/>"</span>
		</xsl:for-each-->
	</xsl:if>
	<!-- process element  -->
	<xsl:choose>
		<!-- if it is complexType - process this complexType and close tag  -->
		<xsl:when test="$complexType">
			<xsl:apply-templates select="$complexType">
				<xsl:with-param name="path" select="$path"/>
				<xsl:with-param name="parentType" select="$parentType"/>
			</xsl:apply-templates>
			<xsl:choose>
				<xsl:when test="$complexType/xs:simpleContent">
					<xsl:variable name="doc">
						<xsl:apply-templates select="xs:annotation"/><xsl:if test="xs:annotation">:</xsl:if>
					</xsl:variable>
					<span class="lt">&gt;</span>
					<xsl:if test="string-length($doc) &gt; 50">
						<br/>
					</xsl:if>
					<span>
					<xsl:if test="string-length($doc) &gt; 50">
						<xsl:attribute name="class"><xsl:text>comment i</xsl:text><xsl:value-of select="$indent + 1"/><xsl:text> block</xsl:text></xsl:attribute>
					</xsl:if>
					<xsl:if test="string-length($doc) &lt;= 50">
						<xsl:attribute name="class">comment</xsl:attribute>
					</xsl:if>
					<xsl:text>&lt;!-- </xsl:text>
					<xsl:value-of select="$doc"/>
					<xsl:value-of select="substring-after($complexType/xs:simpleContent/xs:extension/@base,$xsdPrefixC)"/>
					<xsl:text> --&gt;</xsl:text></span>
					<xsl:if test="string-length($doc) &gt; 50">
						<span class="i{$indent}"/>
					</xsl:if>
					<span class="lt">&lt;/</span><span class="tn"><xsl:value-of select="concat($ins,@name)"/></span>
				</xsl:when>
				<xsl:when test="$complexType/*/xs:element or $complexType/xs:complexContent//xs:element or $complexType/@mixed='true'
					or $complexType/xs:complexContent">
					<span class="lt">&gt;</span><br/>
					<xsl:if test="$complexType/@mixed='true'">
						<span class="i{$indent + 1}">mixed content (text and tags)</span><br/>
					</xsl:if>
					<span class="i{$indent} lt">&lt;/</span><span class="tn"><xsl:value-of select="concat($ins,@name)"/></span>
				</xsl:when>
				<xsl:otherwise>/</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$indent=1"><span class="lt">&gt;</span></xsl:if>
		</xsl:when>
		<!-- if it is simpleType or schema type - print comment and close tag  -->
		<xsl:when test="substring-before(@type,':')=$xsdPrefix or $simpleType">
			<span class="lt">&gt;</span>
			<xsl:variable name="doc">
				<xsl:apply-templates select="xs:annotation"/><xsl:if test="xs:annotation">:</xsl:if>
			</xsl:variable>
			<xsl:if test="string-length($doc) &gt; 50">
				<br/>
			</xsl:if>
			<span>
				<xsl:if test="string-length($doc) &gt; 50">
					<xsl:attribute name="class"><xsl:text>comment i</xsl:text><xsl:value-of select="$indent + 1"/><xsl:text> block</xsl:text></xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($doc) &lt;= 50">
					<xsl:attribute name="class">comment</xsl:attribute>
				</xsl:if>
				<xsl:text>&lt;!-- </xsl:text><xsl:value-of select="$doc"/><xsl:value-of select="substring-after(@type,$xsdPrefixC)"/><xsl:if test="$simpleType"><xsl:apply-templates select="$simpleType"/></xsl:if><xsl:text> --&gt;</xsl:text>
			</span>
			<xsl:if test="string-length($doc) &gt; 50">
				<span class="i{$indent}"/>
			</xsl:if>
			<span class="lt">&lt;</span>/<span class="tn"><xsl:value-of select="concat($ins,@name)"/></span>
		</xsl:when>
		<!-- otherwise - just close tag  -->
		<xsl:otherwise>/</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="printElementComment">
	<xsl:param name="indent"/>
	<xsl:param name="ref"/>
	<xsl:param name="path"/>
	
	<xsl:if test="xs:annotation or ($ref and $ref/xs:annotation) or 
		@minOccurs[.!=0] or @maxOccurs[.!=1] or ($ref and ($ref/@minOccurs[.!=0] or $ref/@maxOccurs[.!=1]))">
	<span class="comment block i{$indent}"><xsl:text>&lt;!-- </xsl:text>
		<!--xsl:value-of select="$path"/-->
		<xsl:if test="xs:annotation">
			<xsl:apply-templates select="xs:annotation"/>
		</xsl:if>
		<xsl:if test="$ref and $ref/xs:annotation">
			<xsl:apply-templates select="$ref/xs:annotation"/>
		</xsl:if>
		<xsl:if test="@minOccurs[.!=0] or @maxOccurs[.!=1]">
			<xsl:apply-templates select="@minOccurs"/>
			<xsl:apply-templates select="@maxOccurs"/>
		</xsl:if>
		<xsl:if test="$ref and ($ref/@minOccurs[.!=0] or $ref/@maxOccurs[.!=1])">
			<xsl:apply-templates select="$ref/@minOccurs"/>
			<xsl:apply-templates select="$ref/@maxOccurs"/>
		</xsl:if>
	<xsl:text> --&gt;</xsl:text></span>
	</xsl:if>
</xsl:template>

<xsl:template match="xs:simpleType">
	<xsl:apply-templates select="xs:union/xs:simpleType"/>
	<xsl:apply-templates select="xs:restriction"/>
</xsl:template>

<xsl:template match="@ref">
&lt;language&gt;
</xsl:template>
<xsl:template match="@use">
</xsl:template>
<xsl:template match="@use[.='required']">
-<b>required</b>
</xsl:template>

<xsl:template match="@minOccurs">
	<xsl:text> </xsl:text>required min <xsl:value-of select="."/> times
</xsl:template>
<xsl:template match="@minOccurs[.=1]">
	<xsl:text> </xsl:text><b>This element is required</b>
</xsl:template>
<xsl:template match="@minOccurs[.=0]">
</xsl:template>
<xsl:template match="@maxOccurs">
	maximum occurs <xsl:value-of select="."/>
</xsl:template>
<xsl:template match="@maxOccurs[.=1 and ../@minOccurs]">
</xsl:template>
<xsl:template match="@maxOccurs[.='unbounded']">
	<xsl:text> </xsl:text><b>Maximum number of repetitions of this element is unlimited</b>
</xsl:template>

<xsl:template match="xs:simpleType/xs:restriction">
	<xsl:if test="not(xs:enumeration)">
		<xsl:value-of select="substring-after(@base,':')"/>
	</xsl:if>
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
</xsl:template>

<xsl:template match="xs:enumeration">
[<xsl:for-each select="../xs:enumeration"><xsl:value-of select="@value"/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>]
</xsl:template>
<xsl:template match="xs:pattern">
,pattern: <xsl:value-of select="@value"/>
</xsl:template>
<xsl:template match="xs:length">
,length: <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:maxLength">
,max length: <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:minLength">
,min length: <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:fractionDigits">
,fraction digits: <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:minInclusive">
,&gt;= <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:maxInclusive">
,&lt;= <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:minExclusive">
,&gt; <xsl:value-of select="@value"/>	
</xsl:template>
<xsl:template match="xs:maxExclusive">
,&lt; <xsl:value-of select="@value"/>	
</xsl:template>

</xsl:stylesheet>


