// blocking_vs_nonblocking_example.v
//
// TEACHING EXAMPLE ONLY - demonstrates the real behavioral difference
// between <= (non-blocking) and = (blocking) assignment, using the
// simplest possible case: passing a value through two chained registers.
//
// Expected correct behavior (like a 2-stage pipeline): on each clock
// edge, reg_b should take on whatever reg_a held BEFORE this edge (i.e.
// reg_b lags reg_a by exactly one cycle), and reg_a takes on the new
// input. This is the standard "shift register" pattern.

module nonblocking_version (
    input  wire clk,
    input  wire [7:0] data_in,
    output reg  [7:0] reg_a,
    output reg  [7:0] reg_b
);
    always @(posedge clk) begin
        reg_a <= data_in;  // non-blocking
        reg_b <= reg_a;    // reads reg_a's OLD (pre-edge) value
    end
endmodule

module blocking_version (
    input  wire clk,
    input  wire [7:0] data_in,
    output reg  [7:0] reg_a,
    output reg  [7:0] reg_b
);
    always @(posedge clk) begin
        reg_a = data_in;   // blocking
        reg_b = reg_a;     // reads reg_a's NEW value (just set on the line above!)
    end
endmodule
