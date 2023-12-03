<?xml version="1.0" encoding="UTF-8"?>
<!--
  MIT License
  Copyright (c) 2017 Semion Sheludko  ssn@artensberne.com

  File:
     xsd2xhtmlForm.xsl
  Description:
     Stylesheet that generates XHTML Form, given an XML Schema document
  Assumptions:
     -Resulting form will only be displayed properly with the latest browsers 
	  that support XHTML and CSS. Older browsers are not supported.
     -Assumed that XSD document conforms to the XSD recommendation.
      No validity checking is done.
-->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:conv="urn:ab:xsdTypeToInputTypeMapping"
	exclude-result-prefixes="xsl xs conv"
	version="1.0">
<xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>

<xsl:include href="xsd2tree.xsl" />

<xsl:variable name="typesMapping" select="document('')//conv:typesMapping"/>
<xsl:variable name="booleanType" select="concat($xsdPrefix,':boolean')"/>
<xsl:variable name="durationType" select="concat($xsdPrefix,':duration')"/>
<xsl:variable name="useNamespaceInPath" select="'no'"/>
<xsl:param name="language"/>

<!--
     Prints out the html for every xsd elements and attributes, called from schema2tree templates (xsd2tree.xsl)
-->
<xsl:template match="xs:element | xs:attribute" mode="print">
	<xsl:param name="path"/>
	<xsl:param name="options"/>
	<xsl:variable name="id" select="translate($path,'/@','')"/>
	<xsl:variable name="label">
		<xsl:call-template name="label"/>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="local-name()='element' and @maxOccurs and @maxOccurs != 1 and (xs:complexType or key('complexType',@type))">
			<!-- For elements with reccurring complex type - do table -->
			<xsl:call-template name="reccuringComplexType">
				<xsl:with-param name="path" select="$path"/>
				<xsl:with-param name="id" select="$id"/>
				<xsl:with-param name="label" select="$label"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="contains($options,'tableview')">
			<!-- For elements inside reccurring complex type - do td -->
			<td xmlns="http://www.w3.org/1999/xhtml">
				<xsl:apply-templates select="." mode="formElement">
					<xsl:with-param name="id" select="$id"/>
					<xsl:with-param name="path" select="$path"/>
				</xsl:apply-templates>
			</td>
		</xsl:when>
		<xsl:when test="local-name()='element' and (xs:complexType or key('complexType',@type))">
			<!-- For elements with complex type - do legend, except root element -->
			<xsl:if test="$path!=concat('/',$ns,@name)">
				<legend xmlns="http://www.w3.org/1999/xhtml"><xsl:value-of select="$label"/></legend>
			</xsl:if>
			<!-- Dive into the tree -->
			<xsl:apply-templates select="key('complexType',@type) | xs:complexType">
				<xsl:with-param name="path" select="$path"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<!-- Print bootstrap form 'label - input' row -->
			<div class="form-group" xmlns="http://www.w3.org/1999/xhtml">
				<label for="i{$id}" class="col-sm-2 control-label"><xsl:value-of select="$label"/></label>
				<div class="col-sm-10">
					<xsl:choose>
						<xsl:when test="@maxOccurs and number(@maxOccurs) &gt; 1">
							<!-- if it is recurring simple element -->
							<xsl:variable name="el" select="."/>
							<div class="row">
								<xsl:for-each select="$typesMapping/*">
									<xsl:if test="position() &lt;= $el/@maxOccurs">
										<div class="col-sm-4">
											<xsl:apply-templates select="$el" mode="formElement">
												<xsl:with-param name="id" select="$id"/>
												<xsl:with-param name="path" select="$path"/>
											</xsl:apply-templates>
										</div>
									</xsl:if>
								</xsl:for-each>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="formElement">
								<xsl:with-param name="id" select="$id"/>
								<xsl:with-param name="path" select="$path"/>
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--
     Prints out the table for reccuring complexType.
