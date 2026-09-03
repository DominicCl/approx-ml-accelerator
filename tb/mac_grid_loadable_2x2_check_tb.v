`timescale 1ns / 1ps

module mac_grid_loadable_2x2_check_tb;

    parameter ROWS = 2;
    parameter COLS = 2;

    reg clk;
    reg reset;
    reg accumulate_enable;
    reg weight_load_enable;
    reg [7:0] threshold;
    reg signed [7:0] weight_shift_in;
    wire signed [7:0] weight_shift_out;
    reg signed [7:0] activation_entry [0:ROWS-1];
    wire signed [31:0] result [0:COLS-1];
    wire skip [0:ROWS-1][0:COLS-1];

    integer errors = 0;

    mac_grid_loadable #(.ROWS(ROWS), .COLS(COLS)) uut (
        .clk(clk), .reset(reset),
        .accumulate_enable(accumulate_enable),
        .weight_load_enable(weight_load_enable),
        .threshold(threshold),
        .weight_shift_in(weight_shift_in),
        .weight_shift_out(weight_shift_out),
        .activation_entry(activation_entry),
        .result(result),
        .skip(skip)
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
        $display("Testing parameterized LOADABLE grid at ROWS=2, COLS=2");
        $display("Loading weights via shift chain (feed order 4,3,2,1 -> pe(0,0)=1,pe(0,1)=2,pe(1,0)=3,pe(1,1)=4)");

        reset = 1;
        accumulate_enable = 0;
        weight_load_enable = 0;
        threshold = 8'd0;
        weight_shift_in = 0;
        activation_entry[0] = 0;
        activation_entry[1] = 0;
        @(posedge clk); #1;

        reset = 0;
        weight_load_enable = 1;

        weight_shift_in = 4;
        @(posedge clk); #1;
        weight_shift_in = 3;
        @(posedge clk); #1;
        weight_shift_in = 2;
        @(posedge clk); #1;
        weight_shift_in = 1;
        @(posedge clk); #1;

        weight_load_enable = 0;

        $display("Compute mode: A=[5,6;7,8], expect C00=23 C01=34 C10=31 C11=46");
        accumulate_enable = 1;

        activation_entry[0] = 5;
        activation_entry[1] = 0;
        @(posedge clk); #1;

        activation_entry[0] = 7;
        activation_entry[1] = 6;
        @(posedge clk); #1;
        check(result[0], 23, "t2: result[0] should be C00=23");

        activation_entry[0] = 0;
        activation_entry[1] = 8;
        @(posedge clk); #1;
        check(result[0], 31, "t3: result[0] should be C10=31");
        check(result[1], 34, "t3: result[1] should be C01=34");

        activation_entry[0] = 0;
        activation_entry[1] = 0;
        @(posedge clk); #1;
        check(result[1], 46, "t4: result[1] should be C11=46");

        if (errors == 0)
            $display("ALL TESTS PASSED - parameterized loadable grid matches confirmed result.");
        else
            $display("%0d TEST(S) FAILED.", errors);

        $finish;
    end

endmodule
