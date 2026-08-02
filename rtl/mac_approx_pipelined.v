module mac_approx_pipelined (
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire signed [7:0]  weight,
    input  wire signed [7:0]  activation,
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
    assign activation_is_zero = (activation == 8'sd0);
    assign skip_decision      = weight_is_small | activation_is_zero;

    reg signed [7:0]  weight_reg;
    reg signed [7:0]  activation_reg;
    reg signed [31:0] partial_sum_reg;
    reg               stage1_valid;
    reg               stage1_skip;

    always @(posedge clk) begin
        if (reset) begin
            weight_reg      <= 8'sd0;
            activation_reg  <= 8'sd0;
            partial_sum_reg <= 32'sd0;
            stage1_valid    <= 1'b0;
            stage1_skip     <= 1'b0;
        end else if (accumulate_enable) begin
            partial_sum_reg <= partial_sum_in;
            stage1_skip     <= skip_decision;
            if (!skip_decision) begin
                weight_reg     <= weight;
                activation_reg <= activation;
                stage1_valid   <= 1'b1;
            end else begin
                stage1_valid   <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            activation_out <= 8'sd0;
        end else if (accumulate_enable) begin
            activation_out <= activation;
        end
    end

    wire signed [15:0] product;
    assign product = weight_reg * activation_reg;

    always @(posedge clk) begin
        if (reset) begin
            partial_sum_out <= 32'sd0;
        end else if (stage1_valid) begin
            partial_sum_out <= partial_sum_reg + product;
        end else if (stage1_skip) begin
            partial_sum_out <= partial_sum_reg;
        end
    end

endmodule
