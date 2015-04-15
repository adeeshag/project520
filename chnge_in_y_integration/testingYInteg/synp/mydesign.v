/* *************************************************************
 * This module contains all the control and data logic for the 
 * Jacobi matrix solver.
 *
 * ************************************************************/

//(like  top.v)
//
module myDesign(clock, reset,
      mydes_chgTxt_row,mydes_chgTxt_col, 
      mydes_chgTxt_real,mydes_chgTxt_img, 
      mydes_ySRAM_rowRead1,mydes_ySRAM_rowRead2,
      mydes_opYval,
      mydes_ydataWrite,
      mydes_op_yReadAddress1, mydes_op_yReadAddress2, mydes_op_yWriteAddress,
      mydes_op_yWriteEnable,

      mydes_op_fpIn1, mydes_op_fpIn2,
      mydes_op_fpMode,
      mydes_in_fpOut
      );

/********** Module Inputs and Outputs **************/
	input clock, reset;

   input [15:0]   mydes_chgTxt_row,mydes_chgTxt_col; //From change.txt
   input [23:0]   mydes_chgTxt_real, mydes_chgTxt_img;
   input [255:0]  mydes_ySRAM_rowRead1;
   input [255:0]  mydes_ySRAM_rowRead2;

   output [47:0]   mydes_opYval;
   output [255:0]  mydes_ydataWrite;
   output [10:0]   mydes_op_yReadAddress1, mydes_op_yReadAddress2, mydes_op_yWriteAddress;
   output mydes_op_yWriteEnable;         
// For fp_DW

   output wire [47:0] mydes_op_fpIn1, mydes_op_fpIn2;
   output wire        mydes_op_fpMode;
   
   input  [47:0]      mydes_in_fpOut;


	
/************************ Wires *******************/	
	


   wire [10:0]  wire_yAddrOut1;
   wire [10:0]  wire_yAddrOut2;

   wire [10:0]  wire_yAddrWrite;
   wire [255:0] wire_yDataWrite;

   wire [10:0]   wire_writeDiagAddr,
                 wire_writeNonDiagAddr;
   wire [3:0]    wire_writeDiagOneHot,
               wire_writeNonDiagOneHot;
// For write logic

   wire bWY_cpDoneFlag, bWY_dpDoneFlag,bWY_inModuleEnable;
   wire [10:0]  bWY_inDiagAddr, bWY_inNonDAddr;
   wire [3:0]   bWY_inDiagOH, bWY_inNonDiagOH;
   wire [255:0] inYreadData1, inYreadData2;
   wire [47:0]  bWY_inYComputedVal;
   wire [47:0]  bWY_inYchngData;
   wire [255:0] bWY_op_writeData;     wire [10:0] bWY_op_writeAddress;
   wire [10:0]  bWY_op_readStoreAddr; wire bWY_op_WEbit; 
   wire bWY_op_writeDone;

// For roundRobin

   wire wire_updateYmoduleEnable, wire_writeYvalEnable;
   wire wire_dataPathDoneFlag,wire_filtYopDone;

//Testing	

 /*********Assign For testing ******/
   assign mydes_yMatOut1 = mydes_ySRAM_rowRead1;
   assign mydes_yMatOut2 = mydes_ySRAM_rowRead2;
