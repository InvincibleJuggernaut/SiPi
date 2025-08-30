`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2025 16:43:21
// Design Name: 
// Module Name: rr
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

module Read_register(
    input clk, input reset,
    input [4:0] read_register_1,
    input [4:0] read_register_2,
    input [4:0] write_register,
    input [31:0] write_data,
    output [31:0] read_data_1,
    output [31:0] read_data_2,
    input RegWrite
    );
    
    reg [31:0] register_file [31:0];
    integer i;
    
    always @(negedge reset)
        begin
            for(i=0; i<32; i=i+1)   begin
                register_file[i] <= i;
            end
        end
        
    always @(posedge clk)
        begin
            if(RegWrite && write_register != 0)    begin
                register_file[write_register] <= write_data;
            end
        end
//    always @(negedge clk)
//        begin
//            read_data_1 = register_file[read_register_1];
//            read_data_2 = register_file[read_register_2];
//        end

    //read made combinational because of 1 cycle lag between Jump signal being raised and Branch.
    assign read_data_1 = register_file[read_register_1];
    assign read_data_2 = register_file[read_register_2];
    
endmodule