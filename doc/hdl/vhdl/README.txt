***** ABOUT

This file provides a quick introduction on how to generate the documentation
from the inline comments of the HDL source files of the provided design.


***** REQUIREMENTS

In order to generate the documentation for the HDL source files, you need to
have Doxygen [1] installed.


***** CREATING THE HDL DOCUMENTATION

1. Make sure that the "INPUT" value in the "*.Doxyfile" is set
   correctly. Basically, it should contain the present directory and the
   directory where the respective module can be found, e.g.:

   INPUT = . ../src/hdl/<DESIGN>

2. Run the Makefile (if you are running an operating system where no "GNU Make"
   is supported, consider running Doxygen directly):

   > make

3. If the Internet browser, predefined in the Makefile, is available on your
   operation system, the documentation should launch automatically. If not, open
   the generated HTML documentation manually, e.g.:

   > firefox ./html/index.html


***** REFERENCES

[1] http://www.stack.nl/~dimitri/doxygen/index.html
