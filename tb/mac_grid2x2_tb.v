`timescale 1ns / 1ps

module mac_grid2x2_tb;

    reg clk;
    reg reset;
    reg accumulate_enable;
    reg [7:0] threshold;
    reg signed [7:0] weight_00, weight_01, weight_10, weight_11;
    reg signed [7:0] activation_col0_in;
    reg signed [7:0] activation_col1_in;
    wire signed [31:0] result_col0, result_col1;

    integer errors = 0;

    mac_grid2x2 uut (
        .clk(clk), .reset(reset), .accumulate_enable(accumulate_enable),
        .threshold(threshold),
        .weight_00(weight_00), .weight_01(weight_01),
        .weight_10(weight_10), .weight_11(weight_11),
        .activation_row0_in(activation_col0_in),
        .activation_row1_in(activation_col1_in),
        .result_col0(result_col0),
        .result_col1(result_col1)
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
        $display("Weights: W00=1 W01=2 W10=3 W11=4  (B = [1 2; 3 4])");
        $display("Activations: A = [5 6; 7 8], entered COLUMN-MAJOR: col0=[5,7] into cell1, col1=[6,8] into cell3");
        $display("Expected: C00=23 C01=34 C10=31 C11=46");

        reset = 1;
        accumulate_enable = 0;
        threshold = 8'd0;
        weight_00 = 1; weight_01 = 2; weight_10 = 3; weight_11 = 4;
        activation_col0_in = 0;
        activation_col1_in = 0;
        @(posedge clk); #1;

        reset = 0;
        accumulate_enable = 1;

        activation_col0_in = 5;
        activation_col1_in = 0;
        @(posedge clk); #1;

        activation_col0_in = 7;
        activation_col1_in = 6;
        @(posedge clk); #1;
        check(result_col0, 23, "t2: result_col0 should be C00=23");

        activation_col0_in = 0;
        activation_col1_in = 8;
        @(posedge clk); #1;
        check(result_col0, 31, "t3: result_col0 should be C10=31");
        check(result_col1, 34, "t3: result_col1 should be C01=34");

        activation_col0_in = 0;
        activation_col1_in = 0;
        @(posedge clk); #1;
        check(result_col1, 46, "t4: result_col1 should be C11=46");

        if (errors == 0)
            $display("ALL TESTS PASSED.");
        else
            $display("%0d TEST(S) FAILED.", errors);

        $finish;
    end

    always @(posedge clk) begin
        #2;
        $display("  [monitor] time=%0t  act_col0=%0d act_col1=%0d  result_col0=%0d result_col1=%0d",
                  $time, activation_col0_in, activation_col1_in, result_col0, result_col1);
    end

endmodule
