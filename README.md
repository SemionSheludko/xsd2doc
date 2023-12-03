XSD to HTML Documentation, XML, CSDL, HTML Form and MS SQL select query 
========

Set of XSLT 1.0 files for creating different formats from XML Schema Definition (XSD) files. 

It contains the following files:
* xsd2tree.xsl - General template, converting the XML schema to XML node tree.
* xsd2htmlDocs.xsl - Converts XSD files into HTML documentation (first doc style). 
* xsd2list.xsl - Converts XSD files into HTML documentation (different style).
* xsd2csdl.xsl - Converts XSD files into CSDL.
* xsd2xhtmlForm.xsl - Converts XSD files into HTML Form (bootstrap).
* xsd2xml.xsl - Converts XSD files into xml.
* xsd2sql_get.xsl - Generates MS SQL select query from XSD files. Additional attributes used in XSD for mapping to SQL tables and fields. Xml request used to create sql query (xsd2sql_get_request.xml is sample). It is QBE (Query by Example) format - give example xml what you want to get and fill attributes and elements with values for sql where clause. 
* .jse - [Windows Script Host](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wscript) files to run samples. 
* .xhtml and *.xml - results of samples run.