module dac_fsm (
    input clk,
    input rstn,

    // From CCU Unpack
    output reg          unpack_busy,
    input               unpack_en,
    input      [15 : 0] unpack_pack_id,
    input      [12 : 0] unpack_pack_length,
    input      [ 7 : 0] unpack_pack_data,
    input      [ 7 : 0] unpack_pack_type,

    // To CCU Pack
    input               pack_busy,
    output reg          pack_dv,
    output reg [15 : 0] pack_pack_id,
    output reg [12 : 0] pack_pack_length,
    output reg [ 7 : 0] pack_pack_data,
    output reg [ 7 : 0] pack_pack_type,

    // DAC Interface
    output reg [15 : 0] axi_awaddr,
    output reg          axi_awvalid,
    input               axi_awready,

    output reg [7 : 0] axi_wdata,
    output reg         axi_wvalid,
    input              axi_wready,
    output reg         axi_wlast,

    input      [1 : 0] axi_bresp,
    input              axi_bvalid,
    output reg         axi_bready
);
    always @(*) begin
        unpack_busy = 0;
    end

endmodule
