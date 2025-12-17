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
        input  wire [31:0] gpi1,
        input  wire [31:0] gpi2,
        //input  wire [4:0]  ra3,
        //output wire [31:0] rd3
        output wire [31:0] gpo1,
        output wire [31:0] gpo2,
        output wire [31:0] rd_data
    );

    wire [31:0] pc_current, instr, addr;
    wire [31:0] wd, rd_dm, rd_fa, rd_io;
    wire mem_write, we_dm, we_fa, we_io;

    mips mips (
            .clk            (clk),
            .rst            (rst),
            //.ra3            (ra3),
            .instr          (instr),
            .rd_dm          (rd_data),
            .we_dm          (mem_write),
            .pc_current     (pc_current),
            .alu_out        (addr),
            .wd_dm          (wd)
            //.rd3            (rd3),
        );

    imem imem (
            .a              (pc_current[7:2]),
            .y              (instr)
        );

    dmem dmem (
            .clk            (clk),
            .we             (we_dm),
            .a              (addr[7:2]),
            .d              (wd),
            .q              (rd_dm)
        );

    fa fa (
            .clk            (clk),
            .rst            (rst),
            .we             (we_fa),
            .wd             (wd[3:0]),
            .a              (addr[3:2]),
            .rd             (rd_fa)
        );

    gpio gpio (
            .clk            (clk),
            .rst            (rst),
            .we             (we_io),
            .a              (addr[3:2]),
            .gpi1           (gpi1),
            .gpi2           (gpi2),
            .wd             (wd),
            .gpo1           (gpo1),
            .gpo2           (gpo2),
            .rd             (rd_io)
        );

    // Address Decoder

    // Pages (addr[11:8])
    wire sel_fa = (addr[11:8] == 4'h8);
    wire sel_io = (addr[11:8] == 4'h9);
    wire sel_dm = (addr[11:8] == 4'h0) | (addr[11:8] == 4'h1);

    assign we_fa = mem_write & sel_fa;
    assign we_io = mem_write & sel_io;
    assign we_dm = mem_write & sel_dm;

    assign rd_data = sel_fa ? rd_fa :
                     sel_io ? rd_io :
                     rd_dm;



endmodule
