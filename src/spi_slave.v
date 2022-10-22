module spi_slave (
    input axi_aresetn,
    input axi_aclk,

    // SPI-Slave Interface
    input      spi_clk,
    input      spi_mosi,
    output reg spi_miso,
    input      spi_cs,

    // AXI4 Interface : SPI to DAC
    input              axis_tvalid,
    output reg         axis_tready,
    input      [7 : 0] axis_tdata,
    input              axis_tlast,

    // AXI4-Stream Interface : ADC to SPI
    output reg [15 : 0] axi_awaddr,
    output reg          axi_awvalid,
    input               axi_awready,

    output reg [7 : 0] axi_wdata,
    output reg         axi_wvalid,
    input              axi_wready,
    output reg         axi_wlast,

    input      [1 : 0] axi_bresp,
    input              axi_bvalid,
    output reg         axi_bready
);
    spi_recv spi_recv_inst(
        .axi_aresetn(axi_aresetn),
        .axi_aclk   (axi_aclk),

        // SPI
        .spi_clk (spi_clk),
        .spi_mosi(spi_mosi),
        .spi_cs  (spi_cs),

        // AXI4
        .axi_awaddr (axi_awaddr),
        .axi_awvalid(axi_awvalid),
        .axi_awready(axi_awready),

        .axi_wdata (axi_wdata),
        .axi_wvalid(axi_wvalid),
        .axi_wready(axi_wready),
        .axi_wlast (axi_wlast),

        .axi_bresp (axi_bresp),
        .axi_bvalid(axi_bvalid),
        .axi_bready(axi_bready)
    );

    spi_send spi_send_inst(
        .axi_aresetn(axi_aresetn),
        .axi_aclk   (axi_aclk),

        // SPI
        .spi_clk (spi_clk),
        .spi_miso(spi_miso),
        .spi_cs  (spi_cs),

        // AXI4-Stream
        .axis_tvalid(axis_valid),
        .axis_tready(axis_ready),
        .axis_tdata (axis_data),
        .axis_tlast (axis_last)
    );
    
endmodule
