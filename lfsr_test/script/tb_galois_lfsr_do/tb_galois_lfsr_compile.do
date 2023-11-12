# compile verilog file
vlog -93 -work work $SIM_HOME/tb_galois_lfsr/tb_galois_lfsr.v \
$SRC_HOME/imports/galois_lfsr/galois_lfsr.v


vsim -t ns -voptargs=+acc work.tb_galois_lfsr 

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {tb_galois_lfsr_wave.do}

view wave
view structure
view signals

run 500 us
# run -all