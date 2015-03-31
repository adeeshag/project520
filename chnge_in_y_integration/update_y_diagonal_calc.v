module y_update_diagonal_calc(y_diag,y_old,y_new,sel_old_or_new,sel_diag_or_sum,sel_mode_addsub,y_new_diag,clock,reset);
parameter width = 48;
input [width-1 :0] y_diag,y_old,y_new;
input [1:0] sel_old_or_new;
input sel_diag_or_sum, sel_mode_addsub,clock,reset;
output reg [width-1 :0] y_new_diag;
reg [width-1:0] y_diag_temp,y_new_temp,y_old_temp;
reg [width-1 :0] addsub_in1,addsub_in2; 
wire [width-1 :0] y_new_diag_wire;
always@(posedge clock or negedge reset)
    begin
    if(!reset)
        begin
        y_diag_temp <= 0;
        y_new_temp <= 0;
        y_old_temp <= 0;

        y_new_diag<=48'b0;
        end
    else
        begin
        y_diag_temp <= y_diag;
        y_new_temp <= y_new;
        y_old_temp <= y_old;

        y_new_diag<=y_new_diag_wire;
        end
    end
always@(*)
    begin
    casex(sel_diag_or_sum)
    1'b0:addsub_in1=y_diag_temp;
    1'b1:addsub_in1=y_new_diag;
    endcase
    end
always@(*)
    begin
    casex(sel_old_or_new)
    2'b00:addsub_in2=y_new_temp;
    2'b11:addsub_in2=y_old_temp;
    default:addsub_in2=48'b0;
    endcase
    end
addsub_cplx u1(.in1(addsub_in1),.in2(addsub_in2),.mode(sel_mode_addsub),.op(y_new_diag_wire));


endmodule





