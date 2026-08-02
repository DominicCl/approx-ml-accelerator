// mac_approx_pipelined.v
//
// Pipelined version of the approximate MAC unit. Unlike mac_approx.v
// (which computes the product every cycle regardless of skip status,
// then just discards it), this version gates the MULTIPLIER'S INPUTS
// themselves - when skipping, the input registers feeding the multiplier
// simply do not update, so no new switching activity reaches the
// multiplier at all. This is a true (if still simplified relative to a
// full commercial design) clock-gating structure, not just a discarded
// result.
//
// Structural change from mac_approx.v: this is now a TWO-STAGE PIPELINE.
//   Stage 1 (input capture): weight/activation -> weight_reg/activation_reg
//       (only updates when NOT skipping this cycle)
//   Stage 2 (multiply + accumulate): weight_reg/activation_reg -> product -> accum_out
//
// Consequence: there is now a ONE CYCLE LATENCY between when an input is
// presented and when it affects accum_out - a direct, expected result of
// pipelining, not a bug.

module mac_approx_pipelined (
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire signed [7:0]  weight,
    input  wire signed [7:0]  activation,
    input  wire        [7:0]  threshold,
    output reg  signed [31:0] accum_out,
    output wire                skip_decision   // visibility: was THIS cycle's input skipped
                                                 // (i.e. NOT captured into the pipeline registers)
);

    // --- Skip decision logic (combinational, same as before) ---
    // This must be computed on the RAW incoming weight/activation, BEFORE
    // they reach the pipeline registers - we're deciding whether to let
    // them into the pipeline at all.
    wire [7:0] abs_weight;
    assign abs_weight = weight[7] ? (-weight) : weight;

    wire weight_is_small;
    wire activation_is_zero;
    assign weight_is_small    = (abs_weight < threshold);
    assign activation_is_zero = (activation == 8'sd0);
    assign skip_decision      = weight_is_small | activation_is_zero;

    // --- Stage 1: input capture registers ---
    // These are the actual gated registers. When skip_decision is true,
    // they simply do not update - they hold their previous values, so no
    // new signal transitions reach the multiplier this cycle.
    reg signed [7:0] weight_reg;
    reg signed [7:0] activation_reg;
    reg              stage1_valid; // tracks whether stage 1 currently holds
                                     // a genuine (non-skipped) captured value

    always @(posedge clk) begin
        if (reset) begin
            weight_reg     <= 8'sd0;
            activation_reg <= 8'sd0;
            stage1_valid   <= 1'b0;
        end else if (accumulate_enable && !skip_decision) begin
            weight_reg     <= weight;
            activation_reg <= activation;
            stage1_valid   <= 1'b1;
        end else begin
            // Skipped (or disabled): hold current register values,
            // and mark stage 1 as not holding a valid new value this cycle.
            stage1_valid <= 1'b0;
        end
    end

    // --- Stage 2: multiply (now reads REGISTERED values, not raw inputs) ---
    // Because weight_reg/activation_reg only change on non-skipped cycles,
    // this multiplier's inputs are genuinely stable (no switching) during
    // skipped cycles - it is not doing new work to then discard.
    wire signed [15:0] product;
    assign product = weight_reg * activation_reg;

    // --- Stage 2: accumulate ---
    // Uses stage1_valid (a registered, one-cycle-delayed signal) rather
    // than the raw skip_decision, since we are now one cycle behind the
    // original input.
    always @(posedge clk) begin
        if (reset) begin
            accum_out <= 32'sd0;
        end else if (stage1_valid) begin
            accum_out <= accum_out + product;
        end
        // else: hold accum_out steady, same pattern as before.
    end

endmodule
