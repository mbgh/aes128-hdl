## We use Natural Docs in order to generate the documentation for the
## SystemVerilog source code directly from the inline comments.

## The directory to be searched recursively for SystemVerilog source files (as
## well as supplementary material such as a license file, a summary, etc.) to
## be documented using Natural Docs.
INP = /home/michmueh/repos/git/aes128-hdl/src/tb

## The output directory into which the created documentation should be written.
OUT = html/tb

## The directory to be used for the project-specific files, which are required
## during each run of Natural Docs.
PRO = natdoc

## The path to the Natural Docs perl script.
BIN = ~/software/naturaldocs/NaturalDocs-1.52/NaturalDocs

all: doc view

## You may need to run the doc target multiple times in order to build the HTML
## menu correctly the first time.
doc:
	mkdir -p $(OUT)
	mkdir -p $(PRO)
	$(BIN) -i $(INP) -o HTML $(OUT) -p $(PRO)
	cp Menu.txt $(PRO)

view:
	firefox ./$(OUT)/index.html

clean:
	rm -rf $(OUT)
	rm -rf $(PRO)