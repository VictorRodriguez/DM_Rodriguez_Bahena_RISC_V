`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2021 09:22:53 PM
// Design Name: 
// Module Name: register_n
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


module register_n_addr # (parameter n = 4)(
    input [n-1:0]D,
    input clk,
    input rst,
    input load,
	 input [4:0]addr,
	 input [4:0]ref_addr,
    output [n-1:0]Q
    );
    
	 reg [n-1:0] Data_reg;
	 
    always @(posedge clk or negedge rst)
	 begin
        if (!rst)
            Data_reg <= {(n){1'b0}};
        else if (load && addr == ref_addr)
            Data_reg <= D;
	 end

assign Q = Data_reg;	 
endmodule
