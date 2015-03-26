module top_with_mem(clock, reset, iMem_WEPin, iMem_WEAddress, idataWrite,
	topmem_out_iMem_data1_1,topmem_out_iMem_data1_2,topmem_out_iMem_data1_3,
          topmem_out_iMem_data1_4,topmem_out_iMem_data1_5,
	topmem_out_iMem_data2_1,topmem_out_iMem_data2_2,topmem_out_iMem_data2_3,
          topmem_out_iMem_data2_4,topmem_out_iMem_data2_5
      );

	input clock, reset,iMem_WEPin;
   input [239:0] idataWrite;
	input 	[7:0] 		iMem_WEAddress;

//For testing purposes
//
	output 	[47:0] 	topmem_out_iMem_data1_1,topmem_out_iMem_data1_2,topmem_out_iMem_data1_3,
                        topmem_out_iMem_data1_4,topmem_out_iMem_data1_5;
	output 	[47:0] 	topmem_out_iMem_data2_1,topmem_out_iMem_data2_2,topmem_out_iMem_data2_3,
                        topmem_out_iMem_data2_4,topmem_out_iMem_data2_5;
	
	
	wire 	[239:0] 		idata1;
	wire 	[239:0] 		idata2;
	wire 	[7:0] 		iSRAM_Address1;
	wire 	[7:0] 		iSRAM_Address2;
	
	top top_inst (	.clock(clock),  .reset(reset), 

	         .top_iMem_data1(idata1),.top_iMem_data1_2(idata2),


// for testing 
	    .top_out_iMem_data1_1(topmem_out_iMem_data1_1) ,.top_out_iMem_data1_2(topmem_out_iMem_data1_2) ,
         .top_out_iMem_data1_3(topmem_out_iMem_data1_3) ,    .top_out_iMem_data1_4(topmem_out_iMem_data1_4) ,
            .top_out_iMem_data1_5(topmem_out_iMem_data1_5) ,
	    .top_out_iMem_data2_1(topmem_out_iMem_data2_1) ,.top_out_iMem_data2_2(topmem_out_iMem_data2_2) ,
         .top_out_iMem_data2_3(topmem_out_iMem_data2_3), .top_out_iMem_data2_4(topmem_out_iMem_data2_4) ,
            .top_out_iMem_data2_5(topmem_out_iMem_data2_5), 

				 .iSRAM_Address1(iSRAM_Address1), .iSRAM_Address2(iSRAM_Address2) 
			);

// Memories instantiation
// I SRAM
   i_sram I_mem(.clock(clock), .WE(iMem_WEPin), .WriteAddress(iMem_WEAddress),
         .ReadAddress1(iSRAM_Address1), .ReadAddress2(iSRAM_Address2), .WriteBus(idataWrite),
            .ReadBus1(idata1), .ReadBus2(idata2));	

//Y SRAM
   y_sram Y_mem(.clock(clock), .WE(yMem_WEPin), .WriteAddress(yMem_WEAddress),
         .ReadAddress1(ySRAM_Address1), .ReadAddress2(ySRAM_Address2), .WriteBus(ydataWrite),
            .ReadBus1(ydata1), .ReadBus2(ydata2));	

//V SRAMS
   v_sram_op2 V1_mem(.clock(clock), .WE(v1Mem_WEPin), .WriteAddress(v1Mem_WEAddress),
         .ReadAddress1(v1SRAM_Address1), .ReadAddress2(v1SRAM_Address2), .WriteBus(v1dataWrite),
            .ReadBus1(v1data1), .ReadBus2(v1data2));	
   v_sram_op2 V2_mem(.clock(clock), .WE(v2Mem_WEPin), .WriteAddress(v2Mem_WEAddress),
         .ReadAddress1(v2SRAM_Address1), .ReadAddress2(v2SRAM_Address2), .WriteBus(v2dataWrite),
            .ReadBus1(v2data1), .ReadBus2(v2data2));	
   v_sram_op2 V3_mem(.clock(clock), .WE(v3Mem_WEPin), .WriteAddress(v3Mem_WEAddress),
         .ReadAddress1(v3SRAM_Address1), .ReadAddress2(v3SRAM_Address2), .WriteBus(v3dataWrite),
            .ReadBus1(v3data1), .ReadBus2(v3data2));	
   v_sram_op2 V4_mem(.clock(clock), .WE(v4Mem_WEPin), .WriteAddress(v4Mem_WEAddress),
         .ReadAddress1(v4SRAM_Address1), .ReadAddress2(v4SRAM_Address2), .WriteBus(v4dataWrite),
            .ReadBus1(v4data1), .ReadBus2(v4data2));	
endmodule
