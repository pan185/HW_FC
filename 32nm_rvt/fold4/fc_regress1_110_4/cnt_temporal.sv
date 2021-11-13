`include "DEF.sv"
`ifdef FOLD
module cnt_temporal
(
    input logic clk,    // Clock
    input logic rst_n,  // Asynchronous reset active low
    input logic enable,
    output logic [`NUM_CNT/`FOLD-1:0][`INWD-1:0]cntOut
);

    logic[`NUM_CNT/`FOLD-1:0][`INWD-1:0]cnt;
    genvar share_w;

    generate
    for (share_w=0; share_w<`NUM_CNT/`FOLD; share_w=share_w+1) begin
    always_ff @(posedge clk or negedge rst_n) begin : proc_1
        if(~rst_n) begin
            cnt[share_w] <= 0;
        end else begin
            cnt[share_w] <= cnt[share_w] + enable;
        end
    end
    end
    endgenerate

    always_comb begin : proc_2
        cntOut <= cnt;
    end

endmodule
`else
module cnt_temporal
(
    input logic clk,    // Clock
    input logic rst_n,  // Asynchronous reset active low
    input logic enable,
    output logic [`NUM_CNT-1:0][`INWD-1:0]cntOut
);

    logic[`NUM_CNT-1:0][`INWD-1:0]cnt;
    genvar share_w;

    generate
    for (share_w=0; share_w<`NUM_CNT; share_w=share_w+1) begin
    always_ff @(posedge clk or negedge rst_n) begin : proc_1
        if(~rst_n) begin
            cnt[share_w] <= 0;
        end else begin
            cnt[share_w] <= cnt[share_w] + enable;
        end
    end
    end
    endgenerate

    always_comb begin : proc_2
        cntOut <= cnt;
    end

endmodule
`endif