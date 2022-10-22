module spi_send (
    input axi_aresetn,
    input axi_aclk,

    // SPI-Slave Interface
    input  spi_clk,
    output spi_miso,
    input  spi_cs,

    // AXI4-Stream Interface : CCU to SPI
    input      [7 : 0] axis_rdata,
    input              axis_rvalid,
    output reg         axis_rready,
    input              axis_rlast
);
    reg  [7 : 0] fifo_wr_data;
    reg          fifo_wr_dv;
    wire         fifo_empty;
    wire         fifo_full;
    fifo_spi_send fifo_spi_send_inst (
        .Reset(~axi_aresetn),  //input Reset

        .WrClk(axi_aclk),     //input WrClk
        .WrEn (fifo_wr_dv),   //input WrEn
        .Data (fifo_wr_data), //input [7:0] Data

        .RdClk(spi_clk),  //input RdClk
        .RdEn (spi_cs),   //input RdEn
        .Q    (spi_miso), //output [0:0] Q

        .Empty(fifo_empty),  //output Empty
        .Full (fifo_full)    //output Full
    );

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
                if (axis_rlast || fifo_full) begin
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
                axis_rready  = 0;

                fifo_wr_data = 8'h0;
                fifo_wr_dv   = 0;
            end

            STATE_WAIT_AXI: begin
                axis_rready = 1;

                if (axis_rvalid && axis_rready) begin
                    fifo_wr_data = axis_rdata;
                    fifo_wr_dv   = 1;
                end else begin
                    fifo_wr_data = 8'h0;
                    fifo_wr_dv   = 0;
                end
            end

            STATE_TRANS_DATA: begin
                axis_rready  = 1;

                fifo_wr_data = axis_rdata;
                fifo_wr_dv   = 1;
            end

            default: begin
                axis_rready  = 0;

                fifo_wr_data = 8'h0;
                fifo_wr_dv   = 0;
            end
        endcase
    end
endmodule
