`timescale 1ns / 1ps

module riscv_led_TB(   );

// clk and rst
reg clk;
reg rst;

wire [31:0] S5_out;
wire [31:0] S6_out;
wire [31:0] S7_out;

mips UUT(
.clk(clk),
.rst(rst),
.S5_out(S5_out),
.S6_out(S6_out),
.S7_out(S7_out)
);

initial
    begin
	 clk = 1'b0;
	 rst = 1'b0;
	 #20
	 rst = 1'b1;
    end

	 // main clock
always
    begin
     # 10 clk = ~clk;
    end


endmodule
