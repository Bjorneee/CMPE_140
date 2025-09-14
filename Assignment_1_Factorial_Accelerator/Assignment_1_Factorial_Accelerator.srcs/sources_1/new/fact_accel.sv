`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2025 08:26:10 AM
// Design Name: 
// Module Name: fact_accel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fact_accel #(localparam WIDTH = 32)(
    input [WIDTH - 1:0] N,
    input logic START, RESET, CLK,
    output [WIDTH - 1:0] product,
    output logic error, done
    );
    
    wire gt_fact, gt_intp;
    wire SEL, LOAD_CNT, LOAD_REG, OUT_EN, ENABLE;
    
    control_unit CU(.GO(START), 
                    .N_GT_1(gt_fact), 
                    .N_GT_12(gt_intp), 
                    .CLK(CLK), 
                    .RESET(RESET),
                    .sel(SEL), 
                    .load_reg(LOAD_REG), 
                    .load_cnt(LOAD_CNT), 
                    .en_cnt(ENABLE), 
                    .en_out(OUT_EN),
                    .fact_error(error), 
                    .fact_done(done));
    
    data_path DP(   .N_INPUT(N), 
                    .SEL(SEL), 
                    .LD_REG(LOAD_REG), 
                    .LD_CNT(LOAD_CNT), 
                    .EN(ENABLE), 
                    .OE(OUT_EN), 
                    .CLK(CLK), 
                    .n_gt_1(gt_fact), 
                    .n_gt_12(gt_intp), 
                    .product_out(product));
    
endmodule
