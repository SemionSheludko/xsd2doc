<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xsl xs"
	version="1.0">
<xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>

<xsl:include href="xsd2list.xsl" />

<!--
     Main template that starts the process
-->
<xsl:template match="/">
<!--xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text-->
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>xsd2htm <xsl:value-of select="$prefix"/></title>
		<link href="bootstrap/css/bootstrap.css" rel="stylesheet"/>
		<link href="themes/bootstrap/forms.css" rel="stylesheet"/>
	</head>
	<body>
		<ul class="list-group">
			<xsl:apply-templates select="/xs:schema/xs:element[1]"/>
		</ul>
	</body>
	<link href="css/font-awesome/css/font-awesome.css" rel="stylesheet"/>
	</html>
</xsl:template>

</xsl:stylesheet>

