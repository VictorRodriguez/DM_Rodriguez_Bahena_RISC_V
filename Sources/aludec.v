module aludec(
	input  [2:0] func3,
	input  [6:0] func7,
	input  [1:0] aluop,
	input  [6:0] opcode,
	output reg[3:0] alucontrol
);

localparam AUIPC 		= 7'b0010111;
localparam B_TYPE		= 7'b1100011;
localparam I_TYPE		= 7'b0010011;


always @*
	begin
	case(aluop)
		2'b00: alucontrol <= 4'b0010; // add (for lw/sw/addi)
		2'b01: alucontrol <= 4'b0000; // andi (for beq)
		default: // R-type instructions and AUIPC
			if (opcode == AUIPC)
				alucontrol <= 4'b0100; // AUIPC
			else if (opcode == B_TYPE)
				alucontrol <= 4'b0101; // sub
			else if (opcode == I_TYPE && func3 == 'h02 )
				alucontrol <= 4'b1000; // SLTI
			else if (func3 == 'h00 && func7 == 'h00)        
				alucontrol <= 4'b0010; // add
			else if (func3 == 'h00 && func7 == 'h20)
				alucontrol <= 4'b0110; // sub
			else if (func3 == 'h01 && func7 == 'h00) 
				alucontrol <= 4'b0111; // sll
			else if (func3 == 'h00 && func7 == 'h01) 
				alucontrol <= 4'b0011; // sll
			else
				alucontrol <= 4'bxxxx; // ???
	endcase
	end
endmodule
	