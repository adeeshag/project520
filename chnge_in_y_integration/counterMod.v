/* *********************************************************
 *                   Control Logic 
 * This module has a counter implemented as a shift register.
 * The done_flag goes high after 3 Clk cycles. It starts
 * counting when reset or enable is triggered.
 *
 * *********************************************************/


module counterMod( clock, reset, countEN,
                        op_done);

input    clock,reset,countEN;
output   op_done;

reg [3:0] countVal,reg_countVal;
reg op_done;

always@(posedge clock)
begin
   if(~(reset&countEN))
   begin
      countVal    <= 4'h8;
   end
   else
   begin
      countVal    <= reg_countVal;
   end
end//always@(posedge)
                        


always@(*)
begin
   if(countVal[0])
   begin
      op_done        = 1'b1;
      reg_countVal   = 4'h8; //1000
   end
   else
   begin
      op_done        = 1'b0;
      reg_countVal    = (countVal>>1);
   end
end//always@(*)

endmodule
