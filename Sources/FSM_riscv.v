`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITESO
// Engineer: Victor Rodriguez
// Finite State Machine to control a MIPS Data path
////////////////////////////////////////////////////////////////////////////////////

module FSM_riscv(
	// Multiplexer Selects
	output reg MemtoReg,
	output reg RegDst,
	output reg IorD,
	output reg PCSrc,
	output reg [1:0]ALUSrcB,
	output reg [1:0]ALUSrcA,

	// Register Enables
	output reg IRWrite,
	output reg MemWrite,
	output reg PCWrite,
	output reg RegWrite,
	output reg PCWriteCond,
	output reg PCWriteCond_NE,


	// ALU control system
	output reg [1:0] ALUOp,

	// clk and rst
	input clk,
	input rst,

	// opcode and func
	input [6:0]opcode,
	input [2:0]func3,
	input [6:0]func7

);

// States
localparam 	FETCH 				= 5'b00000; //0
localparam 	DECODE 				= 5'b00001; //1
localparam 	MEM_ADR				= 5'b00010; //2
localparam 	MEM_READ				= 5'b00011; //3
localparam  MEM_WRITE_BACK		= 5'b00100; //4
localparam 	MEM_WRITE			= 5'b00101; //5
localparam  EXECUTE				= 5'b00110; //6
localparam  ALU_WRITE_BACK		= 5'b00111; //7
localparam  ADDI_EXECUTE		= 5'B01000; //8
localparam  ADDI_WRITE_BACK	= 5'B01001; //9
localparam  EXECUTE_SLL			= 5'b01010; //10
localparam  ANDI_STATE			= 5'b01011; //11
localparam  SLLI_STATE			= 5'b01100; //12
localparam  AUIPC_STATE			= 5'b01101; //13
localparam  B_STATE				= 5'b01110; //14
localparam  BNE_STATE			= 5'b01111; //15
localparam  JAL_STATE			= 5'b10000; //16
localparam  JAL_WRITE_BACK		= 5'b10001; //17
localparam  SLTI_STATE  		= 5'b10010; //18
localparam  JALR_STATE			= 5'b10011; //19
localparam  HALT					= 5'B11111; //31

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


// Func7

reg [4:0] STATE;

always @(negedge rst, posedge clk)
	begin
		if (!rst) 
			STATE<= FETCH;
		else 
		case (STATE)
				FETCH: 		
					STATE <= DECODE;
				DECODE:
					if (opcode == I_LOAD || opcode == S_TYPE)
						STATE <= MEM_ADR;
					else if (opcode == R_TYPE)
						STATE <= EXECUTE;
               else if (opcode == I_TYPE && func3 == ADDI_FUNC3)
						STATE <= ADDI_EXECUTE;
               else if (opcode == I_TYPE && func3 == ANDI_FUNC3)
						STATE <= ANDI_STATE;
               else if (opcode == I_TYPE && func3 == SLLI_FUNC3)
						STATE <= SLLI_STATE;
               else if (opcode == I_TYPE && func3 == SLTI_FUNC3)
						STATE <= SLTI_STATE;
               else if (opcode == AUIPC)
						STATE <= AUIPC_STATE;
					else if (opcode == B_TYPE && func3 == BEQ_FUNC3)
						STATE <= B_STATE;
					else if (opcode == B_TYPE && func3 == BNE_FUNC3)
						STATE <= BNE_STATE;
					else if (opcode == JAL)
						STATE <= JAL_STATE;
					else if (opcode == JALR)
						STATE <= JALR_STATE;
					else
						STATE <= HALT;
				MEM_ADR:
					if (opcode == I_LOAD)
						STATE <= MEM_READ;
					else if (opcode == S_TYPE)
						STATE <= MEM_WRITE;
				MEM_READ:
					STATE <= MEM_WRITE_BACK;
				MEM_WRITE_BACK:
					STATE <= FETCH;
				MEM_WRITE:	
					STATE <= FETCH;
				EXECUTE:
					STATE <= ALU_WRITE_BACK;
				EXECUTE_SLL:
					STATE <= ALU_WRITE_BACK;
				ALU_WRITE_BACK:
					STATE <= FETCH;
				ADDI_EXECUTE:
					STATE <= ADDI_WRITE_BACK;
				ADDI_WRITE_BACK:
					STATE <= FETCH;
				ANDI_STATE:
					STATE <= ADDI_WRITE_BACK;
				SLLI_STATE:
					STATE <= ADDI_WRITE_BACK;
				SLTI_STATE:
					STATE <= ADDI_WRITE_BACK;
				AUIPC_STATE:
					STATE <= ALU_WRITE_BACK;
				B_STATE:
					STATE <= FETCH;
				BNE_STATE:
					STATE <= FETCH;
				JAL_STATE:
					STATE <= JAL_WRITE_BACK;
				JAL_WRITE_BACK:
					STATE <= FETCH;
				JALR_STATE:
					STATE <= JAL_WRITE_BACK;
				HALT:
					STATE <= HALT;
				default:
					STATE <= FETCH;
		endcase
	end

// OUTPUT DEFINITION
always @(STATE)
	begin
		case(STATE)
				FETCH: 	
					begin
					ALUSrcA <= 2'b00;
					IorD <= 1'b0;
					IRWrite <= 1'b1;
					ALUSrcB <= 2'b01;
					ALUOp<= 2'b00;
					PCWrite  <= 1'b1;
					PCSrc  <= 1'b0;
					
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;
					
					end
				DECODE: 	
					begin
					ALUSrcA <= 2'b10;
					ALUSrcB <= 2'b10;
					ALUOp<= 2'b00;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0; //1
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end
				MEM_ADR: 	
					begin
					ALUSrcA <= 2'b01;
					ALUSrcB <= 2'b10;
					ALUOp<= 2'b00;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;					
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;					
					PCWriteCond_NE <= 1'b0;

					end
				MEM_READ: 	
					begin
					IorD <= 1'b1;
					
					ALUSrcA <= 2'b00;
					ALUSrcB <= 2'b01;
					ALUOp<= 2'b00;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;					
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end
				MEM_WRITE_BACK:
					begin
					RegDst <= 1'b0;
					MemtoReg <= 1'b1;
					RegWrite <= 1'b1;
					
					IorD <= 1'b0;
					ALUSrcA <= 2'b00;
					ALUSrcB <= 2'b01;
					ALUOp<= 2'b00;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end
				MEM_WRITE: 	
					begin
					IorD <= 1'b1;
					MemWrite <= 1'b1;
					
					ALUSrcA <= 2'b00;
					ALUSrcB <= 2'b01;
					ALUOp<= 2'b00;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end
				EXECUTE: 	
					begin
					ALUSrcA <= 2'b01;
					ALUSrcB <= 2'b00;
					ALUOp<= 2'b10;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end	
					
				EXECUTE_SLL: 	
					begin
					ALUSrcA <= 2'b10;
					ALUSrcB <= 2'b00;
					ALUOp<= 2'b10;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end
				ANDI_STATE: 	
					begin
					ALUSrcA <= 2'b01;
					ALUSrcB <= 2'b11;
					ALUOp<= 2'b01;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end
				ALU_WRITE_BACK: 	
					begin
					RegDst <= 1'b1;
					MemtoReg <= 1'b0;
					RegWrite <= 1'b1;
					
					IorD <= 1'b0;
					ALUSrcA <= 2'b00;
					ALUSrcB <= 2'b01;
					ALUOp<= 2'b00;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;					
					MemWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end
				ADDI_EXECUTE: 	
					begin
					ALUSrcA <= 2'b01;
					ALUSrcB <= 2'b10;
					ALUOp<= 2'b00;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end					
				ADDI_WRITE_BACK: 	
					begin
					RegDst <= 1'b0;
					MemtoReg <= 1'b0;
					RegWrite <= 1'b1;
					
					IorD <= 1'b0;
					ALUSrcA <= 2'b00;
					ALUSrcB <= 2'b01;
					ALUOp<= 2'b00;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end
				SLLI_STATE: 	
					begin
					ALUSrcA <= 2'b01;
					ALUSrcB <= 2'b10;
					ALUOp<= 2'b00;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end
				AUIPC_STATE: 	
					begin
					ALUSrcA <= 2'b00;
					ALUSrcB <= 2'b10;
					ALUOp<= 2'b10;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;

					end
				B_STATE: 	
					begin
					ALUSrcA <= 2'b01;
					ALUSrcB <= 2'b00;
					ALUOp<= 2'b10;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b1;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b1;
					PCWriteCond_NE <= 1'b0;

					end
				BNE_STATE: 	
					begin
					ALUSrcA <= 2'b01;
					ALUSrcB <= 2'b00;
					ALUOp<= 2'b10;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b1;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b1;
					end
				JAL_STATE: 	
					begin
					ALUSrcA <= 2'b10;
					ALUSrcB <= 2'b01;
					ALUOp<= 2'b00;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b1;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b1;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;
					end
				JALR_STATE: 	
					begin
					ALUSrcA <= 2'b01;
					ALUSrcB <= 2'b10;
					ALUOp<= 2'b00;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b1;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;
					end
				JAL_WRITE_BACK: 	
					begin
					RegDst <= 1'b0;
					MemtoReg <= 1'b0;
					RegWrite <= 1'b1;
					
					IorD <= 1'b0;
					ALUSrcA <= 2'b00;
					ALUSrcB <= 2'b01;
					ALUOp<= 2'b00;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;
					end
				SLTI_STATE: 	
					begin
					ALUSrcA <= 2'b01;
					ALUSrcB <= 2'b10;
					ALUOp<= 2'b10;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;
					end
				default:
					begin
					IorD <= 1'b0;
					ALUSrcA <= 2'b00;
					ALUSrcB <= 2'b01;
					ALUOp<= 2'b00;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b1;
					PCWrite  <= 1'b1;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
					PCWriteCond <= 1'b0;
					PCWriteCond_NE <= 1'b0;
					end
			endcase
	end
endmodule
