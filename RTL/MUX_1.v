module mux_1(
    input [31:0] a,
    input [31:0] b,
    input sel,

    output [31:0] c
);

    assign c = sel ? a : b;
endmodule