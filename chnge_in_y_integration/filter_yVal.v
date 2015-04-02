/************************************************************
 *          Control Path for ChangeInY module
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
 *         4. filt_EN - This module's enable
 *         5. yMemDataReadyNextCycle - So that next cycle it's
 *            waiting for the data
 *    
 * Output: 1. Which row to fetch next. (Output goes to yAddrDec)
 *         2. Value of Y (two o/p, goes to calc_y)
 *         3. Ex_Enable (whether the next cycle should be EX)
 *            (goes to calc_y)
 *         4. Complete bit
 *
 * **********************************************************/

module filt_yVal(clock, reset, exModDone, 
     chng_row, chng_col, chng_real, chng_img,
     ymem_data, filt_EN, yMemDataReadyNextCycle,
     op_y_row, op_yVal1, op_yVal2, op_EX_EN, op_Done
     );

/* Inputs and Outputs */
input clock,reset,filt_EN,yMemDataReadyNextCycle,exModDone;
input [15:0] chng_row, chng_col;
input [23:0] chng_real,chng_img;
input [255:0] ymem_data;

output [47:0] op_yVal1,op_yVal2;
output [15:0] op_y_row;
output op_EX_EN,op_Done;

/* Parameters */

parameter
      s0 = 0,
      s1 = 1,
      s2 = 2,
      s3 = 3;

/* Wires and regs */
reg [2:0] current_state, next_state;
reg [47:0] op_yVal1,op_yVal2;
reg [47:0] temp_yVal;
reg [15:0] op_y_row;
reg [15:0] temp_chng_row, temp_chng_col;
reg op_EX_EN,op_Done;
reg temp_bit; // For use to test whether it's the second iter.
              // That is, the col,row value is being done now.

/* logic for module */
always@(posedge clock)
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
/***********************     S0       ********************/
   s0: begin
   //Set outputs
   op_yVal1       = 48'b0;
   op_yVal2       = 48'b0;
   op_EX_EN       = 1'b0;
   op_Done        = 1'b0;
   op_y_row       = chng_row;
   temp_bit       = 1'b0;
   temp_chng_row  = chng_row;
   temp_chng_col  = chng_col;
   temp_yVal      = 48'b0;

   // Set next state
   if((filt_EN)&(~op_Done))
   begin
      next_state = s1;
   end//if
   else
   begin
      next_state = s0;
   end //-if-else
   //
   end // s0

/***********************     S1       ********************/
   s1: begin
   //Set outputs
   op_yVal1    = 48'b0;
   op_yVal2    = 48'b0;
   op_EX_EN    = 1'b0;
   op_Done     = 1'b0;
   op_y_row    = temp_chng_row;
   temp_yVal   = 48'b0;

   // Set next state
   if(yMemDataReadyNextCycle) // get this from the yAddrDecoder.v 
   begin
      next_state = s2;
   end// -if
   else
      next_state = s1;
   begin
   end //else-if

   end// -s1

