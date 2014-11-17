#!/bin/bash

## Some settings for the simulation start script.
VER="10.3a"           # ModelSim version to be used.
LIB="work"            # Library name to be simulated.
TAR="aes128_top"      # Target entity to be simulated.
TEST="aes128_test"    # The test to be run.
FILE_W="28"           # Width of the file name string printed by the simulator logger.
HIER_W="40"           # Width of the hierarchy string printed by the simulator logger.
UVM_VERB="UVM_LOW"    # The UVM verbosity to be used (UVM_DEBUG = Show all; UVM_LOW = Most restrictive)

## The actual start command for ModelSim.
vsim-$VER -lib $LIB \
	-gui -do 'source ./waves/wave-rtl.do; source ./scripts/rtl_run.tcl;' \
	-voptargs='+acc' \
  +UVM_NO_RELNOTES \
  +UVM_TESTNAME=$TEST \
  +UVM_VERBOSITY=$UVM_VERB \
  +fname_width=$FILE_W \
  +hier_width=$HIER_W \
	$TAR &
