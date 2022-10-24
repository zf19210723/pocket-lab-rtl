`define PACKAGE_TYPE_SYS_CTRL 8'h00 // System Reset
`define PACKAGE_TYPE_DATA_DAC 8'h11 // DAC data (first byte is address to write)
`define PACKAGE_TYPE_DATA_ADC 8'h12 // ADC data (generally return to computer)
`define PACKAGE_TYPE_REQ_ADC 8'h21 // request ADC data
`define PACKAGE_TYPE_REQ_DAC 8'h22 // request DAC data

module ccu_unpack (
    input axi_aclk,
    input axi_aresetn,

    // SPI RX AXI4S
    input      [7 : 0] axis_rdata,
    input              axis_rvalid,
    output reg         axis_rready,
    input              axis_rlast,

    // To FSMs
    input      dac_fsm_busy,
    output reg dac_fsm_dv,
    input      sys_fsm_busy,
    output reg sys_fsm_dv,
    input      adc_fsm_busy,
    output reg adc_fsm_dv,

    // Package infomation
    output reg [15 : 0] pack_id,
    output reg [12 : 0] pack_length,
    output reg [ 7 : 0] pack_data,
    output reg [ 7 : 0] pack_type
);
    reg  [7 : 0] fifo_ccu_unpack_data_buffer_wdata;
    reg          fifo_ccu_unpack_data_buffer_wdv;
    wire [7 : 0] fifo_ccu_unpack_data_buffer_rdata;
    reg          fifo_ccu_unpack_data_buffer_rdv;
    wire         fifo_ccu_unpack_data_buffer_empty;
    wire         fifo_ccu_unpack_data_buffer_full;
    fifo_ccu_unpack_data_buffer fifo_ccu_unpack_data_buffer_inst (
        .Clk  (axi_aclk),     //input Clk
        .Reset(~axi_aresetn), //input Reset

        .Data(fifo_ccu_unpack_data_buffer_wdata),  //input [7:0] Data
        .WrEn(fifo_ccu_unpack_data_buffer_wdv),    //input WrEn

        .Q   (fifo_ccu_unpack_data_buffer_rdata),  //output [7:0] Q
        .RdEn(fifo_ccu_unpack_data_buffer_rdv),    //input RdEn

        .Empty(fifo_ccu_unpack_data_buffer_empty),  //output Empty
        .Full (fifo_ccu_unpack_data_buffer_full)    //output Full
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
    localparam STATE_WAIT_PACKAGE = 8'h1;
    localparam STATE_READ_PACK_ID_LB = 8'h2;
    localparam STATE_READ_PACK_ID_HB = 8'h3;
    localparam STATE_READ_PACK_LEN_LB = 8'h4;
    localparam STATE_READ_PACK_LEN_HB = 8'h5;
    localparam STATE_READ_PACK_TYPE = 8'h6;
    localparam STATE_RECV_DATA = 8'h7;
    localparam STATE_TRANS_DATA = 8'h8;
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
                state_next = STATE_WAIT_PACKAGE;
            end

            STATE_WAIT_PACKAGE: begin
                if (axis_rvalid && axis_rready && (axis_rdata == 8'h5a)) begin
                    state_next = STATE_READ_PACK_ID_LB;
                end else begin
                    state_next = STATE_WAIT_PACKAGE;
                end
            end

            STATE_READ_PACK_ID_LB: begin
                if (axis_rvalid && axis_rready) begin
                    state_next = STATE_READ_PACK_ID_HB;
                end else begin
                    state_next = STATE_READ_PACK_ID_LB;
                end
            end

            STATE_READ_PACK_ID_HB: begin
                if (axis_rvalid && axis_rready) begin
                    state_next = STATE_READ_PACK_LEN_LB;
                end else begin
                    state_next = STATE_READ_PACK_ID_HB;
                end
            end

            STATE_READ_PACK_LEN_LB: begin
                if (axis_rvalid && axis_rready) begin
                    state_next = STATE_READ_PACK_LEN_HB;
                end else begin
                    state_next = STATE_READ_PACK_LEN_LB;
                end
            end

            STATE_READ_PACK_LEN_HB: begin
                if (axis_rvalid && axis_rready) begin
                    state_next = STATE_READ_PACK_TYPE;
                end else begin
                    state_next = STATE_READ_PACK_LEN_HB;
                end
            end

            STATE_READ_PACK_TYPE: begin
                if (axis_rvalid && axis_rready) begin
                    state_next = STATE_RECV_DATA;
                end else begin
                    state_next = STATE_READ_PACK_TYPE;
                end
            end

            STATE_RECV_DATA: begin
                if ((data_recv_ct < pack_length) && (!fifo_ccu_unpack_data_buffer_full)) begin
                    state_next = STATE_RECV_DATA;
                end else begin
                    state_next = STATE_TRANS_DATA;
                end
            end

            STATE_TRANS_DATA: begin
                if (fifo_ccu_unpack_data_buffer_empty) begin
                    state_next = STATE_WAIT_PACKAGE;
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
                axis_rready                       = 0;

                pack_id                           = 16'b0;
                pack_length                       = 13'b0;
                pack_data                         = 8'b0;
                pack_type                         = 8'b0;

                data_recv_ct_next                 = 13'b0;

                dac_fsm_dv                        = 0;
                sys_fsm_dv                        = 0;
                adc_fsm_dv                        = 0;

                fifo_ccu_unpack_data_buffer_wdata = 8'h0;
                fifo_ccu_unpack_data_buffer_wdv   = 0;
                fifo_ccu_unpack_data_buffer_rdv   = 0;
            end

            STATE_WAIT_PACKAGE: begin
                axis_rready                       = 1;

                pack_id                           = 16'b0;
                pack_length                       = 13'b0;
                pack_data                         = 8'b0;
                pack_type                         = 8'b0;

                data_recv_ct_next                 = 13'b0;

                dac_fsm_dv                        = 0;
                sys_fsm_dv                        = 0;
                adc_fsm_dv                        = 0;

                fifo_ccu_unpack_data_buffer_wdata = 8'h0;
                fifo_ccu_unpack_data_buffer_wdv   = 0;
                fifo_ccu_unpack_data_buffer_rdv   = 0;
            end

            STATE_READ_PACK_ID_LB: begin
                axis_rready = 1;

                if (axis_rvalid && axis_rready) begin
                    pack_id[7 : 0] = axis_rdata;
                end else begin
                    pack_id[7 : 0] = 8'b0;
                end
                pack_length                       = 13'b0;
                pack_data                         = 8'b0;
                pack_type                         = 8'b0;

                data_recv_ct_next                 = 13'b0;

                dac_fsm_dv                        = 0;
                sys_fsm_dv                        = 0;
                adc_fsm_dv                        = 0;

                fifo_ccu_unpack_data_buffer_wdata = 8'h0;
                fifo_ccu_unpack_data_buffer_wdv   = 0;
                fifo_ccu_unpack_data_buffer_rdv   = 0;
            end

            STATE_READ_PACK_ID_HB: begin
                axis_rready = 1;

                if (axis_rvalid && axis_rready) begin
                    pack_id[15 : 8] = axis_rdata;
                end else begin
                    pack_id[15 : 8] = 8'b0;
                end
                pack_length                       = 13'b0;
                pack_data                         = 8'b0;
                pack_type                         = 8'b0;

                data_recv_ct_next                 = 13'b0;

                dac_fsm_dv                        = 0;
                sys_fsm_dv                        = 0;
                adc_fsm_dv                        = 0;

                fifo_ccu_unpack_data_buffer_wdata = 8'h0;
                fifo_ccu_unpack_data_buffer_wdv   = 0;
                fifo_ccu_unpack_data_buffer_rdv   = 0;
            end

            STATE_READ_PACK_LEN_LB: begin
                axis_rready = 1;

                if (axis_rvalid && axis_rready) begin
                    pack_length[7 : 0] = axis_rdata;
                end else begin
                    pack_length[7 : 0] = 8'b0;
                end
                pack_data                         = 8'b0;
                pack_type                         = 8'b0;

                data_recv_ct_next                 = 13'b0;

                dac_fsm_dv                        = 0;
                sys_fsm_dv                        = 0;
                adc_fsm_dv                        = 0;

                fifo_ccu_unpack_data_buffer_wdata = 8'h0;
                fifo_ccu_unpack_data_buffer_wdv   = 0;
                fifo_ccu_unpack_data_buffer_rdv   = 0;
            end

            STATE_READ_PACK_LEN_HB: begin
                axis_rready = 1;

                if (axis_rvalid && axis_rready) begin
                    pack_length[15 : 8] = axis_rdata;
                end else begin
                    pack_length[15 : 8] = 8'b0;
                end
                pack_data                         = 8'b0;
                pack_type                         = 8'b0;

                data_recv_ct_next                 = 13'b0;

                dac_fsm_dv                        = 0;
                sys_fsm_dv                        = 0;
                adc_fsm_dv                        = 0;

                fifo_ccu_unpack_data_buffer_wdata = 8'h0;
                fifo_ccu_unpack_data_buffer_wdv   = 0;
                fifo_ccu_unpack_data_buffer_rdv   = 0;
            end

            STATE_READ_PACK_TYPE: begin
                axis_rready = 1;

                if (axis_rvalid && axis_rready) begin
                    pack_type = axis_rdata;
                end else begin
                    pack_type = 8'b0;
                end
                pack_data                         = 8'b0;

                data_recv_ct_next                 = 13'b0;

                dac_fsm_dv                        = 0;
                sys_fsm_dv                        = 0;
                adc_fsm_dv                        = 0;

                fifo_ccu_unpack_data_buffer_wdata = 8'h0;
                fifo_ccu_unpack_data_buffer_wdv   = 0;
                fifo_ccu_unpack_data_buffer_rdv   = 0;
            end

            STATE_RECV_DATA: begin
                axis_rready = 1;

                pack_data   = 8'b0;

                dac_fsm_dv  = 0;
                sys_fsm_dv  = 0;
                adc_fsm_dv  = 0;

                if (axis_rvalid && axis_rready && (!fifo_ccu_unpack_data_buffer_full)) begin
                    fifo_ccu_unpack_data_buffer_wdata = axis_rdata;
                    fifo_ccu_unpack_data_buffer_wdv   = 1;
                    data_recv_ct_next                 = data_recv_ct + 1;
                end else begin
                    fifo_ccu_unpack_data_buffer_wdata = 8'h0;
                    fifo_ccu_unpack_data_buffer_wdv   = 0;
                    data_recv_ct_next                 = data_recv_ct;
                end

                if ((data_recv_ct < pack_length) && (!fifo_ccu_unpack_data_buffer_full)) begin
                    fifo_ccu_unpack_data_buffer_rdv = 0;
                end else begin
                    fifo_ccu_unpack_data_buffer_rdv = 1;
                end
            end
            
            STATE_TRANS_DATA: begin
                axis_rready                       = 0;

                data_recv_ct_next                 = 13'b0;

                fifo_ccu_unpack_data_buffer_wdata = 8'h0;
                fifo_ccu_unpack_data_buffer_wdv   = 0;

                case (pack_type)
                    `PACKAGE_TYPE_SYS_CTRL: begin
                        if (sys_fsm_busy) begin
                            dac_fsm_dv                      = 0;
                            sys_fsm_dv                      = 0;
                            adc_fsm_dv                      = 0;

                            fifo_ccu_unpack_data_buffer_rdv = 0;
                            pack_data                       = 8'b0;
                        end else begin
                            dac_fsm_dv                      = 0;
                            sys_fsm_dv                      = 1;
                            adc_fsm_dv                      = 0;

                            fifo_ccu_unpack_data_buffer_rdv = 1;
                            pack_data                       = fifo_ccu_unpack_data_buffer_rdata;
                        end
                    end

                    `PACKAGE_TYPE_DATA_DAC: begin
                        if (dac_fsm_busy) begin
                            dac_fsm_dv                      = 0;
                            sys_fsm_dv                      = 0;
                            adc_fsm_dv                      = 0;

                            fifo_ccu_unpack_data_buffer_rdv = 0;
                            pack_data                       = 8'b0;
                        end else begin
                            dac_fsm_dv                      = 1;
                            sys_fsm_dv                      = 0;
                            adc_fsm_dv                      = 0;

                            fifo_ccu_unpack_data_buffer_rdv = 1;
                            pack_data                       = fifo_ccu_unpack_data_buffer_rdata;

                        end
                    end

                    `PACKAGE_TYPE_DATA_ADC: begin
                        dac_fsm_dv                      = 0;
                        sys_fsm_dv                      = 0;
                        adc_fsm_dv                      = 0;

                        fifo_ccu_unpack_data_buffer_rdv = 1;
                        pack_data                       = 8'h0;
                    end

                    `PACKAGE_TYPE_REQ_ADC: begin
                        if (adc_fsm_busy) begin
                            dac_fsm_dv                      = 0;
                            sys_fsm_dv                      = 0;
                            adc_fsm_dv                      = 0;

                            fifo_ccu_unpack_data_buffer_rdv = 0;
                            pack_data                       = 8'b0;
                        end else begin
                            dac_fsm_dv                      = 0;
                            sys_fsm_dv                      = 0;
                            adc_fsm_dv                      = 1;

                            fifo_ccu_unpack_data_buffer_rdv = 1;
                            pack_data                       = fifo_ccu_unpack_data_buffer_rdata;

                        end
                    end

                    `PACKAGE_TYPE_REQ_DAC: begin
                        dac_fsm_dv                      = 0;
                        sys_fsm_dv                      = 0;
                        adc_fsm_dv                      = 0;

                        fifo_ccu_unpack_data_buffer_rdv = 1;
                        pack_data                       = 8'h0;
                    end

                    default: begin
                        dac_fsm_dv                      = 0;
                        sys_fsm_dv                      = 0;
                        adc_fsm_dv                      = 0;

                        fifo_ccu_unpack_data_buffer_rdv = 1;
                        pack_data                       = 8'h0;
                    end
                endcase
            end

            default: begin
                axis_rready       = 0;

                pack_id           = 16'b0;
                pack_length       = 13'b0;
                pack_data         = 8'b0;
                pack_type         = 8'b0;

                data_recv_ct_next = 13'b0;

                dac_fsm_dv        = 0;
                sys_fsm_dv        = 0;
                adc_fsm_dv        = 0;
            end
        endcase
    end

endmodule
