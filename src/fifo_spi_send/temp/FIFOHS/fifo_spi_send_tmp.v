//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.08
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18C
//Created Time: Sat Oct 22 14:51:31 2022

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	fifo_spi_send your_instance_name(
		.Data(Data_i), //input [7:0] Data
		.Reset(Reset_i), //input Reset
		.WrClk(WrClk_i), //input WrClk
		.RdClk(RdClk_i), //input RdClk
		.WrEn(WrEn_i), //input WrEn
		.RdEn(RdEn_i), //input RdEn
		.Q(Q_o), //output [0:0] Q
		.Empty(Empty_o), //output Empty
		.Full(Full_o) //output Full
	);

//--------Copy end-------------------
