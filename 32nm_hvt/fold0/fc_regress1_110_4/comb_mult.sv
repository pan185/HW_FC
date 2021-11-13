`include "DEF.sv"

`ifdef FOLD
module comb_mult
(
    input logic [`DIM_IN-1:0]in,
    input logic [`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0]weight,
    output logic [`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0] mult_out
);
    genvar i;
    genvar j;

    generate 
    for (j = 0; j<`DIM_OUT/`FOLD; j = j+1) begin
    for (i = 0; i<`DIM_IN; i = i+1) begin
    always_comb begin : proc_2
        mult_out[j][i] = (~in[i] & ~weight[j][i]) | (in[i] & weight[j][i]);
    end
    end
    end
    endgenerate

endmodule
`else
module comb_mult
(
    input logic [`DIM_IN-1:0]in,
    input logic [`DIM_OUT-1:0][`DIM_IN-1:0]weight,
    output logic [`DIM_OUT-1:0][`DIM_IN-1:0] mult_out
);
    genvar i;
    genvar j;

    generate 
    for (j = 0; j<`DIM_OUT; j = j+1) begin
    for (i = 0; i<`DIM_IN; i = i+1) begin
    always_comb begin : proc_2
        mult_out[j][i] = (~in[i] & ~weight[j][i]) | (in[i] & weight[j][i]);
    end
    end
    end
    endgenerate

endmodule
`endif