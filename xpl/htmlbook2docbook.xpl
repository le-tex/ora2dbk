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
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="1.0"
  name="process-atlas"
  type="letex:process-atlas">

  <p:option name="input" required="true">
    <p:documentation>URI or OS file name, may also be relative, of a JSON, HTML, or ZIP file.
    A ZIP file must contain a single JSON file on its top level.
    File endings must be one of .json, .html, or .zip, no other endings will be recognized.</p:documentation>
  </p:option>
  
  <p:option name="front-end" select="'true'">
    <p:documentation>Whether this is a front-end call of this pipeline. 
      If it is, DocBook and an output zip file will be produced. 
      If it isn’t, only the parsed-html output port will have meaningful output.
      This option is provided for internal use only.
    </p:documentation>
  </p:option>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  
  <p:input port="xsl">
    <p:document href="../xsl/htmlbook2docbook.xsl"/>
  </p:input>

  <p:output port="dbk4">
    <p:pipe port="dbk4" step="main"/>
  </p:output>
  <p:serialization port="dbk4" doctype-public="-//OASIS//DTD DocBook XML V4.5//EN" 
    doctype-system="http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" omit-xml-declaration="false"></p:serialization>

  <p:output port="result" primary="true"/>
  <p:serialization port="result" indent="true" omit-xml-declaration="false"/>

  <p:output port="parsed-html">
    <p:pipe port="html" step="main"/>
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
  <p:import href="http://transpect.le-tex.de/calabash-extensions/ltx-lib.xpl" />
  <p:import href="http://transpect.le-tex.de/html-tables/xpl/add-origin-atts.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/file-uri/file-uri.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl"/>
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Calabash must be invoked with the <a href="http://xmlcalabash.com/docs/reference/langext.html#ext.transparent-json">transparent-json extension</a>
      for the JSON parsing.</p>
  </p:documentation>

  <transpect:file-uri name="file-uri">
    <p:with-option name="filename" select="$input"/>
  </transpect:file-uri>
      
  <letex:store-debug>
    <p:with-option name="pipeline-step" select="concat('file-uri/', /*/@lastpath)"/>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </letex:store-debug>
      
  <p:group name="main">
    <p:output port="result" primary="true"/>
    <p:output port="dbk4">
      <p:pipe port="dbk4" step="process-html-collection"/>
    </p:output>
    <p:output port="html">
      <p:pipe port="result" step="add-base"/>
    </p:output>

    <p:variable name="input-uri" select="/*/@local-href"/>
    <p:variable name="input-ext" select="replace($input-uri, '^.+\.', '')"/>

    <p:choose name="read">
      <p:when test="$input-ext = 'json'">
        <p:output port="result" primary="true" sequence="true"/>
        <p:add-attribute attribute-name="href" match="/*">
          <p:documentation>Unfortunately, we have to revert to http-request the local file, because apparently we cannot p:load
            the JSON file. Even if we could, it’s still unclear whether transparent JSON parsing would work
            then.</p:documentation>
          <p:input port="source">
            <p:inline>
              <c:request method="GET"/>
            </p:inline>
          </p:input>
          <p:with-option name="attribute-value" select="$input-uri"/>
        </p:add-attribute>
        <letex:store-debug pipeline-step="json/http-request">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </letex:store-debug>
        <p:http-request name="get-json"/>
        <letex:store-debug pipeline-step="json/read">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </letex:store-debug>
        <p:for-each name="files-iteration">
          <p:iteration-source select="/c:body/j:json/j:files/j:item"/>
          <!--<cx:message>
            <p:with-option name="message" select="'HHHHHHHHHHHHHHHHHHHHHHH ', ."></p:with-option>
          </cx:message>-->
          <letex:process-atlas front-end="false" name="recursive-html-processing">
            <p:documentation>Recursion FTW!</p:documentation>
            <p:with-option name="input" select="resolve-uri(., $input-uri)"/>
            <p:input port="xsl">
              <p:pipe port="xsl" step="process-atlas"/>
            </p:input>
          </letex:process-atlas>
          <p:filter select="/c:files/html:body"/>
        </p:for-each>
      </p:when>
      <p:when test="$input-ext = 'html'">
        <p:output port="result" primary="true"/>
        <p:add-attribute attribute-name="href" match="/*">
          <p:input port="source">
            <p:inline>
              <c:request method="GET"/>
            </p:inline>
          </p:input>
          <p:with-option name="attribute-value" select="$input-uri"/>
        </p:add-attribute>
        <p:http-request/>
        <p:unescape-markup content-type="text/html"/>
        <p:filter select="/c:body/html:html/html:body"/>
        <p:add-attribute match="/*" attribute-name="xml:base">
          <p:with-option name="attribute-value" select="$input-uri"/>
        </p:add-attribute>
        <letex:store-debug>
          <p:with-option name="pipeline-step" select="concat('single-html/', replace($input-uri, '^.+/', ''))"/>
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </letex:store-debug>
      </p:when>
    </p:choose>

    <p:wrap-sequence wrapper="c:files"/>
    <p:add-attribute match="/*" attribute-name="xml:base" name="add-base">
      <p:with-option name="attribute-value" select="$input-uri"/>
    </p:add-attribute>

    <p:choose name="process-html-collection">
      <p:when test="$front-end = 'true'">
        <p:output port="result" primary="true"/>
        <p:output port="dbk4">
          <p:pipe port="result" step="dbk4"/>
        </p:output>
        <htmltable:add-origin-atts name="htmltable-normalizer"/>

        <letex:store-debug pipeline-step="htmltables/normalized">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </letex:store-debug>

        <p:xslt initial-mode="html2dbk" name="html2dbk">
          <p:input port="parameters">
            <p:empty/>
          </p:input>
          <p:input port="stylesheet">
            <p:pipe port="xsl" step="process-atlas"/>
          </p:input>
        </p:xslt>

        <p:xslt initial-mode="export-chapters" name="export-chapters-xsl">
          <p:input port="parameters">
            <p:empty/>
          </p:input>
          <p:input port="stylesheet">
            <p:pipe port="xsl" step="process-atlas"/>
          </p:input>
        </p:xslt>
        
        <letex:store-debug pipeline-step="dbk/xinclude-with-namespace">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </letex:store-debug>
        
        <transpect:strip-namespaces/>

        <p:store method="xml" omit-xml-declaration="false" doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"
          doctype-system="http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd">
          <p:with-option name="href" select="base-uri(/*)">
            <p:pipe port="result" step="export-chapters-xsl"/>
          </p:with-option>
        </p:store>

        <transpect:strip-namespaces name="dbk4">
          <p:documentation>The complete document as DocBook 4.5.</p:documentation>
          <p:input port="source">
            <p:pipe port="result" step="html2dbk"/>
          </p:input>
        </transpect:strip-namespaces>

        <p:sink/>

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

        <p:xslt name="zip-manifest">
          <p:input port="parameters">
            <p:empty/>
          </p:input>
          <p:input port="source">
            <p:pipe port="result" step="export-chapters-xsl"/>
          </p:input>
          <p:input port="stylesheet">
            <p:inline>
              <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                <xsl:template match="/">
                  <c:zip-manifest>
                    <xsl:apply-templates select="*/@xml:base, //xi:include/@href">
                      <xsl:with-param name="base-uri" select="replace(*/@xml:base, '^(.+/).+$', '$1')" as="xs:string"
                        tunnel="yes"/>
                    </xsl:apply-templates>
                  </c:zip-manifest>
                </xsl:template>
                <xsl:template match="@xml:base | @href">
                  <xsl:param name="base-uri" as="xs:string?" tunnel="yes"/>
                  <c:entry name="{if (self::attribute(xml:base)) then replace(., '^.+/', '') else .}"
                    href="{(self::attribute(xml:base), concat($base-uri, .))[1]}" method="deflated"/>
                </xsl:template>
                <xsl:template match="xi:include">
                  <c:entry>
                    <xsl:apply-templates select="@href"/>
                  </c:entry>
                </xsl:template>
              </xsl:stylesheet>
            </p:inline>
          </p:input>
        </p:xslt>

        <letex:store-debug pipeline-step="zip/manifest">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </letex:store-debug>
        
        <cx:zip command="create" name="zip">
          <p:with-option name="href" select="replace($input-uri, '^(.+)/.+$', '$1.zip')"/>
          <p:input port="source">
            <p:empty/>
          </p:input>
          <p:input port="manifest">
            <p:pipe step="zip-manifest" port="result"/>
          </p:input>
        </cx:zip>

        <p:identity>
          <p:input port="source">
            <p:pipe port="result" step="zip"/>
          </p:input>
        </p:identity>
      </p:when>
  
      <p:otherwise>
        <p:output port="result" primary="true"/>
        <p:output port="dbk4">
          <p:inline><book/></p:inline>
        </p:output>
        <p:identity>
          <p:input port="source">
            <p:pipe port="result" step="add-base"/>
          </p:input>
        </p:identity>
      </p:otherwise>
    </p:choose>

  </p:group>
  
</p:declare-step>