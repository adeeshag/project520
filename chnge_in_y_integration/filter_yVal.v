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
     chng_row, chng_col, chng_real, chng_img, dpModDoneFlag,
     ymem_data1, ymem_data2, filt_EN, yMemDataReadyNextCycle,
     op_y_row, op_yVal1, op_yVal2, op_EX_EN, op_Done, op_DataEN
     );

/* Inputs and Outputs */
input clock,reset,filt_EN,yMemDataReadyNextCycle,exModDone, dpModDoneFlag;
input [15:0]  chng_row, chng_col;
input [23:0]  chng_real,chng_img;
input [255:0] ymem_data1,ymem_data2;

output [47:0] op_yVal1,op_yVal2;
output [15:0] op_y_row;
output op_EX_EN,op_Done,op_DataEN;

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
reg op_EX_EN,op_Done,temp_yMemDataReadyNextCycle,op_DataEN;
reg temp_bit; // For use to test whether it's the second iter.
              // That is, the col,row value is being done now.
reg [47:0] reg_op_yVal1, reg_op_yVal2;
reg [47:0] reg_temp_yVal;
reg [15:0] reg_op_y_row;
reg [15:0] reg_temp_chng_row, reg_temp_chng_col;
reg reg_op_EX_EN, reg_op_Done,reg_op_dataEN;
reg reg_temp_bit,temp_exModDone,reg_exModDone; 

/* logic for module */
always@(posedge clock)
begin
   if(!reset)
   begin

      current_state  <= 2'b0;

      op_yVal1       <= 48'b0;
      op_yVal2       <= 48'b0;
      op_EX_EN       <= 1'b0;
      op_Done        <= 1'b0;
      op_y_row       <= 16'hffff;
      op_DataEN      <= 1'b0;

      temp_yVal      <= 48'b0;
      temp_bit       <= 1'b0;
      temp_chng_row  <= 16'hffff;
      temp_chng_col  <= 16'hffff;
      temp_yMemDataReadyNextCycle <= 1'b0;
      temp_exModDone <= 1'b0;

   end
   else
   begin

      current_state  <= next_state;

      op_yVal1       <= reg_op_yVal1;
      op_yVal2       <= reg_op_yVal2;
      op_EX_EN       <= reg_op_EX_EN;
      op_Done        <= reg_op_Done;
      op_y_row       <= reg_op_y_row;
      op_DataEN      <= reg_op_dataEN;

      temp_yVal      <= reg_temp_yVal;
      temp_bit       <= reg_temp_bit;
      temp_chng_row  <= reg_temp_chng_row;
      temp_chng_col  <= reg_temp_chng_col;
      temp_yMemDataReadyNextCycle <= yMemDataReadyNextCycle;

      if(temp_bit)
         temp_exModDone <= exModDone;

       

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
      reg_op_y_row         = 16'hffff;
      reg_op_dataEN        = 1'b0;
      reg_temp_bit         = 1'b0;
      reg_temp_chng_col    = chng_col;
      reg_temp_chng_row    = chng_row;
      reg_temp_yVal        = 48'b0;

      // Set next state
      if(((filt_EN)&(~op_Done))&(reset))
      begin
         next_state = s1;
      end//if
      else
      begin
         next_state = s0;
      end //-if-else

   end // s0

/***********************     S1       ********************/
   s1: begin
      //Set outputs
      reg_op_yVal1    = 48'b0;
      reg_op_yVal2    = 48'b0;
      reg_op_Done     = 1'b0;
      reg_op_y_row    = temp_chng_row;
      reg_temp_yVal   = 48'b0;

      // Set next state
      if(yMemDataReadyNextCycle) // get this from the yAddrDecoder.v 
      begin
         reg_op_dataEN   = 1'b1;
         casex({temp_bit,temp_exModDone})
         2'b00:begin
            next_state = s2;
            reg_op_EX_EN    = 1'b0;
         end// b00  
         2'b01:begin
            next_state = s2;
            reg_op_EX_EN    = 1'b0;
         end// b01  
         2'b10:begin
            reg_op_EX_EN    = 1'b1;
            next_state = s1;
         end// b10  
         2'b11:begin
            next_state = s2;
            reg_op_EX_EN    = 1'b0;
         end// b11  
         endcase
      end// -if
      else
      begin

      /*
         casex({temp_bit,exModDone})
         2'b00:begin
            reg_op_dataEN    = 1'b1;
            reg_op_EX_EN     = op_EX_EN;// prev value
         end// b00  
         2'b01:begin
            reg_op_EX_EN     = op_EX_EN;// prev value
            reg_op_dataEN    = 1'b0;
         end// b01  
         2'b10:begin
            reg_op_EX_EN     = op_EX_EN;// prev value
            reg_op_dataEN    = 1'b0;
         end// b10  
         2'b11:begin
            reg_op_EX_EN     = op_EX_EN;// prev value
            reg_op_dataEN    = 1'b1;
         end// b11  
         endcase

         */
         if(dpModDoneFlag)
            reg_op_dataEN = 1'b1;
         else if(!temp_bit)
            reg_op_dataEN = 1'b1;
         else
            reg_op_dataEN = 1'b0;

         next_state = s1;
      end //else-if

   end// -s1

