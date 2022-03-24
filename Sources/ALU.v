`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////


module ALU # (parameter WIDTH = 4)(
    input signed [WIDTH:0] A,
    input signed [WIDTH:0] B,
    input [3:0] REG_CONTROL,
    output reg [WIDTH+1:0] RESULT,
	 output zero,
	 output reg carry_out,
	 output reg overflow
    );
   
	localparam ALU_WIDHT = WIDTH + 1;
	assign zero = (RESULT == 0)? 1'b1:1'b0;
	
	always @*	
	begin
		case (REG_CONTROL) 
		4'b0000:
			begin // AND 
			    RESULT <= A & B; 
            end
		4'b0001: //OR
			begin 
			    RESULT <= A | B;
            end
		4'b0010: 
            begin // suma
                RESULT <= A + B;
					 carry_out <= (RESULT[ALU_WIDHT] == 1'b1)? 1'b1:1'b0;
					 overflow <= ((~A[WIDTH] & ~B[WIDTH] & RESULT[ALU_WIDHT]) | (A[WIDTH] & B[WIDTH] & ~RESULT[ALU_WIDHT]))? 1'b1:1'b0;
            end
		4'b0011: // Mul
			begin
			    RESULT <= A * B;
				 carry_out = (RESULT[ALU_WIDHT] == 1'b1)? 1'b1:1'b0;
				 overflow <= ((~A[WIDTH] & ~B[WIDTH] & RESULT[ALU_WIDHT]) | (A[WIDTH] & B[WIDTH] & ~RESULT[ALU_WIDHT]))? 1'b1:1'b0;
         end
		4'b0100: // AUIPC
			begin
			    RESULT <= A + (B<<12) - 4;
         end
		4'b0101: //sub
			begin 
					RESULT <= A - B;
            end
      4'b0110: // BEQ
            begin
			    RESULT <= (A-4) + B ;
            end 
		4'b0111: // shift <<
			begin 
			    RESULT <= A << B;
         end
		4'b1000: // SLTI
			begin 
			    RESULT <= (A < B) ? 1:0;
         end
		default:
			begin
			     RESULT <= 0;
         end   
		endcase			
	end
endmodule