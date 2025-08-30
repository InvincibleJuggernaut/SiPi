`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 15:29:45
// Design Name: 
// Module Name: mem
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


module Memory(
    input clk, input reset,
    input [31:0] address,
    input [31:0] write_data,
    input MemRead,
    input MemWrite,    
    output [31:0] read_data
    );
    
    reg [7:0] Data_Mem [31:0];
    integer i;
    
    assign read_data = {Data_Mem[address], Data_Mem[address+1], Data_Mem[address+2], Data_Mem[address+3]};
        
    always @(posedge clk)   
    begin
        if (reset == 0)  begin
                for(i=0; i<32; i=i+1)   begin
                    if(i == 10)
                        Data_Mem[10] <= 8'd25;
                    else
                        Data_Mem[i] <= i;  
                end
            end
        else
        begin
            if(MemWrite)
            begin
                {Data_Mem[address],Data_Mem[address+1], Data_Mem[address+2], Data_Mem[address+3]} <= write_data;
            end
        end
    end 
       
endmodule

