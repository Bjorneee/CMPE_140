`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2025 10:07:47 AM
// Design Name: 
// Module Name: cnt
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


module cnt(
    input[31:0] in32,
    input load, enable, clk,
    output[31:0] out32
    );
    
    reg[31:0] count;
    
    always @ (posedge clk) begin
        if(load)
            count <= in32;
        else if (enable)
            count = count - 1;
    end
    
    assign out32 = count;
    
endmodule
