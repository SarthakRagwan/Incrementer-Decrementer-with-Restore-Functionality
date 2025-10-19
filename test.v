`timescale 1ps/1ps          // Define simulation time unit and precision
`include "main.v"           // Include the design file containing the 'ic' module

//===========================================================
// Testbench: ic_tb
// Description: Testbench for the Incrementer/Decrementer circuit ('ic')
// This circuit performs +1, -1, +2, -2, or buffer operation 
// depending on control signals: enable, decInc, and oneOrTwo.
//===========================================================

module ic_tb;

    // -------------------------------
    // Parameter Declaration
    // -------------------------------
    parameter N = 7;  // Bit-width of the input/output bus (8-bit total)

    // -------------------------------
    // DUT Input Declarations
    // -------------------------------
    reg [N:0] count;     // Current value (input count)
    reg       decInc;    // Control signal: 0 = increment, 1 = decrement
    reg       oneOrTwo;  // Control signal: 0 = step by 1, 1 = step by 2
    reg       enable;    // Enable signal: 1 = perform operation, 0 = hold/buffer

    // -------------------------------
    // DUT Output Declarations
    // -------------------------------
    wire [N:0] andOutput; // Intermediate AND-chain output (used internally)
    wire [N:0] xorOutput; // Final output (next count after operation)

    // -------------------------------
    // DUT Instantiation
    // -------------------------------
    ic DUT (
        .count      (count),
        .decInc     (decInc),
        .oneOrTwo   (oneOrTwo),
        .enable     (enable),
        .andOutput  (andOutput),
        .xorOutput  (xorOutput)
    );

    // -------------------------------
    // Testbench Stimulus Generation
    // -------------------------------
    integer i;
    initial begin
        // Initialize waveform dump for visualization in GTKWave
        $dumpfile("test.vcd");
        $dumpvars(0, ic_tb);

        // Display signal values dynamically during simulation
        $monitor("Time=%0t | ENA=%b | DEC/INC=%b | 1/2=%b | COUNT=%d | NEXT_COUNT=%d",
                  $time, enable, decInc, oneOrTwo, count, xorOutput);

        // Apply multiple test cases automatically
        // i[2:0] encodes {enable, decInc, oneOrTwo}
        // So, 000 → Disabled buffer
        //     001 → Enable, Increment by 1
        //     010 → Enable, Increment by 2
        //     011 → Enable, Decrement by 1
        //     100 → Enable, Decrement by 2
        // and so on depending on how signals map in binary
        
        for (i = 0; i < 8; i = i + 1) begin
            count = {$random} % 8'd15;         // Random 8-bit count value
            {enable, decInc, oneOrTwo} = i[2:0]; // Assign control bits
            #10;                               // Wait for 10 time units
        end

        // End of simulation
        $finish;
    end

endmodule