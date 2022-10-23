module ccu_write_dac_fsm (
    input clk,
    input resetn,

    // DAC AXI
    output reg [15 : 0] dac_axi_awaddr,
    output reg          dac_axi_awvalid,
    input               dac_axi_awready,

    output reg [7 : 0] dac_axi_wdata,
    output reg         dac_axi_wvalid,
    input              dac_axi_wready,
    output reg         dac_axi_wlast,

    input      [1 : 0] dac_axi_bresp,
    input              dac_axi_bvalid,
    output reg         dac_axi_bready,

    // FIFO Interface
    input      [7 : 0] fifo_rd_data,
    output reg         fifo_rd_dv,
    input              fifo_rd_empty,

    // CTRL
    input ctrl_writedac_dv,

    // Interrupts
    output reg int_writedac_finish,
    output reg int_writedac_err
);
    reg [7 : 0] state;
    reg [7 : 0] state_next;
    localparam STATE_RESET = 8'h0;
    localparam STATE_WRITE_ADDR = 8'h1;
    localparam STATE_WRITE_DATA = 8'h2;
    localparam STATE_RECV_BRESP = 8'h3;
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
                state_next = STATE_WRITE_ADDR;
            end

            STATE_WRITE_ADDR: begin
                if (dac_axi_awvalid && dac_axi_awready) begin
                    state_next = STATE_WRITE_DATA;
                end else begin
                    state_next = STATE_WRITE_ADDR;
                end
            end

            STATE_WRITE_DATA: begin
                if (fifo_rd_empty || !(dac_axi_wvalid && dac_axi_wready)) begin
                    state_next = STATE_RECV_BRESP;
                end else begin
                    state_next = STATE_WRITE_DATA;
                end
            end

            STATE_RECV_BRESP: begin
                if (dac_axi_bvalid && dac_axi_bready) begin
                    state_next = STATE_WRITE_ADDR;
                end else begin
                    state_next = STATE_RECV_BRESP;
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
                dac_axi_awaddr      = 16'h0;
                dac_axi_awvalid     = 0;

                dac_axi_wdata       = 8'h0;
                dac_axi_wvalid      = 0;
                dac_axi_wlast       = 0;

                dac_axi_bready      = 0;

                fifo_rd_dv          = 0;

                int_writedac_finish = 0;
                int_writedac_err    = 0;
            end

            STATE_WRITE_ADDR: begin
                fifo_rd_dv      = 1;
                dac_axi_awvalid = 1;
                if (dac_axi_awvalid && dac_axi_awready) begin
                    dac_axi_awaddr = fifo_rd_data;
                end else begin
                    dac_axi_awaddr = 16'h0;
                end

                dac_axi_wdata       = 8'h0;
                dac_axi_wvalid      = 0;
                dac_axi_wlast       = 0;

                dac_axi_bready      = 0;

                int_writedac_finish = 0;
                int_writedac_err    = 0;
            end

            STATE_WRITE_DATA: begin
                dac_axi_awaddr  = 16'h0;
                dac_axi_awvalid = 0;

                dac_axi_wvalid  = 1;
                if (dac_axi_wvalid && dac_axi_wready) begin
                    dac_axi_wdata = fifo_rd_data;
                    fifo_rd_dv    = 1;
                end else begin
                    dac_axi_wdata = 16'h0;
                    fifo_rd_dv    = 0;
                end

                if (fifo_rd_empty) begin
                    dac_axi_wlast = 1;
                end else begin
                    dac_axi_wlast = 0;
                end
            end

            STATE_RECV_BRESP: begin
                dac_axi_awaddr  = 16'h0;
                dac_axi_awvalid = 0;

                dac_axi_wdata   = 8'h0;
                dac_axi_wvalid  = 0;
                dac_axi_wlast   = 0;

                dac_axi_bready  = 1;
                if (dac_axi_bvalid && dac_axi_bready) begin
                    int_writedac_finish = 1;

                    if (dac_axi_bresp == 2'b01) begin
                        int_writedac_err = 0;
                    end else begin
                        int_writedac_err = 1;
                    end
                end else begin
                    int_writedac_finish = 0;
                    int_writedac_err    = 0;
                end

                fifo_rd_dv = 0;
            end

            default: begin
                dac_axi_awaddr      = 16'h0;
                dac_axi_awvalid     = 0;

                dac_axi_wdata       = 8'h0;
                dac_axi_wvalid      = 0;
                dac_axi_wlast       = 0;

                dac_axi_bready      = 0;

                fifo_rd_dv          = 0;

                int_writedac_finish = 0;
                int_writedac_err    = 0;
            end
        endcase
    end
endmodule
