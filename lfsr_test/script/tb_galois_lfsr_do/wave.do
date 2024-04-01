onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb_top
add wave -noupdate -radix unsigned /tb_galois_lfsr/BIT_WIDTH
add wave -noupdate /tb_galois_lfsr/clk
add wave -noupdate /tb_galois_lfsr/cnt_temp
add wave -noupdate /tb_galois_lfsr/seed_done
add wave -noupdate /tb_galois_lfsr/enable_r
add wave -noupdate /tb_galois_lfsr/enable
add wave -noupdate /tb_galois_lfsr/i_load_evt
add wave -noupdate /tb_galois_lfsr/i_seed_data
add wave -noupdate /tb_galois_lfsr/w_lfsr_vld
add wave -noupdate /tb_galois_lfsr/w_lfsr_done
add wave -noupdate /tb_galois_lfsr/w_lfsr_data
add wave -noupdate /tb_galois_lfsr/o_lfsr_vld
add wave -noupdate /tb_galois_lfsr/o_lfsr_done
add wave -noupdate /tb_galois_lfsr/o_lfsr_data
add wave -noupdate /tb_galois_lfsr/w_lfsr_vld_r
add wave -noupdate /tb_galois_lfsr/w_lfsr_done_r
add wave -noupdate /tb_galois_lfsr/w_lfsr_data_r
add wave -noupdate /tb_galois_lfsr/err_flag
add wave -noupdate /tb_galois_lfsr/stop_sim
add wave -noupdate /tb_galois_lfsr/stop_sim_dly
# add wave -noupdate /tb_galois_lfsr/sss
add wave -noupdate -divider lfsr_gen
add wave -noupdate /tb_galois_lfsr/lfsr_gen/*
add wave -noupdate -divider lfsr_check
add wave -noupdate /tb_galois_lfsr/lfsr_check/*
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {133564 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {525 us}
