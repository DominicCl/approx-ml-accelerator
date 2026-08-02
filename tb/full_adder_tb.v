// full_adder_tb.v
//
// Testbench for full_adder.v. Exhaustively drives all 8 combinations of
// (a, b, cin), prints the result each time, and checks it against the
// expected value computed independently in the testbench itself.

`timescale 1ns / 1ps

module full_adder_tb;

    // reg: things *we* (the testbench) drive/control
    reg a, b, cin;

    // wire: things driven *by* the module under test
    wire sum, cout;

    integer errors = 0;
    integer i;
    reg expected_sum, expected_cout;
    reg [1:0] full_expected; // {cout, sum} bundled for easy comparison

    // Instantiate the module under test ("uut" = unit under test).
    // This wires our testbench regs/wires to the full_adder's ports.
    full_adder uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        $display("Starting full_adder exhaustive test (8 cases)...");

        for (i = 0; i < 8; i = i + 1) begin
            // Unpack loop counter i into the three 1-bit inputs.
            {a, b, cin} = i[2:0];

            // Let the combinational logic settle before checking outputs.
            #5;

            // Compute the expected result independently (plain arithmetic,
            // not reusing the module's own logic) so this is a real check.
            {expected_cout, expected_sum} = a + b + cin;

            if (sum !== expected_sum || cout !== expected_cout) begin
                errors = errors + 1;
                $display("FAIL: a=%b b=%b cin=%b -> got sum=%b cout=%b, expected sum=%b cout=%b",
                          a, b, cin, sum, cout, expected_sum, expected_cout);
            end else begin
                $display("PASS: a=%b b=%b cin=%b -> sum=%b cout=%b",
                          a, b, cin, sum, cout);
            end
        end

        if (errors == 0)
            $display("ALL 8 CASES PASSED.");
        else
            $display("%0d CASE(S) FAILED.", errors);

        $finish;
    end

endmodule
