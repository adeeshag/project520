/* ***************************************************************
 * This module stores the addresses and the OneHot values of the
 * Diagonal and NonDiagonal elements to be written into the Y mem
 * as and when the done flags arrive. 
 * Once all the calculations are done, we first fetch the row(s)
 * and then overwrite the new data on the fetched row(s) back to
 * the same location. This process is repeated for both the sets
 * of data and once the computation is done, we set a done flag.
 *
 * Inputs: 1. 48bit {real,img} part from change.txt
 *         2. 11 bit Diagonal & Non Diag Addresses
 *         3. 4 bit Diag and Non Diag OneHot values
 *         4. DPDoneFlag and CPDoneFlag
 *         5. Two 256 bit yReadData
 *         6. 48 bit computed Y Diag value
 *         7. clock,reset
 *
 * Outputs: 1. 256bit op_writeData
 *          2. 11bit op_writeAddress, op_readStoreAddr
 *          3. 1bit op_WEbit
 *          4. 1bit op_filtEN/op_writeDone - To turn off filtEN.
 *                                           Needs better control
 *                                           logic since we need
 *                                           to consider output
 *                                           module's iteration
 * 
 *
 * ***************************************************************/

module busWriteY(input clock, input reset, 
      input cpDoneFlag, input dpDoneFlag,
      input [10:0] inDiagAddr, input [10:0] inNonDAddr,
      input [3:0] inDiagOH, input [3:0] inNonDiagOH,
      input [255:0] inYreadData1, input [255:0] inYreadData2,
      input [47:0] yComputedVal, input [47:0] ychngData, // concatenated value from change.txt

      output reg [255:0] op_writeData, output reg [10:0] op_writeAddress,
      output reg [10:0] op_readStoreAddr, output reg op_WEbit, 
      output reg op_writeDone
      );

/* Wires and Reg */
reg [1:0]      current_state, next_state;
reg [255:0]    tempStoreData;
reg [10:0]     tempDiagAddr1,tempDiagAddr2,tempNonDiagAddr1,tempNonDiagAddr2;
reg [3:0]      tempDiagOH1,tempDiagOH2,tempNonDiagOH1,tempNonDiagOH2;
reg [47:0]     tempYnonDiagVal;

//Combinational logic
reg [10:0]     reg_tempDiagAddr1,reg_tempDiagAddr2,reg_tempNonDiagAddr1,reg_tempNonDiagAddr2;
reg [3:0]      reg_tempDiagOH1,reg_tempDiagOH2,reg_tempNonDiagOH1,reg_tempNonDiagOH2;

reg            reg_op_WEBit,reg_op_writeDone;
reg [255:0]    reg_op_writeData, reg_tempStoreData;
reg [10:0]     reg_op_writeAddress,reg_op_readStoreAddr;
reg [47:0]     reg_tempYnonDiagVal;

/* parameters */
parameter s0 = 0,
          s1 = 1,
          s2 = 2,
          s3 = 3;

/* modules */
always@(posedge clock)
begin
   if(~(reset))
   begin
      op_writeData      <= 256'b0;
      op_writeAddress   <= 11'b0;
      op_WEbit          <= 1'b0;
      op_readStoreAddr  <= 11'b0
      op_writeDone      <= 1'b0;

      tempStoreData     <= 256'b0;
      tempDiagAddr1     <= 11'b0;
      tempDiagAddr2     <= 11'b0;
      tempNonDiagAddr1  <= 11'b0;
      tempNonDiagAddr2  <= 11'b0;
      tempDiagOH1       <= 4'b0;
      tempDiagOH2       <= 4'b0;
      tempNonDiagOH1    <= 4'b0;
      tempNonDiagOH2    <= 4'b0;
      tempYnonDiagVal   <= 48'b0;

      current_state     <= s0;

   end//reset
   else
   begin
      op_writeData      <= reg_op_writeData;
      op_writeAddress   <= reg_op_writeAddress;
      op_WEbit          <= reg_op_WEBit;
      op_readStoreAddr  <= reg_op_readStoreAddr;
      op_writeDone      <= reg_op_writeDone;

      tempStoreData     <= reg_tempStoreData;
      tempDiagAddr1     <= reg_tempDiagAddr1;
      tempDiagAddr2     <= reg_tempDiagAddr2;
      tempNonDiagAddr1  <= reg_tempNonDiagAddr1;
      tempNonDiagAddr2  <= reg_tempNonDiagAddr2;
      tempDiagOH1       <= reg_tempDiagOH1;
      tempDiagOH2       <= reg_tempDiagOH2;
      tempNonDiagOH1    <= reg_tempNonDiagOH1;
      tempNonDiagOH2    <= reg_tempNonDiagOH2;
      tempYnonDiagVal   <= reg_tempYnonDiagVal;

      current_state     <= next_state;
   end// not reset
end// posedge clock

always@(*)
begin
   case(current_state):
   s0:
   begin
   end//s0
   s1:
   begin
   end//s1
   s2:
   begin
   end//s2
   s3:
   begin
   end//s3

end//awlays@(*)

endmodule
