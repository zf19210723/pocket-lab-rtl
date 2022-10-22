module spi_recv (
    input axi_aresetn,
    input axi_aclk,

    // SPI-Slave Interface
    input spi_clk,
    input spi_mosi,
    input spi_cs,

    // AXI4 Interface : SPI to DAC
    input              axis_tvalid,
    output reg         axis_tready,
    input      [7 : 0] axis_tdata,
    input              axis_tlast
);
   

    reg          fifo_bf_wr_dv;
    reg  [7 : 0] fifo_bf_wdata;
    reg          fifo_bf_rd_dv;
    reg  [7 : 0] fifo_bf_rdata;
    wire         fifo_bf_empty;
    wire         fifo_bf_full;
    fifo_spi_rx_buffer fifo_spi_rx_buffer_inst (
        .Clk  (axi_aclk),     //input Clk
        .Reset(~axi_aresetn), //input Reset

        .WrEn(fifo_bf_wr_dv),  //input WrEn
        .Data(fifo_bf_wdata),  //input [7:0] Data

        .Q   (fifo_bf_rd_dv),  //output [7:0] Q
        .RdEn(fifo_bf_rdata),  //input RdEn

        .Empty(fifo_bf_empty),  //output Empty
        .Full (fifo_bf_full)    //output Full
    );

endmodule
