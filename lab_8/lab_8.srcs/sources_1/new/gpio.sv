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

    reg [N-1:0] rd_reg;
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

    gpio_ad decoder (
        .a          (a),
        .we         (we),
        .we1        (we1),
        .we2        (we2),
        .rd_sel     (rdsel)
    );

    always_comb begin
        case (rd_sel)
            2'b00: rd_reg = gpi1;
            2'b01: rd_reg = gpi2;
            2'b10: rd_reg = gpo1_w;
            2'b11: rd_reg = gpo2_w;
            default: rd_reg = {(N-1){1'bx}};
        endcase
    end

    assign rd = rd_reg;
    assign gpo1 = gpo1_w;
    assign gpo2 = gpo2_w;

endmodule

module gpio_ad (
    input  wire [1:0] a,
    input  wire       we,
    output wire       we1,
    output wire       we2,
    output wire [1:0] rd_sel
);

    reg we1_reg, we2_reg;

    always_comb begin
        case (a)
            2'b00: begin
                we1_reg = 1'b0;
                we2_reg = 1'b0;
            end
            2'b01: begin
                we1_reg = 1'b0;
                we2_reg = 1'b0;
            end
            2'b10: begin
                we1_reg = we;
                we2_reg = 1'b0;
            end
            2'b11: begin
                we1_reg = 1'b0;
                we2_reg = we;
            end
            default: begin
                we1_reg = 1'bx;
                we2_reg = 1'bx;
            end
        endcase
    end

    assign we1 = we1_reg;
    assign we2 = we2_reg;
    assign rd_sel = a;

endmodule

module gpio_reg #(localparam N = 32) (
    input  wire         clk,
    input  wire         rst,
    input  wire [N-1:0] d,
    input  wire         en,
    output wire [N-1:0] q
);

    reg [N-1:0] q_reg;

    always @ (posedge clk, posedge rst) begin

        if (rst) q_reg <= 0;
        else if (en) q_reg <= d;
        else q_reg <= q_reg;

    end

    assign q = q_reg;

endmodule