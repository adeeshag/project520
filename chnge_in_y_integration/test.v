//`timescale 1ns/10ps
module tb;
	parameter CLKPERIOD = 500;
	reg 				clock, reset;
	reg exDone,filt_EN;
   reg [255:0] ydataWrite;
   reg [23:0] inReal,inImg;
   reg [15:0] rowIn,colIn;
//	wire 	[7:0] 		data1, data2;
//	wire 	[9:0] 		address1, address2;
//	wire				rd_en1, rd_en2;
//
   wire[47:0] yRAMout1,yRAMout2;
   wire[15:0] rowToFetchNext;
   wire doneOut,exEnableNext;
	
   
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
	    reset = 0;
       filt_EN =1;
       WEAddress = 0;
       ydataWrite = 0;

	   	#(CLKPERIOD+2)
	    reset = 0; 
		 #CLKPERIOD reset =1'b1; 		 // start the design at a known state

	    #(9*CLKPERIOD) $finish;
	  end
	
	always #(CLKPERIOD/2) clock = ~clock;



      filt_yVal U1 (.clock(clock), .reset(reset), .exModDone(exDone), .chng_img(inImg),
                   .chng_row(rowIn), .chng_col(colIn), .chng_real(inReal), 
                   .ymem_data(ydataWrite), .filt_EN(filt_EN), .yMemDataReady(dataready),
                   .op_y_row(rowToFetchNext), .op_yVal1(yRAMout1), .op_yVal2(yRAMout2),
                   .op_EX_EN(exEnableNext), .op_Done(doneOut)
                   );
	
	
endmodule

