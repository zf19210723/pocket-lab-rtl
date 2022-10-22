module dac (
    input axi_aresetn,
    input axi_aclk,

    // ADC socket, positive edge sensitive
    input          dac_clk,
    output [7 : 0] dac_data,

    // AXI4 Slave interface, to write base address
    input      [15 : 0] axi_awaddr,
    input               axi_awvalid,
    output reg          axi_awready,

    input      [7 : 0] axi_wdata,
    input              axi_wvalid,
    output reg         axi_wready,
    input              axi_wlast,

    output reg [1 : 0] axi_bresp,
    output reg         axi_bvalid,
    input              axi_bready
);
    // Buffer
    reg          buffer_wr_dv;
    reg [15 : 0] buffer_wr_addr;
    reg [ 7 : 0] buffer_wr_data;

    reg          buffer_rd_dv;
    reg [15 : 0] buffer_rd_addr;

    bram_dac bram_dac_inst (
        .clka  (~axi_aclk),        //input clka
        .reseta(~axi_aresetn),     //input reseta
        .cea   (buffer_wr_dv),    //input cea
        .ada   (buffer_wr_addr),  //input [15:0] ada
        .din   (buffer_wr_data),  //input [7:0] din

        .clkb  (~dac_clk),         //input clkb
        .resetb(~axi_aresetn),     //input resetb
        .ceb   (buffer_rd_dv),    //input ceb
        .oce   (buffer_rd_dv),    //input oce
        .adb   (buffer_rd_addr),  //input [15:0] adb
        .dout  (dac_data)         //output [7:0] dout
    );

    // Output Address Generator
    reg oag_output_ctrl;
    reg oag_init_ctrl;
    always @(posedge axi_aclk) begin
        if ((!axi_aresetn) || oag_init_ctrl) begin
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

    // Buffer Writing Address Generator
    reg [15 : 0] bwag_s_addr;
    reg          bwag_s_int;
    reg          bwag_s_ctrl;
    always @(posedge axi_aclk) begin
        if (!axi_aresetn) begin
            buffer_wr_dv   <= 0;
            buffer_wr_addr <= 16'h0;
        end else begin
            if (bwag_s_int) begin
                buffer_wr_dv   <= 0;
                buffer_wr_addr <= bwag_s_addr;
            end else if (bwag_s_ctrl) begin
                buffer_wr_dv   <= 1;
                buffer_wr_addr <= buffer_wr_addr + 1;
            end else begin
                buffer_wr_dv   <= 0;
                buffer_wr_addr <= buffer_wr_addr;
            end
        end
    end

    // FSM
    reg [7 : 0] state;
    reg [7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_RECV_ADDR = 8'h1;
    localparam STATE_RECV_DATA = 8'h2;
    localparam STATE_SEND_BRESP = 8'h3;
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
                state_next = STATE_RECV_ADDR;
            end

            STATE_RECV_ADDR: begin
                if (axi_awvalid && axi_awready) begin
                    state_next = STATE_RECV_DATA;
                end else begin
                    state_next = STATE_RECV_ADDR;
                end
            end

            STATE_RECV_DATA: begin
                if (axi_wlast) begin
                    state_next = STATE_SEND_BRESP;
                end else begin
                    state_next = STATE_RECV_DATA;
                end
            end

            STATE_SEND_BRESP: begin
                if (axi_bvalid && axi_bready) begin
                    state_next = STATE_RECV_ADDR;
                end else begin
                    state_next = STATE_SEND_BRESP;
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
                axi_awready = 0;
                axi_wready  = 0;
                axi_bvalid  = 0;
            end

            STATE_RECV_ADDR: begin
                axi_awready = 1;
                axi_wready  = 0;
                axi_bvalid  = 0;
            end

            STATE_RECV_DATA: begin
                axi_awready = 0;
                axi_wready  = 1;
                axi_bvalid  = 0;
            end

            STATE_SEND_BRESP: begin
                axi_awready = 0;
                axi_wready  = 0;
                axi_bvalid  = 1;
            end

            default: begin
                axi_awready = 0;
                axi_wready  = 0;
                axi_bvalid  = 0;
            end
        endcase
    end

    always @(*) begin
        case (state)
            STATE_RESET: begin
                buffer_wr_data  = 8'h0;

                oag_output_ctrl = 0;
                oag_init_ctrl   = 1;

                bwag_s_addr     = 16'h0;
                bwag_s_int      = 0;
                bwag_s_ctrl     = 0;

                axi_bresp       = 2'b0;
            end

            STATE_RECV_ADDR: begin
                buffer_wr_data  = 8'h0;

                oag_output_ctrl = 1;
                oag_init_ctrl   = 0;

                if (axi_awvalid && axi_awready) begin
                    bwag_s_addr = axi_awaddr;
                    bwag_s_int  = 1;
                end else begin
                    bwag_s_addr = 16'h0;
                    bwag_s_int  = 0;
                end
                bwag_s_ctrl = 0;

                axi_bresp   = 2'b0;
            end

            STATE_RECV_DATA: begin
                if (axi_wvalid && axi_wready) begin
                    bwag_s_ctrl    = 1;
                    buffer_wr_data = axi_wdata;
                end else begin
                    bwag_s_ctrl    = 0;
                    buffer_wr_data = 8'h0;
                end

                oag_output_ctrl = 0;
                oag_init_ctrl   = 0;

                bwag_s_addr     = 16'h0;
                bwag_s_int      = 0;

                axi_bresp       = 2'b0;
            end

            STATE_SEND_BRESP: begin
                buffer_wr_data  = 8'h0;

                oag_output_ctrl = 0;
                oag_init_ctrl   = 1;

                bwag_s_addr     = 16'h0;
                bwag_s_int      = 0;
                bwag_s_ctrl     = 0;

                axi_bresp       = 2'b01;
            end

            default: begin
                buffer_wr_data  = 8'h0;

                oag_output_ctrl = 0;
                oag_init_ctrl   = 1;

                bwag_s_addr     = 16'h0;
                bwag_s_int      = 0;
                bwag_s_ctrl     = 0;

                axi_bresp       = 2'b0;
            end
        endcase
    end

endmodule
