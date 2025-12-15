`timescale 1ns / 1ps

module maindec (
        input  wire [5:0] opcode,
        output wire [1:0] alu_op,
        output wire dm2reg,
        output wire we_dm,
        output wire jump,
        output wire branch,
        output wire alu_src,
        output wire reg_dst,
        output wire npc2ra,            // JAL
        output wire we_reg
    );

    reg [9:0] ctrl;

    assign {alu_op, dm2reg, we_dm, jump, branch, alu_src, reg_dst, npc2ra, we_reg} = ctrl;

    always @ (opcode) begin
        case (opcode)
            6'b00_0000: ctrl = 10'b10_0_0_0_0_0_1_0_1; // R-type
            6'b00_1000: ctrl = 10'b00_0_0_0_0_1_0_0_1; // ADDI
            6'b00_0100: ctrl = 10'b01_0_0_0_1_0_0_0_0; // BEQ
            6'b00_0010: ctrl = 10'b00_0_0_1_0_0_0_0_0; // J
            6'b00_0011: ctrl = 10'b00_0_0_1_0_0_0_1_1; // JAL
            6'b10_1011: ctrl = 10'b00_0_1_0_0_1_0_0_0; // SW
            6'b10_0011: ctrl = 10'b00_1_0_0_0_1_0_0_1; // LW
            default:    ctrl = 10'bxx_x_x_x_x_x_x_x_x;
        endcase
    end

endmodule
