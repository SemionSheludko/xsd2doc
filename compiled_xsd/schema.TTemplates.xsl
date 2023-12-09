<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="SOAP-ENV xqbe" version="1.0" ns:usedForNSOutput="" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xqbe="http://abcmf.net/schema/xqbe/v1" xmlns:ns="http://ab.report/schema/v1">
	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/">
		<xsl:if test="not(SOAP-ENV:Envelope)">
			<xsl:message terminate="yes">XMLSQL: 101: Invalid request,	SOAP-ENV:Envelope required</xsl:message>
		</xsl:if>
		<commands>
			<xsl:apply-templates select="SOAP-ENV:Envelope/SOAP-ENV:Header"/>
		</commands>
	</xsl:template>
	<xsl:template match="//SOAP-ENV:Header">
		<xsl:variable name="method" select="translate(xqbe:EnvHeader/xqbe:Method, 'infogetpsdl', 'INFOGETPSDL')"/>
		<xsl:choose>
			<xsl:when test="$method = ''">
				<xsl:message terminate="yes">XMLSQL: 102: xqbe:EnvHeader/xqbe:Method reqired</xsl:message>
			</xsl:when>
			<xsl:when test="$method = 'GET' or $method = 'INFO'">
				<xsl:apply-templates select="../SOAP-ENV:Body" mode="get"/>
			</xsl:when>
			<xsl:when test="$method = 'POST'">
				<xsl:apply-templates select="../SOAP-ENV:Body" mode="post"/>
			</xsl:when>
			<xsl:when test="$method = 'DELETE'">
				<xsl:apply-templates select="../SOAP-ENV:Body" mode="delete"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="../SOAP-ENV:Body" mode="appinfo"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="SOAP-ENV:Body" mode="get">
		<command type="select" namespace="http://ab.report/schema/v1">
			<text>
				<xsl:apply-templates select="ns:TTemplates/ns:TTemplate" mode="query"/>
			</text>
			<parameters>
				<xsl:apply-templates select="*|@*" mode="param"/>
			</parameters>
		</command>
	</xsl:template>
	<xsl:template match="//SOAP-ENV:Body" mode="post">
		<xsl:apply-templates select="ns:TTemplates/ns:TTemplate" mode="post"/>
	</xsl:template>
	<xsl:template match="//SOAP-ENV:Body" mode="delete">
		<xsl:apply-templates select="ns:TTemplates/ns:TTemplate" mode="delete"/>
	</xsl:template>
	<xsl:template match="//SOAP-ENV:Body" mode="appinfo"></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate (level 2)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate" mode="query">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select3"/></xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where3"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent1"/>WITH XMLNAMESPACES (DEFAULT 'http://ab.report/schema/v1')<xsl:apply-templates select="." mode="indent1"/>SELECT <xsl:apply-templates select="//xqbe:EnvHeader[xqbe:Page=1 and xqbe:PageSize!='']"/>
		<xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent1"/>FROM transaction_templates TTemplateType<xsl:apply-templates select="*" mode="SubTable3"/>
		<xsl:if test="normalize-space($where)!=''">
			<xsl:apply-templates select="." mode="indent1"/>WHERE <xsl:value-of select="substring-after(normalize-space($where),'AND')"/>
		</xsl:if>
		<xsl:variable name="sort">
			<xsl:apply-templates select="//xqbe:EnvHeader/xqbe:Sort"/>
		</xsl:variable>
		<xsl:if test="$sort!=''">
			<xsl:apply-templates select="." mode="indent1"/>ORDER BY <xsl:value-of select="substring-after($sort,',')"/><xsl:text xml:space="preserve"> </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="." mode="indent1"/><xsl:apply-templates select="//xqbe:EnvHeader[xqbe:Page &gt; 1 and xqbe:PageSize!='']"/>
		<xsl:apply-templates select="." mode="indent1"/>FOR XML PATH('TTemplate'), ROOT('TTemplates')
		</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/@id-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/@id" mode="alias">"@id"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@id" mode="fieldName">TTemplateType.tt_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@id" mode="fieldValue">@TTemplateType_tt_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@id[.!='']" mode="where3"> AND TTemplateType.tt_id=@TTemplateType_tt_id</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/@id']">,TTemplateType.tt_id <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@id[.!='']" mode="param"><parameter name="TTemplateType_tt_id" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/@code-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/@code" mode="alias">"@code"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@code" mode="fieldName">TTemplateType.tt_code</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@code" mode="fieldValue">@TTemplateType_tt_code</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@code[.!='']" mode="where3"> AND TTemplateType.tt_code=@TTemplateType_tt_code</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/@code']">,TTemplateType.tt_code <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@code[.!='']" mode="param"><parameter name="TTemplateType_tt_code" type="xs:unsignedShort"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/@type-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/@type" mode="alias">"@type"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@type" mode="fieldName">TTemplateType.tt_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@type" mode="fieldValue">@TTemplateType_tt_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@type[.!='']" mode="where3"> AND TTemplateType.tt_type=@TTemplateType_tt_type</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/@type']">,TTemplateType.tt_type <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/@type[.!='']" mode="param"><parameter name="TTemplateType_tt_type" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Name (level 3)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Name[@*|*]" mode="select3">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select4"/>,TTNames.tt_name AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where4"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent3"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent4"/>FROM transaction_templates_names TTNames<xsl:apply-templates select=".|*|@*" mode="SubTable4"/>
		<xsl:apply-templates select="." mode="indent4"/>WHERE TTNames.tt_id=TTemplateType.tt_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent4"/>FOR XML PATH('Name'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Name/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Name/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Name/@lang" mode="fieldName">TTNames.tt_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Name/@lang" mode="fieldValue">@TTNames_tt_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Name/@lang[.!='']" mode="where4"> AND TTNames.tt_lang=@TTNames_tt_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Name/@lang']">,TTNames.tt_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Name/@lang[.!='']" mode="param"><parameter name="TTNames_tt_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Description (level 3)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Description[@*|*]" mode="select3">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select4"/>,TTNames.tt_descr AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where4"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent3"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent4"/>FROM transaction_templates_names TTNames<xsl:apply-templates select=".|*|@*" mode="SubTable4"/>
		<xsl:apply-templates select="." mode="indent4"/>WHERE TTNames.tt_id=TTemplateType.tt_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent4"/>FOR XML PATH('Description'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Description/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Description/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Description/@lang" mode="fieldName">TTNames.tt_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Description/@lang" mode="fieldValue">@TTNames_tt_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Description/@lang[.!='']" mode="where4"> AND TTNames.tt_lang=@TTNames_tt_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Description/@lang']">,TTNames.tt_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Description/@lang[.!='']" mode="param"><parameter name="TTNames_tt_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Category (level 3)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category[@*|*]" mode="select3">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select4"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where4"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent3"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent4"/>FOR XML PATH('Category'), type)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category" mode="SubTable3">
		<xsl:apply-templates select="." mode="indent3"/><xsl:apply-templates select="." mode="JoinType"/>transaction_categories TCategoryType ON TCategoryType.tc_id=TTemplateType.tc_id</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Category/@id-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/@id" mode="alias">"@id"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/@id" mode="fieldName">TCategoryType.tc_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/@id" mode="fieldValue">@TCategoryType_tc_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/@id[.!='']" mode="where4"> AND TCategoryType.tc_id=@TCategoryType_tc_id</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Category/@id']">,TCategoryType.tc_id <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/@id[.!='']" mode="param"><parameter name="TCategoryType_tc_id" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Category/@type-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/@type" mode="alias">"@type"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/@type" mode="fieldName">TCategoryType.tc_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/@type" mode="fieldValue">@TCategoryType_tc_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/@type[.!='']" mode="where4"> AND TCategoryType.tc_type=@TCategoryType_tc_type</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Category/@type']">,TCategoryType.tc_type <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/@type[.!='']" mode="param"><parameter name="TCategoryType_tc_type" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Category/ns:Name (level 4)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Name[@*|*]" mode="select4">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select5"/>,TCategoryNames.tc_name AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where5"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent4"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent5"/>FROM transaction_categories_names TCategoryNames<xsl:apply-templates select=".|*|@*" mode="SubTable5"/>
		<xsl:apply-templates select="." mode="indent5"/>WHERE TCategoryNames.tc_id=TCategoryType.tc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent5"/>FOR XML PATH('Name'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Category/ns:Name/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Name/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Name/@lang" mode="fieldName">TCategoryNames.tc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Name/@lang" mode="fieldValue">@TCategoryNames_tc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Name/@lang[.!='']" mode="where5"> AND TCategoryNames.tc_lang=@TCategoryNames_tc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Category/Name/@lang']">,TCategoryNames.tc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Name/@lang[.!='']" mode="param"><parameter name="TCategoryNames_tc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Category/ns:Description (level 4)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Description[@*|*]" mode="select4">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select5"/>,TCategoryNames. AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where5"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent4"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent5"/>FROM transaction_categories_names TCategoryNames<xsl:apply-templates select=".|*|@*" mode="SubTable5"/>
		<xsl:apply-templates select="." mode="indent5"/>WHERE TCategoryNames.tc_id=TCategoryType.tc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent5"/>FOR XML PATH('Description'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Category/ns:Description/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Description/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Description/@lang" mode="fieldName">TCategoryNames.tc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Description/@lang" mode="fieldValue">@TCategoryNames_tc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Description/@lang[.!='']" mode="where5"> AND TCategoryNames.tc_lang=@TCategoryNames_tc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Category/Description/@lang']">,TCategoryNames.tc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Category/ns:Description/@lang[.!='']" mode="param"><parameter name="TCategoryNames_tc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items (level 3)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items[@*|*]" mode="select3">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select4"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where4"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent3"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent4"/>FOR XML PATH('Items'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item (level 4)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item[@*|*]" mode="select4">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select5"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where5"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent4"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent5"/>FROM transaction_templates_entries TItemType<xsl:apply-templates select=".|*|@*" mode="SubTable5"/>
		<xsl:apply-templates select="." mode="indent5"/>WHERE TItemType.tt_id=TTemplateType.tt_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent5"/>FOR XML PATH('Item'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@id-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@id" mode="alias">"@id"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@id" mode="fieldName">TItemType.te_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@id" mode="fieldValue">@TItemType_te_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@id[.!='']" mode="where5"> AND TItemType.te_id=@TItemType_te_id</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/@id']">,TItemType.te_id <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@id[.!='']" mode="param"><parameter name="TItemType_te_id" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@type-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@type" mode="alias">"@type"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@type" mode="fieldName">TItemType.te_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@type" mode="fieldValue">@TItemType_te_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@type[.!='']" mode="where5"> AND TItemType.te_type=@TItemType_te_type</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/@type']">,TItemType.te_type <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/@type[.!='']" mode="param"><parameter name="TItemType_te_type" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account (level 5)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account[@*|*]" mode="select5">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select6"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where6"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent5"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent6"/>FOR XML PATH('Account'), type)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account" mode="SubTable5">
		<xsl:apply-templates select="." mode="indent5"/><xsl:apply-templates select="." mode="JoinType"/>accounts AccountType ON AccountType.acc_id=TItemType.acc_id</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@id-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@id" mode="alias">"@id"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@id" mode="fieldName">'A'+convert(varchar,AccountType.acc_id)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@id" mode="fieldValue">@AccountType_acc_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@id[.!='']" mode="where6"> AND AccountType.acc_id=@AccountType_acc_id</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/@id']">,AccountType.acc_id <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@id[.!='']" mode="param"><parameter name="AccountType_acc_id" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@under-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@under" mode="alias">"@under"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@under" mode="fieldName">AccountType.acc_under</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@under" mode="fieldValue">@AccountType_acc_under</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@under[.!='']" mode="where6"> AND AccountType.acc_under=@AccountType_acc_under</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/@under']">,AccountType.acc_under <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@under[.!='']" mode="param"><parameter name="AccountType_acc_under" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@code-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@code" mode="alias">"@code"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@code" mode="fieldName">AccountType.acc_code</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@code" mode="fieldValue">@AccountType_acc_code</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@code[.!='']" mode="where6"> AND AccountType.acc_code=@AccountType_acc_code</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/@code']">,AccountType.acc_code <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@code[.!='']" mode="param"><parameter name="AccountType_acc_code" type="xs:unsignedShort"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@status-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@status" mode="alias">"@status"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@status" mode="fieldName">AccountType.acc_status</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@status" mode="fieldValue">@AccountType_acc_status</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@status[.!='']" mode="where6"> AND AccountType.acc_status=@AccountType_acc_status</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/@status']">,AccountType.acc_status <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@status[.!='']" mode="param"><parameter name="AccountType_acc_status" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@type-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@type" mode="alias">"@type"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@type" mode="fieldName">AccountType.acc_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@type" mode="fieldValue">@AccountType_acc_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@type[.!='']" mode="where6"> AND AccountType.acc_type=@AccountType_acc_type</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/@type']">,AccountType.acc_type <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@type[.!='']" mode="param"><parameter name="AccountType_acc_type" type="xs:token"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@pltype-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@pltype" mode="alias">"@pltype"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@pltype" mode="fieldName">AccountType.acc_pl</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@pltype" mode="fieldValue">@AccountType_acc_pl</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@pltype[.!='']" mode="where6"> AND AccountType.acc_pl=@AccountType_acc_pl</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/@pltype']">,AccountType.acc_pl <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@pltype[.!='']" mode="param"><parameter name="AccountType_acc_pl" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@skipzero-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@skipzero" mode="alias">"@skipzero"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@skipzero" mode="fieldName">AccountType.acc_skipzero</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@skipzero" mode="fieldValue">@AccountType_acc_skipzero</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@skipzero[.!='']" mode="where6"> AND AccountType.acc_skipzero=@AccountType_acc_skipzero</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/@skipzero']">,AccountType.acc_skipzero <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/@skipzero[.!='']" mode="param"><parameter name="AccountType_acc_skipzero" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Name (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Name[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels.acc_name AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Name'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Name/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Name/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Name/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Name/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Name/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/Name/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Name/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Description (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Description[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels. AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Description'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Description/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Description/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Description/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Description/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Description/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/Description/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Description/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:DrFriendlyName (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:DrFriendlyName[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels. AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('DrFriendlyName'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:DrFriendlyName/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:DrFriendlyName/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:DrFriendlyName/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:DrFriendlyName/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:DrFriendlyName/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/DrFriendlyName/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:DrFriendlyName/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:CrFriendlyName (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:CrFriendlyName[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels. AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('CrFriendlyName'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:CrFriendlyName/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:CrFriendlyName/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:CrFriendlyName/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:CrFriendlyName/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:CrFriendlyName/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/CrFriendlyName/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:CrFriendlyName/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Currency (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Currency[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Currency'), type)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Currency" mode="SubTable6">
		<xsl:apply-templates select="." mode="indent6"/><xsl:apply-templates select="." mode="JoinType"/>  ON .=AccountType.cur_id</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Changes (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Changes[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Changes'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Changes/ns:Date-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Changes/ns:Date" mode="alias">"Date"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Changes/ns:Date" mode="fieldName">convert(varchar,AccountType.acc_changedate,126)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Changes/ns:Date" mode="fieldValue">@AccountType_acc_changedate</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Changes/ns:Date[.!='']" mode="where7"> AND AccountType.acc_changedate=@AccountType_acc_changedate</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Account/Changes/Date']">,AccountType.acc_changedate <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Account/ns:Changes/ns:Date[.!='']" mode="param"><parameter name="AccountType_acc_changedate" type="xs:dateTime"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL (level 5)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL[@*|*]" mode="select5">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select6"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where6"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent5"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent6"/>FOR XML PATH('PL'), type)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL" mode="SubTable5">
		<xsl:apply-templates select="." mode="indent5"/><xsl:apply-templates select="." mode="JoinType"/>accounts AccountType ON AccountType.acc_id=TItemType.acc_pl</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@id-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@id" mode="alias">"@id"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@id" mode="fieldName">'A'+convert(varchar,AccountType.acc_id)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@id" mode="fieldValue">@AccountType_acc_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@id[.!='']" mode="where6"> AND AccountType.acc_id=@AccountType_acc_id</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/@id']">,AccountType.acc_id <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@id[.!='']" mode="param"><parameter name="AccountType_acc_id" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@under-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@under" mode="alias">"@under"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@under" mode="fieldName">AccountType.acc_under</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@under" mode="fieldValue">@AccountType_acc_under</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@under[.!='']" mode="where6"> AND AccountType.acc_under=@AccountType_acc_under</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/@under']">,AccountType.acc_under <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@under[.!='']" mode="param"><parameter name="AccountType_acc_under" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@code-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@code" mode="alias">"@code"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@code" mode="fieldName">AccountType.acc_code</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@code" mode="fieldValue">@AccountType_acc_code</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@code[.!='']" mode="where6"> AND AccountType.acc_code=@AccountType_acc_code</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/@code']">,AccountType.acc_code <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@code[.!='']" mode="param"><parameter name="AccountType_acc_code" type="xs:unsignedShort"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@status-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@status" mode="alias">"@status"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@status" mode="fieldName">AccountType.acc_status</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@status" mode="fieldValue">@AccountType_acc_status</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@status[.!='']" mode="where6"> AND AccountType.acc_status=@AccountType_acc_status</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/@status']">,AccountType.acc_status <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@status[.!='']" mode="param"><parameter name="AccountType_acc_status" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@type-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@type" mode="alias">"@type"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@type" mode="fieldName">AccountType.acc_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@type" mode="fieldValue">@AccountType_acc_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@type[.!='']" mode="where6"> AND AccountType.acc_type=@AccountType_acc_type</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/@type']">,AccountType.acc_type <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@type[.!='']" mode="param"><parameter name="AccountType_acc_type" type="xs:token"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@pltype-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@pltype" mode="alias">"@pltype"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@pltype" mode="fieldName">AccountType.acc_pl</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@pltype" mode="fieldValue">@AccountType_acc_pl</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@pltype[.!='']" mode="where6"> AND AccountType.acc_pl=@AccountType_acc_pl</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/@pltype']">,AccountType.acc_pl <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@pltype[.!='']" mode="param"><parameter name="AccountType_acc_pl" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@skipzero-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@skipzero" mode="alias">"@skipzero"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@skipzero" mode="fieldName">AccountType.acc_skipzero</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@skipzero" mode="fieldValue">@AccountType_acc_skipzero</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@skipzero[.!='']" mode="where6"> AND AccountType.acc_skipzero=@AccountType_acc_skipzero</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/@skipzero']">,AccountType.acc_skipzero <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/@skipzero[.!='']" mode="param"><parameter name="AccountType_acc_skipzero" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Name (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Name[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels.acc_name AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Name'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Name/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Name/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Name/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Name/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Name/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/Name/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Name/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Description (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Description[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels. AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Description'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Description/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Description/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Description/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Description/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Description/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/Description/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Description/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:DrFriendlyName (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:DrFriendlyName[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels. AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('DrFriendlyName'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:DrFriendlyName/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:DrFriendlyName/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:DrFriendlyName/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:DrFriendlyName/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:DrFriendlyName/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/DrFriendlyName/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:DrFriendlyName/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:CrFriendlyName (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:CrFriendlyName[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels. AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('CrFriendlyName'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:CrFriendlyName/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:CrFriendlyName/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:CrFriendlyName/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:CrFriendlyName/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:CrFriendlyName/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/CrFriendlyName/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:CrFriendlyName/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Currency (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Currency[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Currency'), type)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Currency" mode="SubTable6">
		<xsl:apply-templates select="." mode="indent6"/><xsl:apply-templates select="." mode="JoinType"/>  ON .=AccountType.cur_id</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Changes (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Changes[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Changes'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Changes/ns:Date-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Changes/ns:Date" mode="alias">"Date"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Changes/ns:Date" mode="fieldName">convert(varchar,AccountType.acc_changedate,126)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Changes/ns:Date" mode="fieldValue">@AccountType_acc_changedate</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Changes/ns:Date[.!='']" mode="where7"> AND AccountType.acc_changedate=@AccountType_acc_changedate</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/PL/Changes/Date']">,AccountType.acc_changedate <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:PL/ns:Changes/ns:Date[.!='']" mode="param"><parameter name="AccountType_acc_changedate" type="xs:dateTime"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF (level 5)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF[@*|*]" mode="select5">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select6"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where6"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent5"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent6"/>FOR XML PATH('CF'), type)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF" mode="SubTable5">
		<xsl:apply-templates select="." mode="indent5"/><xsl:apply-templates select="." mode="JoinType"/>accounts AccountType ON AccountType.acc_id=TItemType.acc_cf</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@id-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@id" mode="alias">"@id"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@id" mode="fieldName">'A'+convert(varchar,AccountType.acc_id)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@id" mode="fieldValue">@AccountType_acc_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@id[.!='']" mode="where6"> AND AccountType.acc_id=@AccountType_acc_id</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/@id']">,AccountType.acc_id <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@id[.!='']" mode="param"><parameter name="AccountType_acc_id" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@under-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@under" mode="alias">"@under"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@under" mode="fieldName">AccountType.acc_under</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@under" mode="fieldValue">@AccountType_acc_under</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@under[.!='']" mode="where6"> AND AccountType.acc_under=@AccountType_acc_under</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/@under']">,AccountType.acc_under <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@under[.!='']" mode="param"><parameter name="AccountType_acc_under" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@code-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@code" mode="alias">"@code"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@code" mode="fieldName">AccountType.acc_code</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@code" mode="fieldValue">@AccountType_acc_code</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@code[.!='']" mode="where6"> AND AccountType.acc_code=@AccountType_acc_code</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/@code']">,AccountType.acc_code <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@code[.!='']" mode="param"><parameter name="AccountType_acc_code" type="xs:unsignedShort"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@status-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@status" mode="alias">"@status"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@status" mode="fieldName">AccountType.acc_status</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@status" mode="fieldValue">@AccountType_acc_status</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@status[.!='']" mode="where6"> AND AccountType.acc_status=@AccountType_acc_status</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/@status']">,AccountType.acc_status <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@status[.!='']" mode="param"><parameter name="AccountType_acc_status" type="xs:unsignedByte"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@type-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@type" mode="alias">"@type"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@type" mode="fieldName">AccountType.acc_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@type" mode="fieldValue">@AccountType_acc_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@type[.!='']" mode="where6"> AND AccountType.acc_type=@AccountType_acc_type</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/@type']">,AccountType.acc_type <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@type[.!='']" mode="param"><parameter name="AccountType_acc_type" type="xs:token"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@pltype-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@pltype" mode="alias">"@pltype"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@pltype" mode="fieldName">AccountType.acc_pl</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@pltype" mode="fieldValue">@AccountType_acc_pl</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@pltype[.!='']" mode="where6"> AND AccountType.acc_pl=@AccountType_acc_pl</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/@pltype']">,AccountType.acc_pl <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@pltype[.!='']" mode="param"><parameter name="AccountType_acc_pl" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@skipzero-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@skipzero" mode="alias">"@skipzero"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@skipzero" mode="fieldName">AccountType.acc_skipzero</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@skipzero" mode="fieldValue">@AccountType_acc_skipzero</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@skipzero[.!='']" mode="where6"> AND AccountType.acc_skipzero=@AccountType_acc_skipzero</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/@skipzero']">,AccountType.acc_skipzero <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/@skipzero[.!='']" mode="param"><parameter name="AccountType_acc_skipzero" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Name (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Name[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels.acc_name AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Name'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Name/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Name/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Name/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Name/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Name/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/Name/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Name/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Description (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Description[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels. AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Description'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Description/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Description/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Description/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Description/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Description/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/Description/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Description/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:DrFriendlyName (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:DrFriendlyName[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels. AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('DrFriendlyName'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:DrFriendlyName/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:DrFriendlyName/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:DrFriendlyName/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:DrFriendlyName/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:DrFriendlyName/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/DrFriendlyName/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:DrFriendlyName/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:CrFriendlyName (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:CrFriendlyName[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>,AccLabels. AS "*"</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FROM accountslocales AccLabels<xsl:apply-templates select=".|*|@*" mode="SubTable7"/>
		<xsl:apply-templates select="." mode="indent7"/>WHERE AccLabels.acc_id=AccountType.acc_id <xsl:value-of select="normalize-space($where)"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('CrFriendlyName'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:CrFriendlyName/@lang-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:CrFriendlyName/@lang" mode="alias">"@lang"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:CrFriendlyName/@lang" mode="fieldName">AccLabels.acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:CrFriendlyName/@lang" mode="fieldValue">@AccLabels_acc_lang</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:CrFriendlyName/@lang[.!='']" mode="where7"> AND AccLabels.acc_lang=@AccLabels_acc_lang</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/CrFriendlyName/@lang']">,AccLabels.acc_lang <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:CrFriendlyName/@lang[.!='']" mode="param"><parameter name="AccLabels_acc_lang" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Currency (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Currency[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Currency'), type)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Currency" mode="SubTable6">
		<xsl:apply-templates select="." mode="indent6"/><xsl:apply-templates select="." mode="JoinType"/>  ON .=AccountType.cur_id</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Changes (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Changes[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Changes'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Changes/ns:Date-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Changes/ns:Date" mode="alias">"Date"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Changes/ns:Date" mode="fieldName">convert(varchar,AccountType.acc_changedate,126)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Changes/ns:Date" mode="fieldValue">@AccountType_acc_changedate</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Changes/ns:Date[.!='']" mode="where7"> AND AccountType.acc_changedate=@AccountType_acc_changedate</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/CF/Changes/Date']">,AccountType.acc_changedate <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:CF/ns:Changes/ns:Date[.!='']" mode="param"><parameter name="AccountType_acc_changedate" type="xs:dateTime"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:An (level 5)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:An[@*|*]" mode="select5">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select6"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where6"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent5"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent6"/>FOR XML PATH('An'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:An/@code-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:An/@code" mode="alias">"@code"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:An/@code" mode="fieldName">TItemType.te_an</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:An/@code" mode="fieldValue">@TItemType_te_an</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:An/@code[.!='']" mode="where6"> AND TItemType.te_an=@TItemType_te_an</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/An/@code']">,TItemType.te_an <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:An/@code[.!='']" mode="param"><parameter name="TItemType_te_an" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount (level 5)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount[@*|*]" mode="select5">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select6"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where6"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent5"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent6"/>FOR XML PATH('Amount'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@type-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@type" mode="alias">"@type"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@type" mode="fieldName">TItemType.te_sum_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@type" mode="fieldValue">@TItemType_te_sum_type</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@type[.!='']" mode="where6"> AND TItemType.te_sum_type=@TItemType_te_sum_type</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Amount/@type']">,TItemType.te_sum_type <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@type[.!='']" mode="param"><parameter name="TItemType_te_sum_type" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@ratio-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@ratio" mode="alias">"@ratio"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@ratio" mode="fieldName">TItemType.te_sum_ratio</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@ratio" mode="fieldValue">@TItemType_te_sum_ratio</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@ratio[.!='']" mode="where6"> AND TItemType.te_sum_ratio=@TItemType_te_sum_ratio</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Amount/@ratio']">,TItemType.te_sum_ratio <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@ratio[.!='']" mode="param"><parameter name="TItemType_te_sum_ratio" type="xs:decimal"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@code-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@code" mode="alias">"@code"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@code" mode="fieldName">TItemType.te_sum_code</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@code" mode="fieldValue">@TItemType_te_sum_code</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@code[.!='']" mode="where6"> AND TItemType.te_sum_code=@TItemType_te_sum_code</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Amount/@code']">,TItemType.te_sum_code <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/@code[.!='']" mode="param"><parameter name="TItemType_te_sum_code" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/ns:Account (level 6)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/ns:Account[@*|*]" mode="select6">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select7"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where7"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent6"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent7"/>FOR XML PATH('Account'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/ns:Account/@id-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/ns:Account/@id" mode="alias">"@id"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/ns:Account/@id" mode="fieldName">TItemType.te_sum_acc_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/ns:Account/@id" mode="fieldValue">@TItemType_te_sum_acc_id</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/ns:Account/@id[.!='']" mode="where7"> AND TItemType.te_sum_acc_id=@TItemType_te_sum_acc_id</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Amount/Account/@id']">,TItemType.te_sum_acc_id <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Amount/ns:Account/@id[.!='']" mode="param"><parameter name="TItemType_te_sum_acc_id" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Comment-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Comment" mode="alias">"Comment"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Comment" mode="fieldName">TItemType.te_comment</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Comment" mode="fieldValue">@TItemType_te_comment</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Comment[.!='']" mode="where5"> AND TItemType.te_comment=@TItemType_te_comment</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Items/Item/Comment']">,TItemType.te_comment <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Items/ns:Item/ns:Comment[.!='']" mode="param"><parameter name="TItemType_te_comment" type="xs:string"><xsl:value-of select="."/></parameter></xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Changes (level 3)-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Changes[@*|*]" mode="select3">
		<xsl:variable name="fields"><xsl:apply-templates select="*|@*" mode="select4"/>
		</xsl:variable>
		<xsl:variable name="where"><xsl:apply-templates select="*|@*" mode="where4"/></xsl:variable>
		<xsl:apply-templates select="." mode="indent3"/>,(SELECT <xsl:value-of select="substring-after($fields,',')"/>
		<xsl:apply-templates select="." mode="indent4"/>FOR XML PATH('Changes'), type)</xsl:template>
	<!--/ns:TTemplates/ns:TTemplate/ns:Changes/ns:Date-->
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Changes/ns:Date" mode="alias">"Date"</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Changes/ns:Date" mode="fieldName">convert(varchar,TTemplateType.tt_changedate,126)</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Changes/ns:Date" mode="fieldValue">@TTemplateType_tt_changedate</xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Changes/ns:Date[.!='']" mode="where4"> AND TTemplateType.tt_changedate=@TTemplateType_tt_changedate</xsl:template>
	<xsl:template match="xqbe:Sort[.='/TTemplates/TTemplate/Changes/Date']">,TTemplateType.tt_changedate <xsl:apply-templates select="@type"/></xsl:template>
	<xsl:template match="ns:TTemplates/ns:TTemplate/ns:Changes/ns:Date[.!='']" mode="param"><parameter name="TTemplateType_tt_changedate" type="xs:dateTime"><xsl:value-of select="."/></parameter></xsl:template>
	<xsl:template match="*|@*" mode="param"><xsl:apply-templates select="*|@*" mode="param"/></xsl:template>
	<xsl:template match="*|@*" mode="select">
		<xsl:variable name="fieldName"><xsl:apply-templates select="." mode="fieldName"/></xsl:variable>
		<xsl:if test="$fieldName!=''">,<xsl:value-of select="$fieldName"/> AS <xsl:apply-templates select="." mode="alias"/></xsl:if>
	</xsl:template>
	<xsl:template match="*|@*" mode="select2">
		<xsl:variable name="fieldName"><xsl:apply-templates select="." mode="fieldName"/></xsl:variable>
		<xsl:if test="$fieldName!=''"><xsl:apply-templates select="." mode="indent2"/>,<xsl:value-of select="$fieldName"/> AS <xsl:apply-templates select="." mode="alias"/></xsl:if>
	</xsl:template>
	<xsl:template match="*|@*" mode="select3">
		<xsl:variable name="fieldName"><xsl:apply-templates select="." mode="fieldName"/></xsl:variable>
		<xsl:if test="$fieldName!=''"><xsl:apply-templates select="." mode="indent3"/>,<xsl:value-of select="$fieldName"/> AS <xsl:apply-templates select="." mode="alias"/></xsl:if>
	</xsl:template>
	<xsl:template match="*|@*" mode="select4">
		<xsl:variable name="fieldName"><xsl:apply-templates select="." mode="fieldName"/></xsl:variable>
		<xsl:if test="$fieldName!=''"><xsl:apply-templates select="." mode="indent4"/>,<xsl:value-of select="$fieldName"/> AS <xsl:apply-templates select="." mode="alias"/></xsl:if>
	</xsl:template>
	<xsl:template match="*|@*" mode="select5">
		<xsl:variable name="fieldName"><xsl:apply-templates select="." mode="fieldName"/></xsl:variable>
		<xsl:if test="$fieldName!=''"><xsl:apply-templates select="." mode="indent5"/>,<xsl:value-of select="$fieldName"/> AS <xsl:apply-templates select="." mode="alias"/></xsl:if>
	</xsl:template>
	<xsl:template match="*|@*" mode="select6">
		<xsl:variable name="fieldName"><xsl:apply-templates select="." mode="fieldName"/></xsl:variable>
		<xsl:if test="$fieldName!=''"><xsl:apply-templates select="." mode="indent6"/>,<xsl:value-of select="$fieldName"/> AS <xsl:apply-templates select="." mode="alias"/></xsl:if>
	</xsl:template>
	<xsl:template match="*|@*" mode="where"><xsl:apply-templates select="*|@*" mode="where"/></xsl:template>
	<xsl:template match="*[* and text()]" mode="where"><xsl:apply-templates select="*|@*" mode="where"/></xsl:template>
	<xsl:template match="*|@*" mode="JoinType">LEFT JOIN </xsl:template>
	<xsl:template match="*[descendant::text()]|@*[descendant::text()]" mode="JoinType">INNER JOIN </xsl:template>
	<xsl:template match="*|@*" mode="SubTable3"/>
	<xsl:template match="*|@*" mode="SubTable4"/>
	<xsl:template match="*|@*" mode="SubTable5"/>
	<xsl:template match="*|@*" mode="SubTable6"/>
	<xsl:template match="*|@*" mode="SubTable7"/>
	<xsl:template match="*|@*" mode="indent1"><xsl:text xml:space="preserve">
</xsl:text></xsl:template>
	<xsl:template match="*|@*" mode="indent2"><xsl:text xml:space="preserve">
</xsl:text></xsl:template>
	<xsl:template match="*|@*" mode="indent3"><xsl:text xml:space="preserve">
	</xsl:text></xsl:template>
	<xsl:template match="*|@*" mode="indent4"><xsl:text xml:space="preserve">
		</xsl:text></xsl:template>
	<xsl:template match="*|@*" mode="indent5"><xsl:text xml:space="preserve">
			</xsl:text></xsl:template>
	<xsl:template match="*|@*" mode="indent6"><xsl:text xml:space="preserve">
				</xsl:text></xsl:template>
	<xsl:template match="*|@*" mode="indent7"><xsl:text xml:space="preserve">
					</xsl:text></xsl:template>
	<xsl:template match="//xqbe:EnvHeader[xqbe:Page=1 and xqbe:PageSize!='']">	TOP <xsl:value-of select="xqbe:PageSize"/></xsl:template>
	<xsl:template match="//xqbe:EnvHeader[xqbe:Page &gt; 1 and xqbe:PageSize!='']">OFFSET <xsl:value-of select="(number(xqbe:Page) -1) * number(xqbe:PageSize)"/> ROWS FETCH NEXT <xsl:value-of select="xqbe:PageSize"/> ROWS ONLY</xsl:template>
	<xsl:template match="xqbe:Sort/@type[translate(.,'ascde','ASCDE')='ASC' or translate(.,'ascde','ASCDE')='DESC']">
		<xsl:value-of select="."/>
	</xsl:template>
	<xsl:template match="text()|@*"/>
</xsl:stylesheet>
