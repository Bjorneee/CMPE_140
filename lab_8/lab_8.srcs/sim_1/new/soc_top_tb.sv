`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 10:58:38 AM
// Design Name: 
// Module Name: soc_top_tb
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

module soc_top_tb;

    // Clock and reset
    logic        clk;
    logic        rst;

    // GPIO inputs/outputs
    logic  [31:0] gpi1;
    logic  [31:0] gpi2;
    wire   [31:0] gpo1;
    wire   [31:0] gpo2;

    // Data returned to the CPU (from dmem/fact/gpio mux)
    wire   [31:0] rd_data;

    // DUT instance
    soc_top dut (
        .clk    (clk),
        .rst    (rst),
        .gpi1   (gpi1),
        .gpi2   (gpi2),
        .gpo1   (gpo1),
        .gpo2   (gpo2),
        .rd_data(rd_data)
    );

    // Clock generation: 100 MHz (10 ns period)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Reset + simple GPIO stimulus
    initial begin
        // Initialize inputs
        rst  = 1'b1;
        gpi1 = 32'h0000_0000;
        gpi2 = 32'h0000_0000;

        // Hold reset for a bit
        #40;
        rst = 1'b0;

        // Wait a few cycles, then change GPIO inputs
        // (You can tweak these to match whatever your program expects)
        repeat (10) @(posedge clk);
        gpi1 = 32'h0000_0005;   // example: maybe factorial input, switches, etc.
        gpi2 = 32'h0000_00A0;

        // Change again later if desired
        repeat (50) @(posedge clk);
        gpi1 = 32'h0000_0003;
        gpi2 = 32'h0000_000F;

        // Let the program run for a while
        repeat (500) @(posedge clk);

        $display("Simulation finished.");
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("soc_top_tb.vcd");
        $dumpvars(0, soc_top_tb);
    end

    // Simple debug printing
    // Uses hierarchical references into soc_top for handy visibility.
    // These names match your soc_top internal nets: pc_current, addr, etc.
    initial begin
        $display("Time     PC          ALU_addr    GPO1        GPO2        rd_data");
        $display("-----------------------------------------------------------------");
        forever begin
            @(posedge clk);
            if (!rst) begin
                $display("%0t  %h  %h  %h  %h  %h",
                         $time,
                         dut.pc_current,
                         dut.addr,
                         gpo1,
                         gpo2,
                         rd_data);
            end
        end
    end

endmodule
