module CPU(
    input clk,
    input reset
);

    // =========================================================
    // 1. PROGRAM COUNTER
    // =========================================================

    wire [31:0] current_pc;
    wire [31:0] next_pc;

    Program_Counter PC(
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .current_pc(current_pc)
    );


    // =========================================================
    // 2. PC + 4
    // =========================================================

    wire [31:0] pc_plus_4;

    assign pc_plus_4 = current_pc + 32'd4;


    // =========================================================
    // 3. INSTRUCTION MEMORY
    // =========================================================

    wire [31:0] instruction;

    insturction_memory IM(
        .read_address(current_pc),
        .instruction(instruction)
    );


    // =========================================================
    // 4. EXTRACT INSTRUCTION FIELDS
    // =========================================================

    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [5:0] funct;

    assign opcode = instruction[31:26];
    assign rs     = instruction[25:21];
    assign rt     = instruction[20:16];
    assign rd     = instruction[15:11];
    assign funct  = instruction[5:0];


    // =========================================================
    // 5. MAIN CONTROL UNIT
    // =========================================================

    wire mem_to_reg;
    wire mem_write;
    wire branch;
    wire alu_src;
    wire reg_dst;
    wire reg_write;
    wire jump;
    wire [1:0] alu_op;

    Control ControlUnit(
        .opcode(opcode),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .branch(branch),
        .alu_src(alu_src),
        .reg_dst(reg_dst),
        .reg_write(reg_write),
        .jump(jump),
        .alu_op(alu_op)
    );


    // =========================================================
    // 6. REGISTER FILE
    // =========================================================

    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    wire [4:0] write_register;
    wire [31:0] write_back_data;

    // Choose destination register:
    //
    // R-type -> rd
    // lw/addi -> rt

    assign write_register = reg_dst ? rd : rt;

    Register_file RegisterFile(
        .clk(clk),
        .read_reg_1(rs),
        .read_reg_2(rt),
        .write_reg(write_register),
        .write_data(write_back_data),
        .write_enable(reg_write),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );


    // =========================================================
    // 7. SIGN EXTEND IMMEDIATE
    // =========================================================

    wire [31:0] sign_extended;

    Sign_Extend SignExtend(
        .IN(instruction[15:0]),
        .OUT(sign_extended)
    );


    // =========================================================
    // 8. ALU CONTROL
    // =========================================================

    wire [2:0] alu_control;

    ALU_Control ALUControlUnit(
        .ALUOp(alu_op),
        .funct(funct),
        .ALUControl(alu_control)
    );


    // =========================================================
    // 9. ALU SECOND INPUT MUX
    // =========================================================

    wire [31:0] alu_input_b;

    MUX_1 ALUInputMux(
        .a(sign_extended),
        .b(read_data_2),
        .sel(alu_src),
        .c(alu_input_b)
    );


    // =========================================================
    // 10. ALU
    // =========================================================

    wire [31:0] alu_result;
    wire zero;

    ALU ALUUnit(
        .A(read_data_1),
        .B(alu_input_b),
        .ALUControl(alu_control),
        .Result(alu_result),
        .zero(zero)
    );


    // =========================================================
    // 11. DATA MEMORY
    // =========================================================

    wire [31:0] memory_read_data;

    Data_Memory DataMemory(
        .clk(clk),
        .address(alu_result),
        .write_enable(mem_write),
        .write_data(read_data_2),
        .reg_read(memory_read_data)
    );


    // =========================================================
    // 12. WRITEBACK MUX
    // =========================================================
    //
    // lw:
    //     memory data -> register
    //
    // R-type / addi:
    //     ALU result -> register

    assign write_back_data =
        mem_to_reg ? memory_read_data : alu_result;


    // =========================================================
    // 13. BRANCH ADDRESS
    // =========================================================

    wire [31:0] branch_offset;
    wire [31:0] branch_target;

    // Immediate << 2

    assign branch_offset = sign_extended << 2;

    assign branch_target = pc_plus_4 + branch_offset;


    // =========================================================
    // 14. BRANCH DECISION
    // =========================================================

    wire pc_src;

    assign pc_src = branch & zero;


    // =========================================================
    // 15. NEXT PC: NORMAL OR BRANCH
    // =========================================================

    wire [31:0] pc_after_branch;

    assign pc_after_branch =
        pc_src ? branch_target : pc_plus_4;


    // =========================================================
    // 16. JUMP ADDRESS
    // =========================================================

    wire [31:0] jump_target;

    assign jump_target = {
        pc_plus_4[31:28],
        instruction[25:0],
        2'b00
    };


    // =========================================================
    // 17. NEXT PC: BRANCH OR JUMP
    // =========================================================

    assign next_pc =
        jump ? jump_target : pc_after_branch;


endmodule