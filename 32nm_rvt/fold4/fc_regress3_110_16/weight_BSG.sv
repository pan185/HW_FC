`include "DEF.sv"
`include "cnt_temporal.sv"
`include "cmp_weight.sv"
`ifdef FOLD
module weight_BSG
(
    input clk,
    input rst_n,
    input enable,
    input [`LOG_FOLD-1:0] mux_select,
    input logic[`DIM_OUT-1:0][`DIM_IN-1:0][`INWD-1:0] weight_reg,
    output logic[`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0]  weight_temporal
);
    logic [`NUM_CNT/`FOLD-1:0][`INWD-1:0] cntOut;
    logic [`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0][`INWD-1:0] weight_reg_mux;
`ifdef MUX2   
    mux2 U_weight_folding_mux2(
	.select(mux_select),
	.in(weight_reg),
	.out(weight_reg_mux));
`endif
`ifdef MUX4
    mux4 U_weight_folding_mux2(
	.select(mux_select),
	.in(weight_reg),
	.out(weight_reg_mux));
`endif

    cnt_temporal U_weight_temporal_cnt(
	.clk(clk),
	.rst_n(rst_n),
	.enable(enable),
	.cntOut(cntOut));

    cmp_weight U_weight_temporal_cmp(
	.rng_cnt(cntOut),
	.in(weight_reg_mux),
	.cmp_out(weight_temporal));
endmodule
`else
module weight_BSG
(
    input clk,
    input rst_n,
    input enable,
    input logic[`DIM_OUT-1:0][`DIM_IN-1:0][`INWD-1:0] weight_reg,
    output logic[`DIM_OUT-1:0][`DIM_IN-1:0]  weight_temporal
);
    logic [`NUM_CNT-1:0][`INWD-1:0] cntOut;
    // temporal weight
    cnt_temporal U_weight_temporal_cnt(
	.clk(clk),
	.rst_n(rst_n),
	.enable(enable),
	.cntOut(cntOut));

    cmp_weight U_weight_temporal_cmp(
	.rng_cnt(cntOut),
	.in(weight_reg),
	.cmp_out(weight_temporal));
endmodule
`endif
