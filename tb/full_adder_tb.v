`timescale 1ns / 1ps

module full_adder_tb;

    reg a, b, cin;

    wire sum, cout;

    integer errors = 0;
    integer i;
    reg expected_sum, expected_cout;
    reg [1:0] full_expected;

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

            {a, b, cin} = i[2:0];

            #5;

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
