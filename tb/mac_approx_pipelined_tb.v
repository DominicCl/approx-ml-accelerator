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

        weight = 10;
        activation = 4;
        @(posedge clk);
        #1;

        check_accum(0, "cycle 1: pipeline still filling, accum not yet updated");

        weight = 3;
        activation = 20;
        @(posedge clk);
        #1;

        check_accum(40, "cycle 2: 10*4=40 now reflected (1-cycle delay)");

        weight = 6;
        activation = 6;
        @(posedge clk);
        #1;

        check_accum(40, "cycle 3: skipped cycle produced no change, still 40");

        weight = 0;
        activation = 0;
        @(posedge clk);
        #1;

        check_accum(76, "cycle 4: 6*6=36 added, 40+36=76");

        @(posedge clk);
        #1;
        check_accum(76, "cycle 5: (0,0) input skipped (activation=0), still 76");

        if (errors == 0)
            $display("ALL TESTS PASSED.");
        else
            $display("%0d TEST(S) FAILED.", errors);

        $finish;
    end

    always @(posedge clk) begin
        #2;
        $display("  [monitor] time=%0t  weight_reg=%0d  activation_reg=%0d  skip_decision=%0b",
                  $time, uut.weight_reg, uut.activation_reg, skip_decision);
    end

endmodule
