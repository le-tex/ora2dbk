<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:html="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  xmlns="http://docbook.org/ns/docbook"
  version="2.0">
  
  <xsl:template match="/" mode="html2dbk">
    <book>
      <xsl:apply-templates select="c:files/html:body/node()" mode="#current"/>
    </book>
  </xsl:template>
  
  <xsl:template match="* | @*" mode="html2dbk">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html:body/*/@data-type" mode="html2dbk">
    <xsl:attribute name="xml:base" select="base-uri()"/>
    <xsl:next-match/>
  </xsl:template>
  
</xsl:stylesheet>