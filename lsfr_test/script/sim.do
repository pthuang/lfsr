quit -sim  
.main clear

# shift to upper level direction
cd .. 

set BASE_HOME [pwd]

set DO_HOME  $BASE_HOME/script/ 
set SRC_HOME $BASE_HOME/src/ 
set SIM_HOME $BASE_HOME/sim/ 

cd $DO_HOME 

vlib ./work
vlib ./work/modelsim_lib

vmap work ./work/modelsim_lib

do {./tb_galois_lsfr_do/tb_galois_lsfr_compile.do}
# do {./tb_fibonacci_lsfr_do/tb_fibonacci_lsfr_compile.do}
 
