module peripherals_control_unit(
	/// inputs
	input [31:0]Adr_in,
	input MemWrite_in,
	input MemRead_in,
	
	input [31:0] Data_in_1,
	input [31:0] Data_in_2,
	input [31:0] Data_in_3,

	// outputs
	output [2:0]  selector_w,
	output [2:0]  selector_r,
	output [31:0] Data_out,
	
);

