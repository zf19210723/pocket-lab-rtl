module spi_send (
    input axi_aresetn,
    input axi_aclk,

    // SPI-Slave Interface
    input      spi_clk,
    output reg spi_miso,
    input      spi_cs,

    // AXI4-Stream Interface : CCU to SPI
    input      [7 : 0] axis_rdata,
    input              axis_rvalid,
    output reg         axis_rready,
    input              axis_rlast
);
    // Sample period generator
    reg spi_clk_r0, spi_clk_r1;
    wire spi_sample_int;
    assign spi_sample_int = spi_cs && (~spi_clk_r0) && spi_clk_r1;
    always @(posedge axi_aclk) begin
        spi_clk_r0 <= spi_clk;
        spi_clk_r1 <= spi_clk_r0;
    end

    // Sending counter
    reg         spi_send_start_int;
    reg         spi_send_finish_int;
    reg         spi_send_dv;
    reg [2 : 0] spi_send_ct;
    reg [7 : 0] spi_send_buffer;

    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            spi_send_ct <= 3'b0;
        end else begin
            if (spi_sample_int && spi_send_dv) begin
                spi_send_ct <= spi_send_ct + 1;
            end else begin
                spi_send_ct <= spi_send_ct;
            end
        end
    end

    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            spi_send_dv         <= 0;
            spi_send_finish_int <= 0;
        end else begin
            if (spi_send_start_int) begin
                spi_send_dv         <= 1;
                spi_send_finish_int <= 0;
            end else if (spi_sample_int && (spi_send_ct == 3'b111)) begin
                spi_send_dv         <= 0;
                spi_send_finish_int <= 1;
            end else begin
                spi_send_dv         <= spi_send_dv;
                spi_send_finish_int <= 0;
            end
        end
    end

    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            spi_send_ct <= 3'b0;
        end else begin
            if (spi_sample_int && spi_send_dv) begin
                spi_send_ct <= spi_send_ct + 1;
            end else begin
                spi_send_ct <= spi_send_ct;
            end
        end
    end

    always @(*) begin
        if (!axi_aresetn) begin
            spi_miso = 0;
        end else begin
            spi_miso = spi_send_buffer[spi_send_ct];
        end
    end

    reg [7 : 0] state;
    reg [7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_WAIT_AXI = 8'h1;
    localparam STATE_TRANS_DATA = 8'h2;
    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            state <= STATE_RESET;
        end else begin
            state <= state_next;
        end
    end

    always @(*) begin
        case (state)
            STATE_RESET: begin
                state_next = STATE_WAIT_AXI;
            end

            STATE_WAIT_AXI: begin
                if (axis_rvalid && axis_rready) begin
                    state_next = STATE_TRANS_DATA;
                end else begin
                    state_next = STATE_WAIT_AXI;
                end
            end

            STATE_TRANS_DATA: begin
                if (spi_send_finish_int) begin
                    state_next = STATE_WAIT_AXI;
                end else begin
                    state_next = STATE_TRANS_DATA;
                end
            end

            default: begin
                state_next = STATE_RESET;
            end
        endcase
    end

    always @(*) begin
        case (state)
            STATE_RESET: begin
                axis_rready        = 0;

                spi_send_buffer    = 8'b0;
                spi_send_start_int = 0;
            end

            STATE_WAIT_AXI: begin
                axis_rready = 1;

                if (axis_rvalid && axis_rready) begin
                    spi_send_buffer    = axis_rdata;
                    spi_send_start_int = 1;
                end else begin
                    spi_send_buffer    = 8'b0;
                    spi_send_start_int = 0;
                end
            end

            STATE_TRANS_DATA: begin
                axis_rready        = 0;
                spi_send_start_int = 0;
            end

            default: begin
                axis_rready        = 0;

                spi_send_buffer    = 8'b0;
                spi_send_start_int = 0;
            end
        endcase
    end
endmodule
