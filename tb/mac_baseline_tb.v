// mac_baseline_tb.v
//
// Testbench for mac_baseline.v. Tests four distinct behaviors:
//   1. Basic correctness of one multiply-accumulate
//   2. Accumulation across multiple cycles
//   3. Reset behavior
//   4. accumulate_enable gating (holding steady when disabled)

`timescale 1ns / 1ps

module mac_baseline_tb;

    reg clk;
    reg reset;
    reg accumulate_enable;
    reg signed [7:0] weight;
    reg signed [7:0] activation;
    wire signed [31:0] accum_out;

    integer errors = 0;

    mac_baseline uut (
        .clk(clk),
        .reset(reset),
        .accumulate_enable(accumulate_enable),
        .weight(weight),
        .activation(activation),
        .accum_out(accum_out)
    );

    // Generate a clock: 10ns period (5ns high, 5ns low).
    initial clk = 0;
    always #5 clk = ~clk;

    // Helper task: check accum_out against an expected value, log result.
    // A "task" in Verilog is similar to a function in software - a named,
    // reusable block of steps we can call multiple times instead of
    // repeating the same check-and-print logic over and over.
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
        $display("Starting mac_baseline test...");

        // --- Test 1: reset behavior ---
        reset = 1;
        accumulate_enable = 0;
        weight = 0;
        activation = 0;
        @(posedge clk); // wait for one rising clock edge
        #1;             // tiny extra delay so accum_out has settled
        check_accum(0, "after reset");

        // --- Test 2: basic single MAC correctness ---
        reset = 0;
        accumulate_enable = 1;
        weight = 5;
        activation = 3;
        @(posedge clk);
        #1;
        check_accum(15, "single MAC: 5*3=15"); // 5*3 = 15

        // --- Test 3: accumulation across multiple cycles ---
        weight = 2;
        activation = 4;
        @(posedge clk); // adds 2*4=8 to existing 15 -> 23
        #1;
        check_accum(23, "accum cycle 2: +8 = 23");

        weight = -3;      // test a negative (signed) weight
        activation = 10;
        @(posedge clk);   // adds -3*10=-30 to existing 23 -> -7
        #1;
        check_accum(-7, "accum cycle 3 (negative weight): -30 = -7");

        // --- Test 4: accumulate_enable gating ---
        accumulate_enable = 0;
        weight = 100;     // large values, to make sure they are IGNORED
        activation = 100;
        @(posedge clk);
        #1;
        check_accum(-7, "enable=0: value should NOT change");

        @(posedge clk); // check again on a second disabled cycle too
        #1;
        check_accum(-7, "enable=0 (second cycle): still unchanged");

        // --- Test 5: reset clears a non-zero accumulator ---
        reset = 1;
        @(posedge clk);
        #1;
        check_accum(0, "reset clears non-zero accumulator");

        if (errors == 0)
            $display("ALL TESTS PASSED.");
        else
            $display("%0d TEST(S) FAILED.", errors);

        $finish;
    end

endmodule
