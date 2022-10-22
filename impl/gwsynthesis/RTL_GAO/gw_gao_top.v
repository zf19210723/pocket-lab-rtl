module gw_gao(
    \dac_inst/bram_dac_inst/dout[7] ,
    \dac_inst/bram_dac_inst/dout[6] ,
    \dac_inst/bram_dac_inst/dout[5] ,
    \dac_inst/bram_dac_inst/dout[4] ,
    \dac_inst/bram_dac_inst/dout[3] ,
    \dac_inst/bram_dac_inst/dout[2] ,
    \dac_inst/bram_dac_inst/dout[1] ,
    \dac_inst/bram_dac_inst/dout[0] ,
    \dac_inst/bram_dac_inst/ada[15] ,
    \dac_inst/bram_dac_inst/ada[14] ,
    \dac_inst/bram_dac_inst/ada[13] ,
    \dac_inst/bram_dac_inst/ada[12] ,
    \dac_inst/bram_dac_inst/ada[11] ,
    \dac_inst/bram_dac_inst/ada[10] ,
    \dac_inst/bram_dac_inst/ada[9] ,
    \dac_inst/bram_dac_inst/ada[8] ,
    \dac_inst/bram_dac_inst/ada[7] ,
    \dac_inst/bram_dac_inst/ada[6] ,
    \dac_inst/bram_dac_inst/ada[5] ,
    \dac_inst/bram_dac_inst/ada[4] ,
    \dac_inst/bram_dac_inst/ada[3] ,
    \dac_inst/bram_dac_inst/ada[2] ,
    \dac_inst/bram_dac_inst/ada[1] ,
    \dac_inst/bram_dac_inst/ada[0] ,
    \dac_inst/bram_dac_inst/din[7] ,
    \dac_inst/bram_dac_inst/din[6] ,
    \dac_inst/bram_dac_inst/din[5] ,
    \dac_inst/bram_dac_inst/din[4] ,
    \dac_inst/bram_dac_inst/din[3] ,
    \dac_inst/bram_dac_inst/din[2] ,
    \dac_inst/bram_dac_inst/din[1] ,
    \dac_inst/bram_dac_inst/din[0] ,
    \dac_inst/bram_dac_inst/adb[15] ,
    \dac_inst/bram_dac_inst/adb[14] ,
    \dac_inst/bram_dac_inst/adb[13] ,
    \dac_inst/bram_dac_inst/adb[12] ,
    \dac_inst/bram_dac_inst/adb[11] ,
    \dac_inst/bram_dac_inst/adb[10] ,
    \dac_inst/bram_dac_inst/adb[9] ,
    \dac_inst/bram_dac_inst/adb[8] ,
    \dac_inst/bram_dac_inst/adb[7] ,
    \dac_inst/bram_dac_inst/adb[6] ,
    \dac_inst/bram_dac_inst/adb[5] ,
    \dac_inst/bram_dac_inst/adb[4] ,
    \dac_inst/bram_dac_inst/adb[3] ,
    \dac_inst/bram_dac_inst/adb[2] ,
    \dac_inst/bram_dac_inst/adb[1] ,
    \dac_inst/bram_dac_inst/adb[0] ,
    \dac_inst/bram_dac_inst/cea ,
    \dac_inst/bram_dac_inst/reseta ,
    \dac_inst/bram_dac_inst/ceb ,
    \dac_inst/bram_dac_inst/resetb ,
    \dac_inst/bram_dac_inst/oce ,
    \triggers[0] ,
    sys_clk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \dac_inst/bram_dac_inst/dout[7] ;
input \dac_inst/bram_dac_inst/dout[6] ;
input \dac_inst/bram_dac_inst/dout[5] ;
input \dac_inst/bram_dac_inst/dout[4] ;
input \dac_inst/bram_dac_inst/dout[3] ;
input \dac_inst/bram_dac_inst/dout[2] ;
input \dac_inst/bram_dac_inst/dout[1] ;
input \dac_inst/bram_dac_inst/dout[0] ;
input \dac_inst/bram_dac_inst/ada[15] ;
input \dac_inst/bram_dac_inst/ada[14] ;
input \dac_inst/bram_dac_inst/ada[13] ;
input \dac_inst/bram_dac_inst/ada[12] ;
input \dac_inst/bram_dac_inst/ada[11] ;
input \dac_inst/bram_dac_inst/ada[10] ;
input \dac_inst/bram_dac_inst/ada[9] ;
input \dac_inst/bram_dac_inst/ada[8] ;
input \dac_inst/bram_dac_inst/ada[7] ;
input \dac_inst/bram_dac_inst/ada[6] ;
input \dac_inst/bram_dac_inst/ada[5] ;
input \dac_inst/bram_dac_inst/ada[4] ;
input \dac_inst/bram_dac_inst/ada[3] ;
input \dac_inst/bram_dac_inst/ada[2] ;
input \dac_inst/bram_dac_inst/ada[1] ;
input \dac_inst/bram_dac_inst/ada[0] ;
input \dac_inst/bram_dac_inst/din[7] ;
input \dac_inst/bram_dac_inst/din[6] ;
input \dac_inst/bram_dac_inst/din[5] ;
input \dac_inst/bram_dac_inst/din[4] ;
input \dac_inst/bram_dac_inst/din[3] ;
input \dac_inst/bram_dac_inst/din[2] ;
input \dac_inst/bram_dac_inst/din[1] ;
input \dac_inst/bram_dac_inst/din[0] ;
input \dac_inst/bram_dac_inst/adb[15] ;
input \dac_inst/bram_dac_inst/adb[14] ;
input \dac_inst/bram_dac_inst/adb[13] ;
input \dac_inst/bram_dac_inst/adb[12] ;
input \dac_inst/bram_dac_inst/adb[11] ;
input \dac_inst/bram_dac_inst/adb[10] ;
input \dac_inst/bram_dac_inst/adb[9] ;
input \dac_inst/bram_dac_inst/adb[8] ;
input \dac_inst/bram_dac_inst/adb[7] ;
input \dac_inst/bram_dac_inst/adb[6] ;
input \dac_inst/bram_dac_inst/adb[5] ;
input \dac_inst/bram_dac_inst/adb[4] ;
input \dac_inst/bram_dac_inst/adb[3] ;
input \dac_inst/bram_dac_inst/adb[2] ;
input \dac_inst/bram_dac_inst/adb[1] ;
input \dac_inst/bram_dac_inst/adb[0] ;
input \dac_inst/bram_dac_inst/cea ;
input \dac_inst/bram_dac_inst/reseta ;
input \dac_inst/bram_dac_inst/ceb ;
input \dac_inst/bram_dac_inst/resetb ;
input \dac_inst/bram_dac_inst/oce ;
input \triggers[0] ;
input sys_clk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \dac_inst/bram_dac_inst/dout[7] ;
wire \dac_inst/bram_dac_inst/dout[6] ;
wire \dac_inst/bram_dac_inst/dout[5] ;
wire \dac_inst/bram_dac_inst/dout[4] ;
wire \dac_inst/bram_dac_inst/dout[3] ;
wire \dac_inst/bram_dac_inst/dout[2] ;
wire \dac_inst/bram_dac_inst/dout[1] ;
wire \dac_inst/bram_dac_inst/dout[0] ;
wire \dac_inst/bram_dac_inst/ada[15] ;
wire \dac_inst/bram_dac_inst/ada[14] ;
wire \dac_inst/bram_dac_inst/ada[13] ;
wire \dac_inst/bram_dac_inst/ada[12] ;
wire \dac_inst/bram_dac_inst/ada[11] ;
wire \dac_inst/bram_dac_inst/ada[10] ;
wire \dac_inst/bram_dac_inst/ada[9] ;
wire \dac_inst/bram_dac_inst/ada[8] ;
wire \dac_inst/bram_dac_inst/ada[7] ;
wire \dac_inst/bram_dac_inst/ada[6] ;
wire \dac_inst/bram_dac_inst/ada[5] ;
wire \dac_inst/bram_dac_inst/ada[4] ;
wire \dac_inst/bram_dac_inst/ada[3] ;
wire \dac_inst/bram_dac_inst/ada[2] ;
wire \dac_inst/bram_dac_inst/ada[1] ;
wire \dac_inst/bram_dac_inst/ada[0] ;
wire \dac_inst/bram_dac_inst/din[7] ;
wire \dac_inst/bram_dac_inst/din[6] ;
wire \dac_inst/bram_dac_inst/din[5] ;
wire \dac_inst/bram_dac_inst/din[4] ;
wire \dac_inst/bram_dac_inst/din[3] ;
wire \dac_inst/bram_dac_inst/din[2] ;
wire \dac_inst/bram_dac_inst/din[1] ;
wire \dac_inst/bram_dac_inst/din[0] ;
wire \dac_inst/bram_dac_inst/adb[15] ;
wire \dac_inst/bram_dac_inst/adb[14] ;
wire \dac_inst/bram_dac_inst/adb[13] ;
wire \dac_inst/bram_dac_inst/adb[12] ;
wire \dac_inst/bram_dac_inst/adb[11] ;
wire \dac_inst/bram_dac_inst/adb[10] ;
wire \dac_inst/bram_dac_inst/adb[9] ;
wire \dac_inst/bram_dac_inst/adb[8] ;
wire \dac_inst/bram_dac_inst/adb[7] ;
wire \dac_inst/bram_dac_inst/adb[6] ;
wire \dac_inst/bram_dac_inst/adb[5] ;
wire \dac_inst/bram_dac_inst/adb[4] ;
wire \dac_inst/bram_dac_inst/adb[3] ;
wire \dac_inst/bram_dac_inst/adb[2] ;
wire \dac_inst/bram_dac_inst/adb[1] ;
wire \dac_inst/bram_dac_inst/adb[0] ;
wire \dac_inst/bram_dac_inst/cea ;
wire \dac_inst/bram_dac_inst/reseta ;
wire \dac_inst/bram_dac_inst/ceb ;
wire \dac_inst/bram_dac_inst/resetb ;
wire \dac_inst/bram_dac_inst/oce ;
wire \triggers[0] ;
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
    .trig0_i(\triggers[0] ),
    .data_i({\dac_inst/bram_dac_inst/dout[7] ,\dac_inst/bram_dac_inst/dout[6] ,\dac_inst/bram_dac_inst/dout[5] ,\dac_inst/bram_dac_inst/dout[4] ,\dac_inst/bram_dac_inst/dout[3] ,\dac_inst/bram_dac_inst/dout[2] ,\dac_inst/bram_dac_inst/dout[1] ,\dac_inst/bram_dac_inst/dout[0] ,\dac_inst/bram_dac_inst/ada[15] ,\dac_inst/bram_dac_inst/ada[14] ,\dac_inst/bram_dac_inst/ada[13] ,\dac_inst/bram_dac_inst/ada[12] ,\dac_inst/bram_dac_inst/ada[11] ,\dac_inst/bram_dac_inst/ada[10] ,\dac_inst/bram_dac_inst/ada[9] ,\dac_inst/bram_dac_inst/ada[8] ,\dac_inst/bram_dac_inst/ada[7] ,\dac_inst/bram_dac_inst/ada[6] ,\dac_inst/bram_dac_inst/ada[5] ,\dac_inst/bram_dac_inst/ada[4] ,\dac_inst/bram_dac_inst/ada[3] ,\dac_inst/bram_dac_inst/ada[2] ,\dac_inst/bram_dac_inst/ada[1] ,\dac_inst/bram_dac_inst/ada[0] ,\dac_inst/bram_dac_inst/din[7] ,\dac_inst/bram_dac_inst/din[6] ,\dac_inst/bram_dac_inst/din[5] ,\dac_inst/bram_dac_inst/din[4] ,\dac_inst/bram_dac_inst/din[3] ,\dac_inst/bram_dac_inst/din[2] ,\dac_inst/bram_dac_inst/din[1] ,\dac_inst/bram_dac_inst/din[0] ,\dac_inst/bram_dac_inst/adb[15] ,\dac_inst/bram_dac_inst/adb[14] ,\dac_inst/bram_dac_inst/adb[13] ,\dac_inst/bram_dac_inst/adb[12] ,\dac_inst/bram_dac_inst/adb[11] ,\dac_inst/bram_dac_inst/adb[10] ,\dac_inst/bram_dac_inst/adb[9] ,\dac_inst/bram_dac_inst/adb[8] ,\dac_inst/bram_dac_inst/adb[7] ,\dac_inst/bram_dac_inst/adb[6] ,\dac_inst/bram_dac_inst/adb[5] ,\dac_inst/bram_dac_inst/adb[4] ,\dac_inst/bram_dac_inst/adb[3] ,\dac_inst/bram_dac_inst/adb[2] ,\dac_inst/bram_dac_inst/adb[1] ,\dac_inst/bram_dac_inst/adb[0] ,\dac_inst/bram_dac_inst/cea ,\dac_inst/bram_dac_inst/reseta ,\dac_inst/bram_dac_inst/ceb ,\dac_inst/bram_dac_inst/resetb ,\dac_inst/bram_dac_inst/oce }),
    .clk_i(sys_clk)
);

endmodule
