module register_file(
    input clk,
    input [4:0] read_reg_1,
    input [4:0] read_reg_2,
    input [4:0] write_reg,
    input [31:0] write_data,
    input write_enable,

    output [31:0] read_data_1,
    output [31:0] read_data_2
);
    reg [31:0] register [31:0];

    assign read_data_1= (read_reg_1 == 5'b0) ? 32'b0 :register[read_reg_1];
    assign read_data_2= (read_reg_2 == 5'b0) ? 32'b0 :register[read_reg_2];

    always @(posedge clk)
    begin
        if(write_enable && write_reg!=5'b0)
        begin
            register[write_reg]<=write_data;
        end
    end
endmodule