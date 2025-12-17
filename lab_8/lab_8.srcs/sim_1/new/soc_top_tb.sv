`timescale 1ns/1ps

module tb_soc_top;

  // Clock / reset
  reg clk;
  reg rst;

  // GPIO inputs
  reg [31:0] gpi1;
  reg [31:0] gpi2;

  // DUT outputs
  wire [31:0] gpo1;
  wire [31:0] gpo2;
  wire [31:0] rd_data;

  // Control
  integer cycle;
  integer max_cycles;

  // Tracking / checks
  reg [31:0] gpo1_prev;
  reg [31:0] gpo2_prev;
  reg saw_update;
  reg saw_gpo1;
  reg saw_gpo2;

  // Optional plusargs temp
  integer tmp;

  // Instantiate DUT
  soc_top dut (
    .clk    (clk),
    .rst    (rst),
    .gpi1   (gpi1),
    .gpi2   (gpi2),
    .gpo1   (gpo1),
    .gpo2   (gpo2),
    .rd_data(rd_data)
  );

  // Clock: 100 MHz (10ns period)
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Defaults + plusargs
  initial begin
    max_cycles = 5000;

    // Default: N=5 in low nibble, and bit4=1 (0x10)
    gpi1 = 32'h0000_0015;
    gpi2 = 32'h0000_0000;

    if ($value$plusargs("MAXCYC=%d", tmp))
      max_cycles = tmp;

    // Many simulators accept %h for 32-bit hex
    if ($value$plusargs("GPI1=%h", tmp))
      gpi1 = tmp;

    if ($value$plusargs("GPI2=%h", tmp))
      gpi2 = tmp;
  end

  // Wave dump
  initial begin
    $dumpfile("soc_top_tb.vcd");
    $dumpvars(0, tb_soc_top);
  end

  // Reset sequence
  initial begin
    rst = 1'b1;
    repeat (5) @(posedge clk);
    rst = 1'b0;
  end

  // Monitor (soc_top has these internal signals)
  initial begin
    $display(" time    pc        addr      instr     memwrite   wd        rd_data    gpo1      gpo2");
    $display("---------------------------------------------------------------------------------------");
    forever begin
      @(posedge clk);
      $display("%6t  %08h  %08h  %08h     %0d     %08h  %08h  %08h  %08h",
               $time,
               dut.pc_current,
               dut.addr,
               dut.instr,
               dut.mem_write,
               dut.wd,
               rd_data,
               gpo1,
               gpo2);
    end
  end

  // Main test flow
  initial begin
    // After reset deassert:
    @(negedge rst);

    gpo1_prev  = gpo1;
    gpo2_prev  = gpo2;

    saw_gpo1 = 1'b0;
    saw_gpo2 = 1'b0;

    for (cycle = 0; cycle < max_cycles; cycle = cycle + 1) begin
      @(posedge clk);

      if (gpo1 !== gpo1_prev) saw_gpo1 = 1'b1;
      if (gpo2 !== gpo2_prev) saw_gpo2 = 1'b1;

      if (saw_gpo1 && saw_gpo2) begin
        $display("[TB] Both GPIO outputs updated at t=%0t: gpo1=%08h gpo2=%08h",
                $time, gpo1, gpo2);

        // Optional: give one extra cycle for any final settling
        @(posedge clk);
        $display("[TB] One-cycle-later: gpo1=%08h gpo2=%08h", gpo1, gpo2);

        #20;
        $finish;
      end

      gpo1_prev = gpo1;
      gpo2_prev = gpo2;
    end


    if (!saw_update) begin
      $display("[TB][FAIL] No GPIO update within %0d cycles.", max_cycles);
      $display("Likely causes:");
      $display("  - soc_top decoder not using 0x08xx (FA) / 0x09xx (GPIO)");
      $display("  - gpio.sv outputs still not driven from wd on writes");
      $display("  - FA never asserts done/error so poll loop never exits");
      $finish;
    end
  end

endmodule
