module riscv_core(
	/// inputs
	input clk,
	input rst,
	input [31:0]Data_in_RAM,
	input [31:0]Data_in_ROM,

	//outputs
	output MemWrite,
	output [31:0]RomAdr,
	output [31:0]RamAdr,
	output [31:0]PC_q,
	output [31:0]Data_out
);


///////////////////////////////////////////////////////////////////////////////////////
// Control Unit
///////////////////////////////////////////////////////////////////////////////////////

wire IorD;                                                                      
wire MemRead;
wire IRWrite;                                                                   
wire RegWrite;  
wire ALUSrc;
wire ALUSrcA;
wire Branch;
wire [1:0]Jump;                                                                  
wire [1:0]ALUOp;                                                                
wire PCWrite;
wire PCWriteCond;
wire PCWriteCond_NE;                                                                   
wire PCSource;                                                                     
wire [31:0] imm_generated;
wire [31:0] imm_generated_signed;
wire [1:0] MemtoReg;

///////////////////////////////////////////////////////////////////////////////////////
// Control Unit
///////////////////////////////////////////////////////////////////////////////////////
maindec maindec_(
	// opcode and func                                                          
	.opcode(Data_in_ROM[6:0]),                                              
	.func3(Data_in_ROM[14:12]),                                                  

	// Multiplexer Selects                                                      
	.MemtoReg(MemtoReg),
	.ALUSrcA(ALUSrcA),
	.ALUSrc(ALUSrc),
	.RegDst(),

	// Register Enables 
	.MemWrite(MemWrite),
	.Branch(Branch),
	.RegWrite(RegWrite),
	.Jump(Jump),

	// ALU control system
	.ALUOp(ALUOp)
	);
	

///////////////////////////////////////////////////////////////////////////////////////
// Data Path
///////////////////////////////////////////////////////////////////////////////////////

wire [31:0]PC;
wire [31:0]PC_branch;
wire [31:0]result_pc;
wire [31:0]result_pc_branch;
wire [31:0]result_pc_jal;
wire [31:0]result_pc_jalr;

wire [31:0]A_register_q;                                                        
wire [31:0]RD1;                                                                 
wire [31:0]RD2;                                                                 
wire [31:0]RD;  
wire [31:0]WD3;
wire [31:0]SrcA;                                                                
wire [31:0]SrcB;                                                                
wire [31:0]ALUResult;                                                           
wire [31:0]ALUOut;   
wire [3:0]ALUControl; 
wire zero;

register_pc_n # (.n(32)) PC_register (.D(PC),.clk(clk),.rst(rst),.load(1'b1),.Q(PC_q));


 register_file register_file_1(                                                  
	.A1(Data_in_ROM[19:15]),                                              
	.A2(Data_in_ROM[24:20]),
	.A3(Data_in_ROM[11:7]),                                                                
	.WD3(WD3),                                                              
	.RD1(RD1),                                                   
	.RD2(RD2),                                                            
	.WE(RegWrite),                                                    
	.rst(rst),                                                              
	.clk(clk));
	

imm_gen imm_gen (.opcode(Data_in_ROM[6:0]),.instruction(Data_in_ROM[31:0]),.imm(imm_generated));
sign_extend_riscv sign_extend_riscv(.opcode(Data_in_ROM[6:0]),.extend(imm_generated),.extended(imm_generated_signed));

mux_2_1 # (.N (32)) mux_B_src (.A(RD2), .B(imm_generated_signed), .sel(ALUSrc), .Y(SrcB));
mux_2_1 # (.N (32)) mux_A_src (.A(PC_q), .B(RD1), .sel(ALUSrcA), .Y(SrcA));

aludec aludec(.func3(Data_in_ROM[14:12]),.func7(Data_in_ROM[31:25]),.aluop(ALUOp),.opcode(Data_in_ROM[6:0]),.alucontrol(ALUControl));

// Regular ALU
ALU # (.WIDTH(31))ALU(
	.A(SrcA),                                                                   
	.B(SrcB),                                                                   
	.REG_CONTROL(ALUControl),                                                   
	.RESULT(ALUResult),                                                         
	.zero(zero),                                                                   
	.carry_out(),                                                              
	.overflow()                                                                
);   

// Add + 4 for PC
ALU # (.WIDTH(31))adder_1(                                                          
	.A(PC_q),                                                                   
	.B(4),                                                                   
	.REG_CONTROL(4'b0010),                                                   
	.RESULT(result_pc),                                                         
	.zero(),                                                                   
	.carry_out(),                                                              
	.overflow()                                                                
);   

// Add PC + IMM branch
 ALU # (.WIDTH(31))adder_2(                                                          
	.A(PC_q),                                                                   
	.B(imm_generated_signed),                                                                   
	.REG_CONTROL(4'b0010),                                                   
	.RESULT(result_pc_branch),                                                         
	.zero(),                                                                   
	.carry_out(),                                                              
	.overflow()                                                                
);

// Add for JUMP
 ALU # (.WIDTH(31))adder_jump(                                                          
	.A(PC_q),                                                                   
	.B(imm_generated_signed),                                                                   
	.REG_CONTROL(4'b0010),                                                   
	.RESULT(result_pc_jal),                                                         
	.zero(),                                                                   
	.carry_out(),                                                              
	.overflow()                                                                
);

// Add for JALR
 ALU # (.WIDTH(31))adder_jalr(                                                          
	.A(SrcA),                                                                   
	.B(imm_generated_signed),                                                                   
	.REG_CONTROL(4'b0010),                                                   
	.RESULT(result_pc_jalr),                                                         
	.zero(),                                                                   
	.carry_out(),                                                              
	.overflow()                                                                
);    

mux_2_1 # (.N (32)) mux_branch (.A(result_pc), .B(result_pc_branch), .sel(Branch && zero), .Y(PC_branch));
mux_4_1 # (.N (32)) mux_jump (.A(PC_branch), .B(result_pc_jal),.C(result_pc_jalr), .D(),  .SEL(Jump), .Y(PC));

mux_4_1 # (.N (32)) mux_mem_to_reg(.A(Data_in_RAM), .B(ALUResult), .C(result_pc), .D(), .SEL(MemtoReg), .Y(WD3));

assign Data_out = RD2;
assign RomAdr = PC_q;
assign RamAdr = ALUResult;

endmodule
