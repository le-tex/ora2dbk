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


  <!-- book component elements -->

  <xsl:template match="html:section[@data-type eq 'chapter']" mode="html2dbk">
    <chapter>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </chapter>
  </xsl:template>
  <xsl:template match="html:section[@data-type eq 'chapter']/@data-type" mode="html2dbk"/>
  
  <xsl:template match="html:section[@data-type eq 'colophon']" mode="html2dbk">
    <colophon>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </colophon>
  </xsl:template>
  
  <xsl:template match="html:section[@data-type eq 'colophon']/@data-type" mode="html2dbk"/>

  <xsl:template match="html:section[@data-type eq 'dedication']" mode="html2dbk">
    <dedication>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dedication>
  </xsl:template>
  <xsl:template match="html:section[@data-type eq 'dedication']/@data-type" mode="html2dbk"/>
  
  <xsl:template match="html:section[not(@data-type)]" mode="html2dbk">
    <section>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </section>
  </xsl:template>
  
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
  <xsl:template match="html:aside[@data-type eq 'sidebar']/@data-type" mode="html2dbk"/>

  <xsl:variable name="htmlbook-div-types-to-docbook-element" as="xs:string*"
    select="('note', 'warning', 'tip', 'caution', 'important', 'example', 'equation')"/>

  <xsl:template match="html:div[
                         @data-type = $htmlbook-div-types-to-docbook-element
                       ]" mode="html2dbk">
    <xsl:element name="{@data-type}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <!-- to do: handle h2, h3, h4, h5 and h6 -->
      <xsl:call-template name="create-para-wrapper-for-inline-content"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="create-para-wrapper-for-inline-content">
    <xsl:call-template name="create-para-wrapper-for-inline-content"/>
  </xsl:template>

  <xsl:template match="html:div[
                         @data-type = $htmlbook-div-types-to-docbook-element
                       ]/@data-type" mode="html2dbk"/>

  <xsl:template match="html:div[not(@data-type)]" mode="html2dbk">
    <formalpara>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(html:*[matches(local-name(), '^h\d$')])">
        <title/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </formalpara>
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

  <xsl:template match="html:figcaption" mode="html2dbk">
    <title>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </title>
  </xsl:template>

  <xsl:template match="html:img" mode="html2dbk">
    <mediaobject>
      <!-- to do: handle @alt -->
      <xsl:apply-templates select="@* except (@src, @alt)" mode="#current"/>
      <imageobject>
        <imagedata fileref="{@src}"/>
      </imageobject>
    </mediaobject>
  </xsl:template>

  <xsl:template match="html:pre[@data-type eq 'programlisting']" mode="html2dbk">
    <programlisting>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </programlisting>
  </xsl:template>
  <xsl:template match="html:pre[@data-type eq 'programlisting']/@data-type" mode="html2dbk"/>

  <xsl:template match="html:pre[@data-type eq 'programlisting']/@data-code-language" mode="html2dbk">
    <xsl:attribute name="language" select="."/>
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
      <xsl:apply-templates select="node()" mode="#current"/>
      <xsl:call-template name="create-para-wrapper-for-inline-content"/>
    </listitem>
  </xsl:template>

  <xsl:template match="html:dl" mode="html2dbk">
    <variablelist>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="node()" group-starting-with="dt">
        <varlistentry>
          <term>
            <xsl:apply-templates select="current-group()[1]" mode="#current"/>
          </term>
          <xsl:for-each select="current-group()[position() gt 1]">
            <listitem>
              <xsl:call-template name="create-para-wrapper-for-inline-content"/>
            </listitem>
          </xsl:for-each>
        </varlistentry>
      </xsl:for-each-group>
    </variablelist>
  </xsl:template>

  <xsl:template match="html:blockquote" mode="html2dbk">
    <blockquote>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="create-para-wrapper-for-inline-content"/>
    </blockquote>
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
    <code>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
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
      <xsl:apply-templates select="@*" mode="#current"/>
      <para>
        <!-- to do: handle br and generate more than one para element -->
        <xsl:apply-templates select="node()" mode="#current"/>
      </para>
    </footnote>
  </xsl:template>
  <xsl:template match="html:span[@data-type eq 'footnote']/@data-type" mode="html2dbk"/>

  <xsl:template match="html:a[not(@data-type)]" mode="html2dbk" priority="-1">
    <ulink>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </ulink>
  </xsl:template>

  <xsl:template match="html:a[not(@data-type)][starts-with(@href, '#')]" mode="html2dbk">
    <link>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </link>
  </xsl:template>
  
  <xsl:template match="html:a[not(@data-type)][starts-with(@href, '#')]/@href" mode="html2dbk">
    <xsl:attribute name="linkend" select="substring-after(., '#')"/>
  </xsl:template>
  
  <xsl:template match="html:a[not(@data-type)]/@href" mode="html2dbk" priority="-1">
    <xsl:attribute name="url" select="."/>
  </xsl:template>

  <xsl:template match="html:a[@data-type eq 'xref']" mode="html2dbk">
    <xref>
      <xsl:apply-templates select="@*" mode="#current"/>
    </xref>
  </xsl:template>
  <xsl:template match="html:a[@data-type eq 'xref']/@data-type" mode="html2dbk"/>
  
  <xsl:template match="html:a[@data-type eq 'xref']/@href" mode="html2dbk">
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
  <xsl:template match="html:a[@data-type eq 'indexterm']/@data-type" mode="html2dbk"/>
  
  <xsl:template match="html:a[@data-type eq 'indexterm']/@id" mode="html2dbk">
    <xsl:next-match/>
    <xsl:if test=". = root(.)//html:a[@data-type eq 'indexterm']/@data-startref">
      <xsl:attribute name="class" select="'startofrange'"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="html:a[@data-type eq 'indexterm'][@data-startref]" mode="html2dbk" priority="3">
    <indexterm startref="{@data-startref}" class="endofrange"/>
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

  <xsl:template match="@contenteditable" mode="html2dbk"/>

  <xsl:template match="@class" mode="html2dbk">
    <xsl:attribute name="role" select="."/>
  </xsl:template>
  
  <xsl:template match="@id" mode="html2dbk">
    <xsl:copy/>
  </xsl:template>

  <!-- catch all and debug -->

  <xsl:template match="* | @*" mode="html2dbk" priority="-10">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
    <xsl:message select="'html2dbk info, unmapped:', if(. instance of element()) then name() else ."/>
  </xsl:template>
  
  <xsl:template match="comment() | processing-instruction()" mode="html2dbk">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="html:body/*/@data-type" mode="html2dbk" priority="3">
    <xsl:attribute name="xml:base" select="base-uri()"/>
    <xsl:next-match/>
  </xsl:template>
  
</xsl:stylesheet>