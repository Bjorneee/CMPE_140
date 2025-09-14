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
  reg  START, RESET, CLK;
  wire [31:0] product;
  wire error, done;

  // DUT
  fact_accel DUT (
    .N(N),
    .START(START),
    .RESET(RESET),
    .CLK(CLK),
    .product(product),
    .error(error),
    .done(done)
  );

  // Clock generator (20ns period)
  initial CLK = 0;
  always #10 CLK = ~CLK;

  integer i;

  // Reference factorial function for checking
  function [31:0] fact_ref(input integer val);
    integer k;
    begin
      if (val == 0 || val == 1)
        fact_ref = 1;
      else if (val > 12)
        fact_ref = 0; // indicate "error case"
      else begin
        fact_ref = 1;
        for (k = 2; k <= val; k = k + 1)
          fact_ref = fact_ref * k;
      end
    end
  endfunction

  initial begin
    $display("time\tN\tproduct\tdone\terror\tExpected");

    // Initialize
    RESET = 1; START = 0; N = 0;
    #50 RESET = 0;

    // Sweep through N = 0 to 13
    for (i = 0; i <= 13; i = i + 1) begin
      // Apply input
      N = i;
      START = 1;
      #20 START = 0;  // short pulse

      // Wait until either done or error
      wait (done || error);

      // Print results
      $display("%0t\t%0d\t%0d\t%b\t%b\t%0d",
               $time, N, product, done, error, fact_ref(N));

      // Small delay, then reset FSM before next test
      #40 RESET = 1;
      #20 RESET = 0;
    end

    $finish;
  end

endmodule

