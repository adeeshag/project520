`timescale 1ns/10ps
module tb2;
	parameter CLKPERIOD = 50;
	reg 				clock, reset;
	reg exDone,filt_EN, dataready;
   reg [255:0] ydataWrite;
   reg [23:0] inReal,inImg;
   reg [15:0] rowIn,colIn;
//	wire 	[7:0] 		data1, data2;
//	wire 	[9:0] 		address1, address2;
//	wire				rd_en1, rd_en2;
//
   wire[47:0] finalVal;
	
   
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
	   $readmemh("ymem_small.mem", u1.memory_inst.Y1.Register); 	
      
      reset       = 0;
      clock       = 0;

      #(CLKPERIOD*2)
            reset = 1;

       


	    #(100*CLKPERIOD) $finish;
	  end
	
	always #(CLKPERIOD/2) clock = ~clock;


top u1(.clock(clock), .reset(reset),
      .top_chgTxt_row(16'h0012), .top_chgTxt_col(16'h0009), 
      .top_chgTxt_real(24'h517bf4),.top_chgTxt_img(24'h5fa0aa), 
      .top_opYval(finalVal)
      );

	
 
	
endmodule

