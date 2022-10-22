module main (
    input rst_key,
    input osc_27m,

    // ADC Socket
    output         adc_clk,
    input  [7 : 0] adc_data,

    // DAC Socket
    output         dac_clk,
    output [7 : 0] dac_data,

    // SPI Interface
    input  spi_clk,
    input  spi_mosi,
    output spi_miso,
    input  spi_cs,

    // Test triggers
    input [1 : 0] triggers
);
    // system clock
    wire sys_clk;
    wand sys_resetn;
    pll_main pll_main_inst (
        .clkin(osc_27m),
        .reset(~rst_key),

        .clkout(sys_clk),
        .lock  (sys_resetn)
    );

    // ADC clock
    clkdiv_adda clkdiv_adda_inst (
        .clkout(adda_clk),   //output clkout
        .hclkin(sys_clk),    //input hclkin
        .resetn(sys_resetn)  //input resetn
    );
    assign adc_clk = adda_clk;
    assign dac_clk = adda_clk;

    wire         axis_valid;
    wire         axis_ready;
    wire [7 : 0] axis_data;
    wire         axis_last;
    adc adc_inst (
        .axis_aresetn(sys_resetn),
        .axis_aclk   (sys_clk),

        // ADC socket, positive edge sensitive
        .adc_clk (adc_clk),
        .adc_data(adc_data),

        // AXI4-Stream Transmitter interface
        .axis_tvalid(axis_valid),
        .axis_tready(1),
        .axis_tdata (axis_data),
        .axis_tlast (axis_last)
    );

    wire [15 : 0] axi_awaddr;
    wire          axi_awvalid;
    wire          axi_awready;

    wire [ 7 : 0] axi_wdata;
    wire          axi_wvalid;
    wire          axi_wready;
    wire          axi_wlast;

    wire [ 1 : 0] axi_bresp;
    wire          axi_bvalid;
    wire          axi_bready;

    dac dac_inst (
        .axi_aresetn(sys_resetn),
        .axi_aclk   (sys_clk),

        // ADC socket, positive edge sensitive
        .dac_clk (dac_clk),
        .dac_data(dac_data),

        // AXI4-Lite Slave interface, to write base address
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

    spi_slave spi_slave_inst (
        .axi_aresetn(sys_resetn),
        .axi_aclk   (sys_clk),

        // SPI
        .spi_clk (spi_clk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
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
        .axi_bready(axi_bready),

        // AXI4-Stream
        .axis_tvalid(axis_valid),
        .axis_tready(axis_ready),
        .axis_tdata (axis_data),
        .axis_tlast (axis_last)
    );

endmodule
