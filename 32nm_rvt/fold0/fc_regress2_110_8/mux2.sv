`include "DEF.sv"
`ifdef MUX2
module mux2
(
    input logic [`LOG_FOLD-1:0] select,
    input logic[`DIM_OUT-1:0][`DIM_IN-1:0][`INWD-1:0] in,
    output logic [`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0][`INWD-1:0]out
);
    always @(in or select) begin
        if (select == 1'b0) begin
		out <= in[`DIM_OUT/2-1:0];
	end else begin
		out <= in[`DIM_OUT-1:`DIM_OUT/2];
	end
   end
    
endmodule
`endif
