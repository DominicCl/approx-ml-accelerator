module mac_grid_cell (
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire signed [7:0]  weight,
    input  wire signed [7:0]  activation_in,
    input  wire        [7:0]  threshold,
    input  wire signed [31:0] partial_sum_in,
    output wire                skip_decision,
    output reg  signed [7:0]  activation_out,
    output reg  signed [31:0] partial_sum_out
);

    wire [7:0] abs_weight;
    assign abs_weight = weight[7] ? (-weight) : weight;

    wire weight_is_small;
    wire activation_is_zero;
    assign weight_is_small    = (abs_weight < threshold);
    assign activation_is_zero = (activation_in == 8'sd0);
    assign skip_decision      = weight_is_small | activation_is_zero;

    wire signed [15:0] product;
    assign product = weight * activation_in;

    always @(posedge clk) begin
        if (reset) begin
            activation_out   <= 8'sd0;
            partial_sum_out  <= 32'sd0;
        end else if (accumulate_enable) begin
            activation_out  <= activation_in;
            if (skip_decision)
                partial_sum_out <= partial_sum_in;
            else
                partial_sum_out <= partial_sum_in + product;
        end
    end

endmodule
