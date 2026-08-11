module sign_extend(
    input [15:0] IN,
    
    output [31:0] OUT
);

    assign OUT[31:0] ={{16{IN[15]}},IN[15:0]};
endmodule