module peripherals_control_unit(
	/// inputs
	input [31:0]Adr_in,
	input MemWrite_in,
	input MemRead_in,
	
	input [31:0] Data_in_0,
	input [31:0] Data_in_1,
	input [31:0] Data_in_2,

	// outputs
	output reg [2:0]  selector,
	output reg [31:0] Data_out,
	output reg [31:0] Adr_out

);

localparam  TEXT 		= 	16'B0000000001000000;
localparam  DATA 		= 	32'B10000000000010000000000000000;
localparam  GPIO_1 	=  16'B0000000000100100;
localparam  GPIO_2 	=  16'B0000000000101000;


	always @*
	begin
	if (Adr_in[31:16] == TEXT )
			begin // ROM
			Adr_out <= (Adr_in[15:0]) / 4;
			Data_out <= Data_in_0;
			selector <= 3'b001;
			end

	else if (Adr_in[31:16] == DATA && (Adr_in[15:0] == GPIO_1 || Adr_in[15:0] == GPIO_2 ) )
			begin //GPIO
			Adr_out <= Adr_in[31:0];
			Data_out <= Data_in_2;
			selector <= 3'b010;
			end
	else if (Adr_in[31:0] >= DATA)
			begin //RAM
			Adr_out <= (Adr_in[15:0]) / 4;
			Data_out <=Data_in_1;
			selector <= 3'b100;
			end
	else
			begin //??
			Adr_out <= 0;
			Data_out <= 0;
			selector <= 3'b000;
			end

	end


endmodule

