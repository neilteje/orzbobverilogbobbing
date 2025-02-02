module register_unit_8 (
    input  logic       Clk, 
    input  logic       Reset,
    input  logic       A_In,  // 1-bit shift in for A
    input  logic       B_In,  // 1-bit shift in for B
    input  logic       Ld_A,
    input  logic       Ld_B, 
    input  logic       Shift_En,
    input  logic [7:0] D,     // 8-bit parallel load

    output logic       A_out, 
    output logic       B_out, 
    output logic [7:0] A,
    output logic [7:0] B
);

    reg_8 regA (
        .Clk       (Clk), 
        .Reset     (Reset),

        .Shift_In  (A_In), 
        .Load      (Ld_A), 
        .Shift_En  (Shift_En),
        .D         (D),

        .Shift_Out (A_out),
        .Data_Out  (A)
    );

    reg_8 regB (
        .Clk       (Clk), 
        .Reset     (Reset),

        .Shift_In  (B_In), 
        .Load      (Ld_B), 
        .Shift_En  (Shift_En),
        .D         (D),

        .Shift_Out (B_out),
        .Data_Out  (B)
    );

endmodule
