module control_8 (
    input  logic Clk, 
    input  logic Reset,
    input  logic LoadA,
    input  logic LoadB,
    input  logic Execute,

    output logic Shift_En, 
    output logic Ld_A,
    output logic Ld_B
);

    // Enough bits in the enum to hold 9+ states
    enum logic [3:0] {
        s_start, 
        s_count0, 
        s_count1, 
        s_count2, 
        s_count3, 
        s_count4,
        s_count5,
        s_count6,
        s_count7,
        s_done
    } curr_state, next_state; 

    //--------------------------------------------
    // Combinational logic for outputs
    //--------------------------------------------
    always_comb begin
        // Default assignments (to avoid latches)
        Ld_A     = 1'b0;
        Ld_B     = 1'b0;
        Shift_En = 1'b0;

        unique case (curr_state) 
            s_start: begin
                // Only load if we are in start state
                Ld_A     = LoadA;
                Ld_B     = LoadB;
                Shift_En = 1'b0;
            end

            s_done: begin
                // Everything off
                Ld_A     = 1'b0;
                Ld_B     = 1'b0;
                Shift_En = 1'b0;
            end

            default: begin
                // For s_count0..s_count7: shift enabled
                Ld_A     = 1'b0;
                Ld_B     = 1'b0;
                Shift_En = 1'b1;
            end
        endcase
    end

    //--------------------------------------------
    // Combinational logic for next state
    //--------------------------------------------
    always_comb begin
        next_state = curr_state;  

        unique case (curr_state) 
            s_start: begin
                if (Execute) begin
                    next_state = s_count0;
                end
            end

            s_count0: next_state = s_count1;
            s_count1: next_state = s_count2;
            s_count2: next_state = s_count3;
            s_count3: next_state = s_count4;
            s_count4: next_state = s_count5;
            s_count5: next_state = s_count6;
            s_count6: next_state = s_count7;
            s_count7: next_state = s_done;

            s_done: begin
                // Wait for Execute to go low again, then next cycle can happen
                if (~Execute) begin
                    next_state = s_start;
                end
            end
        endcase
    end

    //--------------------------------------------
    // Synchronous state update
    //--------------------------------------------
    always_ff @(posedge Clk) begin
        if (Reset) begin
            curr_state <= s_start;
        end
        else begin
            curr_state <= next_state;
        end
    end

endmodule
