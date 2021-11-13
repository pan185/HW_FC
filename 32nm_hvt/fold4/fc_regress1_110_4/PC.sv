`include "DEF.sv"
`include "adderTree.sv"
`ifdef FOLD
module PC
(
    input logic[`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0] mulOut,
    output logic[`DIM_OUT/`FOLD-1:0][`LOG_DIM_IN:0] pc_out_comb
);
    
    genvar j;
    generate
    for (j=0; j<`DIM_OUT/`FOLD; j = j+1) begin
    UnsignedAdderTree U_adderTree(
	.in_addends(mulOut[j]),
	.out_sum(pc_out_comb[j])
	);
    end
    endgenerate
endmodule
`else
module PC
(
    input logic[`DIM_OUT-1:0][`DIM_IN-1:0] mulOut,
    output logic[`DIM_OUT-1:0][`LOG_DIM_IN:0] pc_out_comb
);
    
    genvar j;
    generate
    for (j=0; j<`DIM_OUT; j = j+1) begin
    UnsignedAdderTree U_adderTree(
	.in_addends(mulOut[j]),
	.out_sum(pc_out_comb[j])
	);
    end
    endgenerate
endmodule
`endif