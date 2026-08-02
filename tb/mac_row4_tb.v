`timescale 1ns / 1ps

module mac_row4_tb;

    reg clk;
    reg reset;
    reg accumulate_enable;
    reg [7:0] threshold;
    reg signed [7:0] activation_in;
    reg signed [7:0] weight_0, weight_1, weight_2, weight_3;

    wire signed [31:0] accum_out_0, accum_out_1, accum_out_2, accum_out_3;
    wire skip_0, skip_1, skip_2, skip_3;

    integer errors = 0;

    mac_row4 uut (
        .clk(clk),
        .reset(reset),
        .accumulate_enable(accumulate_enable),
        .threshold(threshold),
        .activation_in(activation_in),
        .weight_0(weight_0),
        .weight_1(weight_1),
        .weight_2(weight_2),
        .weight_3(weight_3),
        .accum_out_0(accum_out_0),
        .accum_out_1(accum_out_1),
        .accum_out_2(accum_out_2),
        .accum_out_3(accum_out_3),
        .skip_0(skip_0),
        .skip_1(skip_1),
        .skip_2(skip_2),
        .skip_3(skip_3)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task check(input signed [31:0] actual, input signed [31:0] expected, input [255:0] label);
        begin
            if (actual !== expected) begin
                errors = errors + 1;
                $display("FAIL [%0s]: got=%0d, expected=%0d", label, actual, expected);
            end else begin
                $display("PASS [%0s]: %0d", label, actual);
            end
        end
    endtask

    integer i;

    initial begin
        $display("Starting mac_row4 test...");

        reset = 1;
        accumulate_enable = 0;
        threshold = 8'd0;
        activation_in = 0;
        weight_0 = 1; weight_1 = 1; weight_2 = 1; weight_3 = 1;
        @(posedge clk); #1;
        check(accum_out_0, 0, "reset: accum_out_0");
        check(accum_out_3, 0, "reset: accum_out_3");

        reset = 0;
        accumulate_enable = 1;

        activation_in = 1;
        @(posedge clk); #1;

        activation_in = 2;
        @(posedge clk); #1;

        activation_in = 3;
        @(posedge clk); #1;

        activation_in = 4;
        @(posedge clk); #1;

        activation_in = 0;
        for (i = 0; i < 6; i = i + 1) begin
            @(posedge clk); #1;
        end

        check(accum_out_0, 1+2+3+4, "final accum_out_0 (weight=1, sum of all activations)");
        check(accum_out_1, 1+2+3+4, "final accum_out_1");
        check(accum_out_2, 1+2+3+4, "final accum_out_2");
        check(accum_out_3, 1+2+3+4, "final accum_out_3");

        if (errors == 0)
            $display("ALL TESTS PASSED.");
        else
            $display("%0d TEST(S) FAILED.", errors);

        $finish;
    end

    always @(posedge clk) begin
        #2;
        $display("  [monitor] time=%0t  acc0=%0d acc1=%0d acc2=%0d acc3=%0d",
                  $time, accum_out_0, accum_out_1, accum_out_2, accum_out_3);
    end

endmodule
