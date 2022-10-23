module gw_gao(
    \spi_recv_axis_data[7] ,
    \spi_recv_axis_data[6] ,
    \spi_recv_axis_data[5] ,
    \spi_recv_axis_data[4] ,
    \spi_recv_axis_data[3] ,
    \spi_recv_axis_data[2] ,
    \spi_recv_axis_data[1] ,
    \spi_recv_axis_data[0] ,
    spi_recv_axis_valid,
    spi_recv_axis_ready,
    spi_recv_axis_last,
    \spi_recv_inst/axis_tdata[7] ,
    \spi_recv_inst/axis_tdata[6] ,
    \spi_recv_inst/axis_tdata[5] ,
    \spi_recv_inst/axis_tdata[4] ,
    \spi_recv_inst/axis_tdata[3] ,
    \spi_recv_inst/axis_tdata[2] ,
    \spi_recv_inst/axis_tdata[1] ,
    \spi_recv_inst/axis_tdata[0] ,
    \spi_recv_inst/fifo_rd_data[7] ,
    \spi_recv_inst/fifo_rd_data[6] ,
    \spi_recv_inst/fifo_rd_data[5] ,
    \spi_recv_inst/fifo_rd_data[4] ,
    \spi_recv_inst/fifo_rd_data[3] ,
    \spi_recv_inst/fifo_rd_data[2] ,
    \spi_recv_inst/fifo_rd_data[1] ,
    \spi_recv_inst/fifo_rd_data[0] ,
    \spi_recv_inst/state[7] ,
    \spi_recv_inst/state[6] ,
    \spi_recv_inst/state[5] ,
    \spi_recv_inst/state[4] ,
    \spi_recv_inst/state[3] ,
    \spi_recv_inst/state[2] ,
    \spi_recv_inst/state[1] ,
    \spi_recv_inst/state[0] ,
    \spi_recv_inst/state_next[7] ,
    \spi_recv_inst/state_next[6] ,
    \spi_recv_inst/state_next[5] ,
    \spi_recv_inst/state_next[4] ,
    \spi_recv_inst/state_next[3] ,
    \spi_recv_inst/state_next[2] ,
    \spi_recv_inst/state_next[1] ,
    \spi_recv_inst/state_next[0] ,
    \spi_recv_inst/fifo_spi_recv_inst/Data[0] ,
    \spi_recv_inst/fifo_spi_recv_inst/Q[7] ,
    \spi_recv_inst/fifo_spi_recv_inst/Q[6] ,
    \spi_recv_inst/fifo_spi_recv_inst/Q[5] ,
    \spi_recv_inst/fifo_spi_recv_inst/Q[4] ,
    \spi_recv_inst/fifo_spi_recv_inst/Q[3] ,
    \spi_recv_inst/fifo_spi_recv_inst/Q[2] ,
    \spi_recv_inst/fifo_spi_recv_inst/Q[1] ,
    \spi_recv_inst/fifo_spi_recv_inst/Q[0] ,
    \spi_recv_inst/axi_aresetn ,
    \spi_recv_inst/axi_aclk ,
    \spi_recv_inst/spi_clk ,
    \spi_recv_inst/spi_mosi ,
    \spi_recv_inst/spi_cs ,
    \spi_recv_inst/axis_tvalid ,
    \spi_recv_inst/axis_tready ,
    \spi_recv_inst/axis_tlast ,
    \spi_recv_inst/fifo_rd_dv ,
    \spi_recv_inst/fifo_empty ,
    \spi_recv_inst/fifo_full ,
    spi_cs,
    sys_clk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \spi_recv_axis_data[7] ;
input \spi_recv_axis_data[6] ;
input \spi_recv_axis_data[5] ;
input \spi_recv_axis_data[4] ;
input \spi_recv_axis_data[3] ;
input \spi_recv_axis_data[2] ;
input \spi_recv_axis_data[1] ;
input \spi_recv_axis_data[0] ;
input spi_recv_axis_valid;
input spi_recv_axis_ready;
input spi_recv_axis_last;
input \spi_recv_inst/axis_tdata[7] ;
input \spi_recv_inst/axis_tdata[6] ;
input \spi_recv_inst/axis_tdata[5] ;
input \spi_recv_inst/axis_tdata[4] ;
input \spi_recv_inst/axis_tdata[3] ;
input \spi_recv_inst/axis_tdata[2] ;
input \spi_recv_inst/axis_tdata[1] ;
input \spi_recv_inst/axis_tdata[0] ;
input \spi_recv_inst/fifo_rd_data[7] ;
input \spi_recv_inst/fifo_rd_data[6] ;
input \spi_recv_inst/fifo_rd_data[5] ;
input \spi_recv_inst/fifo_rd_data[4] ;
input \spi_recv_inst/fifo_rd_data[3] ;
input \spi_recv_inst/fifo_rd_data[2] ;
input \spi_recv_inst/fifo_rd_data[1] ;
input \spi_recv_inst/fifo_rd_data[0] ;
input \spi_recv_inst/state[7] ;
input \spi_recv_inst/state[6] ;
input \spi_recv_inst/state[5] ;
input \spi_recv_inst/state[4] ;
input \spi_recv_inst/state[3] ;
input \spi_recv_inst/state[2] ;
input \spi_recv_inst/state[1] ;
input \spi_recv_inst/state[0] ;
input \spi_recv_inst/state_next[7] ;
input \spi_recv_inst/state_next[6] ;
input \spi_recv_inst/state_next[5] ;
input \spi_recv_inst/state_next[4] ;
input \spi_recv_inst/state_next[3] ;
input \spi_recv_inst/state_next[2] ;
input \spi_recv_inst/state_next[1] ;
input \spi_recv_inst/state_next[0] ;
input \spi_recv_inst/fifo_spi_recv_inst/Data[0] ;
input \spi_recv_inst/fifo_spi_recv_inst/Q[7] ;
input \spi_recv_inst/fifo_spi_recv_inst/Q[6] ;
input \spi_recv_inst/fifo_spi_recv_inst/Q[5] ;
input \spi_recv_inst/fifo_spi_recv_inst/Q[4] ;
input \spi_recv_inst/fifo_spi_recv_inst/Q[3] ;
input \spi_recv_inst/fifo_spi_recv_inst/Q[2] ;
input \spi_recv_inst/fifo_spi_recv_inst/Q[1] ;
input \spi_recv_inst/fifo_spi_recv_inst/Q[0] ;
input \spi_recv_inst/axi_aresetn ;
input \spi_recv_inst/axi_aclk ;
input \spi_recv_inst/spi_clk ;
input \spi_recv_inst/spi_mosi ;
input \spi_recv_inst/spi_cs ;
input \spi_recv_inst/axis_tvalid ;
input \spi_recv_inst/axis_tready ;
input \spi_recv_inst/axis_tlast ;
input \spi_recv_inst/fifo_rd_dv ;
input \spi_recv_inst/fifo_empty ;
input \spi_recv_inst/fifo_full ;
input spi_cs;
input sys_clk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \spi_recv_axis_data[7] ;
wire \spi_recv_axis_data[6] ;
wire \spi_recv_axis_data[5] ;
wire \spi_recv_axis_data[4] ;
wire \spi_recv_axis_data[3] ;
wire \spi_recv_axis_data[2] ;
wire \spi_recv_axis_data[1] ;
wire \spi_recv_axis_data[0] ;
wire spi_recv_axis_valid;
wire spi_recv_axis_ready;
wire spi_recv_axis_last;
wire \spi_recv_inst/axis_tdata[7] ;
wire \spi_recv_inst/axis_tdata[6] ;
wire \spi_recv_inst/axis_tdata[5] ;
wire \spi_recv_inst/axis_tdata[4] ;
wire \spi_recv_inst/axis_tdata[3] ;
wire \spi_recv_inst/axis_tdata[2] ;
wire \spi_recv_inst/axis_tdata[1] ;
wire \spi_recv_inst/axis_tdata[0] ;
wire \spi_recv_inst/fifo_rd_data[7] ;
wire \spi_recv_inst/fifo_rd_data[6] ;
wire \spi_recv_inst/fifo_rd_data[5] ;
wire \spi_recv_inst/fifo_rd_data[4] ;
wire \spi_recv_inst/fifo_rd_data[3] ;
wire \spi_recv_inst/fifo_rd_data[2] ;
wire \spi_recv_inst/fifo_rd_data[1] ;
wire \spi_recv_inst/fifo_rd_data[0] ;
wire \spi_recv_inst/state[7] ;
wire \spi_recv_inst/state[6] ;
wire \spi_recv_inst/state[5] ;
wire \spi_recv_inst/state[4] ;
wire \spi_recv_inst/state[3] ;
wire \spi_recv_inst/state[2] ;
wire \spi_recv_inst/state[1] ;
wire \spi_recv_inst/state[0] ;
wire \spi_recv_inst/state_next[7] ;
wire \spi_recv_inst/state_next[6] ;
wire \spi_recv_inst/state_next[5] ;
wire \spi_recv_inst/state_next[4] ;
wire \spi_recv_inst/state_next[3] ;
wire \spi_recv_inst/state_next[2] ;
wire \spi_recv_inst/state_next[1] ;
wire \spi_recv_inst/state_next[0] ;
wire \spi_recv_inst/fifo_spi_recv_inst/Data[0] ;
wire \spi_recv_inst/fifo_spi_recv_inst/Q[7] ;
wire \spi_recv_inst/fifo_spi_recv_inst/Q[6] ;
wire \spi_recv_inst/fifo_spi_recv_inst/Q[5] ;
wire \spi_recv_inst/fifo_spi_recv_inst/Q[4] ;
wire \spi_recv_inst/fifo_spi_recv_inst/Q[3] ;
wire \spi_recv_inst/fifo_spi_recv_inst/Q[2] ;
wire \spi_recv_inst/fifo_spi_recv_inst/Q[1] ;
wire \spi_recv_inst/fifo_spi_recv_inst/Q[0] ;
wire \spi_recv_inst/axi_aresetn ;
wire \spi_recv_inst/axi_aclk ;
wire \spi_recv_inst/spi_clk ;
wire \spi_recv_inst/spi_mosi ;
wire \spi_recv_inst/spi_cs ;
wire \spi_recv_inst/axis_tvalid ;
wire \spi_recv_inst/axis_tready ;
wire \spi_recv_inst/axis_tlast ;
wire \spi_recv_inst/fifo_rd_dv ;
wire \spi_recv_inst/fifo_empty ;
wire \spi_recv_inst/fifo_full ;
wire spi_cs;
wire sys_clk;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(spi_cs),
    .data_i({\spi_recv_axis_data[7] ,\spi_recv_axis_data[6] ,\spi_recv_axis_data[5] ,\spi_recv_axis_data[4] ,\spi_recv_axis_data[3] ,\spi_recv_axis_data[2] ,\spi_recv_axis_data[1] ,\spi_recv_axis_data[0] ,spi_recv_axis_valid,spi_recv_axis_ready,spi_recv_axis_last,\spi_recv_inst/axis_tdata[7] ,\spi_recv_inst/axis_tdata[6] ,\spi_recv_inst/axis_tdata[5] ,\spi_recv_inst/axis_tdata[4] ,\spi_recv_inst/axis_tdata[3] ,\spi_recv_inst/axis_tdata[2] ,\spi_recv_inst/axis_tdata[1] ,\spi_recv_inst/axis_tdata[0] ,\spi_recv_inst/fifo_rd_data[7] ,\spi_recv_inst/fifo_rd_data[6] ,\spi_recv_inst/fifo_rd_data[5] ,\spi_recv_inst/fifo_rd_data[4] ,\spi_recv_inst/fifo_rd_data[3] ,\spi_recv_inst/fifo_rd_data[2] ,\spi_recv_inst/fifo_rd_data[1] ,\spi_recv_inst/fifo_rd_data[0] ,\spi_recv_inst/state[7] ,\spi_recv_inst/state[6] ,\spi_recv_inst/state[5] ,\spi_recv_inst/state[4] ,\spi_recv_inst/state[3] ,\spi_recv_inst/state[2] ,\spi_recv_inst/state[1] ,\spi_recv_inst/state[0] ,\spi_recv_inst/state_next[7] ,\spi_recv_inst/state_next[6] ,\spi_recv_inst/state_next[5] ,\spi_recv_inst/state_next[4] ,\spi_recv_inst/state_next[3] ,\spi_recv_inst/state_next[2] ,\spi_recv_inst/state_next[1] ,\spi_recv_inst/state_next[0] ,\spi_recv_inst/fifo_spi_recv_inst/Data[0] ,\spi_recv_inst/fifo_spi_recv_inst/Q[7] ,\spi_recv_inst/fifo_spi_recv_inst/Q[6] ,\spi_recv_inst/fifo_spi_recv_inst/Q[5] ,\spi_recv_inst/fifo_spi_recv_inst/Q[4] ,\spi_recv_inst/fifo_spi_recv_inst/Q[3] ,\spi_recv_inst/fifo_spi_recv_inst/Q[2] ,\spi_recv_inst/fifo_spi_recv_inst/Q[1] ,\spi_recv_inst/fifo_spi_recv_inst/Q[0] ,\spi_recv_inst/axi_aresetn ,\spi_recv_inst/axi_aclk ,\spi_recv_inst/spi_clk ,\spi_recv_inst/spi_mosi ,\spi_recv_inst/spi_cs ,\spi_recv_inst/axis_tvalid ,\spi_recv_inst/axis_tready ,\spi_recv_inst/axis_tlast ,\spi_recv_inst/fifo_rd_dv ,\spi_recv_inst/fifo_empty ,\spi_recv_inst/fifo_full }),
    .clk_i(sys_clk)
);

endmodule
