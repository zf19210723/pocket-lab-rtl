onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/clk
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/rstn
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/unpack_busy
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/unpack_en
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/unpack_pack_id
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/unpack_pack_length
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/unpack_pack_data
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/unpack_pack_type
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/pack_busy
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/pack_dv
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/pack_pack_id
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/pack_pack_length
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/pack_pack_data
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/pack_pack_type
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/axi_awaddr
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/axi_awvalid
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/axi_awready
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/axi_wdata
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/axi_wvalid
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/axi_wready
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/axi_wlast
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/axi_bresp
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/axi_bvalid
add wave -noupdate /bench/main_inst/ccu_inst/dac_fsm_inst/axi_bready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {513306705 ps} {513876349 ps}
