module mac_grid2x2_loadable (
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire               weight_load_enable,
    input  wire        [7:0]  threshold,

    input  wire signed [7:0]  weight_shift_in,
    output wire signed [7:0]  weight_shift_out,

    input  wire signed [7:0]  activation_col0_entry,
    input  wire signed [7:0]  activation_col1_entry,

    output wire signed [31:0] result_col0,
    output wire signed [31:0] result_col1
);

    wire signed [7:0] act_row0_c0_to_c1;
    wire signed [7:0] act_row1_c0_to_c1;

    wire signed [31:0] psum_c0_row0_to_row1;
    wire signed [31:0] psum_c1_row0_to_row1;

    wire signed [7:0] w_shift_0to1;
    wire signed [7:0] w_shift_1to2;
    wire signed [7:0] w_shift_2to3;

    mac_grid_cell_loadable pe00 (
        .clk(clk), .reset(reset), .accumulate_enable(accumulate_enable),
        .weight_load_enable(weight_load_enable),
        .weight_shift_in(weight_shift_in),
        .activation_in(activation_col0_entry),
        .threshold(threshold),
        .partial_sum_in(32'sd0),
        .skip_decision(),
        .activation_out(act_row0_c0_to_c1),
        .partial_sum_out(psum_c0_row0_to_row1),
        .weight_shift_out(w_shift_0to1)
    );

    mac_grid_cell_loadable pe01 (
        .clk(clk), .reset(reset), .accumulate_enable(accumulate_enable),
        .weight_load_enable(weight_load_enable),
        .weight_shift_in(w_shift_0to1),
        .activation_in(act_row0_c0_to_c1),
        .threshold(threshold),
        .partial_sum_in(32'sd0),
        .skip_decision(),
        .activation_out(),
        .partial_sum_out(psum_c1_row0_to_row1),
        .weight_shift_out(w_shift_1to2)
    );

    mac_grid_cell_loadable pe10 (
        .clk(clk), .reset(reset), .accumulate_enable(accumulate_enable),
        .weight_load_enable(weight_load_enable),
        .weight_shift_in(w_shift_1to2),
        .activation_in(activation_col1_entry),
        .threshold(threshold),
        .partial_sum_in(psum_c0_row0_to_row1),
        .skip_decision(),
        .activation_out(act_row1_c0_to_c1),
        .partial_sum_out(result_col0),
        .weight_shift_out(w_shift_2to3)
    );

    mac_grid_cell_loadable pe11 (
        .clk(clk), .reset(reset), .accumulate_enable(accumulate_enable),
        .weight_load_enable(weight_load_enable),
        .weight_shift_in(w_shift_2to3),
        .activation_in(act_row1_c0_to_c1),
        .threshold(threshold),
        .partial_sum_in(psum_c1_row0_to_row1),
        .skip_decision(),
        .activation_out(),
        .partial_sum_out(result_col1),
        .weight_shift_out(weight_shift_out)
    );

endmodule
