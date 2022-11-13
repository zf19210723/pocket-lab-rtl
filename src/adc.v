module adc (
    input resetn,
    input clk,

    // ADC socket, positive edge sensitive
    input         adc_clk,
    input [7 : 0] adc_data,

    // SPI Socket
    output reg [7:0] txd_data,
    input            rxd_flag
);
    // FIFO, 8-bit width, independent R/W
    reg           fifo_wr_dv;
    reg           fifo_wr_dv_r;
    wire          fifo_full_w;
    wire          fifo_empty_w;
    reg           fifo_full;
    reg           fifo_empty;
    reg           fifo_rd_dv;
    reg           fifo_rd_dv_r;
    wire [ 7 : 0] fifo_rd_data;
    wire [15 : 0] fifo_data_rnum;
    fifo_adc fifo_adc_inst (
        .Reset(~resetn),

        .Data (adc_data),
        .WrClk(adc_clk),
        .WrEn (fifo_wr_dv_r),

        .RdClk(clk),
        .RdEn (fifo_rd_dv_r),
        .Q    (fifo_rd_data),

        .Empty(fifo_empty_w),
        .Full (fifo_full_w),
        .Rnum (fifo_data_rnum)
    );

    always @(posedge clk) begin
        if (!resetn) begin
            fifo_rd_dv_r <= 1'b0;
            fifo_empty   <= 1'b0;
            fifo_full    <= 1'b0;
            fifo_wr_dv_r <= 1'b0;
        end else begin
            fifo_rd_dv_r <= fifo_rd_dv;
            fifo_empty   <= fifo_empty_w;
            fifo_full    <= fifo_full_w;
            fifo_wr_dv_r <= fifo_wr_dv;
        end
    end

    reg [7 : 0] state;
    reg [7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_WAIT_ADC = 8'h1;
    localparam STATE_WRITE_FLAG = 8'h2;
    localparam STATE_WRITE_LENGTH_LB = 8'h3;
    localparam STATE_WRITE_LENGTH_HB = 8'h4;
    localparam STATE_WRITE_DATA = 8'h5;
    always @(posedge clk) begin
        if (!resetn) begin
            state <= STATE_RESET;
        end else begin
            state <= state_next;
        end
    end

    always @(*) begin
        case (state)
            STATE_RESET: begin
                state_next = STATE_WAIT_ADC;
            end

            STATE_WAIT_ADC: begin
                if (fifo_full) begin
                    state_next = STATE_WRITE_FLAG;
                end else begin
                    state_next = STATE_WAIT_ADC;
                end
            end

            STATE_WRITE_FLAG: begin
                if (rxd_flag) begin
                    state_next = STATE_WRITE_LENGTH_LB;
                end else begin
                    state_next = STATE_WRITE_FLAG;
                end
            end

            STATE_WRITE_LENGTH_LB: begin
                if (rxd_flag) begin
                    state_next = STATE_WRITE_LENGTH_HB;
                end else begin
                    state_next = STATE_WRITE_LENGTH_LB;
                end
            end

            STATE_WRITE_LENGTH_HB: begin
                if (rxd_flag) begin
                    state_next = STATE_WRITE_DATA;
                end else begin
                    state_next = STATE_WRITE_LENGTH_HB;
                end
            end

            STATE_WRITE_DATA: begin
                if (fifo_empty) begin
                    state_next = STATE_WAIT_ADC;
                end else begin
                    state_next = STATE_WRITE_DATA;
                end
            end

            default: begin
                state_next = STATE_RESET;
            end

        endcase
    end

    always @(posedge clk) begin
        if (!resetn) begin
            fifo_wr_dv <= 1'b0;
            fifo_rd_dv <= 1'b0;

            txd_data   <= 8'h0;
        end else begin
            case (state_next)
                STATE_RESET: begin
                    fifo_wr_dv <= 1'b0;
                    fifo_rd_dv <= 1'b0;

                    txd_data   <= 8'h0;
                end

                STATE_WAIT_ADC: begin
                    fifo_wr_dv <= 1'b1;
                    fifo_rd_dv <= 1'b0;

                    txd_data   <= 8'h0;
                end

                STATE_WRITE_FLAG: begin
                    fifo_wr_dv <= 1'b0;
                    fifo_rd_dv <= 1'b0;

                    txd_data   <= 8'h5a;
                end

                STATE_WRITE_LENGTH_LB: begin
                    fifo_wr_dv <= 1'b0;
                    fifo_rd_dv <= 1'b0;

                    txd_data   <= fifo_data_rnum[7 : 0];
                end

                STATE_WRITE_LENGTH_HB: begin
                    fifo_wr_dv <= 1'b0;
                    fifo_rd_dv <= 1'b0;

                    txd_data   <= fifo_data_rnum[15 : 8];
                end

                STATE_WRITE_DATA: begin
                    fifo_wr_dv <= 1'b0;

                    if (rxd_flag) begin
                        fifo_rd_dv <= 1'b1;
                    end else begin
                        fifo_rd_dv <= 1'b0;
                    end
                    txd_data <= fifo_rd_data;
                end

                default: begin
                    fifo_wr_dv <= 1'b0;
                    fifo_rd_dv <= 1'b0;

                    txd_data   <= 8'h0;
                end
            endcase
        end
    end

endmodule
