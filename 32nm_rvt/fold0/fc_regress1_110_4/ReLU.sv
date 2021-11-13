`include "DEF.sv"
`ifdef FOLD
module ReLU
(
    input logic [`DIM_OUT/`FOLD-1:0][`INWD+`LOG_DIM_IN-1:0]in,
    output logic [`DIM_OUT/`FOLD-1:0][`INWD-1:0] relu_out
);
    genvar j;
    generate
    for (j=0; j<`DIM_OUT/`FOLD; j = j+1) begin
`ifndef NP2
`ifdef HARDTANH
// <=?DIM_IN-1?*128: Clip to -1
// [DIM_IN*128-127, DIM_IN*128+127] NO CLIP
// >= DIM_IN*128 +127 cLIP TO 255
    always_comb begin 
        if (in[j][`INWD+`LOG_DIM_IN-1:`INWD-1] < `DIM_IN-1) begin: clip_to_0
		relu_out[j] = '0; //clipped to -1
	end 
	else if (in[j][`INWD+`LOG_DIM_IN-1] & in[j][`INWD-1]) begin: clip_to_255
		relu_out[j] = '1; //clipped to +1
	end 
	else if (in[j][`INWD+`LOG_DIM_IN-1]==1'b0) begin : less_than_0_no_clip
		relu_out[j] = {1'b0, in[j][(`INWD-2):0]};
	end
	else begin: gt_0_no_clip
		relu_out[j] = {1'b1, in[j][(`INWD-2):0]};
	end
    end
`else
// <DIM_IN*128: CLIP TO 128
// [DIM_IN*128, DIM_IN*128+127] NO CLIP
// >=DIM_IN*128+128: CLIP TO 255
    always_comb begin 
	if (in[j][`INWD+`LOG_DIM_IN-1]==1'b0) begin: clip_to_128
		relu_out[j] = 1'b1 << (`INWD-1); //clipped to 0
	end 
        else if (in[j][`INWD+`LOG_DIM_IN-1] & in[j][`INWD-1]) begin: clip_to_255_hardRELU
		relu_out[j] = '1; //clipped to +1
	end 
	else begin: no_clip
		relu_out[j] = {1'b1, in[(`INWD-2):0]};
	end
    end
`endif
`else
///////////////////NP2 RELU///////////////////////
`ifdef HARDTANH
//Note: This is technically impossible
// <=(DIM_IN-1)*128: Clip to -1
// [DIM_IN*128-127, DIM_IN*128+127] NO CLIP
// >= DIM_IN*128+127 cLIP TO 255
    always_comb begin 
        if (in[j][`INWD+`LOG_DIM_IN-1:`INWD-1] < `DIM_IN-1) begin: clip_to_0
		relu_out[j] = '0; //clipped to -1
	end 
	else if (in[j][`INWD+`LOG_DIM_IN-1] & in[j][`INWD-1]) begin: clip_to_255
		relu_out[j] = '1; //clipped to +1
	end 
	else if (in[j][`INWD+`LOG_DIM_IN-1]==1'b0) begin : less_than_0_no_clip
		relu_out[j] = {1'b0, in[j][(`INWD-2):0]};
	end
	else begin: gt_0_no_clip
		relu_out[j] = {1'b1, in[j][(`INWD-2):0]};
	end
    end
`else
// <DIM_IN*128: CLIP TO 128
// [DIM_IN*128, DIM_IN*128+127] NO CLIP
// >=DIM_IN*128+128: CLIP TO 255
    always_comb begin 
	if (in[j][`INWD+`LOG_DIM_IN-1:(`INWD-1)]<`DIM_IN) begin: clip_to_128
		relu_out[j] = 1'b1 << (`INWD-1); //clipped to 0
	end 
        else if (in[j][`INWD+`LOG_DIM_IN-1:(`INWD-1)] >= `DIM_IN+1) begin: clip_to_255_hardRELU
		relu_out[j] = '1; //clipped to +1
	end 
	else begin: no_clip
		relu_out[j] = {1'b1, in[j][(`INWD-2):0]};
	end
    end
`endif
`endif
    end
    endgenerate

endmodule
`else
module ReLU
(
    input logic [`DIM_OUT-1:0][`INWD+`LOG_DIM_IN-1:0]in,
    output logic [`DIM_OUT-1:0][`INWD-1:0] relu_out
);
    genvar j;
    generate
    for (j=0; j<`DIM_OUT; j = j+1) begin
`ifndef NP2
`ifdef HARDTANH
// <=?DIM_IN-1?*128: Clip to -1
// [DIM_IN*128-127, DIM_IN*128+127] NO CLIP
// >= DIM_IN*128 +127 cLIP TO 255
    always_comb begin 
        if (in[j][`INWD+`LOG_DIM_IN-1:`INWD-1] < `DIM_IN-1) begin: clip_to_0
		relu_out[j] = '0; //clipped to -1
	end 
	else if (in[j][`INWD+`LOG_DIM_IN-1] & in[j][`INWD-1]) begin: clip_to_255
		relu_out[j] = '1; //clipped to +1
	end 
	else if (in[j][`INWD+`LOG_DIM_IN-1]==1'b0) begin : less_than_0_no_clip
		relu_out[j] = {1'b0, in[j][(`INWD-2):0]};
	end
	else begin: gt_0_no_clip
		relu_out[j] = {1'b1, in[j][(`INWD-2):0]};
	end
    end
`else
// <DIM_IN*128: CLIP TO 128
// [DIM_IN*128, DIM_IN*128+127] NO CLIP
// >=DIM_IN*128+128: CLIP TO 255
    always_comb begin 
	if (in[j][`INWD+`LOG_DIM_IN-1]==1'b0) begin: clip_to_128
		relu_out[j] = 1'b1 << (`INWD-1); //clipped to 0
	end 
        else if (in[j][`INWD+`LOG_DIM_IN-1] & in[j][`INWD-1]) begin: clip_to_255_hardRELU
		relu_out[j] = '1; //clipped to +1
	end 
	else begin: no_clip
		relu_out[j] = {1'b1, in[(`INWD-2):0]};
	end
    end
`endif
`else
///////////////////NP2 RELU///////////////////////
`ifdef HARDTANH
//Note: This is technically impossible
// <=(DIM_IN-1)*128: Clip to -1
// [DIM_IN*128-127, DIM_IN*128+127] NO CLIP
// >= DIM_IN*128+127 cLIP TO 255
    always_comb begin 
        if (in[j][`INWD+`LOG_DIM_IN-1:`INWD-1] < `DIM_IN-1) begin: clip_to_0
		relu_out[j] = '0; //clipped to -1
	end 
	else if (in[j][`INWD+`LOG_DIM_IN-1] & in[j][`INWD-1]) begin: clip_to_255
		relu_out[j] = '1; //clipped to +1
	end 
	else if (in[j][`INWD+`LOG_DIM_IN-1]==1'b0) begin : less_than_0_no_clip
		relu_out[j] = {1'b0, in[j][(`INWD-2):0]};
	end
	else begin: gt_0_no_clip
		relu_out[j] = {1'b1, in[j][(`INWD-2):0]};
	end
    end
`else
// <DIM_IN*128: CLIP TO 128
// [DIM_IN*128, DIM_IN*128+127] NO CLIP
// >=DIM_IN*128+128: CLIP TO 255
    always_comb begin 
	if (in[j][`INWD+`LOG_DIM_IN-1:(`INWD-1)]<`DIM_IN) begin: clip_to_128
		relu_out[j] = 1'b1 << (`INWD-1); //clipped to 0
	end 
        else if (in[j][`INWD+`LOG_DIM_IN-1:(`INWD-1)] >= `DIM_IN+1) begin: clip_to_255_hardRELU
		relu_out[j] = '1; //clipped to +1
	end 
	else begin: no_clip
		relu_out[j] = {1'b1, in[j][(`INWD-2):0]};
	end
    end
`endif
`endif
    end
    endgenerate

endmodule
`endif