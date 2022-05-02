`timescale 1ns / 1ps

module riscv_factorial_TB(   );

// clk and rst
reg clk;
reg rst;
wire [7:0]gpio_port_out;
reg [7:0]gpio_port_in;

riscv_factorial UUT(
.clk(clk),
.rst(rst),
.gpio_port_out(gpio_port_out),
.gpio_port_in(gpio_port_in)
);

initial
    begin
	 clk = 1'b0;
	 rst = 1'b0;
	 gpio_port_in = 8'b00001000;
	 #20
	 rst = 1'b1;
    end

// main clock
always
    begin
     # 10 clk = ~clk;
    end


endmodule
