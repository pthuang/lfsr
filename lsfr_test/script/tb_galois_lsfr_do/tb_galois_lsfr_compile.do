# compile verilog file
vlog -93 -work work $SIM_HOME/tb_galois_lsfr/tb_galois_lsfr.v \
$SRC_HOME/galois_lsfr/galois_lsfr.v


vsim -t ns -voptargs=+acc work.tb_galois_lsfr 

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {tb_galois_lsfr_wave.do}

view wave
view structure
view signals

run 500 us
# run -all