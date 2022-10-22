module spi_send (
    input axi_aresetn,
    input axi_aclk,

    // SPI-Slave Interface
    input      spi_clk,
    output reg spi_miso,
    input      spi_cs,

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
    
endmodule