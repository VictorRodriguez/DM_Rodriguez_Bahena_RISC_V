module ram_module #(parameter DATA_WIDTH= 32, parameter ADDR_WIDTH= 16 )(

	input 		[31:0]Addr,
	input 		clk,
	input 		WE,
	input 		[31:0]WD,
	output   	[31:0]RD

);

reg [DATA_WIDTH-1:0] ram[ADDR_WIDTH-1:0];

//initial
//begin
//	$readmemb("/home/vmrod/devel/quartus/riscv_factorial/ram.txt" ,ram);
//end
always@ (posedge clk)
  begin
  	if (WE) begin
	 ram[Addr] <= WD;
	end 
end
 
assign RD = ram[Addr];

endmodule
