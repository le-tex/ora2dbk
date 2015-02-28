<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xiout="bogo"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:variable name="common-uri" as="xs:string" select="replace(base-uri(/*), '^(.+/).+$', '$1')"/>

  <xsl:template match="/" mode="html2dbk">
    <book>
      <xsl:apply-templates select="c:files/html:body/node()" mode="#current"/>
    </book>
  </xsl:template>
  
  <xsl:template match="* | @*" mode="html2dbk export-chapters">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html:body/*/@data-type" mode="html2dbk">
    <xsl:attribute name="xml:base" select="base-uri()"/>
    <xsl:next-match/>
  </xsl:template>



  <!-- export chapters -->
  
  <xsl:function name="dbk:export-file-uri" as="xs:string">
    <xsl:param name="original-uri" as="xs:string"/>
    <xsl:sequence select="replace($original-uri, '^(.+)/([^/]+)/(.+)\..+$', '$1/$2.out/$3.xml')"/>
  </xsl:function>
  
  <xsl:template match="/dbk:book[@xml:base]" mode="export-chapters">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="xml:base" select="dbk:export-file-uri(@xml:base)"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[@xml:base]" mode="export-chapters">
    <xsl:variable name="href" select="dbk:export-file-uri(@xml:base)"/>
    <xiout:include href="{substring-after($href, $common-uri)}"/>
    <xsl:result-document href="{$href}">
      <xsl:copy>
        <xsl:apply-templates select="@* except @xml:base, node()" mode="#current"/>  
      </xsl:copy>
    </xsl:result-document>
  </xsl:template>

  <!-- recursive sections to sect1, sect2, … -->
  <xsl:template match="dbk:section" mode="export-chapters">
    <xsl:element name="sect{count(ancestor-or-self::section)}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  

</xsl:stylesheet>