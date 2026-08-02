`timescale 1ns / 1ps

module counter_example_tb;

    reg clk;
    reg reset;
    wire [3:0] count;

    counter_example uut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("time=%0t  count=%0d  (starting, reset held high)", $time, count);
        reset = 1;
        #10;

        reset = 0;
        $display("time=%0t  count=%0d  (reset released)", $time, count);

        repeat (20) begin
            #10;
            $display("time=%0t  count=%0d", $time, count);
        end

        $finish;
    end

endmodule
