`timescale 1ns / 1ps

module mac_approx_tb;

    reg clk;
    reg reset;
    reg accumulate_enable;
    reg signed [7:0] weight;
    reg signed [7:0] activation;
    reg [7:0] threshold;
    wire signed [31:0] accum_out;
    wire skipped;

    integer errors = 0;

    mac_approx uut (
        .clk(clk),
        .reset(reset),
        .accumulate_enable(accumulate_enable),
        .weight(weight),
        .activation(activation),
        .threshold(threshold),
        .accum_out(accum_out),
        .skipped(skipped)
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

    task check_skipped(input expected, input [255:0] label);
        begin
            if (skipped !== expected) begin
                errors = errors + 1;
                $display("FAIL [%0s]: skipped=%0b, expected=%0b", label, skipped, expected);
            end else begin
                $display("PASS [%0s]: skipped=%0b", label, skipped);
            end
        end
    endtask

    initial begin
        $display("Starting mac_approx test...");

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
        check_skipped(0, "normal op: not skipped");
        check_accum(40, "normal op: 10*4=40");

        weight = 3;
        activation = 20;
        @(posedge clk);
        #1;
        check_skipped(1, "weight-skip: small positive weight");
        check_accum(40, "weight-skip: accum unchanged (still 40)");

        weight = -2;
        activation = 50;
        @(posedge clk);
        #1;
        check_skipped(1, "weight-skip: small negative weight");
        check_accum(40, "weight-skip (negative): accum unchanged (still 40)");

        weight = 100;
        activation = 0;
        @(posedge clk);
        #1;
        check_skipped(1, "activation-skip: activation is zero");
        check_accum(40, "activation-skip: accum unchanged (still 40)");

        weight = 5;
        activation = 2;
        @(posedge clk);
        #1;
        check_skipped(0, "boundary: weight == threshold, should NOT skip");
        check_accum(50, "boundary: 40 + 5*2=10 -> 50");

        weight = 6;
        activation = 6;
        @(posedge clk);
        #1;
        check_skipped(0, "resumed normal op: not skipped");
        check_accum(86, "resumed normal op: 50 + 6*6=36 -> 86");

        if (errors == 0)
            $display("ALL TESTS PASSED.");
        else
            $display("%0d TEST(S) FAILED.", errors);

        $finish;
    end

endmodule
