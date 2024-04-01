# compile systemverilog file
# vlog -93 -sv -work work $SimHome/tb_ddr_ctrl/tb_ddr_ctrl.sv 

# compile verilog file
vlog -93 -work work $DoHome/glbl.v \
					$SimHome/tb_galois_lfsr/tb_galois_lfsr.v \
					$SrcHome/imports/galois_lfsr/galois_lfsr.v

# compile VHDL file
# vcom -93 -work work $SrcHome/ip/ddr_mult/sim/ddr_mult.vhd

vsim -t ns -voptargs=+acc -L work -L blk_mem_gen_v8_4_4 -L dist_mem_gen_v8_0_13 -L xbip_bram18k_v3_0_6 \
							-L unisims_ver -L unimacro_ver -L secureip work.tb_galois_lfsr work.glbl  

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do $WaveHome/wave.do  

view wave
view structure
view signals

log -r */

# set simulation time(us)
set sim_time 500

run $sim_time us 
# run -all