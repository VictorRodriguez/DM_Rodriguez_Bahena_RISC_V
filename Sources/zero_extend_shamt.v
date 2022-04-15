module zero_extend_shamt (extend, extended);
input[4:0] extend;
output[31:0] extended;
assign extended[31:0] = { {27 {1'b0}}, extend[4:0] };
endmodule