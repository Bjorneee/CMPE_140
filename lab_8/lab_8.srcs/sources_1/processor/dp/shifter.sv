`timescale 1ns / 1ps

module shifter (
    input  wire [31:0] d,
    input  wire [4:0]  shamt,
    input  wire        dir,
    output wire [31:0] q
    );

    assign q = (dir) ? (d >> shamt) : (d << shamt);
    
endmodule