`timescale 1ns / 1ps

module mac_grid_4x4_check_tb;

    parameter ROWS = 4;
    parameter COLS = 4;

    reg clk;
    reg reset;
    reg accumulate_enable;
    reg [7:0] threshold;

    reg signed [7:0] weight [0:ROWS-1][0:COLS-1];
    reg signed [7:0] activation_entry [0:ROWS-1];
    wire signed [31:0] result [0:COLS-1];
    wire skip [0:ROWS-1][0:COLS-1];

    integer errors = 0;
    integer t;

    mac_grid #(.ROWS(ROWS), .COLS(COLS)) uut (
        .clk(clk),
        .reset(reset),
        .accumulate_enable(accumulate_enable),
        .threshold(threshold),
        .weight(weight),
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
        $display("Testing parameterized mac_grid at ROWS=4, COLS=4");
        $display("A = [[1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,16]]");
        $display("B = [[1,0,0,1],[0,1,1,0],[1,1,0,0],[0,0,1,1]]");
        $display("Expected C = [[4,5,6,5],[12,13,14,13],[20,21,22,21],[28,29,30,29]]");

        reset = 1;
        accumulate_enable = 0;
        threshold = 8'd0;

        weight[0][0]=1; weight[0][1]=0; weight[0][2]=0; weight[0][3]=1;
        weight[1][0]=0; weight[1][1]=1; weight[1][2]=1; weight[1][3]=0;
        weight[2][0]=1; weight[2][1]=1; weight[2][2]=0; weight[2][3]=0;
        weight[3][0]=0; weight[3][1]=0; weight[3][2]=1; weight[3][3]=1;

        activation_entry[0] = 0;
        activation_entry[1] = 0;
        activation_entry[2] = 0;
        activation_entry[3] = 0;
        @(posedge clk); #1;

        reset = 0;
        accumulate_enable = 1;

        activation_entry[0] = 1;
        @(posedge clk); #1;

        activation_entry[0] = 5;
        activation_entry[1] = 2;
        @(posedge clk); #1;

        activation_entry[0] = 9;
        activation_entry[1] = 6;
        activation_entry[2] = 3;
        @(posedge clk); #1;

        activation_entry[0] = 13;
        activation_entry[1] = 10;
        activation_entry[2] = 7;
        activation_entry[3] = 4;
        @(posedge clk); #1;
        check(result[0], 4, "t3: result[0] (col0 first value) should be C[0][0]=4");

        activation_entry[0] = 0;
        activation_entry[1] = 14;
        activation_entry[2] = 11;
        activation_entry[3] = 8;
        @(posedge clk); #1;
        check(result[0], 12, "t4: result[0] should be C[1][0]=12");
        check(result[1], 5, "t4: result[1] should be C[0][1]=5");

        activation_entry[0] = 0;
        activation_entry[1] = 0;
        activation_entry[2] = 15;
        activation_entry[3] = 12;
        @(posedge clk); #1;
        check(result[0], 20, "t5: result[0] should be C[2][0]=20");
        check(result[1], 13, "t5: result[1] should be C[1][1]=13");
        check(result[2], 6, "t5: result[2] should be C[0][2]=6");

        activation_entry[0] = 0;
        activation_entry[1] = 0;
        activation_entry[2] = 0;
        activation_entry[3] = 16;
        @(posedge clk); #1;
        check(result[0], 28, "t6: result[0] should be C[3][0]=28");
        check(result[1], 21, "t6: result[1] should be C[2][1]=21");
        check(result[2], 14, "t6: result[2] should be C[1][2]=14");
        check(result[3], 5, "t6: result[3] should be C[0][3]=5");

        activation_entry[0] = 0;
        activation_entry[1] = 0;
        activation_entry[2] = 0;
        activation_entry[3] = 0;
        @(posedge clk); #1;
        check(result[1], 29, "t7: result[1] should be C[3][1]=29");
        check(result[2], 22, "t7: result[2] should be C[2][2]=22");
        check(result[3], 13, "t7: result[3] should be C[1][3]=13");

        @(posedge clk); #1;
        check(result[2], 30, "t8: result[2] should be C[3][2]=30");
        check(result[3], 21, "t8: result[3] should be C[2][3]=21");

        @(posedge clk); #1;
        check(result[3], 29, "t9: result[3] should be C[3][3]=29");

        if (errors == 0)
            $display("ALL TESTS PASSED - 4x4 grid matches numpy-verified matmul exactly.");
        else
            $display("%0d TEST(S) FAILED.", errors);

        $finish;
    end

endmodule
