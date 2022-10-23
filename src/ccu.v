`define PACKAGE_TYPE_SYS_RESET 8'h00 // System Reset
`define PACKAGE_TYPE_DATA_DAC 8'h11 // DAC data (first byte is address to write)
`define PACKAGE_TYPE_DATA_ADC 8'h12 // ADC data (generally return to computer)
`define PACKAGE_TYPE_REQ_ADC 8'h21 // request ADC data
`define PACKAGE_TYPE_REQ_DAC 8'h22 // request DAC data

module ccu (
    input axi_aclk,
    input axi_aresetn,

    // SPI RX AXI4S
    input      [7 : 0] spi_recv_axis_rdata,
    input              spi_recv_axis_rvalid,
    output reg         spi_recv_axis_rready,
    input              spi_recv_axis_rlast,

    // SPI TX AXI4S
    output reg [7 : 0] spi_send_axis_tdata,
    output reg         spi_send_axis_tvalid,
    input              spi_send_axis_tready,
    output reg         spi_send_axis_tlast,

    // DAC AXI4
    output [15 : 0] dac_axi_awaddr,
    output          dac_axi_awvalid,
    input           dac_axi_awready,

    output [7 : 0] dac_axi_wdata,
    output         dac_axi_wvalid,
    input          dac_axi_wready,
    output         dac_axi_wlast,

    input  [1 : 0] dac_axi_bresp,
    input          dac_axi_bvalid,
    output         dac_axi_bready,

    // ADC AXI4S
    output reg [7 : 0] adc_axis_tdata,
    output reg         adc_axis_tvalid,
    input              adc_axis_tready,
    output reg         adc_axis_tlast
);
    // RECV counter
    reg [15 : 0] recv_counter_data;
    reg [15 : 0] recv_counter_data_next;
    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            recv_counter_data <= 16'h0;
        end else begin
            recv_counter_data <= recv_counter_data_next;
        end
    end

    // RECV buffer
    reg  [ 7 : 0] recv_buffer_wdata;
    reg           recv_buffer_wdv;
    wire [ 7 : 0] recv_buffer_rd_data;
    wire          recv_buffer_rdv;
    wire [15 : 0] recv_buffer_wnum;
    wire          recv_buffer_empty;
    wire          recv_buffer_full;
    fifo_ccu_recv_buffer fifo_ccu_recv_buffer_inst (
        .Clk  (axi_aclk),     //input Clk
        .Reset(~axi_aresetn), //input Reset

        .Data(recv_buffer_wdata),  //input [7:0] Data
        .WrEn(recv_buffer_wdv),    //input WrEn

        .Q   (recv_buffer_rd_data),  //output [7:0] Q
        .RdEn(recv_buffer_rdv),      //input RdEn

        .Wnum(recv_buffer_wnum),  //output [16:0] Wnum

        .Empty(recv_buffer_empty),  //output Empty
        .Full (recv_buffer_full)    //output Full
    );

    reg [7 : 0] state;
    reg [7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_RECV_PACK_HEAD = 8'h1;
    localparam STATE_RECV_DATA = 8'h2;
    localparam STATE_SET_SYS_STATE = 8'h3;
    localparam STATE_WRITE_DAC = 8'h4;
    localparam STATE_READ_ADC = 8'h5;
    localparam STATE_BUILD_PACK = 8'h6;
    localparam STATE_SEND_PACK = 8'h7;
    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            state <= STATE_RESET;
        end else begin
            state <= state_next;
        end
    end

    wire          int_recv_start;
    wire          int_recv_finish;
    wire [15 : 0] pack_id;
    wire [ 7 : 0] pack_type;
    wire [15 : 0] pack_length;
    ccu_recv_header_fsm ccu_recv_header_fsm_inst (
        .clk   (axi_aclk),
        .resetn(axi_aresetn),

        .crtl_recv_data(spi_recv_axis_rdata),
        .ctrl_recv_en  ((state == STATE_RECV_PACK_HEAD) && spi_recv_axis_rvalid && spi_recv_axis_rready),

        .int_recv_start (int_recv_start),
        .int_recv_finish(int_recv_finish),

        .pack_id    (pack_id),
        .pack_type  (pack_type),
        .pack_length(pack_length)
    );

    reg  ctrl_writedac_dv;
    wire int_writedac_finish;
    wire int_writedac_err;
    ccu_write_dac_fsm ccu_write_dac_fsm_inst (
        .clk   (axi_aclk),
        .resetn(axi_aresetn),

        // DAC AXI
        .dac_axi_awaddr (dac_axi_awaddr),
        .dac_axi_awvalid(dac_axi_awvalid),
        .dac_axi_awready(dac_axi_awready),

        .dac_axi_wdata (dac_axi_wdata),
        .dac_axi_wvalid(dac_axi_wvalid),
        .dac_axi_wready(dac_axi_wready),
        .dac_axi_wlast (dac_axi_wlast),

        .dac_axi_bresp (dac_axi_bresp),
        .dac_axi_bvalid(dac_axi_bvalid),
        .dac_axi_bready(dac_axi_bready),

        // FIFO Interface
        .fifo_rd_data (recv_buffer_rd_data),
        .fifo_rd_dv   (recv_buffer_rdv),
        .fifo_rd_empty(recv_buffer_empty),

        // CTRL
        .ctrl_writedac_dv(ctrl_writedac_dv),

        // Interrupts
        .int_writedac_finish(int_writedac_finish),
        .int_writedac_err   (int_writedac_err)
    );

    always @(*) begin
        case (state)
            STATE_RESET: begin
                state_next = STATE_RECV_PACK_HEAD;
            end

            STATE_RECV_PACK_HEAD: begin
                if (int_recv_finish) begin
                    state_next = STATE_RECV_DATA;
                end else begin
                    state_next = STATE_RECV_PACK_HEAD;
                end
            end

            STATE_RECV_DATA: begin
                if (recv_counter_data < pack_length) begin
                    state_next = STATE_SET_SYS_STATE;
                end else begin
                    state_next = STATE_RECV_DATA;
                end
            end

            STATE_SET_SYS_STATE: begin
                case (pack_type)
                    `PACKAGE_TYPE_SYS_RESET: begin
                        state_next = STATE_RESET;
                    end

                    `PACKAGE_TYPE_DATA_DAC: begin
                        state_next = STATE_WRITE_DAC;
                    end

                    `PACKAGE_TYPE_DATA_ADC: begin
                        state_next = STATE_RECV_PACK_HEAD;
                    end

                    `PACKAGE_TYPE_REQ_ADC: begin
                        state_next = STATE_READ_ADC;
                    end

                    `PACKAGE_TYPE_REQ_DAC: begin
                        state_next = STATE_RECV_PACK_HEAD;
                    end

                    default: begin
                        state_next = STATE_RECV_PACK_HEAD;
                    end
                endcase
            end

            STATE_WRITE_DAC: begin
                if (int_writedac_finish) begin
                    if (int_writedac_err) begin
                        state_next = STATE_RECV_PACK_HEAD;
                    end else begin
                        state_next = STATE_RECV_PACK_HEAD;
                    end
                end else begin
                    state_next = STATE_WRITE_DAC;
                end
            end

            STATE_READ_ADC: begin

            end

            STATE_BUILD_PACK: begin

            end

            STATE_SEND_PACK: begin

            end

            default: begin

            end
        endcase
    end

    always @(*) begin
        case (state)
            STATE_RESET: begin
                spi_recv_axis_rready   = 0;

                recv_counter_data_next = 16'h0;

                recv_buffer_wdata      = 8'h0;
                recv_buffer_wdv        = 0;

                ctrl_writedac_dv       = 0;
            end

            STATE_RECV_PACK_HEAD: begin
                spi_recv_axis_rready   = 1;

                recv_counter_data_next = 16'h0;

                recv_buffer_wdata      = 8'h0;
                recv_buffer_wdv        = 0;

                ctrl_writedac_dv       = 0;
            end

            STATE_RECV_DATA: begin
                spi_recv_axis_rready = 1;

                if (spi_recv_axis_rvalid && spi_recv_axis_rready) begin
                    recv_counter_data_next = recv_counter_data_next;

                    recv_buffer_wdata      = spi_recv_axis_rdata;
                    recv_buffer_wdv        = 1;
                end else begin
                    recv_counter_data_next = 16'h0;

                    recv_buffer_wdata      = 8'h0;
                    recv_buffer_wdv        = 0;
                end

                ctrl_writedac_dv = 0;
            end

            STATE_SET_SYS_STATE: begin
                spi_recv_axis_rready   = 0;

                recv_counter_data_next = 16'h0;

                recv_buffer_wdata      = 8'h0;
                recv_buffer_wdv        = 0;

                ctrl_writedac_dv       = 0;
            end

            STATE_WRITE_DAC: begin
                spi_recv_axis_rready   = 0;

                recv_counter_data_next = 16'h0;

                recv_buffer_wdata      = 8'h0;
                recv_buffer_wdv        = 0;

                ctrl_writedac_dv       = 1;
            end

            STATE_READ_ADC: begin

            end

            STATE_BUILD_PACK: begin

            end

            STATE_SEND_PACK: begin

            end

            default: begin
                spi_recv_axis_rready   = 0;

                recv_counter_data_next = 16'h0;

                recv_buffer_wdata      = 8'h0;
                recv_buffer_wdv        = 0;

                ctrl_writedac_dv       = 0;
            end
        endcase
    end

endmodule
