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


module gpio #(localparam N = 32) (
        input  wire         clk,
        input  wire         rst,
        input  wire         we,
        input  wire [3:2]   a,
        input  wire [N-1:0] gpi1,
        input  wire [N-1:0] gpi2,
        input  wire [N-1:0] wd,
        output wire [N-1:0] gpo1,
        output wire [N-1:0] gpo2,
        output wire [N-1:0] rd
    );

    wire [31:0] gpo1_w, gpo2_w;
    wire [1:0] rd_sel;
    wire we1, we2;

    gpio_reg gpo1_reg (
        .clk        (clk),
        .rst        (rst),
        .d          (gpi1),
        .en         (we1),
        .q          (gpo1_w)
    );

    gpio_reg gpo2_reg (
        .clk        (clk),
        .rst        (rst),
        .d          (gpi2),
        .en         (we2),
        .q          (gpo2_w)
    );

    always_comb begin
        case (rd_sel)
            2'b00: rd = gpi1;
            2'b01: rd = gpi2;
            2'b10: rd = gpo1_w;
            2'b11: rd = gpo2_w;
            default: rd = 32'bx;
        endcase
    end

endmodule

module gpio_ad (
    input  wire [1:0] a,
    input  wire       we,
    output wire       we1,
    output wire       we2,
    output wire [1:0] rd_sel
);

    always_comb begin
        case (a)
            2'b00: begin
                we1 = 1'b0;
                we2 = 1'b0;
            end
            2'b01: begin
                we1 = 1'b0;
                we2 = 1'b0;
            end
            2'b10: begin
                we1 = WE;
                we2 = 1'b0;
            end
            2'b11: begin
                we1 = 1'b0;
                we2 = WE;
            end
            default: begin
                we1 = 1'bx;
                we2 = 1'bx;
            end
        endcase
    end

    assign rd_sel = a;

endmodule

module gpio_reg #(localparam N = 32) (
    input  wire       clk,
    input  wire       rst,
    input  wire [N-1] d,
    input  wire       en,
    output wire [N-1] q
);

    always @ (posedge clk, posedge rst) begin

        if (rst) q <= 0;
        else if (en) q <= d;
        else q <= q;

    end

endmodule