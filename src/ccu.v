module ccu (
    input axi_aclk,
    input axi_aresetn,

    // SPI RX AXI4S
    input  [7 : 0] spi_recv_axis_rdata,
    input          spi_recv_axis_rvalid,
    output         spi_recv_axis_rready,
    input          spi_recv_axis_rlast,

    // SPI TX AXI4S
    output reg [7 : 0] spi_send_axis_tdata,
    output reg         spi_send_axis_tvalid,
    input              spi_send_axis_tready,
    output reg         spi_send_axis_tlast,

    // DAC AXI4
    output reg [15 : 0] dac_axi_awaddr,
    output reg          dac_axi_awvalid,
    input               dac_axi_awready,

    output reg [7 : 0] dac_axi_wdata,
    output reg         dac_axi_wvalid,
    input              dac_axi_wready,
    output reg         dac_axi_wlast,

    input      [1 : 0] dac_axi_bresp,
    input              dac_axi_bvalid,
    output reg         dac_axi_bready,

    // ADC AXI4S
    output reg [7 : 0] adc_axis_tdata,
    output reg         adc_axis_tvalid,
    input              adc_axis_tready,
    output reg         adc_axis_tlast
);
    assign spi_recv_axis_tready = 0;
endmodule
