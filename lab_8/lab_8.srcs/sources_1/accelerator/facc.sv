module fa (
        input  wire        clk,
        input  wire        rst,
        input  wire        we,
        input  wire [3:0]  wd,
        input  wire [1:0]  a,
        output wire [31:0] rd
);

        wire [31:0] product, result, ctrl_out, go_out, n_out;
        wire [1:0]  rd_sel;
        wire we1, we2, pulse, pulse_cmb;
        wire done, error;

        fact_ad fa_ad (
                .a          (a),
                .we         (we),
                .we1        (we1),
                .we2        (we2),
                .rd_sel     (rd_sel)
        );

        fact_wrap_reg #4 n_reg (
                .clk        (clk),
                .rst        (rst),
                .d          (wd),
                .load_reg   (we1),
                .q          (n_out[3:0])
        );

        assign n_out[31:4] = 28'b0;

        fact_wrap_reg #1 go_reg (
                .clk        (clk),
                .rst        (rst),
                .d          (wd[0]),
                .load_reg   (we2),
                .q          (go_out[0])
        );

        assign go_out[31:1] = 31'b0;

        // Go Pulse
        reg temp;
        assign pulse_cmb = we2 & wd[0];
        always @ (posedge clk) begin
            temp <= pulse_cmb;
        end
        assign pulse = temp;

        // Done Register
        reg done_out;
        always @ (posedge clk, posedge rst) begin
            if (rst) done_out <= 1'b0;
            else done_out <= (~pulse_cmb) & (done | done_out);
        end

        // Error Register
        reg error_out;
        always @ (posedge clk, posedge rst) begin
            if (rst) error_out <= 1'b0;
            else error_out <= (~pulse_cmb) & (error | error_out);
        end

        assign ctrl_out = {30'b0, error_out, done_out};

        fact_accel #4 fact_accel (
                .N_INPUT    (wd),
                .GO         (pulse),
                .RESET      (rst),
                .CLK        (clk),
                .PRODUCT    (product),
                .ERROR      (error),
                .DONE       (done)
        );

        fact_wrap_reg res_reg (
                .clk        (clk),
                .rst        (rst),
                .d          (product),
                .load_reg   (done),
                .q          (result)
        );

        // Output Mux
        assign rd = (rd_sel == 2'b00) ? n_out    :
                    (rd_sel == 2'b01) ? go_out   :
                    (rd_sel == 2'b10) ? ctrl_out : result;


endmodule

module fact_ad (
        input  wire [1:0] a,
        input  wire       we,
        output reg        we1,
        output reg        we2,
        output wire [1:0] rd_sel
);

always_comb begin
    case (a)

        2'b00: begin
            we1 = we;
            we2 = 1'b0;
        end

        2'b01: begin
            we1 = 1'b0;
            we2 = we;
        end

        2'b10: begin
            we1 = 1'b0;
            we2 = 1'b0;
        end

        2'b11: begin
            we1 = 1'b0;
            we2 = 1'b0;
        end

        default: begin
            we1 = 1'bx;
            we2 = 1'bx;
        end

    endcase
end     

assign rd_sel = a;

endmodule

module fact_wrap_reg #(localparam w = 32) (
        input  wire         clk, rst,
        input  wire [w-1:0] d,
        input  wire         load_reg,
        output reg  [w-1:0] q
);

always @ (posedge clk, posedge rst) begin

    if (rst) q <= 0;
    else if (load_reg) q <= d;
    else q <= q;

end

endmodule