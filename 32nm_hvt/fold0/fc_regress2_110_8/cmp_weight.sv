`include "DEF.sv"
`ifdef FOLD
module cmp_weight
(
    input logic [`NUM_CNT/`FOLD-1:0][`INWD-1:0]rng_cnt,
    input logic [`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0][`INWD-1:0]in,
    output logic [`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0] cmp_out
);

    genvar i;
    genvar j;

    generate 
    for (j = 0; j<`DIM_OUT/`FOLD; j = j+1) begin
    for (i = 0; i<`DIM_IN; i = i+1) begin
    always_comb begin : proc_2
        cmp_out[j][i] = (in[j][i] > rng_cnt[i*j/`SHARE]);
    end
    end
    end
    endgenerate

endmodule
`else
module cmp_weight
(
    input logic [`NUM_CNT-1:0][`INWD-1:0]rng_cnt,
    input logic [`DIM_OUT-1:0][`DIM_IN-1:0][`INWD-1:0]in,
    output logic [`DIM_OUT-1:0][`DIM_IN-1:0] cmp_out
);

    genvar i;
    genvar j;

    generate 
    for (j = 0; j<`DIM_OUT; j = j+1) begin
    for (i = 0; i<`DIM_IN; i = i+1) begin
    always_comb begin : proc_2
        cmp_out[j][i] = (in[j][i] > rng_cnt[i*j/`SHARE]);
    end
    end
    end
    endgenerate

endmodule
`endif