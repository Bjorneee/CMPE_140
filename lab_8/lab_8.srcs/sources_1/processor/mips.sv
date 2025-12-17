`timescale 1ns / 1ps

module mips (
        input  wire        clk,
        input  wire        rst,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        output wire        we_dm,
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire [31:0] rd3
    );
    
    wire       branch;
    wire       jump;
    wire       reg_dst;
    wire       we_reg;
    wire       alu_src;
    wire       dm2reg;
    wire       hilo_sel;
    wire       jr;
    wire       npc2ra;
    wire       mul_en;
    wire       shdir;
    wire [1:0] wdrf_src;
    wire [2:0] alu_ctrl;
    wire [31:0] shift;

    p_datapath dp (
            .clk            (clk),
            .rst            (rst),
            .branch         (branch),
            .jump           (jump),
            .reg_dst        (reg_dst),
            .we_reg         (we_reg),
            .alu_src        (alu_src),
            .dm2reg         (dm2reg),
            .hilo_sel       (hilo_sel),
            .jr             (jr),
            .npc2ra         (npc2ra),
            .mul_en         (mul_en),
            .shdir          (shdir),
            .wdrf_src       (wdrf_src),
            .alu_ctrl       (alu_ctrl),
            .ra3            (ra3),
            .instr          (instr),
            .rd_dm          (rd_dm),
            .pc_current     (pc_current),
            .alu_out        (alu_out),
            .wd_dm          (wd_dm),
            .rd3            (rd3),
            .shift         (shift)
        );

    p_controlunit cu (
            .opcode         (instr[31:26]),
            .funct          (instr[5:0]),
            .wdrf_src       (wdrf_src),
            .dm2reg         (dm2reg),
            .we_dm          (we_dm),
            .jump           (jump),
            .branch         (branch),
            .alu_ctrl       (alu_ctrl),
            .alu_src        (alu_src),
            .reg_dst        (reg_dst),
            .hilo_sel       (hilo_sel),
            .jr             (jr),
            .npc2ra         (npc2ra),
            .mul_en         (mul_en),
            .shdir          (shdir),
            .we_reg         (we_reg)
        );

endmodule
