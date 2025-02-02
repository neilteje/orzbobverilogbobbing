//4-bit logic processor top level module
//for use with ECE 385 Fall 2023
//last modified by Satvik Yellanki


//Always use input/output logic types when possible, prevents issues with tools that have strict type enforcement

module Processor (
    // 8-bit changes
    input  logic         Clk,     
    input  logic         Reset,   
    input  logic         LoadA,   
    input  logic         LoadB,   
    input  logic         Execute, 
    input  logic [7:0]   Din,       
    input  logic [2:0]   F,       
    input  logic [1:0]   R,       

    output logic [3:0]   LED,     
    output logic [7:0]   Aval,    // now 8 bits
    output logic [7:0]   Bval,    // now 8 bits
    output logic [7:0]   hex_seg, 
    output logic [3:0]   hex_grid
); 

    // Local logic signals.
    logic Reset_SH;
    logic LoadA_SH;
    logic LoadB_SH;
    logic Execute_SH;

    logic [2:0] F_S;
    logic [1:0] R_S;

    // For the register unit
    logic        Ld_A;
    logic        Ld_B;
    logic        newA;   // 1 bit
    logic        newB;   // 1 bit
    logic        opA;    // 1 bit
    logic        opB;    // 1 bit
    logic        Shift_En;

    logic        F_A_B;  // 1 bit from compute
    logic [7:0]  A;      // 8 bits now
    logic [7:0]  B;      // 8 bits now
    logic [7:0]  Din_S;  // 8 bits from sync

    // Simple assignments
    assign Aval = A;
    assign Bval = B;
    assign LED  = {Execute_SH, LoadA_SH, LoadB_SH, Reset_SH};

    // Instantiate the register unit (8 bits).
    register_unit_8 reg_unit (
        .Clk      (Clk),
        .Reset    (Reset_SH),

        .Ld_A     (Ld_A),
        .Ld_B     (Ld_B),
        .Shift_En (Shift_En),
        .D        (Din_S),
        .A_In     (newA),
        .B_In     (newB),
        .A_out    (opA),
        .B_out    (opB),

        .A        (A),
        .B        (B) 
    );

    // 1-bit compute
    compute compute_unit (
        .F     (F_S),
        .A_In  (opA),
        .B_In  (opB),

        .A_Out (/* unused? */),
        .B_Out (/* unused? */),
        .F_A_B (F_A_B)
    );

    // 1-bit router
    router router (
        .R      (R_S),
        .A_In   (opA),
        .B_In   (opB),
        .F_A_B  (F_A_B),

        .A_Out  (newA),
        .B_Out  (newB)
    );

    // 8-cycle control
    control_8 control_unit (
        .Clk        (Clk),
        .Reset      (Reset_SH),
        .LoadA      (LoadA_SH),
        .LoadB      (LoadB_SH),
        .Execute    (Execute_SH),

        .Shift_En   (Shift_En),
        .Ld_A       (Ld_A),
        .Ld_B       (Ld_B)
    );

    // Now we have 16 bits total: {B,A}. 
    // Each nibble is displayed by the HexDriver's 4 slots => 16 bits total
    //    in[0] is the rightmost digit 
    //    in[3] is the leftmost digit
    // So we pass { B[7:4], B[3:0], A[7:4], A[3:0] }
    HexDriver HexA (
        .clk      (Clk),
        .reset    (Reset_SH),
        .in       ({ B[7:4], B[3:0], A[7:4], A[3:0] }),
        .hex_seg  (hex_seg),
        .hex_grid (hex_grid)
    );

    //------------------------------------------
    // Input synchronizers/debouncers
    //------------------------------------------
    sync_debounce button_sync [3:0] (
        .Clk  (Clk),
        .d    ({Reset, LoadA, LoadB, Execute}),
        .q    ({Reset_SH, LoadA_SH, LoadB_SH, Execute_SH})
    );

    // Now 8 bits for Din
    sync_debounce Din_sync [7:0] (
        .Clk  (Clk),
        .d    (Din),
        .q    (Din_S)
    );

    // same for F, R
    sync_debounce F_sync [2:0] (
        .Clk  (Clk),
        .d    (F),
        .q    (F_S)
    );

    sync_debounce R_sync [1:0] (
        .Clk  (Clk),
        .d    (R),
        .q    (R_S)
    );

endmodule
