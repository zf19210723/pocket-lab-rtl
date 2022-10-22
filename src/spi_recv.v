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
    reg          fifo_rd_dv;
    wire [7 : 0] fifo_rd_data;
    wire         fifo_empty;
    wire         fifo_full;
    fifo_spi_recv fifo_spi_recv_inst (
        .Reset(~axi_aresetn),  //input Reset

        .WrClk(spi_clk),  //input WrClk
        .WrEn (spi_cs),   //input WrEn
        .Data (spi_mosi), //input [7:0] Data

        .RdClk(axi_aclk),     //input RdClk
        .RdEn (fifo_rd_dv),   //input RdEn
        .Q    (fifo_rd_data), //output [0:0] Q

        .Empty(fifo_empty),  //output Empty
        .Full (fifo_full)    //output Full
    );

    reg [7 : 0] state;
    reg [7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_WAIT_SPI_BYTE = 8'h1;
    localparam STATE_WAIT_AXI = 8'h2;
    localparam STATE_TRANS_DATA = 8'h3;
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
                if (!fifo_empty) begin
                    state_next = STATE_WAIT_AXI;
                end else begin
                    state_next = STATE_WAIT_SPI_BYTE;
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
                if (fifo_empty || !(axis_tvalid && axis_tready)) begin
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

                fifo_rd_dv  = 0;
            end

            STATE_WAIT_SPI_BYTE: begin
                axis_tdata  = 8'h0;
                axis_tvalid = 0;
                axis_tlast  = 0;

                fifo_rd_dv  = 0;
            end

            STATE_WAIT_AXI: begin
                axis_tvalid = 1;
                if (axis_tvalid && axis_tready) begin
                    axis_tdata = fifo_rd_data;
                end else begin
                    axis_tdata = 8'h0;
                end
                axis_tlast  = 0;

                fifo_rd_dv  = 1;
            end

            STATE_TRANS_DATA: begin
                axis_tdata  = fifo_rd_data;
                axis_tvalid = 1;
                if (fifo_empty || !(axis_tvalid && axis_tready)) begin
                    axis_tlast = 1;
                end else begin
                    axis_tlast = 0;
                end

                fifo_rd_dv = 1;
            end

            default: begin
                axis_tdata  = 8'h0;
                axis_tvalid = 0;
                axis_tlast  = 0;

                fifo_rd_dv  = 0;
            end
        endcase
    end

endmodule
