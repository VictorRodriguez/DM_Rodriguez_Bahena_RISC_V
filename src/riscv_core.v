module riscv_core(
	/// inputs
	input clk,
	input rst,
	
	//outputs
	output [31:0]Adr,
	output MemWrite,
	output [31:0]Data_out,
	input  [31:0]Data_in
);


///////////////////////////////////////////////////////////////////////////////////////
// Control Unit
///////////////////////////////////////////////////////////////////////////////////////

wire IorD;                                                                      
wire MemRead;
wire IRWrite;                                                                   
wire RegWrite;  
wire [1:0]ALUSrcA;                                                              
wire [1:0]ALUSrcB;                                                              
wire MemtoReg;                                                                  
wire [1:0]ALUOp;                                                                
wire PCWrite;
wire PCWriteCond;
wire PCWriteCond_NE;                                                                   
wire PCSource;                                                                     
wire [31:0] imm_generated;
wire [31:0] imm_generated_signed;
wire [31:0] instruction_q;
                                                                            
 
FSM_riscv FSM_riscv(                                                              
	// Multiplexer Selects                                                      
	.MemtoReg(MemtoReg),                                                        
	.RegDst(), // n/a                                                            
	.IorD(IorD),                                                                
	.PCSrc(PCSource),                                                              
	.ALUSrcB(ALUSrcB),                                                          
	.ALUSrcA(ALUSrcA),                                                          
                                                                               
	// Register Enables                                                         
	.IRWrite(IRWrite),                                                          
	.MemWrite(MemWrite),                                                        
	.PCWrite(PCWrite),                                                          
	.RegWrite(RegWrite),
	.PCWriteCond(PCWriteCond),
	.PCWriteCond_NE(PCWriteCond_NE),
                                                                                
	// ALU control system                                                       
	.ALUOp(ALUOp),                                                              
                                                                              
	// clk and rst                                                              
	.clk(clk),                                                                  
	.rst(rst),                                                                  
                                                                               
	// opcode and func                                                          
	.opcode(instruction_q[6:0]),                                              
	.func3(instruction_q[14:12]),                                                  
   .func7(instruction_q[31:25])                                                 
);          


///////////////////////////////////////////////////////////////////////////////////////
// Data Path
///////////////////////////////////////////////////////////////////////////////////////

wire [31:0]PC;
wire [31:0]PC_q;
wire [31:0]PC_q_b;

wire [31:0]data_q;                                                              
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

register_pc_n # (.n(32)) PC_register (.D(PC),.clk(clk),.rst(rst),.load(PCWrite || (PCWriteCond && zero) || (PCWriteCond_NE && ~zero) ),.Q(PC_q));

register_pc_n # (.n(32)) PC_register_b (.D(PC_q),.clk(clk),.rst(rst),.load(PCWrite || (PCWriteCond && zero) || (PCWriteCond_NE && ~zero)),.Q(PC_q_b));


mux_2_1 # (.N (32))mux_2_1_PC_ALUOut(.A(PC_q), .B(ALUOut), .sel(IorD), .Y(Adr));

//Instr_Data_Memory #(.DATA_WIDTH(32), .ADDR_WIDTH(32) ) Instr_Data_Memory(
//	.Addr(Adr),
//	.clk(clk),
//	.WE(MemWrite),
//	.WD(B_register_q),
//	.RD(RD)
//);  

register_n # (.n(32)) instruction_register (.D(Data_in),.clk(clk),.rst(rst),.load(IRWrite),.Q(instruction_q));
register_n # (.n(32)) data_register (.D(Data_in),.clk(clk),.rst(rst),.load(1'b1),.Q(data_q));

mux_2_1 # (.N (32)) mux_2_1_ALU_data (.A(ALUOut), .B(data_q), .sel(MemtoReg), .Y(WD3));

 register_file register_file_1(                                                  
	.A1(instruction_q[19:15]),                                              
	.A2(instruction_q[24:20]),
	.A3(instruction_q[11:7]),                                                                
	.WD3(WD3),                                                              
	.RD1(RD1),                                                   
	.RD2(RD2),                                                            
	.WE(RegWrite),                                                    
	.rst(rst),                                                              
	.clk(clk));
	
imm_gen imm_gen (.opcode(instruction_q[6:0]),.instruction(instruction_q[31:0]),.imm(imm_generated));

sign_extend_riscv sign_extend_riscv(.opcode(instruction_q[6:0]),.extend(imm_generated),.extended(imm_generated_signed));

register_n # (.n(32)) A_register (.D(RD1),.clk(clk),.rst(rst),.load(1'b1),.Q(A_register_q));
register_n # (.n(32)) B_register (.D(RD2),.clk(clk),.rst(rst),.load(1'b1),.Q(Data_out));

// mux_2_1 # (.N (32))mux_2_1_PC_A(.A(PC_q), .B(A_register_q), .sel(ALUSrcA),.Y(SrcA));
mux_4_1 # (.N (32))mux_4_1_PC_A(.A(PC_q), .B(A_register_q), .C(PC_q_b),.D(), .SEL(ALUSrcA),.Y(SrcA));

                                                                                 
mux_4_1 # (.N(32))mux_4_1(.A(Data_out),.B(4), .C(imm_generated_signed),.D(), .SEL(ALUSrcB),.Y(SrcB));
                                                                                
aludec aludec(.func3(instruction_q[14:12]),.func7(instruction_q[31:25]),.aluop(ALUOp),.opcode(instruction_q[6:0]),.alucontrol(ALUControl));
                                                                                
ALU # (.WIDTH(31))ALU(                                                          
	.A(SrcA),                                                                   
	.B(SrcB),                                                                   
	.REG_CONTROL(ALUControl),                                                   
	.RESULT(ALUResult),                                                         
	.zero(zero),                                                                   
	.carry_out(),                                                              
	.overflow()                                                                
);   

register_n # (.n(32)) ALU_result_register (.D(ALUResult),.clk(clk),.rst(rst),.load(1'b1),.Q(ALUOut));
                                                      
mux_2_1 # (.N (32))mux_2_1_ALU_result(.A(ALUResult), .B(ALUOut), .sel(PCSource), .Y(PC));


endmodule
