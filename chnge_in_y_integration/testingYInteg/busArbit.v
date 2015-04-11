/* *****************************************************************
 * This combinational logic module just multiplexes the incoming
 * address lines from the different modules so that only one circuit
 * is connected to the Y SRAM. In other words, to avoid "wired-OR"
 * logic while accessing the data files.
 *
 * Inputs: 1.  in_controlPathReadAddr1,in_controlPathReadAddr2
 *         3.  in_controlPathWE
 *         4.  in_controlPathWriteData
 *         5.  in_controlPathWriteAddr
 *         6.  in_writePathReadAddr1,in_writePathReadAddr2
 *         8.  in_writePathWE
 *         9.  in_writePathWriteData
 *         10. in_writePathWriteAddr
 *         11. in_yComputeModuleEnable
 *         12. in_yWriteModuleEnable
 *
 * Output: 1. op_yReadAddress1, op_yReadAddress2
 *         2. op_yWriteAddress
 *         3. op_yWriteEnable
 *         4. op_readData1, op_readData2
 *         5. op_writeData
 * 
 *
 * *****************************************************************/

module busArbit(input reset,
      input in_yComputeModuleEnable, input in_yWriteModuleEnable,
      input [10:0] in_controlPathReadAddr1, input [10:0] in_controlPathReadAddr2,
      input in_controlPathWE, input [10:0] in_controlPathWriteAddr,
      input [255:0] in_controlPathWriteData,

      input [10:0]  in_writePathReadAddr1, input [10:0]  in_writePathReadAddr2,
      input in_writePathWE, input [10:0] in_writePathWriteAddr,
      input [255:0] in_writePathWriteData,

      input [255:0] in_ReadData1, input [255:0] in_ReadData2,

      output reg [10:0]  op_yReadAddress1, output reg [10:0]  op_yReadAddress2,
      output reg op_yWriteEnable,          output reg [10:0] op_yWriteAddress,
      output reg [255:0] op_writeData

      );

/* Wires and Reg */

//Combinational logic

//Wires


/* Circuit Logic */

always@(*)
begin
   if(~reset)
   begin
      op_yReadAddress1  = 11'h7ff;
      op_yReadAddress2  = 11'h7ff;
      op_yWriteEnable   = 1'b0;
      op_yWriteAddress  = 11'h7ff;
      op_writeData      = 256'b0;
   end//reset
   else
   begin
      case({in_yComputeModuleEnable,in_yWriteModuleEnable})
      2'b00:
      begin
         op_yReadAddress1  = in_controlPathReadAddr1;
         op_yReadAddress2  = in_controlPathReadAddr2;
         op_yWriteEnable   = in_controlPathWE;
         op_yWriteAddress  = in_controlPathWriteAddr;
         op_writeData      = in_controlPathWriteData;
      end//00
      2'b01:
      begin
         op_yReadAddress1  = in_writePathReadAddr1;
         op_yReadAddress2  = in_writePathReadAddr2;
         op_yWriteEnable   = in_writePathWE;
         op_yWriteAddress  = in_writePathWriteAddr;
         op_writeData      = in_writePathWriteData;
      end//01
      2'b10:
      begin
         op_yReadAddress1  = in_controlPathReadAddr1;
         op_yReadAddress2  = in_controlPathReadAddr2;
         op_yWriteEnable   = in_controlPathWE;
         op_yWriteAddress  = in_controlPathWriteAddr;
         op_writeData      = in_controlPathWriteData;
      end//10
      default: // not supposed to happen
      begin
         op_yReadAddress1  = in_controlPathReadAddr1;
         op_yReadAddress2  = in_controlPathReadAddr2;
         op_yWriteEnable   = in_controlPathWE;
         op_yWriteAddress  = in_controlPathWriteAddr;
         op_writeData      = in_controlPathWriteData;
      end// default
      endcase
   end// not reset
   
end

endmodule
