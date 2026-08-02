// counter_example_tb.v
// TEACHING EXAMPLE ONLY.

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

    // Generate a repeating clock signal: flip clk every 5ns.
    // This gives a full clock period of 10ns (5ns low, 5ns high).
    initial clk = 0;
    always #5 clk = ~clk;   // ~ means "flip/invert" (like ! in C++, but bitwise)

    initial begin
        $display("time=%0t  count=%0d  (starting, reset held high)", $time, count);
        reset = 1;
        #10; // hold reset through one full clock period

        reset = 0;
        $display("time=%0t  count=%0d  (reset released)", $time, count);

        // Watch the counter tick forward over several clock cycles,
        // including past its max value of 15, to observe overflow.
        repeat (20) begin
            #10; // wait one full clock period
            $display("time=%0t  count=%0d", $time, count);
        end

        $finish;
    end

endmodule
