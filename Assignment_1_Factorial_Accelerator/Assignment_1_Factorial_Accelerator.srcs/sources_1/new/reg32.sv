`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2025 10:15:59 AM
// Design Name: 
// Module Name: reg32
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


module reg32(
    input[31:0] D,
    input load, clk,
    output[31:0] Q
    );
    
    reg[31:0] data;
    
    always @ (posedge clk) begin
        if(load) begin
            data[31:1] = 31'b0;
            data[0] <= 1'b1;
        end
        else
            data <= D;
    end
    
    assign Q = data;
    
endmodule
