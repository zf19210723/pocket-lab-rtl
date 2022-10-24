module ccu_pack (
    input axi_aclk,
    input axi_aresetn,

    // SPI TX AXI4S
    output reg [7 : 0] axis_tdata,
    output reg         axis_tvalid,
    input              axis_tready,
    output reg         axis_tlast,

    // From FSMs
    input      pack_en,
    output reg pack_busy,

    // Package infomation
    input [15 : 0] pack_id,
    input [12 : 0] pack_length,
    input [ 7 : 0] pack_data,
    input [ 7 : 0] pack_type
);
    reg  [7 : 0] fifo_ccu_pack_data_buffer_wdata;
    reg          fifo_ccu_pack_data_buffer_wdv;
    wire [7 : 0] fifo_ccu_pack_data_buffer_rdata;
    reg          fifo_ccu_pack_data_buffer_rdv;
    wire         fifo_ccu_pack_data_buffer_empty;
    wire         fifo_ccu_pack_data_buffer_full;
    fifo_ccu_pack_data_buffer fifo_ccu_pack_data_buffer_inst (
        .Clk  (axi_aclk),     //input Clk
        .Reset(~axi_aresetn), //input Reset

        .Data(fifo_ccu_pack_data_buffer_wdata),  //input [7:0] Data
        .WrEn(fifo_ccu_pack_data_buffer_wdv),    //input WrEn

        .Q   (fifo_ccu_pack_data_buffer_rdata),  //output [7:0] Q
        .RdEn(fifo_ccu_pack_data_buffer_rdv),    //input RdEn

        .Empty(fifo_ccu_pack_data_buffer_empty),  //output Empty
        .Full (fifo_ccu_pack_data_buffer_full)    //output Full
    );

    reg [12 : 0] data_recv_ct;
    reg [12 : 0] data_recv_ct_next;
    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            data_recv_ct <= 13'b0;
        end else begin
            data_recv_ct <= data_recv_ct_next;
        end
    end

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
                if ((data_recv_ct < pack_length) && (!fifo_ccu_pack_data_buffer_full)) begin
                    state_next = STATE_RECV_DATA;
                end else begin
                    state_next = STATE_WRITE_START_BYTE;
                end
            end

            STATE_WRITE_START_BYTE: begin
                if (axis_tvalid && axis_tready) begin
                    state_next = STATE_WRITE_PACK_ID_LB;
                end else begin
                    state_next = STATE_WRITE_START_BYTE;
                end
            end

            STATE_WRITE_PACK_ID_LB: begin
                if (axis_tvalid && axis_tready) begin
                    state_next = STATE_WRITE_PACK_ID_HB;
                end else begin
                    state_next = STATE_WRITE_PACK_ID_LB;
                end
            end

            STATE_WRITE_PACK_ID_HB: begin
                if (axis_tvalid && axis_tready) begin
                    state_next = STATE_WRITE_PACK_LEN_LB;
                end else begin
                    state_next = STATE_WRITE_PACK_ID_HB;
                end
            end

            STATE_WRITE_PACK_LEN_LB: begin
                if (axis_tvalid && axis_tready) begin
                    state_next = STATE_WRITE_PACK_LEN_HB;
                end else begin
                    state_next = STATE_WRITE_PACK_LEN_LB;
                end
            end

            STATE_WRITE_PACK_LEN_HB: begin
                if (axis_tvalid && axis_tready) begin
                    state_next = STATE_WRITE_PACK_TYPE;
                end else begin
                    state_next = STATE_WRITE_PACK_LEN_HB;
                end
            end

            STATE_WRITE_PACK_TYPE: begin
                if (axis_tvalid && axis_tready) begin
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

    always @(*) begin
        case (state)
            STATE_RESET: begin
                axis_tdata                      = 8'h0;
                axis_tvalid                     = 0;
                axis_tlast                      = 0;

                fifo_ccu_pack_data_buffer_wdata = 8'h0;
                fifo_ccu_pack_data_buffer_wdv   = 0;
                fifo_ccu_pack_data_buffer_rdv   = 0;

                data_recv_ct_next               = 13'b0;

                pack_id_b                       = 16'b0;
                pack_length_b                   = 13'b0;
                pack_type_b                     = 8'b0;

                pack_busy                       = 1;
            end

            STATE_WAIT_DATA: begin
                axis_tdata  = 8'h0;
                axis_tvalid = 0;
                axis_tlast  = 0;

                if (pack_en) begin
                    fifo_ccu_pack_data_buffer_wdata = pack_data;
                    fifo_ccu_pack_data_buffer_wdv   = 1;
                end else begin
                    fifo_ccu_pack_data_buffer_wdata = 8'h0;
                    fifo_ccu_pack_data_buffer_wdv   = 0;
                end
                fifo_ccu_pack_data_buffer_rdv = 0;

                data_recv_ct_next             = 13'b0;

                pack_id_b                     = 16'b0;
                pack_length_b                 = 13'b0;
                pack_type_b                   = 8'b0;

                pack_busy                     = 0;
            end

            STATE_RECV_DATA: begin
                axis_tdata                      = 8'h0;
                axis_tvalid                     = 0;
                axis_tlast                      = 0;

                fifo_ccu_pack_data_buffer_wdata = pack_data;
                fifo_ccu_pack_data_buffer_wdv   = 1;
                fifo_ccu_pack_data_buffer_rdv   = 0;

                data_recv_ct_next               = data_recv_ct + 1;

                pack_id_b                       = pack_id;
                pack_length_b                   = pack_length;
                pack_type_b                     = pack_type;

                pack_busy                       = 1;
            end

            STATE_WRITE_START_BYTE: begin
                axis_tvalid = 1;
                if (axis_tvalid && axis_tready) begin
                    axis_tdata = 8'h5a;
                    axis_tlast = 1;
                end else begin
                    axis_tdata = 8'h0;
                    axis_tlast = 0;
                end

                fifo_ccu_pack_data_buffer_wdata = 0;
                fifo_ccu_pack_data_buffer_wdv   = 0;
                fifo_ccu_pack_data_buffer_rdv   = 0;

                data_recv_ct_next               = data_recv_ct + 1;

                pack_id_b                       = pack_id;
                pack_length_b                   = pack_length;
                pack_type_b                     = pack_type;

                pack_busy                       = 1;
            end

            STATE_WRITE_PACK_ID_LB: begin
                axis_tvalid = 1;
                if (axis_tvalid && axis_tready) begin
                    axis_tdata = pack_id_b[7 : 0];
                    axis_tlast = 1;
                end else begin
                    axis_tdata = 8'h0;
                    axis_tlast = 0;
                end

                fifo_ccu_pack_data_buffer_wdata = 8'h0;
                fifo_ccu_pack_data_buffer_wdv   = 0;
                fifo_ccu_pack_data_buffer_rdv   = 0;

                data_recv_ct_next               = 13'b0;

                pack_busy                       = 1;
            end

            STATE_WRITE_PACK_ID_HB: begin
                axis_tvalid = 1;
                if (axis_tvalid && axis_tready) begin
                    axis_tdata = pack_id_b[15 : 8];
                    axis_tlast = 1;
                end else begin
                    axis_tdata = 8'h0;
                    axis_tlast = 0;
                end

                fifo_ccu_pack_data_buffer_wdata = 8'h0;
                fifo_ccu_pack_data_buffer_wdv   = 0;
                fifo_ccu_pack_data_buffer_rdv   = 0;

                data_recv_ct_next               = 13'b0;

                pack_busy                       = 1;
            end

            STATE_WRITE_PACK_LEN_LB: begin
                axis_tvalid = 1;
                if (axis_tvalid && axis_tready) begin
                    axis_tdata = pack_length_b[7 : 0];
                    axis_tlast = 1;
                end else begin
                    axis_tdata = 8'h0;
                    axis_tlast = 0;
                end

                fifo_ccu_pack_data_buffer_wdata = 8'h0;
                fifo_ccu_pack_data_buffer_wdv   = 0;
                fifo_ccu_pack_data_buffer_rdv   = 0;

                data_recv_ct_next               = 13'b0;

                pack_busy                       = 1;
            end

            STATE_WRITE_PACK_LEN_HB: begin
                axis_tvalid = 1;
                if (axis_tvalid && axis_tready) begin
                    axis_tdata = pack_length_b[15 : 8];
                    axis_tlast = 1;
                end else begin
                    axis_tdata = 8'h0;
                    axis_tlast = 0;
                end

                fifo_ccu_pack_data_buffer_wdata = 8'h0;
                fifo_ccu_pack_data_buffer_wdv   = 0;
                fifo_ccu_pack_data_buffer_rdv   = 0;

                data_recv_ct_next               = 13'b0;
            end

            STATE_WRITE_PACK_TYPE: begin
                axis_tvalid = 1;
                if (axis_tvalid && axis_tready) begin
                    axis_tdata = pack_type_b;
                    axis_tlast = 1;
                end else begin
                    axis_tdata = 8'h0;
                    axis_tlast = 0;
                end

                fifo_ccu_pack_data_buffer_wdata = 8'h0;
                fifo_ccu_pack_data_buffer_wdv   = 0;
                fifo_ccu_pack_data_buffer_rdv   = 0;

                data_recv_ct_next               = 13'b0;

                pack_busy                       = 1;
            end

            STATE_WRITE_DATA: begin
                axis_tvalid = 1;
                if (axis_tvalid && axis_tready) begin
                    fifo_ccu_pack_data_buffer_rdv = 1;
                    axis_tdata                    = fifo_ccu_pack_data_buffer_rdata;
                    axis_tlast                    = 1;
                end else begin
                    fifo_ccu_pack_data_buffer_rdv = 1;
                    axis_tdata                    = 8'h0;
                    axis_tlast                    = 0;
                end

                fifo_ccu_pack_data_buffer_wdata = 8'h0;
                fifo_ccu_pack_data_buffer_wdv   = 0;

                data_recv_ct_next               = 13'b0;

                pack_busy                       = 1;
            end

            default: begin
                axis_tdata                      = 8'h0;
                axis_tvalid                     = 0;
                axis_tlast                      = 0;

                fifo_ccu_pack_data_buffer_wdata = 8'h0;
                fifo_ccu_pack_data_buffer_wdv   = 0;
                fifo_ccu_pack_data_buffer_rdv   = 0;

                data_recv_ct_next               = 13'b0;

                pack_id_b                       = 16'b0;
                pack_length_b                   = 13'b0;
                pack_type_b                     = 8'b0;

                pack_busy                       = 1;
            end
        endcase
    end

endmodule
