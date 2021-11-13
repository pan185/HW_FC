`include "DEF.sv"
module wreg
(
    input logic clk,    // Clock
    input logic rst_n,  // Asynchronous reset active lo
    input logic enable,
    input logic [`DIM_OUT-1:0][`DIM_IN-1:0][`INWD-1:0]in, // Val to be written to reg
    output logic [`DIM_OUT-1:0][`DIM_IN-1:0][`INWD-1:0]out // Val read out
);
    logic [`DIM_OUT-1:0][`DIM_IN-1:0][`INWD-1:0]out_;

    always_ff @(posedge clk or negedge rst_n) begin : proc_1
        if(~rst_n) begin
            	out_ <= 0;
        end else if (enable) begin
            	out_ <= in;
        end
    end

    always_comb begin : proc_2
        out <= out_;
    end

endmodule
