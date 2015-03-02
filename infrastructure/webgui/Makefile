IN_FILE_COPY = $(OUT_DIR)/$(notdir $(IN_FILE))
DEBUG_DIR  = $(OUT_DIR)/debug

conversion:
	if [ $(IN_FILE) != $(IN_FILE_COPY) ]; then cp $(IN_FILE) $(IN_FILE_COPY); fi
	chmod 664 $(IN_FILE_COPY)
	cd ora2dbk && \
		calabash/calabash.sh \
		-o dbk4=dbk.xml -o parsed-html=parsed.xhtml \
		xpl/htmlbook2docbook.xpl \
		input=$(IN_FILE_COPY) \
		debug=yes debug-dir-uri=file:$(DEBUG_DIR)
	rm $(IN_FILE_COPY)
	cp $(DEBUG_DIR)/error.log $(OUT_DIR)/log.txt

progress:
	@echo konvertiere...

actions:
	@echo ""