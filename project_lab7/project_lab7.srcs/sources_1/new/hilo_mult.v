module hilo_mult (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire        en,
    input  wire        sel,
    input  wire        clk,
    input  wire        rst,
    output wire [31:0] y
    );

    wire [63:0] prod_64;
    wire [63:0] mux_out;
    wire [31:0] mfhi;
    wire [31:0] mflo;

    reg [31:0] hi;
    reg [31:0] lo;

    assign prod_64 = a * b;

    mux2 #(64) mul_en_mux (
        .sel            (en),
        .a              ({mfhi, mflo}),
        .b              (prod_64),
        .y              (mux_out)
        );

    dreg hi_reg (
        .clk            (clk),
        .rst            (rst),
        .d              (mux_out[63:32]),
        .q              (mfhi)
        );

    dreg lo_reg (
        .clk            (clk),
        .rst            (rst),
        .d              (mux_out[31:0]),
        .q              (mflo)
        );

    mux2 #(32) hilo_mux (
        .sel            (sel),
        .a              (mfhi),
        .b              (mflo),
        .y              (y)
        );
    
endmodule
