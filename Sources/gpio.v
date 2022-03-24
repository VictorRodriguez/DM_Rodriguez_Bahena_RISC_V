module gpio(
	/// inputs
	input [31:0] Adr_in,
	
	input [31:0] Data_in,
	input [7:0]  gpio_port_in, // SWITCHES

	// outputs
	output reg set_leds,
	output reg [31:0] Data_out,
	output reg [7:0]  gpio_port_out // LEDS
);

localparam  TEXT 		= 	16'B0000000001000000;
localparam  DATA 		= 	16'B0001000000000001;
localparam  GPIO_1 	=  16'B0000000000100100; // 24 leds
localparam  GPIO_2 	=  16'B0000000000101000; // 28 switches


	always @*
	begin
	if (Adr_in[31:16] == DATA && (Adr_in[15:0] == GPIO_1) )
			begin // LEDS
			gpio_port_out <= Data_in[7:0];
			set_leds <= 1'B1;
			end
	else if (Adr_in[31:16] == DATA && (Adr_in[15:0] == GPIO_2) )
			begin // SWITCHES
			Data_out[7:0] <= gpio_port_in;
			set_leds <= 1'B0;
			end
	else
			begin //??
			Data_out <= 0;
			gpio_port_out <= 0;
			set_leds <= 1'B0;
			end

	end


endmodule

