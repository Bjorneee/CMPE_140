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


module s_controlunit(
    input GO, N_GT_1, N_GT_12, CLK, RESET,
    output Sel, Load_reg, Load_cnt, EN, OE, ERROR, DONE
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
    
    // Next State Logic
    always @ (*) begin
    
        case (state)
            s0: next_state = (GO ? s1 : s0);        // Idle
            s1: next_state = s2;                    // Load
            s2: next_state = (N_GT_12 ? s4 : s3);   // Compare to 1          
            s3: next_state = (N_GT_1 ? s5 : s6);    // Compare to 12
            s4: next_state = (GO ? s1 : s4);        // Error
            s5: next_state = s3;                    // Multiply & Decrement
            s6: next_state = (GO ? s1 : s6);        // Done
            default: next_state = s0;
        endcase;
            
    end
    
    // Output Logic
    assign Load_reg = state == s1;
    assign Load_cnt = state == s1;
    assign EN = state == s5;
    assign Sel = state == s5;
    assign ERROR = state == s4;
    assign DONE = state == s6;
    assign OE = state == s6;
    
endmodule

