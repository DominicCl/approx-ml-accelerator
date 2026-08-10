// A systolic array of MAC cells, sized by ROWS and COLS. The same file
// works for a 2x2 grid or a 32x32 grid - just change these two numbers
// when instantiating it, no rewriting needed.
module mac_grid #(
    parameter ROWS = 2,
    parameter COLS = 2
) (
    // Shared control signals - every cell in the grid uses the same
    // clock, reset, enable, and skip-threshold.
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire        [7:0]  threshold,

    // weight[r][c] is the fixed value stored in the cell at row r,
    // column c. This is the "weight-stationary" part of the design -
    // these values get loaded once and never move.
    input  wire signed [7:0]  weight [0:ROWS-1][0:COLS-1],

    // One activation entry point per row. activation_entry[0] feeds the
    // leftmost cell of row 0, activation_entry[1] feeds row 1, etc.
    // Activations enter here and then flow rightward through the grid.
    input  wire signed [7:0]  activation_entry [0:ROWS-1],

    // One final answer per column, read from that column's bottom cell,
    // since that's where a column's full accumulated sum ends up.
    output wire signed [31:0] result [0:COLS-1],

    // skip[r][c] lets us see, from outside, whether the cell at (r,c)
    // decided to skip its multiply-accumulate this cycle. Useful for
    // verifying the approximation logic is really triggering, and later
    // for measuring what fraction of cells skipped (an energy metric).
    output wire                skip [0:ROWS-1][0:COLS-1]
);

    // Internal wiring: act_wire[r][c] carries the activation flowing OUT
    // of cell (r,c), which the cell to its right will read as its own
    // input. psum_wire[r][c] carries the running sum flowing OUT of cell
    // (r,c) downward, which the cell below it will read as its input.
    wire signed [7:0]  act_wire  [0:ROWS-1][0:COLS-1];
    wire signed [31:0] psum_wire [0:ROWS-1][0:COLS-1];

    // genvar: a loop counter that only exists at compile time, used to
    // "unroll" this code into ROWS x COLS separate copies of real
    // hardware - not a real signal in the final circuit.
    genvar r, c;
    generate
        // Outer loop: once per row.
        for (r = 0; r < ROWS; r = r + 1) begin : row_gen
            // Inner loop: once per column, for each row. Together these
            // two loops mean everything below happens once for EVERY
            // cell position in the grid (ROWS x COLS times total).
            for (c = 0; c < COLS; c = c + 1) begin : col_gen

                // Each grid position gets its own fresh copy of these two
                // wires (a new one per loop iteration, not one shared wire).
                wire signed [7:0] this_activation_in;
                wire signed [31:0] this_psum_in;

                // Where does this cell's activation come from?
                // Leftmost column (c==0): from the grid's external entry
                // point for this row. Any other column: from the cell
                // immediately to the left (rightward flow).
                if (c == 0) begin
                    assign this_activation_in = activation_entry[r];
                end else begin
                    assign this_activation_in = act_wire[r][c-1];
                end

                // Where does this cell's incoming partial sum come from?
                // Top row (r==0): nothing above it, so it starts at zero.
                // Any other row: from the cell directly above (downward flow).
                if (r == 0) begin
                    assign this_psum_in = 32'sd0;
                end else begin
                    assign this_psum_in = psum_wire[r-1][c];
                end

                // Create one real MAC cell for this exact (r,c) position,
                // wired to its own weight, its own computed inputs above,
                // and writing its outputs into the array slots that the
                // NEXT cell (right and below) will read from.
                mac_grid_cell pe (
                    .clk(clk),
                    .reset(reset),
                    .accumulate_enable(accumulate_enable),
                    .weight(weight[r][c]),
                    .activation_in(this_activation_in),
                    .threshold(threshold),
                    .partial_sum_in(this_psum_in),
                    .skip_decision(skip[r][c]),
                    .activation_out(act_wire[r][c]),
                    .partial_sum_out(psum_wire[r][c])
                );

                // Only the bottom row's cells hold a column's true final
                // answer, so only they connect to the grid's real output.
                if (r == ROWS - 1) begin
                    assign result[c] = psum_wire[r][c];
                end

            end
        end
    endgenerate

endmodule
