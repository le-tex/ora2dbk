<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xiout="bogo"
  xmlns:htmltable="http://transpect.io/htmltable"
  xmlns:html2hub = "http://transpect.io/html2hub"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:import href="http://transpect.io/html2hub/xsl/tables.xsl"/>

  <xsl:param name="debug" select="'0'"/>

  <xsl:namespace-alias stylesheet-prefix="xiout" result-prefix="xi"/>

  <xsl:variable name="common-uri" as="xs:string" select="replace(base-uri(/*), '^(.+)/.+$', '$1.out/')"/>

  <xsl:template match="/" mode="html2dbk">
    <book>
      <xsl:copy-of select="/*/@xml:base"/>
      <bookinfo>
        <title/>
        <xsl:apply-templates mode="#current"
          select="c:files/html:body/node()[@data-type eq 'cover']"/>
      </bookinfo>
      <xsl:apply-templates select="c:files/html:body/node()[
                                     not(@data-type eq 'cover')
                                   ]" mode="#current"/>
    </book>
  </xsl:template>


  <!-- book component elements -->

  <xsl:template match="html:section[@data-type eq 'preface']" mode="html2dbk">
    <preface>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </preface>
  </xsl:template>
  <xsl:template match="html:section/@data-type[. eq 'preface']" mode="html2dbk"/>

  <xsl:template match="html:section[@data-type eq 'introduction']" mode="html2dbk">
    <preface>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </preface>
  </xsl:template>
  <xsl:template match="html:section/@data-type[. eq 'introduction']" mode="html2dbk"/>

  <xsl:template match="html:section[@data-type eq 'chapter']" mode="html2dbk">
    <chapter>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </chapter>
  </xsl:template>
  <xsl:template match="html:section/@data-type[. eq 'chapter']" mode="html2dbk"/>
  
  <xsl:template match="html:section[@data-type eq 'colophon']" mode="html2dbk">
    <colophon>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </colophon>
  </xsl:template>
  <xsl:template match="html:section/@data-type[. eq 'colophon']" mode="html2dbk"/>

  <xsl:template match="html:section[@data-type eq 'dedication']" mode="html2dbk">
    <dedication>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dedication>
  </xsl:template>
  <xsl:template match="html:section/@data-type[. eq 'dedication']" mode="html2dbk"/>
  
  <xsl:template match="html:section[@data-type = ('copyright-page', 'titlepage')]" mode="html2dbk">
    <appendix role="{@data-type}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </appendix>
  </xsl:template>
  <xsl:template match="html:section/@data-type[. = ('copyright-page', 'titlepage')]" mode="html2dbk"/>
  
  <xsl:template match="html:section" mode="html2dbk">
    <section>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </section>
  </xsl:template>
  
  <xsl:template match="html:section[matches(@data-type, '^sect\d$')]" mode="html2dbk">
    <xsl:element name="{@data-type}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="html:section[matches(@data-type, '^sect\d$')]/@data-type" mode="html2dbk"/>
  
  <xsl:template match="html:nav[@data-type eq 'toc']" mode="html2dbk">
    <toc>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(html:*[matches(local-name(), '^h[1-6]$')])">
        <title/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </toc>
  </xsl:template>
  <xsl:template match="html:nav/@data-type[. eq 'toc']" mode="html2dbk"/>
  
  <xsl:template match="html:section[@data-type eq 'index']" mode="html2dbk">
    <index>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(html:*[matches(local-name(), '^h[1-6]$')])">
        <title/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </index>
  </xsl:template>
  <xsl:template match="html:section/@data-type[. eq 'index']" mode="html2dbk"/>
  
  <xsl:template match="html:*[matches(local-name(), '^h[1-6]$')]" mode="html2dbk">
    <title>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </title>
  </xsl:template>


  <!-- block elements -->

  <xsl:template match="html:p" mode="html2dbk">
    <para>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </para>
  </xsl:template>
  
  <xsl:template match="html:aside[@data-type eq 'sidebar']" mode="html2dbk">
    <sidebar>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </sidebar>
  </xsl:template>
  <xsl:template match="html:aside/@data-type[. eq 'sidebar']" mode="html2dbk"/>

  <xsl:variable name="htmlbook-div-types-to-docbook-element" as="xs:string*"
    select="('note', 'warning', 'tip', 'caution', 'important', 'example', 'equation')"/>

  <xsl:template match="html:div[
                         @data-type = $htmlbook-div-types-to-docbook-element
                       ]" mode="html2dbk">
    <xsl:element name="{@data-type}">
      <xsl:apply-templates select="@* except @data-type" mode="#current"/>
      <!-- to do: handle h2, h3, h4, h5 and h6 -->
      <xsl:call-template name="create-para-wrapper-for-inline-content"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="html:div/@data-type[. = $htmlbook-div-types-to-docbook-element]" mode="html2dbk"/>

  <xsl:template name="create-para-wrapper-for-inline-content">
    <xsl:param name="content" as="node()*" select="node()"/>
    <xsl:choose>
      <xsl:when test="text()[normalize-space()] or 
                      html:*[local-name() = $html5-inline-element-localnames]">
        <para>
          <xsl:apply-templates select="node()" mode="#current"/>
        </para>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="html:div[not(@data-type)]" mode="html2dbk">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="html2dbk" priority="2"
    match="html:div[not(@data-type)]/html:*[matches(local-name(), '^h\d$')]">
    <bridgehead>
      <xsl:apply-templates select="@* except @class, (@class, parent::*/@class)[1], node()" mode="#current"/>
    </bridgehead>
  </xsl:template>

  <xsl:template match="html:figure" mode="html2dbk">
    <figure>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(html:figcaption)">
        <title/>
      </xsl:if>
      <xsl:apply-templates select="html:figcaption, node() except html:figcaption" mode="#current"/>
    </figure>
  </xsl:template>
  
  <!-- project specific @data-type='cover'? -->
  <xsl:template match="html:figure[@data-type eq 'cover']" mode="html2dbk" priority="3">
    <imageobject>
      <xsl:apply-templates select="@data-type" mode="#current"/>
        <imagedata fileref="{html:img/@src}">
          <xsl:apply-templates select="html:img/@width, html:img/@height" mode="#current"/>
        </imagedata>
      </imageobject>
  </xsl:template>

  <xsl:template match="html:figcaption" mode="html2dbk">
    <title>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </title>
  </xsl:template>

  <xsl:template match="html:img" mode="html2dbk">
    <mediaobject>
      <!-- to do: handle @alt -->
      <xsl:apply-templates select="@* except (@src, @alt, @width, @height)" mode="#current"/>
      <imageobject>
        <imagedata fileref="{@src}">
          <xsl:apply-templates select="@width, @height" mode="#current"/>
        </imagedata>
      </imageobject>
    </mediaobject>
  </xsl:template>
  
  <xsl:template match="html:img/@width | html:img/@height" mode="html2dbk">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="html:pre" mode="html2dbk">
    <programlisting>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </programlisting>
  </xsl:template>
  
  <xsl:template match="html:dfn" mode="html2dbk">
    <firstterm>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </firstterm>
  </xsl:template>

  <xsl:template match="@data-programming-language" mode="html2dbk">
    <xsl:attribute name="language" select="."/>
  </xsl:template>

  <xsl:template match="*[self::html:ul or self::html:ol][parent::html:div]" 
    mode="html2dbk" priority="3">
  <para>
    <xsl:next-match/>
  </para>
