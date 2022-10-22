module adc (
    input axis_aresetn,
    input axis_aclk,

    // ADC socket, positive edge sensitive
    input         adc_clk,
    input [7 : 0] adc_data,

    // AXI4-Stream Transmitter interface
    output reg         axis_tvalid,
    input              axis_tready,
    output reg [7 : 0] axis_tdata,
    output reg         axis_tlast
);
    // ADC data buffer
    reg [7 : 0] adc_data_buf;
    always @(negedge adc_clk) begin
        if (!axis_aresetn) begin
            adc_data_buf <= 8'b0;
        end else begin
            adc_data_buf <= adc_data;
        end
    end

    reg [7 : 0] adc_data_r;
    always @(posedge adc_clk) begin
        if (!axis_aresetn) begin
            adc_data_r <= 8'b0;
        end else begin
            adc_data_r <= adc_data_buf;
        end
    end

    // FIFO, 8-bit width, independent R/W
    reg          fifo_wr_dv;
    wire         fifo_full;
    wire         fifo_empty;
    reg          fifo_rd_dv;
    wire [7 : 0] fifo_data_rd;
    fifo_adc fifo_adc_inst (
        .Reset(~axis_aresetn),

        .Data (adc_data_r),
        .WrClk(adc_clk),
        .WrEn (fifo_wr_dv),

        .RdClk(axis_aclk),
        .RdEn (fifo_rd_dv),
        .Q    (fifo_data_rd),

        .Empty(fifo_empty),
        .Full (fifo_full)
    );

    // AXI4 Stream FSM
    localparam STATE_RESET = 8'h0;
    localparam STATE_IDEL = 8'h1;
    localparam STATE_RECV_ADC_DATA = 8'h2;
    localparam STATE_WAIT_TRANS = 8'h3;
    localparam STATE_TRANS = 8'h4;
    reg [7 : 0] state;
    reg [7 : 0] state_next;

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
                state_next = STATE_IDEL;
            end

            STATE_IDEL: begin
                state_next = STATE_RECV_ADC_DATA;
            end

            STATE_RECV_ADC_DATA: begin
                if (fifo_full) begin
                    state_next = STATE_WAIT_TRANS;
                end else begin
                    state_next = STATE_RECV_ADC_DATA;
                end
            end

            STATE_WAIT_TRANS: begin
                if (axis_tready && axis_tvalid) begin
                    state_next = STATE_TRANS;
                end else begin
                    state_next = STATE_WAIT_TRANS;
                end
            end

            STATE_TRANS: begin
                if (fifo_empty && axis_tready) begin
                    state_next = STATE_IDEL;
                end else begin
                    state_next = STATE_TRANS;
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
                axis_tvalid = 0;
                axis_tdata  = 8'h0;
                axis_tlast  = 0;

                fifo_wr_dv  = 0;
                fifo_rd_dv  = 0;
            end

            STATE_IDEL: begin
                axis_tvalid = 0;
                axis_tdata  = 8'h0;
                axis_tlast  = 0;

                fifo_wr_dv  = 0;
                fifo_rd_dv  = 0;
            end

            STATE_RECV_ADC_DATA: begin
                axis_tvalid = 0;
                axis_tdata  = 8'h0;
                axis_tlast  = 0;

                fifo_wr_dv  = 1;
                fifo_rd_dv  = 0;
            end

            STATE_WAIT_TRANS: begin
                axis_tvalid = 1;
                axis_tdata  = 8'h0;
                axis_tlast  = 0;

                fifo_wr_dv  = 0;
                fifo_rd_dv  = 0;
            end

            STATE_TRANS: begin
                axis_tvalid = 1;
                axis_tdata  = fifo_data_rd;
                if (fifo_empty) begin
                    axis_tlast = 1;
                end else begin
                    axis_tlast = 0;
                end

                fifo_wr_dv = 0;
                fifo_rd_dv = 1;
            end

            default: begin
                axis_tvalid = 0;
                axis_tdata  = 8'h0;
                axis_tlast  = 0;

                fifo_wr_dv  = 0;
                fifo_rd_dv  = 0;
            end
        endcase
    end

endmodule

