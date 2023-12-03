<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx"
	xmlns:edm="http://docs.oasis-open.org/odata/ns/edm"
	xmlns:sql="urn:schemas-microsoft-com:mapping-schema"
	exclude-result-prefixes="xsl xs edmx edm sql"
	version="1.0">

<xsl:output indent="yes" method="xml" /> 

<xsl:variable name="Namespace" select="translate(substring-after(/xs:schema/@targetNamespace,'http://'),'/','.')"/>
<xsl:key name="attributeGroup" match="/xs:schema/xs:attributeGroup" use="@name" />
<xsl:key name="group" match="/xs:schema/xs:group" use="@name" />

<xsl:template match="/">
<edmx:Edmx xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx" Version="4.0">
	<edmx:DataServices>
		<Schema xmlns="http://docs.oasis-open.org/odata/ns/edm" Namespace="{$Namespace}">
			<xsl:apply-templates select="//xs:complexType[@name]"/>
			<xsl:apply-templates select="//xs:element[xs:complexType]" mode="type"/>
		</Schema>
	</edmx:DataServices>
</edmx:Edmx>
</xsl:template>

<xsl:template match="xs:element[xs:complexType]" mode="type">
	<xsl:variable name="ParentType" select="concat(ancestor::xs:complexType[@name]/@name,ancestor::xs:group[@name]/@name)"/>
	<ComplexType xmlns="http://docs.oasis-open.org/odata/ns/edm" Name="{$ParentType}{@name}">
		<xsl:apply-templates select=".//xs:attribute|.//xs:attributeGroup"/>
		<xsl:apply-templates select=".//xs:extension"/>
		<xsl:apply-templates select=".//xs:element"/>
	</ComplexType>
</xsl:template>

<xsl:template match="/xs:schema/xs:element[1]" mode="type">
	<EntityContainer xmlns="http://docs.oasis-open.org/odata/ns/edm"  Name="DefaultContainer">
		<EntitySet Name="{@name}" EntityType="{$Namespace}.{//xs:element/@type}"/>
	</EntityContainer>
</xsl:template>

<xsl:template match="xs:complexType[@name]">
	<ComplexType xmlns="http://docs.oasis-open.org/odata/ns/edm" Name="{@name}">
		<xsl:apply-templates select="xs:attribute | xs:attributeGroup | xs:simpleContent/xs:extension/xs:attribute | xs:simpleContent/xs:extension/xs:attributeGroup"/>
		<xsl:apply-templates select="xs:complexContent/xs:extension"/>
		<xsl:apply-templates select="xs:complexContent/xs:restriction"/>
		<xsl:apply-templates select="xs:simpleContent/xs:extension"/>
		<xsl:apply-templates select="key('group',descendant::xs:group/@ref)"/>
		<xsl:apply-templates select="./*/xs:element"/>
	</ComplexType>
</xsl:template>

<xsl:template match="xs:complexType[@name=/xs:schema/xs:element[1]//xs:element/@type]">
	<EntityType xmlns="http://docs.oasis-open.org/odata/ns/edm" Name="{@name}">
		<xsl:apply-templates select=".//xs:attribute[@sql:field=current()/@sql:key-fields]" mode="key"/>
		<xsl:apply-templates select="xs:attribute|xs:attributeGroup"/>
		<xsl:apply-templates select="key('group',descendant::xs:group/@ref)"/>
		<xsl:apply-templates select="./*/xs:element"/>
	</EntityType>
</xsl:template>

<xsl:template match="xs:attribute" mode="key">
	<Key xmlns="http://docs.oasis-open.org/odata/ns/edm">
		<PropertyRef Name="{@name}"/> 
	</Key>
</xsl:template>

<xsl:template match="xs:attribute|xs:element">
	<xsl:variable name="tp">
		<xsl:apply-templates select="@type" mode="sc"/>
		<xsl:apply-templates select="self::node()[not(@type)]" mode="sd"/>
	</xsl:variable>
	<Property xmlns="http://docs.oasis-open.org/odata/ns/edm" Name="{@name}" Type="{$tp}" Nullable="true"/>
</xsl:template>

<xsl:template match="xs:simpleContent/xs:extension">
	<xsl:variable name="tp">
		<xsl:apply-templates select="@base" mode="sc"/>
	</xsl:variable>
	<Property xmlns="http://docs.oasis-open.org/odata/ns/edm" Name="text" Type="{$tp}" Nullable="true"/>
</xsl:template> 

<xsl:template match="xs:complexContent/xs:restriction">
	<xsl:apply-templates select="xs:attribute | xs:attributeGroup"/>
	<xsl:apply-templates select="./*/xs:element"/>
</xsl:template>

<xsl:template match="xs:complexContent/xs:extension">
	<xsl:apply-templates select="xs:attribute | xs:attributeGroup"/>
	<xsl:apply-templates select="./*/xs:element"/>

	<xsl:variable name="ref" select="//xs:complexType[@name=current()/@base]"/>
	<xsl:apply-templates select="$ref/xs:attribute | $ref/xs:attributeGroup | $ref/xs:simpleContent/xs:extension/xs:attribute | $ref/xs:simpleContent/xs:extension/xs:attributeGroup"/>
	<xsl:apply-templates select="$ref/xs:complexContent/xs:extension"/>
	<xsl:apply-templates select="$ref/xs:complexContent/xs:restriction"/>
	<xsl:apply-templates select="$ref/xs:simpleContent/xs:extension"/>
	<xsl:apply-templates select="$ref/*/xs:element"/>
