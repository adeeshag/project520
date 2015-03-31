
/************************************************************
 *
 * This module is supposed to filter out the correct Y values
 * based on the row/col and also give out a "EX-Enable" or a 
 * "Compute_EN" signal so that the Y Computation module does
 * not pull out anymore data. It should sit idle till the next
 * read from change.txt, i.e a computation/ all the iters 
 * should be done.
 *
 * Inputs: 1. Values from change.txt
 *         2. Value read from yMem
 *         3. clock,rst
 *    
 * Output: 1. Which row to fetch next. (Output goes to yAddrDec)
 *         2. Value of Y (two o/p, goes to calc_y)
 *         3. Ex_Enable (whether the next cycle should be EX)
 *            (goes to calc_y)
 *
 * **********************************************************/

module filt_yVal(clock, reset, 
     chng_row, chng_col, chng_real, chng_img,
     ymem_data,
     op_y_row, op_yVal1, op_yVal2, op_EX_EN
     );

/* Inputs and Outputs */
input [15:0] chng_row, chng_col;
input [23:0] chng_real,chng_img;
input [255:0] ymem_data;

output [47:0] op_yVal1,op_yVal2;
output [15:0] op_y_row;
output op_EX_EN;

/* Parameters */

parameter
      s0 =0,
      s1 =1,
      s2 =2,
      s3 =3,
      s4=4;

/* Wires and regs */
reg [2:0] current_state, next_state;
reg [47:0] op_yVal1,op_yVal2;
reg [15:0] op_y_row;
reg op_EX_EN;

/* logic for module */
always@(posedge clock or negedge reset)
begin
   if((!reset))
   begin

   current_state <= 2'b0;

   end
   else
   begin

   current_state <= next_state;

   end
end

always@(*)
begin
   case(current_state)
   s0: begin
   //Set outputs
   op_yVal1 = 48'bz;
   op_yVal2 = 48'bz;
   op_EX_EN = 1'b0;
   op_y_row = 16'bz;
   // Set next state
   //
   end
   s1: begin
   //Set outputs
   op_yVal1 = 48'bz;
   op_yVal2 = 48'bz;
   op_EX_EN = 1'b0;
   op_y_row = chng_row;
   // Set next state

   end
   s2: begin
   //Set outputs
   op_yVal1 = 48'bz;
   op_yVal2 = {chng_real,chng_img};
   op_EX_EN = 1'b1;
   op_y_row = chng_col;
   // Set next state

   end

end



endmodule
