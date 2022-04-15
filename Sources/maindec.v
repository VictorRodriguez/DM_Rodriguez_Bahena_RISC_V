module maindec(
	input [6:0] opcode,
	input [2:0] func3,
	output ALUSrcA,
	output MemtoReg,
	output MemWrite,
	output Branch,
	output ALUSrc,
	output RegDst,
	output RegWrite,
	output Jump,
	output [1:0] ALUOp
);
	
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

// Func3
localparam ADDI_FUNC3 = 3'b000;
localparam ANDI_FUNC3 = 3'b111;
localparam SLLI_FUNC3 = 3'b001;
localparam SLTI_FUNC3 = 3'b010;
localparam BEQ_FUNC3  = 3'b000;
localparam BNE_FUNC3  = 3'b001;

reg [9:0] controls;

assign ALUSrcA 	= controls[9];
assign RegWrite 	= controls[8];
assign RegDst 		= controls[7];
assign ALUSrc 		= controls[6];
assign Branch 		= controls[5];
assign MemWrite 	= controls[4];
assign MemtoReg 	= controls[3];
assign Jump 		= controls[2];
assign ALUOp[1:0] = controls [1:0];

always @*
	begin
		if (opcode == I_LOAD || opcode == S_TYPE)
			controls <= 10'b1101000000; // LW/SW
		else if (opcode == R_TYPE)  
			controls <= 10'b1110001010; // Rtype
      else if (opcode == I_TYPE && func3 == ADDI_FUNC3)
			controls <= 10'b1101001000; // ADDI_EXECUTE
      else if (opcode == I_TYPE && func3 == ANDI_FUNC3)
			controls <= 10'b1110001001; // ANDI_EXECUTE
      else if (opcode == I_TYPE && func3 == SLLI_FUNC3)
			controls <= 10'b1110000010; // SLLI_EXECUTE
      else if (opcode == I_TYPE && func3 == SLTI_FUNC3)
			controls <= 10'b1110000010; // SLTI_EXECUTE
      else if (opcode == AUIPC)
			controls <= 10'b0101001010; // AUICP_EXECUTE
		else if (opcode == B_TYPE && func3 == BEQ_FUNC3)
			controls <= 10'b0000100001; // BEQ_EXECUTE
		else if (opcode == B_TYPE && func3 == BNE_FUNC3)
			controls <= 10'b0000100001; // BNEQ_EXECUTE
		else if (opcode == JAL)
			controls <= 10'b0000000100; // JAL_EXECUTE
		else if (opcode == JALR)
			controls <= 10'b0000000100; // JALR_EXECUTE
		else
			controls <= 10'b0000000000; // HALT
	end
endmodule
