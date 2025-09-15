`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2025 10:34:45 AM
// Design Name: 
// Module Name: testbench
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

module testbench;

  reg  [31:0] N;
  reg  GO, RESET, CLK;
  wire [31:0] product;
  wire error, done;

  fact_accel DUT (
    .N_INPUT(N),
    .GO(GO),
    .RESET(RESET),
    .CLK(CLK),
    .PRODUCT(product),
    .ERROR(error),
    .DONE(done)
  );

  // Clock
  initial CLK = 0;
  always #10 CLK = ~CLK;

  integer i;

  // Factorial function for expected values
  function [31:0] fact_ref(input integer val);
    integer k;
    begin
      if (val == 0 || val == 1)
        fact_ref = 1;
      else if (val > 12)
        fact_ref = 0;
      else begin
        fact_ref = 1;
        for (k = 2; k <= val; k = k + 1)
          fact_ref = fact_ref * k;
      end
    end
  endfunction

  initial begin
    $display("%0s\t%-1s\t%-9s %-10s %-5s %-5s",
                "Time", "N", "Product", "Expected", "Done", "Error");

    // Initialize
    RESET = 1; GO = 0; N = 0;
    #50 RESET = 0;

    // Test N = 0 to 13
    for (i = 0; i <= 13; i = i + 1) begin
      // Apply input
      N = i;
      GO = 1;
      #20 GO = 0;

      // Wait until finished state is reached
      wait (done || error);

      // Print to output table
      $display("%0t\t%-1d\t%-9d %-10d %-5b %-5b",
               $time, N, product, fact_ref(N), done, error);

      // Small delay, then reset
      #40 RESET = 1;
      #20 RESET = 0;
    end

    $finish;
  end

endmodule

