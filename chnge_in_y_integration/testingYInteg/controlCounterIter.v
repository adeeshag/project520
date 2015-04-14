/* *****************************************************************
 * This module is used as the counter between the 20/30 iterations 
 * till the output values of v reac a convergence point.
 *
 * Inputs: 1. V SRAM Write Module Done Flag
 *         2. enable entire module (from Round robin)
 *
 * Output: 1. Read Y SRAM enable
 *         2. Total Iterations Done Flag (for roundRobin.v)
 * 
 *
 * *****************************************************************/

module controlCounterIter( input reset,                  input clock,
                           input in_accumCalcDoneFlag,   input in_enableEntireModule,

                           output reg op_enableAccumCalc, output reg op_allItersDoneFlag
      );

/* Wires and Reg */
//Registers
reg [5:0] controlCounterVal;
reg tempSwitchBit; // This bit is used to make enable low and then high


//Combinational logic
reg reg_op_enableAccumCalc, reg_op_allItersDoneFlag;
reg [5:0] reg_controlCounterVal;
reg reg_tempSwitchBit; // This bit is used to make enable low and then high

//Wires


/* Circuit Logic */

always @(posedge clock)
begin
   if(~(reset&in_enableEntireModule))
   begin
      op_enableAccumCalc   <= 1'b0;
      op_allItersDoneFlag  <= 1'b0;

      controlCounterVal    <= 5'd30;
      tempSwitchBit        <= 1'b0;

   end// reset
   else
   begin
      op_enableAccumCalc   <= reg_op_enableAccumCalc;
      op_allItersDoneFlag  <= reg_op_allItersDoneFlag;

      controlCounterVal    <= reg_controlCounterVal;
      tempSwitchBit        <= reg_tempSwitchBit;
   end// reset is high
end// always@

always@(*)
begin
   if(in_accumCalcDoneFlag)
   begin
      reg_op_enableAccumCalc  = 1'b0; // disable it. next enable it
      reg_tempSwitchBit       = 1'b1;
      reg_controlCounterVal   = controlCounterVal;
      reg_op_allItersDoneFlag = 1'b0;
   end// accumflag is high
   else if(tempSwitchBit)
   begin
      reg_tempSwitchBit       = 1'b0;

      if(|controlCounterVal)
      begin
         reg_controlCounterVal   = controlCounterVal - 5'd1;
         reg_op_enableAccumCalc  = 1'b1;
         reg_op_allItersDoneFlag = 1'b0;
      end
      else// reached the end of iterations
      begin
         reg_controlCounterVal   = 5'd30;
         reg_op_enableAccumCalc  = 1'b0;
         reg_op_allItersDoneFlag = 1'b1;
      end
   end// tempSwitchBit
   else
   begin
      reg_op_enableAccumCalc  = in_enableEntireModule;
      reg_tempSwitchBit       = 1'b0;
      reg_controlCounterVal   = controlCounterVal;
      reg_op_allItersDoneFlag = 1'b0;
   end



   
end// always@(*)
endmodule