-->
<xsl:template name="reccuringComplexType">
	<xsl:param name="path"/>
	<xsl:param name="id"/>
	<xsl:param name="label"/>
	<xsl:variable name="complexType" select="xs:complexType | key('complexType',@type)"/>
	<legend xmlns="http://www.w3.org/1999/xhtml"><xsl:value-of select="$label"/></legend>
	<table class='table' id="reccuring_{$id}" xmlns="http://www.w3.org/1999/xhtml">
		<thead>
		<tr>
		<xsl:for-each select="$complexType/*/xs:element | $complexType/xs:attribute">
			<xsl:sort select="local-name()" data-type="text" order="ascending" />
			<xsl:variable name="th">
				<xsl:call-template name="label"/>
			</xsl:variable>
			<th><xsl:value-of select="$th"/></th>
		</xsl:for-each>
		</tr>
		</thead>
		<tbody>
			<xsl:choose>
				<xsl:when test="@maxOccurs='unbounded'">
					<tr>
						<!-- Dive into the tree -->
						<xsl:apply-templates select="key('complexType',@type) | xs:complexType">
							<xsl:with-param name="path" select="$path"/>
							<xsl:with-param name="options" select="'tableview'"/>
						</xsl:apply-templates>
					</tr>
					<tr>
						<td colspan="{count($complexType/*/xs:element | $complexType/xs:attribute)}">
							<a href="javascript:addnewrow('reccuring_{$id}')">Add new row</a>
						</td>
					</tr>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="el" select="."/>
					<xsl:for-each select="$typesMapping/*">
						<xsl:if test="position() &lt;= $el/@maxOccurs">
							<tr>
								<!-- Dive into the tree -->
								<xsl:apply-templates select="key('complexType',$el/@type) | $el/xs:complexType">
									<xsl:with-param name="path" select="$path"/>
									<xsl:with-param name="options" select="'tableview'"/>
								</xsl:apply-templates>
							</tr>
						</xsl:if>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</tbody>
	</table>
</xsl:template>

<!--
     Prints out the input, textarea or select elements with attributes.
-->
<xsl:template match="xs:element | xs:attribute" mode="formElement">
	<xsl:param name="id"/>
	<xsl:param name="path"/>
	<xsl:variable name="simpleType" select="key('simpleType',@type) | key('simpleType',substring-after(@type,':')) | xs:simpleType"/>
	<xsl:variable name="ntype" select="$simpleType/xs:restriction/@base | @type"/>
	<xsl:choose>
		<xsl:when test="$simpleType/xs:restriction/xs:enumeration">
			<xsl:apply-templates select="$simpleType/xs:restriction" mode="createSelectElement">
				<xsl:with-param name="id" select="$id"/>
				<xsl:with-param name="path" select="$path"/>
				<xsl:with-param name="element" select="."/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:when test="substring-after($ntype,':')='string' and number($simpleType/xs:restriction/xs:maxLength) &gt; 2000">
			<textarea class="form-control" id="{$id}" name="{$id}" 
				rows="{round(number($simpleType/xs:restriction/xs:maxLength) div 800)}"
				xmlns="http://www.w3.org/1999/xhtml"></textarea>
		</xsl:when>
		<xsl:when test="$ntype=$durationType">
			<div class="input-group" xmlns="http://www.w3.org/1999/xhtml">
				<div class="input-group-addon duration-value" id="v-{$id}"></div>
				<xsl:call-template name="createInputElement">
					<xsl:with-param name="id" select="$id"/>
					<xsl:with-param name="path" select="$path"/>
					<xsl:with-param name="ntype" select="$ntype"/>
					<xsl:with-param name="simpleType" select="$simpleType"/>
				</xsl:call-template>
			</div>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="createInputElement">
				<xsl:with-param name="id" select="$id"/>
				<xsl:with-param name="path" select="$path"/>
				<xsl:with-param name="ntype" select="$ntype"/>
				<xsl:with-param name="simpleType" select="$simpleType"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--
     Prints out the select element constructed from xs:simpleType/xs:restriction/xs:enumeration
-->
<xsl:template match="xs:restriction[xs:enumeration]" mode="createSelectElement">
	<xsl:param name="id"/>
	<xsl:param name="element"/>
	<select id="{$id}" name="{$id}" class="form-control" xmlns="http://www.w3.org/1999/xhtml">
		<xsl:if test="$element/@fixed">
			<xsl:attribute name="readonly">readonly</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="." mode="makeAttributes"/>
		<xsl:for-each select="xs:enumeration">
			<option value="{@value}"><xsl:if test="@value=$element/@fixed"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:value-of select="@value"/></option>
		</xsl:for-each>
	</select>
</xsl:template>

<!--
     Prints out the input element
-->
<xsl:template name="createInputElement">
	<xsl:param name="path"/>
	<xsl:param name="id"/>
	<xsl:param name="ntype"/>
	<xsl:param name="simpleType"/>
	<input class="form-control" id="{$id}" name="{$id}" xmlns="http://www.w3.org/1999/xhtml">
		<!-- add @type attribute with optional @step attrinute -->
		<xsl:call-template name="makeTypeAttribute">
			<xsl:with-param name="ntype" select="$ntype"/>
			<xsl:with-param name="simpleType" select="$simpleType"/>
		</xsl:call-template>
		<!-- add @value attribute with optional @required and @readonly attributes -->
		<xsl:call-template name="makeValue"/>
		<!-- add @min, @max, @pattern attrinutes -->
		<xsl:apply-templates select="$simpleType/xs:restriction" mode="makeAttributes"/>
	</input>
