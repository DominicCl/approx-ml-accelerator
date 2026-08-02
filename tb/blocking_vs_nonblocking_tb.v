// blocking_vs_nonblocking_tb.v
// TEACHING EXAMPLE ONLY.

`timescale 1ns / 1ps

module blocking_vs_nonblocking_tb;

    reg clk;
    reg [7:0] data_in;

    wire [7:0] nb_reg_a, nb_reg_b; // non-blocking version's outputs
    wire [7:0] bl_reg_a, bl_reg_b; // blocking version's outputs

    nonblocking_version nb_uut (
        .clk(clk), .data_in(data_in), .reg_a(nb_reg_a), .reg_b(nb_reg_b)
    );

    blocking_version bl_uut (
        .clk(clk), .data_in(data_in), .reg_a(bl_reg_a), .reg_b(bl_reg_b)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Feeding data_in = 10, 20, 30, 40 on successive cycles...");
        $display("time  data_in | NONBLOCKING (correct pipeline)  | BLOCKING (incorrect pipeline)");
        $display("            | reg_a  reg_b                     | reg_a  reg_b");

        data_in = 10;
        @(posedge clk); #1;
        $display("%40t  %3d    |  %3d    %3d                        |  %3d    %3d",
                   $time, data_in, nb_reg_a, nb_reg_b, bl_reg_a, bl_reg_b);

        data_in = 20;
        @(posedge clk); #1;
        $display("%40t  %3d    |  %3d    %3d                        |  %3d    %3d",
                   $time, data_in, nb_reg_a, nb_reg_b, bl_reg_a, bl_reg_b);

        data_in = 30;
        @(posedge clk); #1;
        $display("%40t  %3d    |  %3d    %3d                        |  %3d    %3d",
                   $time, data_in, nb_reg_a, nb_reg_b, bl_reg_a, bl_reg_b);

        data_in = 40;
        @(posedge clk); #1;
        $display("%40t  %3d    |  %3d    %3d                        |  %3d    %3d",
                   $time, data_in, nb_reg_a, nb_reg_b, bl_reg_a, bl_reg_b);

        $finish;
    end

endmodule
