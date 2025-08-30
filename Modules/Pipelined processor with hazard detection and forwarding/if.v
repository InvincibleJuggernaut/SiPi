`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2025 16:45:33
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

module Instruction_fetch(
    input clk, input reset,
    input [31:0] PC,
    output [31:0] Instruction_Code,
    output reg [31:0] PC_increment,
    input PC_Write
    );
    
    reg [31:0] Mem [31:0];   
    assign Instruction_Code = Mem[PC];

    always @(posedge clk, negedge reset)
    begin
        if (reset == 0)  
        begin
            PC_increment <= 0;
            Mem[0] = 32'b100011_00010_00001_0000000000001010;
            Mem[1] = 32'b101011_00011_00001_0000000000000101;
            Mem[2] = 32'b000000_00101_00011_00010_00000_100101;
            Mem[3] = 32'b000000_00110_00111_00001_00000_100101;
            Mem[4] = 32'b001100_00011_00001_0000000000001010;
            Mem[5] = 32'b000100_01000_01000_00000000_00000110; //branch to 31st location
            Mem[6] = 32'b000101_01000_11000_00000000_00000110; //bne
            Mem[31] = 32'b000010_00000000000000000000000000; //J to 0th location

        end
        else    
        begin
            if(PC_Write !== 0)
                PC_increment <= PC+1;
        end
    end
    
endmodule

module PC_increment(input clk,
    input reset,
    input [31:0] PC,
    output reg [31:0] PC_incremented
    );
    
    always @(posedge clk)
    begin
        if(!reset)
            PC_incremented <= 32'b0;
        else
            PC_incremented <= PC + 1;
    end
    
endmodule