module insturction_memory(
    input [31:0] read_address,
    
    output [31:0] instruction
);

    reg [31:0] memory [0:63];

    assign instruction = memory[read_address[31:2]];

    initial
    begin
        $readmemh("program_code.txt",memory);
    end
endmodule
