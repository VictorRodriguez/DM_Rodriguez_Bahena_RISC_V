module maindec(
	input [6:0] opcode,
	input [2:0] func3,
	output ALUSrcA,
	output [1:0]MemtoReg,
	output MemWrite,
	output Branch,
	output ALUSrc,
	output RegDst,
	output RegWrite,
	output [1:0] Jump,
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

reg [11:0] controls;

assign ALUSrcA 			= controls[11];
assign RegWrite 			= controls[10];
assign RegDst 				= controls[9];
assign ALUSrc 				= controls[8];
assign Branch 				= controls[7];
assign MemWrite 			= controls[6];
assign MemtoReg[1:0] 	= controls[5:4];
assign Jump [1:0] 		= controls[3:2];
assign ALUOp[1:0] 		= controls [1:0];

always @*
	begin
		if (opcode == I_LOAD )
			controls <= 12'b110100_00_00_00; // LW
		else if (opcode == S_TYPE )
			controls <= 12'b110101_00_00_00; // SW
		else if (opcode == R_TYPE)  
			controls <= 12'b111000_01_00_10; // Rtype
      else if (opcode == I_TYPE && func3 == ADDI_FUNC3)
			controls <= 12'b110100_01_00_00; // ADDI_EXECUTE
      else if (opcode == I_TYPE && func3 == ANDI_FUNC3)
			controls <= 12'b111100_01_00_01; // ANDI_EXECUTE
      else if (opcode == I_TYPE && func3 == SLLI_FUNC3)
			controls <= 12'b111100_01_00_10; // SLLI_EXECUTE
      else if (opcode == I_TYPE && func3 == SLTI_FUNC3)
			controls <= 12'b111100_01_00_10; // SLTI_EXECUTE
      else if (opcode == AUIPC)
			controls <= 12'b010100_01_00_10; // AUICP_EXECUTE
		else if (opcode == B_TYPE && func3 == BEQ_FUNC3)
			controls <= 12'b100010_01_00_10; // BEQ_EXECUTE
		else if (opcode == B_TYPE && func3 == BNE_FUNC3)
			controls <= 12'b100010_01_00_10; // BNEQ_EXECUTE
		else if (opcode == JAL)
			controls <= 12'b010000_10_01_00; // JAL_EXECUTE
		else if (opcode == JALR)
			controls <= 12'b110000_10_10_00; // JALR_EXECUTE
		else
			controls <= 12'b000000_00_00_00; // HALT
	end
endmodule
