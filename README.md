# ora2dbk

HTMLBook → DocBook 4.5 conversion and postprocessing of asciidoc’s DocBook conversion output.

We’re not doing this because we’re die-hard DocBook proponents. It’s for German typesetters who receive translations of Atlas books written in HTMLBook and asciidoc. Until these kinds of books are also produced in Atlas, they’re still sent to typesetters who have existing layouts & workflows based on DocBook 4.5.

Sample invocation:

    calabash/calabash.sh xpl/htmlbook2docbook.xpl json=../path/to/atlas.json

The ```json``` option may also be a file: or HTTP URI. It is optional. If it is omitted, a standalone HTMLBook document is expected on the source port – if we figure out how to deal with the named character entitities. Maybe we’ll have to preprocess them using validator.nu. 

The parsing of the files accessed through processing the the JSON should also be parsed from within Calabash using validator.nu, but this isn’t working yet.  