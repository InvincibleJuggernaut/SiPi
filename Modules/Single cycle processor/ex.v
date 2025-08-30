`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2025 16:42:19
// Design Name: 
// Module Name: ex
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


module Execution(
    input [31:0] A, [31:0] B,
    input [2:0] control,
    output reg [31:0] result,
    output reg zero_indicator
    );
    
    always @(*)
    begin
        case(control)
            3'd2: result = A & B;
            3'd0: result = A + B;
            3'd1: result = A | B;
            3'd3: result = A - B;
            default: result = 31'b0;
        endcase
        zero_indicator = result ? 1'b0 : 1'b1;   
    end
    
endmodule

module Address_calculator(
    input [31:0] current_PC,
    input [31:0] sign_extended_address,
    output reg [31:0] resolved_address
    );
    
    always @(*)
    begin
         resolved_address = {{16{sign_extended_address[15]}}, (sign_extended_address[15:0] << 2)} +  current_PC;
    end

endmodule

module Execution_source_mux(input [31:0] read_data_2,
    input [31:0] sign_extended_address,
    input ALUSrc,
    output [31:0] execution_second_operand
    );
    
    assign execution_second_operand = ALUSrc ? sign_extended_address : read_data_2;
    
endmodule

module Memory_source_mux(input [4:0] instruction_rs,
    input [4:0] instruction_rt,
    input RegDst,
    output [4:0] write_register
    );
    
    assign write_register = RegDst ? instruction_rt : instruction_rs;
    
endmodule

module alu_control(input [5:0] function_field,
    input [2:0] ALUOp,
    output reg [3:0] alu_operation_select
    );
    
    always@(*)
    begin
        if(ALUOp == 3'd2)
        begin
            case (function_field)
                6'b100101: alu_operation_select = 3'd1;
                default: alu_operation_select = 3'd0;
            endcase
        end
        else if(ALUOp == 3'd0)
            alu_operation_select = 3'd0;
        else if(ALUOp == 3'd1)
            alu_operation_select = 3'd2;
        else if(ALUOp == 3'd3)
            alu_operation_select = 3'd3;    
    end
    
endmodule

module PC_source_mux(input [31:0] PC,
    input [31:0] PC_address_resolved,
    input PCSrc,
    output reg [31:0] PC_current
    );
    
    always @(*)
    begin
        if(PCSrc === 1) //Checking for bitwise equaluity with value 1
        begin
            PC_current = PC_address_resolved;
            //$display($time, "ONE");
        end
        else
        begin
            PC_current = PC;
            //$display($time, "TWO");
        end
    end
        
endmodule

module PC_source_mux_two(input [31:0] PC,
    input [3:0] PC_msb_4,
    input [25:0] jump_address_resolved,
    input Jump,
    output reg [31:0] PC_correct
    );
    
    always @(*)
    begin
        if(Jump === 1) //Checking for bitwise equaluity with value 1
        begin
            PC_correct = ({PC_msb_4,(jump_address_resolved << 2)});
            //$display($time, "THREE");
        end
        else
        begin
            PC_correct = PC;
            //$display($time, "FOUR");
        end
    end
        
endmodule