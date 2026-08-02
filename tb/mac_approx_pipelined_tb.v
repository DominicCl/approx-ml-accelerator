// mac_approx_pipelined_tb.v
// Testbench for mac_approx_pipelined.v.
//
// IMPORTANT DIFFERENCE from previous testbenches: because this design is
// now pipelined, an input presented on cycle N does not affect accum_out
// until cycle N+1. Every check in this testbench accounts for that
// one-cycle delay explicitly.

`timescale 1ns / 1ps

module mac_approx_pipelined_tb;

    reg clk;
    reg reset;
    reg accumulate_enable;
    reg signed [7:0] weight;
    reg signed [7:0] activation;
    reg [7:0] threshold;
    wire signed [31:0] accum_out;
    wire skip_decision;

    integer errors = 0;

    mac_approx_pipelined uut (
        .clk(clk),
        .reset(reset),
        .accumulate_enable(accumulate_enable),
        .weight(weight),
        .activation(activation),
        .threshold(threshold),
        .accum_out(accum_out),
        .skip_decision(skip_decision)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task check_accum(input signed [31:0] expected, input [255:0] label);
        begin
            if (accum_out !== expected) begin
                errors = errors + 1;
                $display("FAIL [%0s]: accum_out=%0d, expected=%0d", label, accum_out, expected);
            end else begin
                $display("PASS [%0s]: accum_out=%0d", label, accum_out);
            end
        end
    endtask

    initial begin
        $display("Starting mac_approx_pipelined test...");

        // --- Setup ---
        reset = 1;
        accumulate_enable = 0;
        weight = 0;
        activation = 0;
        threshold = 8'd5;
        @(posedge clk);
        #1;
        check_accum(0, "after reset");

        reset = 0;
        accumulate_enable = 1;

        // --- Present a normal-operation input: weight=10, activation=4 ---
        // This gets CAPTURED into stage 1 on this clock edge.
        weight = 10;
        activation = 4;
        @(posedge clk);
        #1;
        // Stage 1 just captured (10,4). Stage 2 has NOT multiplied yet -
        // it's working from the previous (reset) stage1_valid=0 state.
        check_accum(0, "cycle 1: pipeline still filling, accum not yet updated");

        // Now present the NEXT input while the first one flows to stage 2.
        weight = 3;           // will be skipped (abs(3) < threshold 5)
        activation = 20;
        @(posedge clk);
        #1;
        // NOW stage 2 processes the (10,4) that was captured last cycle:
        // accum_out becomes 10*4 = 40. Meanwhile stage 1 evaluates (3,20)
        // and since it's skipped, does NOT capture it.
        check_accum(40, "cycle 2: 10*4=40 now reflected (1-cycle delay)");

        // Present a normal input again.
        weight = 6;
        activation = 6;
        @(posedge clk);
        #1;
        // Stage 2 processes whatever stage 1 held over from last cycle.
        // Since (3,20) was skipped, stage1_valid was 0, so accum_out
        // should NOT have changed - still 40.
        check_accum(40, "cycle 3: skipped cycle produced no change, still 40");

        // One more cycle to let (6,6) flow through to stage 2.
        weight = 0;
        activation = 0;
        @(posedge clk);
        #1;
        // Now stage 2 processes (6,6): accum_out = 40 + 36 = 76.
        check_accum(76, "cycle 4: 6*6=36 added, 40+36=76");

        // One more cycle: input is now (0,0), which is skipped (activation
        // is zero) - accum_out should hold steady at 76.
        @(posedge clk);
        #1;
        check_accum(76, "cycle 5: (0,0) input skipped (activation=0), still 76");

        if (errors == 0)
            $display("ALL TESTS PASSED.");
        else
            $display("%0d TEST(S) FAILED.", errors);

        $finish;
    end

    // --- Direct visibility into the gating mechanism itself ---
    // This monitor prints weight_reg/activation_reg every cycle, so we can
    // SEE with our own eyes that they genuinely hold steady (don't change)
    // during skipped cycles, rather than just trusting the final
    // accum_out result to imply it.
    always @(posedge clk) begin
        #2; // small delay so registers have settled after the clock edge
        $display("  [monitor] time=%0t  weight_reg=%0d  activation_reg=%0d  skip_decision=%0b",
                  $time, uut.weight_reg, uut.activation_reg, skip_decision);
    end

endmodule
