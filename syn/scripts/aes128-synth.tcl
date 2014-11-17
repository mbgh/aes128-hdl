################################################################################

## Name of the VHDL entity to be evaluated.
set entity aes128

## Name of the library to be used.
set lib work

## Directory for the reports.
set reportsDir "./reports"

## The clock period to be used.
set period 2

################################################################################

## Start from a fresh design.
remove_design -design
sh rm -rf $lib/*

## Analyze the source files.
analyze -library $lib -format vhdl { \
  ../sourcecode/src/vhdl/aes128Pkg.vhd \
  ../sourcecode/src/vhdl/sbox.vhd \
  ../sourcecode/src/vhdl/subWord.vhd \
  ../sourcecode/src/vhdl/keyExpansion.vhd \
  ../sourcecode/src/vhdl/subMatrix.vhd \
  ../sourcecode/src/vhdl/mixColumn.vhd \
  ../sourcecode/src/vhdl/mixMatrix.vhd \
  ../sourcecode/src/vhdl/cipherRound.vhd \
  ../sourcecode/src/vhdl/aes128.vhd
}

## Elaborate the current configuration.
elaborate $entity

## Set the clock period constraint (in nanoseconds).
create_clock Clk_CI -period $period

## Start compilation.
compile_ultra
				
## Save compiled design.
write -f ddc -h -o ${entity}_compiled.ddc

## Create some reports.
file mkdir $reportsDir
report_area -hierarchy -nosplit                                                           > $reportsDir/area.rpt
report_timing -from [all_registers -clock_pins] -to [all_registers -data_pins]            > $reportsDir/timing_ss.rpt
report_timing -from [all_inputs] -to [all_registers -data_pins] -max_paths 10 -path end   > $reportsDir/timing_is.rpt
report_timing -from [all_registers -clock_pins] -to [all_outputs] -max_paths 10 -path end > $reportsDir/timing_so.rpt
report_timing -from [all_inputs] -to [all_outputs]                                        > $reportsDir/timing_io.rpt

