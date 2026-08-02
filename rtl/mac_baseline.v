// mac_baseline.v
//
// Baseline (Mode A) multiply-accumulate unit: full precision, no
// approximation tricks. This is our reference/control design - everything
// we compare the approximate version against in later phases.
//
// Behavior: every clock cycle where accumulate_enable is high, this unit
// computes (weight * activation) and adds it into a running total stored
// in accum_out. Reset clears that running total back to zero.

module mac_baseline (
    input  wire              clk,
    input  wire              reset,
    input  wire              accumulate_enable,
    input  wire signed [7:0] weight,       // 8-bit signed weight
    input  wire signed [7:0] activation,   // 8-bit signed activation
    output reg  signed [31:0] accum_out    // 32-bit signed running total
);

    // "wire signed [7:0]" - same [3:0]-style bit-width syntax we've seen,
    // now paired with "signed" so Verilog interprets these bits as a
    // signed (positive or negative) number using two's complement, the
    // standard binary representation for negative numbers.

    // Intermediate wire holding the multiplication result.
    // 8 bits x 8 bits can produce up to 16 bits of result (not 8+8=16
    // by coincidence - multiplying two n-bit numbers can need up to 2n
    // bits to represent the result without overflow. Example in decimal:
    // a 3-digit number x a 3-digit number can need up to 6 digits,
    // e.g. 999 x 999 = 998001).
    wire signed [15:0] product;
    assign product = weight * activation;

    always @(posedge clk) begin
        if (reset) begin
            accum_out <= 32'sd0; // 32-bit signed zero
        end else if (accumulate_enable) begin
            // Add this cycle's product into the running total.
            // product is 16 bits; accum_out is 32 bits. Verilog
            // automatically sign-extends the smaller value to match the
            // larger width before adding - this is safe and expected.
            accum_out <= accum_out + product;
        end
        // If accumulate_enable is low and we're not resetting, accum_out
        // simply holds its current value - same "hold between clock
        // edges" behavior we saw in the counter example.
    end

endmodule
