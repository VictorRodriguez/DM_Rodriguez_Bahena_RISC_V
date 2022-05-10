module rom_module #(parameter DATA_WIDTH= 32, parameter ADDR_WIDTH= 16 )(

	input 		[31:0]Addr,
	input 		clk,
	input 		WE,
	input 		[31:0]WD,
	output   	[31:0]RD

);

reg [DATA_WIDTH-1:0] rom[ADDR_WIDTH-1:0];

initial
  begin
		$readmemb("../assembly_code/opcode.txt" ,rom);
  end
always@ (posedge clk)
  begin
  	if (WE) begin
	 rom[Addr] <= WD;
	end
end

assign RD = rom[Addr];

endmodule
