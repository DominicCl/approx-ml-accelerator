// counter_example.v
//
// TEACHING EXAMPLE ONLY - not part of the final chip design.
// A simple 4-bit counter: on every rising clock edge, it adds 1 to its
// stored value. This is the simplest possible circuit that "remembers"
// something across time, to illustrate registers + clock edges.

module counter_example (
    input  wire clk,      // the clock signal
    input  wire reset,    // sets count back to 0 when high
    output reg [3:0] count // a 4-bit stored value (0 to 15)
);

    // "always @(posedge clk)" means: run this block ONLY at the instant
    // the clock transitions from 0 to 1 (a "positive edge" / "rising
    // edge"). At all other times, this block does nothing at all - the
    // circuit just holds (remembers) whatever count currently is.
    always @(posedge clk) begin
        if (reset)
            count <= 4'b0000;      // reset to zero
        else
            count <= count + 1;    // otherwise, increment
    end

endmodule
