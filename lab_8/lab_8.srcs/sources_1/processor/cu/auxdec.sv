`timescale 1ns / 1ps

module auxdec (
        input  wire [1:0] alu_op,
        input  wire [5:0] funct,
        output wire [2:0] alu_ctrl,
        output wire [1:0] wdrf_src,
        output wire hilo_sel,
        output wire jr,
        output wire mul_en,
        output wire shdir
    );

    reg [8:0] ctrl;

    assign {alu_ctrl, wdrf_src, hilo_sel, jr, mul_en, shdir} = ctrl;

    always @ (alu_op, funct) begin
        case (alu_op)
            2'b00: ctrl = 9'b010_00_0_0_0_0;          // ADD
            2'b01: ctrl = 9'b110_00_0_0_0_0;          // SUB
            default: case (funct)
                // ALU
                6'b10_0100: ctrl = 9'b000_00_0_0_0_0; // AND
                6'b10_0101: ctrl = 9'b001_00_0_0_0_0; // OR
                6'b10_0000: ctrl = 9'b010_00_0_0_0_0; // ADD
                6'b10_0010: ctrl = 9'b110_00_0_0_0_0; // SUB
                6'b10_1010: ctrl = 9'b111_00_0_0_0_0; // SLT
                // Shift
                6'b00_0000: ctrl = 9'b000_01_0_0_0_0; // SLL
                6'b00_0010: ctrl = 9'b000_01_0_0_0_1; // SRL
                // Mult
                6'b01_0000: ctrl = 9'b000_10_0_0_0_0; // MFHI
                6'b01_0010: ctrl = 9'b000_10_1_0_0_0; // MFLO
                6'b01_1000: ctrl = 9'b000_10_0_0_1_0; // MULT
                6'b01_1001: ctrl = 9'b000_10_0_0_1_0; // MULTU
                // Branch/Jump
                6'b00_1000: ctrl = 9'b000_00_0_1_0_0; // JR
                default:    ctrl = 9'bxxx_xx_x_x_x_x;
            endcase
        endcase
    end

endmodule
