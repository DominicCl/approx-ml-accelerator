module nonblocking_version (
    input  wire clk,
    input  wire [7:0] data_in,
    output reg  [7:0] reg_a,
    output reg  [7:0] reg_b
);
    always @(posedge clk) begin
        reg_a <= data_in;
        reg_b <= reg_a;
    end
endmodule

module blocking_version (
    input  wire clk,
    input  wire [7:0] data_in,
    output reg  [7:0] reg_a,
    output reg  [7:0] reg_b
);
    always @(posedge clk) begin
        reg_a = data_in;
        reg_b = reg_a;
    end
endmodule