</xsl:template>

<!-- 
     Prints out the 'value' attribute for input element 
-->
<xsl:template name="makeValue">
	<xsl:choose>
		<xsl:when test="@fixed and @type=$booleanType">
			<xsl:attribute name="readonly">readonly</xsl:attribute>
			<xsl:if test="@fixed = 'true'">
				<xsl:attribute name="checked">checked</xsl:attribute>
			</xsl:if>
		</xsl:when>
		<xsl:when test="@fixed">
			<xsl:attribute name="readonly">readonly</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="@fixed"/></xsl:attribute>
		</xsl:when>
		<xsl:when test="@default and @type=$booleanType">
			<xsl:if test="@default = 'true'">
				<xsl:attribute name="checked">checked</xsl:attribute>
			</xsl:if>
		</xsl:when>
		<xsl:when test="@default">
			<xsl:attribute name="value"><xsl:value-of select="@default"/></xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
			<xsl:attribute name="value"></xsl:attribute>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="@use = 'required'">
		<xsl:attribute name="required">required</xsl:attribute>
	</xsl:if>
</xsl:template>

<!--
     Prints out the 'type', 'min', 'max', 'step' attributes for input element, 
	 based on (xs:element | xs"attribute)/@type or xs:simpleType/xs:restriction/@base.
	 Check mappings xml at the end of template. 
-->
<xsl:template name="makeTypeAttribute">
	<xsl:param name="ntype"/>
	<xsl:param name="simpleType"/>
	<xsl:variable name="type" select="substring-after($ntype,':')"/>
	<xsl:variable name="mapping" select="$typesMapping/conv:map[@type=$type]"/>
	<xsl:attribute name="type"><xsl:value-of select="$mapping/@to"/></xsl:attribute>
	<xsl:if test="$mapping/@min!='' and not($simpleType/xs:restriction[xs:minInclusive or xs:minExclusive])">
		<xsl:attribute name="min"><xsl:value-of select="$mapping/@min"/></xsl:attribute>
	</xsl:if>
	<xsl:if test="$mapping/@max!='' and not($simpleType/xs:restriction[xs:maxInclusive or xs:maxExclusive])">
		<xsl:attribute name="max"><xsl:value-of select="$mapping/@max"/></xsl:attribute>
	</xsl:if>
	<xsl:if test="$mapping/@step!=''">
		<xsl:attribute name="step">
			<xsl:choose>
				<xsl:when test="$simpleType/@fractionDigits!='' and $simpleType/@fractionDigits!='0'">
					<xsl:value-of select="concat('0.',substring('000000000',1,$simpleType/@fractionDigits - 1),'1')" />
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$mapping/@step"/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:if>
	<xsl:if test="$type='boolean'">
		<xsl:attribute name="style">width: 30px;</xsl:attribute>
	</xsl:if>
</xsl:template>

<!--
     Prints out the 'pattern', 'maxlength', 'max', 'min' attributes for input element, 
	 based on xs:simpleType/xs:restriction settings.
-->
<xsl:template match="xs:simpleType/xs:restriction" mode="makeAttributes">
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
<xsl:template match="xs:pattern">
	<xsl:attribute name="pattern"><xsl:value-of select="@value"/></xsl:attribute>
</xsl:template>
<xsl:template match="xs:length">
	<xsl:attribute name="maxlength"><xsl:value-of select="@value"/></xsl:attribute>
</xsl:template>
<xsl:template match="xs:maxLength">
	<xsl:attribute name="maxlength"><xsl:value-of select="@value"/></xsl:attribute>
</xsl:template>
<xsl:template match="xs:minLength">
	<xsl:attribute name="min"><xsl:value-of select="@value"/></xsl:attribute>
</xsl:template>
<xsl:template match="xs:fractionDigits">
</xsl:template>
<xsl:template match="xs:minInclusive">
	<xsl:attribute name="min"><xsl:value-of select="@value"/></xsl:attribute>
</xsl:template>
<xsl:template match="xs:maxInclusive">
	<xsl:attribute name="max"><xsl:value-of select="@value"/></xsl:attribute>
</xsl:template>
<xsl:template match="xs:minExclusive">
	<xsl:attribute name="min"><xsl:value-of select="@value"/></xsl:attribute>
</xsl:template>
<xsl:template match="xs:maxExclusive">
	<xsl:attribute name="max"><xsl:value-of select="@value"/></xsl:attribute>
</xsl:template>

<!-- 
	Returns an element's label from xs:annotation/xs:documentation or @value or @name 
-->
<xsl:template name="label">
	<xsl:choose>
		<xsl:when test="not($language = '') and xs:annotation/xs:documentation[@xml:lang=$language]">
			<xsl:value-of select="xs:annotation/xs:documentation[@xml:lang=$language]" />
		</xsl:when>
		<xsl:when test="not($language = '') and xs:annotation/xs:documentation[not(@xml:lang)]">
			<xsl:value-of select="xs:annotation/xs:documentation[not(@xml:lang)]" />
		</xsl:when>
		<xsl:when test="$language = '' and xs:annotation/xs:documentation">
			<xsl:value-of select="xs:annotation/xs:documentation" />
		</xsl:when>
		<xsl:when test="@name">
			<xsl:value-of select="@name" />
		</xsl:when>
		<xsl:when test="@value">
			<xsl:value-of select="@value" />
		</xsl:when>
	</xsl:choose>
</xsl:template>

<!-- 
	Returns an element's label
-->
<xsl:template match="xs:element" mode="header">
	<xsl:call-template name="label"/>
</xsl:template>

<!-- ******** 
	Xml Schema types to xHTML input types mapping.  
	******** -->
<conv:typesMapping>
	<conv:map type="anyURI" to="url" pattern=""/>
	<conv:map type="base64Binary" to="file" pattern=""/>
	<conv:map type="boolean" to="checkbox" pattern=""/>
	<conv:map type="byte" to="number" min="-128" max="127" pattern="" step="1"/>
	<conv:map type="date" to="date" pattern="" step="1"/>
	<conv:map type="dateTime" to="datetime-local" pattern="" step="1"/>
	<conv:map type="decimal" to="number" pattern="" step="0.01"/>
	<conv:map type="double" to="number" pattern="" step="0.01"/>
	<conv:map type="duration" to="range" pattern="" step="1"/>
	<conv:map type="ENTITIES" to="text" pattern=""/>
	<conv:map type="ENTITY" to="text" pattern=""/>
	<conv:map type="float" to="number" pattern="" step="0.01"/>
	<conv:map type="gDay" to="number" min="1" max="31" pattern="" step="1"/>
	<conv:map type="gMonth" to="number" min="1" max="12" pattern="" step="1"/>
	<conv:map type="gMonthDay" to="date" pattern="" step="1"/>
	<conv:map type="gYear" to="number" min="1700" max="2700" pattern="" step="1"/>
	<conv:map type="gYearMonth" to="month" pattern="" step="1"/>
	<conv:map type="hexBinary" to="file" pattern=""/>
	<conv:map type="ID" to="hidden" pattern=""/>
	<conv:map type="IDREF" to="text" pattern=""/>
	<conv:map type="IDREFS" to="text" pattern=""/>
	<conv:map type="int" to="number" pattern=""/>
	<conv:map type="integer" to="number" pattern=""/>
	<conv:map type="language" to="text" pattern=""/>
	<conv:map type="long" to="number" pattern=""/>
	<conv:map type="Name" to="text" pattern=""/>
	<conv:map type="NCName" to="text" pattern=""/>
	<conv:map type="negativeInteger" to="number" max="-1" pattern=""/>
	<conv:map type="NMTOKEN" to="text" pattern=""/>
	<conv:map type="NMTOKENS" to="text" pattern=""/>
	<conv:map type="nonNegativeInteger" to="number" min="0" pattern=""/>
	<conv:map type="nonPositiveInteger" to="number" max="0" pattern=""/>
	<conv:map type="normalizedString" to="text" pattern=""/>
	<conv:map type="NOTATION" to="text" pattern=""/>
	<conv:map type="positiveInteger" to="number" min="1" pattern=""/>
	<conv:map type="QName" to="text" pattern=""/>
	<conv:map type="short" to="number" min="-32768" max="32767" pattern=""/>
	<conv:map type="string" to="text" pattern=""/>
	<conv:map type="time" to="time" pattern="" step="1"/>
	<conv:map type="token" to="text" pattern=""/>
	<conv:map type="unsignedByte" to="number" min="0" max="255" pattern=""/>
	<conv:map type="unsignedInt" to="number" min="0" pattern=""/>
	<conv:map type="unsignedLong" to="number" min="0" pattern=""/>
	<conv:map type="unsignedShort" to="number" min="0" max="65535" pattern=""/>
</conv:typesMapping>

</xsl:stylesheet>


