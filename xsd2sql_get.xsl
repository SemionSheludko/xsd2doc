<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:axsl="http://www.w3.org/1999/XSL/Transform1"
				xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sql="urn:schemas-microsoft-com:mapping-schema"
				xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xqbe="http://abcmf.net/schema/xqbe/v1"
		        exclude-result-prefixes="xs sql" version="1.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:include href="xsd2tree.xsl" />

	<xsl:namespace-alias stylesheet-prefix="axsl" result-prefix="xsl" />
	<xsl:param name="useNamespaceInPath" select="'yes'"/>
	<xsl:param name="language"/>
	<xsl:variable name="APOS">'</xsl:variable>

	<!-- Main template that starts the process -->
	<xsl:template match="/">
		<axsl:stylesheet xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
			xmlns:xqbe="http://abcmf.net/schema/xqbe/v1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="SOAP-ENV xqbe" version="1.0">
			<xsl:attribute name="{$prefix}:usedForNSOutput" namespace="{/xs:schema/@targetNamespace}"></xsl:attribute>

			<axsl:output method="xml" indent="yes"/>
			
			<!-- Create root templates - process SOAP request -->
			<xsl:call-template name="CreateSOAPHeaderTemplates"/>

			<!--  Process schema, use xsd2tree.xsl to call every 
				xs:element | xs:attribute template with mode="print" -->
			<xsl:apply-templates select="/xs:schema/xs:element[1]" />
			
			<!--  Create templates to prohibit default xslt node processing --> 
			<xsl:call-template name="ChangeDefaultXsltTemplates"/>
			
			<!--  Create some helper templates  --> 
			<xsl:call-template name="SelectTopAndOffsetTemplates"/>

			<!-- change default Xslt template -->
			<axsl:template match="text()|@*"/>
		</axsl:stylesheet>
	</xsl:template>
	
	<xsl:template name="CreateSOAPHeaderTemplates">
		<axsl:template match="/">
			<axsl:if test="not(SOAP-ENV:Envelope)">
				<axsl:message terminate="yes">XMLSQL: 101: Invalid request,	SOAP-ENV:Envelope required</axsl:message>
			</axsl:if>
			<commands><!--  xmlns="{/xs:schema/@targetNamespace}" -->
				<axsl:apply-templates select="SOAP-ENV:Envelope/SOAP-ENV:Header" />
			</commands>
		</axsl:template>
	
		<!-- template to process SOAP request -->
		<axsl:template match="//SOAP-ENV:Header">
			<!-- uppercase method -->
			<axsl:variable name="method" select="translate(xqbe:EnvHeader/xqbe:Method, 'infogetpsdl', 'INFOGETPSDL')"/>
			<axsl:choose>
				<axsl:when test="$method = ''">
					<axsl:message terminate="yes">XMLSQL: 102: xqbe:EnvHeader/xqbe:Method reqired</axsl:message>
				</axsl:when>
				<axsl:when test="$method = 'GET' or $method = 'INFO'">
					<axsl:apply-templates select="../SOAP-ENV:Body" mode="get"/>
				</axsl:when>
				<axsl:when test="$method = 'POST'">
					<axsl:apply-templates select="../SOAP-ENV:Body" mode="post"/>
				</axsl:when>
				<axsl:when test="$method = 'DELETE'">
					<axsl:apply-templates select="../SOAP-ENV:Body" mode="delete"/>
				</axsl:when>
				<axsl:otherwise>
					<axsl:apply-templates select="../SOAP-ENV:Body" mode="appinfo"/>
				</axsl:otherwise>
			</axsl:choose>
		</axsl:template>

		<!-- template to process GET SOAP request -->
		<axsl:template match="SOAP-ENV:Body" mode="get">
			<command type="select" namespace="{/xs:schema/@targetNamespace}">
				<text>
					<axsl:apply-templates
						select="{$ns}{//xs:schema/xs:element/@name}/{$ns}{//xs:schema/xs:element/descendant::xs:element[1]/@name}" mode="query" />
				</text>
				<parameters>
					<axsl:apply-templates select="*|@*" mode="param" />
				</parameters>
			</command>
		</axsl:template>

		<!-- template to process POST SOAP request -->
		<axsl:template match="//SOAP-ENV:Body" mode="post">
			<axsl:apply-templates select="{$ns}{//xs:schema/xs:element/@name}/{$ns}{//xs:schema/xs:element/descendant::xs:element[1]/@name}" mode="post"/>
		</axsl:template>

		<!-- template to process DELETE SOAP request -->
		<axsl:template match="//SOAP-ENV:Body" mode="delete">
			<axsl:apply-templates select="{$ns}{//xs:schema/xs:element/@name}/{$ns}{//xs:schema/xs:element/descendant::xs:element[1]/@name}" mode="delete"/>
		</axsl:template>

		<!-- template to process other SOAP requests -->
		<axsl:template match="//SOAP-ENV:Body" mode="appinfo">
		</axsl:template>
	</xsl:template>
	
	<!-- Create templates for every xsd elements and attributes, 
		called from schema2tree templates (xsd2tree.xsl) -->
	<xsl:template match="xs:element | xs:attribute" mode="print">
		<xsl:param name="path" /> <!-- path to node, like /ns:A/ns:B/@attr -->
		<xsl:param name="ref" /> <!-- Referenced element, if exists, to process minOccuts/maxOccurs  -->
		<xsl:param name="simpleType" /> <!-- link to simpleType of node -->
		<xsl:param name="complexType" /> <!-- link to complexType of node -->
		<xsl:param name="parentType"/> <!-- link to complexType of parent node -->

		<!-- level: root element 0, first complex type 1,  nested tables + 1-->
		<xsl:variable name="level">
			<xsl:variable name="pt" select="translate($path,'/','')"/>
			<xsl:value-of select="string-length($path) - string-length($pt)"/>
		</xsl:variable>

		<!--  for simple types -->
		<xsl:if test="not($complexType)">
			<xsl:apply-templates select="." mode="ConstructEementTemplates">
				<xsl:with-param name="path" select="$path"/>
				<xsl:with-param name="type" select="$simpleType/xs:restriction/@base | @type"/>
				<xsl:with-param name="parentType" select="$parentType"/>
				<xsl:with-param name="level" select="$level"/>
			</xsl:apply-templates>
		</xsl:if>

		<!--  for complex types -->
		<xsl:if test="$complexType">
			<xsl:if test="$level=2">
				<!--  create query template -->
				<xsl:apply-templates select="." mode="ConstructQueryTemplateForRoot">
					<xsl:with-param name="path" select="$path"/>
					<xsl:with-param name="complexType" select="$complexType"/>
					<xsl:with-param name="level" select="$level"/>
				</xsl:apply-templates>
			</xsl:if>
			<xsl:if test="$level &gt; 2">
				<xsl:apply-templates select="." mode="ConstructQueryTemplateForChilds">
					<xsl:with-param name="path" select="$path"/>
					<xsl:with-param name="parentType" select="$parentType"/>
					<xsl:with-param name="complexType" select="$complexType"/>
					<xsl:with-param name="level" select="$level"/>
				</xsl:apply-templates>
			</xsl:if>
			<xsl:apply-templates select="." mode="ConstructInsertUpdateTemplates">
				<xsl:with-param name="path" select="$path"/>
				<xsl:with-param name="parentType" select="$parentType"/>
				<xsl:with-param name="complexType" select="$complexType"/>
				<xsl:with-param name="level" select="$level"/>
			</xsl:apply-templates>
			<!-- call xsd2tree.xsl to process complexType and child nodes -->
			<xsl:apply-templates select="$complexType">
				<xsl:with-param name="path" select="$path" />
				<xsl:with-param name="parentType" select="$parentType"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<!-- =========================================================
	INSERT/UPDATE templates
	======================================================== -->
	<xsl:template match="xs:element" mode="ConstructInsertUpdateTemplates">
		<xsl:param name="path"/>
		<xsl:param name="parentType"/>
		<xsl:param name="complexType"/>
		<xsl:param name="level"/>
	</xsl:template>

	<!-- =========================================================
	SELECT Templates
	======================================================== -->
	<!-- Create sql select for first complexType -->
	<xsl:template match="xs:element" mode="ConstructQueryTemplateForRoot">
		<xsl:param name="path"/>
		<xsl:param name="complexType"/>
		<xsl:param name="level"/>
		<xsl:comment><xsl:value-of select="$path"/> (level <xsl:value-of select="$level"/>)</xsl:comment>
		<axsl:template match="{substring-after($path,'/')}" mode="query">
			<axsl:variable name="fields"><axsl:apply-templates select="*|@*" mode="select{$level+1}"/></axsl:variable>
			<axsl:variable name="where"><axsl:apply-templates select="*|@*" mode="where{$level+1}" /></axsl:variable>
			<axsl:apply-templates select="." mode="indent1"/>WITH XMLNAMESPACES (DEFAULT '<xsl:value-of select="$targetNamespace"/><xsl:text>')</xsl:text>
			<axsl:apply-templates select="." mode="indent1"/>SELECT <axsl:apply-templates select="//xqbe:EnvHeader[xqbe:Page=1 and xqbe:PageSize!='']"/>
			<axsl:value-of select="substring-after($fields,',')"/>
			<axsl:apply-templates select="." mode="indent1"/>FROM <xsl:value-of select="$complexType/@sql:table"/><xsl:text> </xsl:text><xsl:value-of select="$complexType/@name"/>
			<axsl:apply-templates select="*" mode="SubTable{$level+1}"/>
			<axsl:if test="normalize-space($where)!=''" >
			<axsl:apply-templates select="." mode="indent1"/>WHERE <axsl:value-of select="substring-after(normalize-space($where),'AND')"/>
			</axsl:if>
			<axsl:variable name="sort">
				<axsl:apply-templates select="//xqbe:EnvHeader/xqbe:Sort"/>
			</axsl:variable>
			<axsl:if test="$sort!=''">
				<axsl:apply-templates select="." mode="indent1"/>ORDER BY <axsl:value-of select="substring-after($sort,',')"/><axsl:text xml:space="preserve"> </axsl:text>
			</axsl:if>
			<axsl:apply-templates select="." mode="indent1"/><axsl:apply-templates select="//xqbe:EnvHeader[xqbe:Page &gt; 1 and xqbe:PageSize!='']"/>
			<axsl:apply-templates select="." mode="indent1"/>FOR XML PATH('<xsl:value-of select="@name"/>'), ROOT('<xsl:value-of select="//xs:schema/xs:element/@name"/>')
		</axsl:template>
	</xsl:template>

	<!-- Create sql select for child complexTypes -->
	<xsl:template match="xs:element" mode="ConstructQueryTemplateForChilds">
		<xsl:param name="path"/>
		<xsl:param name="parentType"/>
		<xsl:param name="complexType"/>
		<xsl:param name="level"/>
		<xsl:comment><xsl:value-of select="$path"/> (level <xsl:value-of select="$level"/>)</xsl:comment>
		<xsl:variable name="typename">
			<xsl:choose>
				<xsl:when test="ancestor::xs:group"><xsl:value-of select="ancestor::xs:group/@name"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$parentType/@name"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Create SELECT subquery for nested types -->
		<axsl:template match="{substring-after($path,'/')}[@*|*]" mode="select{$level}">
			<axsl:variable name="fields"><axsl:apply-templates select="*|@*" mode="select{$level+1}"/>
				<xsl:apply-templates select="$complexType/xs:simpleContent" mode="addSelfField"/></axsl:variable>
			<axsl:variable name="where"><axsl:apply-templates select="*|@*" mode="where{$level+1}"/></axsl:variable>
			<axsl:apply-templates select="." mode="indent{$level}"/>,(SELECT <axsl:value-of select="substring-after($fields,',')"/>
			<xsl:choose>
				<xsl:when test="ancestor::xs:group">
					<!-- group should contain linked table  -->
					<xsl:call-template name="ConstructSubquery">
						<xsl:with-param name="complexType" select="ancestor::xs:group"/>
						<xsl:with-param name="parentType" select="$parentType"/>
						<xsl:with-param name="foreignKeysElemet" select="ancestor::xs:group"/>
						<xsl:with-param name="level" select="$level"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="@maxOccurs='unbounded'">
					<!-- for one-to-many relationship make subquery with from clause -->
					<xsl:call-template name="ConstructSubquery">
						<xsl:with-param name="complexType" select="$complexType"/>
						<xsl:with-param name="parentType" select="$parentType"/>
						<xsl:with-param name="foreignKeysElemet" select="$complexType"/>
						<xsl:with-param name="level" select="$level"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<axsl:apply-templates select="." mode="indent{$level+1}"/>FOR XML PATH('<xsl:value-of select="@name"/>'), type)</axsl:template>
		<!-- Create JOINS templates for nested tables -->
		<xsl:choose>
			<xsl:when test="$complexType/xs:complexContent/xs:extension">
				<!-- extended table joined to extension table -->
				<xsl:call-template name="ConstructJoin">
					<xsl:with-param name="path" select="$path"/>
					<xsl:with-param name="thisType" select="key('complexType',$complexType/xs:complexContent/xs:extension/@base)"/>
					<xsl:with-param name="parentType" select="$complexType"/>
					<xsl:with-param name="foreignKeysElemet" select="$complexType/xs:complexContent/xs:extension"/>
					<xsl:with-param name="level" select="$level+1"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="(@maxOccurs=1 or not (@maxOccurs)) and @sql:foreign-keys">
				<!-- for one-to-one relationship join table to parent table -->
				<xsl:variable name="tableLevel">
					<xsl:variable name="firstElementNotRoot" select="key('complexType',/xs:schema/xs:element[1]/@type)/*/xs:element[1]|
						/xs:schema/xs:element[1]/xs:complexType/*/xs:element[1]"/>
					<xsl:choose>
						<!-- if parent is main table, join it to main query -->
						<xsl:when test="$parentType/@name=$firstElementNotRoot/@type">3</xsl:when>
						<xsl:otherwise><xsl:value-of select="$level"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:call-template name="ConstructJoin">
					<xsl:with-param name="path" select="$path"/>
					<xsl:with-param name="thisType" select="$complexType"/>
					<xsl:with-param name="parentType" select="$parentType"/>
					<xsl:with-param name="foreignKeysElemet" select="."/>
					<xsl:with-param name="level" select="$tableLevel"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
		<xsl:for-each select="$complexType//xs:attributeGroup">
			<xsl:variable name="agType" select="key('attributeGroup',@ref)"/>
			<xsl:call-template name="ConstructJoin">
				<xsl:with-param name="path" select="concat($path,'/@',$agType/xs:attribute[position()=last()]/@name)"/>
				<xsl:with-param name="thisType" select="$agType"/>
				<xsl:with-param name="parentType" select="$complexType"/>
				<xsl:with-param name="foreignKeysElemet" select="."/>
				<xsl:with-param name="level" select="$level+1"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="ConstructSubquery">
		<xsl:param name="complexType"/>
		<xsl:param name="parentType"/>
		<xsl:param name="foreignKeysElemet"/>
		<xsl:param name="level"/>
		<xsl:variable name="sql-table"><xsl:apply-templates select="$complexType" mode="sql-table"/></xsl:variable>
		<xsl:variable name="foreign-keys"><xsl:apply-templates select="$foreignKeysElemet" mode="foreign-keys"/></xsl:variable>
		<xsl:variable name="key-fields"><xsl:apply-templates select="$parentType" mode="key-fields"/></xsl:variable>
		<xsl:variable name="subqery-join" select="concat($complexType/@name,'.',$foreign-keys,'=',$parentType/@name,'.',$key-fields)"/>
		<axsl:apply-templates select="." mode="indent{$level+1}"/>FROM <xsl:value-of select="$sql-table"/><xsl:text> </xsl:text><xsl:value-of select="$complexType/@name"/>
		<axsl:apply-templates select=".|*|@*" mode="SubTable{$level+1}"/>
		<axsl:apply-templates select="." mode="indent{$level+1}"/>WHERE <xsl:value-of select="$subqery-join"/><xsl:text> </xsl:text><axsl:value-of select="normalize-space($where)"/>
	</xsl:template>

	<xsl:template name="ConstructJoin">
		<xsl:param name="path"/>
		<xsl:param name="thisType"/>
		<xsl:param name="parentType"/>
		<xsl:param name="foreignKeysElemet"/>
		<xsl:param name="level"/>
		<xsl:choose>
			<xsl:when test="$thisType/xs:complexContent/xs:restriction">
				<!-- join restricted table -->
				<xsl:variable name="linkedType" select="key('complexType',$thisType/xs:complexContent/xs:restriction/@base)"/>
				<xsl:variable name="sql-table"><xsl:apply-templates select="$linkedType" mode="sql-table"/></xsl:variable>
				<xsl:variable name="key-fields"><xsl:apply-templates select="$linkedType" mode="key-fields"/></xsl:variable>
				<xsl:variable name="foreign-keys"><xsl:apply-templates select="$foreignKeysElemet" mode="foreign-keys"/></xsl:variable>
				<xsl:variable name="join" select="concat($sql-table,' ',$linkedType/@name,' ON ',$linkedType/@name,'.',$key-fields,'=',$parentType/@name,'.',$foreign-keys)"/>
				<axsl:template match="{substring-after($path,'/')}" mode="SubTable{$level}">
					<axsl:apply-templates select="." mode="indent{$level}"/><axsl:apply-templates select="." mode="JoinType"/> <xsl:value-of select="$join"/>
				</axsl:template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="sql-table"><xsl:apply-templates select="$thisType" mode="sql-table"/></xsl:variable>
				<xsl:variable name="key-fields"><xsl:apply-templates select="$thisType" mode="key-fields"/></xsl:variable>
				<xsl:variable name="foreign-keys"><xsl:apply-templates select="$foreignKeysElemet" mode="foreign-keys"/></xsl:variable>
				<xsl:variable name="join" select="concat($sql-table,' ',$thisType/@name,' ON ',$thisType/@name,'.',$key-fields,'=',$parentType/@name,'.',$foreign-keys)"/>
				<axsl:template match="{substring-after($path,'/')}" mode="SubTable{$level}">
					<axsl:apply-templates select="." mode="indent{$level}"/><axsl:apply-templates select="." mode="JoinType"/> <xsl:value-of select="$join"/>
				</axsl:template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xs:simpleContent" mode="addSelfField">
		<xsl:variable name="complexType" select="ancestor::xs:group|ancestor::xs:complexType[@name]"/>
		<xsl:text>,</xsl:text><xsl:apply-templates select="xs:extension" mode="dataValue"><xsl:with-param name="typename" select="$complexType/@name"/></xsl:apply-templates><xsl:text> AS "*"</xsl:text>
	</xsl:template>

	<xsl:template match="xs:complexType" mode="key-fields">INVALID VALUE</xsl:template>
	<xsl:template match="xs:complexType[xs:attribute[@name='id']]" mode="key-fields">
		<xsl:value-of select="xs:attribute[@name='id']/@sql:field"/>
	</xsl:template>
	<xsl:template match="xs:complexType[xs:attribute[@type='xs:ID']]" mode="key-fields">
		<xsl:value-of select="xs:attribute[@type='xs:ID']/@sql:field"/>
	</xsl:template>
	<xsl:template match="*[@sql:key-fields]" mode="key-fields">
		<xsl:value-of select="@sql:key-fields"/>
	</xsl:template>
	<xsl:template match="*[@sql:foreign-keys]" mode="foreign-keys">
		<xsl:value-of select="@sql:foreign-keys"/>
	</xsl:template>
	<xsl:template match="*[@sql:table]" mode="sql-table">
		<xsl:value-of select="@sql:table"/>
	</xsl:template>

	<!-- =========================================================
	ConstructEementTemplates
	======================================================== -->
	<xsl:template match="xs:element | xs:attribute" mode="ConstructEementTemplates">
		<xsl:param name="path"/>
		<xsl:param name="type"/>
		<xsl:param name="parentType"/>
		<xsl:param name="level"/>
		<xsl:variable name="typename">
			<xsl:choose>
				<xsl:when test="ancestor::xs:group"><xsl:value-of select="ancestor::xs:group/@name"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$parentType/@name"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="spath" select="substring-after($path,'/')"></xsl:variable>
		<xsl:variable name="sqlfield"><xsl:value-of select="@sql:field"/></xsl:variable>
		<xsl:variable name="rpath"><xsl:call-template name="string-remove-namespace"><xsl:with-param name="text" select="$path"/><xsl:with-param name="ns" select="concat($prefix,':')"/></xsl:call-template></xsl:variable>

		<xsl:comment><xsl:value-of select="$path"/></xsl:comment>
		<axsl:template match="{$spath}" mode="alias">"<xsl:apply-templates select="." mode="getname"/>"</axsl:template>
		<axsl:template match="{$spath}" mode="fieldName"><xsl:apply-templates select="." mode="dataValue"><xsl:with-param name="typename" select="$typename"/></xsl:apply-templates></axsl:template>
		<axsl:template match="{$spath}" mode="fieldValue"><xsl:value-of select="concat('@',$typename,'_',$sqlfield)"/></axsl:template>
		<axsl:template match="{$spath}[.!='']" mode="where{$level}"> AND <xsl:value-of select="concat($typename,'.',@sql:field)" />=<xsl:value-of select="concat('@',$typename,'_',$sqlfield)"/></axsl:template>
		<axsl:template match="xqbe:Sort[.='{$rpath}']"><xsl:value-of select="concat(',',$typename,'.',$sqlfield)"/><xsl:text> </xsl:text><axsl:apply-templates select='@type'/></axsl:template>
		<axsl:template match="{$spath}[.!='']" mode="param"><parameter name='{$typename}_{$sqlfield}' type='{$type}'><axsl:value-of select="."/></parameter></axsl:template>
	</xsl:template>

	<xsl:template match="xs:element | xs:attribute | xs:extension" mode="dataValue">
		<xsl:param name="typename"/>
		<xsl:value-of select="concat($typename,'.',@sql:field)" />
	</xsl:template>
	<xsl:template match="xs:element[@sql:prefix] | xs:attribute[@sql:prefix]" mode="dataValue">
		<xsl:param name="typename"/>
		<xsl:value-of select="concat($APOS,@sql:prefix,$APOS,'+convert(varchar,',$typename,'.',@sql:field,')')" />
	</xsl:template>
	<xsl:template match="xs:element[@type='xs:dateTime'] | xs:attribute[@type='xs:dateTime']" mode="dataValue">
		<xsl:param name="typename"/>
		<xsl:value-of select="concat('convert(varchar,',$typename,'.',@sql:field,',126)')"/>
	</xsl:template>
	<xsl:template match="xs:attribute[@fixed]" mode="dataValue">
		<xsl:param name="typename"/>
		<xsl:text>'</xsl:text><xsl:value-of select="@fixed"/><xsl:text>'</xsl:text>
	</xsl:template>

	<!-- =========================================================
	change default Xslt templates to include attributes
	======================================================== -->
	<xsl:template name="ChangeDefaultXsltTemplates">
		<axsl:template match="*|@*" mode="param"><axsl:apply-templates select="*|@*" mode="param"/></axsl:template>
		<axsl:template match="*|@*" mode="select">
			<axsl:variable name="fieldName"><axsl:apply-templates select="." mode="fieldName"/></axsl:variable>
			<axsl:if test="$fieldName!=''">,<axsl:value-of select="$fieldName"/> AS <axsl:apply-templates select="." mode="alias"/></axsl:if>
		</axsl:template>
		<axsl:template match="*|@*" mode="select2">
			<axsl:variable name="fieldName"><axsl:apply-templates select="." mode="fieldName"/></axsl:variable>
			<axsl:if test="$fieldName!=''"><axsl:apply-templates select="." mode="indent2"/>,<axsl:value-of select="$fieldName"/> AS <axsl:apply-templates select="." mode="alias"/></axsl:if>
		</axsl:template>
		<axsl:template match="*|@*" mode="select3">
			<axsl:variable name="fieldName"><axsl:apply-templates select="." mode="fieldName"/></axsl:variable>
			<axsl:if test="$fieldName!=''"><axsl:apply-templates select="." mode="indent3"/>,<axsl:value-of select="$fieldName"/> AS <axsl:apply-templates select="." mode="alias"/></axsl:if>
		</axsl:template>
		<axsl:template match="*|@*" mode="select4">
			<axsl:variable name="fieldName"><axsl:apply-templates select="." mode="fieldName"/></axsl:variable>
			<axsl:if test="$fieldName!=''"><axsl:apply-templates select="." mode="indent4"/>,<axsl:value-of select="$fieldName"/> AS <axsl:apply-templates select="." mode="alias"/></axsl:if>
		</axsl:template>
		<axsl:template match="*|@*" mode="select5">
			<axsl:variable name="fieldName"><axsl:apply-templates select="." mode="fieldName"/></axsl:variable>
			<axsl:if test="$fieldName!=''"><axsl:apply-templates select="." mode="indent5"/>,<axsl:value-of select="$fieldName"/> AS <axsl:apply-templates select="." mode="alias"/></axsl:if>
		</axsl:template>
		<axsl:template match="*|@*" mode="select6">
			<axsl:variable name="fieldName"><axsl:apply-templates select="." mode="fieldName"/></axsl:variable>
			<axsl:if test="$fieldName!=''"><axsl:apply-templates select="." mode="indent6"/>,<axsl:value-of select="$fieldName"/> AS <axsl:apply-templates select="." mode="alias"/></axsl:if>
		</axsl:template>
		<axsl:template match="*|@*" mode="where"><axsl:apply-templates select="*|@*" mode="where"/></axsl:template>
		<!--axsl:template match="*[.!='']|@*[.!='']" mode="where"> AND <axsl:apply-templates select="." mode="fieldName"/>=<axsl:apply-templates select="." mode="fieldValue"/></axsl:template>
		<axsl:template match="*[@xqbe:like]" mode="where"> AND <axsl:apply-templates select="." mode="fieldName"/> LIKE <axsl:apply-templates select="." mode="fieldValue"/></axsl:template>
		<axsl:template match="*[not(text())]" mode="where"><axsl:apply-templates select="*|@*" mode="where"/></axsl:template--><!-- pass empty nodes -->
		<axsl:template match="*[* and text()]" mode="where"><axsl:apply-templates select="*|@*" mode="where"/></axsl:template><!-- pass mixed content (text and tags) -->
		<axsl:template match="*|@*" mode="JoinType">LEFT JOIN </axsl:template>
		<axsl:template match="*[descendant::text()]|@*[descendant::text()]" mode="JoinType">INNER JOIN </axsl:template>
		<axsl:template match="*|@*" mode="SubTable3"/>
		<axsl:template match="*|@*" mode="SubTable4"/>
		<axsl:template match="*|@*" mode="SubTable5"/>
		<axsl:template match="*|@*" mode="SubTable6"/>
		<axsl:template match="*|@*" mode="SubTable7"/>
		<axsl:template match="*|@*" mode="indent1"><axsl:text xml:space="preserve">&#xa;</axsl:text></axsl:template>
		<axsl:template match="*|@*" mode="indent2"><axsl:text xml:space="preserve">&#xa;</axsl:text></axsl:template>
		<axsl:template match="*|@*" mode="indent3"><axsl:text xml:space="preserve">&#xa;&#x9;</axsl:text></axsl:template>
		<axsl:template match="*|@*" mode="indent4"><axsl:text xml:space="preserve">&#xa;&#x9;&#x9;</axsl:text></axsl:template>
		<axsl:template match="*|@*" mode="indent5"><axsl:text xml:space="preserve">&#xa;&#x9;&#x9;&#x9;</axsl:text></axsl:template>
		<axsl:template match="*|@*" mode="indent6"><axsl:text xml:space="preserve">&#xa;&#x9;&#x9;&#x9;&#x9;</axsl:text></axsl:template>
		<axsl:template match="*|@*" mode="indent7"><axsl:text xml:space="preserve">&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;</axsl:text></axsl:template>
	</xsl:template>

	<xsl:template name="SelectTopAndOffsetTemplates">
		<!-- templates for SELECT TOP -->
		<axsl:template match="//xqbe:EnvHeader[xqbe:Page=1 and xqbe:PageSize!='']">	TOP <axsl:value-of select="xqbe:PageSize"/></axsl:template>
		<!-- template for OFFSET -->
		<axsl:template match="//xqbe:EnvHeader[xqbe:Page &gt; 1 and xqbe:PageSize!='']">OFFSET <axsl:value-of select="(number(xqbe:Page) -1) * number(xqbe:PageSize)"/> ROWS FETCH NEXT <axsl:value-of select="xqbe:PageSize"/> ROWS ONLY</axsl:template>
		<axsl:template match="xqbe:Sort/@type[translate(.,'ascde','ASCDE')='ASC' or translate(.,'ascde','ASCDE')='DESC']">
			<axsl:value-of select="."/>
		</axsl:template>
	</xsl:template>

	<!-- =========================================================
	Triggers
	======================================================== -->
	<xsl:template match="sql:trigger" mode="trigger">
		<xsl:variable name="ctype">
			<xsl:choose><xsl:when test="@run='instead'">select</xsl:when><xsl:otherwise>trigger</xsl:otherwise></xsl:choose>
		</xsl:variable>
		<command type="{$ctype}" mode="{@type}">
			<text>
				<axsl:variable name="pars">
					<xsl:for-each select="sql:param">
						<xsl:variable name="pt">
							<xsl:call-template name="add-namespaces-to-path">
								<xsl:with-param name="text" select="@path"/>
							</xsl:call-template>
						</xsl:variable><axsl:apply-templates select="{$pt}" mode="value"/>
					</xsl:for-each>
				</axsl:variable>
				EXEC <xsl:value-of select="@call"/><xsl:text> </xsl:text><axsl:value-of select="substring-after(normalize-space($pars),',')"/>
			</text>
			<parameters>
				<xsl:for-each select="sql:param">
					<xsl:variable name="pt">
						<xsl:call-template name="add-namespaces-to-path">
							<xsl:with-param name="text" select="@path"/>
						</xsl:call-template>
					</xsl:variable>
					<axsl:apply-templates select="{$pt}" mode="param"/>
				</xsl:for-each>
			</parameters>
		</command>
	</xsl:template>

	<!-- =========================================================
	Helper transforms
	======================================================== -->
	<xsl:template match="xs:attribute" mode="getname">
		<xsl:value-of select="concat('@',@name)"/>
	</xsl:template>
	<xsl:template match="xs:element" mode="getname">
		<xsl:value-of select="@name"/>
	</xsl:template>
	
	<xsl:template name="add-namespaces-to-path">
		<xsl:param name="text" />
		<xsl:if test="substring($text,1,1)!='/' and substring($text,1,1)!='@'"><xsl:value-of select="$ns"/></xsl:if>
		<xsl:choose>
			<xsl:when test="contains($text, '/')">
				<xsl:value-of select="substring-before($text,'/')" />
				<xsl:value-of select="'/'"/>
				<xsl:call-template name="add-namespaces-to-path">
					<xsl:with-param name="text" select="substring-after($text,'/')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="string-remove-namespace">
		<xsl:param name="text" />
		<xsl:param name="ns" />
		<xsl:choose>
			<xsl:when test="$text = '' or $ns = '' or not($ns)" >
				<xsl:value-of select="$text" />
			</xsl:when>
			<xsl:when test="contains($text, $ns)">
				<xsl:value-of select="substring-before($text,$ns)" />
				<xsl:call-template name="string-remove-namespace">
					<xsl:with-param name="text" select="substring-after($text,$ns)" />
					<xsl:with-param name="ns" select="$ns" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>