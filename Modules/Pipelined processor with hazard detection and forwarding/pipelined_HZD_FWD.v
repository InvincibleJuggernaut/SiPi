`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2025 18:14:31
// Design Name: 
// Module Name: pipelined_HZD_FWD
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


module pipelined_HZD_FWD(
    input clk,
    input reset
);

// ---------- IF Stage ----------
wire [31:0] PC_correct, PC_incremented, instruction_code, PC_fetched;

Instruction_fetch IF_stage (
    .clk(clk),
    .reset(reset),
    .PC(PC_correct),        // Correct PC after jump/branch
    .Instruction_Code(instruction_code),
    .PC_increment(PC_incremented),                 // Current PC before increment
    .PC_Write(PC_Write)
);

//PC_increment pc_inc (
//    .clk(clk),
//    .reset(reset),
//    .PC(PC_fetched),
//    .PC_incremented(PC_incremented)
//);

// IF/ID Pipeline Register
wire [31:0] IFID_instruction, IFID_PC;
IF_ID if_id_reg (
    .clk(clk),
    .reset(reset),
    .instruction_in(instruction_code),
    .pc_in(PC_incremented),
    .instruction_out(IFID_instruction),
    .pc_out(IFID_PC),
    .IF_ID_Write(IF_ID_Write)
);

// ---------- ID Stage ----------
wire [5:0] opcode;
wire [4:0] rs, rt, rd;
wire [31:0] sign_ext;

Instruction_decode ID_stage (
    .instruction(IFID_instruction),
    .opcode(opcode),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .sign_extended_address(sign_ext)
);

wire RegDst, Jump, MemRead, MemWrite, MemToReg, ALUSrc, RegWrite, BranchEQ, BranchNEQ;
wire [2:0] ALUOp;

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
    .BranchEQ(BranchEQ),
    .BranchNEQ(BranchNEQ),
    .disable_control(disable_control)
);

// ID/RR Register
wire [4:0] IDRR_rs, IDRR_rt, IDRR_rd;
wire [31:0] IDRR_sign_ext;
wire [5:0] IDRR_opcode;
wire IDRR_RegDst, IDRR_Jump, IDRR_MemRead, IDRR_MemWrite, IDRR_MemToReg, IDRR_ALUSrc, IDRR_RegWrite, IDRR_BranchEQ, IDRR_BranchNEQ;
wire [2:0] IDRR_ALUOp;

ID_RR id_rr_reg (
    .clk(clk), .reset(reset),
    .rs_in(rs), .rt_in(rt), .rd_in(rd),
    .sign_ext_in(sign_ext),
    .opcode_in(opcode),
    .RegDst_in(RegDst), .Jump_in(Jump), .MemRead_in(MemRead),
    .MemWrite_in(MemWrite), .MemToReg_in(MemToReg), .ALUOp_in(ALUOp),
    .ALUSrc_in(ALUSrc), .RegWrite_in(RegWrite), .BranchEQ_in(BranchEQ), .BranchNEQ_in(BranchNEQ),
    .rs_out(IDRR_rs), .rt_out(IDRR_rt), .rd_out(IDRR_rd),
    .sign_ext_out(IDRR_sign_ext), .opcode_out(IDRR_opcode),
    .RegDst_out(IDRR_RegDst), .Jump_out(IDRR_Jump), .MemRead_out(IDRR_MemRead),
    .MemWrite_out(IDRR_MemWrite), .MemToReg_out(IDRR_MemToReg), .ALUOp_out(IDRR_ALUOp),
    .ALUSrc_out(IDRR_ALUSrc), .RegWrite_out(IDRR_RegWrite), .BranchEQ_out(IDRR_BranchEQ), .BranchNEQ_out(IDRR_BranchNEQ)
    //.ID_RR_Write(ID_RR_Write)
);

// ---------- RR Stage ----------
wire [31:0] read_data_1, read_data_2;
wire [4:0] write_reg_WB;
wire [31:0] write_data_WB;
wire RegWrite_WB;

Read_register reg_file (
    .clk(clk),
    .reset(reset),
    .read_register_1(IDRR_rs),
    .read_register_2(IDRR_rt),
    .write_register(write_reg_WB),
    .write_data(write_data_WB),
    .read_data_1(read_data_1),
    .read_data_2(read_data_2),
    .RegWrite(RegWrite_WB)
);

// RR/EX
wire [31:0] RREX_rd1, RREX_rd2, RREX_sign_ext;
wire [4:0] RREX_rs, RREX_rt, RREX_rd;
wire RREX_RegDst, RREX_MemRead, RREX_MemWrite, RREX_MemToReg, RREX_ALUSrc, RREX_RegWrite, RREX_BranchEQ, RREX_BranchNEQ;
wire [2:0] RREX_ALUOp;

RR_EX rr_ex_reg (
    .clk(clk), .reset(reset),
    .read_data_1_in(read_data_1),
    .read_data_2_in(read_data_2),
    .sign_ext_in(IDRR_sign_ext),
    .rs_in(IDRR_rs), .rt_in(IDRR_rt), .rd_in(IDRR_rd),
    .RegDst_in(IDRR_RegDst), .MemRead_in(IDRR_MemRead),
    .MemWrite_in(IDRR_MemWrite), .MemToReg_in(IDRR_MemToReg),
    .ALUOp_in(IDRR_ALUOp), .ALUSrc_in(IDRR_ALUSrc),
    .RegWrite_in(IDRR_RegWrite), .BranchEQ_in(IDRR_BranchEQ), .BranchNEQ_in(IDRR_BranchNEQ),
    .read_data_1_out(RREX_rd1), .read_data_2_out(RREX_rd2),
    .sign_ext_out(RREX_sign_ext),
    .rs_out(RREX_rs), .rt_out(RREX_rt), .rd_out(RREX_rd),
    .RegDst_out(RREX_RegDst), .MemRead_out(RREX_MemRead),
    .MemWrite_out(RREX_MemWrite), .MemToReg_out(RREX_MemToReg),
    .ALUOp_out(RREX_ALUOp), .ALUSrc_out(RREX_ALUSrc),
    .RegWrite_out(RREX_RegWrite), .BranchEQ_out(RREX_BranchEQ), .BranchNEQ_out(RREX_BranchNEQ)
);

// ---------- EX Stage ----------
wire [3:0] alu_control_code;
wire [31:0] alu_operand_B, alu_result;
wire [4:0] write_register_EX;
wire zero_flag;

alu_control alu_ctrl (
    .function_field(RREX_sign_ext[5:0]),
    .ALUOp(RREX_ALUOp),
    .alu_operation_select(alu_control_code)
);

Execution_source_mux ex_src_mux (
    .read_data_2(forwardB_result),
    .sign_extended_address(RREX_sign_ext),
    .ALUSrc(RREX_ALUSrc),
    .execution_second_operand(alu_operand_B)
);

Execution ex_unit (
    .A(forwardA_result),
    .B(alu_operand_B),
    .control(alu_control_code),
    .result(alu_result),
    .zero_indicator(zero_flag)
);

Memory_source_mux mem_src_mux (
    .instruction_rs(RREX_rt),
    .instruction_rt(RREX_rd),
    .RegDst(RREX_RegDst),
    .write_register(write_register_EX)
);

wire [31:0] resolved_address;
Address_calculator addr_calc (
    .current_PC(IFID_PC),
    .sign_extended_address(RREX_sign_ext),
    .resolved_address(resolved_address)
);

wire PCSrc_EX;
assign PCSrc_EX = (RREX_BranchEQ & zero_flag) | (RREX_BranchNEQ & (~zero_flag));

wire [31:0] PC_mux_out;
PC_source_mux PC_mux_one (
    .PC(PC_incremented),                   // From PC_increment
    .PC_address_resolved(resolved_address),
    .PCSrc(PCSrc_EX),
    .PC_current(PC_mux_out)
);

PC_source_mux_two PC_mux_two (
    .PC(PC_mux_out),
    .PC_msb_4(PC_incremented[31:28]),
    .jump_address_resolved(IFID_instruction[25:0]),
    //.Jump(IDRR_Jump),
    .Jump(Jump),
    .PC_correct(PC_correct)
);

// ---------- EX/MEM ----------
wire [31:0] alu_result_MEM, write_data_MEM;
wire [4:0] write_reg_MEM;
wire zero_MEM;
wire MEM_MemRead, MEM_MemWrite, MEM_MemToReg, MEM_RegWrite, MEM_BranchEQ, MEM_BranchNEQ;

EX_MEM ex_mem_reg (
    .clk(clk), .reset(reset),
    .alu_result_in(alu_result),
    .write_data_in(forwardB_result),
    .write_reg_in(write_register_EX),
    .zero_in(zero_flag),
    .MemRead_in(RREX_MemRead), .MemWrite_in(RREX_MemWrite),
    .MemToReg_in(RREX_MemToReg), .RegWrite_in(RREX_RegWrite), .BranchEQ_in(RREX_BranchEQ), .BranchNEQ_in(RREX_BranchNEQ),
    .alu_result_out(alu_result_MEM),
    .write_data_out(write_data_MEM),
    .write_reg_out(write_reg_MEM),
    .zero_out(zero_MEM),
    .MemRead_out(MEM_MemRead), .MemWrite_out(MEM_MemWrite),
    .MemToReg_out(MEM_MemToReg), .RegWrite_out(MEM_RegWrite), .BranchEQ_out(MEM_BranchEQ), .BranchNEQ_out(MEM_BranchNEQ)
);

// ---------- MEM Stage ----------
wire [31:0] read_data_MEM;

Memory mem_stage (
    .clk(clk), .reset(reset),
    .address(alu_result_MEM),
    .write_data(write_data_MEM),
    .MemRead(MEM_MemRead),
    .MemWrite(MEM_MemWrite),
    .read_data(read_data_MEM)
);

// ---------- MEM/WB ----------
wire [31:0] read_data_WB, alu_result_WB;
wire [4:0] write_reg_WB_internal;
wire MemToReg_WB;

MEM_WB mem_wb_reg (
    .clk(clk), .reset(reset),
    .read_data_in(read_data_MEM),
    .alu_result_in(alu_result_MEM),
    .write_reg_in(write_reg_MEM),
    .MemToReg_in(MEM_MemToReg),
    .RegWrite_in(MEM_RegWrite),
    .read_data_out(read_data_WB),
    .alu_result_out(alu_result_WB),
    .write_reg_out(write_reg_WB),
    .MemToReg_out(MemToReg_WB),
    .RegWrite_out(RegWrite_WB)
);

// ---------- WB Stage ----------
Write_back WB_stage (
    .MemToReg(MemToReg_WB),
    .data_memory_output(read_data_WB),
    .alu_output(alu_result_WB),
    .write_data(write_data_WB)
);

wire PC_Write, IF_ID_Write, ID_RR_Write, disable_control; 

hazard_detection_unit hzd(
    .ID_EX_MemRead(IDRR_MemRead), //rr_ex_MemRead
    .ID_EX_Rt(IDRR_rt),      //rr_ex_Rt
    .IF_ID_Rs(IFID_instruction[25:21]), //id_rr_rs
    .IF_ID_Rt(IFID_instruction[20:16]), //id_rr_rt
    .PC_Write(PC_Write),
    .IF_ID_Write(IF_ID_Write),
    //.ID_RR_Write(ID_RR_Write),
    .disable_control(disable_control) //made as a control signal to control unit
    );
    
wire [1:0] forwardA, forwardB;
wire ex_hzd, mem_hzd;

forwarding_unit fwd_unit(
    .EX_MEM_RegWrite(MEM_RegWrite),
    .EX_MEM_Rd(write_reg_MEM),
    .ID_EX_Rs(RREX_rs),
    .ID_EX_Rt(RREX_rt),
    .MEM_WB_RegWrite(RegWrite_WB),
    .MEM_WB_Rd(write_reg_WB),
    .forwardA(forwardA),
    .forwardB(forwardB),
    .ex_hzd(ex_hzd),
    .mem_hzd(mem_hzd)
);

wire [31:0] forwardA_result, forwardB_result;

forwardA_mux fwdA_mux (
    .id_ex_operand(RREX_rd1),
    .mem_wb_result(write_data_WB),
    .ex_mem_result(alu_result_MEM),
    .select_line(forwardA),
    .forwardA_result(forwardA_result)
);

forwardB_mux fwdB_mux (
    .id_ex_operand(RREX_rd2),
    .mem_wb_result(write_data_WB),
    .ex_mem_result(alu_result_MEM),
    .select_line(forwardB),
    .forwardB_result(forwardB_result)
);

endmodule

module IF_ID (
    input wire clk,
    input wire reset,
    input wire [31:0] instruction_in,
    input wire [31:0] pc_in,
    output reg [31:0] instruction_out,
    output reg [31:0] pc_out,
    input IF_ID_Write
);

always @(posedge clk) begin
    if (reset == 0) begin
        instruction_out <= 32'b0;
        pc_out <= 32'b0;
    end else begin
        if(IF_ID_Write != 0)
        begin
            instruction_out <= instruction_in;
            pc_out <= pc_in;
        end
    end
end

endmodule

module ID_RR (
    input wire clk,
    input wire reset,
    input wire [4:0] rs_in, rt_in, rd_in,
    input wire [31:0] sign_ext_in,
    input wire [5:0] opcode_in,
    input wire RegDst_in, Jump_in, MemRead_in, MemWrite_in, MemToReg_in,
    input wire [2:0] ALUOp_in,
    input wire ALUSrc_in, RegWrite_in, BranchEQ_in, BranchNEQ_in,
    output reg [4:0] rs_out, rt_out, rd_out,
    output reg [31:0] sign_ext_out,
    output reg [5:0] opcode_out,
    output reg RegDst_out, Jump_out, MemRead_out, MemWrite_out, MemToReg_out,
    output reg [2:0] ALUOp_out,
    output reg ALUSrc_out, RegWrite_out, BranchEQ_out, BranchNEQ_out
);

always @(posedge clk) begin
    if (reset == 0) begin
        rs_out <= 0; rt_out <= 0; rd_out <= 0;
        sign_ext_out <= 0; opcode_out <= 0;
        RegDst_out <= 0; Jump_out <= 0; MemRead_out <= 0;
        MemWrite_out <= 0; MemToReg_out <= 0; ALUOp_out <= 0;
        ALUSrc_out <= 0; RegWrite_out <= 0; BranchEQ_out <= 0; BranchNEQ_out <= 0;
    end else begin
        rs_out <= rs_in; rt_out <= rt_in; rd_out <= rd_in;
        sign_ext_out <= sign_ext_in; opcode_out <= opcode_in;
        RegDst_out <= RegDst_in; Jump_out <= Jump_in; MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in; MemToReg_out <= MemToReg_in; ALUOp_out <= ALUOp_in;
        ALUSrc_out <= ALUSrc_in; RegWrite_out <= RegWrite_in; BranchEQ_out <= BranchEQ_in; BranchNEQ_out <= BranchNEQ_in;
    end
end

endmodule

module RR_EX (
    input wire clk,
    input wire reset,
    input wire [31:0] read_data_1_in, read_data_2_in, sign_ext_in,
    input wire [4:0] rs_in, rt_in, rd_in,
    input wire RegDst_in, MemRead_in, MemWrite_in, MemToReg_in,
    input wire [2:0] ALUOp_in,
    input wire ALUSrc_in, RegWrite_in, BranchEQ_in, BranchNEQ_in,
    output reg [31:0] read_data_1_out, read_data_2_out, sign_ext_out,
    output reg [4:0] rs_out, rt_out, rd_out,
    output reg RegDst_out, MemRead_out, MemWrite_out, MemToReg_out,
    output reg [2:0] ALUOp_out,
    output reg ALUSrc_out, RegWrite_out, BranchEQ_out, BranchNEQ_out
);

always @(posedge clk) begin
    if (reset == 0) begin
        read_data_1_out <= 0; read_data_2_out <= 0; sign_ext_out <= 0;
        rs_out <= 0; rt_out <= 0; rd_out <= 0;
        RegDst_out <= 0; MemRead_out <= 0; MemWrite_out <= 0;
        MemToReg_out <= 0; ALUOp_out <= 0; ALUSrc_out <= 0;
        RegWrite_out <= 0; BranchEQ_out <= 0; BranchNEQ_out <= 0;
    end else begin
        read_data_1_out <= read_data_1_in;
        read_data_2_out <= read_data_2_in;
        sign_ext_out <= sign_ext_in;
        rs_out <= rs_in; rt_out <= rt_in; rd_out <= rd_in;
        RegDst_out <= RegDst_in; MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in; MemToReg_out <= MemToReg_in;
        ALUOp_out <= ALUOp_in; ALUSrc_out <= ALUSrc_in;
        RegWrite_out <= RegWrite_in; BranchEQ_out <= BranchEQ_in; BranchNEQ_out <= BranchNEQ_in;
    end
end

endmodule

module EX_MEM (
    input wire clk,
    input wire reset,
    input wire [31:0] alu_result_in, write_data_in,
    input wire [4:0] write_reg_in,
    input wire zero_in,
    input wire MemRead_in, MemWrite_in, MemToReg_in, RegWrite_in, BranchEQ_in, BranchNEQ_in,
    output reg [31:0] alu_result_out, write_data_out,
    output reg [4:0] write_reg_out,
    output reg zero_out,
    output reg MemRead_out, MemWrite_out, MemToReg_out, RegWrite_out, BranchEQ_out, BranchNEQ_out
);

always @(posedge clk) begin
    if (reset == 0) begin
        alu_result_out <= 0; write_data_out <= 0;
        write_reg_out <= 0; zero_out <= 0;
        MemRead_out <= 0; MemWrite_out <= 0;
        MemToReg_out <= 0; RegWrite_out <= 0; BranchEQ_out <= 0; BranchNEQ_out <= 0;
    end else begin
        alu_result_out <= alu_result_in;
        write_data_out <= write_data_in;
        write_reg_out <= write_reg_in;
        zero_out <= zero_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        MemToReg_out <= MemToReg_in;
        RegWrite_out <= RegWrite_in;
        BranchEQ_out <= BranchEQ_in;
        BranchNEQ_out <= BranchNEQ_in;
    end
end

endmodule

module MEM_WB (
    input wire clk,
    input wire reset,
    input wire [31:0] read_data_in, alu_result_in,
    input wire [4:0] write_reg_in,
    input wire MemToReg_in, RegWrite_in,
    output reg [31:0] read_data_out, alu_result_out,
    output reg [4:0] write_reg_out,
    output reg MemToReg_out, RegWrite_out
);

always @(posedge clk) begin
    if (reset == 0) begin
        read_data_out <= 0; alu_result_out <= 0;
        write_reg_out <= 0; MemToReg_out <= 0; RegWrite_out <= 0;
    end else begin
        read_data_out <= read_data_in;
        alu_result_out <= alu_result_in;
        write_reg_out <= write_reg_in;
        MemToReg_out <= MemToReg_in;
        RegWrite_out <= RegWrite_in;
    end
end

endmodule