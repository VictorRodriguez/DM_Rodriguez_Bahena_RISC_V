`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Victor Rodriguez
// Design Name: Register of N bits
// Module Name: register_n
//////////////////////////////////////////////////////////////////////////////////


module register_n # (parameter n = 4)(
    input [n-1:0]D,
    input clk,
    input rst,
    input load,
    output [n-1:0]Q
    );
    
	 reg [n-1:0] Data_reg;
	 
    always @(posedge clk or negedge rst)
	 begin
        if (!rst)
            Data_reg <= {(n){1'b0}};
        else if (load)
            Data_reg <= D;
	 end

assign Q = Data_reg;	 
endmodule
