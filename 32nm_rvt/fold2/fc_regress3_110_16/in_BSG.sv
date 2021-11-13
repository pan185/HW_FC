`include "DEF.sv"
`include "SobolRNGDim1.sv"
`include "cmp_input.sv"
module in_BSG
(
    input clk,
    input rst_n,
    input enable,
    input logic [`DIM_IN-1:0][`INWD-1:0]in,
    output logic [`DIM_IN-1:0] input_rate
);
    logic [`NUM_RNG-1:0][`INWD-1:0]rng_seq;

    // rate INPUT
    SobolRNGDim1 U_input_rng(
	.clk(clk),
	.rst_n(rst_n),
	.enable(enable),
	.rng_seq(rng_seq));

    cmp_input U_input_rate_cmp(
	.rng_cnt(rng_seq),
	.in(in),
	.cmp_out(input_rate));

endmodule
