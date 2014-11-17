# Ignore integer warnings from IEEE 'numeric_std' at time 0.
set NumericStdNoWarnings 1;
run 0;
set NumericStdNoWarnings 0;

set NoQuitOnFinish 1
onbreak {resume}
run -all