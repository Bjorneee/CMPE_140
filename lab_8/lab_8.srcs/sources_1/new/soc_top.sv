`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 03:51:54 AM
// Design Name: 
// Module Name: soc_top
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


module soc_top(
        input  wire        clk,
        input  wire        rst,
        //input  wire [4:0]  ra3,
        //output wire [31:0] rd3
        output  wire [31:0] rd_data
    );

    wire [31:0] pc_current, instr, alu_out;
    wire [31:0] addr, wd, rd_dm, rd_fa, rd_io;
    wire [1:0] rd_sel;
    wire mem_write, we_dm, we_fa, we_io;

    mips mips (
            .clk            (clk),
            .rst            (rst),
            //.ra3            (ra3),
            .instr          (instr),
            //.addr         (addr), // Need to implement
            .rd_dm          (rd_dm),
            .we_dm          (we_dm),
            .pc_current     (pc_current),
            .alu_out        (alu_out),
            .wd_dm          (wd_dm),
            //.rd3            (rd3)
        );

    imem imem (
            .a              (pc_current[7:2]),
            .y              (instr)
        );

    dmem dmem (
            .clk            (clk),
            .we             (we_dm),
            .a              (alu_out[7:2]),
            .d              (wd),
            .q              (rd_dm)
        );

    fa fa (
            .clk            (clk),
            .rst            (rst),
            .we             (we),
            .wd             (wd[3:0]),
            .rd             (rd_fa)
        );

    gpio gpio (
            .clk            (clk),
            .rst            (rst),
            .we             (we),
            .wd             (wd[15:0]),
            .rd             (rd_io)
        );

    address_decoder ad (
            .mem_we         (we),
            .addr           (addr),
            .we_dm          (we_dm),
            .we_fa          (we_fa),
            .we_io          (we_io),
            .rd_sel         (rd_sel)
        );

endmodule
