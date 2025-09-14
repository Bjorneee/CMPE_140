`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2025 08:26:10 AM
// Design Name: 
// Module Name: data_path
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


module data_path(
    input[31:0] N_INPUT,
    input SEL, LD_REG, LD_CNT, EN, OE, CLK,
    output n_gt_1, n_gt_12,
    output[31:0] product_out
    );
    
    wire[31:0] n_out, n_prod, c_prod, out_sel_1;
    
    // CNT
    cnt down_counter(N_INPUT, LD_CNT, EN, CLK, n_out);
    
    // REG
    reg32 register(out_sel_1, LD_REG, CLK, c_prod);
    
    // MUL
    assign n_prod = n_out * c_prod;
    
    // CMP 1
    assign n_gt_1 = (n_out > 32'd1);
    
    // CMP 12
    assign n_gt_12 = (n_out > 32'd12);
    
    // MUX PROD
    assign out_sel_1 = SEL ? n_prod : c_prod;
    
    // MUX OUT
    assign product_out = OE ? c_prod : 32'b0;
    
endmodule
