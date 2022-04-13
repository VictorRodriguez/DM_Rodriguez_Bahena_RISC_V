module riscv_factorial(
	// inputs
	input clk,
	input rst,
	
	//outputs
	output [7:0] gpio_port_out,
	input  [7:0] gpio_port_in,
	output heard_bit_out
	
);

wire [31:0] Adr;
wire MemWrite;
wire [31:0] Data_out;
wire [31:0] Data_in;
wire set_leds;
wire [31:0] Data_ROM;
wire [31:0] Data_RAM;
wire [31:0] Data_from_GPIO;
wire [31:0] Adr_out;
wire [31:0] Data_to_CPU;
wire [2:0] selector;
wire clk_;

riscv_core riscv_core_(
	// inputs
	.clk(clk),
	.rst(rst),
	// outputs
	.Adr(Adr),
	.MemWrite(MemWrite),
	.Data_out(Data_out),
	.Data_in(Data_to_CPU)
);

peripherals_control_unit peripherals_control_unit_(
	// inputs
	.Adr_in(Adr),
	.MemWrite_in(MemWrite),
	.MemRead_in(),
	
	.Data_in_0(Data_ROM),
	.Data_in_1(Data_RAM),
	.Data_in_2(Data_from_GPIO),

	// outputs
	.selector(selector),
	.Data_out(Data_to_CPU),
	.Adr_out(Adr_out)
);

rom_module #(.DATA_WIDTH(32), .ADDR_WIDTH(32) ) rom_module_(
	// inputs
	.Addr(Adr_out),
	.clk(clk),
	.WE(), // N/A
	.WD(), // N/A
	// outputs
	.RD(Data_ROM)
);

ram_module #(.DATA_WIDTH(32), .ADDR_WIDTH(128) ) ram_module_(
	// inputs
	.Addr(Adr_out),
	.clk(clk),
	.WE(MemWrite),
	.WD(Data_out),
	// outputs
	.RD(Data_RAM)
);

gpio gpio_(
	/// inputs
	.Adr_in(Adr),
	.clk(clk),
	.rst(rst),
	.Data_in(Data_out),
	.switches (gpio_port_in), // SWITCHES
	// outputs
	.Data_out(Data_from_GPIO),
	.Leds (gpio_port_out) // LEDS
);

Heard_Bit  # (.Half_Period_Counts(10_000) ) // main clk
          clk_timer(.clk(clk), .rst(rst), .enable(1'b1), .heard_bit_out(clk_));

Heard_Bit  # (.Half_Period_Counts(10_000_000) ) // half second for a clk of 50 MHz 
          design_monitor (.clk(clk), .rst(rst), .enable(1'b1), .heard_bit_out(heard_bit_out));
			 
endmodule
