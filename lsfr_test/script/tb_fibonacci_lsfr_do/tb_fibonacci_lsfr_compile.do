# compile verilog file
vlog -93 -work work $SIM_HOME/tb_fibonacci_lsfr/tb_fibonacci_lsfr.v \
$SRC_HOME/fibonacci_lsfr/fibonacci_lsfr.v

vsim -t ns -voptargs=+acc work.tb_fibonacci_lsfr 

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {tb_fibonacci_lsfr_wave.do}

view wave
view structure
view signals

run 500 us
# run -all