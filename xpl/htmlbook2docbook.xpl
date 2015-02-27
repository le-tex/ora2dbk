<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:j="http://marklogic.com/json"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect" 
  version="1.0"
  name="process-json">

  <p:option name="json" required="false">
    <p:documentation>URI or OS file name, may also be relative. If omitted, an XHTML source document
    is expected.</p:documentation>
  </p:option>
  
  <p:input port="html" primary="true">
    <p:documentation>If the json option is not specified, an HTMLBook document is expected here.</p:documentation>
    <p:empty/>
  </p:input>
  
  <p:output port="result" primary="true"/>

  <p:import href="http://transpect.le-tex.de/xproc-util/file-uri/file-uri.xpl"/>

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Calabash must be invoked with the <a href="http://xmlcalabash.com/docs/reference/langext.html#ext.transparent-json">transparent-json extension</a>
      for the JSON parsing.</p>
  </p:documentation>

  <p:choose>
    <p:when test="p:value-available('json')">
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
        <p:http-request/>
        <p:for-each>
          <p:iteration-source select="/c:body/j:json/j:files/j:item[. = 'dedication.html']"/>
          <p:add-attribute attribute-name="href" match="/*">
            <p:input port="source">
              <p:inline>
                <c:request method="GET" />
              </p:inline>
            </p:input>
            <p:with-option name="attribute-value" select="resolve-uri(., $json-uri)"/>
          </p:add-attribute>
          <p:http-request/>
          <p:unescape-markup content-type="text/html"/>
        </p:for-each>
        <p:wrap-sequence wrapper="files"/>
      </p:group>    
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>


</p:declare-step>