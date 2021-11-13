`include "DEF.sv"
module cmp_input
(
    input logic [`NUM_RNG-1:0][`INWD-1:0]rng_cnt,
    input logic [`DIM_IN-1:0][`INWD-1:0]in,
    output logic [`DIM_IN-1:0] cmp_out
);
    genvar i;

    generate 
    for (i = 0; i<`DIM_IN; i = i+1)
    begin
    always_comb begin : proc_2
        cmp_out[i] = (in[i] >= rng_cnt[i/`SHARE]);
    end
    end
    endgenerate

endmodule