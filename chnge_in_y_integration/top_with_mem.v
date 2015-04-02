module top_with_mem(clock, reset,
      yMem_WEPin, yMem_WEAddress, ydataWrite,
      topmem_chgTxt_row,topmem_chgTxt_col, 
      topmem_chgTxt_real,topmem_chgTxt_img, 
      topmem_yMatOut1,topmem_yMatOut2, 
      topmem_dataPathDoneFlag,topmem_filtYopDone,
      topmem_opYval
      );

/********** Module Inputs and Outputs **************/
	input clock, reset, yMem_WEPin;
   input [255:0]  ydataWrite;
	input [7:0]    yMem_WEAddress;

   input [15:0]   topmem_chgTxt_row,topmem_chgTxt_col; //From change.txt
   input [23:0]   topmem_chgTxt_real, topmem_chgTxt_img;

   output [255:0] topmem_yMatOut1,topmem_yMatOut2; 
   output topmem_dataPathDoneFlag,topmem_filtYopDone;
   output [47:0] topmem_opYval;

//For testing purposes

	
/************************ Wires *******************/	
	

   wire [255:0] wire_ySRAM_rowRead1;
   wire [255:0] wire_ySRAM_rowRead2;

   wire [10:0]  wire_yAddrOut1;
   wire [10:0]  wire_yAddrOut2;

   wire [10:0]  wire_yAddrWrite;
   wire [255:0] wire_yDataWrite;


//Testing	

 /*********Assign For testing ******/
 assign topmem_yMatOut1 = wire_ySRAM_rowRead1;
 assign topmem_yMatOut2 = wire_ySRAM_rowRead2;
/***************** Modules Instan *******************/
	top top_inst (	.clock(clock),  .reset(reset), 

            .top_chgTxt_row(topmem_chgTxt_row),  .top_chgTxt_col(topmem_chgTxt_col),
            .top_chgTxt_real(topmem_chgTxt_real), .top_chgTxt_img(topmem_chgTxt_img),
            .top_ySRAM_rowRead1(wire_ySRAM_rowRead1), .top_ySRAM_rowRead2(wire_ySRAM_rowRead2), 
            .top_yMatAddrOut1(wire_yAddrOut1), .top_yMatAddrOut2(wire_yAddrOut2), 
            .top_dataPathDoneFlag(topmem_dataPathDoneFlag), .top_filtYopDone(topmem_filtYopDone),
            .top_opYval(topmem_opYval)
			);

// Memories instantiation

//Y SRAM
   y_sram Y_mem(.clock(clock), .WE(1'b0), .WriteAddress(wire_yAddrWrite),
         .ReadAddress1(wire_yAddrOut1), .ReadAddress2(wire_yAddrOut2), .WriteBus(wire_yDataWrite),
         .ReadBus1(wire_ySRAM_rowRead1), .ReadBus2(wire_ySRAM_rowRead2));	

endmodule
