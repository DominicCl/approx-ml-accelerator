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
        $display("Starting mac_baseline test...");

        reset = 1;
        accumulate_enable = 0;
        weight = 0;
        activation = 0;
        @(posedge clk);
        #1;
        check_accum(0, "after reset");

        reset = 0;
        accumulate_enable = 1;
        weight = 5;
        activation = 3;
        @(posedge clk);
        #1;
        check_accum(15, "single MAC: 5*3=15");

        weight = 2;
        activation = 4;
        @(posedge clk);
        #1;
        check_accum(23, "accum cycle 2: +8 = 23");

        weight = -3;
        activation = 10;
        @(posedge clk);
        #1;
        check_accum(-7, "accum cycle 3 (negative weight): -30 = -7");

        accumulate_enable = 0;
        weight = 100;
        activation = 100;
        @(posedge clk);
        #1;
        check_accum(-7, "enable=0: value should NOT change");

        @(posedge clk);
        #1;
        check_accum(-7, "enable=0 (second cycle): still unchanged");

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
