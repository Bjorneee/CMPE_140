`timescale 1ns / 1ps

module p_controlunit (
        input  wire [5:0]  opcode,
        input  wire [5:0]  funct,
        output wire [1:0] wdrf_src,
        output wire dm2reg,
        output wire we_dm,
        output wire jump,
        output wire branch,
        output wire [2:0] alu_ctrl,
        output wire alu_src,
        output wire reg_dst,
        output wire hilo_sel,
        output wire jr,
        output wire npc2ra,
        output wire mul_en,
        output wire shdir,
        output wire we_reg
    );
    
    wire [1:0] alu_op;

    maindec md (
        .opcode         (opcode),
        .alu_op         (alu_op),
        .dm2reg         (dm2reg),
        .we_dm          (we_dm),
        .jump           (jump),
        .branch         (branch),
        .alu_src        (alu_src),
        .reg_dst        (reg_dst),
        .npc2ra         (npc2ra),
        .we_reg         (we_reg)
    );

    auxdec ad (
        .alu_op         (alu_op),
        .funct          (funct),
        .alu_ctrl       (alu_ctrl),
        .wdrf_src       (wdrf_src),
        .hilo_sel       (hilo_sel),
        .jr             (jr),
        .mul_en         (mul_en),
        .shdir          (shdir)
    );

endmodule
