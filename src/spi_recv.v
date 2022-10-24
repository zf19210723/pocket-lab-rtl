module spi_recv (
    input axis_aresetn,
    input axis_aclk,

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
    wire [7 : 0] fifo_spi_recv_rdata;
    reg          fifo_spi_recv_rdv;
    wire         fifo_spi_recv_empty;
    wire         fifo_spi_recv_full;
    fifo_spi_recv fifo_spi_recv_inst (
        .WrClk(~spi_clk),  //input WrClk
        .WrEn (spi_cs),   //input WrEn
        .Data (spi_mosi), //input [7:0] Data

        .RdClk(axis_aclk),           //input RdClk
        .RdEn (fifo_spi_recv_rdv),   //input RdEn
        .Q    (fifo_spi_recv_rdata), //output [0:0] Q

        .Empty(fifo_spi_recv_empty),  //output Empty
        .Full (fifo_spi_recv_full),   //output Full
        .Reset(~axis_aresetn)         //input Reset
    );

    reg [7 : 0] state;
    reg [7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_WAIT_SPI = 8'h1;
    localparam STATE_WAIT_AXI = 8'h2;
    localparam STATE_TRANS_DATA = 8'h3;
    always @(posedge axis_aclk) begin
        if (!axis_aresetn) begin
            state <= STATE_RESET;
        end else begin
            state <= state_next;
        end
    end

    always @(*) begin
        case (state)
            STATE_RESET: begin
                state_next = STATE_WAIT_SPI;
            end

            STATE_WAIT_SPI: begin
                if (fifo_spi_recv_empty) begin
                    state_next = STATE_WAIT_SPI;
                end else begin
                    state_next = STATE_WAIT_AXI;
                end
            end

            STATE_WAIT_AXI: begin
                if (axis_tvalid && axis_tready) begin
                    state_next = STATE_TRANS_DATA;
                end else begin
                    state_next = STATE_WAIT_AXI;
                end
            end

            STATE_TRANS_DATA: begin
                if (!(axis_tvalid && axis_tready) || fifo_spi_recv_empty) begin
                    state_next = STATE_WAIT_SPI;
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
                axis_tdata        = 8'h0;
                axis_tvalid       = 0;
                axis_tlast        = 0;

                fifo_spi_recv_rdv = 0;
            end

            STATE_WAIT_SPI: begin
                axis_tdata        = 8'h0;
                axis_tvalid       = 0;
                axis_tlast        = 0;

                fifo_spi_recv_rdv = 0;
            end

            STATE_WAIT_AXI: begin
                axis_tvalid = 1;
                axis_tlast  = 0;

                if (axis_tvalid && axis_tready) begin
                    axis_tdata        = fifo_spi_recv_rdata;
                    fifo_spi_recv_rdv = 1;
                end else begin
                    axis_tdata        = 8'h0;
                    fifo_spi_recv_rdv = 0;
                end
            end

            STATE_TRANS_DATA: begin
                axis_tvalid       = 1;
                axis_tdata        = fifo_spi_recv_rdata;
                fifo_spi_recv_rdv = 1;

                if (!(axis_tvalid && axis_tready) || fifo_spi_recv_empty) begin
                    axis_tlast = 1;
                end else begin
                    axis_tlast = 0;
                end
            end

            default: begin
                axis_tdata        = 8'h0;
                axis_tvalid       = 0;
                axis_tlast        = 0;

                fifo_spi_recv_rdv = 0;
            end
        endcase
    end

endmodule
