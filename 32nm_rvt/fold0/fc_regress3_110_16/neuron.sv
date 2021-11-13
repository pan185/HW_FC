`include "DEF.sv"
`include "comb_mult.sv"
`include "ReLU.sv"
`include "accumulator.sv"
`include "PC.sv"

`ifdef FOLD
module neuron
(
    input clk,
    input rst_n,
    input enable,
    input toggle,
    input logic [`DIM_IN-1:0] input_rate,
    input logic [`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0] weight_temporal,
    output logic [`DIM_OUT/`FOLD-1:0][`INWD-1:0]mac_out_clipped
);
    logic [`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0] mulOut;
    logic [`DIM_OUT/`FOLD-1:0][`LOG_DIM_IN:0]pc_out_comb;
    logic [`DIM_OUT/`FOLD-1:0][`INWD+`LOG_DIM_IN-1:0]mac_out;

    // comb logic to do rate & temporal multiplication
    comb_mult U_comb_mult(
	.in(input_rate),
	.weight(weight_temporal),
	.mult_out(mulOut));

    // PC
    PC U_pc(
	.mulOut(mulOut),
	.pc_out_comb(pc_out_comb)
	);
    // accumulator
    accumulator U_accumulator(
	.clk(clk),
	.rst_n(rst_n),
	.enable(enable),
	.control_knob(toggle),
	.clear('0),
	.val(pc_out_comb),
	.sum(mac_out));

    // ReLU
    ReLU U_ReLU(
	.in(mac_out),
	.relu_out(mac_out_clipped));
    
endmodule
`else
module neuron
(
    input clk,
    input rst_n,
    input enable,
    input toggle,
    input logic [`DIM_IN-1:0] input_rate,
    input logic [`DIM_OUT-1:0][`DIM_IN-1:0] weight_temporal,
    output logic [`DIM_OUT-1:0][`INWD-1:0]mac_out_clipped
);
    logic [`DIM_OUT-1:0][`DIM_IN-1:0] mulOut;
    logic [`DIM_OUT-1:0][`LOG_DIM_IN:0]pc_out_comb;
    logic [`DIM_OUT-1:0][`INWD+`LOG_DIM_IN-1:0]mac_out;

    // comb logic to do rate & temporal multiplication
    comb_mult U_comb_mult(
	.in(input_rate),
	.weight(weight_temporal),
	.mult_out(mulOut));

    // PC
    PC U_pc(
	.mulOut(mulOut),
	.pc_out_comb(pc_out_comb)
	);
    // accumulator
    accumulator U_accumulator(
	.clk(clk),
	.rst_n(rst_n),
	.enable(enable),
	.control_knob(toggle),
	.clear('0),
	.val(pc_out_comb),
	.sum(mac_out));

    // ReLU
    ReLU U_ReLU(
	.in(mac_out),
	.relu_out(mac_out_clipped));
    
endmodule
`endif