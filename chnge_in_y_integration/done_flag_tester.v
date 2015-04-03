module done_flag_tester(input_done_flag,done_flag_unified);
input [1:0] input_done_flag;
output done_flag_unified;
assign done_flag_unified = &input_done_flag;
endmodule 
