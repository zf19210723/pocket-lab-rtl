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

    wire [7 : 0] spi_rxd_out;
    wire [7 : 0] spi_txd_data;
    wire         spi_rxd_flag;

    // ADC clock
    clkdiv_adda clkdiv_adda_inst (
        .clkout(adda_clk),   //output clkout
        .hclkin(sys_clk),    //input hclkin
        .resetn(sys_resetn)  //input resetn
    );

    adc adc_inst (
        .resetn(sys_resetn),
        .clk   (sys_clk),

        // ADC socket, positive edge sensitive
        .adc_clk (adda_clk),
        .adc_data(adc_data),

        // SPI
        .txd_data(spi_txd_data),
        .rxd_flag(spi_rxd_flag)
    );

    dac dac_inst (
        .resetn(sys_resetn),
        .clk   (sys_clk),

        // ADC socket, positive edge sensitive
        .dac_clk (adda_clk),
        .dac_data(dac_data),

        // SPI
        .rxd_out (spi_rxd_out),
        .rxd_flag(spi_rxd_flag)
    );

    spi_slaver spi_slaver_inst (
        .rstn(sys_resetn),
        .clk (sys_clk),

        // SPI
        .sck (spi_clk),
        .MOSI(spi_mosi),
        .MISO(spi_miso),
        .cs  (~spi_cs),

        .rxd_out (spi_rxd_out),
        .txd_data(spi_txd_data),
        .rxd_flag(spi_rxd_flag)
    );

endmodule
