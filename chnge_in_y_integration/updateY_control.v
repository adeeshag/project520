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

module updateY_control(clock, reset, exModDone, 
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
      s3 = 3,
      s4 = 4,
      s5 = 5,
      s6 = 6,
      s7 = 7;

/* Wires and regs */
reg [2:0] current_state, next_state;
reg [47:0] op_yVal1,op_yVal2;
reg [47:0] temp_yVal;
reg [15:0] op_y_row;
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

      current_state  <= 3'b0;

      op_yVal1       <= 48'b0;
      op_yVal2       <= 48'b0;
      op_EX_EN       <= 1'b0;
      op_Done        <= 1'b0;
      op_y_row       <= 16'hffff;
      op_DataEN      <= 1'b0;

      temp_yVal      <= 48'b0;
      temp_bit       <= 1'b0;
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
      reg_op_y_row    = chng_row;
      reg_temp_yVal   = 48'b0;
      reg_op_dataEN   = 1'b1; // start fetching data
      reg_op_EX_EN    = 1'b0;

      // Set next state
      if(yMemDataReadyNextCycle) // get this from the yAddrDecoder.v 
      begin
         next_state = s2;
      end //else-if
      else // data not ready
      begin
         next_state = s1;
      end

   end// --s1 case

/***********************     S2       ********************/
   s2: begin
   //Set outputs
   //Calc y Diag1
      if((&(ymem_data1[255:253]))&(ymem_data1[247:240]==chng_row)) // all bits are high
      begin
         reg_op_yVal1 = ymem_data1[239:192];
         //Now check the rest for the diag element
         if((ymem_data1[191:176])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data1[175:128];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data1[127:112])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data1[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data1[63:48])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data1[47:0];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[255:240])==(chng_col)) 
         begin
            reg_op_dataEN   = 1'b0;
            reg_temp_yVal = ymem_data2[239:192];
         end
         else if((ymem_data2[191:176])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[175:128];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[127:112])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[63:48])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[47:0];
            reg_op_dataEN   = 1'b0;
         end
         else
         begin
            reg_temp_yVal   = 48'b0;
            reg_op_dataEN   = 1'b1;
         end
         //end if-else
         //
      end
      else if((&(ymem_data1[191:189]))&(ymem_data1[187:176]==chng_row))
      begin
         reg_op_yVal1 = ymem_data1[175:128];

         //Now check the rest for the diag element
         if((ymem_data1[127:112])==(chng_col)) 
         begin
            reg_temp_yVal   = ymem_data1[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data1[63:48])==(chng_col)) 
         begin
            reg_temp_yVal   = ymem_data1[47:0];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[255:240])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[239:192];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[191:176])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[175:128];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[127:112])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[63:48])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[47:0];
            reg_op_dataEN   = 1'b0;
         end
         else
         begin
            reg_temp_yVal = 48'b0;
            reg_op_dataEN   = 1'b1;
         end
         //end if-else
         //
      end
      else if((&(ymem_data1[127:125]))&(ymem_data1[119:112]==chng_row)) 
      begin
         reg_op_yVal1    = ymem_data1[111:64];

         //Now check the rest for the diag element
         if((ymem_data1[63:48])==(chng_col)) 
         begin
            reg_temp_yVal   = ymem_data1[47:0];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[255:240])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[239:192];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[191:176])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[175:128];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[127:112])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[63:48])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[47:0];
            reg_op_dataEN   = 1'b0;
         end
         else
         begin
            reg_temp_yVal   = 48'b0;
            reg_op_dataEN   = 1'b1;
         end
         //end if-else
         //
      end
      else if((&(ymem_data1[63:61]))&(ymem_data1[55:48]==chng_row)) 
      begin
         reg_op_yVal1    = ymem_data1[47:0];

         if((ymem_data2[255:240])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[239:192];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[191:176])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[175:128];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[127:112])==(chng_col)) 
         begin
            reg_temp_yVal = ymem_data2[111:64];
            reg_op_dataEN   = 1'b0;
         end
         else if((ymem_data2[63:48])==(chng_col)) 
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
      reg_op_yVal2       = 48'bz;
      reg_op_y_row       = 16'hffff; // invalid
      reg_op_dataEN      = 1'b0;
      reg_op_EX_EN       = 1'b0;
      end// if-else main nest
      
      // Set next state
      reg_op_yVal2    = {chng_real,chng_img};
      reg_op_EX_EN    = 1'b1;
      reg_op_Done     = 1'b0;

      next_state = s3;

   end// s2
