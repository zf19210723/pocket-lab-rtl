module spi_recv_pu (
    input axi_aresetn,
    input axi_aclk,

    // SPI-Slave Interface
    input spi_clk,
    input spi_mosi,
    input spi_cs,

    // PU Interface
    output reg package_start_int,
    output reg package_end_int
);
    reg          fifo_rx_dv;
    wire [7 : 0] fifo_rx_data;
    wire         fifo_rx_empty;
    wire         fifo_rx_full;
    fifo_spi_recv fifo_spi_recv_inst (
        .Reset(~axi_aresetn),

        .WrClk(spi_clk),
        .WrEn (spi_cs),
        .Data (spi_mosi),

        .RdClk(axi_aclk),
        .RdEn (fifo_rx_dv),
        .Q    (fifo_rx_data),

        .Empty(fifo_rx_empty),
        .Full (fifo_rx_full)
    );

endmodule
