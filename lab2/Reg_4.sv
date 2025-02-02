module reg_8 (
    input  logic        Clk, 
    input  logic        Reset, 
    input  logic        Shift_In, 
    input  logic        Load, 
    input  logic        Shift_En,
    input  logic [7:0]  D,   // 8-bit parallel load

    output logic        Shift_Out,
    output logic [7:0]  Data_Out
);

    logic [7:0] Data_Out_d;

    always_comb begin
        if (Load) begin
            // Parallel load
            Data_Out_d = D;
        end
        else if (Shift_En) begin
            // Shift left, shifting in Shift_In at the MSB side
            Data_Out_d = { Shift_In, Data_Out[7:1] };
        end
        else begin
            Data_Out_d = Data_Out; 
        end
    end

    always_ff @(posedge Clk) begin
        if (Reset) begin
            Data_Out <= 8'h00;
        end
        else begin
            Data_Out <= Data_Out_d;
        end
    end

    assign Shift_Out = Data_Out[0]; // shift out the LSB

endmodule
