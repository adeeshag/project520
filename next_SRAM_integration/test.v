//`timescale 1ns/10ps
module test_bench;
	parameter CLKPERIOD = 500;
	reg 				clock, reset;
	reg WEPin;
   reg [239:0] idataWrite;
   reg [7:0] WEAddress;
   wire [47:0] IData1_1;
   wire [47:0] IData1_2;
   wire [47:0] IData1_3;
   wire [47:0] IData1_4;
   wire [47:0] IData1_5;
   wire [47:0] IData2_1;
   wire [47:0] IData2_2;
   wire [47:0] IData2_3;
   wire [47:0] IData2_4;
   wire [47:0] IData2_5;
//	wire 	[7:0] 		data1, data2;
//	wire 	[9:0] 		address1, address2;
//	wire				rd_en1, rd_en2;
//
   wire[255:0] yRAMout1,yRAMout2;
	
   
  // integer data_file,scan_file;
  // integer isram_file,isram_scan;
/*
   initial
   begin
      data_file = $fopen("change_data1.txt","r");
      if(data_file == 0) begin
         $display(" File Handle was NULL\n");
         $finish;
      end
    end
*/
	initial	begin
	  	//$dumpfile("Tut2.vcd"); // save waveforms in this file
	  	//$dumpvars;  // saves all waveforms
	    $readmemh("ymem_data1.mem", Top_mem.Y_mem.Register); 	
			
	    clock = 0; 
	    reset = 1;
       WEPin = 0;
       WEAddress = 0;
       idataWrite = 0;

	   	#(CLKPERIOD+2)
	    reset = 1; 
		 #CLKPERIOD reset =1'b0; 		 // start the design at a known state

	    #(9*CLKPERIOD) $finish;
	  end
	
	always #(CLKPERIOD/2) clock = ~clock;



	top_with_mem	Top_mem(	
			.clock(clock), .reset(reset), .iMem_WEPin(WEPin), .iMem_WEAddress(WEAddress),
             .idataWrite(idataWrite),
 /*            
	    .topmem_out_iMem_data1_1(IData1_1) ,.topmem_out_iMem_data1_2(IData1_2) ,
         .topmem_out_iMem_data1_3(IData1_3) ,    .topmem_out_iMem_data1_4(IData1_4) ,
            .topmem_out_iMem_data1_5(IData1_5) ,
	    .topmem_out_iMem_data2_1(IData2_1) ,.topmem_out_iMem_data2_2(IData2_2) ,
         .topmem_out_iMem_data2_3(IData2_3), .topmem_out_iMem_data2_4(IData2_4) ,
            .topmem_out_iMem_data2_5(IData2_5) 
 */
               .topmem_chgTxt_row(16'd0) ,    .topmem_chgTxt_col(16'd0) , 
               .topmem_yMatOut1(yRAMout1) ,  .topmem_yMatOut2(yRAMout2) 
             );
	
	
endmodule

