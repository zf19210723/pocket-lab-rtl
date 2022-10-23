module ccu_recv_header_fsm (
    input clk,
    input resetn,

    // CTRL ports
    input [7 : 0] crtl_recv_data,
    input         ctrl_recv_en,

    // Interrupts
    output reg int_recv_start,
    output reg int_recv_finish,

    // Output registers
    output reg [15 : 0] pack_id,
    output reg [ 7 : 0] pack_type,
    output reg [15 : 0] pack_length
);
    reg [7 : 0] state;
    reg [7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_WAIT_PACKAGE = 8'h1;
    localparam STATE_RECV_PACK_ID_LB = 8'h2;
    localparam STATE_RECV_PACK_ID_HB = 8'h3;
    localparam STATE_RECV_DATA_LENGTH_LB = 8'h4;
    localparam STATE_RECV_DATA_LENGTH_HB = 8'h5;
    localparam STATE_RECV_PACK_TYPE = 8'h6;
    localparam STATE_FINISH = 8'h7;
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
                state_next = STATE_WAIT_PACKAGE;
            end

            STATE_WAIT_PACKAGE: begin
                if (ctrl_recv_en && crtl_recv_data == 8'h5a) begin
                    state_next = STATE_RECV_PACK_ID_LB;
                end else begin
                    state_next = STATE_WAIT_PACKAGE;
                end
            end

            STATE_RECV_PACK_ID_LB: begin
                if (ctrl_recv_en) begin
                    state_next = STATE_RECV_PACK_ID_HB;
                end else begin
                    state_next = STATE_RECV_PACK_ID_LB;
                end
            end

            STATE_RECV_PACK_ID_HB: begin
                if (ctrl_recv_en) begin
                    state_next = STATE_RECV_DATA_LENGTH_LB;
                end else begin
                    state_next = STATE_RECV_PACK_ID_HB;
                end
            end

            STATE_RECV_DATA_LENGTH_LB: begin
                if (ctrl_recv_en) begin
                    state_next = STATE_RECV_DATA_LENGTH_HB;
                end else begin
                    state_next = STATE_RECV_DATA_LENGTH_LB;
                end
            end

            STATE_RECV_DATA_LENGTH_HB: begin
                if (ctrl_recv_en) begin
                    state_next = STATE_RECV_PACK_TYPE;
                end else begin
                    state_next = STATE_RECV_DATA_LENGTH_HB;
                end
            end

            STATE_RECV_PACK_TYPE: begin
                if (ctrl_recv_en) begin
                    state_next = STATE_FINISH;
                end else begin
                    state_next = STATE_RECV_PACK_TYPE;
                end
            end

            STATE_FINISH: begin
                state_next = STATE_WAIT_PACKAGE;
            end

            default: begin
                state_next = STATE_RESET;
            end
        endcase
    end

    always @(*) begin
        case (state)
            STATE_RESET: begin
                int_recv_start  = 0;
                int_recv_finish = 0;

                pack_id         = 16'h0;
                pack_type       = 8'h0;
                pack_length     = 16'h0;
            end

            STATE_WAIT_PACKAGE: begin
                if (ctrl_recv_en && crtl_recv_data == 8'h5a) begin
                    int_recv_start = 1;
                end else begin
                    int_recv_start = 0;
                end
                int_recv_start  = 0;
                int_recv_finish = 0;

                pack_id         = 16'h0;
                pack_type       = 8'h0;
                pack_length     = 16'h0;
            end

            STATE_RECV_PACK_ID_LB: begin
                int_recv_start  = 0;
                int_recv_finish = 0;

                if (ctrl_recv_en) begin
                    pack_id[7 : 0] = crtl_recv_data;
                end else begin
                    pack_id[7 : 0] = 8'h0;
                end
            end

            STATE_RECV_PACK_ID_HB: begin
                int_recv_start  = 0;
                int_recv_finish = 0;

                if (ctrl_recv_en) begin
                    pack_id[15 : 7] = crtl_recv_data;
                end else begin
                    pack_id[15 : 7] = 8'h0;
                end
            end

            STATE_RECV_DATA_LENGTH_LB: begin
                int_recv_start  = 0;
                int_recv_finish = 0;

                if (ctrl_recv_en) begin
                    pack_length[7 : 0] = crtl_recv_data;
                end else begin
                    pack_length[7 : 0] = 8'h0;
                end
            end

            STATE_RECV_DATA_LENGTH_HB: begin
                int_recv_start  = 0;
                int_recv_finish = 0;

                if (ctrl_recv_en) begin
                    pack_length[15 : 7] = crtl_recv_data;
                end else begin
                    pack_length[15 : 7] = 8'h0;
                end
            end

            STATE_RECV_PACK_TYPE: begin
                int_recv_start  = 0;
                int_recv_finish = 0;

                if (ctrl_recv_en) begin
                    pack_type[7 : 0] = crtl_recv_data;
                end else begin
                    pack_type[7 : 0] = 8'h0;
                end
            end

            STATE_FINISH: begin
                int_recv_start  = 0;
                int_recv_finish = 1;
            end

            default: begin
                int_recv_start  = 0;
                int_recv_finish = 0;

                pack_id         = 16'h0;
                pack_type       = 8'h0;
                pack_length     = 16'h0;
            end
        endcase
    end
endmodule
