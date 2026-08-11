module data_memory(
    input clk,
    input [31:0] address,
    input write_enable,
    input [31:0] write_data,

    output [31:0] reg_read
);
    reg [31:0] memory [1023:0];

    wire [9:0] effective_address = address[11:2];

    always @(posedge clk)
    begin
        if(write_enable)
        begin
            memory[effective_address] <= write_data;
        end
    end

    assign reg_read = memory[effective_address];
endmodule