/***********************     S3       ********************/
   s3: begin
   // A Wait for Yij State

      if(|temp_yVal)
      begin
         if(exModDone)
         begin
            reg_op_yVal1       = temp_yVal;
            reg_op_yVal2       = 48'b0;
            reg_op_EX_EN       = 1'b1; // Calculate second part
            reg_op_Done        = 1'b0;
            reg_op_y_row       = 16'hffff; 
            reg_op_dataEN      = 1'b0; //Don't fetch data till next EX is done

            reg_temp_yVal      = temp_yVal; // maintain the data

            next_state         = s4;
         end
         else// --else-reg_-exmodDone
         begin
         //If execution isn't done but data is found
            reg_op_yVal1    = 48'b0; // don't matter
            reg_op_yVal2    = 48'b0;
            reg_op_EX_EN    = 1'b1;
            reg_op_Done     = 1'b0;
            reg_op_y_row    = 16'hffff; 
            reg_op_dataEN   = 1'b0;

            reg_temp_yVal   = temp_yVal; // maintain the data
            next_state      = s3; // stay in s3
         end // if-else of exModDone
      end// end-if of |temp_yVal
      else
      begin
         //Now check for the diag element
         if((ymem_data1[255:240])==(chng_col)) 
         begin
            if(exModDone)
            begin
               reg_op_yVal1       = ymem_data1[239:192];
               reg_op_yVal2       = 48'b0;
               reg_op_EX_EN       = 1'b1;
               reg_op_Done        = 1'b0;
               reg_op_y_row       = 16'hffff;
               reg_op_dataEN      = 1'b0; 

               reg_temp_yVal      = ymem_data1[239:192];

               next_state         = s4;
            end
            else
            begin
            //If execution isn't done
               reg_op_yVal1    = 48'b0;
               reg_op_yVal2    = 48'b0;
               reg_op_EX_EN    = 1'b1;
               reg_op_Done     = 1'b0;
               reg_op_y_row    = 16'hffff;// Don't fetch 
               reg_op_dataEN      = 1'b0;

               reg_temp_yVal   = ymem_data1[239:192];

               next_state  = s3; 
            end // if-else of exModDone
         end
         else if((ymem_data1[191:176])==(chng_col)) 
         begin
            if(exModDone)
            begin
               reg_op_yVal1          = ymem_data1[175:128];
               reg_op_yVal2          = 48'b0;
               reg_op_EX_EN          = 1'b1;
               reg_op_Done           = 1'b0;
               reg_op_y_row          = 16'hffff;// Don't fetch 
               reg_op_dataEN         = 1'b0;

               reg_temp_yVal         = ymem_data1[175:128];

               next_state            = s4;
            end
            else
            begin
            //If execution isn't done
               reg_op_yVal1    = 48'b0;
               reg_op_yVal2    = 48'b0;
               reg_op_EX_EN    = 1'b1;
               reg_op_Done     = 1'b0;
               reg_op_y_row    = 16'hffff;// Don't fetch 
               reg_op_dataEN   = 1'b0;

               reg_temp_yVal   = ymem_data1[175:128];

               next_state  = s3; 
            end // if-else of exModDone
         end
         else if((ymem_data1[127:112])==(chng_col)) 
         begin
            if (exModDone)
            begin
               reg_op_yVal1       = ymem_data1[111:64];
               reg_op_yVal2       = 48'b0;
               reg_op_EX_EN       = 1'b1;
               reg_op_Done        = 1'b0;
               reg_op_y_row       = 16'hffff;
               reg_op_dataEN      = 1'b0;

               reg_temp_yVal      = ymem_data1[111:64];

               next_state         = s4;
            end
            else
            begin
            //If execution isn't done
               reg_op_yVal1    = 48'b0;
               reg_op_yVal2    = 48'b0;
               reg_op_EX_EN    = 1'b1;
               reg_op_Done     = 1'b0;
               reg_op_y_row    = 16'hffff;// Don't fetch 
               reg_op_dataEN   = 1'b0;

               reg_temp_yVal   = ymem_data1[111:64];

               next_state  = s3; 
            end // if-else of exModDone
         end
         else if((ymem_data1[63:48])==(chng_col)) 
         begin
            if(exModDone)
            begin
               reg_op_yVal1       = ymem_data1[47:0];
               reg_op_EX_EN       = 1'b1;
               reg_op_yVal2       = 48'b0;
               reg_op_Done        = 1'b0;
               reg_op_y_row       = 16'hffff;
               reg_op_dataEN      = 1'b0;

               reg_temp_yVal      = ymem_data1[47:0];

               next_state         = s4;
            end
            else
            begin
            //If execution isn't done
               reg_op_yVal1    = 48'b0;
               reg_op_yVal2    = 48'b0;
               reg_op_EX_EN    = 1'b1;
               reg_op_Done     = 1'b0;
               reg_op_y_row    = 16'hffff;// Don't fetch 
               reg_op_dataEN   = 1'b0;

               reg_temp_yVal   = ymem_data1[47:0];

               next_state  = s3; 
            end // if-else of exModDone
         end
         else if((ymem_data2[255:240])==(chng_col)) 
         begin
            if(exModDone)
            begin
               reg_op_yVal1       = ymem_data2[239:192];
               reg_op_yVal2       = 48'b0;
               reg_op_EX_EN       = 1'b1;
               reg_op_Done        = 1'b0;
               reg_op_y_row       = 16'hffff;
               reg_op_dataEN      = 1'b0; 

               reg_temp_yVal      = ymem_data2[239:192];

               next_state         = s4;
            end
            else
            begin
            //If execution isn't done
               reg_op_yVal1    = 48'b0;
               reg_op_yVal2    = 48'b0;
               reg_op_EX_EN    = 1'b1;
               reg_op_Done     = 1'b0;
               reg_op_y_row    = 16'hffff;// Don't fetch 
               reg_op_dataEN      = 1'b0;

               reg_temp_yVal   = ymem_data2[239:192];

               next_state  = s3; 
            end // if-else of exModDone
         end
         else if((ymem_data2[191:176])==(chng_col)) 
         begin
            if(exModDone)
            begin
               reg_op_yVal1          = ymem_data2[175:128];
               reg_op_yVal2          = 48'b0;
               reg_op_EX_EN          = 1'b1;
               reg_op_Done           = 1'b0;
               reg_op_y_row          = 16'hffff;// Don't fetch 
               reg_op_dataEN         = 1'b0;

               reg_temp_yVal         = ymem_data2[175:128];

               next_state            = s4;
            end
            else
            begin
            //If execution isn't done
               reg_op_yVal1    = 48'b0;
               reg_op_yVal2    = 48'b0;
               reg_op_EX_EN    = 1'b1;
               reg_op_Done     = 1'b0;
               reg_op_y_row    = 16'hffff;// Don't fetch 
               reg_op_dataEN   = 1'b0;

               reg_temp_yVal   = ymem_data2[175:128];

               next_state  = s3; 
            end // if-else of exModDone
         end
         else if((ymem_data2[127:112])==(chng_col)) 
         begin
            if (exModDone)
            begin
               reg_op_yVal1       = ymem_data2[111:64];
               reg_op_yVal2       = 48'b0;
               reg_op_EX_EN       = 1'b1;
               reg_op_Done        = 1'b0;
               reg_op_y_row       = 16'hffff;
               reg_op_dataEN      = 1'b0;

               reg_temp_yVal      = ymem_data2[111:64];

               next_state         = s4;
            end
            else
            begin
            //If execution isn't done
               reg_op_yVal1    = 48'b0;
               reg_op_yVal2    = 48'b0;
               reg_op_EX_EN    = 1'b1;
               reg_op_Done     = 1'b0;
               reg_op_y_row    = 16'hffff;// Don't fetch 
               reg_op_dataEN   = 1'b0;

               reg_temp_yVal   = ymem_data2[111:64];

               next_state  = s3; 
            end // if-else of exModDone
         end
         else if((ymem_data2[63:48])==(chng_col)) 
         begin
            if(exModDone)
            begin
               reg_op_yVal1       = ymem_data2[47:0];
               reg_op_EX_EN       = 1'b1;
               reg_op_yVal2       = 48'b0;
               reg_op_Done        = 1'b0;
               reg_op_y_row       = 16'hffff;
               reg_op_dataEN      = 1'b0;

               reg_temp_yVal      = ymem_data2[47:0];

               next_state         = s4;
            end
            else
            begin
            //If execution isn't done
               reg_op_yVal1    = 48'b0;
               reg_op_yVal2    = 48'b0;
               reg_op_EX_EN    = 1'b1;
               reg_op_Done     = 1'b0;
               reg_op_y_row    = 16'hffff;// Don't fetch 
               reg_op_dataEN   = 1'b0;

               reg_temp_yVal   = ymem_data2[47:0];

               next_state  = s3; 
            end // if-else of exModDone
         end
         else // DATA NOT FOUND. SEARCH
         begin
            reg_op_yVal1             = 48'b0;
            reg_op_yVal2             = 48'b0;
            reg_op_Done              = 1'b0;
            reg_op_y_row             = 16'hffff; //fetch next row
            reg_op_dataEN            = 1'b1;

            reg_temp_yVal            = 48'b0;

            reg_op_EX_EN             = 1'b1; // let it keep executing because it shouldn't lose whether
                                             // or not it has to add or
                                             // subtract. if we reset, it'll
                                             // reset to subtract.

            next_state               = s3;
         //
         end //else-if for different ymem data search
      end// if-else of |TempData

   end//s3
