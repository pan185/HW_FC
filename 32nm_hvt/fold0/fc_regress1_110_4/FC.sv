`include "DEF.sv"
`include "wreg.sv"

`include "in_BSG.sv"
`include "weight_BSG.sv"

`include "neuron.sv"

module FC(
    input logic clk,    // Clock
    input logic rst_n,  // Asynchronous reset active low
    input logic enable,
    input logic toggle,
`ifdef FOLD
    input logic [`LOG_FOLD-1:0] mux_select,
`endif
    input logic [`DIM_IN-1:0][`INWD-1:0]in,
    input logic [`DIM_OUT-1:0][`DIM_IN-1:0][`INWD-1:0]weight,
`ifdef FOLD
    output logic [`DIM_OUT/`FOLD-1:0][`INWD-1:0]mac_out_clipped
`else
    output logic [`DIM_OUT-1:0][`INWD-1:0]mac_out_clipped
`endif
);
    logic [`DIM_OUT-1:0][`DIM_IN-1:0][`INWD-1:0]weight_reg;
    logic [`DIM_IN-1:0] input_rate;
`ifdef FOLD
    logic [`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0] weight_temporal;
`else
    logic [`DIM_OUT-1:0][`DIM_IN-1:0] weight_temporal;
`endif

    wreg U_reg_weight(
	.clk(clk),
	.rst_n(rst_n),
	.enable(enable),
	.in(weight),
	.out(weight_reg));

    in_BSG U_in_bsg(
	.clk(clk),
	.rst_n(rst_n),
	.enable(enable),
	.in(in),
	.input_rate(input_rate));

    weight_BSG U_weight_bsg(
	.clk(clk),
	.rst_n(rst_n),
	.enable(enable),
`ifdef FOLD
	.mux_select(mux_select),
`endif
	.weight_reg(weight_reg),
	.weight_temporal(weight_temporal));
    
    neuron U_neuron(
	.clk(clk),
	.rst_n(rst_n),
	.enable(enable),
	.toggle(toggle),
	.input_rate(input_rate),
	.weight_temporal(weight_temporal),
	.mac_out_clipped(mac_out_clipped));

endmodule
