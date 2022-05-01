`timescale 1ns / 1ps


module mips(

// clk and rst
input clk,
input rst,

output [31:0] S5_out,
output [31:0] S6_out,
output [31:0] S7_out

);

wire [31:0]instruction;
wire [31:0]instruction_q;
wire [31:0]data_q;
wire [31:0]A_register_q;
wire [31:0]B_register_q;
wire [31:0]RD1;
wire [31:0]RD2;
wire [31:0]Adr;
wire [31:0]RD;

wire [31:0]SrcA;
wire [31:0]SrcB;
wire [31:0]ALUResult;
wire [31:0]ALUOut;

wire [31:0]PC;
wire [31:0]PC_q;

wire [31:0]SignImm;
wire [31:0]ZeroImm;
wire [31:0]zero_extend_shamt_reg;

wire [31:0]WD3;
wire [4:0]A3;

wire [1:0]ALUSrcB;
wire [1:0]ALUSrcA;
wire MemtoReg;
wire RegDst;
wire IorD;
wire PCSrc;

wire IRWrite; 
wire MemWrite;
wire PCWrite;
wire RegWrite;

wire [1:0]ALUOp;

wire [2:0]ALUControl;

parameter S5 = 21;
parameter S6 = 22;
parameter S7 = 23;


register_n # (.n(32)) PC_register (.D(PC),.clk(clk),.rst(rst),.load(PCWrite),.Q(PC_q));

mux_2_1 # (.N (32))mux_2_1_PC_ALUOut(.A(PC_q), .B(ALUOut), .sel(IorD), .Y(Adr));

Instr_Data_Memory #(.DATA_WIDTH(32), .ADDR_WIDTH(32) ) Instr_Data_Memory(
	.Addr(Adr),
	.clk(clk),
	.WE(MemWrite),
	.WD(B_register_q),
	.RD(RD)
);
	
register_n # (.n(32)) instruction_register (.D(RD),.clk(clk),.rst(rst),.load(IRWrite),.Q(instruction_q));
register_n # (.n(32)) data_register (.D(RD),.clk(clk),.rst(rst),.load(1'b1),.Q(data_q));

mux_2_1 # (.N (5)) mux_2_1_inst_data(.A(instruction_q[20:16]), .B(instruction_q[15:11]), .sel(RegDst), .Y(A3));
mux_2_1 # (.N (32)) mux_2_1_ALU_data (.A(ALUOut), .B(data_q), .sel(MemtoReg), .Y(WD3));


register_file register_file_1(
		.WD3(WD3), 
      .A3(A3), 
		.RD1(RD1), 
		.A1(instruction_q[25:21]), 
      .RD2(RD2), 
		.A2(instruction_q[20:16]), 
		.WE(RegWrite), 
		.rst(rst), 
		.clk(clk));
		
register_n # (.n(32)) A_register (.D(RD1),.clk(clk),.rst(rst),.load(1'b1),.Q(A_register_q));
register_n # (.n(32)) B_register (.D(RD2),.clk(clk),.rst(rst),.load(1'b1),.Q(B_register_q));

sign_extend #(.width(16))sign_extend(.extend(instruction_q[15:0]), .extended(SignImm));
zero_extend #(.width(16))zero_extend(.extend(instruction_q[15:0]), .extended(ZeroImm));



FSM_mips FSM_mips(
	// Multiplexer Selects
	.MemtoReg(MemtoReg),
	.RegDst(RegDst),
	.IorD(IorD),
	.PCSrc(PCSrc),
	.ALUSrcB(ALUSrcB),
	.ALUSrcA(ALUSrcA),

	// Register Enables
	.IRWrite(IRWrite),
	.MemWrite(MemWrite),
	.PCWrite(PCWrite),
	.RegWrite(RegWrite),

	// ALU control system
	.ALUOp(ALUOp),

	// clk and rst
	.clk(clk),
	.rst(rst),

	// opcode and func
	.opcode(instruction_q[31:26]),
	.func(instruction_q[5:0]),
	.shamt(instruction_q[10:6])
);

zero_extend_shamt zero_extend_shamt(instruction_q[10:6], zero_extend_shamt_reg);

mux_4_1 # (.N (32))mux_4_1_PC_A(.A(PC_q), .B(A_register_q), .C(zero_extend_shamt_reg),.D(), .SEL(ALUSrcA),.Y(SrcA));

mux_4_1 # (.N(32))mux_4_1(.A(B_register_q),.B(1), .C(SignImm),.D(ZeroImm), .SEL(ALUSrcB),.Y(SrcB));

aludec aludec(.funct(instruction_q[5:0]),.aluop(ALUOp),.alucontrol(ALUControl));



ALU # (.WIDTH(31))ALU(
    .A(SrcA),
    .B(SrcB),
    .REG_CONTROL(ALUControl),
    .RESULT(ALUResult),
	 .zero(),
	 .carry_out(),
	 .overflow()
    );

register_n # (.n(32)) ALU_result_register (.D(ALUResult),.clk(clk),.rst(rst),.load(1'b1),.Q(ALUOut));

mux_2_1 # (.N (32))mux_2_1_ALU_result(.A(ALUResult), .B(ALUOut), .sel(PCSrc), .Y(PC));


register_n_addr # (.n(32)) register_n_addr_1 (.D(WD3),.clk(clk),.rst(rst),.load(RegWrite),.addr(A3),.ref_addr(S5),.Q(S5_out));
register_n_addr # (.n(32)) register_n_addr_2 (.D(WD3),.clk(clk),.rst(rst),.load(RegWrite),.addr(A3),.ref_addr(S6),.Q(S6_out));
register_n_addr # (.n(32)) register_n_addr_3 (.D(WD3),.clk(clk),.rst(rst),.load(RegWrite),.addr(A3),.ref_addr(S7),.Q(S7_out));
	 
endmodule
