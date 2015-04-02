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
     ymem_data1, ymem_data2, filt_EN, yMemDataReadyNextCycle,
     op_y_row, op_yVal1, op_yVal2, op_EX_EN, op_Done
     );

/* Inputs and Outputs */
input clock,reset,filt_EN,yMemDataReadyNextCycle,exModDone;
input [15:0]  chng_row, chng_col;
input [23:0]  chng_real,chng_img;
input [255:0] ymem_data1,ymem_data2;

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
reg [1:0] current_state, next_state;
reg [47:0] op_yVal1,op_yVal2;
reg [47:0] temp_yVal;
reg [15:0] op_y_row;
reg [15:0] temp_chng_row, temp_chng_col;
reg op_EX_EN,op_Done,temp_yMemDataReadyNextCycle,temp_exModDone;
reg temp_bit; // For use to test whether it's the second iter.
              // That is, the col,row value is being done now.
reg [47:0] reg_op_yVal1, reg_op_yVal2;
reg [47:0] reg_temp_yVal;
reg [15:0] reg_op_y_row;
reg [15:0] reg_temp_chng_row, reg_temp_chng_col;
reg reg_op_EX_EN, reg_op_Done;
reg reg_temp_bit; 

/* logic for module */
always@(posedge clock)
begin
   if((!reset))
   begin

      current_state  <= 2'b0;

      op_yVal1       <= 48'b0;
      op_yVal2       <= 48'b0;
      op_EX_EN       <= 1'b0;
      op_Done        <= 1'b0;
      op_y_row       <= 16'hffff;

      temp_yVal      <= 48'b0;
      temp_bit       <= 1'b0;
      temp_chng_row  <= 16'hffff;
      temp_chng_col  <= 16'hffff;
      temp_yMemDataReadyNextCycle <= 1'b0;

   end
   else
   begin

      current_state  <= next_state;

      op_yVal1       <= reg_op_yVal1;
      op_yVal2       <= reg_op_yVal2;
      op_EX_EN       <= reg_op_EX_EN;
      op_Done        <= reg_op_Done;
      op_y_row       <= reg_op_y_row;

      temp_yVal      <= reg_temp_yVal;
      temp_bit       <= reg_temp_bit;
      temp_chng_row  <= reg_temp_chng_row;
      temp_chng_col  <= reg_temp_chng_col;
      temp_yMemDataReadyNextCycle <= yMemDataReadyNextCycle;
      temp_exModDone  <= exModDone;

   end
end

always@(*)
begin
   case(current_state)
