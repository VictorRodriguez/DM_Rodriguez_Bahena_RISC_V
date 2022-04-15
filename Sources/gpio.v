module gpio(
	/// inputs
	input [31:0] Adr_in,
	input clk,
   input rst,
	input [31:0] Data_in,
	input [7:0]  switches, // SWITCHES

	// outputs
	output [31:0] Data_out,
	output reg [7:0]  Leds // LEDS
);

localparam  TEXT 		= 	16'B0000000001000000;
localparam  DATA 		= 	16'B0001000000000001;
localparam  GPIO_1 	=  16'B0000000000100100; // 24 leds
localparam  GPIO_2 	=  16'B0000000000101000; // 28 switches


	always @(posedge clk or negedge rst)
	begin
	if (!rst)
		begin
			Leds <= {(7){1'b0}};
		end
	else if (Adr_in[31:16] == DATA && (Adr_in[15:0] == GPIO_1) )
			begin // LEDS
			Leds <= Data_in[7:0];
			end
	else if (Adr_in[31:16] == DATA && (Adr_in[15:0] == GPIO_2) )
			begin // SWITCHES
			Leds <= Leds;
			end
	else
			begin //??
			Leds <= Leds;
			end

	end
	
	assign Data_out[31:0] = {24'b0000_0000_0000_0000_0000_0000,switches[7:0]};

endmodule

