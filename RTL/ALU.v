module ALU(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUcontrole,
    output reg [31:0] Result,
    output zero
);
always @(*)
begin
    case(ALUcontrole)
        3'b000:
            Result =A & B;
        3'b001:
            Result = A|B; 
        3'b010:
            Result = A+B;
        3'b110:
            Result = A-B;
        3'b111:
            Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
        default:
            Result=32'b0;
    endcase
end
assign zero=(Result==32'b0);
endmodule



