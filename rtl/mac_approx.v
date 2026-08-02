// mac_approx.v
//
// Approximate (Mode A precision, approximation features enabled) MAC unit.
// Same 8-bit weight x 8-bit activation x 32-bit accumulator sizing as
// mac_baseline.v, but adds:
//   1. Near-zero WEIGHT skip: if abs(weight) < threshold, skip the MAC.
//   2. Near-zero ACTIVATION skip: if activation == 0, skip the MAC.
//   3. Simplified clock gating: when skipping, the accumulator register
//      simply holds its value (does not toggle), same mechanism as
//      accumulate_enable in the baseline design.
//
// threshold is a runtime-configurable input (an actual register elsewhere
// in the system would drive this in a full design; here it's just an
// input port so the testbench can set/sweep it directly).

module mac_approx (
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire signed [7:0]  weight,
    input  wire signed [7:0]  activation,
    input  wire        [7:0]  threshold,     // unsigned: compared against abs(weight)
    output reg  signed [31:0] accum_out,
    output wire                skipped        // 1 if this cycle's MAC was skipped (for testing/visibility)
);

    // --- Step 1: compute abs(weight) ---
    // If weight's sign bit (the top bit, weight[7]) is 1, it's negative -
    // flip its sign to get the magnitude. Otherwise, use it as-is.
    // This is a combinational (assign) circuit: always up to date, no
    // clock needed, since it's a pure function of the current weight.
    wire [7:0] abs_weight;
    assign abs_weight = weight[7] ? (-weight) : weight;

    // --- Step 2: the two skip conditions ---
    wire weight_is_small;
    wire activation_is_zero;
    assign weight_is_small   = (abs_weight < threshold);
    assign activation_is_zero = (activation == 8'sd0);

    // --- Step 3: combined skip decision ---
    // Skip this cycle's MAC if EITHER condition is true.
    assign skipped = weight_is_small | activation_is_zero;

    // --- Step 4: the multiplier (same as baseline) ---
    // Note: in a true clock-gated design, this multiplier's own internal
    // transistors would stop switching entirely when skipped is true, not
    // just have its result ignored. Our simplified model doesn't force
    // that at the gate level - it's a known simplification, flagged here
    // so we remember it when interpreting Phase 4 energy estimates.
    wire signed [15:0] product;
    assign product = weight * activation;

    // --- Step 5: accumulate, with skip-awareness ---
    always @(posedge clk) begin
        if (reset) begin
            accum_out <= 32'sd0;
        end else if (accumulate_enable && !skipped) begin
            // Only add the product if we're enabled AND not skipping.
            accum_out <= accum_out + product;
        end
        // Otherwise (disabled, OR skipped, OR both): hold current value.
        // This is our simplified clock-gating mechanism - the register
        // simply doesn't update, so it doesn't toggle/consume dynamic
        // switching energy on this cycle.
    end

endmodule
