`define PACKAGE_TYPE_SYS_RESET 8'h00 // System Reset
`define PACKAGE_TYPE_DATA_DAC 8'h11 // DAC data (first byte is address to write)
`define PACKAGE_TYPE_DATA_ADC 8'h12 // ADC data (generally return to computer)
`define PACKAGE_TYPE_REQ_ADC 8'h21 // request ADC data
`define PACKAGE_TYPE_REQ_DAC 8'h22 // request DAC data

module ccu (
    input axi_aclk,
    input axi_aresetn,

    // SPI RX AXI4S
    input  [7 : 0] spi_recv_axis_rdata,
    input          spi_recv_axis_rvalid,
    output         spi_recv_axis_rready,
    input          spi_recv_axis_rlast,

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

    wire          dac_fsm_busy;
    wire          dac_fsm_dv;
    wire          sys_fsm_busy;
    wire          sys_fsm_dv;
    wire          adc_fsm_busy;
    wire          adc_fsm_dv;

    wire [15 : 0] pack_id;
    wire [12 : 0] pack_length;
    wire [ 7 : 0] pack_data;
    wire [ 7 : 0] pack_type;

    ccu_unpack ccu_unpack_inst (
        .axi_aclk   (axi_aclk),
        .axi_aresetn(axi_aresetn),

        .axis_rvalid(spi_recv_axis_rvalid),
        .axis_rready(spi_recv_axis_rready),
        .axis_rdata (spi_recv_axis_rdata),
        .axis_rlast (spi_recv_axis_rlast),

        .dac_fsm_busy(0),
        .dac_fsm_dv  (dac_fsm_dv),
        .sys_fsm_busy(0),
        .sys_fsm_dv  (sys_fsm_dv),
        .adc_fsm_busy(0),
        .adc_fsm_dv  (adc_fsm_dv),

        .pack_id    (pack_id),
        .pack_length(pack_length),
        .pack_data  (pack_data),
        .pack_type  (pack_type)
    );

endmodule
