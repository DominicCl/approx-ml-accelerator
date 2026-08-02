module mac_approx (
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire signed [7:0]  weight,
    input  wire signed [7:0]  activation,
    input  wire        [7:0]  threshold,
    output reg  signed [31:0] accum_out,
    output wire                skipped
);

    wire [7:0] abs_weight;
    assign abs_weight = weight[7] ? (-weight) : weight;

    wire weight_is_small;
    wire activation_is_zero;
    assign weight_is_small   = (abs_weight < threshold);
    assign activation_is_zero = (activation == 8'sd0);

    assign skipped = weight_is_small | activation_is_zero;

    wire signed [15:0] product;
    assign product = weight * activation;

    always @(posedge clk) begin
        if (reset) begin
            accum_out <= 32'sd0;
        end else if (accumulate_enable && !skipped) begin

            accum_out <= accum_out + product;
        end

    end

endmodule
