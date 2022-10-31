//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.08
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18C
//Created Time: Mon Oct 31 16:28:59 2022

module clkdiv_adda (clkout, hclkin, resetn);

output clkout;
input hclkin;
input resetn;

wire gw_gnd;

assign gw_gnd = 1'b0;

CLKDIV clkdiv_inst (
    .CLKOUT(clkout),
    .HCLKIN(hclkin),
    .RESETN(resetn),
    .CALIB(gw_gnd)
);

defparam clkdiv_inst.DIV_MODE = "4";
defparam clkdiv_inst.GSREN = "false";

endmodule //clkdiv_adda
