<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xsl xs"
	version="1.0">
<xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>

<xsl:include href="xsd2htmlDocs.xsl" />

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
		<style>
			.code {
				padding: 5px;
				margin: 0;
				font-family: Consolas,Courier,monospace!important;
				font-style: normal;
				font-weight: normal;
				overflow: auto;
				word-wrap: normal;
				border-left: solid 1px #939393;
				border-bottom: solid 1px #939393;
				border-right: solid 1px #939393;
				border-top: solid 1px #939393;
				clear: both;
				margin-bottom: 12px;
				position: relative;
			}
			.lt {color: Blue;} 
			.tn {color: #A31515; font-weight: bold;}
			.at {color: Red;}
			.av {color: Blue;} 
			.atv {color: Blue;}
			.comment {color: Green;}
			.block {display:block;}
			.i1 {margin-left: 5px;}
			.i2 {margin-left: 20px;}
			.i3 {margin-left: 35px;}
			.i4 {margin-left: 50px;}
			.i5 {margin-left: 65px;}
			.i6 {margin-left: 80px;}
		</style>
	</head>
	<body>
		<div class="container">
			<div class="code">
				<xsl:apply-templates select="/xs:schema/xs:element[1]"/>
			</div>
		</div>
	</body>
	<link href="css/font-awesome/css/font-awesome.css" rel="stylesheet"/>
	</html>
</xsl:template>

</xsl:stylesheet>

