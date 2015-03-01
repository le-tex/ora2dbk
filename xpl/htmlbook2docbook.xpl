<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:htmltable="http://www.le-tex.de/namespace/htmltable"
  xmlns:j="http://marklogic.com/json"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect" 
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0"
  name="process-json">

  <p:option name="json" required="false">
    <p:documentation>URI or OS file name, may also be relative. If omitted, an XHTML source document
    is expected.</p:documentation>
  </p:option>
  
  <p:option name="file" required="false" select="''">
    <p:documentation>Optional file from within the files list in the JSON file. Conversion will be restricted to a single file then.</p:documentation>
  </p:option>
  
  <p:input port="html" primary="true">
    <p:documentation>If the json option is not specified, an HTMLBook document is expected here.
    On second thought, this will only work if we are able to specify validator.nu as the parser.
    Until we figure that out, use the json invocation.</p:documentation>
    <p:empty/>
  </p:input>

  <p:input port="xsl">
    <p:document href="../xsl/htmlbook2docbook.xsl"/>
  </p:input>

  <p:output port="result" primary="true">
    <p:pipe port="result" step="html2dbk"/>
<!--    <p:pipe port="result" step="strip-namespace"/>-->
  </p:output>
  <p:serialization port="result" doctype-public="-//OASIS//DTD DocBook XML V4.5//EN" 
    doctype-system="http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" omit-xml-declaration="false"></p:serialization>

  <p:output port="parsed-html">
    <p:pipe port="result" step="htmltable-normalizer"/>
  </p:output>

  <p:declare-step type="transpect:strip-namespaces">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:xslt name="strip-namespace">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
          <xsl:template match="*">
            <xsl:element name="{name()}" namespace="">
              <xsl:apply-templates select="@*, node()"/>
            </xsl:element>
          </xsl:template>
          <xsl:template match="xi:*">
            <xsl:copy copy-namespaces="no">
              <xsl:apply-templates select="@*, node()"/>
            </xsl:copy>
          </xsl:template>
          <xsl:template match="@* | processing-instruction() | comment()">
            <xsl:copy/>
          </xsl:template>
          <xsl:template match="@xml:base"/>
          <xsl:template match="@xml:id">
            <xsl:attribute name="id" select="."/>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  </p:declare-step>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/xproc-util/file-uri/file-uri.xpl"/>
  <p:import href="http://transpect.le-tex.de/html-tables/xpl/add-origin-atts.xpl"/>

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Calabash must be invoked with the <a href="http://xmlcalabash.com/docs/reference/langext.html#ext.transparent-json">transparent-json extension</a>
      for the JSON parsing.</p>
  </p:documentation>

  <p:choose name="read">
    <p:when test="p:value-available('json')">
      <p:output port="result" primary="true"/>
      <transpect:file-uri name="file-uri">
        <p:with-option name="filename" select="$json"/>
      </transpect:file-uri>
      <p:group>
        <p:variable name="json-uri" select="/*/@local-href"/>
        <p:add-attribute attribute-name="href" match="/*">
          <p:documentation>Unfortunately, we have to revert to http-request the local file, because apparently we cannot p:load
            the JSON file. Even if we could, it’s still unclear whether transparent JSON parsing would work
            then.</p:documentation>
          <p:input port="source">
            <p:inline>
              <c:request method="GET"/>
            </p:inline>
          </p:input>
          <p:with-option name="attribute-value" select="$json-uri"/>
        </p:add-attribute>
        <p:http-request name="get-json"/>
        <p:for-each name="files-iteration">
          <p:iteration-source select="/c:body/j:json/j:files/j:item[if (normalize-space($file)) then . = $file else true()]"/>
          <p:add-attribute attribute-name="href" match="/*">
            <p:input port="source">
              <p:inline>
                <c:request method="GET"/>
              </p:inline>
            </p:input>
            <p:with-option name="attribute-value" select="resolve-uri(., $json-uri)"/>
          </p:add-attribute>
          <p:http-request/>
          <p:unescape-markup content-type="text/html" />
          <p:filter select="/c:body/html:html/html:body"/>
          <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="resolve-uri(., $json-uri)">
              <p:pipe port="current" step="files-iteration"/>
            </p:with-option>
          </p:add-attribute>
        </p:for-each>
        <p:wrap-sequence wrapper="c:files"/>
        <p:add-attribute match="/*" attribute-name="xml:base">
          <p:with-option name="attribute-value" select="$json-uri"/>
        </p:add-attribute>
      </p:group>    
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true"/>
      <p:wrap-sequence wrapper="c:files"/>
    </p:otherwise>
  </p:choose>

  <htmltable:add-origin-atts name="htmltable-normalizer"/>

  <p:xslt initial-mode="html2dbk" name="html2dbk">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="stylesheet">
      <p:pipe port="xsl" step="process-json"/>
    </p:input>
  </p:xslt>

  <p:xslt initial-mode="export-chapters" name="export-chapters-xsl">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="stylesheet">
      <p:pipe port="xsl" step="process-json"/>
    </p:input>
  </p:xslt>  
  
  <transpect:strip-namespaces/>
  
  <p:store method="xml" omit-xml-declaration="false" doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"
    doctype-system="http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd">
    <p:with-option name="href" select="base-uri(/*)">
      <p:pipe port="result" step="export-chapters-xsl"/>
    </p:with-option>
  </p:store>
  
  <p:for-each name="store-chapters">
    <p:iteration-source>
      <p:pipe port="secondary" step="export-chapters-xsl"/>
    </p:iteration-source>
    <transpect:strip-namespaces/>
    <p:store method="xml" omit-xml-declaration="false" doctype-public="-//OASIS//DTD DocBook XML V4.5//EN" 
      doctype-system="http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd">
      <p:with-option name="href" select="base-uri()">
        <p:pipe port="current" step="store-chapters"/>
      </p:with-option>
    </p:store>
  </p:for-each>

</p:declare-step>