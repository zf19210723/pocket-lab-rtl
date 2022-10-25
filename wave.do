onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/clk
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/rstn
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/txd_data
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/rxd_flag
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/pack_en
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/pack_busy
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/pack_id
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/pack_length
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/pack_data
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/pack_type
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/fifo_ccu_pack_data_buffer_rdata
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/fifo_ccu_pack_data_buffer_rdv
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/fifo_ccu_pack_data_buffer_empty
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/fifo_ccu_pack_data_buffer_full
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/fifo_ccu_pack_data_buffer_wnum
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/state
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/state_next
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/pack_id_b
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/pack_length_b
add wave -noupdate /bench/main_inst/ccu_inst/ccu_pack_inst/pack_type_b
add wave -noupdate /bench/main_inst/spi_slaver_inst/clk
add wave -noupdate /bench/main_inst/spi_slaver_inst/rstn
add wave -noupdate /bench/main_inst/spi_slaver_inst/cs
add wave -noupdate /bench/main_inst/spi_slaver_inst/sck
add wave -noupdate /bench/main_inst/spi_slaver_inst/MOSI
add wave -noupdate /bench/main_inst/spi_slaver_inst/MISO
add wave -noupdate /bench/main_inst/spi_slaver_inst/rxd_out
add wave -noupdate /bench/main_inst/spi_slaver_inst/txd_data
add wave -noupdate /bench/main_inst/spi_slaver_inst/rxd_flag
add wave -noupdate /bench/main_inst/spi_slaver_inst/rxd_data
add wave -noupdate /bench/main_inst/spi_slaver_inst/sck_r0
add wave -noupdate /bench/main_inst/spi_slaver_inst/sck_r1
add wave -noupdate /bench/main_inst/spi_slaver_inst/sck_n
add wave -noupdate /bench/main_inst/spi_slaver_inst/sck_p
add wave -noupdate /bench/main_inst/spi_slaver_inst/rxd_flag_r
add wave -noupdate /bench/main_inst/spi_slaver_inst/rxd_state
add wave -noupdate /bench/main_inst/spi_slaver_inst/rxd_flag_r0
add wave -noupdate /bench/main_inst/spi_slaver_inst/rxd_flag_r1
add wave -noupdate /bench/main_inst/spi_slaver_inst/txd_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {127 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {1 ns}
