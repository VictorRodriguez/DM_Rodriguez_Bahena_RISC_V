module sign_extend_riscv (opcode,extend,extended);
input[6:0] opcode;
input[31:0] extend;
output reg[31:0] extended;

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
		I_TYPE: extended <= { {20{extend[11]}}, extend[11:0] };
		S_TYPE: extended <= { {20{extend[11]}}, extend[11:0] };
		B_TYPE: extended <= { {20{extend[11]}}, extend[11:0] };
		AUIPC:  extended <= { {12{extend[19]}}, extend[19:0] };
		JAL:    extended <= { {12{extend[19]}}, extend[19:0] };
		default: extended <= 32'b0;

	endcase
	end
endmodule


