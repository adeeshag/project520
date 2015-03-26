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
	
	initial	begin
	  	//$dumpfile("Tut2.vcd"); // save waveforms in this file
	  	//$dumpvars;  // saves all waveforms
	    $readmemh("imem_data1.mem", top_mem.i_mem.Register); 	
			
	    clock = 0; 
	    reset = 0;
       WEPin = 0;
       WEAddress = 0;
       idataWrite = 0;

	   	#(CLKPERIOD+2)
	    reset = 1; 
		 #CLKPERIOD reset =1'b0; 		 // start the design at a known state

	    #(50*CLKPERIOD) $finish;
	  end
	
	always #(CLKPERIOD/2) clock = ~clock;
	top_with_mem	Top_mem(	
			.clock(clock), .reset(reset), .iMem_WEPin(WEPin), .WEAddress(WEAddress),
             .idataWrite(idataWrite),
             
	    .topmem_out_iMem_data1_1(IData1_1) ,.topmem_out_iMem_data1_2(IData1_2) ,
         .topmem_out_iMem_data1_3(IData1_3) ,    .topmem_out_iMem_data1_4(IData1_4) ,
            .topmem_out_iMem_data1_5(IData1_5) ,
	    .topmem_out_iMem_data2_1(IData2_1) ,.topmem_out_iMem_data2_2(IData2_2) ,
         .topmem_out_iMem_data2_3(IData2_3), .topmem_out_iMem_data2_4(IData2_4) ,
            .topmem_out_iMem_data2_5(IData2_5) 
             );
	
	
endmodule

