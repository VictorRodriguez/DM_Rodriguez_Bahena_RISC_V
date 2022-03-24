module imm_gen (opcode,instruction,imm);
input[6:0] opcode;
input[31:0] instruction;
output reg[31:0] imm;

// Opcodes
localparam R_TYPE 	= 7'b0110011;
localparam I_TYPE		= 7'b0010011;
localparam I_LOAD		= 7'b0000011;
localparam S_TYPE		= 7'b0100011;
localparam B_TYPE		= 7'b1100011;
localparam AUIPC		= 7'b0010111;
localparam LUI			= 7'b0110111;
localparam JAL 		= 7'b1101111;
localparam JALR 		= 7'b1100111;

always @*
	begin
	case(opcode)
		I_TYPE: imm <= instruction[31:20];
		S_TYPE: imm <= {instruction[31:25],instruction[11:7]};
		B_TYPE: imm <= {instruction[31],instruction[7],instruction[30:25],instruction[11:8],{1'b0}};
		AUIPC:  imm <= instruction[31:12];
		JAL   : imm <= {instruction[31],instruction[19:12],instruction[20],instruction[30:25],instruction[24:21],{1'b0}};
		default: imm <= 32'b0;

	endcase
	end
endmodule


