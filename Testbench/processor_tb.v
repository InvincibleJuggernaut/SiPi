`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2025 17:26:43
// Design Name: 
// Module Name: processor_tb
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


module processor_tb();

    reg reset, clk;

    //single_cycle_processor p0(.reset(reset), .clk(clk));
    //pipelined_processor p0(.reset(reset), .clk(clk));
    pipelined_HZD_FWD p0(.reset(reset), .clk(clk));

    initial begin
        clk = 1'b0;
        //reset = 1'b1; #1;
        reset = 1'b0;
        #13
        reset = 1'b1;
        #350;
        $finish;
    end

    always begin
        #10;
        clk = ~clk;
    end

endmodule

