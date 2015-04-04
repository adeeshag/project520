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
                     op_yWriteVal, op_DoneFlag, op_ExDoneFlag
                    );
/* Inputs and Outputs */

input          clock,reset,executeEnableBit;
input [47:0]   yInVal1,yInVal2;

output [47:0]  op_yWriteVal;
output         op_DoneFlag,op_ExDoneFlag;


/* Wires and Regs */
wire        wire_DoneFlag_CmplxMod;
wire        wire_useless_now;

wire         op_ExDoneFlag;

reg [47:0]  op_yWriteVal;
reg         op_DoneFlag;

   //Stored in Registers
reg  [47:0]  temp_yComputedVal;
reg         temp_nextMode;

   //Wires
wire [47:0] wire_addsubOut;
reg  [47:0] reg_addsub_in1,reg_addsub_in2;
 

/* Main Circuit Logic */
always@(posedge clock)
begin
   if(~(reset&executeEnableBit)) // Reset or Enable are 0
   begin
      op_yWriteVal      <= 48'b0;
      op_DoneFlag       <= 1'b0;
     // op_ExDoneFlag     <= 1'b0;
      temp_nextMode     <= 1'b1; // always start with subtract first

      temp_yComputedVal <= 48'b0;
      
   end//if-reset
   else
   begin
      if(wire_DoneFlag_CmplxMod) 
      begin
         temp_yComputedVal <= wire_addsubOut;
        // op_ExDoneFlag     <= 1'b1;

         if(temp_nextMode)
         begin
            temp_nextMode  <= 1'b0; // set to adder next
            op_DoneFlag    <= 1'b0;
            op_yWriteVal   <= wire_addsubOut; // let it keep putting out data either way
         end
         else // temp_nextMode==0
         begin
            op_yWriteVal   <= wire_addsubOut;
            temp_nextMode  <= 1'b1; // Reset to subtractor next
            op_DoneFlag    <= 1'b1;
         end // temp_nextMode

      end//---if wire_DoneFlag_CmplxMod is high
      else
      begin
         op_yWriteVal   <= wire_addsubOut;
         op_DoneFlag    <= 1'b0;
        // op_ExDoneFlag  <= 1'b0;
         // temp_nextMode should retain it's previous value
      end// else wire_DoneFlag_CmplxMod


   end//-- else-reset

end//posedge clk

      //Deciding inputs and mode to addsub module
always@(*)
begin

   reg_addsub_in1     = yInVal1;

   if(temp_nextMode)
   begin
      reg_addsub_in2  = yInVal2;
   end
   else
   begin
      reg_addsub_in2  = temp_yComputedVal;
   end


end// always@(*)

assign op_ExDoneFlag = wire_DoneFlag_CmplxMod;

/* Modules */

addsub_cplx u1 (.clock(clock),.reset(reset),.in1(reg_addsub_in1),.in2(reg_addsub_in2),.mode(temp_nextMode),
                  .op(wire_addsubOut),.done_flag(wire_useless_now),.enable(executeEnableBit)
               );

counterMod cnt_mod( .clock(clock), .reset(reset), .countEN(executeEnableBit),
                        .op_done(wire_DoneFlag_CmplxMod));

endmodule


