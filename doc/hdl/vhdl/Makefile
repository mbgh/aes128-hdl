## The name of the design to be documented.
DESIGN = aes128

## The path to the Doxygen binary.
BIN = ~/software/doxygen/doxygen-1.8.6/bin/

all: doc view

doc:
	$(BIN)/doxygen $(DESIGN).Doxyfile

view:
	firefox ./html/index.html

clean:
	rm -rf ./html