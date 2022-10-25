module sys_fsm (
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
    output reg [ 7 : 0] pack_pack_type

);
    always @(*) begin
        unpack_busy = 0;
    end
endmodule
