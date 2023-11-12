# compile verilog file
vlog -93 -work work $SIM_HOME/tb_fibonacci_lfsr/tb_fibonacci_lfsr.v \
$SRC_HOME/imports/fibonacci_lfsr/fibonacci_lfsr.v

vsim -t ns -voptargs=+acc work.tb_fibonacci_lfsr 

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {tb_fibonacci_lfsr_wave.do}

view wave
view structure
view signals

run 500 us
# run -all