module dac (
    input resetn,
    input clk,

    // ADC socket, positive edge sensitive
    input          dac_clk,
    output [7 : 0] dac_data,

    // SPI Socket
    input [7:0] rxd_out,
    input       rxd_flag
);
    // Buffer
    reg          buffer_wr_dv;
    reg [15 : 0] buffer_wr_addr;
    reg [ 7 : 0] buffer_wr_data;

    reg          buffer_rd_dv;
    reg [15 : 0] buffer_rd_addr;

    bram_dac bram_dac_inst (
        .clka  (clk),             //input clka
        .reseta(~resetn),         //input reseta
        .cea   (buffer_wr_dv),    //input cea
        .ada   (buffer_wr_addr),  //input [15:0] ada
        .din   (buffer_wr_data),  //input [7:0] din

        .clkb  (dac_clk),         //input clkb
        .resetb(~resetn),         //input resetb
        .ceb   (buffer_rd_dv),    //input ceb
        .oce   (buffer_rd_dv),    //input oce
        .adb   (buffer_rd_addr),  //input [15:0] adb
        .dout  (dac_data)         //output [7:0] dout
    );

    // Output Address Generator
    reg oag_output_ctrl;
    reg oag_init_ctrl;
    always @(posedge dac_clk) begin
        if ((!resetn) || oag_init_ctrl) begin
            buffer_rd_dv   <= 0;
            buffer_rd_addr <= 16'h0;
        end else begin
            if (oag_output_ctrl) begin
                buffer_rd_dv   <= 1;
                buffer_rd_addr <= buffer_rd_addr + 1;
            end else begin
                buffer_rd_dv   <= 0;
                buffer_rd_addr <= buffer_rd_addr;
            end
        end
    end

    // Recv Data Counter
    reg [15 : 0] recv_data_ct;

    // FSM
    reg [ 7 : 0] state;
    reg [ 7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_RECV_FLAG = 8'h1;
    localparam STATE_RECV_ADDR = 8'h2;
    localparam STATE_RECV_LENGTH_LB = 8'h3;
    localparam STATE_RECV_LENGTH_HB = 8'h4;
    localparam STATE_RECV_DATA = 8'h5;
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
                state_next = STATE_RECV_FLAG;
            end

            STATE_RECV_FLAG: begin
                if (rxd_flag && (rxd_out == 8'h5a)) begin
                    state_next = STATE_RECV_ADDR;
                end else begin
                    state_next = STATE_RECV_FLAG;
                end
            end

            STATE_RECV_ADDR: begin
                if (rxd_flag) begin
                    state_next = STATE_RECV_LENGTH_LB;
                end else begin
                    state_next = STATE_RECV_ADDR;
                end
            end

            STATE_RECV_LENGTH_LB: begin
                if (rxd_flag) begin
                    state_next = STATE_RECV_LENGTH_HB;
                end else begin
                    state_next = STATE_RECV_LENGTH_LB;
                end
            end

            STATE_RECV_LENGTH_HB: begin
                if (rxd_flag) begin
                    state_next = STATE_RECV_DATA;
                end else begin
                    state_next = STATE_RECV_LENGTH_HB;
                end
            end

            STATE_RECV_DATA: begin
                if (recv_data_ct == 16'h0) begin
                    state_next = STATE_RECV_FLAG;
                end else begin
                    state_next = STATE_RECV_DATA;
                end
            end

            default: begin
                state_next = STATE_RESET;
            end
        endcase
    end

    always @(posedge clk) begin
        if (!resetn) begin
            oag_output_ctrl <= 1'b0;
            oag_init_ctrl   <= 1'b1;

            buffer_wr_addr  <= 16'h0;

            recv_data_ct    <= 16'h0;
        end else begin
            case (state)
                STATE_RESET: begin
                    oag_output_ctrl <= 1'b0;
                    oag_init_ctrl   <= 1'b1;

                    buffer_wr_addr  <= 16'h0;

                    recv_data_ct    <= 16'h0;
                end

                STATE_RECV_FLAG: begin
                    oag_output_ctrl <= 1'b1;
                    oag_init_ctrl   <= 1'b0;

                    buffer_wr_addr  <= 16'h0;

                    recv_data_ct    <= 16'h0;
                end

                STATE_RECV_ADDR: begin
                    oag_output_ctrl <= 1'b0;
                    oag_init_ctrl   <= 1'b1;

                    if (rxd_flag) begin
                        buffer_wr_addr <= {rxd_out, 8'h0};
                    end else begin
                        buffer_wr_addr <= 16'h0;
                    end

                    recv_data_ct <= 16'h0;
                end

                STATE_RECV_LENGTH_LB: begin
                    oag_output_ctrl <= 1'b0;
                    oag_init_ctrl   <= 1'b0;

                    buffer_wr_addr  <= buffer_wr_addr;

                    if (rxd_flag) begin
                        recv_data_ct <= {8'h0, rxd_out};
                    end else begin
                        recv_data_ct <= 16'h0;
                    end
                end

                STATE_RECV_LENGTH_HB: begin
                    oag_output_ctrl <= 1'b0;
                    oag_init_ctrl   <= 1'b0;

                    buffer_wr_addr  <= buffer_wr_addr;

                    if (rxd_flag) begin
                        recv_data_ct <= {rxd_out, recv_data_ct[7 : 0]};
                    end else begin
                        recv_data_ct <= recv_data_ct;
                    end
                end

                STATE_RECV_DATA: begin
                    oag_output_ctrl <= 1'b0;
                    oag_init_ctrl   <= 1'b0;

                    if (rxd_flag) begin
                        buffer_wr_addr <= buffer_wr_addr + 1;
                        recv_data_ct   <= recv_data_ct - 1;
                    end else begin
                        buffer_wr_addr <= buffer_wr_addr;
                        recv_data_ct   <= recv_data_ct;
                    end
                end

                default: begin
                    oag_output_ctrl <= 1'b0;
                    oag_init_ctrl   <= 1'b0;

                    buffer_wr_addr  <= 16'h0;

                    recv_data_ct    <= 16'h0;
                end
            endcase
        end
    end

    always @(*) begin
        if (state == STATE_RECV_DATA) begin
            if (rxd_flag) begin
                buffer_wr_dv   = 1'b1;
                buffer_wr_data = rxd_out;
            end else begin
                buffer_wr_dv   = 1'b0;
                buffer_wr_data = 8'h0;
            end

        end else begin
            buffer_wr_dv   = 1'b0;
            buffer_wr_data = 8'h0;
        end
    end

endmodule
