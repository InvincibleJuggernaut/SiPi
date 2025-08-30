`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 15:45:48
// Design Name: 
// Module Name: wb
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

module Write_back(
    input MemToReg,
    input [31:0] data_memory_output,
    input [31:0] alu_output,
    output [31:0] write_data
    );
    
    assign write_data = MemToReg ? data_memory_output : alu_output;
    
endmodule
