module mac_baseline (
    input  wire              clk,
    input  wire              reset,
    input  wire              accumulate_enable,
    input  wire signed [7:0] weight,
    input  wire signed [7:0] activation,
    output reg  signed [31:0] accum_out
);

    wire signed [15:0] product;
    assign product = weight * activation;

    always @(posedge clk) begin
        if (reset) begin
            accum_out <= 32'sd0;
        end else if (accumulate_enable) begin

            accum_out <= accum_out + product;
        end

    end

endmodule
