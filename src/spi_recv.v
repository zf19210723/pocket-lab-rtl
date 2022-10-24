module spi_recv (
    input axi_aresetn,
    input axi_aclk,

    // SPI-Slave Interface
    input spi_clk,
    input spi_mosi,
    input spi_cs,

    // AXI-Stream Interface : SPI to CCU
    output reg [7 : 0] axis_tdata,
    output reg         axis_tvalid,
    input              axis_tready,
    output reg         axis_tlast
);
    reg spi_clk_r0, spi_clk_r1;
    wire spi_sample_int;
    assign spi_sample_int = spi_cs && spi_clk_r0 && (~spi_clk_r1);
    always @(posedge axi_aclk) begin
        spi_clk_r0 <= spi_clk;
        spi_clk_r1 <= spi_clk_r0;
    end

    reg [2 : 0] spi_recv_ct;
    reg [7 : 0] spi_recv_buffer;
    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            spi_recv_ct     <= 3'b0;
            spi_recv_buffer <= 8'h0;
        end else begin
            if (spi_sample_int) begin
                spi_recv_ct                  <= spi_recv_ct + 1;
                spi_recv_buffer[spi_recv_ct] <= spi_mosi;
            end else begin
                spi_recv_ct                  <= spi_recv_ct;
                spi_recv_buffer[spi_recv_ct] <= spi_recv_buffer[spi_recv_ct];
            end
        end
    end

    reg spi_byte_recv_int;
    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            spi_byte_recv_int <= 0;
        end else begin
            if ((spi_recv_ct == 3'b111) && (spi_sample_int)) begin
                spi_byte_recv_int <= 1;
            end else begin
                spi_byte_recv_int <= 0;
            end
        end
    end

    reg [7 : 0] state;
    reg [7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_WAIT_SPI_BYTE = 8'h1;
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
                state_next = STATE_WAIT_SPI_BYTE;
            end

            STATE_WAIT_SPI_BYTE: begin
                if (spi_byte_recv_int) begin
                    state_next = STATE_TRANS_DATA;
                end else begin
                    state_next = STATE_WAIT_SPI_BYTE;
                end
            end

            STATE_TRANS_DATA: begin
                if (axis_tvalid && axis_tready) begin
                    state_next = STATE_WAIT_SPI_BYTE;
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
                axis_tdata  = 8'h0;
                axis_tvalid = 0;
                axis_tlast  = 0;
            end

            STATE_WAIT_SPI_BYTE: begin
                axis_tdata  = 8'h0;
                axis_tvalid = 0;
                axis_tlast  = 0;
            end

            STATE_TRANS_DATA: begin
                axis_tvalid = 1;
                if (axis_tvalid && axis_tready) begin
                    axis_tdata = spi_recv_buffer;
                    axis_tlast = 1;
                end else begin
                    axis_tdata = 8'h0;
                    axis_tlast = 0;
                end
            end

            default: begin
                axis_tdata  = 8'h0;
                axis_tvalid = 0;
                axis_tlast  = 0;
            end
        endcase
    end

endmodule
