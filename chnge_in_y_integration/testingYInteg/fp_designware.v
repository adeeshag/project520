module fp_dw(in1_adder1,in2_adder1,opt_adder1, adder1_mode, clock);

input clock;
input adder1_mode;
input   [47:0] in1_adder1, in2_adder1;//these will have to be sent to adder 1
output  [47:0] opt_adder1;//this be be received from adder 1



addsub_cplx A1(.in1(in1_adder1),.in2(in2_adder1),.mode(adder1_mode),.op(opt_adder1),.clock(clock));

endmodule
