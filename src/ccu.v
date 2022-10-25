`define PACKAGE_TYPE_SYS_RESET 8'h00 // System Reset
`define PACKAGE_TYPE_DATA_DAC 8'h11 // DAC data (first byte is address to write)
`define PACKAGE_TYPE_DATA_ADC 8'h12 // ADC data (generally return to computer)
`define PACKAGE_TYPE_REQ_ADC 8'h21 // request ADC data
`define PACKAGE_TYPE_REQ_DAC 8'h22 // request DAC data

module ccu (
    input axi_aclk,
    input axi_aresetn,

    // SPI
    input  [7 : 0] rxd_out,
    output [7 : 0] txd_data,
    input          rxd_flag,

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
    output [7 : 0] adc_axis_tdata,
    output         adc_axis_tvalid,
    input          adc_axis_tready,
    output         adc_axis_tlast
);

    wire          dac_fsm_busy;
    wire          dac_fsm_dv;
    wire          sys_fsm_busy;
    wire          sys_fsm_dv;
    wire          adc_fsm_busy;
    wire          adc_fsm_dv;

    wire [15 : 0] unpack_pack_id;
    wire [12 : 0] unpack_pack_length;
    wire [ 7 : 0] unpack_pack_data;
    wire [ 7 : 0] unpack_pack_type;

    ccu_unpack ccu_unpack_inst (
        .clk (axi_aclk),
        .rstn(axi_aresetn),

        .rxd_out (rxd_out),
        .rxd_flag(rxd_flag),

        .dac_fsm_busy(dac_fsm_busy),
        .dac_fsm_dv  (dac_fsm_dv),
        .sys_fsm_busy(sys_fsm_busy),
        .sys_fsm_dv  (sys_fsm_dv),
        .adc_fsm_busy(adc_fsm_busy),
        .adc_fsm_dv  (adc_fsm_dv),

        .pack_id    (unpack_pack_id),
        .pack_length(unpack_pack_length),
        .pack_data  (unpack_pack_data),
        .pack_type  (unpack_pack_type)
    );

    wor  pack_dv;
    wire pack_busy;

    wire [15 : 0] pack_pack_id;
    wire [12 : 0] pack_pack_length;
    wire [ 7 : 0] pack_pack_data;
    wire [ 7 : 0] pack_pack_type;

    ccu_pack ccu_pack_inst (
        .clk (axi_aclk),
        .rstn(axi_aresetn),

        .txd_data(txd_data),
        .rxd_flag(rxd_flag),

        .pack_en  (pack_dv),
        .pack_busy(pack_busy),

        .pack_id    (pack_pack_id),
        .pack_length(pack_pack_length),
        .pack_data  (pack_pack_data),
        .pack_type  (pack_pack_type)
    );

    adc_fsm adc_fsm_inst (
        .clk (axi_aclk),
        .rstn(axi_aresetn),

        // From CCU Unpack
        .unpack_busy       (adc_fsm_busy),
        .unpack_en         (adc_fsm_dv),
        .unpack_pack_id    (unpack_pack_id),
        .unpack_pack_length(unpack_pack_length),
        .unpack_pack_data  (unpack_pack_data),
        .unpack_pack_type  (unpack_pack_type),

        // To CCU Pack
        .pack_busy       (pack_busy),
        .pack_dv         (pack_dv),
        .pack_pack_id    (pack_pack_id),
        .pack_pack_length(pack_pack_length),
        .pack_pack_data  (pack_pack_data),
        .pack_pack_type  (pack_pack_type),

        // ADC Interface
        .axis_tvalid(adc_axis_tvalid),
        .axis_tready(adc_axis_tready),
        .axis_tdata (adc_axis_tdata),
        .axis_tlast (adc_axis_tlast)
    );

    dac_fsm dac_fsm_inst (
        .clk (axi_aclk),
        .rstn(axi_aresetn),

        // From CCU Unpack
        .unpack_busy       (dac_fsm_busy),
        .unpack_en         (dac_fsm_dv),
        .unpack_pack_id    (unpack_pack_id),
        .unpack_pack_length(unpack_pack_length),
        .unpack_pack_data  (unpack_pack_data),
        .unpack_pack_type  (unpack_pack_type),

        // To CCU Pack
        .pack_busy       (pack_busy),
        .pack_dv         (pack_dv),
        .pack_pack_id    (pack_pack_id),
        .pack_pack_length(pack_pack_length),
        .pack_pack_data  (pack_pack_data),
        .pack_pack_type  (pack_pack_type),

        // DAC
        .axi_awaddr (dac_axi_awaddr),
        .axi_awvalid(dac_axi_awvalid),
        .axi_awready(dac_axi_awready),

        .axi_wdata (dac_axi_wdata),
        .axi_wvalid(dac_axi_wvalid),
        .axi_wready(dac_axi_wready),
        .axi_wlast (dac_axi_wlast),

        .axi_bresp (dac_axi_bresp),
        .axi_bvalid(dac_axi_bvalid),
        .axi_bready(dac_axi_bready)
    );
endmodule
