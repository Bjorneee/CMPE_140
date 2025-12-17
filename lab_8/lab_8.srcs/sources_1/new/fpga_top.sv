`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2025 04:25:24 AM
// Design Name: 
// Module Name: fpga_top
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


module fpga_top(
    input        clk,
    input        rst,
    input  [4:0] sw,
    output [4:0] led,
    output [3:0] seg_led_sel,
    output [6:0] seg_led
    );

    wire clk_5kHz;
    clk_gen Clock_Generator (
        .clk50MHz   (clk),
        .rst        (rst),
        //clksec4,
        .clk_5KHz   (clk_5kHz)
        );

    wire [31:0] gpO1, gpO2, gpI1;
    assign gpI1 = {27'b0, sw};
    soc_top System (
        .clk        (clk_5KHz),
        .rst        (rst),
        .gpi1       (gpI1),
        .gpi2       (gpO1),
        .gpo1       (gpO1),
        .gpo2       (gpO2)
        //,.rd_data
    );

    wire dispSe, factErr;
    assign led[4] = dispSe;
    assign led[3:0] = {4{factErr}};

    assign dispSe = gpO1[4]; // Hi/Lo Select
    assign factErr = gpO1[0]; // Error bit shifted to index 0 in program

    wire [15:0] hex_bus;
    assign hex_bus = dispSe ? gpO2[31:16] : gpO2[15:0];

    wire [3:0] dig0, dig1, dig2, dig3, dig4, dig5, dig6, dig7;
    wire [6:0] LED3, LED2, LED1, LED0;

    bin2hex32 U1(
        .value(hex_bus),    // Display output to 7-seg display
        .dig0(dig0),
        .dig1(dig1),
        .dig2(dig2),
        .dig3(dig3)
        );
        
    hex2led U_LD_3(
        .number(dig3),
        .s0(LED3[0]),
        .s1(LED3[1]),
        .s2(LED3[2]),
        .s3(LED3[3]),
        .s4(LED3[4]),
        .s5(LED3[5]),
        .s6(LED3[6])
        );
        
    hex2led U_LD_2(
        .number(dig2),
        .s0(LED2[0]),
        .s1(LED2[1]),
        .s2(LED2[2]),
        .s3(LED2[3]),
        .s4(LED2[4]),
        .s5(LED2[5]),
        .s6(LED2[6])
        );
        
    hex2led U_LD_1(
        .number(dig1),
        .s0(LED1[0]),
        .s1(LED1[1]),
        .s2(LED1[2]),
        .s3(LED1[3]),
        .s4(LED1[4]),
        .s5(LED1[5]),
        .s6(LED1[6])
        );
    hex2led U_LD_0(
        .number(dig0),
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
        .LEDOUT(seg_led),
        .LEDSEL(seg_led_sel)
        );

endmodule

module bin2hex32(
    input wire [15:0] value,
    output wire [3:0] dig0,
    output wire [3:0] dig1,
    output wire [3:0] dig2,
    output wire [3:0] dig3
    );
    
    assign dig0 = value[3:0];
    assign dig1 = value[7:4];
    assign dig2 = value[11:8];
    assign dig3 = value[15:12];
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
