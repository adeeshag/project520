/* *****************************************************************
 * This module just selects which module should
 * be active at any given time. It operates based on the done flags
 * received from each module. It also controls the bus control
 * logic.
 *
 * Inputs: 1. Control Path done flag
 *         2. write module done flag
 *
 * Output: 1. updateY Module enable
 *         2. write Y module enable 
 * 
 *
 * *****************************************************************/

module roundRobin(input reset, input clock,
      input in_updateYCtrlPathDoneFlag, input in_updateYwriteDoneFlag,

      output reg op_updateYmoduleEnable, output reg op_writeYvalEnable

      );

/* Wires and Reg */

//Combinational logic
reg reg_op_updateYmoduleEnable,reg_op_writeYvalEnable;

//Wires


/* Circuit Logic */

always @(posedge clock)
begin
   if(~(reset))
   begin
      op_updateYmoduleEnable  <= 1'b1; // change this later
      op_writeYvalEnable      <= 1'b0;

   end// reset
   else
   begin
      op_updateYmoduleEnable  <= reg_op_updateYmoduleEnable;
      op_writeYvalEnable      <= reg_op_writeYvalEnable;

   end// reset is high
end// always@

always@(*)
begin
   case({in_updateYCtrlPathDoneFlag,in_updateYwriteDoneFlag})
   2'b00:
   begin
      reg_op_updateYmoduleEnable = op_updateYmoduleEnable;
      reg_op_writeYvalEnable     = op_writeYvalEnable;
   end//00
   2'b01: // this means that the write is actually done and we can start 
   begin  // computing matrix data
      reg_op_updateYmoduleEnable = 1'b0;
      reg_op_writeYvalEnable     = 1'b0;
   end
   2'b10: // this means that the computation is done
   begin      // we need to write the data in Y SRAM
      reg_op_updateYmoduleEnable = 1'b0;
      reg_op_writeYvalEnable     = 1'b1;
   end
   default: // shouldn't happen
   begin
      reg_op_updateYmoduleEnable = 1'b0;
      reg_op_writeYvalEnable     = 1'b0;
   end
   endcase
end// always@(*)
endmodule