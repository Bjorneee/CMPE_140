`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2025 01:47:16 AM
// Design Name: 
// Module Name: basys3_top
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


module basys3_top(
    input clk,
    input rst,
    input start,
    input HILO_sel, 
    input [12:0] sw,
    output HILO_led,
    output error,
    output done,
    output [12:0] led,
    output [3:0] LEDSEL,
    output [6:0] LEDOUT
    );
    
    reg  [31:0] N;
    wire [31:0] product;

    // DUT
    fact_accel FDUT (
        .N(N),
        .START(start),
        .RESET(rst),
        .CLK(clk),
        .product(product),
        .error(error),
        .done(done)
        );
    
    input_switches (
        .in_sw(sw), 
        .HILO_sel(HILO_sel), 
        .sw_led(led), 
        .HILO_led(HILO_led), 
        .FACT_INPUT(N)
        );
    
    wire clk_5kHz;
    wire [3:0] dig0, dig1, dig2, dig3, dig4, dig5, dig6, dig7;
    wire [3:0] HEX3, HEX2, HEX1, HEX0;
    wire [6:0] LED3, LED2, LED1, LED0;
    
    clk_gen U0 (
        .clk50MHz(clk),
        .rst(rst),
        //clksec4,
        .clk_5KHz(clk_5kHz)
        );
        
    bin2hex32 U1(
        .value(product),
        .dig0(dig0),
        .dig1(dig1),
        .dig2(dig2),
        .dig3(dig3),
        .dig4(dig4),
        .dig5(dig5),
        .dig6(dig6),
        .dig7(dig7)
        );
        
    HILO_MUX DUT(
        .HI_dig3(dig7),
        .HI_dig2(dig6),
        .HI_dig1(dig5),
        .HI_dig0(dig4),
        .LO_dig3(dig3),
        .LO_dig2(dig2),
        .LO_dig1(dig1),
        .LO_dig0(dig0),
        .HILO_sel(HILO_sel),
        .HW_dig3(HEX3),
        .HW_dig2(HEX2),
        .HW_dig1(HEX1),
        .HW_dig0(HEX0)
        );
        
    hex2led U_LD_3(
        .number(HEX3),
        .s0(LED3[0]),
        .s1(LED3[1]),
        .s2(LED3[2]),
        .s3(LED3[3]),
        .s4(LED3[4]),
        .s5(LED3[5]),
        .s6(LED3[6])
        );
        
    hex2led U_LD_2(
        .number(HEX2),
        .s0(LED2[0]),
        .s1(LED2[1]),
        .s2(LED2[2]),
        .s3(LED2[3]),
        .s4(LED2[4]),
        .s5(LED2[5]),
        .s6(LED2[6])
        );
        
    hex2led U_LD_1(
        .number(HEX1),
        .s0(LED1[0]),
        .s1(LED1[1]),
        .s2(LED1[2]),
        .s3(LED1[3]),
        .s4(LED1[4]),
        .s5(LED1[5]),
        .s6(LED1[6])
        );
    hex2led U_LD_0(
        .number(HEX0),
        .s0(LED0[0]),
        .s1(LED0[1]),
        .s2(LED0[2]),
        .s3(LED0[3]),
        .s4(LED0[4]),
        .s5(LED0[5]),
        .s6(LED0[6])
        );
    
    LED_MUX U3(
        .clk(clk_5kHz),
        .rst(rst),
        .LED0(LED0),
        .LED1(LED1),
        .LED2(LED2),
        .LED3(LED3),
        .LEDOUT(LEDOUT),
        .LEDSEL(LEDSEL)
        );
        
endmodule

module input_switches(
    input wire [12:0] in_sw,
    input wire HILO_sel,
    output wire [12:0] sw_led,
    output wire HILO_led,
    output wire [31:0] FACT_INPUT
    );
    
    // Enable LEDs
    assign sw_led[0] = in_sw[0];
    assign sw_led[1] = in_sw[1];
    assign sw_led[2] = in_sw[2];
    assign sw_led[3] = in_sw[3];
    assign sw_led[4] = in_sw[4];
    assign sw_led[5] = in_sw[5];
    assign sw_led[6] = in_sw[6];
    assign sw_led[7] = in_sw[7];
    assign sw_led[8] = in_sw[8];
    assign sw_led[9] = in_sw[9];
    assign sw_led[10] = in_sw[10];
    assign sw_led[11] = in_sw[11];
    assign sw_led[12] = in_sw[12];
    assign HILO_led = HILO_sel;
    
    reg [31:0] in;
    
    // Assign inputs
    always @ (*) begin
        case (in_sw)
            13'b0000000000001: in = 32'd1;
            13'b0000000000010: in = 32'd2;
            13'b0000000000100: in = 32'd3;
            13'b0000000001000: in = 32'd4;
            13'b0000000010000: in = 32'd5;
            13'b0000000100000: in = 32'd6;
            13'b0000001000000: in = 32'd7;
            13'b0000010000000: in = 32'd8;
            13'b0000100000000: in = 32'd9;
            13'b0001000000000: in = 32'd10;
            13'b0010000000000: in = 32'd11;
            13'b0100000000000: in = 32'd12;
            13'b1000000000000: in = 32'd13;
            default: in = 32'd0;
        endcase
    end
    
    assign FACT_INPUT = in;
    
endmodule

module bin2hex32(
    input wire [31:0] value,
    output wire [3:0] dig0,
    output wire [3:0] dig1,
    output wire [3:0] dig2,
    output wire [3:0] dig3,
    output wire [3:0] dig4,
    output wire [3:0] dig5,
    output wire [3:0] dig6,
    output wire [3:0] dig7
    );
    
    assign dig0 = value & 4'hFF;
    assign dig1 = value >> 4 & 4'hFF;
    assign dig2 = value >> 8 & 4'hFF;
    assign dig3 = value >> 12 & 4'hFF;
    assign dig4 = value >> 16 & 4'hFF;
    assign dig5 = value >> 20 & 4'hFF;
    assign dig6 = value >> 24 & 4'hFF;
    assign dig7 = value >> 28 & 4'hFF;
endmodule

module HILO_MUX(
    input wire [3:0] HI_dig3,
    input wire [3:0] HI_dig2,
    input wire [3:0] HI_dig1,
    input wire [3:0] HI_dig0,
    input wire [3:0] LO_dig3,
    input wire [3:0] LO_dig2,
    input wire [3:0] LO_dig1,
    input wire [3:0] LO_dig0,
    input wire HILO_sel,
    output wire [3:0] HW_dig3,
    output wire [3:0] HW_dig2,
    output wire [3:0] HW_dig1,
    output wire [3:0] HW_dig0
    );
    
    assign HW_dig3 = HILO_sel ? HI_dig3 : LO_dig3;
    assign HW_dig2 = HILO_sel ? HI_dig2 : LO_dig2;
    assign HW_dig1 = HILO_sel ? HI_dig1 : LO_dig1;
    assign HW_dig0 = HILO_sel ? HI_dig0 : LO_dig0;
endmodule

module hex2led(number, s0, s1, s2, s3, s4, s5, s6);

    output s0, s1, s2, s3, s4, s5, s6;
    input [3:0] number;
    reg s0, s1, s2, s3, s4, s5, s6;
    
    always @ (number) begin
        case (number)
            4'h0: begin s0=0; s1=0; s2=0; s3=0; s4=0; s5=0; s6=1; end
            4'h1: begin s0=1; s1=0; s2=0; s3=1; s4=1; s5=1; s6=1; end
            4'h2: begin s0=0; s1=0; s2=1; s3=0; s4=0; s5=1; s6=0; end
            4'h3: begin s0=0; s1=0; s2=0; s3=0; s4=1; s5=1; s6=0; end
            4'h4: begin s0=1; s1=0; s2=0; s3=1; s4=1; s5=0; s6=0; end
            4'h5: begin s0=0; s1=1; s2=0; s3=0; s4=1; s5=0; s6=0; end
            4'h6: begin s0=0; s1=1; s2=0; s3=0; s4=0; s5=0; s6=0; end
            4'h7: begin s0=0; s1=0; s2=0; s3=1; s4=1; s5=1; s6=1; end
            4'h8: begin s0=0; s1=0; s2=0; s3=0; s4=0; s5=0; s6=0; end
            4'h9: begin s0=0; s1=0; s2=0; s3=1; s4=1; s5=0; s6=0; end
            4'ha: begin s0=0; s1=0; s2=0; s3=0; s4=0; s5=1; s6=0; end
            4'hb: begin s0=1; s1=1; s2=0; s3=0; s4=0; s5=0; s6=0; end
            4'hc: begin s0=1; s1=1; s2=1; s3=0; s4=0; s5=1; s6=0; end
            4'hd: begin s0=1; s1=0; s2=0; s3=0; s4=0; s5=1; s6=0; end
            4'he: begin s0=0; s1=0; s2=1; s3=0; s4=0; s5=0; s6=0; end
            4'hf: begin s0=0; s1=1; s2=1; s3=1; s4=0; s5=0; s6=0; end
            default: begin s0=1; s1=1; s2=1; s3=1; s4=1; s5=1; s6=1; end
        endcase
    end
endmodule

module clk_gen(clk50MHz, rst, clksec4, clk_5KHz); 

    input clk50MHz, rst;
    output clksec4, clk_5KHz;
    reg clksec4, clk_5KHz;
    integer count, count1;
    
    always@(posedge clk50MHz) begin
        if(rst) begin
            count = 0;
            count1 = 0;
            clksec4 = 0;
            clk_5KHz =0;
        end
        else begin
        
            if(count == 100000000) begin
                clksec4 = ~clksec4;
                count = 0;
            end
            if(count1 == 20000) begin
                clk_5KHz = ~clk_5KHz;
                count1 = 0;
            end
            
            count = count + 1;
            count1 = count1 + 1;
        end
    end
endmodule

module LED_MUX (clk, rst, LED0, LED1, LED2, LED3, LEDOUT, LEDSEL);

    input clk, rst;
    input [6:0] LED0, LED1, LED2, LED3;
    output[3:0] LEDSEL;
    output[6:0] LEDOUT;
    reg [3:0] LEDSEL;
    reg [6:0] LEDOUT;
    reg [1:0] index;
    
    always @(posedge clk) begin
        if(rst)
            index = 0;
        else
            index = index + 1;
    end
    always @(index or LED0 or LED1 or LED2 or LED3) begin
        
        case(index)
            0: begin
                LEDSEL = 4'b1110;
                LEDOUT = LED0;
            end
            1: begin
                LEDSEL = 4'b1101;
                LEDOUT = LED1;
            end
            2: begin
                LEDSEL = 4'b1011;
                LEDOUT = LED2;
            end
            3: begin
                LEDSEL = 4'b0111;
                LEDOUT = LED3;
            end
            default: begin
                LEDSEL = 0; LEDOUT = 0;
            end
        endcase
    end
endmodule
