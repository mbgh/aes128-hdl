***** ABOUT *****

This file provides a quick introduction on how to generate the documentation for
the SystemVerilog HDL source code directly from the inline comments.


***** REQUIREMENTS *****

We use Natural Docs [1] in order to generate the documentation for the HDL
source files. We used Natural Docs version 1.52 during the development of the
design. Although generating the documentation may work with an older version of
Natural Docs, we recommend using the latest one available from [1].

Since Natural Docs does not support SystemVerilog per default, you need to
configure it accordingly. In order to do so, download the "Languages.txt" and
the "Topics.txt" files from [2] and add their content to your personal Natural
Docs configuration (either globally into the Natural Docs installation directory
or locally only for this project).

Moreover, we make use of a patch for Natural Docs, which allows us to use the
back tick (`) and the pipe (|) symbol in order to generate italic type text and a
typewriter font, respectively. You can obtain the patch from [3], but may need
to adapt it to your personal Natural Docs version as it has been created for
version 1.35. You can then apply the patch as follows:

   > cd <NATURAL_DOCS_ROOT>/Modules/NaturalDocs/Parser/
   > patch Native.pm < italic_tt.patch


***** CREATING THE HDL DOCUMENTATION *****

1. Open the provided Makefile and adapt the paths to the SystemVerilog sources
   and the path to the Natural Docs installation to your own needs.

2. Run the Makefile (if you are running an operating system where no "GNU Make"
   is supported, consider running Natural Docs directly):

   > make

3. If the Internet browser, predefined in the Makefile, is available on your
   operation system, the documentation should launch automatically. If not, open
   the generated HTML documentation manually, e.g.:

   > firefox ./<OUT>/index.html


***** REFERENCES

[1] http://www.naturaldocs.org/
[2] http://sourceforge.net/p/uvm/code/ci/master/tree/natural_docs/Config/
[3] http://sourceforge.net/p/naturaldocs/feature-requests/151/
