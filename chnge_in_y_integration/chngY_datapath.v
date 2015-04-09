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

module updateY_datapath(clock,reset, executeEnableBit,
                     yInVal1, yInVal2, 
                     op_yWriteVal, op_DoneFlag, op_ExDoneFlag
                    );
/* Inputs and Outputs */

input          clock,reset,executeEnableBit;
input [47:0]   yInVal1,yInVal2;

output [47:0]  op_yWriteVal;
output         op_DoneFlag,op_ExDoneFlag;


/* Wires and Regs */
wire        wire_DoneFlag_CmplxMod,both_valid,diag_valid;

reg         op_ExDoneFlag;

wire [47:0]  op_yWriteVal;
reg         op_DoneFlag;

   //Stored in Registers
reg  [47:0]  temp_yComputedVal,temp_addsubout;
reg         temp_nextMode,temp_curMode;

   //Wires
wire [47:0] wire_addsubOut;
reg  [47:0] reg_addsub_in1,reg_addsub_in2;
 

/* Main Circuit Logic */
always@(posedge clock)
begin
   if(~(reset&executeEnableBit)) // Reset or Enable are 0
   begin
      //op_yWriteVal      <= 48'b0;
      op_DoneFlag       <= 1'b0;
      op_ExDoneFlag     <= 1'b0;
      temp_nextMode     <= 1'b1; // always start with subtract first

      temp_yComputedVal <= 48'd0;
      temp_addsubout    <= 48'b0;
      
   end//if-reset
   else
   begin
      


      //op_yWriteVal         <= wire_addsubOut; // just so that we can always see the output

      if(op_ExDoneFlag&(~op_DoneFlag))
      begin
         temp_yComputedVal    <= wire_addsubOut;
      end
      else if(op_ExDoneFlag & op_DoneFlag)
      begin
         temp_yComputedVal    <= 48'b0;
      end

      //if((|yInVal1) & (|yInVal2)) // both are non zeros
      if(both_valid)
      begin
         op_ExDoneFlag     <= 1'b1; // it'll be done next cycle
         op_DoneFlag       <= 1'b0;
         temp_nextMode     <= 1'b0;
      end//both !=0
      //else if((|yInVal1) & (~(|yInVal2))) // yIn1 is non zero and yIn2 is 0. diag element
      else if(diag_valid)
      begin
         op_ExDoneFlag     <= 1'b1; // it'll be done next cycle
         op_DoneFlag       <= 1'b1;
         temp_nextMode     <= 1'b1;// reset to subtract
         //temp_yComputedVal <= 48'b0;
      end // diag elem
      else
      begin // no valid inputs
         op_ExDoneFlag     <= 1'b0; // it'll be done next cycle
         op_DoneFlag       <= 1'b0;
      end // check for inputs


   end//-- else-reset

end//posedge clk

      //Deciding inputs and mode to addsub module
always@(*)
begin

   reg_addsub_in1     = yInVal1;

  // if((|yInVal1) & (|yInVal2)) // both are non zeros
  if(both_valid)
   begin
      reg_addsub_in2  = yInVal2;
   end
   else
   begin
      reg_addsub_in2  = temp_yComputedVal;
   end


end// always@(*)

assign both_valid    = ((|yInVal1) & (|yInVal2));
assign diag_valid    = ((|yInVal1) & (~(|yInVal2)));

assign op_yWriteVal  = wire_addsubOut;

/* Modules */

addsub_cplx u1 (.clock(clock),.in1(reg_addsub_in1),.in2(reg_addsub_in2),.mode(temp_nextMode),
                  .op(wire_addsubOut)
               );


endmodule


