#!/bin/bash

## Some settings for the compile script.
VER="10.3a"       # QuestaSim version to be used
LIB="work"        # Library name in which to compile

## Remove existing library since we want to start from scratch.
if [ -d $LIB ]; then
 rm -rf $LIB
fi

## Create new library.
vlib-$VER $LIB

## Compile required VHDL source files of the design under test.
vlog-$VER -work $LIB -sv ../sourcecode/src/sv/aes128Pkg.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/sv/sbox.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/sv/subWord.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/sv/keyExpansion.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/sv/subMatrix.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/sv/mixColumn.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/sv/mixMatrix.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/sv/cipherRound.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/sv/aes128.sv

## Compile the required SystemVerilog source files for the test bench.
vlog-$VER -work $LIB -sv ../sourcecode/src/tb/utils/mbgh_utils_pkg.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/tb/aes128_pkg/aes128_ifc.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/tb/aes128_pkg/aes128_wrapper.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/tb/aes128_pkg/aes128_pkg.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/tb/aes128_pkg/aes128_top.sv

## List available design entities in the library.
vdir-$VER -lib $LIB

