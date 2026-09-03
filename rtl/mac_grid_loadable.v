module mac_grid_loadable #(
    parameter ROWS = 2,
    parameter COLS = 2
) (
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire               weight_load_enable,
    input  wire        [7:0]  threshold,

    input  wire signed [7:0]  weight_shift_in,
    output wire signed [7:0]  weight_shift_out,

    input  wire signed [7:0]  activation_entry [0:ROWS-1],
    output wire signed [31:0] result [0:COLS-1],
    output wire                skip [0:ROWS-1][0:COLS-1]
);

    wire signed [7:0]  act_wire  [0:ROWS-1][0:COLS-1];
    wire signed [31:0] psum_wire [0:ROWS-1][0:COLS-1];
    wire signed [7:0]  w_wire    [0:ROWS-1][0:COLS-1];

    genvar r, c;
    generate
        for (r = 0; r < ROWS; r = r + 1) begin : row_gen
            for (c = 0; c < COLS; c = c + 1) begin : col_gen

                wire signed [7:0] this_activation_in;
                wire signed [31:0] this_psum_in;
                wire signed [7:0] this_weight_shift_in;

                if (c == 0) begin
                    assign this_activation_in = activation_entry[r];
                end else begin
                    assign this_activation_in = act_wire[r][c-1];
                end

                if (r == 0) begin
                    assign this_psum_in = 32'sd0;
                end else begin
                    assign this_psum_in = psum_wire[r-1][c];
                end

                if (r == 0 && c == 0) begin
                    assign this_weight_shift_in = weight_shift_in;
                end else if (c == 0) begin
                    assign this_weight_shift_in = w_wire[r-1][COLS-1];
                end else begin
                    assign this_weight_shift_in = w_wire[r][c-1];
                end

                mac_grid_cell_loadable pe (
                    .clk(clk),
                    .reset(reset),
                    .accumulate_enable(accumulate_enable),
                    .weight_load_enable(weight_load_enable),
                    .weight_shift_in(this_weight_shift_in),
                    .activation_in(this_activation_in),
                    .threshold(threshold),
                    .partial_sum_in(this_psum_in),
                    .skip_decision(skip[r][c]),
                    .activation_out(act_wire[r][c]),
                    .partial_sum_out(psum_wire[r][c]),
                    .weight_shift_out(w_wire[r][c])
                );

                if (r == ROWS - 1) begin
                    assign result[c] = psum_wire[r][c];
                end

            end
        end
    endgenerate

    assign weight_shift_out = w_wire[ROWS-1][COLS-1];

endmodule
