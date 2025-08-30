`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2025 17:42:17
// Design Name: 
// Module Name: id
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


module Instruction_decode(
    input [31:0] instruction,
    output [5:0] opcode,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [31:0] sign_extended_address
    );

    assign opcode = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign sign_extended_address = {{16{instruction[15]}}, instruction[15:0]};

endmodule

module control(input [5:0] opcode,
    output reg RegDst,
    output reg Jump,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg,
    output reg [2:0] ALUOp,
    output reg ALUSrc,  //0 for r type, 1 for i type
    output reg RegWrite,
    output reg BranchEQ,
    output reg BranchNEQ,
    input disable_control
    );

    always @(*) begin
        if(disable_control != 1)
        begin
            if(opcode == 6'b100011) begin   //lw: 100011 //writeback needed
                ALUOp = 3'd0;
                MemRead = 1'b1;
                MemWrite = 1'b0;
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                Jump = 1'b0;
                MemToReg = 1'b1;
                RegDst = 1'b0;
                BranchEQ = 1'b0;
                BranchNEQ = 1'b0;
            end
            else if(opcode == 6'b101011)   begin    //sw: 101011 //no writeback
                ALUOp = 3'd0;
                MemRead = 1'b0;
                MemWrite = 1'b1;
                RegWrite = 1'b0;
                ALUSrc = 1'b1;
                Jump = 1'b0;
                MemToReg = 1'b0;
                RegDst = 1'b0; //1 = Rd 5 bits; 0 = Rt is the destination reg
                BranchEQ = 1'b0;
                BranchNEQ = 1'b0;
            end
            else if(opcode == 6'b000000)  begin //or: 000000
                ALUOp = 3'd2;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                RegWrite = 1'b1;
                ALUSrc = 1'b0;
                Jump = 1'b0;
                MemToReg = 1'b0;
                RegDst = 1'b1;
                BranchEQ = 1'b0;
                BranchNEQ = 1'b0;
            end
            else if(opcode == 6'b001100)  begin //andi: 001100
                ALUOp = 3'd1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                Jump = 1'b0;
                MemToReg = 1'b0;
                RegDst = 1'b0;
                BranchEQ = 1'b0;
                BranchNEQ = 1'b0;
            end
            else if(opcode == 6'b000010)  begin  //j: 000010
                ALUOp = 3'd3;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                RegWrite = 1'b0;
                ALUSrc = 1'b0;
                Jump = 1'b1;
                MemToReg = 1'b0;
                RegDst = 1'b1;
                BranchEQ = 1'b0;
                BranchNEQ = 1'b0;
            end
            else if(opcode == 6'b000100)  begin //branch beq
                ALUOp = 3'd3;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                RegWrite = 1'b0;
                ALUSrc = 1'b0;
                Jump = 1'b0;
                MemToReg = 1'b0;
                RegDst = 1'b0;
                BranchEQ = 1'b1;
                BranchNEQ = 1'b0;
            end
            else if(opcode == 6'b000101)  begin //bne
                ALUOp = 3'd3;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                RegWrite = 1'b0;
                ALUSrc = 1'b0;
                Jump = 1'b0;
                MemToReg = 1'b0;
                RegDst = 1'b0;
                BranchEQ = 1'b0;
                BranchNEQ = 1'b1;
            end
            else    begin
                ALUOp = 3'd2;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                RegWrite = 1'b0;
                ALUSrc = 1'b0;
                Jump = 1'b0;
                MemToReg = 1'b0;
                RegDst = 1'b1;
                BranchEQ = 1'b0;
                BranchNEQ = 1'b0;
            end
        end
        else
        begin
                ALUOp = 3'd0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                RegWrite = 1'b0;
                ALUSrc = 1'b0;
                Jump = 1'b0;
                MemToReg = 1'b0;
                RegDst = 1'b0;
                BranchEQ = 1'b0;
                BranchNEQ = 1'b0;
        end
    end

endmodule
