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
vcom-$VER -work $LIB ../sourcecode/src/vhdl/aes128Pkg.vhd
vcom-$VER -work $LIB ../sourcecode/src/vhdl/sbox.vhd
vcom-$VER -work $LIB ../sourcecode/src/vhdl/subWord.vhd
vcom-$VER -work $LIB ../sourcecode/src/vhdl/keyExpansion.vhd
vcom-$VER -work $LIB ../sourcecode/src/vhdl/subMatrix.vhd
vcom-$VER -work $LIB ../sourcecode/src/vhdl/mixColumn.vhd
vcom-$VER -work $LIB ../sourcecode/src/vhdl/mixMatrix.vhd
vcom-$VER -work $LIB ../sourcecode/src/vhdl/cipherRound.vhd
vcom-$VER -work $LIB ../sourcecode/src/vhdl/aes128.vhd

## Compile the required SystemVerilog source files for the test bench.
vlog-$VER -work $LIB -sv ../sourcecode/src/tb/utils/mbgh_utils_pkg.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/tb/aes128_pkg/aes128_ifc.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/tb/aes128_pkg/aes128_wrapper.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/tb/aes128_pkg/aes128_pkg.sv
vlog-$VER -work $LIB -sv ../sourcecode/src/tb/aes128_pkg/aes128_top.sv

## List available design entities in the library.
vdir-$VER -lib $LIB

