/************************************************************
 *
 * This module is the datapath for the change in Y matrix
 * update. 
 * "Compute_EN" signal so that the Y Computation module does
 * not pull out anymore data. It should sit idle till the next
 * read from change.txt, i.e a computation/ all the iters 
 * should be done.
 *
 * Inputs: 1. Two Y values from the control path. Second value
 *            might be 0 the second read.
 *         2. Execute Enable - module doesn't compute when 0
 *         3. clock,rst
 *    
 * Output: 1. Output of Computation. 
 *            -> this value is not valid if "DoneFlag" is 0
 *         2. DoneFlag - indicates that Computation is done
 *
 * **********************************************************/

module updateY_calc(clock,reset, executeEnableBit,
                     yInVal1, yInVal2, 
                     op_yWriteVal, op_DoneFlag
                    );
/* Inputs and Outputs */

input clock,reset,executeEnableBit;
input [47:0] yInVal1,yInVal2;

output [47:0] op_yWriteVal;
output op_DoneFlag;


/* Wires and Regs */
wire wire_DoneFlag_CmplxMod;
wire [47:0] wire_addsubOut;

reg [47:0] temp_yComputedVal;
reg reg_nextMode;

/* Main Circuit Logic */

always@(posedge clock)
begin
   if(~(reset&executeEnableBit)) //NAND
   begin
      op_yWriteVal <= 48'bz;
      op_DoneFlag <= 1'b0;
      reg_nextMode <= 1'b1;
      
   end//if-reset
   else
   begin
      if(wire_DoneFlag_CmplxMod) 
      begin
         op_yWriteVal <= wire_addsubOut; 
         op_DoneFlag <= 1'b1;
      end//---if wire_DoneFlag_CmplxMod is high
      else
      begin
         op_yWriteVal <= 48'bz;
         op_DoneFlag <= 1'b0;
      end// else wire_DoneFlag_CmplxMod

      //Deciding inputs and mode to addsub module
      

   end//-- else-reset

end//posedge clk



/* Modules */

addsub_cplx u1(.clock(clock),.reset(reset),.in1(addsub_in1),.in2(addsub_in2),.mode(sel_mode_addsub),
               .op(y_new_diag_wire),.doneflag(wire_DoneFlag_CmplxMod),.addsub_enable(executeEnableBit)
               );


endmodule





