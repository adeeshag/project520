module top (clock, reset,
	    top_iMem_data1 ,top_iMem_data2, 
 //To Test
 /*
	top_out_iMem_data1_1,top_out_iMem_data1_2,
                        top_out_iMem_data1_3, top_out_iMem_data1_4,
                            top_out_iMem_data1_5,
	top_out_iMem_data2_1,top_out_iMem_data2_2,
                        top_out_iMem_data2_3, top_out_iMem_data2_4,
                           top_out_iMem_data2_5,
  */
      top_chgTxt_row,top_chgTxt_col,
      top_ySRAM_rowRead, top_gMYR_cacldRow,
      top_gMYR_addr1,top_gMYR_addr2, 
	   iSRAM_Address1 , iSRAM_Address2 
       
	   );
/********** Module Inputs and Outputs **************/
	   
	input clock;
	input	reset;
	
   input [10:0] top_chgTxt_row,top_chgTxt_col; //From change.txt
	
	input [239:0] top_iMem_data1,top_iMem_data2;

   input [255:0] top_ySRAM_rowRead;

/*
	output 	[47:0] 	top_out_iMem_data1_1,top_out_iMem_data1_2,
                        top_out_iMem_data1_3, top_out_iMem_data1_4,
                            top_out_iMem_data1_5;
	output 	[47:0] 	top_out_iMem_data2_1,top_out_iMem_data2_2,
                        top_out_iMem_data2_3, top_out_iMem_data2_4,
                           top_out_iMem_data2_5;
*/
   output [10:0] top_gMYR_cacldRow; 
   output [10:0] top_gMYR_addr1,top_gMYR_addr2; 

	output [7:0] 	iSRAM_Address1,iSRAM_Address2;



/************************ Wires *********************/	
   wire [10:0] top_gMYR_cacldRow; 
   wire [255:0] top_ySRAM_rowRead;
   

/***************** Modules Instan *******************/
   getYMatRow matRow (.clock(clock), .reset(reset), .gYMR_row_in(15'd0),
         .gYMR_row_addr(top_gMYR_cacldRow)
         );

/*
   getYMatAddress U1(.clock(clock), .reset(reset), 
                  .gYMA_row(15'd0), .gYMA_readData(top_ySRAM_rowRead),
                  .gYMA_row_addr1(top_gMYR_addr1), .gYMA_row_addr2(top_gMYR_addr2) );
*/
/*
	Engine Data1 (.clock(clock), .reset(reset),
	    .eng_iMem_data1(top_iMem_data1) ,.eng_iMem_data2(top_iMem_data2) ,

	    .out_eng_iMem_data1_1(top_out_iMem_data1_1) ,.out_eng_iMem_data1_2(top_out_iMem_data1_2) ,
     .out_eng_iMem_data1_3(top_out_iMem_data1_3) ,    .out_eng_iMem_data1_4(top_out_iMem_data1_4) ,
            .out_eng_iMem_data1_5(top_out_iMem_data1_5) ,
	    .out_eng_iMem_data2_1(top_out_iMem_data2_1) ,.out_eng_iMem_data2_2(top_out_iMem_data2_2) ,
         .out_eng_iMem_data2_3(top_out_iMem_data2_3) ,    .out_eng_iMem_data2_4(top_out_iMem_data2_4) ,
            .out_eng_iMem_data2_5(top_out_iMem_data2_5) 
       );
*/
/*
	Engine Data1 (.clock(clock), .reset(reset), .new(new), .search(search), .Found(Found1), .NotFound(NotFound1),
		     .data(data1), .ETX(ETX1),  .match(match1), .sp(sp1), .CharCount(CharCount1));
*/	
	
	Controller Ctrl (	.clock(clock),  .reset(reset), 
					.Address1(iSRAM_Address1), .Address2(iSRAM_Address2) 
					);

endmodule

