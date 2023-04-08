onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb_top
add wave -noupdate -radix unsigned /tb_galois_lsfr/BIT_WIDTH
add wave -noupdate /tb_galois_lsfr/clk
add wave -noupdate /tb_galois_lsfr/cnt_temp
add wave -noupdate /tb_galois_lsfr/seed_done
add wave -noupdate /tb_galois_lsfr/enable_r
add wave -noupdate /tb_galois_lsfr/enable
add wave -noupdate /tb_galois_lsfr/i_load_evt
add wave -noupdate /tb_galois_lsfr/i_seed_data
add wave -noupdate /tb_galois_lsfr/w_lsfr_vld
add wave -noupdate /tb_galois_lsfr/w_lsfr_done
add wave -noupdate /tb_galois_lsfr/w_lsfr_data
add wave -noupdate /tb_galois_lsfr/o_lsfr_vld
add wave -noupdate /tb_galois_lsfr/o_lsfr_done
add wave -noupdate /tb_galois_lsfr/o_lsfr_data
add wave -noupdate /tb_galois_lsfr/w_lsfr_vld_r
add wave -noupdate /tb_galois_lsfr/w_lsfr_done_r
add wave -noupdate /tb_galois_lsfr/w_lsfr_data_r
add wave -noupdate /tb_galois_lsfr/err_flag
add wave -noupdate /tb_galois_lsfr/stop_sim
add wave -noupdate /tb_galois_lsfr/stop_sim_dly
add wave -noupdate -divider lsfr_gen
add wave -noupdate /tb_galois_lsfr/lsfr_gen/*
add wave -noupdate -divider lsfr_check
add wave -noupdate /tb_galois_lsfr/lsfr_check/*
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
