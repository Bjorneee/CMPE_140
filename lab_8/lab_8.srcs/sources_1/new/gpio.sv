`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 05:54:13 AM
// Design Name: 
// Module Name: gpio
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


module gpio #(localparam N = 16) (
        input  wire         clk,
        input  wire         rst,
        input  wire         we,
        input  wire [N-1:0] wd,
        output wire [N-1:0] rd
    );


    
endmodule
