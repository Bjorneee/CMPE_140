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


module data_path #(localparam WIDTH = 32)(
    input[WIDTH - 1:0] N_INPUT,
    input logic Sel, Load_reg, Load_cnt, EN, OE, CLK,
    output logic N_GT_1, N_GT_12,
    output[WIDTH - 1:0] PRODUCT
    );
    
    wire[WIDTH - 1:0] n_out, n_prod, c_prod, out_sel_1;
    
    // CNT
    down_counter cnt(N_INPUT, Load_cnt, EN, CLK, n_out);
    
    // REG
    fact_reg register(out_sel_1, Load_reg, CLK, c_prod);
    
    // MUL
    assign n_prod = n_out * c_prod;
    
    // CMP 1
    assign N_GT_1 = (n_out > 32'd1);
    
    // CMP 12
    assign N_GT_12 = (n_out > 32'd12);
    
    // MUX PROD
    assign out_sel_1 = Sel ? n_prod : c_prod;
    
    // MUX OUT
    assign PRODUCT = OE ? c_prod : 32'b0;
    
endmodule

module down_counter #(localparam WIDTH = 32)(
    input[WIDTH - 1:0] D,
    input logic load_cnt, en, clk,
    output[WIDTH - 1:0] Q
    );
    
    reg[WIDTH - 1:0] count;
    
    always @ (posedge clk) begin
        if(load_cnt)
            count <= D;
        else if (en)
            count = count - 1;
    end
    
    assign Q = count;
    
endmodule

module fact_reg #(localparam WIDTH = 32)(
    input[WIDTH - 1:0] D,
    input logic load_reg, clk,
    output[WIDTH - 1:0] Q
    );
    
    reg[WIDTH - 1:0] data;
    
    always @ (posedge clk) begin
        if(load_reg) begin
            data[WIDTH - 1:1] = {WIDTH - 2{1'b0}};
            data[0] <= 1'b1;
        end
        else
            data <= D;
    end
    
    assign Q = data;
    
endmodule
