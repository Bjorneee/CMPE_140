`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2025 08:26:10 AM
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    input GO, N_GT_1, N_GT_12, CLK, RESET,
    output sel, load_reg, load_cnt, en_cnt, en_out, fact_error, fact_done
    );
    
    reg[2:0] state, next_state;
    
    localparam  s0 = 3'b000,
                s1 = 3'b001,
                s2 = 3'b010,
                s3 = 3'b011,
                s4 = 3'b100,
                s5 = 3'b101,
                s6 = 3'b110;
                
    always @ (posedge CLK) begin
    
        if (RESET)
            state <= s0;
        else 
            state <= next_state;
    
    end
    
    always @ (*) begin
    
        case (state)
            s0: next_state = (GO ? s1 : s0);
            s1: next_state = s2;
            s2: next_state = (N_GT_12 ? s4 : s3);                
            s3: next_state = (N_GT_1 ? s5 : s6);
            s4: next_state = (GO ? s0 : s4);
            s5: next_state = s3;
            s6: next_state = (GO ? s0 : s6);
            default: next_state = s0;
        endcase;
            
    end
    
    assign load_reg = state === s1;
    assign load_cnt = state === s1;
    assign en_cnt = state === s5;
    assign sel = state === s5;
    assign fact_error = state === s4;
    assign fact_done = state === s6;
    assign en_out = state === s6;
    
endmodule

