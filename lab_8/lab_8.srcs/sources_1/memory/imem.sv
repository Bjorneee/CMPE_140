`timescale 1ns / 1ps

module imem (
        input  wire [5:0]  a,
        output wire [31:0] y
    );

    reg [31:0] rom [0:63];

    initial begin
        `include "imem_init.svh"
    end

    assign y = rom[a];
    
endmodule