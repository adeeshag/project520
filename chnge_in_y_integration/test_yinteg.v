//`timescale 1ns/10ps
module tb1;
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
   wire[47:0] yRAMout1,yRAMout2,finalVal;
   wire[15:0] rowToFetchNext;
   wire doneOut,exEnableNext,datapathDoneFlag,filtYDone;
   wire [255:0] rowRead1, rowRead2;
	
   
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
	   $readmemh("ymem_datasingle.mem", top_inst.Y_mem.Register); 	
      
      reset       = 0;

      #(CLKPERIOD*2)
            reset = 1;

       


	    #(100*CLKPERIOD) $finish;
	  end
	
	always #(CLKPERIOD/2) clock = ~clock;


       top_with_mem U1(.clock(clock), .reset(reset),
      .yMem_WEPin(1'b0), .yMem_WEAddress(8'b0), .ydataWrite(256'b0),
      .topmem_chgTxt_row(16'h0000),.topmem_chgTxt_col(16'h0010), 
      .topmem_chgTxt_real(24'h4ebd90),.topmem_chgTxt_img(24'h5c2e27), 
      .topmem_yMatOut1(rowRead1),.topmem_yMatOut2(rowRead2), 
      .topmem_dataPathDoneFlag(datapathDoneFlag),.topmem_filtYopDone(filtYDone),
      .topmem_opYval(finalVal)
      );

	
	
endmodule

