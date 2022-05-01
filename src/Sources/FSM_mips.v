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

	// ALU control system
	output reg [1:0] ALUOp,

	// clk and rst
	input clk,
	input rst,

	// opcode and func
	input [5:0]opcode,
	input [5:0]func,
	input [4:0]shamt

);

localparam 	FETCH 				= 4'b0000;
localparam 	DECODE 				= 4'b0001;
localparam 	MEM_ADR				= 4'b0010;
localparam 	MEM_READ				= 4'b0011;
localparam  MEM_WRITE_BACK		= 4'b0100;
localparam 	MEM_WRITE			= 4'b0101;
localparam  EXECUTE				= 4'b0110;
localparam  ALU_WRITE_BACK		= 4'b0111;
localparam  ADDI_EXECUTE		= 4'B1000;
localparam  ADDI_WRITE_BACK	= 4'B1001;
localparam  EXECUTE_SLL			= 4'b1010;
localparam  ANDI_STATE			= 4'b1011;
localparam  HALT					= 4'B1111;


localparam LW 		= 6'b100011;
localparam SW 		= 6'b101011;
localparam ANDI	= 6'b001100;
localparam R_TYPE = 6'b000000;
localparam ADDI	= 6'b001000;

reg [3:0] STATE;

always @(negedge rst, posedge clk)
	begin
		if (!rst) 
			STATE<= FETCH;
		else 
		case (STATE)
				FETCH: 		
					STATE <= DECODE;
				DECODE:
					if (opcode == LW || opcode == SW)
						STATE <= MEM_ADR;
					else if (opcode == R_TYPE && shamt == 5'b00000)
						STATE <= EXECUTE;
					else if (opcode == R_TYPE && shamt != 5'b00000)
						STATE <= EXECUTE_SLL;
					else if (opcode == ADDI)
						STATE <= ADDI_EXECUTE;
					else if (opcode == ANDI)
						STATE <= ANDI_STATE;
					else
						STATE <= HALT;
				MEM_ADR:
					if (opcode == LW)
						STATE <= MEM_READ;
					else if (opcode == SW)
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
					
					end
				DECODE: 	
					begin
					ALUSrcA <= 2'b00;
					ALUSrcB <= 2'b11;
					ALUOp<= 2'b00;
					
					IorD <= 1'b0;
					PCSrc  <= 1'b0;
					IRWrite <= 1'b0;
					PCWrite  <= 1'b0;
					MemtoReg  <= 1'b0;
					RegDst  <= 1'b0;
					MemWrite <= 1'b0;
					RegWrite <= 1'b0;
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
					end
			endcase
	end
endmodule
