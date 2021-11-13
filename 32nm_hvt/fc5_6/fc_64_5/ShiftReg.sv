`include "DEF.sv"
module ShiftReg
(
    input logic clk,    // Clock
    input logic rst_n,  // Asynchronous reset active lo
    input logic [`INWD-1:0]serial_in, // Val to be written to reg
    output logic [`NUM_RNG-1:0][`INWD-1:0]parallel_out // Val read out
);
    logic [`NUM_RNG-2:0][`INWD-1:0]out_;

    genvar i;
    generate
    for (i=1; i < `NUM_RNG-1; i=i+1) begin
    always_ff @(posedge clk or negedge rst_n) begin : proc_ff
        if(~rst_n) begin
            out_[i] <= 0;
        end else begin
            out_[i] <= out_[i-1];
        end
    end
    end
    endgenerate
    always_ff @(posedge clk or negedge rst_n) begin : proc_ff
        if(~rst_n) begin
            out_[0] <= 0;
        end else begin
            out_[0] <= serial_in;
        end
    end
   
    always_comb begin : proc_comb
	parallel_out[`NUM_RNG-1:1] <= out_[`NUM_RNG-2:0];
        parallel_out[0] <= serial_in;
    end


endmodule