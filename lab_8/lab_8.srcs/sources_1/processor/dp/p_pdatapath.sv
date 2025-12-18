`timescale 1ns / 1ps

module p_pdatapath (
        input  wire        clk,
        input  wire        rst,

        // ID-stage controls (generated from instrD_out each cycle)
        input  wire        branch,
        input  wire        jump,
        input  wire        reg_dst,
        input  wire        we_reg,
        input  wire        alu_src,
        input  wire        dm2reg,
        input  wire        we_dm,
        input  wire        hilo_sel,
        input  wire        jr,
        input  wire        npc2ra,
        input  wire        mul_en,
        input  wire        shdir,
        input  wire [1:0]  wdrf_src,
        input  wire [2:0]  alu_ctrl,

        input  wire [4:0]  ra3,

        // IF-stage fetched instruction (from imem at pc_current)
        input  wire [31:0] instr,

        // MEM-stage read data (from SoC mux based on alu_out address)
        input  wire [31:0] rd_dm,

        // Outputs to SoC (MEM stage)
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire        we_dm_out,

        // Export ID-stage instruction for CU
        output wire [31:0] instrD_out,

        // Debug/aux
        output wire [31:0] rd3,
        output wire [31:0] shift
    );

    // ============================================================
    // IF STAGE
    // ============================================================
    reg  [31:0] pcF;
    wire [31:0] pc_plus4F;

    // hazard controls
    wire stallF, stallD;
    wire flushD, flushE;

    // control-flow from later stages
    wire        pc_srcE;
    wire [31:0] pc_branchE;
    wire        jumpD;
    wire [31:0] pc_jumpD;
    wire        jr_takeE;
    wire [31:0] pc_jrE;

    // Next PC priority: JR (EX) > taken branch (EX) > jump (ID) > pc+4
    wire [31:0] pc_next =
        jr_takeE ? pc_jrE     :
        pc_srcE  ? pc_branchE :
        jumpD    ? pc_jumpD   :
                   pc_plus4F  ;

    always @(posedge clk) begin
        if (rst) pcF <= 32'b0;
        else if (!stallF) pcF <= pc_next;
    end

    assign pc_current = pcF;

    adder pc_plus_4_F (
        .a (pcF),
        .b (32'd4),
        .y (pc_plus4F)
    );

    // ============================================================
    // IF/ID PIPELINE REG
    // ============================================================
    reg  [31:0] instrD;
    reg  [31:0] pc_plus4D;

    always @(posedge clk) begin
        if (rst) begin
            instrD    <= 32'b0;
            pc_plus4D <= 32'b0;
        end else if (flushD) begin
            instrD    <= 32'b0;   // bubble/NOP
            pc_plus4D <= 32'b0;
        end else if (!stallD) begin
            instrD    <= instr;
            pc_plus4D <= pc_plus4F;
        end
    end

    assign instrD_out = instrD;

    // ============================================================
    // ID STAGE
    // ============================================================
    wire [4:0] rsD = instrD[25:21];
    wire [4:0] rtD = instrD[20:16];
    wire [4:0] rdD = instrD[15:11];

    // Jump target (ID)
    assign jumpD    = jump;
    assign pc_jumpD = {pc_plus4D[31:28], instrD[25:0], 2'b00};

    // Regfile writeback signals (WB stage)
    reg        we_regW;
    reg [4:0]  waW;
    reg [31:0] wdW;

    wire [31:0] rd1D, rd2D;
    regfile rf (
        .clk (clk),
        .we  (we_regW),
        .ra1 (rsD),
        .ra2 (rtD),
        .ra3 (ra3),
        .wa  (waW),
        .wd  (wdW),
        .rd1 (rd1D),
        .rd2 (rd2D),
        .rd3 (rd3),
        .rst (rst)
    );

    // Sign-extend immediate in ID
    wire [31:0] sext_immD;
    signext se (
        .a (instrD[15:0]),
        .y (sext_immD)
    );

    // ============================================================
    // ID/EX PIPELINE REG (data + control)
    // ============================================================
    // Data
    reg [31:0] rd1E, rd2E, immE, pc_plus4E;
    reg [4:0]  rsE, rtE, rdE, shamtE;

    // EX controls
    reg        branchE, reg_dstE, alu_srcE, jrE, npc2raE, mul_enE, shdirE;
    reg [2:0]  alu_ctrlE;
    reg [1:0]  wdrf_srcE;

    // Controls flowing to MEM/WB
    reg        we_regE, dm2regE, hilo_selE;
    reg        we_dmE;

    always @(posedge clk) begin
        if (rst) begin
            rd1E <= 0; rd2E <= 0; immE <= 0; pc_plus4E <= 0;
            rsE  <= 0; rtE  <= 0; rdE  <= 0; shamtE   <= 0;

            branchE   <= 0; reg_dstE <= 0; alu_srcE <= 0;
            jrE       <= 0; npc2raE  <= 0; mul_enE  <= 0; shdirE <= 0;
            alu_ctrlE <= 0; wdrf_srcE<= 0;

            we_regE   <= 0; dm2regE  <= 0; hilo_selE<= 0;
            we_dmE    <= 0;
        end else if (flushE) begin
            // bubble: zero controls
            rd1E <= 0; rd2E <= 0; immE <= 0; pc_plus4E <= 0;
            rsE  <= 0; rtE  <= 0; rdE  <= 0; shamtE   <= 0;

            branchE   <= 0; reg_dstE <= 0; alu_srcE <= 0;
            jrE       <= 0; npc2raE  <= 0; mul_enE  <= 0; shdirE <= 0;
            alu_ctrlE <= 0; wdrf_srcE<= 0;

            we_regE   <= 0; dm2regE  <= 0; hilo_selE<= 0;
            we_dmE    <= 0;
        end else begin
            rd1E <= rd1D;
            rd2E <= rd2D;
            immE <= sext_immD;
            pc_plus4E <= pc_plus4D;

            rsE  <= rsD;
            rtE  <= rtD;
            rdE  <= rdD;
            shamtE <= instrD[10:6];

            branchE   <= branch;
            reg_dstE  <= reg_dst;
            alu_srcE  <= alu_src;
            jrE       <= jr;
            npc2raE   <= npc2ra;
            mul_enE   <= mul_en;
            shdirE    <= shdir;
            alu_ctrlE <= alu_ctrl;
            wdrf_srcE <= wdrf_src;

            we_regE   <= we_reg;
            dm2regE   <= dm2reg;
            hilo_selE <= hilo_sel;

            we_dmE    <= we_dm;
        end
    end

    // ============================================================
    // Forwarding Unit (EX operands)
    // ============================================================
    reg        we_regM;
    reg [4:0]  waM;
    reg [31:0] alu_outM;

    // WB stage components for forwarding
    reg        dm2regW, npc2raW;
    reg [1:0]  wdrf_srcW;
    reg [31:0] alu_outW, rd_dmW, shiftW, m_prodW, pc_plus4W;

    wire [31:0] srcW = dm2regW ? rd_dmW : alu_outW;

    wire [31:0] wd_rfW;
    mux4 #(32) wd_src_mux_W (
        .sel (wdrf_srcW),
        .a   (srcW),
        .b   (shiftW),
        .c   (m_prodW),
        .d   (32'bx),
        .y   (wd_rfW)
    );

    mux2 #(32) ra_wd_mux_W (
        .sel (npc2raW),
        .a   (wd_rfW),
        .b   (pc_plus4W),
        .y   (wdW)
    );

    // Forward select: 00=no fwd, 10=from MEM, 01=from WB
    wire [1:0] forwardAE =
        (we_regM && (waM != 5'd0) && (waM == rsE)) ? 2'b10 :
        (we_regW && (waW != 5'd0) && (waW == rsE)) ? 2'b01 :
                                                      2'b00 ;

    wire [1:0] forwardBE =
        (we_regM && (waM != 5'd0) && (waM == rtE)) ? 2'b10 :
        (we_regW && (waW != 5'd0) && (waW == rtE)) ? 2'b01 :
                                                      2'b00 ;

    wire [31:0] fwdA_E =
        (forwardAE == 2'b10) ? alu_outM :
        (forwardAE == 2'b01) ? wdW      :
                               rd1E     ;

    wire [31:0] fwdB_E =
        (forwardBE == 2'b10) ? alu_outM :
        (forwardBE == 2'b01) ? wdW      :
                               rd2E     ;

    // ============================================================
    // EX STAGE (ALU + branch + jr + shift + mult)
    // ============================================================
    wire [31:0] alu_b_E;
    mux2 #(32) alu_pb_mux_E (
        .sel (alu_srcE),
        .a   (fwdB_E),
        .b   (immE),
        .y   (alu_b_E)
    );

    wire        zeroE;
    wire [31:0] alu_outE;

    alu alu_u (
        .op   (alu_ctrlE),
        .a    (fwdA_E),
        .b    (alu_b_E),
        .zero (zeroE),
        .y    (alu_outE)
    );

    // Branch target = pc_plus4E + (immE << 2)
    wire [31:0] imm_shift2E = {immE[29:0], 2'b00};
    adder pc_plus_br_E (
        .a (pc_plus4E),
        .b (imm_shift2E),
        .y (pc_branchE)
    );

    assign pc_srcE  = branchE & zeroE;

    // JR resolved in EX (use forwarded rs value)
    assign jr_takeE = jrE;
    assign pc_jrE   = fwdA_E;

    // Shift computed in EX (use forwarded rt value)
    wire [31:0] shiftE;
    shifter sh (
        .d     (fwdB_E),
        .shamt (shamtE),
        .dir   (shdirE),
        .q     (shiftE)
    );

    // Multiplier uses forwarded operands
    wire [31:0] m_prodE;
    hilo_mult mult (
        .a   (fwdA_E),
        .b   (fwdB_E),
        .en  (mul_enE),
        .sel (hilo_selE),
        .clk (clk),
        .rst (rst),
        .y   (m_prodE)
    );

    // Destination register select in EX (+ JAL -> $31)
    wire [4:0] rf_waE;
    mux2 #(5) rf_wa_mux_E (
        .sel (reg_dstE),
        .a   (rtE),
        .b   (rdE),
        .y   (rf_waE)
    );

    wire [4:0] waE;
    mux2 #(5) ra_wa_mux_E (
        .sel (npc2raE),
        .a   (rf_waE),
        .b   (5'd31),
        .y   (waE)
    );

    // ============================================================
    // EX/MEM PIPELINE REG
    // ============================================================
    reg        dm2regM, npc2raM;
    reg [1:0]  wdrf_srcM;
    reg [31:0] writedataM, shiftM, m_prodM, pc_plus4M;
    reg        we_dmM;          // <-- MEM-stage store enable

    always @(posedge clk) begin
        if (rst) begin
            we_regM    <= 0;
            dm2regM    <= 0;
            npc2raM    <= 0;
            wdrf_srcM  <= 0;
            we_dmM     <= 0;

            alu_outM   <= 0;
            writedataM <= 0;
            shiftM     <= 0;
            m_prodM    <= 0;
            pc_plus4M  <= 0;
            waM        <= 0;
        end else begin
            we_regM    <= we_regE;
            dm2regM    <= dm2regE;
            npc2raM    <= npc2raE;
            wdrf_srcM  <= wdrf_srcE;
            we_dmM     <= we_dmE;

            alu_outM   <= alu_outE;
            writedataM <= fwdB_E;
            shiftM     <= shiftE;
            m_prodM    <= m_prodE;
            pc_plus4M  <= pc_plus4E;

            waM        <= waE;
        end
    end

    // MEM-stage store enable exported
    assign we_dm_out = we_dmM;

    // ============================================================
    // MEM STAGE (store-data forwarding) + SoC outputs
    // ============================================================
    // Store-data forwarding from WB (for sw value dependencies)
    wire [31:0] writedataM_fwd =
        (we_regW && (waW != 5'd0) && (waW == waM) && 1'b0) ? wdW : // disabled (wrong compare)
        writedataM;

    // Correct store-data forwarding compare is against the store's rt register.
    // We carry rtE only in ID/EX; by MEM stage it's already lost unless you pipeline it.
    // Minimal approach: pipeline the store's rt through EX/MEM:
    // For now, implement robust store forwarding by also pipelining rt into EX/MEM.
    // (Done below via rtM and compare to waW.)

    reg [4:0] rtM;
    always @(posedge clk) begin
        if (rst) rtM <= 5'b0;
        else     rtM <= rtE;
    end

    wire [31:0] writedataM_fwd2 =
        (we_regW && (waW != 5'd0) && (waW == rtM)) ? wdW : writedataM;

    assign alu_out = alu_outM;
    assign wd_dm   = writedataM_fwd2;

    // ============================================================
    // MEM/WB PIPELINE REG
    // ============================================================
    always @(posedge clk) begin
        if (rst) begin
            we_regW   <= 0;
            dm2regW   <= 0;
            npc2raW   <= 0;
            wdrf_srcW <= 0;

            alu_outW  <= 0;
            rd_dmW    <= 0;
            shiftW    <= 0;
            m_prodW   <= 0;
            pc_plus4W <= 0;

            waW       <= 0;
        end else begin
            we_regW   <= we_regM;
            dm2regW   <= dm2regM;
            npc2raW   <= npc2raM;
            wdrf_srcW <= wdrf_srcM;

            alu_outW  <= alu_outM;
            rd_dmW    <= rd_dm;
            shiftW    <= shiftM;
            m_prodW   <= m_prodM;
            pc_plus4W <= pc_plus4M;

            waW       <= waM;
        end
    end

    // Debug: show WB-stage shift result
    assign shift = shiftW;

    // ============================================================
    // Hazard Unit (stall + flush)
    // ============================================================
    // Load-use hazard: if EX is a load (dm2regE) and ID uses that reg -> stall 1 cycle.
    wire lw_stall =
        dm2regE &&
        (rtE != 5'd0) &&
        ((rtE == rsD) || (rtE == rtD));

    assign stallF = lw_stall;
    assign stallD = lw_stall;

    // Flush IF/ID on taken control flow (jump in ID, branch/jr in EX)
    assign flushD = pc_srcE | jr_takeE | jumpD;

    // Flush ID/EX on load-use bubble and on taken branch/jr (kill younger op)
    assign flushE = lw_stall | pc_srcE | jr_takeE;

endmodule
