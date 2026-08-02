module mac_approx_pipelined (
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire signed [7:0]  weight,
    input  wire signed [7:0]  activation,
    input  wire        [7:0]  threshold,
    output reg  signed [31:0] accum_out,
    output wire                skip_decision

);

    wire [7:0] abs_weight;
    assign abs_weight = weight[7] ? (-weight) : weight;

    wire weight_is_small;
    wire activation_is_zero;
    assign weight_is_small    = (abs_weight < threshold);
    assign activation_is_zero = (activation == 8'sd0);
    assign skip_decision      = weight_is_small | activation_is_zero;

    reg signed [7:0] weight_reg;
    reg signed [7:0] activation_reg;
    reg              stage1_valid;

    always @(posedge clk) begin
        if (reset) begin
            weight_reg     <= 8'sd0;
            activation_reg <= 8'sd0;
            stage1_valid   <= 1'b0;
        end else if (accumulate_enable && !skip_decision) begin
            weight_reg     <= weight;
            activation_reg <= activation;
            stage1_valid   <= 1'b1;
        end else begin

            stage1_valid <= 1'b0;
        end
    end

    wire signed [15:0] product;
    assign product = weight_reg * activation_reg;

    always @(posedge clk) begin
        if (reset) begin
            accum_out <= 32'sd0;
        end else if (stage1_valid) begin
            accum_out <= accum_out + product;
        end

    end

endmodule
