   // synopsys translate_off
`include "/afs/eos.ncsu.edu/dist/synopsys2013/syn/dw/sim_ver/DW_fp_addsub.v"

     //synopsys translate_on
module fp_addsub_24(in1,in2,mode,opt,clock,reset,status,enable,done_flag);
parameter sig_width = 17;
parameter exp_width = 6;
parameter ieee_compliance = 1;
input [sig_width+exp_width : 0] in1;
input [sig_width+exp_width: 0] in2;
input mode,clock,reset,enable;
output [sig_width+exp_width :0]opt;
output [7:0] status;
output  done_flag;
reg [3:0] done_reg;
reg   [sig_width+exp_width : 0] z_inst_pipe1, z_inst_pipe2, z_inst_pipe3;
wire  [sig_width+exp_width : 0] z_inst_internal;

reg   [7 : 0] status_inst_pipe1, status_inst_pipe2, status_inst_pipe3;
wire [7:0] status_inst_internal;
    DW_fp_addsub #(sig_width, exp_width, ieee_compliance)
	  U1 ( .a(in1), .b(in2), .rnd(3'b000), .op(mode), .z(z_inst_internal), .status(status_inst_internal));


always@(posedge clock)
begin
if((enable)&(reset))
begin

    z_inst_pipe1 <= z_inst_internal;
    z_inst_pipe2 <= z_inst_pipe1;
    z_inst_pipe3 <= z_inst_pipe2;
   

    status_inst_pipe1 <= status_inst_internal;
    status_inst_pipe2 <= status_inst_pipe1;
    status_inst_pipe3 <= status_inst_pipe2;
    done_reg <= (done_reg>>1);
end
else
begin
    z_inst_pipe1 <= 24'b0;
    z_inst_pipe2 <= 24'b0;
    z_inst_pipe3 <= 24'b0;
   

    status_inst_pipe1 <= 8'b0;
    status_inst_pipe2 <= 8'b0;
    status_inst_pipe3 <= 8'b0;
    done_reg <=4'b1000;
end

end
assign done_flag=done_reg[0];
assign opt=z_inst_pipe3;
assign status=status_inst_pipe3;
endmodule



