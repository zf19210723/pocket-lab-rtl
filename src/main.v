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

    wire adda_clk;
    assign adc_clk = adda_clk;
    assign dac_clk = adda_clk;

    wire          adc_axis_valid;
    wire          adc_axis_ready;
    wire [ 7 : 0] adc_axis_data;
    wire          adc_axis_last;

    wire [15 : 0] dac_axi_awaddr;
    wire          dac_axi_awvalid;
    wire          dac_axi_awready;

    wire [ 7 : 0] dac_axi_wdata;
    wire          dac_axi_wvalid;
    wire          dac_axi_wready;
    wire          dac_axi_wlast;

    wire [ 1 : 0] dac_axi_bresp;
    wire          dac_axi_bvalid;
    wire          dac_axi_bready;

    wire          spi_recv_axis_tvalid;
    wire          spi_recv_axis_tready;
    wire [ 7 : 0] spi_recv_axis_tdata;
    wire          spi_recv_axis_tlast;

    wire          spi_send_axis_rvalid;
    wire          spi_send_axis_rready;
    wire [ 7 : 0] spi_send_axis_rdata;
    wire          spi_send_axis_rlast;

    ccu ccu_inst (
        .axi_aresetn(sys_resetn),
        .axi_aclk   (sys_clk),

        // ADC
        .adc_axis_tvalid(adc_axis_valid),
        .adc_axis_tready(adc_axis_ready),
        .adc_axis_tdata (adc_axis_data),
        .adc_axis_tlast (adc_axis_last),

        // DAC
        .dac_axi_awaddr (dac_axi_awaddr),
        .dac_axi_awvalid(dac_axi_awvalid),
        .dac_axi_awready(dac_axi_awready),

        .dac_axi_wdata (dac_axi_wdata),
        .dac_axi_wvalid(dac_axi_wvalid),
        .dac_axi_wready(dac_axi_wready),
        .dac_axi_wlast (dac_axi_wlast),

        .dac_axi_bresp (dac_axi_bresp),
        .dac_axi_bvalid(dac_axi_bvalid),
        .dac_axi_bready(dac_axi_bready),

        // SPI Recv
        .spi_recv_axis_rvalid(spi_recv_axis_tvalid),
        .spi_recv_axis_rready(spi_recv_axis_tready),
        .spi_recv_axis_rdata (spi_recv_axis_tdata),
        .spi_recv_axis_rlast (spi_recv_axis_tlast),

        // SPI Send
        .spi_send_axis_tvalid(spi_send_axis_rvalid),
        .spi_send_axis_tready(spi_send_axis_rready),
        .spi_send_axis_tdata (spi_send_axis_rdata),
        .spi_send_axis_tlast (spi_send_axis_rlast)
    );

    // ADC clock
    clkdiv_adda clkdiv_adda_inst (
        .clkout(adda_clk),   //output clkout
        .hclkin(sys_clk),    //input hclkin
        .resetn(sys_resetn)  //input resetn
    );

    adc adc_inst (
        .axis_aresetn(sys_resetn),
        .axis_aclk   (sys_clk),

        // ADC socket, positive edge sensitive
        .adc_clk (adda_clk),
        .adc_data(adc_data),

        // AXI4-Stream Transmitter interface
        .axis_tvalid(adc_axis_valid),
        .axis_tready(adc_axis_ready),
        .axis_tdata (adc_axis_data),
        .axis_tlast (adc_axis_last)
    );

    dac dac_inst (
        .axi_aresetn(sys_resetn),
        .axi_aclk   (sys_clk),

        // ADC socket, positive edge sensitive
        .dac_clk (adda_clk),
        .dac_data(dac_data),

        // AXI4 Slave interface
        .axi_awaddr (dac_axi_awaddr),
        .axi_awvalid(dac_axi_awvalid),
        .axi_awready(dac_axi_awready),

        .axi_wdata (dac_axi_wdata),
        .axi_wvalid(dac_axi_wvalid),
        .axi_wready(dac_axi_wready),
        .axi_wlast (dac_axi_wlast),

        .axi_bresp (dac_axi_bresp),
        .axi_bvalid(dac_axi_bvalid),
        .axi_bready(dac_axi_bready)
    );

    spi_recv spi_recv_inst (
        .axis_aresetn(sys_resetn),
        .axis_aclk   (sys_clk),

        // SPI
        .spi_clk (spi_clk),
        .spi_mosi(spi_mosi),
        .spi_cs  (spi_cs),

        // AXI4-Stream
        .axis_tvalid(spi_recv_axis_tvalid),
        .axis_tready(spi_recv_axis_tready),
        .axis_tdata (spi_recv_axis_tdata),
        .axis_tlast (spi_recv_axis_tlast)
    );

    spi_send spi_send_inst (
        .axis_aresetn(sys_resetn),
        .axis_aclk   (sys_clk),

        // SPI
        .spi_clk (spi_clk),
        .spi_miso(spi_miso),
        .spi_cs  (spi_cs),

        // AXI4-Stream
        .axis_rvalid(spi_send_axis_rvalid),
        .axis_rready(spi_send_axis_rready),
        .axis_rdata (spi_send_axis_rdata),
        .axis_rlast (spi_send_axis_rlast)
    );



endmodule
