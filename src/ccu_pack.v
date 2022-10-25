module ccu_pack (
    input clk,
    input rstn,

    // SPI
    output reg [7 : 0] txd_data,
    input              rxd_flag,

    // From FSMs
    input      pack_en,
    output reg pack_busy,

    // Package infomation
    input [15 : 0] pack_id,
    input [12 : 0] pack_length,
    input [ 7 : 0] pack_data,
    input [ 7 : 0] pack_type
);
    wire [ 7 : 0] fifo_ccu_pack_data_buffer_rdata;
    reg           fifo_ccu_pack_data_buffer_rdv;
    wire          fifo_ccu_pack_data_buffer_empty;
    wire          fifo_ccu_pack_data_buffer_full;
    wire [12 : 0] fifo_ccu_pack_data_buffer_wnum;
    fifo_ccu_pack_data_buffer fifo_ccu_pack_data_buffer_inst (
        .Clk  (clk),   //input Clk
        .Reset(~rstn), //input Reset

        .Data(pack_data),  //input [7:0] Data
        .WrEn(pack_en),    //input WrEn

        .Q   (fifo_ccu_pack_data_buffer_rdata),  //output [7:0] Q
        .RdEn(fifo_ccu_pack_data_buffer_rdv),    //input RdEn

        .Empty(fifo_ccu_pack_data_buffer_empty),  //output Empty
        .Full (fifo_ccu_pack_data_buffer_full),   //output Full
        .Wnum (fifo_ccu_pack_data_buffer_wnum)    //output [12:0] Wnum
    );

    reg [7 : 0] state;
    reg [7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_WAIT_DATA = 8'h1;
    localparam STATE_RECV_DATA = 8'h2;
    localparam STATE_WRITE_START_BYTE = 8'h3;
    localparam STATE_WRITE_PACK_ID_LB = 8'h4;
    localparam STATE_WRITE_PACK_ID_HB = 8'h5;
    localparam STATE_WRITE_PACK_LEN_LB = 8'h6;
    localparam STATE_WRITE_PACK_LEN_HB = 8'h7;
    localparam STATE_WRITE_PACK_TYPE = 8'h8;
    localparam STATE_WRITE_DATA = 8'h9;
    always @(posedge clk) begin
        if (!rstn) begin
            state <= STATE_RESET;
        end else begin
            state <= state_next;
        end
    end

    always @(*) begin
        case (state)
            STATE_RESET: begin
                state_next = STATE_WAIT_DATA;
            end

            STATE_WAIT_DATA: begin
                if (pack_en) begin
                    state_next = STATE_RECV_DATA;
                end else begin
                    state_next = STATE_WAIT_DATA;
                end
            end

            STATE_RECV_DATA: begin
                if ((fifo_ccu_pack_data_buffer_wnum < pack_length) && (!fifo_ccu_pack_data_buffer_full)) begin
                    state_next = STATE_RECV_DATA;
                end else begin
                    state_next = STATE_WRITE_START_BYTE;
                end
            end

            STATE_WRITE_START_BYTE: begin
                if (rxd_flag) begin
                    state_next = STATE_WRITE_PACK_ID_LB;
                end else begin
                    state_next = STATE_WRITE_START_BYTE;
                end
            end

            STATE_WRITE_PACK_ID_LB: begin
                if (rxd_flag) begin
                    state_next = STATE_WRITE_PACK_ID_HB;
                end else begin
                    state_next = STATE_WRITE_PACK_ID_LB;
                end
            end

            STATE_WRITE_PACK_ID_HB: begin
                if (rxd_flag) begin
                    state_next = STATE_WRITE_PACK_LEN_LB;
                end else begin
                    state_next = STATE_WRITE_PACK_ID_HB;
                end
            end

            STATE_WRITE_PACK_LEN_LB: begin
                if (rxd_flag) begin
                    state_next = STATE_WRITE_PACK_LEN_HB;
                end else begin
                    state_next = STATE_WRITE_PACK_LEN_LB;
                end
            end

            STATE_WRITE_PACK_LEN_HB: begin
                if (rxd_flag) begin
                    state_next = STATE_WRITE_PACK_TYPE;
                end else begin
                    state_next = STATE_WRITE_PACK_LEN_HB;
                end
            end

            STATE_WRITE_PACK_TYPE: begin
                if (rxd_flag) begin
                    state_next = STATE_WRITE_DATA;
                end else begin
                    state_next = STATE_WRITE_PACK_TYPE;
                end
            end

            STATE_WRITE_DATA: begin
                if (!fifo_ccu_pack_data_buffer_empty) begin
                    state_next = STATE_WRITE_DATA;
                end else begin
                    state_next = STATE_WAIT_DATA;
                end
            end

            default: begin
                state_next = STATE_RESET;
            end
        endcase
    end

    reg [15 : 0] pack_id_b;
    reg [12 : 0] pack_length_b;
    reg [ 7 : 0] pack_type_b;
    always @(negedge clk) begin
        if (rstn) begin
            if (pack_en) begin
                pack_id_b     <= pack_id;
                pack_length_b <= pack_length;
                pack_type_b   <= pack_type;
            end else begin
                pack_id_b     <= pack_id_b;
                pack_length_b <= pack_length_b;
                pack_type_b   <= pack_type_b;
            end
        end else begin
            pack_id_b     <= 16'b0;
            pack_length_b <= 13'b0;
            pack_type_b   <= 8'b0;
        end
    end

    always @(*) begin
        case (state)
            STATE_RESET: begin
                txd_data                      = 8'h0;
                fifo_ccu_pack_data_buffer_rdv = 0;
                pack_busy                     = 1;
            end

            STATE_WAIT_DATA: begin
                txd_data                      = 8'h0;
                fifo_ccu_pack_data_buffer_rdv = 0;
                pack_busy                     = 0;
            end

            STATE_RECV_DATA: begin
                txd_data                      = 8'h0;
                fifo_ccu_pack_data_buffer_rdv = 0;
                pack_busy                     = 0;
            end

            STATE_WRITE_START_BYTE: begin
                txd_data                      = 8'h5a;
                fifo_ccu_pack_data_buffer_rdv = 0;
                pack_busy                     = 1;
            end

            STATE_WRITE_PACK_ID_LB: begin
                txd_data                      = pack_id_b[7 : 0];
                fifo_ccu_pack_data_buffer_rdv = 0;
                pack_busy                     = 1;
            end

            STATE_WRITE_PACK_ID_HB: begin
                txd_data                      = pack_id_b[15 : 8];
                fifo_ccu_pack_data_buffer_rdv = 0;
                pack_busy                     = 1;
            end

            STATE_WRITE_PACK_LEN_LB: begin
                txd_data                      = pack_length_b[7 : 0];
                fifo_ccu_pack_data_buffer_rdv = 0;
                pack_busy                     = 1;
            end

            STATE_WRITE_PACK_LEN_HB: begin
                txd_data                      = {3'b0, pack_length_b[12 : 8]};
                fifo_ccu_pack_data_buffer_rdv = 0;
                pack_busy                     = 1;
            end

            STATE_WRITE_PACK_TYPE: begin
                txd_data                      = pack_type_b;
                fifo_ccu_pack_data_buffer_rdv = 0;
                pack_busy                     = 1;
            end

            STATE_WRITE_DATA: begin
                if (rxd_flag) begin
                    fifo_ccu_pack_data_buffer_rdv = 1;
                end else begin
                    fifo_ccu_pack_data_buffer_rdv = 0;
                end
                txd_data  = fifo_ccu_pack_data_buffer_rdata;
                pack_busy = 1;
            end

            default: begin
                txd_data                      = 8'h0;
                fifo_ccu_pack_data_buffer_rdv = 0;
                pack_busy                     = 1;
            end
        endcase
    end

endmodule
