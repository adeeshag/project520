module top(clock, reset,
      top_chgTxt_row,top_chgTxt_col, 
      top_chgTxt_real,top_chgTxt_img, 
      top_opYval
      );

/********** Module Inputs and Outputs **************/
	input clock, reset;

   input [15:0]   top_chgTxt_row,top_chgTxt_col; //From change.txt
   input [23:0]   top_chgTxt_real, top_chgTxt_img;

   output [47:0] top_opYval;
// For fp_DW

   wire [47:0] top_op_fpIn1, top_op_fpIn2;
   wire        top_op_fpMode;
   
   wire  [47:0]      top_in_fpOut;


	
/************************ Wires *******************/	
	

   wire [255:0] wire_ySRAM_rowRead1;
   wire [255:0] wire_ySRAM_rowRead2;

   wire [10:0]  wire_yAddrOut1;
   wire [10:0]  wire_yAddrOut2;

   wire [10:0]  wire_yAddrWrite;
   wire [255:0] wire_yDataWrite;

   wire wire_WEBit;


/***************** Modules Instan *******************/
myDesign myDes_inst(.clock(clock), .reset(reset),
      .mydes_chgTxt_row(top_chgTxt_row),     .mydes_chgTxt_col(top_chgTxt_col), 
      .mydes_chgTxt_real(top_chgTxt_real),    .mydes_chgTxt_img(top_chgTxt_img), 
      .mydes_ySRAM_rowRead1(wire_ySRAM_rowRead1), .mydes_ySRAM_rowRead2(wire_ySRAM_rowRead2),
      .mydes_opYval(top_opYval),
      .mydes_ydataWrite(wire_yDataWrite),
      .mydes_op_yReadAddress1(wire_yAddrOut1),  .mydes_op_yReadAddress2(wire_yAddrOut2),
      .mydes_op_yWriteAddress(wire_yAddrWrite), .mydes_op_yWriteEnable(wire_WEBit),

      //For fp_DW
      .mydes_op_fpIn1(top_op_fpIn1), .mydes_op_fpIn2(top_op_fpIn2),
      .mydes_op_fpMode(top_op_fpMode),
      .mydes_in_fpOut(top_in_fpOut)
      );

// Memories 
memory memory_inst(.Y_WE(wire_WEBit), .clock(clock),
      .Y_WriteAddress(wire_yAddrWrite),
      .Y_WriteBus(wire_yDataWrite),
      .Y_ReadAddress1(wire_yAddrOut1),  .Y_ReadAddress2(wire_yAddrOut2),
      .Y_ReadBus1(wire_ySRAM_rowRead1), .Y_ReadBus2(wire_ySRAM_rowRead2)
	);

// fp_designware
fp_dw fp_dw_inst(.clock(clock) , .adder1_mode(top_op_fpMode), 
      .in1_adder1(top_op_fpIn1) ,       .in2_adder1(top_op_fpIn2),
      .opt_adder1(top_in_fpOut)
      );


endmodule
