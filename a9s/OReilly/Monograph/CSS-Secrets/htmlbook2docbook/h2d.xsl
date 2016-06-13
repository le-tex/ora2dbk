<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xiout="bogo"
  xmlns:htmltable="http://transpect.io/htmltable"
  xmlns:html2hub = "http://transpect.io/html2hub"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:import href="http://transpect.io/htmlbook2docbook/xsl/htmlbook2docbook.xsl"/>

  <xsl:template match="html:figure/html:code" mode="bareflow-into-paras">
    <pre data-type="programlisting" data-code-language="js" xmlns="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="xml:space" select="'preserve'"/><!-- apparently the line breaks will be destroyed by the parser :( -->
      <xsl:apply-templates mode="#current"/>
    </pre> 
  </xsl:template>

  <xsl:template match="html:figure/html:p[html:pre][count(*) = 1]" mode="html2dbk" priority="4">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>


  <xsl:template match="html:section[@class = 'prereqs']" mode="html2dbk">
    <sidebar>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </sidebar>
  </xsl:template>

  <xsl:template match="html:header" mode="html2dbk">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="html:section[@data-type = 'copyright-page']/html:section[@class = 'history']" mode="html2dbk">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="html:time" mode="html2dbk">
    <phrase role="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </phrase>
  </xsl:template>

  <xsl:template match="html:h1/@id[. = 'one-line']" mode="html2dbk"/>

  <xsl:template match="@css:font-family" mode="html2dbk">
    <xsl:attribute name="role" select="concat('font-', replace(., '\C', '_'))"/>
  </xsl:template>
  
  <xsl:template match="@css:*[matches(local-name(), 'width|line-height|margin|padding|letter-spacing')]" mode="html2dbk" priority="2"/>

  <xsl:template match="@css:color" mode="html2dbk" priority="2">
    <xsl:attribute name="condition" select="concat('color: ', .)"/>
  </xsl:template>


</xsl:stylesheet>