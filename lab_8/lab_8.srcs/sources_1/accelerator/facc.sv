module fa (
        input  wire        clk,
        input  wire        rst,
        input  wire        we,
        input  wire [3:0]  wd,
        output wire [31:0] rd
);

        wire ngt1, ngt12, error, done;
        wire sel, load_count, load_reg, oe, en;

        s_controlunit fa_cu (
                .GO         (we),
                .N_GT_1     (ngt1),
                .CLK        (clk),
                .RESET      (rst),
                .Sel        (sel),
                .Load_reg   (load_reg),
                .Load_cnt   (load_cnt),
                .EN         (en),
                .OE         (oe),
                .ERROR      (error),
                .DONE       (done)
        );

        s_datapath fa_dp    (
                .N_INPUT    (wd),
                .Sel        (sel),
                .Load_reg   (load_reg),
                .Load_cnt   (load_cnt),
                .EN         (en),
                .OE         (oe),
                .CLK        (clk),
                .N_GT_1     (ngt1),
                .N_GT_12    (ngt12),
                .PRODUCT    (rd)
        );

endmodule