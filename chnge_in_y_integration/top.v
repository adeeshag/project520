module top (clock, reset,

      top_chgTxt_row,top_chgTxt_col,
      top_chgTxt_real, top_chgTxt_img,
      top_ySRAM_rowRead1,top_ySRAM_rowRead2, 

      top_yMatAddrOut1,top_yMatAddrOut2, 
      top_dataPathDoneFlag, top_filtYopDone,
      top_opYval

	   );
/********** Module Inputs and Outputs **************/
	   
	input clock;
	input	reset;
	
   input [15:0]   top_chgTxt_row,top_chgTxt_col; //From change.txt
   input [23:0]   top_chgTxt_real, top_chgTxt_img;
   input [255:0]  top_ySRAM_rowRead1,top_ySRAM_rowRead2; //From Y SRAM
	


   output [10:0]  top_yMatAddrOut1,top_yMatAddrOut2; 
   output [47:0]  top_opYval;
   output         top_dataPathDoneFlag,top_filtYopDone;




/************************ Wires and Regs*********************/	
 //  wire [255:0] top_ySRAM_rowRead;
 wire          wire_execEnable,wire_dataOuNxtCycle, wire_execDoneFlag;
 wire [47:0]   top_filtYval1,top_filtYval2; 
 wire [15:0]   top_opRowNum_from_filtY;
   

/***************** Modules Instantiation *******************/


updateY_calc unit_dataPath1 (.clock(clock),.reset(reset), .executeEnableBit(wire_execEnable),
                     .yInVal1(top_filtYval1), .yInVal2(top_filtYval2), 
                     .op_yWriteVal(top_opYval), .op_DoneFlag(top_dataPathDoneFlag),
                     .op_ExDoneFlag(wire_execDoneFlag)
                    );


filt_yVal unit_filtY1 ( .clock(clock), .reset(reset), .exModDone(wire_execDoneFlag), 
     .chng_row(top_chgTxt_row), .chng_col(top_chgTxt_col),
     .chng_real(top_chgTxt_real),.chng_img(top_chgTxt_img),
     .ymem_data1(top_ySRAM_rowRead1), .ymem_data2(top_ySRAM_rowRead2), .filt_EN(1'b1),
     .yMemDataReadyNextCycle(wire_dataOuNxtCycle),
     .op_y_row(top_opRowNum_from_filtY),  .op_EX_EN(wire_execEnable), .op_Done(top_filtYopDone),
     .op_yVal1(top_filtYval1), .op_yVal2(top_filtYval2)
     );


yAddrDecodr unit_yAD1 (.clock(clock), .reset(reset), .yAD_enable(1'b1),
      .yAD_readRowNum(top_opRowNum_from_filtY), .yAD_readRowData(top_ySRAM_rowRead1), 
      .yAD_outAddr1(top_yMatAddrOut1), .yAD_outAddr2(top_yMatAddrOut2), // send to yMem 
      .yAD_dataOutNextCycle(wire_dataOuNxtCycle)
      );

	

endmodule