/***********************     S0       ********************/
   s0: begin
   //Set outputs
   reg_op_yVal1         = 48'b0;
   reg_op_yVal2         = 48'b0;
   reg_op_EX_EN         = 1'b0;
   reg_op_Done          = 1'b0;
   reg_temp_bit         = 1'b0;
   reg_temp_chng_row    = chng_row;
   reg_temp_chng_col    = chng_col;
   reg_temp_yVal        = 48'b0;

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
   reg_op_yVal1    = 48'b0;
   reg_op_yVal2    = 48'b0;
   reg_op_EX_EN    = 1'b0;
   reg_op_Done     = 1'b0;
   reg_op_y_row    = temp_chng_row;
   reg_temp_yVal   = 48'b0;

   // Set next state
   if(temp_yMemDataReadyNextCycle) // get this from the yAddrDecoder.v 
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
   reg_op_Done  = 1'b0;
   reg_op_y_row = 16'hffff;
   //Calc y Diag1
   if((&(ymem_data1[255:253]))&(ymem_data1[248:240]==temp_chng_row)) // all bits are high
   begin
      reg_op_yVal1 = ymem_data1[239:192];
      //Now check the rest for the diag element
      if((ymem_data1[191:176])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data1[175:128];
      end
      else if((ymem_data1[127:112])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data1[111:64];
      end
      else if((ymem_data1[63:48])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data1[47:0];
      end
      else if((ymem_data2[255:240])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[239:192];
      end
      else if((ymem_data2[191:176])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[175:128];
      end
      else if((ymem_data2[127:112])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[111:64];
      end
      else if((ymem_data2[63:48])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[47:0];
      end
      else
      begin
         reg_temp_yVal = 48'b0;
      end
      //end if-else
      reg_op_yVal2 = {chng_real,chng_img};
      reg_op_EX_EN = 1'b1;
      //
   end
   else if((&(ymem_data1[191:189]))&(ymem_data1[184:176]==temp_chng_row))
   begin
      reg_op_yVal1 = ymem_data1[175:128];

      //Now check the rest for the diag element
      if((ymem_data1[127:112])==(temp_chng_col)) 
      begin
         reg_temp_yVal   = ymem_data1[111:64];
      end
      else if((ymem_data1[63:48])==(temp_chng_col)) 
      begin
         reg_temp_yVal   = ymem_data1[47:0];
      end
      else if((ymem_data2[255:240])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[239:192];
      end
      else if((ymem_data2[191:176])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[175:128];
      end
      else if((ymem_data2[127:112])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[111:64];
      end
      else if((ymem_data2[63:48])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[47:0];
      end
      else
      begin
         reg_temp_yVal = 48'b0;
      end
      //end if-else
      reg_op_yVal2    = {chng_real,chng_img};
      reg_op_EX_EN    = 1'b1;
      //
   end
   else if((&(ymem_data1[127:125]))&(ymem_data1[120:112]==temp_chng_row)) 
   begin
      reg_op_yVal1    = ymem_data1[111:64];

      //Now check the rest for the diag element
      if((ymem_data1[63:48])==(temp_chng_col)) 
      begin
         reg_temp_yVal   = ymem_data1[47:0];
      end
      else if((ymem_data2[255:240])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[239:192];
      end
      else if((ymem_data2[191:176])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[175:128];
      end
      else if((ymem_data2[127:112])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[111:64];
      end
      else if((ymem_data2[63:48])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[47:0];
      end
      else
      begin
         reg_temp_yVal   = 48'b0;
      end
      //end if-else
      reg_op_yVal2    = {chng_real,chng_img};
      reg_op_EX_EN    = 1'b1;
      //
   end
   else if((&(ymem_data1[63:61]))&(ymem_data1[56:48]==temp_chng_row)) 
   begin
      reg_op_yVal1    = ymem_data1[47:0];
      reg_op_yVal2    = {chng_real,chng_img};
      reg_op_EX_EN    = 1'b1;

      if((ymem_data2[255:240])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[239:192];
      end
      else if((ymem_data2[191:176])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[175:128];
      end
      else if((ymem_data2[127:112])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[111:64];
      end
      else if((ymem_data2[63:48])==(temp_chng_col)) 
      begin
         reg_temp_yVal = ymem_data2[47:0];
      end
      else
      begin
         reg_temp_yVal   = 48'b0;
      end
   end
   else
   begin
   //Shouldn't come here
   reg_op_yVal2       = 48'b0;
   reg_op_EX_EN       = 1'b0;
   reg_op_y_row       = 16'hffff;
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
         if(temp_exModDone)
         begin

            if(temp_bit)
            begin
               reg_op_yVal1       = temp_yVal;
               reg_op_yVal2       = 48'b0;
               reg_op_EX_EN       = 1'b1;
               reg_op_Done        = 1'b1;

               reg_temp_chng_col  = 16'hffff;
               reg_temp_chng_row  = 16'hffff;
               reg_temp_bit       = 1'b0;
               next_state         = s0;
            end
            else
            begin
               reg_op_yVal1       = temp_yVal;
               reg_op_yVal2       = 48'b0;
               reg_op_EX_EN       = 1'b1;
               reg_op_Done        = 1'b0;
               reg_op_y_row       = op_y_row; //store old value

               reg_temp_chng_col  = chng_row;
               reg_temp_chng_row  = chng_col;
               reg_temp_bit       = 1'b1;
               next_state         = s1;
            end //if-else
         end
         else// --else-reg_-exmodDone
         begin
         //If execution isn't done
            reg_op_yVal1    = 48'b0;
            reg_op_yVal2    = 48'b0;
            reg_op_EX_EN    = 1'b1;
            reg_op_Done     = 1'b0;
            reg_op_y_row    = 16'hffff;// fetch next row. may happen quite often
            next_state      = s3;
         end // if-else of exModDone
      end// end-if of |temp_yVal
      else
      begin
         //Now check for the diag element
         if((ymem_data1[255:240])==(temp_chng_col)) 
         begin
            if(temp_exModDone)
            begin
               if(temp_bit)
               begin
                  reg_op_yVal1       = ymem_data1[239:192];
                  reg_op_yVal2       = 48'b0;
                  reg_op_EX_EN       = 1'b1;
                  reg_op_Done        = 1'b1;
                  reg_op_y_row       = 16'hffff;

                  reg_temp_chng_col  = 16'hffff;
                  reg_temp_chng_row  = 16'hffff;
                  reg_temp_bit       = 1'b0;
                  next_state         = s0;
               end
               else
               begin
                  reg_op_yVal1       = ymem_data1[239:192];
                  reg_op_yVal2       = 48'b0;
                  reg_op_EX_EN       = 1'b1;
                  reg_op_Done        = 1'b0;
                  reg_op_y_row       = chng_col;

                  reg_temp_chng_col  = chng_row;
                  reg_temp_chng_row  = chng_col;
                  reg_temp_bit       = 1'b1;
                  next_state         = s1;
               end //if-else
            end
            else
            begin
            //If execution isn't done
               reg_op_yVal1    = 48'b0;
               reg_op_yVal2    = 48'b0;
               reg_op_EX_EN    = 1'b1;
               reg_op_Done     = 1'b0;
               reg_op_y_row    = 16'hffff;// keep fetching next row

               reg_temp_yVal   = ymem_data1[239:192];
               next_state  = s3; 
            end // if-else of exModDone
         end
         else if((ymem_data1[191:176])==(temp_chng_col)) 
         begin
            if(temp_exModDone)
            begin

               if(temp_bit)
               begin
                  reg_op_yVal1          = ymem_data1[175:128];
                  reg_op_yVal2          = 48'b0;
                  reg_op_EX_EN          = 1'b1;
                  reg_op_Done           = 1'b1;
                  reg_op_y_row          = 16'hffff;

                  reg_temp_chng_col     = 16'hffff;
                  reg_temp_chng_row     = 16'hffff;
                  reg_temp_bit          = 1'b0;
                  next_state            = s0;
               end
               else
               begin
                  reg_op_yVal1          = ymem_data1[175:128];
                  reg_op_yVal2          = 48'b0;
                  reg_op_EX_EN          = 1'b1;
                  reg_op_Done           = 1'b0;
                  reg_op_y_row          = chng_col;

                  reg_temp_chng_col     = chng_row;
                  reg_temp_chng_row     = chng_col;
                  reg_temp_bit          = 1'b1;
                  next_state            = s1;
               end //if-else
            end
            else
            begin
            //If execution isn't done
                  reg_temp_yVal      = ymem_data1[175:128];
                  reg_op_yVal1       = 48'b0;
                  reg_op_yVal2       = 48'b0;
                  reg_op_EX_EN       = 1'b1;
                  reg_op_Done        = 1'b0;
                  reg_op_y_row       = 16'hffff;
                  next_state         = s3;
            end // if-else of exModDone
         end
         else if((ymem_data1[127:112])==(temp_chng_col)) 
         begin
            if (temp_exModDone)
            begin
               if(temp_bit)
               begin
                  reg_op_yVal1       = ymem_data1[111:64];
                  reg_op_yVal2       = 48'b0;
                  reg_op_EX_EN       = 1'b1;
                  reg_op_Done        = 1'b1;
                  reg_op_y_row       = 16'hffff;

                  reg_temp_chng_col  = 16'hffff;
                  reg_temp_chng_row  = 16'hffff;
                  reg_temp_bit       = 1'b0;
                  next_state         = s0;
               end
               else
               begin
                  reg_op_yVal1       = ymem_data1[111:64];
                  reg_op_yVal2       = 48'b0;
                  reg_op_EX_EN       = 1'b1;
                  reg_op_Done        = 1'b0;
                  reg_op_y_row       = chng_col;

                  reg_temp_chng_col  = chng_row;
                  reg_temp_chng_row  = chng_col;
                  reg_temp_bit       = 1'b1;
                  next_state         = s1;
               end //if-else
            end
            else
            begin
            //If execution isn't done
                  reg_temp_yVal      = ymem_data1[111:64];
                  reg_op_yVal1       = 48'b0;
                  reg_op_yVal2       = 48'b0;
                  reg_op_EX_EN       = 1'b1;
                  reg_op_Done        = 1'b0;
                  reg_op_y_row       = 16'hffff;
                  next_state         = s3;
            end // if-else of exModDone

/*
            if (exModDone)
            begin
               op_yVal1    = ymem_data1[111:64];
               op_EX_EN    = 1'b1;

               if(temp_bit)
               begin
                  temp_chng_col  = 16'hffff;
                  temp_chng_row  = 16'hffff;
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
                  temp_yVal   = ymem_data1[111:64];
                  op_yVal1    = 48'b0;
                  op_yVal2    = 48'b0;
                  op_EX_EN    = 1'b1;
                  op_Done     = 1'b0;
                  op_y_row    = 16'hffff;
                  next_state  = s3;
            end // if-else of exModDone
*/
         end
         else if((ymem_data1[63:48])==(temp_chng_col)) 
         begin
            if(temp_exModDone)
            begin

               if(temp_bit)
               begin
                  reg_op_yVal1       = ymem_data1[47:0];
                  reg_op_EX_EN       = 1'b1;
                  reg_op_yVal2       = 48'b0;
                  reg_op_Done        = 1'b1;
                  reg_op_y_row       = 16'hffff;

                  reg_temp_chng_col  = 16'hffff;
                  reg_temp_chng_row  = 16'hffff;
                  reg_temp_bit       = 1'b0;
                  next_state         = s0;
               end
               else
               begin
                  reg_op_yVal1       = ymem_data1[47:0];
                  reg_op_EX_EN       = 1'b1;
                  reg_op_yVal2       = 48'b0;
                  reg_op_Done        = 1'b0;
                  reg_op_y_row       = chng_col;

                  reg_temp_chng_col  = chng_row;
                  reg_temp_chng_row  = chng_col;
                  reg_temp_bit       = 1'b1;
                  next_state         = s1;
               end //if-else
            end
            else
            begin
            //If execution isn't done
                  reg_temp_yVal      = ymem_data1[47:0];
                  reg_op_yVal1       = 48'b0;
                  reg_op_yVal2       = 48'b0;
                  reg_op_EX_EN       = 1'b1;
                  reg_op_Done        = 1'b0;
                  reg_op_y_row       = 16'hffff;
                  next_state         = s3;
            end // if-else of exModDone
         end
         else
         begin
            reg_op_yVal1             = 48'b0;
            reg_op_yVal2             = 48'b0;
            reg_op_EX_EN             = 1'b0;
            reg_op_Done              = 1'b0;
            reg_op_y_row             = 16'hffff;
            next_state               = s3;
         //
         end //else-if for different ymem data
      end// if-else of |TempData
   end //-if
   else
   begin
       next_state     = s3; 
       reg_op_yVal1   = 48'b0;
       reg_op_yVal2   = 48'b0;
       reg_op_Done    = 1'b0;
       reg_op_y_row   = temp_chng_row;
   end//else-if - Op NOT Done

   end//s3
   endcase


end // always@(*)


endmodule
