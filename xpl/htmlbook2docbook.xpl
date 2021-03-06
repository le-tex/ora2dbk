<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:htmltable="http://transpect.io/htmltable" xmlns:j="http://marklogic.com/json"
  xmlns:tr="http://transpect.io"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.0" name="process-atlas"
  type="tr:process-atlas">

  <p:option name="input" required="true">
    <p:documentation>URI or OS file name, may also be relative, of a JSON, HTML, or ZIP file. A ZIP file must contain a single
      JSON file on its top level. File endings must be one of .json, .html, or .zip, no other endings will be
      recognized.</p:documentation>
  </p:option>

  <p:option name="front-end" select="'true'">
    <p:documentation>Whether this is a front-end call of this pipeline. If it is, DocBook and an output zip file will be
      produced. If it isn’t, only the parsed-html output port will have meaningful output. This option is provided for internal
      use only. </p:documentation>
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
    doctype-system="http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" omit-xml-declaration="false"/>

  <p:output port="result" primary="true"/>
  <p:serialization port="result" indent="true" omit-xml-declaration="false"/>

  <p:output port="report" sequence="true">
    <p:pipe port="report" step="main"/>
  </p:output>
  <p:serialization port="report" indent="true" omit-xml-declaration="false"/>
  
  <p:output port="parsed-html">
    <p:pipe port="html" step="main"/>
  </p:output>

  <p:declare-step type="tr:strip-namespaces">
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:xslt name="strip-namespace">
      <p:input port="parameters">
        <p:empty/>
      </p:input>
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

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/calabash-extensions/transpect-lib.xpl"/>
  <p:import href="http://transpect.io/htmltables/xpl/add-origin-atts.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/css-tools/xpl/css.xpl"/>
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Calabash must be invoked with the <a href="http://xmlcalabash.com/docs/reference/langext.html#ext.transparent-json"
        >transparent-json extension</a> for the JSON parsing.</p>
  </p:documentation>

  <tr:file-uri name="file-uri">
    <p:with-option name="filename" select="$input"/>
  </tr:file-uri>

  <tr:store-debug>
    <p:with-option name="pipeline-step" select="concat('file-uri/', /*/@lastpath)"/>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:group name="main">
    <p:output port="result" primary="true"/>
    <p:output port="dbk4">
      <p:pipe port="dbk4" step="process-html-collection"/>
    </p:output>
    <p:output port="html">
      <p:pipe port="result" step="add-base"/>
    </p:output>
    <p:output port="report" sequence="true">
      <p:documentation>If the input is zip, the dbk4 validation report will be collected within
      the 'read' step (through recursive invocation of this step). If the input is HTML</p:documentation>
      <p:pipe port="report" step="read"/>
      <p:pipe port="report" step="process-html-collection"/>
    </p:output>

    <p:variable name="input-uri" select="/*/@local-href"/>
    <p:variable name="input-ext" select="replace($input-uri, '^.+\.', '')"/>

    <p:choose name="read">
      <p:when test="$input-ext = 'zip'">
        <p:output port="result" primary="true" sequence="true"/>
        <p:output port="report">
          <p:pipe port="report" step="recursive-json-processing"/>
        </p:output>
        <p:output port="dbk4">
          <p:pipe port="dbk4" step="recursive-json-processing"/>
        </p:output>
        <tr:unzip>
          <p:with-option name="zip" select="/*/@os-path">
            <p:pipe port="result" step="file-uri"/>
          </p:with-option>
          <p:with-option name="dest-dir" select="replace(/*/@os-path, '\.zip$', '.dbk/')">
            <p:pipe port="result" step="file-uri"/>
          </p:with-option>
          <p:with-option name="overwrite" select="'yes'"/>
        </tr:unzip>
        <p:directory-list include-filter=".*\.json">
          <p:with-option name="path" select="/*/@xml:base"/>
        </p:directory-list>
        <tr:store-debug pipeline-step="zip-in/dirlist">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        <tr:process-atlas front-end="true" name="recursive-json-processing">
          <p:with-option name="input" select="resolve-uri(/*/c:file[1]/@name, base-uri(/c:directory))"/>
          <p:input port="xsl">
            <p:pipe port="xsl" step="process-atlas"/>
          </p:input>
          <p:with-option name="debug" select="$debug"/>
          <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        </tr:process-atlas>
        <p:sink/>
        <p:identity>
          <p:input port="source" select="/c:files/*">
            <p:pipe port="parsed-html" step="recursive-json-processing"/>
          </p:input>
        </p:identity>
      </p:when>
      
      <p:when test="$input-ext = 'json'">
        <p:output port="result" primary="true"/>
        <p:output port="report">
          <p:empty/>
        </p:output>
        <p:output port="dbk4">
          <p:empty/>
        </p:output>
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
        <tr:store-debug pipeline-step="json/http-request">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        <p:http-request name="get-json"/>
        <p:for-each name="files-iteration">
          <p:iteration-source select="/c:body/j:json/j:files/j:item"/>
          <tr:process-atlas front-end="false" name="recursive-html-processing">
            <p:documentation>Recursion FTW!</p:documentation>
            <p:with-option name="input" select="resolve-uri(., $input-uri)"/>
            <p:input port="xsl">
              <p:pipe port="xsl" step="process-atlas"/>
            </p:input>
            <p:with-option name="debug" select="$debug"/>
            <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
          </tr:process-atlas>
          <p:filter select="/c:files/html:body"/>
        </p:for-each>
      </p:when>
      <p:when test="$input-ext = 'html'">
        <p:output port="result" primary="true"/>
        <p:output port="report">
          <p:empty/>
        </p:output>
        <p:output port="dbk4">
          <p:empty/>
        </p:output>
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
        <css:expand name="add-css-attributes">
          <p:with-option name="debug" select="$debug" />
          <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
        </css:expand>
        <p:filter select="/c:body/html:html/html:body"/>
        <p:add-attribute match="/*" attribute-name="xml:base">
          <p:with-option name="attribute-value" select="$input-uri"/>
        </p:add-attribute>
        <tr:store-debug>
          <p:with-option name="pipeline-step" select="concat('single-html/', replace($input-uri, '^.+/', ''))"/>
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
      </p:when>
    </p:choose>

    <p:wrap-sequence wrapper="c:files"/>
    <p:add-attribute match="/*" attribute-name="xml:base" name="add-base">
      <p:with-option name="attribute-value" select="$input-uri"/>
    </p:add-attribute>

    <p:choose name="process-html-collection">
      <p:when test="$front-end = 'true' and not($input-ext = 'zip')">
        <p:output port="result" primary="true"/>
        <p:output port="dbk4">
          <p:pipe port="result" step="dbk4"/>
        </p:output>
        <p:output port="report">
          <p:pipe port="report" step="validate"/>
        </p:output>
        <htmltable:add-origin-atts name="htmltable-normalizer"/>

        <tr:store-debug pipeline-step="htmltables/normalized">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>

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

        <tr:store-debug pipeline-step="dbk/xinclude-with-namespace">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>

        <tr:strip-namespaces/>

        <p:store method="xml" omit-xml-declaration="false" doctype-public="-//OASIS//DTD DocBook XML V4.5//EN"
          doctype-system="http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd">
          <p:with-option name="href" select="base-uri(/*)">
            <p:pipe port="result" step="export-chapters-xsl"/>
          </p:with-option>
        </p:store>

        <tr:strip-namespaces name="dbk4">
          <p:documentation>The complete document as DocBook 4.5.</p:documentation>
          <p:input port="source">
            <p:pipe port="result" step="html2dbk"/>
          </p:input>
        </tr:strip-namespaces>

        <tr:validate-with-rng name="validate">
          <p:input port="schema">
            <p:document href="http://www.oasis-open.org/docbook/xml/4.5/rng/docbook.rng"/>
          </p:input>
        </tr:validate-with-rng>

        <p:sink/>

        <p:store method="xml" omit-xml-declaration="false" indent="true">
          <p:input port="source">
            <p:pipe port="report" step="validate"/>
          </p:input>
          <p:with-option name="href" select="concat(base-uri(/*), '.validation.xml')">
            <p:pipe port="result" step="export-chapters-xsl"/>
          </p:with-option>
        </p:store>
        
        <p:for-each name="store-chapters">
          <p:iteration-source>
            <p:pipe port="secondary" step="export-chapters-xsl"/>
          </p:iteration-source>
          <tr:strip-namespaces/>
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
          <p:with-param name="validation-suffix" select="'.validation.xml'"/>
          <p:input port="source">
            <p:pipe port="result" step="export-chapters-xsl"/>
          </p:input>
          <p:input port="stylesheet">
            <p:inline>
              <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                <xsl:param name="validation-suffix" as="xs:string"/>
                <xsl:template match="/">
                  <c:zip-manifest>
                    <xsl:apply-templates select="*/@xml:base, //xi:include/@href">
                      <xsl:with-param name="base-uri" select="replace(*/@xml:base, '^(.+/).+$', '$1')" as="xs:string"
                        tunnel="yes"/>
                    </xsl:apply-templates>
                  </c:zip-manifest>
                </xsl:template>
                <xsl:template match="@xml:base">
                  <xsl:variable name="base" select="replace(., '^.+/', '')" as="xs:string"/>
                  <c:entry name="{$base}" href="{.}" method="deflated"/>
                  <xsl:if test="normalize-space($validation-suffix)">
                    <c:entry name="{concat($base, $validation-suffix)}" href="{concat(., $validation-suffix)}" method="deflated"/>  
                  </xsl:if>
                </xsl:template>
                <xsl:template match="@href">
                  <xsl:param name="base-uri" as="xs:string?" tunnel="yes"/>
                  <c:entry name="{.}" href="{concat($base-uri, .)}" method="deflated"/>
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

        <tr:store-debug pipeline-step="zip/manifest">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>

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

      <p:when test="$front-end = 'true' and $input-ext = 'zip'">
        <p:output port="result" primary="true"/>
        <p:output port="dbk4">
          <p:pipe port="dbk4" step="read"></p:pipe>
        </p:output>
        <p:output port="report">
          <p:empty/>
        </p:output>
        <p:identity>
          <p:input port="source">
            <p:pipe port="result" step="add-base"/>
          </p:input>
        </p:identity>
      </p:when>

      <p:otherwise>
        <p:output port="result" primary="true"/>
        <p:output port="dbk4">
          <p:inline>
            <book/>
          </p:inline>
        </p:output>
        <p:output port="report"  sequence="true">
          <p:empty/>
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