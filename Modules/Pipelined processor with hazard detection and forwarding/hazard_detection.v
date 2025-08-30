`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2025 17:39:23
// Design Name: 
// Module Name: hazard_detection
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


module hazard_detection_unit(input ID_EX_MemRead,
    input [4:0] ID_EX_Rt,
    input [4:0] IF_ID_Rs,
    input [4:0] IF_ID_Rt,
    output reg PC_Write,
    output reg IF_ID_Write,
    output reg disable_control
    );
    
    always @(*)
    begin
        if((ID_EX_MemRead === 1) && ((ID_EX_Rt === IF_ID_Rs) || (ID_EX_Rt === IF_ID_Rt)))
        begin
            PC_Write = 0;
            IF_ID_Write = 0;
            disable_control = 1;
        end
        else
        begin
            PC_Write = 1;
            IF_ID_Write = 1;
            disable_control = 0;
        end
    end
    
endmodule

module forwarding_unit(input EX_MEM_RegWrite,
    input [4:0] EX_MEM_Rd,
    input [4:0] ID_EX_Rs,
    input [4:0] ID_EX_Rt,
    input MEM_WB_RegWrite,
    input [4:0] MEM_WB_Rd,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB,
    output reg ex_hzd,
    output reg mem_hzd
    );
    
    always @(*)
    begin
        forwardA = 2'b00;
        forwardB = 2'b00;
        ex_hzd = 1'b0;
        mem_hzd = 1'b0;
        
        // EX hazard
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 0)) begin
            if (EX_MEM_Rd == ID_EX_Rs)
                forwardA = 2'b10;
                ex_hzd = 1'b1;
            if (EX_MEM_Rd == ID_EX_Rt)
                forwardB = 2'b10;
                ex_hzd = 1'b1; 
        end
    
        // MEM hazard
        if (MEM_WB_RegWrite && (MEM_WB_Rd != 0)) begin
            if ((forwardA == 2'b00) && (MEM_WB_Rd == ID_EX_Rs))
                forwardA = 2'b01;
                mem_hzd = 1'b1;
            if ((forwardB == 2'b00) && (MEM_WB_Rd == ID_EX_Rt))
                forwardB = 2'b01;
                mem_hzd = 1'b1;
        end
    end
  
endmodule

module forwardA_mux(input [31:0] id_ex_operand,
    input [31:0] mem_wb_result,
    input [31:0] ex_mem_result,
    input [1:0] select_line,
    output reg [31:0] forwardA_result
    );
    
    always @(*)
    begin
        case(select_line)
            2'b00: forwardA_result = id_ex_operand;
            2'b01: forwardA_result = mem_wb_result;
            2'b10: forwardA_result = ex_mem_result;
            default: forwardA_result = id_ex_operand;
        endcase
    end
    
endmodule

module forwardB_mux(input [31:0] id_ex_operand,
    input [31:0] mem_wb_result,
    input [31:0] ex_mem_result,
    input [1:0] select_line,
    output reg [31:0] forwardB_result
    );
    
    always @(*)
    begin
        case(select_line)
            2'b00: forwardB_result = id_ex_operand;
            2'b01: forwardB_result = mem_wb_result;
            2'b10: forwardB_result = ex_mem_result;
            default: forwardB_result = id_ex_operand;
        endcase
    end
    
endmodule