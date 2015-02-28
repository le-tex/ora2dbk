# ora2dbk

HTMLBook → DocBook 4.5 conversion and postprocessing of asciidoc’s DocBook conversion output.

We’re not doing this because we’re die-hard DocBook proponents. It’s for German typesetters who receive translations of Atlas books written in HTMLBook and asciidoc. Until these kinds of books are also produced in Atlas, they’re still sent to typesetters who have existing layouts & workflows based on DocBook 4.5.

Sample invocation:

    calabash/calabash.sh -o parsed-html=parsed.xhtml xpl/htmlbook2docbook.xpl json=../path/to/atlas.json

The ```json``` option may also be a file: or HTTP URI. It is optional. If it is omitted, a standalone HTMLBook document is expected on the source port – if we figure out how to deal with the named character entitities. Maybe we’ll have to preprocess them using validator.nu. 

If you use the json option, you can restrict conversion to a certain item in the JSON’s "files" list by specifying an additional ```file``` option, for example, ```file=dedication.html```.

You can override the default XSLT by importing it and submitting your importing stylesheet to the xsl port.

We’ll output namespaced DocBook (which may or may not be DocBook 5.x – it will probably be DocBook 4.5 in the DocBook namespace) on the result port and DocBook 4.5 on a to-be-implemented dbk4 port. 
