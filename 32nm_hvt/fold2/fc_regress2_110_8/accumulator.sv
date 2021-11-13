`include "DEF.sv"
`ifdef FOLD
module accumulator
(
    input logic clk,    // Clock
    input logic rst_n,  // Asynchronous reset active low
    input logic enable,
    input logic control_knob,
    input logic clear,
    input logic[`DIM_OUT/`FOLD-1:0] [`LOG_DIM_IN:0]val, // input val to be accumulated
    output logic [`DIM_OUT/`FOLD-1:0][`INWD+`LOG_DIM_IN-1:0]sum
);
`ifdef DOUBLE_BUFF
    logic[`DIM_OUT/`FOLD-1:0][`INWD+`LOG_DIM_IN-1:0]  sum_0;
    logic[`DIM_OUT/`FOLD-1:0][`INWD+`LOG_DIM_IN-1:0]  sum_1;

    logic select;
    always_ff @(posedge clk or negedge rst_n) begin : select_logic_db
	if(~rst_n) begin
	    select <= 0;
	end else if (control_knob) begin
	    select <= ~select;
        end
    end

    genvar j;
    generate
    for (j=0; j < `DIM_OUT/`FOLD; j=j+1) begin
    always_ff @(posedge clk or negedge rst_n) begin : sum_logic_db
        if(~rst_n) begin
            sum_0[j] <= 0;
	    sum_1[j] <= 0;
	end else if (clear) begin
	    if (select) begin
	    	sum_1[j] <= 0;
	    end else begin
		sum_0[j] <= 0;
	    end
        end else begin
		if (enable) begin
			if (select) begin
				sum_1[j] <= sum_1[j]+val[j];
			end else begin
				sum_0[j] <= sum_0[j] + val[j];
			end
		end
		else begin
			sum_0[j] <= sum_0[j];
			sum_1[j] <= sum_1[j];
		end
        end
    end
    end
    endgenerate

    always_comb begin : proc_2
        if (select) begin
		sum <= sum_1;
	end else begin
		sum <= sum_0;
	end
    end
`else

    logic[`DIM_OUT/`FOLD-1:0][`INWD+`LOG_DIM_IN-1:0] sum_;

    genvar j;
    generate
    for (j=0; j < `DIM_OUT/`FOLD; j=j+1) begin
    always_ff @(posedge clk or negedge rst_n) begin : proc_1
        if(~rst_n) begin
            sum_[j] <= 0;
	end else if (clear) begin
	    sum_[j] <= 0;
        end else begin
		if (enable) begin
			sum_[j] <= sum_[j]+val[j];
		end
		else begin
			sum_[j] <= sum_[j];
		end
        end
    end
    end
    endgenerate
   
    always_comb begin : proc_2
        sum <= sum_;
    end
`endif
endmodule
`else
module accumulator
(
    input logic clk,    // Clock
    input logic rst_n,  // Asynchronous reset active low
    input logic enable,
    input logic control_knob,
    input logic clear,
    input logic[`DIM_OUT-1:0] [`LOG_DIM_IN:0]val, // input val to be accumulated
    output logic [`DIM_OUT-1:0][`INWD+`LOG_DIM_IN-1:0]sum
);
`ifdef DOUBLE_BUFF
    logic[`DIM_OUT-1:0][`INWD+`LOG_DIM_IN-1:0]  sum_0;
    logic[`DIM_OUT-1:0][`INWD+`LOG_DIM_IN-1:0]  sum_1;

    logic select;
    always_ff @(posedge clk or negedge rst_n) begin : select_logic_db
	if(~rst_n) begin
	    select <= 0;
	end else if (control_knob) begin
	    select <= ~select;
        end
    end

    genvar j;
    generate
    for (j=0; j < `DIM_OUT; j=j+1) begin
    always_ff @(posedge clk or negedge rst_n) begin : sum_logic_db
        if(~rst_n) begin
            sum_0[j] <= 0;
	    sum_1[j] <= 0;
	end else if (clear) begin
	    if (select) begin
	    	sum_1[j] <= 0;
	    end else begin
		sum_0[j] <= 0;
	    end
        end else begin
		if (enable) begin
			if (select) begin
				sum_1[j] <= sum_1[j]+val[j];
			end else begin
				sum_0[j] <= sum_0[j] + val[j];
			end
		end
		else begin
			sum_0[j] <= sum_0[j];
			sum_1[j] <= sum_1[j];
		end
        end
    end
    end
    endgenerate

    always_comb begin : proc_2
        if (select) begin
		sum <= sum_1;
	end else begin
		sum <= sum_0;
	end
    end
`else

    logic[`DIM_OUT-1:0][`INWD+`LOG_DIM_IN-1:0] sum_;

    genvar j;
    generate
    for (j=0; j < `DIM_OUT; j=j+1) begin
    always_ff @(posedge clk or negedge rst_n) begin : proc_1
        if(~rst_n) begin
            sum_[j] <= 0;
	end else if (clear) begin
	    sum_[j] <= 0;
        end else begin
		if (enable) begin
			sum_[j] <= sum_[j]+val[j];
		end
		else begin
			sum_[j] <= sum_[j];
		end
        end
    end
    end
    endgenerate
   
    always_comb begin : proc_2
        sum <= sum_;
    end
`endif
endmodule
`endif