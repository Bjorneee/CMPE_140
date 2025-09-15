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
    input [WIDTH - 1:0] N_INPUT,
    input logic GO, RESET, CLK,
    output [WIDTH - 1:0] PRODUCT,
    output logic ERROR, DONE
    );
    
    wire N_GT_1, N_GT_12;
    wire Sel, Load_cnt, Load_reg, OE, EN;
    
    control_unit CU(.GO(GO), 
                    .N_GT_1(N_GT_1), 
                    .N_GT_12(N_GT_12), 
                    .CLK(CLK), 
                    .RESET(RESET),
                    .Sel(Sel), 
                    .Load_reg(Load_reg), 
                    .Load_cnt(Load_cnt), 
                    .EN(EN), 
                    .OE(OE),
                    .ERROR(ERROR), 
                    .DONE(DONE));
                    
    data_path DP(   .N_INPUT(N_INPUT), 
                    .Sel(Sel), 
                    .Load_reg(Load_reg), 
                    .Load_cnt(Load_cnt), 
                    .EN(EN), 
                    .OE(OE), 
                    .CLK(CLK), 
                    .N_GT_1(N_GT_1), 
                    .N_GT_12(N_GT_12), 
                    .PRODUCT(PRODUCT));
    
endmodule
