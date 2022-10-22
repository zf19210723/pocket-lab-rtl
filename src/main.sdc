//Copyright (C)2014-2022 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.08 
//Created Time: 2022-10-23 07:48:53
create_clock -name spi_clk -period 27.778 -waveform {0 13.889} [get_ports {spi_clk}] -add
