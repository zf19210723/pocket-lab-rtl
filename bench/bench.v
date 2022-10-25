`timescale 1ns / 100ps

module bench ();
    GSR GSR (.GSRI(1'b1));

    reg clk = 0;
    always #36 clk = ~clk;

    reg          rstn = 0;

    reg  [7 : 0] adc_data = 8'h0;
    wire         adc_clk;
    always @(posedge adc_clk) begin
        if (!rstn) begin
            adc_data <= 8'h0;
        end else begin
            adc_data <= adc_data + 1;
        end
    end

    `define SPIPERIOD 1254

    reg           spi_clk = 1;
    reg   [7 : 0] spi_send_byte;
    reg   [7 : 0] spi_recv_byte;

    reg           spi_mosi;
    wire          spi_miso;

    event         e_spi_send_byte;
    always @(e_spi_send_byte) begin
        #(`SPIPERIOD) spi_clk = 1;
        spi_mosi = 0;

        #(`SPIPERIOD / 2) spi_clk = 0;
        spi_mosi = spi_send_byte[7];
        #(`SPIPERIOD / 2) spi_clk = 1;

        #(`SPIPERIOD / 2) spi_clk = 0;
        spi_mosi = spi_send_byte[6];
        #(`SPIPERIOD / 2) spi_clk = 1;

        #(`SPIPERIOD / 2) spi_clk = 0;
        spi_mosi = spi_send_byte[5];
        #(`SPIPERIOD / 2) spi_clk = 1;

        #(`SPIPERIOD / 2) spi_clk = 0;
        spi_mosi = spi_send_byte[4];
        #(`SPIPERIOD / 2) spi_clk = 1;

        #(`SPIPERIOD / 2) spi_clk = 0;
        spi_mosi = spi_send_byte[3];
        #(`SPIPERIOD / 2) spi_clk = 1;

        #(`SPIPERIOD / 2) spi_clk = 0;
        spi_mosi = spi_send_byte[2];
        #(`SPIPERIOD / 2) spi_clk = 1;

        #(`SPIPERIOD / 2) spi_clk = 0;
        spi_mosi = spi_send_byte[1];
        #(`SPIPERIOD / 2) spi_clk = 1;

        #(`SPIPERIOD / 2) spi_clk = 0;
        spi_mosi = spi_send_byte[0];
        #(`SPIPERIOD / 2) spi_clk = 1;

        #(`SPIPERIOD);
    end


    initial begin
        #1000 rstn = 1;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #200000 #(20 * `SPIPERIOD) spi_send_byte = 8'h5a;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h01;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'hff;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h05;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h11;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'hdf;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h01;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h02;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h03;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;

        #(20 * `SPIPERIOD) spi_send_byte = 8'h00;
        ->e_spi_send_byte;
    end

    main main_inst (
        .rst_key(rstn),
        .osc_27m(clk),

        // ADC Socket
        .adc_clk (adc_clk),
        .adc_data(adc_data),

        // DAC Socket
        .dac_clk (),
        .dac_data(),

        // SPI Interface
        .spi_clk (spi_clk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_cs  (1'b1),

        // Test triggers
        .triggers()
    );

endmodule