</xsl:template> 

<xsl:template match="xs:attributeGroup[@ref]">
	<xsl:variable name="ag" select="key('attributeGroup',@ref)"/>
	<xsl:apply-templates select="$ag/xs:attribute"/>
</xsl:template>

<xsl:template match="xs:element[xs:complexType]">
	<xsl:variable name="ParentType">
		<xsl:apply-templates select="." mode="getType"/>
	</xsl:variable>
	<Property xmlns="http://docs.oasis-open.org/odata/ns/edm" Name="{@name}" Type="{$Namespace}.{$ParentType}{@name}" Nullable="true"/>
</xsl:template>

<xsl:template match="xs:group">
	<xsl:apply-templates select="./*/xs:attribute"/>
	<xsl:apply-templates select="./*/xs:element"/>
</xsl:template>

<xsl:template mode="sc" match="@*"><xsl:value-of select="$Namespace"/>.<xsl:value-of select="."/></xsl:template>
<xsl:template mode="sc" match="@*[.='base64Binary']">Edm.Binary</xsl:template>
<xsl:template mode="sc" match="@*[.='boolean']">Edm.Boolean</xsl:template>
<xsl:template mode="sc" match="@*[.='unsignedByte']">Edm.Byte</xsl:template>
<xsl:template mode="sc" match="@*[.='unsignedShort']">Edm.Int16</xsl:template>
<xsl:template mode="sc" match="@*[.='date']">Edm.Date</xsl:template>
<xsl:template mode="sc" match="@*[.='dateTime']">Edm.DateTimeOffset</xsl:template>
<xsl:template mode="sc" match="@*[.='decimal']">Edm.Decimal</xsl:template>
<xsl:template mode="sc" match="@*[.='double']">Edm.Double</xsl:template>
<xsl:template mode="sc" match="@*[.='duration']">Edm.Duration</xsl:template>
<xsl:template mode="sc" match="@*[.='string']">Edm.String</xsl:template>
<xsl:template mode="sc" match="@*[.='short']">Edm.Int16</xsl:template>
<xsl:template mode="sc" match="@*[.='int']">Edm.Int32</xsl:template>
<xsl:template mode="sc" match="@*[.='long']">Edm.Int64</xsl:template>
<xsl:template mode="sc" match="@*[.='byte']">Edm.SByte</xsl:template>
<xsl:template mode="sc" match="@*[.='float']">Edm.Single</xsl:template>
<xsl:template mode="sc" match="@*[.='time']">Edm.TimeOfDay</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:base64Binary']">Edm.Binary</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:boolean']">Edm.Boolean</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:unsignedByte']">Edm.Byte</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:unsignedShort']">Edm.Int16</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:date']">Edm.Date</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:dateTime']">Edm.DateTimeOffset</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:decimal']">Edm.Decimal</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:double']">Edm.Double</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:duration']">Edm.Duration</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:string']">Edm.String</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:short']">Edm.Int16</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:int']">Edm.Int32</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:long']">Edm.Int64</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:byte']">Edm.SByte</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:float']">Edm.Single</xsl:template>
<xsl:template mode="sc" match="@*[.='xs:time']">Edm.TimeOfDay</xsl:template>
<xsl:template mode="sd" match="*">Edm.String</xsl:template>

<!--xsl:template match="xs:element[ancestor::xs:group[@name]] | xs:attribute[ancestor::xs:group[@name]]" mode="getType">
	<xsl:variable name="group_desc" select="//xs:group[@ref=current()/ancestor::xs:group[1]/@name]"/>
	<xsl:value-of select="concat(ancestor::xs:group/@name,'-',$group_desc/ancestor::xs:complexType/@name)"/>
</xsl:template-->

<xsl:template match="xs:attribute[ancestor::xs:element]|xs:extension[ancestor::xs:element]" mode="getType">
	<xsl:value-of select="ancestor::xs:element[1]/@name"/>
</xsl:template>

<xsl:template match="xs:attribute[ancestor::xs:attributeGroup]" mode="getType">
	<xsl:variable name="group_desc" select="//xs:attributeGroup[@ref=current()/ancestor::xs:attributeGroup[1]/@name]"/>
	<xsl:value-of select="$group_desc/ancestor::xs:complexType/@name"/>
</xsl:template>

<xsl:template match="xs:element[xs:complexType]" mode="getType">
	<xsl:value-of select="concat(ancestor::xs:complexType[@name]/@name,ancestor::xs:group[@name]/@name)"/>
</xsl:template>

<xsl:template match="xs:element[ancestor::xs:complexType[@name]] | xs:attribute[ancestor::xs:complexType[@name]] |  xs:extension[ancestor::xs:complexType[@name]]" mode="getType">
	<xsl:value-of select="ancestor::xs:complexType/@name"/>
</xsl:template>

</xsl:stylesheet>

