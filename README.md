# ora2dbk

HTMLBook → DocBook 4.5 conversion and postprocessing of asciidoc’s DocBook conversion output.

We’re not doing this because we’re die-hard DocBook proponents. It’s for German typesetters who receive translations of Atlas books written in HTMLBook and asciidoc. Until these kinds of books are also produced in Atlas, they’re still sent to typesetters who have existing layouts & workflows based on DocBook 4.5.

## Prerequisites

 * ext (see http://nopugs.com/ext-tutorial)
 * Java 1.7 or newer

## Initial Checkout

In the top-level git repo folder, call:

    ext co

For updates, call:

    ext up

## Sample invocation

    calabash/calabash.sh -o dbk4=dbk.xml -o parsed-html=parsed.xhtml -o result=/dev/null xpl/htmlbook2docbook.xpl input=../path/to/atlas.json

The ```input``` option may also be a file: or HTTP URI. It may point to a JSON file or to a single HTMLBook file.   

You can override the default XSLT by importing it and submitting your importing stylesheet to the xsl port.

The output files will be split in the same manner as the input files and included via XInclude in a wrapper file that contains the /book element. 
If the input is in ../path/to/, then the output is in ../path/to.out/ 

The result files will also be zipped into ../path/to.zip

The zip file will also contain a file atlas.validation.xml. It contains errors like this:

    <c:error xpath="/book/preface[3]/indexterm[1]">element "indexterm" not allowed 
    here; expected the element end-tag or element "bibliography", 
    "glossary", "index", "lot", "sect1" or "toc"</c:error> 

When editing atlas.xml, you can paste the XPath ```/book/preface[3]/indexterm[1]``` into an oXygen or another XInclude-aware tool that lets you search for XPath expressions
in order to jump to the error. (On 2nd thought: If you’re using oXygen, you’d use the built-in validation anyway.)
