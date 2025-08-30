`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 15:50:26
// Design Name: 
// Module Name: single_cycle_processor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_cycle_processor(input clk,
    input reset
    );

    wire [31:0] PC_current;
    wire [31:0] PC_to_be_incremented;
    
    wire [31:0] PC, PC_correct;
    wire [31:0] instruction_code;
    
    // Instruction decode outputs
    wire [5:0] opcode;
    wire [4:0] rs, rt, rd;
    wire [31:0] sign_extended_address;
    //wire [27:0] jump_address_shift;
    wire Jump_ID;  // renamed to avoid conflict with control Jump
    wire Branch;

    // Control signals
    wire RegDst, Jump, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite;
    wire [2:0] ALUOp;

    // Register file wires
    wire [4:0] read_register_1, read_register_2, write_register, destination_register, destination_write_register;
    wire [31:0] write_data, read_data_1, read_data_2;

    // Execution stage wires
    wire [31:0] A, B, execution_second_operand, result;
    wire zero_indicator;
    wire alu_operand_select;
    wire [3:0] alu_operation_select;

    // Address calculator
    wire [31:0] current_PC, resolved_address;

    // Memory wires
    wire [4:0] instruction_rs, instruction_rt;  // for Memory_source_mux
    wire [4:0] write_register_mem;
    wire [31:0] data_memory_output, alu_output;

    // For Memory module
    wire [4:0] address;
    wire MemRead_mem, MemWrite_mem;
    wire [31:0] read_data;

    // Connect PC_source_mux control signal
    wire PCSrc;
    
    assign PCSrc = Branch & zero_indicator;
    
Instruction_fetch IF_stage (
    .clk(clk),
    .reset(reset),
    .PC_current(PC_correct),
    .Instruction_Code(instruction_code),
    .PC(PC_to_be_incremented)
);

PC_increment pc_inc(
    .PC(PC_to_be_incremented),
    .PC_incremented(PC_current)
);
    
PC_source_mux PC_mux_one (
    .PC(PC_current),
    .PC_address_resolved(resolved_address),
    .PCSrc(PCSrc),
    .PC_current(PC)
);

PC_source_mux_two PC_mux_two(
    .PC(PC),
    .PC_msb_4(PC_current[31:28]),
    .jump_address_resolved(instruction_code[25:0]),
    .Jump(Jump),
    .PC_correct(PC_correct)
    );

Instruction_decode ID_stage (
    .instruction(instruction_code),
    .opcode(opcode),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .sign_extended_address(sign_extended_address)
    //.current_PC(PC_current),
    //.jump_address_shift(jump_address_shift)
);

control control_unit (
    .opcode(opcode),
    .RegDst(RegDst),
    .Jump(Jump),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemToReg(MemToReg),
    .ALUOp(ALUOp),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .Branch(Branch)
);

Read_register reg_file (
    .clk(clk),
    .reset(reset),
    .read_register_1(rs),
    .read_register_2(rt),
    .write_register(write_register),
    .write_data(write_data),
    .read_data_1(read_data_1),
    .read_data_2(read_data_2),
    .RegWrite(RegWrite)
);

Execution EX_stage (
    .A(read_data_1),
    .B(execution_second_operand),
    .control(alu_operation_select),
    .result(result),
    .zero_indicator(zero_indicator)
);

Address_calculator addr_calc (
    .current_PC(PC_current),
    .sign_extended_address(sign_extended_address),
    .resolved_address(resolved_address)
);

Execution_source_mux EX_src_mux (
    .read_data_2(read_data_2),
    .sign_extended_address(sign_extended_address),
    .ALUSrc(ALUSrc),
    .execution_second_operand(execution_second_operand)
);

Memory_source_mux mem_src_mux (
    .instruction_rs(rt),
    .instruction_rt(rd),
    .RegDst(RegDst),
    .write_register(write_register)
);

alu_control alu_ctrl (
    .function_field(sign_extended_address[5:0]),
    .ALUOp(ALUOp),
    .alu_operation_select(alu_operation_select)
);

Memory memory_unit (
    .clk(clk),
    .reset(reset),
    .address(result),
    .write_data(read_data_2),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .read_data(read_data)
);

Write_back WB_stage (
    .MemToReg(MemToReg),
    .data_memory_output(read_data),
    .alu_output(result),
    .write_data(write_data)
);

endmodule
