// full_adder.v
//
// A 1-bit full adder: the most fundamental building block of digital
// arithmetic. Adds two 1-bit inputs (a, b) plus a carry-in (cin), and
// produces a 1-bit sum and a carry-out (cout).
//
// This exists purely as a toolchain smoke test — it's not part of the
// final chip design. If this compiles and simulates correctly, we know
// iverilog is working end-to-end before we build anything real.

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);

    // Sum is 1 whenever an odd number of inputs are 1 (classic XOR logic).
    assign sum  = a ^ b ^ cin;

    // Carry-out is 1 whenever at least two of the three inputs are 1.
    assign cout = (a & b) | (a & cin) | (b & cin);

endmodule
