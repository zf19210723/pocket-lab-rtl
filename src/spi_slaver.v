//极性特点：时钟空闲时为高电平
//sck的时钟要大大小于clk的时钟，至多为clk/8
module spi_slaver (
    input clk,
    input rstn,

    input      cs,
    input      sck,
    input      MOSI,
    output reg MISO,

    output reg [7:0] rxd_out,
    input      [7:0] txd_data,
    output           rxd_flag
);
    reg [7:0] rxd_data;
    reg sck_r0, sck_r1;
    wire sck_n, sck_p;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sck_r0 <= 1'b1;
            sck_r1 <= 1'b1;

        end else begin
            sck_r0 <= sck;
            sck_r1 <= sck_r0;
        end
    end
    assign sck_n = (~sck_r0 & sck_r1) ? 1'b1 : 1'b0;
    assign sck_p = (~sck_r1 & sck_r0) ? 1'b1 : 1'b0;
    //-----------------------spi_slaver read data-------------------------------
    reg       rxd_flag_r;
    reg [7:0] rxd_state;
    always @(posedge clk) begin
        if (!rstn) begin
            rxd_data   <= 1'b0;
            rxd_flag_r <= 1'b0;
            rxd_state  <= 1'b0;
        end else begin
            if (sck_p && !cs) begin
                case (rxd_state)
                    3'd0: begin
                        rxd_data[7] <= MOSI;
                        rxd_flag_r  <= 1'b0;  //reset rxd_flag
                        rxd_state   <= 3'd1;
                    end
                    3'd1: begin
                        rxd_data[6] <= MOSI;
                        rxd_flag_r  <= 1'b0;
                        rxd_state   <= 3'd2;
                    end
                    3'd2: begin
                        rxd_data[5] <= MOSI;
                        rxd_flag_r  <= 1'b0;
                        rxd_state   <= 3'd3;
                    end
                    3'd3: begin
                        rxd_data[4] <= MOSI;
                        rxd_flag_r  <= 1'b0;
                        rxd_state   <= 3'd4;
                    end
                    3'd4: begin
                        rxd_data[3] <= MOSI;
                        rxd_flag_r  <= 1'b0;
                        rxd_state   <= 3'd5;
                    end
                    3'd5: begin
                        rxd_data[2] <= MOSI;
                        rxd_flag_r  <= 1'b0;
                        rxd_state   <= 3'd6;
                    end
                    3'd6: begin
                        rxd_data[1] <= MOSI;
                        rxd_flag_r  <= 1'b0;
                        rxd_state   <= 3'd7;
                    end
                    3'd7: begin
                        rxd_out     <= {rxd_data[7:1], MOSI};
                        rxd_data[0] <= MOSI;
                        rxd_flag_r  <= 1'b1;  //set rxd_flag
                        rxd_state   <= 3'd0;
                    end
                    default: begin
                        rxd_data   <= rxd_data;
                        rxd_flag_r <= rxd_flag_r;
                        rxd_state  <= rxd_state;
                    end
                endcase
            end else begin
                rxd_data   <= rxd_data;
                rxd_flag_r <= rxd_flag_r;
                rxd_state  <= rxd_state;
            end
        end
    end


    //--------------------capture spi_flag posedge--------------------------------
    reg rxd_flag_r0, rxd_flag_r1;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rxd_flag_r0 <= 1'b0;
            rxd_flag_r1 <= 1'b0;
        end else begin
            rxd_flag_r0 <= rxd_flag_r;
            rxd_flag_r1 <= rxd_flag_r0;
        end
    end

    assign rxd_flag = (~rxd_flag_r1 && rxd_flag_r0) ? 1'b1 : 1'b0;

    //---------------------spi_slaver send data---------------------------
    reg [7:0] txd_state;
    always @(posedge clk) begin
        if (!rstn) begin
            txd_state <= 3'd0;
            MISO      <= 1'b1;
        end else begin
            if (sck_p && !cs) begin
                case (txd_state)
                    3'd0: begin
                        MISO      <= txd_data[7];
                        txd_state <= 3'd1;
                    end
                    3'd1: begin
                        MISO      <= txd_data[6];
                        txd_state <= 3'd2;
                    end
                    3'd2: begin
                        MISO      <= txd_data[5];
                        txd_state <= 3'd3;
                    end
                    3'd3: begin
                        MISO      <= txd_data[4];
                        txd_state <= 3'd4;
                    end
                    3'd4: begin
                        MISO      <= txd_data[3];
                        txd_state <= 3'd5;
                    end
                    3'd5: begin
                        MISO      <= txd_data[2];
                        txd_state <= 3'd6;
                    end
                    3'd6: begin
                        MISO      <= txd_data[1];
                        txd_state <= 3'd7;
                    end
                    3'd7: begin
                        MISO      <= txd_data[0];
                        txd_state <= 3'd0;
                    end
                    default: begin
                        txd_state <= 3'd0;
                        MISO      <= 1'b1;
                    end
                endcase
            end else begin
                txd_state <= txd_state;
                MISO      <= MISO;
            end
        end
    end

endmodule
