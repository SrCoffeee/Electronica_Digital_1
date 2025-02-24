`include "seven_segment_driver.v"
`include "binary_to_bcd.v"
`include "adc_control.v"
`include "clk_divider.v"
module top (
    input wire clk,
    input wire reset_n,
    input wire [7:0] adc_data,
    input wire eoc,
    output wire adc_clk,
    output wire start,
    output wire oe,
    output wire add_a,
    output wire add_b,
    output wire add_c,
    output wire [6:0] segmentos,
    output wire [2:0] anodos
);

// Instancias
clk_divider clk_div_adc (
    .CLK_IN(clk),
    .CLK_OUT(adc_clk)
);

adc_control adc_ctrl (
    .clk(clk),
    .reset_n(reset_n),
    .eoc(eoc),
    .start(start),
    .oe(oe),

);

wire [3:0] hundreds, tens, unit;
binary_to_bcd bcd_conv (
    .binary(adc_data),
    .hundreds(hundreds),
    .tens(tens),
    .unit(unit)
);

seven_segment_driver display (
    .clk(clk),
    .reset_n(reset_n),
    .digit0(unit),
    .digit1(tens),
    .digit2(hundreds),
    .segmentos(segmentos),
    .anodos(anodos)
);

endmodule
