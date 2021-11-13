`include "DEF.sv"
`ifdef MUX4
module mux4
(
    input logic [`LOG_FOLD-1:0] select,
    input logic[`DIM_OUT-1:0][`DIM_IN-1:0][`INWD-1:0] in,
    output logic [`DIM_OUT/`FOLD-1:0][`DIM_IN-1:0][`INWD-1:0]out
);
    always @(in or select) begin
        if (select == 2'b00) begin
		out <= in[`DIM_OUT/4-1:0];
	end else if (select == 2'b01) begin
		out <= in[`DIM_OUT/2-1:`DIM_OUT/4];
	end else if (select == 2'b10) begin
		out <= in[`DIM_OUT/2+`DIM_OUT/4-1:`DIM_OUT/2];
	end else begin
		out <= in[`DIM_OUT-1: `DIM_OUT/2+`DIM_OUT/4];
	end
   end
    
endmodule
`endif
