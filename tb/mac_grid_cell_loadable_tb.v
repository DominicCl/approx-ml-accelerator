`timescale 1ns / 1ps

module mac_grid_cell_loadable_tb;

    reg clk;
    reg reset;
    reg accumulate_enable;
    reg weight_load_enable;
    reg signed [7:0] weight_shift_in;
    reg signed [7:0] activation_in;
    reg [7:0] threshold;
    reg signed [31:0] partial_sum_in;
    wire skip_decision;
    wire signed [7:0] activation_out;
    wire signed [31:0] partial_sum_out;
    wire signed [7:0] weight_shift_out;

    integer errors = 0;

    mac_grid_cell_loadable uut (
        .clk(clk), .reset(reset),
        .accumulate_enable(accumulate_enable),
        .weight_load_enable(weight_load_enable),
        .weight_shift_in(weight_shift_in),
        .activation_in(activation_in),
        .threshold(threshold),
        .partial_sum_in(partial_sum_in),
        .skip_decision(skip_decision),
        .activation_out(activation_out),
        .partial_sum_out(partial_sum_out),
        .weight_shift_out(weight_shift_out)
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
        $display("Testing single loadable cell: shift in 9, then 7, verify shift-out behavior");

        reset = 1;
        weight_load_enable = 0;
        accumulate_enable = 0;
        weight_shift_in = 0;
        activation_in = 0;
        threshold = 8'd0;
        partial_sum_in = 0;
        @(posedge clk); #1;
        check(weight_shift_out, 0, "after reset: weight_shift_out=0");

        reset = 0;
        weight_load_enable = 1;

        weight_shift_in = 9;
        @(posedge clk); #1;
        check(weight_shift_out, 9, "cycle1: shifted in 9, now visible immediately (no extra lag)");

        weight_shift_in = 7;
        @(posedge clk); #1;
        check(weight_shift_out, 7, "cycle2: shifted in 7, replaces 9 immediately");

        weight_load_enable = 0;
        accumulate_enable = 1;
        activation_in = 3;
        @(posedge clk); #1;
        check(partial_sum_out, 21, "compute mode: weight_reg should now hold 7, 7*3=21");

        if (errors == 0)
            $display("ALL TESTS PASSED.");
        else
            $display("%0d TEST(S) FAILED.", errors);

        $finish;
    end

endmodule
