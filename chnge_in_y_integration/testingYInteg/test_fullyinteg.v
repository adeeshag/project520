`timescale 1ns/10ps
module tb2;
	parameter CLKPERIOD = 50;
	reg 				clock, reset;
	reg exDone,filt_EN, dataready;
   reg [255:0] ydataWrite;
   reg [23:0] inReal,inImg;
   reg [15:0] rowIn,colIn;
   wire writeDoneFlag;
//	wire 	[7:0] 		data1, data2;
//	wire 	[9:0] 		address1, address2;
//	wire				rd_en1, rd_en2;
//
   wire[47:0] finalVal;
   integer data_file,scan_file;
   //integer i=0;
	
   
  // integer data_file,scan_file;
  // integer isram_file,isram_scan;
   initial
   begin
      data_file = $fopen("change_small.txt","r");
      if(data_file == 0) begin
         $display(" File Handle was NULL\n");
         $finish;
      end
    end

	initial	begin
	  	//$dumpfile("Tut2.vcd"); // save waveforms in this file
	  	//$dumpvars;  // saves all waveforms
	   $readmemh("ymem_small.mem", u1.memory_inst.Y1.Register); 	
      
      reset       = 0;
      clock       = 0;

      while(!$feof(data_file)) begin
      
      scan_file = $fscanf(data_file, "%h %h %h %h\n",rowIn,colIn,inReal, inImg); 

      #(CLKPERIOD*2)
            reset = 1;

         @(posedge writeDoneFlag);

       


	   // #(50*CLKPERIOD) 
          

       end// while
      $finish;
	  end
	
	always #(CLKPERIOD/2) clock = ~clock;


top u1(.clock(clock), .reset(reset),
      .writeDoneFlag(writeDoneFlag),
      .top_chgTxt_row(rowIn), .top_chgTxt_col(colIn), 
      .top_chgTxt_real(inReal),.top_chgTxt_img(inImg), 
      .top_opYval(finalVal)
      );

	
 
	
endmodule

