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
    wire [1:0] rd_sel;
    wire mem_write, we_dm, we_fa, we_io;

    mips mips (
            .clk            (clk),
            .rst            (rst),
            //.ra3            (ra3),
            .instr          (instr),
            .rd_dm          (rd_dm),
            .we_dm          (mem_write),
            .pc_current     (pc_current),
            .alu_out        (addr),
            .wd_dm          (wd),
            //.rd3            (rd3)
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
    always_comb begin
        case (addr[5:4])
            2'b00: begin
                we_dm = 1'b0;
                we_fa = 1'b0;
                we_io = 1'b0;
            end
            2'b01: begin
                we_dm = mem_write;
                we_fa = 1'b0;
                we_io = 1'b0;
            end
            2'b10: begin
                we_dm = 1'b0;
                we_fa = mem_write;
                we_io = 1'b0;
            end
            2'b11: begin
                we_dm = 1'b0;
                we_fa = 1'b0;
                we_io = mem_write;
            end
            default: begin
                we_dm = 1'bx;
                we_fa = 1'bx;
                we_io = 1'bx;
            end
        endcase
    end

    assign rd_sel = addr[5:4];

    // Output Mux
    always_comb begin
        case (rd_sel)
            2'b00: rd_data = rd_dm;
            2'b01: rd_data = rd_dm;
            2'b10: rd_data = rd_fa;
            2'b11: rd_data = rd_io;
            default: rd_data = 32'bx;
        endcase
    end

endmodule
