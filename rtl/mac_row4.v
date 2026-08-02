module mac_row4 (
    input  wire               clk,
    input  wire               reset,
    input  wire               accumulate_enable,
    input  wire        [7:0]  threshold,

    input  wire signed [7:0]  activation_in,

    input  wire signed [7:0]  weight_0,
    input  wire signed [7:0]  weight_1,
    input  wire signed [7:0]  weight_2,
    input  wire signed [7:0]  weight_3,

    output wire signed [31:0] accum_out_0,
    output wire signed [31:0] accum_out_1,
    output wire signed [31:0] accum_out_2,
    output wire signed [31:0] accum_out_3,

    output wire                skip_0,
    output wire                skip_1,
    output wire                skip_2,
    output wire                skip_3
);

    wire signed [7:0] act_link_0to1;
    wire signed [7:0] act_link_1to2;
    wire signed [7:0] act_link_2to3;
    wire signed [7:0] act_link_3out;

    mac_approx_pipelined unit0 (
        .clk(clk),
        .reset(reset),
        .accumulate_enable(accumulate_enable),
        .weight(weight_0),
        .activation(activation_in),
        .threshold(threshold),
        .accum_out(accum_out_0),
        .skip_decision(skip_0),
        .activation_out(act_link_0to1)
    );

    mac_approx_pipelined unit1 (
        .clk(clk),
        .reset(reset),
        .accumulate_enable(accumulate_enable),
        .weight(weight_1),
        .activation(act_link_0to1),
        .threshold(threshold),
        .accum_out(accum_out_1),
        .skip_decision(skip_1),
        .activation_out(act_link_1to2)
    );

    mac_approx_pipelined unit2 (
        .clk(clk),
        .reset(reset),
        .accumulate_enable(accumulate_enable),
        .weight(weight_2),
        .activation(act_link_1to2),
        .threshold(threshold),
        .accum_out(accum_out_2),
        .skip_decision(skip_2),
        .activation_out(act_link_2to3)
    );

    mac_approx_pipelined unit3 (
        .clk(clk),
        .reset(reset),
        .accumulate_enable(accumulate_enable),
        .weight(weight_3),
        .activation(act_link_2to3),
        .threshold(threshold),
        .accum_out(accum_out_3),
        .skip_decision(skip_3),
        .activation_out(act_link_3out)
    );

endmodule