/***************** Modules Instan *******************/
	updateYcomputation uYc_inst (	.clock(clock),  .reset(reset), .computationEnable(wire_updateYmoduleEnable),

            .uYc_chgTxt_row(mydes_chgTxt_row),  .uYc_chgTxt_col(mydes_chgTxt_col),
            .uYc_chgTxt_real(mydes_chgTxt_real), .uYc_chgTxt_img(mydes_chgTxt_img),
            .uYc_ySRAM_rowRead1(mydes_ySRAM_rowRead1), .uYc_ySRAM_rowRead2(mydes_ySRAM_rowRead2), 
            .uYc_yMatAddrOut1(wire_yAddrOut1), .uYc_yMatAddrOut2(wire_yAddrOut2), 
            .uYc_dataPathDoneFlag(mydes_dataPathDoneFlag), .uYc_filtYopDone(mydes_filtYopDone),
            .uYc_opYval(mydes_opYval),// might not need this output
            .uYc_writeDiagAddr(wire_writeDiagAddr),     .uYc_writeNonDiagAddr(wire_writeNonDiagAddr),
            .uYc_writeDiagOneHot(wire_writeDiagOneHot), .uYc_writeNonDiagOneHot(wire_writeNonDiagOneHot),

      // For fp_DW

            .uYC_op_fpIn1(mydes_op_fpIn1), .uYC_op_fpIn2(mydes_op_fpIn2),
            .uYC_op_fpMode(mydes_op_fpMode),
            .uYC_in_fpOut(mydes_in_fpOut)
			);

//-----------------
   roundRobin rR_inst(.reset(reset), .clock(clock),
      .in_updateYCtrlPathDoneFlag(mydes_filtYopDone),   .in_updateYwriteDoneFlag(bWY_op_writeDone),

      .op_updateYmoduleEnable(wire_updateYmoduleEnable),     .op_writeYvalEnable(wire_writeYvalEnable)
      );
//------------


busArbit busArbit_inst(.reset(reset),
       .in_yComputeModuleEnable(wire_updateYmoduleEnable),   .in_yWriteModuleEnable(wire_writeYvalEnable),

       .in_controlPathReadAddr1(wire_yAddrOut1),   .in_controlPathReadAddr2(wire_yAddrOut2),
       .in_controlPathWE(1'b0),          .in_controlPathWriteAddr(11'h7ff),
       .in_controlPathWriteData(256'b0),

       .in_writePathReadAddr1(bWY_op_writeAddress), .in_writePathReadAddr2(bWY_op_readStoreAddr),
       .in_writePathWE(bWY_op_WEbit),        .in_writePathWriteAddr(bWY_op_writeAddress),
       .in_writePathWriteData(bWY_op_writeData),

       .op_yReadAddress1(mydes_op_yReadAddress1), .op_yReadAddress2(mydes_op_yReadAddress2),
       .op_yWriteEnable(mydes_op_yWriteEnable),  .op_yWriteAddress(mydes_op_yWriteAddress),
       .op_writeData(mydes_ydataWrite)

      );
//------------

busWriteY busWriteY_inst(.clock(clock), .reset(reset), .inModuleEnable(wire_writeYvalEnable),
      .cpDoneFlag(mydes_filtYopDone),    .dpDoneFlag(mydes_dataPathDoneFlag),
      .inDiagAddr(wire_writeDiagAddr),    .inNonDAddr(wire_writeNonDiagAddr),
      .inDiagOH(wire_writeDiagOneHot),        .inNonDiagOH(wire_writeNonDiagOneHot),
      .inYreadData1(mydes_ySRAM_rowRead1),  .inYreadData2(mydes_ySRAM_rowRead2),
      .inYComputedVal(mydes_opYval),
      .inYchngData({mydes_chgTxt_real,mydes_chgTxt_img}), 

      .op_writeData(bWY_op_writeData),     .op_writeAddress(bWY_op_writeAddress),
      .op_readStoreAddr(bWY_op_readStoreAddr), .op_WEbit(bWY_op_WEbit), 
      .op_writeDone(bWY_op_writeDone)
      );

// Memories instantiation
/*
//Y SRAM
   y_sram Y_mem(.clock(clock), .WE(1'b0), .WriteAddress(wire_yAddrWrite),
         .ReadAddress1(wire_yAddrOut1), .ReadAddress2(wire_yAddrOut2), .WriteBus(wire_yDataWrite),
         .ReadBus1(mydes_ySRAM_rowRead1), .ReadBus2(mydes_ySRAM_rowRead2));	
*/

endmodule