/***********************     S2       ********************/
   s2: begin
   //Set outputs
   op_Done = 1'b0;
   op_y_row = '1;
   //Calc y Diag1
   if((ymem_data[255:245])==({3'd7,temp_chng_row})) // all bits are high
   begin
      op_yVal1 = ymem_data[239:192];
      //Now check the rest for the diag element
      if((ymem_data[191:176])==(temp_chng_col)) 
      begin
         temp_yVal = ymem_data[175:128];
      end
      else if((ymem_data[127:112])==(temp_chng_col)) 
      begin
         temp_yVal = ymem_data[111:64];
      end
      else if((ymem_data[63:48])==(temp_chng_col)) 
      begin
         temp_yVal = ymem_data[47:0];
      end
      else
      begin
         temp_yVal = 48'b0;
      end
      //end if-else
      op_yVal2 = {chng_real,chng_img};
      op_EX_EN = 1'b1;
      //
   end
   else if((ymem_data[191:181])==({3'd7,temp_chng_row})) 
   begin
      op_yVal1 = ymem_data[175:128];

      //Now check the rest for the diag element
      if((ymem_data[127:112])==(temp_chng_col)) 
      begin
         temp_yVal   = ymem_data[111:64];
      end
      else if((ymem_data[63:48])==(temp_chng_col)) 
      begin
         temp_yVal   = ymem_data[47:0];
      end
      else
      begin
         temp_yVal = 48'b0;
      end
      //end if-else
      op_yVal2    = {chng_real,chng_img};
      op_EX_EN    = 1'b1;
      //
   end
   else if((ymem_data[127:117])==({3'd7,temp_chng_row})) 
   begin
      op_yVal1    = ymem_data[111:64];

      //Now check the rest for the diag element
      if((ymem_data[63:48])==(temp_chng_col)) 
      begin
         temp_yVal   = ymem_data[47:0];
      end
      else
      begin
         temp_yVal   = 48'b0;
      end
      //end if-else
      op_yVal2    = {chng_real,chng_img};
      op_EX_EN    = 1'b1;
      //
   end
   else if((ymem_data[63:61])==({3'd7,temp_chng_row})) 
   begin
      op_yVal1    = ymem_data[47:0];
      op_yVal2    = {chng_real,chng_img};
      op_EX_EN    = 1'b1;
   end
   else
   begin
   //Shouldn't come here
   op_yVal2       = 48'b0;
   op_EX_EN       = 1'b0;
   op_y_row       = '1;
   end// if-else main nest
   // 
   
   // Set next state
   next_state = s3;

   end// s2
/***********************     S3       ********************/
   s3: begin
   // A Wait for Yij State

   if(~op_Done) // don't think we need this. Remove later if not needed
   begin
   //
      if(|temp_yVal)
      begin
         if(exModDone)
         begin
            op_yVal1    = temp_yVal;
            op_EX_EN    = 1'b1;

            if(temp_bit)
            begin
               temp_chng_col  = 'b1;
               temp_chng_row  = 'b1;
               op_Done        = 1'b1;
               temp_bit       = 1'b0;
               next_state     = s0;
            end
            else
            begin
               temp_chng_col  = chng_row;
               temp_chng_row  = chng_col;
               op_Done        = 1'b0;
               temp_bit       = 1'b1;
               next_state     = s1;
            end //if-else
         end
         else// --else--exmodDone
         begin
         //If execution isn't done
            op_yVal1    = 48'b0;
            op_yVal2    = 48'b0;
            op_EX_EN    = 1'b1;
            op_Done     = 1'b0;
            op_y_row    = '1;// fetch next row. may happen quite often
            next_state  = s3;
         end // if-else of exModDone
      end// end-if of |temp_yVal
      else
      begin
         //Now check for the diag element
         if((ymem_data[255:240])==(temp_chng_col)) 
         begin
            if(exModDone)
            begin
               if(temp_bit)
               begin
                  op_yVal1       = ymem_data[239:192];
                  op_yVal2       = 48'b0;
                  op_EX_EN       = 1'b1;
                  op_Done        = 1'b1;
                  op_y_row       = '1;

                  temp_chng_col  = '1;
                  temp_chng_row  = '1;
                  temp_bit       = 1'b0;
                  next_state     = s0;
               end
               else
               begin
                  op_yVal1       = ymem_data[239:192];
                  op_yVal2       = 48'b0;
                  op_EX_EN       = 1'b1;
                  op_Done        = 1'b0;
                  op_y_row       = chng_col;

                  temp_chng_col  = chng_row;
                  temp_chng_row  = chng_col;
                  temp_bit       = 1'b1;
                  next_state     = s1;
               end //if-else
            end
            else
            begin
            //If execution isn't done
               op_yVal1    = 48'b0;
               op_yVal2    = 48'b0;
               op_EX_EN    = 1'b1;
               op_Done     = 1'b0;
               op_y_row    = '1;// keep fetching next row

               temp_yVal   = ymem_data[239:192];
               next_state  = s3; 
            end // if-else of exModDone
         end
         else if((ymem_data[191:176])==(temp_chng_col)) 
         begin
            if(exModDone)
            begin

               if(temp_bit)
               begin
                  op_yVal1          = ymem_data[175:128];
                  op_yVal2          = 48'b0;
                  op_EX_EN          = 1'b1;
                  op_Done           = 1'b1;
                  op_y_row          = '1;

                  temp_chng_col     = '1;
                  temp_chng_row     = '1;
                  temp_bit          = 1'b0;
                  next_state        = s0;
               end
               else
               begin
                  op_yVal1          = ymem_data[175:128];
                  op_yVal2          = 48'b0;
                  op_EX_EN          = 1'b1;
                  op_Done           = 1'b0;
                  op_y_row          = chng_col;

                  temp_chng_col     = chng_row;
                  temp_chng_row     = chng_col;
                  temp_bit          = 1'b1;
                  next_state        = s1;
               end //if-else
            end
            else
            begin
            //If execution isn't done
                  temp_yVal      = ymem_data[175:128];
                  op_yVal1       = 48'b0;
                  op_yVal2       = 48'b0;
                  op_EX_EN       = 1'b1;
                  op_Done        = 1'b0;
                  op_y_row       = '1;
                  next_state     = s3;
            end // if-else of exModDone
         end
         else if((ymem_data[127:112])==(temp_chng_col)) 
         begin
            if (exModDone)
            begin
               if(temp_bit)
               begin
                  op_yVal1       = ymem_data[111:64];
                  op_yVal2       = 48'b0;
                  op_EX_EN       = 1'b1;
                  op_Done        = 1'b1;
                  op_y_row       = '1;

                  temp_chng_col  = '1;
                  temp_chng_row  = '1;
                  temp_bit       = 1'b0;
                  next_state     = s0;
               end
               else
               begin
                  op_yVal1       = ymem_data[111:64];
                  op_yVal2       = 48'b0;
                  op_EX_EN       = 1'b1;
                  op_Done        = 1'b0;
                  op_y_row       = chng_col;

                  temp_chng_col  = chng_row;
                  temp_chng_row  = chng_col;
                  temp_bit       = 1'b1;
                  next_state     = s1;
               end //if-else
            end
            else
            begin
            //If execution isn't done
                  temp_yVal      = ymem_data[111:64];
                  op_yVal1       = 48'b0;
                  op_yVal2       = 48'b0;
                  op_EX_EN       = 1'b1;
                  op_Done        = 1'b0;
                  op_y_row       = '1;
                  next_state     = s3;
            end // if-else of exModDone

/*
            if (exModDone)
            begin
               op_yVal1    = ymem_data[111:64];
               op_EX_EN    = 1'b1;

               if(temp_bit)
               begin
                  temp_chng_col  = '1;
                  temp_chng_row  = '1;
                  op_Done        = 1'b1;
                  temp_bit       = 1'b0;
                  next_state     = s0;
               end
               else
               begin
                  temp_chng_col  = chng_row;
                  temp_chng_row  = chng_col;
                  op_Done        = 1'b0;
                  temp_bit       = 1'b1;
                  next_state     = s1;
               end //if-else
            end
            else
            begin
            //If execution isn't done
                  temp_yVal   = ymem_data[111:64];
                  op_yVal1    = 48'b0;
                  op_yVal2    = 48'b0;
                  op_EX_EN    = 1'b1;
                  op_Done     = 1'b0;
                  op_y_row    = '1;
                  next_state  = s3;
            end // if-else of exModDone
*/
         end
         else if((ymem_data[63:48])==(temp_chng_col)) 
         begin
            if(exModDone)
            begin

               if(temp_bit)
               begin
                  op_yVal1       = ymem_data[47:0];
                  op_EX_EN       = 1'b1;
                  op_yVal2       = 48'b0;
                  op_Done        = 1'b1;
                  op_y_row       = '1;

                  temp_chng_col  = '1;
                  temp_chng_row  = '1;
                  temp_bit       = 1'b0;
                  next_state     = s0;
               end
               else
               begin
                  op_yVal1       = ymem_data[47:0];
                  op_EX_EN       = 1'b1;
                  op_yVal2       = 48'b0;
                  op_Done        = 1'b0;
                  op_y_row       = chng_col;

                  temp_chng_col  = chng_row;
                  temp_chng_row  = chng_col;
                  temp_bit       = 1'b1;
                  next_state     = s1;
               end //if-else
            end
            else
            begin
            //If execution isn't done
                  temp_yVal      = ymem_data[47:0];
                  op_yVal1       = 48'b0;
                  op_yVal2       = 48'b0;
                  op_EX_EN       = 1'b1;
                  op_Done        = 1'b0;
                  op_y_row       = '1;
                  next_state     = s3;
            end // if-else of exModDone
         end
         else
         begin
            op_yVal1             = 48'b0;
            op_yVal2             = 48'b0;
            op_EX_EN             = 1'b0;
            op_Done              = 1'b0;
            op_y_row             = '1;
            next_state           = s3;
         //
         end //else-if for different ymem data
      end// if-else of |TempData
   end //-if
   else
   begin
       next_state = s3; 
       op_yVal1   = 48'b0;
       op_yVal2   = 48'b0;
       op_Done    = 1'b0;
       op_y_row   = temp_chng_row;
   end//else-if - Op NOT Done

   end//s3
   endcase


end // always@(*)


endmodule
