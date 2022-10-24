module bench_cc_pack ();
    GSR GSR (.GSRI(1'b1));

    reg clk = 0;
    always #36 clk = ~clk;

    reg spi_clk = 0;
    always #851 spi_clk = ~spi_clk;

    reg          rstn = 0;

    reg          spi_send_axis_valid;
    wire         spi_send_axis_ready;
    reg  [7 : 0] spi_send_axis_data;
    reg          spi_send_axis_last;

    spi_send spi_send_inst (
        .axi_aresetn(rstn),
        .axi_aclk   (clk),

        // SPI
        .spi_clk (spi_clk),
        .spi_miso(),
        .spi_cs  (1),

        // AXI4-Stream
        .axis_rvalid(spi_send_axis_valid),
        .axis_rready(spi_send_axis_ready),
        .axis_rdata (spi_send_axis_data),
        .axis_rlast (spi_send_axis_last)
    );

    initial begin
        spi_send_axis_valid = 0;
        spi_send_axis_data  = 8'b0;
        spi_send_axis_last  = 0;

        #720 rstn = 1;

        #720 spi_send_axis_valid = 1;
        if (spi_send_axis_ready) spi_send_axis_data = 8'h5a;
        spi_send_axis_last = 1;

        #72 spi_send_axis_valid = 0;
        spi_send_axis_data = 8'b0;
        spi_send_axis_last = 0;
    end