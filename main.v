//======================================================================
// Project      : Configurable Increment/Decrement Unit (±1 / ±2)
// File Name    : ic.v
// Author       : [Your Name]
// Description  : Parametric Verilog design that performs increment or
//                decrement operations by 1 or 2, or acts as a buffer,
//                based on three control signals.
//
// Control Signals:
//   - enable    : Global enable for the entire circuit
//   - decInc    : Direction selector (0 = Increment, 1 = Decrement)
//   - oneOrTwo  : Step selector (0 = ±1, 1 = ±2)
//
// Functional Summary:
//   When enabled, this module performs one of the following:
//     • +1 increment
//     • +2 increment
//     • −1 decrement
//     • −2 decrement
//     • Pass-through / buffer
//
// Output Summary:
//   - xorOutput : Final result (processed output vector)
//   - andOutput : Carry/borrow propagation chain used internally
//======================================================================


//---------------------------------------------------------------------
// Module: processingUnit
// Description:
//   - Handles bitwise logic propagation (carry/borrow chain).
//   - Performs XOR and AND logic for each bit stage.
//---------------------------------------------------------------------
module processingUnit(
  andInput,
  decIncInput,
  xorInput,
  andOutput,
  xorOutput
);
  input  andInput;
  input  decIncInput, xorInput;
  output andOutput, xorOutput;

  // XOR produces the next stage output bit
  assign xorOutput = andInput ^ xorInput;

  // Temporary XOR used for carry/borrow propagation
  wire tempXorOutput;
  assign tempXorOutput = decIncInput ^ xorInput;

  // AND generates next stage carry/borrow signal
  assign andOutput = andInput & tempXorOutput;

endmodule


//---------------------------------------------------------------------
// Module: initialModule
// Description:
//   - Initializes the first stage (LSB) logic.
//   - Combines enable, direction, and step size to produce
//     the initial carry/borrow and output bit.
//
//   • When oneOrTwo = 0 → ±1 operation
//   • When oneOrTwo = 1 → ±2 operation
//
// Ports:
//   enable, oneOrTwo, decIncInput, xorInput → Control + LSB input
//   xorOutput → LSB result
//   andOutput → Carry/borrow to next stage
//---------------------------------------------------------------------
module initialModule(
  enable,
  oneOrTwo,
  decIncInput,
  xorInput,
  xorOutput,
  andOutput
);
  input  enable, oneOrTwo, decIncInput, xorInput;
  output xorOutput, andOutput;

  // Internal intermediate wires
  wire tempXorOutput, orOutput, tempAndOutput;

  // Generate temporary AND path — active only when enabled and oneOrTwo = 0
  assign tempAndOutput = enable & ~oneOrTwo;

  // XOR for initial direction control
  assign tempXorOutput = decIncInput ^ xorInput;

  // OR combines control (±2 mode) and direction logic
  assign orOutput = tempXorOutput | oneOrTwo;

  // Initial carry/borrow output
  assign andOutput = enable & orOutput;

  // First output bit (processed LSB)
  assign xorOutput = xorInput ^ tempAndOutput;

endmodule


//---------------------------------------------------------------------
// Module: ic (Increment/Decrement Controller)
// Description:
//   - Top-level parametric module implementing a configurable
//     increment/decrement/buffer circuit for (N+1) bits.
//
//   - The module can perform ±1 or ±2 operations based on control
//     inputs. It connects one `initialModule` (for LSB) and N
//     `processingUnit` stages (for higher bits).
//
// Parameters:
//   N : Bit-width (default = 7 → 8-bit operation)
//
// Ports:
//   count[N:0]  : Input vector
//   decInc      : 0 = increment, 1 = decrement
//   oneOrTwo    : 0 = ±1 operation, 1 = ±2 operation
//   enable      : Global enable control
//   andOutput   : Carry/borrow chain
//   xorOutput   : Processed output vector (final result)
//---------------------------------------------------------------------
module ic(
  count,
  decInc,
  oneOrTwo,
  enable,
  andOutput,
  xorOutput
);
  parameter N = 7;
  input [N:0] count;
  input decInc, oneOrTwo, enable;
  output [N:0] andOutput, xorOutput;

  // Instantiate first (LSB) stage
  initialModule m0 (
    enable,
    oneOrTwo,
    decInc,
    count[0],
    xorOutput[0],
    andOutput[0]
  );

  // Generate remaining stages for bits [1..N]
  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin : ic_stage
      processingUnit pu (
        andOutput[i],
        decInc,
        count[i+1],
        andOutput[i+1],
        xorOutput[i+1]
      );
    end
  endgenerate

endmodule