/***********************     S2       ********************/
   s2: begin
   //Set outputs
   //Calc y Diag1
      if((&(ymem_data1[255:253]))&(ymem_data1[248:240]==temp_chng_row)) // all bits are high
      begin
         reg_op_yVal1 = ymem_data1[239:192];
         //Now check the rest for the diag element
         if((ymem_data1[191:176])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data1[175:128];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data1[127:112])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data1[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data1[63:48])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data1[47:0];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[255:240])==(temp_chng_col)) 
         begin
            reg_op_dataEN   = 1'b0;
            reg_temp_yVal = ymem_data2[239:192];
         end
         else if((ymem_data2[191:176])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[175:128];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[127:112])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[63:48])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[47:0];
            reg_op_dataEN   = 1'b0;
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
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data1[63:48])==(temp_chng_col)) 
         begin
            reg_temp_yVal   = ymem_data1[47:0];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[255:240])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[239:192];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[191:176])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[175:128];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[127:112])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[63:48])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[47:0];
            reg_op_dataEN   = 1'b0;
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
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[255:240])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[239:192];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[191:176])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[175:128];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[127:112])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[63:48])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[47:0];
            reg_op_dataEN   = 1'b0;
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
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[191:176])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[175:128];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[127:112])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[63:48])==(temp_chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[47:0];
            reg_op_dataEN   = 1'b0;
         end
         else
         begin
            reg_temp_yVal   = 48'b0;
            reg_op_dataEN   = 1'b1;
         end
      end
      else
      begin
      //Shouldn't come here
      reg_op_yVal2       = 48'b0;
      reg_op_y_row       = 16'hffff; // invalid
      reg_op_dataEN      = 1'b0;
      reg_op_EX_EN       = 1'b0;
      end// if-else main nest
      
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
            if(temp_bit)
            begin
               reg_op_yVal1       = temp_yVal;
               reg_op_yVal2       = 48'b0;
               reg_op_EX_EN       = 1'b1;
               reg_op_Done        = 1'b1;
               reg_op_y_row       = op_y_row; //store old value
               reg_op_dataEN      = 1'b1;

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
               reg_op_y_row       = chng_col; 
               reg_op_dataEN      = 1'b0; // Don't fetch yet

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
            reg_op_dataEN   = 1'b1;
            next_state      = s3;
         end // if-else of exModDone
      end// end-if of |temp_yVal
      else
      begin
         //Now check for the diag element
         if((ymem_data1[255:240])==(temp_chng_col)) 
         begin
            if(exModDone)
            begin
               if(temp_bit)
               begin
                  reg_op_yVal1       = ymem_data1[239:192];
                  reg_op_yVal2       = 48'b0;
                  reg_op_EX_EN       = 1'b1;
                  reg_op_Done        = 1'b1;
                  reg_op_y_row       = 16'hffff;
                  reg_op_dataEN      = 1'b1;

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
                  reg_op_dataEN      = 1'b1;

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
               reg_op_dataEN      = 1'b1;

               reg_temp_yVal   = ymem_data1[239:192];
               next_state  = s3; 
            end // if-else of exModDone
         end
         else if((ymem_data1[191:176])==(temp_chng_col)) 
         begin
            if(exModDone)
            begin

               if(temp_bit)
               begin
                  reg_op_yVal1          = ymem_data1[175:128];
                  reg_op_yVal2          = 48'b0;
                  reg_op_EX_EN          = 1'b1;
                  reg_op_Done           = 1'b1;
                  reg_op_y_row          = 16'hffff;
                  reg_op_dataEN      = 1'b1;
   

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
                  reg_op_dataEN      = 1'b1;

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
                  reg_op_dataEN      = 1'b1;
                  next_state         = s3;
            end // if-else of exModDone
         end
         else if((ymem_data1[127:112])==(temp_chng_col)) 
         begin
            if (exModDone)
            begin
               if(temp_bit)
               begin
                  reg_op_yVal1       = ymem_data1[111:64];
                  reg_op_yVal2       = 48'b0;
                  reg_op_EX_EN       = 1'b1;
                  reg_op_Done        = 1'b1;
                  reg_op_y_row       = 16'hffff;
                  reg_op_dataEN      = 1'b1;

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
                  reg_op_dataEN      = 1'b1;

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
                  reg_op_dataEN      = 1'b1;

                  next_state         = s3;
            end // if-else of exModDone
         end
         else if((ymem_data1[63:48])==(temp_chng_col)) 
         begin
            if(exModDone)
            begin

               if(temp_bit)
               begin
                  reg_op_yVal1       = ymem_data1[47:0];
                  reg_op_EX_EN       = 1'b1;
                  reg_op_yVal2       = 48'b0;
                  reg_op_Done        = 1'b1;
                  reg_op_y_row       = 16'hffff;
                  reg_op_dataEN      = 1'b1;

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
                  reg_op_dataEN      = 1'b1;

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
                  reg_op_dataEN      = 1'b1;
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
            reg_op_dataEN      = 1'b1;
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
       reg_op_dataEN      = 1'b0;

   end//else-if - Op NOT Done

   end//s3
   endcase


end // always@(*)


endmodule
