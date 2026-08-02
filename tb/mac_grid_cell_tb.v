`timescale 1ns / 1ps

module mac_grid_cell_tb;

    reg clk;
    reg reset;
    reg accumulate_enable;
    reg signed [7:0] weight;
    reg signed [7:0] activation_in;
    reg [7:0] threshold;
    reg signed [31:0] partial_sum_in;
    wire skip_decision;
    wire signed [7:0] activation_out;
    wire signed [31:0] partial_sum_out;

    integer errors = 0;

    mac_grid_cell uut (
        .clk(clk), .reset(reset), .accumulate_enable(accumulate_enable),
        .weight(weight), .activation_in(activation_in), .threshold(threshold),
        .partial_sum_in(partial_sum_in),
        .skip_decision(skip_decision),
        .activation_out(activation_out),
        .partial_sum_out(partial_sum_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task check(input signed [31:0] actual, input signed [31:0] expected, input [255:0] label);
        begin
            if (actual !== expected) begin
                errors = errors + 1;
                $display("FAIL [%0s]: got=%0d, expected=%0d", label, actual, expected);
            end else begin
                $display("PASS [%0s]: got=%0d", label, actual);
            end
        end
    endtask

    initial begin
        $display("Testing single grid cell: weight=1, matching reference model cell1 (t0=5, t1=6, t2=7, t3=8)");

        reset = 1;
        accumulate_enable = 0;
        weight = 1;
        threshold = 8'd0;
        activation_in = 0;
        partial_sum_in = 0;
        @(posedge clk); #1;

        reset = 0;
        accumulate_enable = 1;

        activation_in = 5; partial_sum_in = 0;
        @(posedge clk); #1;
        check(partial_sum_out, 5, "t0 input(5) -> t1 output should be 5*1+0=5");

        activation_in = 6; partial_sum_in = 0;
        @(posedge clk); #1;
        check(partial_sum_out, 6, "t1 input(6) -> t2 output should be 6*1+0=6");

        activation_in = 7; partial_sum_in = 0;
        @(posedge clk); #1;
        check(partial_sum_out, 7, "t2 input(7) -> t3 output should be 7*1+0=7");

        activation_in = 8; partial_sum_in = 0;
        @(posedge clk); #1;
        check(partial_sum_out, 8, "t3 input(8) -> t4 output should be 8*1+0=8");

        if (errors == 0)
            $display("ALL TESTS PASSED.");
        else
            $display("%0d TEST(S) FAILED.", errors);

        $finish;
    end

endmodule
