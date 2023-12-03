<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xsl xs"
	version="1.0">
<xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>

<xsl:include href="xsd2xhtmlForm.xsl" />

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
		<div class="container">
			<form class="form-horizontal validate-form">
				<div class="panel panel-default">
					<div class="panel-heading">
						<h1><xsl:apply-templates select="/xs:schema/xs:element[1]" mode="header"/></h1>
					</div>
					<div class="panel-body">
						<xsl:apply-templates select="/xs:schema/xs:element[1]"/>
					</div>
					<div class="panel-footer">
						<div class="alert alert-danger" style="display:none"></div>
						<div class="btn-toolbar">
							<button id="edit-form-submit" type="submit" class="btn btn-primary" title="Save">
								<i class="fa fa-check"></i><span>Submit</span></button>
							<button id="form-back" type="button" class="btn btn-back" onclick="history.go(-1)">
								<i class="fa fa-arrow-left"></i><span class="hidden-xs">Cancel</span></button>
						</div>
					</div>
				</div>
			</form>
		</div>
	</body>
	<link href="css/font-awesome/css/font-awesome.css" rel="stylesheet"/>
	<script type="text/javascript" src="js/jquery.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.validator.js"></script>
	<script type="text/javascript" src="js/typeahead.bundle.min.js"></script>
	<script type="text/javascript" src="bootstrap/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="js/calendar.js"></script>
	<script type="text/javascript" src="js/xsd2xhtmlForm.js"></script>
	</html>
</xsl:template>

</xsl:stylesheet>