/***********************     S4       ********************/
   s4: begin
   //s4

      // Set next state
      if(exModDone)
      begin

         reg_op_yVal1    = 48'b0;
         reg_op_yVal2    = 48'b0;
         reg_op_Done     = 1'b0;
         reg_op_y_row    = chng_col;
         reg_temp_yVal   = temp_yVal; // retain old value
         reg_op_dataEN   = 1'b1; // start fetching data
         reg_op_EX_EN    = 1'b0;

         next_state      = s4;
         
      end// --exModDone
      else if(yMemDataReadyNextCycle) // get this from the yAddrDecoder.v 
      begin

         reg_op_yVal1    = 48'b0;
         reg_op_yVal2    = 48'b0;
         reg_op_Done     = 1'b0;
         reg_op_y_row    = chng_col;
         reg_temp_yVal   = temp_yVal; // retain old value
         reg_op_dataEN   = 1'b1; // start fetching data
         reg_op_EX_EN    = 1'b0;

         next_state      = s5;
      end //else-if
      else // data not ready or !exModDone
      begin
         reg_op_yVal1    = 48'b0;
         reg_op_yVal2    = 48'b0;
         reg_op_Done     = 1'b0;
         reg_op_y_row    = chng_col;
         reg_temp_yVal   = temp_yVal; // retain old value
         reg_op_dataEN   = 1'b1; // start fetching data
         reg_op_EX_EN    = 1'b1; // this can be either exModDone or data isn't ready

         next_state      = s4;
      end

   end //s4