</xsl:template>

  <xsl:template match="html:ul" mode="html2dbk">
    <itemizedlist>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </itemizedlist>
  </xsl:template>
  
  <xsl:template match="html:ol" mode="html2dbk">
    <orderedlist>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </orderedlist>
  </xsl:template>
  
  <xsl:template match="html:li" mode="html2dbk">
    <listitem>
      <xsl:call-template name="create-para-wrapper-for-inline-content"/>
    </listitem>
  </xsl:template>

  <xsl:template match="html:dl" mode="html2dbk">
    <variablelist>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*" group-starting-with="html:dt">
        <varlistentry>
          <term>
            <xsl:apply-templates select="current-group()[1]/node()" mode="#current"/>
          </term>
          <listitem>
            <xsl:call-template name="create-para-wrapper-for-inline-content">
              <xsl:with-param name="content" select="current-group()[position() gt 1]"/>
            </xsl:call-template>
          </listitem>
        </varlistentry>
      </xsl:for-each-group>
    </variablelist>
  </xsl:template>

  <xsl:template match="html:blockquote" mode="html2dbk">
    <blockquote>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="html:p[@data-type eq 'attribution']" mode="#current"/>
      <xsl:choose>
        <xsl:when test="html:*[local-name() = $html5-inline-element-localnames]">
          <para>
            <xsl:apply-templates select="node()" mode="#current"/>
          </para>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="* except html:p[@data-type eq 'attribution']" mode="#current"/>
        </xsl:otherwise>
      </xsl:choose>
    </blockquote>
  </xsl:template>
  
  <xsl:template match="html:blockquote
                         /html:p[@data-type eq 'attribution']" mode="html2dbk">
    <attribution>
      <xsl:apply-templates select="@* except @data-type, node()" mode="#current"/>
    </attribution>
  </xsl:template>

  <!-- tables -->
  
  <xsl:template match="html:table" mode="html2dbk">
    <xsl:apply-templates select="." mode="html2hub:default"/>
  </xsl:template>


  <!-- inline elements -->

  <xsl:variable name="htmlbook-inline-element-names" as="xs:string*" 
    select="('html:em', 'html:strong', 'html:code', 'html:span', 'html:a', 'html:sub', 'html:sup')"/>
  
  <xsl:variable name="html5-inline-element-localnames" as="xs:string*" 
    select="('a', 'abbr', 'b', 'bdi', 'bdo', 'br', 'button', 'command', 'cite', 'code',
             'datalist', 'del', 'dfn', 'dt', 'em', 'i', 'input', 'img', 'ins', 'kbd',
             'keygen', 'label', 'mark', 'meter', 'output', 'progress', 'q', 'ruby', 
             's', 'samp', 'select', 'small', 'span', 'strong', 'sub', 'sup', 'textarea',
             'time', 'u', 'var', 'wbr')"/>


  <xsl:template match="html:em" mode="html2dbk">
    <emphasis>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </emphasis>
  </xsl:template>
  
  <xsl:template match="html:strong" mode="html2dbk">
    <emphasis role="bold">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </emphasis>
  </xsl:template>

  <xsl:template match="html:code" mode="html2dbk">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="html:code//text()" mode="html2dbk">
    <code>
      <xsl:apply-templates select="ancestor::html:code[1]/@*" mode="#current"/>
      <xsl:value-of select="."/>
    </code>
  </xsl:template>

  <xsl:template match="html:sup" mode="html2dbk">
    <superscript>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </superscript>
  </xsl:template>
  
  <xsl:template match="html:sub" mode="html2dbk">
    <subscript>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </subscript>
  </xsl:template>

  <xsl:template match="html:span[not(@data-type)]" mode="html2dbk">
    <phrase>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </phrase>
  </xsl:template>

  <xsl:template match="html:span[@data-type eq 'footnote']" mode="html2dbk">
    <footnote>
      <xsl:apply-templates select="@* except @data-type" mode="#current"/>
      <para>
        <!-- to do: handle br and generate more than one para element -->
        <xsl:apply-templates select="node()" mode="#current"/>
      </para>
    </footnote>
  </xsl:template>

  <xsl:template match="html:a[@href]" mode="html2dbk">
    <ulink>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </ulink>
  </xsl:template>

  <xsl:template match="html:a/@href" mode="html2dbk">
    <xsl:attribute name="url" select="."/>
  </xsl:template>
  
  <xsl:template match="html:a[not(@data-type)][starts-with(@href, '#')]" mode="html2dbk" priority="2">
    <link>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </link>
  </xsl:template>
  
  <xsl:template match="html:a[not(@data-type)][starts-with(@href, '#')]/@href" mode="html2dbk" priority="2">
    <xsl:attribute name="linkend" select="substring-after(., '#')"/>
  </xsl:template>

  <xsl:template match="html:a[@data-type eq 'xref']" mode="html2dbk" priority="3">
    <xref>
      <xsl:apply-templates select="@* except @data-type" mode="#current"/>
    </xref>
  </xsl:template>
  
  <xsl:template match="html:a[@data-type eq 'xref']/@href" mode="html2dbk" priority="3">
    <xsl:attribute name="linkend" select="substring-after(., '#')"/>
  </xsl:template>

  <xsl:template match="html:a[@data-type eq 'indexterm']" mode="html2dbk">
    <indexterm>
      <xsl:apply-templates mode="#current" 
        select="@id,
                @data-primary,
                @data-secondary,
                @data-tertiary,
                @data-see,
                @data-seealso"/>
    </indexterm>
  </xsl:template>
  
  <xsl:template match="html:a[@data-type eq 'indexterm']/@id" mode="html2dbk">
    <xsl:next-match/>
    <xsl:if test=". = root(.)//html:a[@data-type eq 'indexterm']/@data-startref">
      <xsl:attribute name="class" select="'startofrange'"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="html:a[@data-type eq 'indexterm'][@data-startref]" mode="html2dbk" priority="3">
    <xsl:if test="@data-startref = root(.)//html:a[@data-type eq 'indexterm']/@id">
      <indexterm startref="{@data-startref}" class="endofrange"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="html:a[@data-type eq 'indexterm']/@data-primary" mode="html2dbk">
    <primary>
      <xsl:if test="../@data-primary-sortas">
        <xsl:attribute name="sortas" select="../@data-primary-sortas"/>
      </xsl:if>
      <xsl:value-of select="."/>
    </primary>
  </xsl:template>
  
  <xsl:template match="html:a[@data-type eq 'indexterm']/@data-secondary" mode="html2dbk">
    <secondary>
      <xsl:if test="../@data-secondary-sortas">
        <xsl:attribute name="sortas" select="../@data-secondary-sortas"/>
      </xsl:if>
      <xsl:value-of select="."/>
    </secondary>
  </xsl:template>
  
  <xsl:template match="html:a[@data-type eq 'indexterm']/@data-tertiary" mode="html2dbk">
    <tertiary>
      <xsl:if test="../@data-tertiary-sortas">
        <xsl:attribute name="sortas" select="../@data-tertiary-sortas"/>
      </xsl:if>
      <xsl:value-of select="."/>
    </tertiary>
  </xsl:template>
  
  <xsl:template match="html:a[@data-type eq 'indexterm']/@data-see" mode="html2dbk">
    <see>
      <xsl:value-of select="."/>
    </see>
  </xsl:template>
  
  <xsl:template match="html:a[@data-type eq 'indexterm']/@data-seealso" mode="html2dbk">
    <seealso>
      <xsl:value-of select="."/>
    </seealso>
  </xsl:template>

  <xsl:template match="html:br" mode="html2dbk">
    <phrase role="br"/>
  </xsl:template>

  <xsl:template match="html:span[@data-type eq 'email']" mode="html2dbk" priority="3">
    <email>
      <xsl:apply-templates select="@* except @data-type, node()" mode="#current"/>
    </email>
  </xsl:template>

  <xsl:template match="@contenteditable" mode="html2dbk"/>

  <xsl:template match="@class" mode="html2dbk">
    <xsl:attribute name="role" select="."/>
  </xsl:template>
  
  <xsl:template match="@id" mode="html2dbk">
    <xsl:attribute name="xml:id" select="."/>
  </xsl:template>
  
  <xsl:template match="@style" mode="html2dbk"/>

  <!-- catch all -->

  <xsl:template match="* | @*" mode="html2dbk" priority="-10">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
    <xsl:if test="$debug = '1'">
      <xsl:message select="'html2dbk info, unmapped:', if(. instance of element()) then name() else ."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*[starts-with(name(), 'data-')]" mode="html2dbk" priority="-2">
    <xsl:if test="$debug = '1'">
      <xsl:message select="'html2dbk info, unmapped:', if(. instance of element()) then name() else ."/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="comment() | processing-instruction()" mode="html2dbk">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="html:body/*/@data-type" mode="html2dbk" priority="3">
    <xsl:attribute name="xml:base" select="base-uri()"/>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="@class" mode="html2hub:default">
    <xsl:attribute name="role" select="."/>
  </xsl:template>


  <!-- export chapters -->
  
  <xsl:function name="dbk:export-file-uri" as="xs:string">
    <xsl:param name="original-uri" as="xs:string"/>
    <xsl:sequence select="replace($original-uri, '^(.+)/([^/]+)/(.+)\..+$', '$1/$2.out/$3.xml')"/>
  </xsl:function>
  

  <xsl:template match="* | @*" mode="export-chapters">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/*[@xml:base]" mode="export-chapters" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="xml:base" select="dbk:export-file-uri(@xml:base)"/>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="top-level-base-uri" as="xs:string" select="@xml:base" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[@xml:base]" mode="export-chapters">
    <xsl:param name="top-level-base-uri" as="xs:string" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="@xml:base = $top-level-base-uri">
        <xsl:copy>
          <xsl:apply-templates select="@* except @xml:base, node()" mode="#current"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="href" select="dbk:export-file-uri(@xml:base)"/>
        <xiout:include href="{substring-after($href, $common-uri)}"/>
        <xsl:result-document href="{$href}">
          <xsl:copy>
            <xsl:apply-templates select="@* except @xml:base, node()" mode="#current"/>
          </xsl:copy>
        </xsl:result-document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- recursive sections to sect1, sect2, … -->
  <xsl:template match="dbk:section" mode="export-chapters">
    <xsl:element name="sect{count(ancestor-or-self::dbk:section)}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>