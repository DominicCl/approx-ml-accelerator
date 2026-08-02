module mac_grid2x2 (
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire        [7:0]  threshold,

    input  wire signed [7:0]  weight_00,
    input  wire signed [7:0]  weight_01,
    input  wire signed [7:0]  weight_10,
    input  wire signed [7:0]  weight_11,

    input  wire signed [7:0]  activation_col0_entry,
    input  wire signed [7:0]  activation_col1_entry,

    output wire signed [31:0] result_col0,
    output wire signed [31:0] result_col1
);

    wire signed [7:0] act_row0_c0_to_c1;
    wire signed [7:0] act_row1_c0_to_c1;

    wire signed [31:0] psum_c0_row0_to_row1;
    wire signed [31:0] psum_c1_row0_to_row1;

    wire skip_00, skip_01, skip_10, skip_11;

    mac_grid_cell cell1 (
        .clk(clk), .reset(reset), .accumulate_enable(accumulate_enable),
        .weight(weight_00),
        .activation_in(activation_col0_entry),
        .threshold(threshold),
        .partial_sum_in(32'sd0),
        .skip_decision(skip_00),
        .activation_out(act_row0_c0_to_c1),
        .partial_sum_out(psum_c0_row0_to_row1)
    );

    mac_grid_cell cell2 (
        .clk(clk), .reset(reset), .accumulate_enable(accumulate_enable),
        .weight(weight_01),
        .activation_in(act_row0_c0_to_c1),
        .threshold(threshold),
        .partial_sum_in(32'sd0),
        .skip_decision(skip_01),
        .activation_out(),
        .partial_sum_out(psum_c1_row0_to_row1)
    );

    mac_grid_cell cell3 (
        .clk(clk), .reset(reset), .accumulate_enable(accumulate_enable),
        .weight(weight_10),
        .activation_in(activation_col1_entry),
        .threshold(threshold),
        .partial_sum_in(psum_c0_row0_to_row1),
        .skip_decision(skip_10),
        .activation_out(act_row1_c0_to_c1),
        .partial_sum_out(result_col0)
    );

    mac_grid_cell cell4 (
        .clk(clk), .reset(reset), .accumulate_enable(accumulate_enable),
        .weight(weight_11),
        .activation_in(act_row1_c0_to_c1),
        .threshold(threshold),
        .partial_sum_in(psum_c1_row0_to_row1),
        .skip_decision(skip_11),
        .activation_out(),
        .partial_sum_out(result_col1)
    );

endmodule