/***********************     S5       ********************/
   s5: begin
   //s5
      reg_op_yVal2    = {chng_real,chng_img};
      reg_op_Done     = 1'b0;
      reg_op_y_row    = 16'hffff;
      reg_temp_yVal   = temp_yVal; // retain old value
      reg_op_dataEN   = 1'b0; // fetching data is done 
      reg_op_EX_EN    = 1'b1; // this can be either exModDone or data isn't ready


      if((&(ymem_data1[255:253]))&(ymem_data1[247:240]==chng_col)) // all bits are high
      begin
         reg_op_yVal1 = ymem_data1[239:192];
      end
      else if((&(ymem_data1[191:189]))&(ymem_data1[183:176]==chng_col))
      begin
         reg_op_yVal1 = ymem_data1[175:128];
      end
      else if((&(ymem_data1[127:125]))&(ymem_data1[119:112]==chng_col)) 
      begin
         reg_op_yVal1    = ymem_data1[111:64];
      end
      else if((&(ymem_data1[63:61]))&(ymem_data1[55:48]==chng_col)) 
      begin
         reg_op_yVal1    = ymem_data1[47:0];
      end
      else
      begin
      //Shouldn't come here
      reg_op_yVal1       = 48'bz;
      reg_op_y_row       = 16'hffff; // invalid
      reg_op_dataEN      = 1'b0;
      reg_op_EX_EN       = 1'b0;
      end// if-else main nest

      next_state =   s6;
   end //s5

/***********************     S6       ********************/
   s6: begin
   //s6
      reg_op_yVal2    = 48'b0;
      reg_op_Done     = 1'b0;
      reg_op_y_row    = 16'hffff;
      reg_temp_yVal   = temp_yVal; // retain old value
      reg_op_dataEN   = 1'b0; // fetching data is done 
      reg_op_EX_EN    = 1'b1; // this can be either exModDone or data isn't ready

      if(exModDone)
      begin
         reg_op_yVal1   = temp_yVal;

         next_state     = s7;
         
      end
      else
      begin
         reg_op_yVal1   = 48'b0;

         next_state     = s6;
         
      end



   end //s6
/***********************     S7       ********************/
   s7: begin
   //s7
      reg_op_yVal1    = 48'b0;
      reg_op_yVal2    = 48'b0;
      reg_op_Done     = 1'b0;
      reg_op_y_row    = 16'hffff;
      reg_temp_yVal   = temp_yVal;
      reg_op_dataEN   = 1'b0; // fetching data is done 

      if(exModDone)
      begin
         reg_op_EX_EN    = 1'b0; // now going into sleep stat

         next_state      = s0;
      end
      else
      begin
         reg_op_EX_EN    = 1'b1; // 

         next_state      = s7;
         
      end//exModDone

   end //s7
   endcase


end // always@(*)


endmodule
