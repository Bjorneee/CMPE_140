`timescale 1ns / 1ps

module pmips (
        input  wire        clk,
        input  wire        rst,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,     // IF-stage instruction from imem
        input  wire [31:0] rd_dm,     // MEM-stage read data from SoC mux
        output wire        we_dm,     // MEM-stage store enable to SoC
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,   // MEM-stage address
        output wire [31:0] wd_dm,     // MEM-stage write data
        output wire [31:0] rd3
    );

    // ----------------------------
    // ID-stage control wires (from CU decoding instrD)
    // ----------------------------
    wire        branchD;
    wire        jumpD;
    wire        reg_dstD;
    wire        we_regD;
    wire        alu_srcD;
    wire        dm2regD;
    wire        hilo_selD;
    wire        jrD;
    wire        npc2raD;
    wire        mul_enD;
    wire        shdirD;
    wire [1:0]  wdrf_srcD;
    wire [2:0]  alu_ctrlD;

    // CU also produces mem write enable in ID
    wire        we_dmD;

    // From datapath (exports)
    wire [31:0] instrD_out;   // IF/ID instruction inside datapath
    wire        we_dm_out;    // MEM-stage memwrite (pipelined)
    wire [31:0] shift;        // debug

    // ----------------------------
    // Datapath (pipelined)
    // ----------------------------
    p_pdatapath dp (
            .clk            (clk),
            .rst            (rst),

            // ID-stage controls (must align to instrD_out)
            .branch         (branchD),
            .jump           (jumpD),
            .reg_dst        (reg_dstD),
            .we_reg         (we_regD),
            .alu_src        (alu_srcD),
            .dm2reg         (dm2regD),
            .hilo_sel       (hilo_selD),
            .jr             (jrD),
            .npc2ra         (npc2raD),
            .mul_en         (mul_enD),
            .shdir          (shdirD),
            .wdrf_src       (wdrf_srcD),
            .alu_ctrl       (alu_ctrlD),

            // *** NEW: ID-stage memwrite into datapath so it can be pipelined to MEM ***
            .we_dm          (we_dmD),

            .ra3            (ra3),

            // IF + MEM external connections
            .instr          (instr),
            .rd_dm          (rd_dm),

            // SoC-facing outputs (MEM stage)
            .pc_current     (pc_current),
            .alu_out        (alu_out),
            .wd_dm          (wd_dm),

            // Debug
            .rd3            (rd3),
            .shift          (shift),

            // *** NEW exports ***
            .instrD_out     (instrD_out),
            .we_dm_out      (we_dm_out)
        );

    // ----------------------------
    // Control Unit (decode in ID stage)
    // ----------------------------
    p_controlunit cu (
            .opcode         (instrD_out[31:26]),
            .funct          (instrD_out[5:0]),
            .wdrf_src       (wdrf_srcD),
            .dm2reg         (dm2regD),
            .we_dm          (we_dmD),
            .jump           (jumpD),
            .branch         (branchD),
            .alu_ctrl       (alu_ctrlD),
            .alu_src        (alu_srcD),
            .reg_dst        (reg_dstD),
            .hilo_sel       (hilo_selD),
            .jr             (jrD),
            .npc2ra         (npc2raD),
            .mul_en         (mul_enD),
            .shdir          (shdirD),
            .we_reg         (we_regD)
        );

    // MEM-stage write enable to SoC
    assign we_dm = we_dm_out;

endmodule
