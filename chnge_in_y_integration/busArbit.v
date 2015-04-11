/* *****************************************************************
 * This combinational logic module just multiplexes the incoming
 * address lines from the different modules so that only one circuit
 * is connected to the Y SRAM. In other words, to avoid "wired-OR"
 * logic while accessing the data files.
 *
 * Inputs: 1.  in_controlPathReadAddr1,in_controlPathReadAddr2
 *         2.  in_controlPathReadData1, in_controlPathReadData2
 *         3.  in_controlPathWE
 *         4.  in_controlPathWriteData
 *         5.  in_controlPathWriteAddr
 *         6.  in_writePathReadAddr1,in_writePathReadAddr2
 *         7.  in_writePathReadData1, in_writePathReadData2
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
      input [47:0] in_controlPathReadAddr1, input [47:0] in_controlPathReadAddr2,
      input [255:0] in_controlPathReadData1, input [255:0] in_controlPathReadData2,
      input in_controlPathWE, input [47:0] in_controlPathWriteAddr,
      input [255:0] in_controlPathWriteData,

      input [47:0]  in_writePathReadAddr1, input [47:0]  in_writePathReadAddr2,
      input [255:0] in_writePathReadData1, input [255:0] in_writePathReadData2,
      input in_writePathWE, input [47:0] in_controlPathWriteAddr,
      input [255:0] in_writePathWriteData,

      output reg [47:0]  op_yReadAddress1, output reg [47:0]  op_yReadAddress2,
      output reg [255:0] op_readData1,     output reg [255:0] op_readData2,
      output reg op_yWriteEnable,          output reg [47:0] op_yWriteAddress,
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
      op_yReadAddress1  = in_controlPathReadAddr1;
      op_yReadAddress2  = in_controlPathReadAddr2;
      op_readData1      = in_controlPathReadData1;
      op_readData2      = in_controlPathReadData2;
      op_yWriteEnable   = in_controlPathWE;
      op_yWriteAddress  = in_controlPathWriteAddr;
      op_writeData      = in_controlPathWriteData;
   end//reset
   else
   begin
      case({in_yComputeModuleEnable,in_yWriteModuleEnable})
      2'b00:
      begin
         op_yReadAddress1  = in_controlPathReadAddr1;
         op_yReadAddress2  = in_controlPathReadAddr2;
         op_readData1      = in_controlPathReadData1;
         op_readData2      = in_controlPathReadData2;
         op_yWriteEnable   = in_controlPathWE;
         op_yWriteAddress  = in_controlPathWriteAddr;
         op_writeData      = in_controlPathWriteData;
      end//00
      2'b01:
      begin
         op_yReadAddress1  = in_writePathReadAddr1;
         op_yReadAddress2  = in_writePathReadAddr2;
         op_readData1      = in_writePathReadData1;
         op_readData2      = in_writePathReadData2;
         op_yWriteEnable   = in_writePathWE;
         op_yWriteAddress  = in_writePathWriteAddr;
         op_writeData      = in_writePathWriteData;
      end//01
      2'b10:
      begin
         op_yReadAddress1  = in_controlPathReadAddr1;
         op_yReadAddress2  = in_controlPathReadAddr2;
         op_readData1      = in_controlPathReadData1;
         op_readData2      = in_controlPathReadData2;
         op_yWriteEnable   = in_controlPathWE;
         op_yWriteAddress  = in_controlPathWriteAddr;
         op_writeData      = in_controlPathWriteData;
      end//10
      default: // not supposed to happen
      begin
         op_yReadAddress1  = in_controlPathReadAddr1;
         op_yReadAddress2  = in_controlPathReadAddr2;
         op_readData1      = in_controlPathReadData1;
         op_readData2      = in_controlPathReadData2;
         op_yWriteEnable   = in_controlPathWE;
         op_yWriteAddress  = in_controlPathWriteAddr;
         op_writeData      = in_controlPathWriteData;
      end// default
   end// not reset
   
end

endmodule
