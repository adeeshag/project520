//`timescale 1ns/10ps
module tb;
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
	    //$readmemh("ymem_data1.mem", Top_mem.Y_mem.Register); 	
       
	    clock      = 0; 
	    reset      = 0;
       filt_EN    = 0;
       ydataWrite = '0;
       rowIn      = 16'hffff;
       colIn      = 16'hffff;
       inReal     = 24'h0;
       inImg      = 24'h0;
       dataready  = 0;
       exDone     = 0;

		 #(((CLKPERIOD*3)/2)-1) reset =1'b1; 		 // start the design at a known state
       //First CLK cycle
       filt_EN       =  1;
       rowIn         = 16'h0000;
       colIn         = 16'h0010;
       inReal        = 24'h4ebd90;
       inImg         = 24'h5c2e27;
       ydataWrite    = '0;
       dataready     = 0;
       exDone        = 0;

       #(CLKPERIOD*2) // should sit in s1 state
       dataready     = 1;

         
       #(CLKPERIOD)
       ydataWrite    = 256'he6005bbd1be6cb8e0003d26a1562c7ae0004d2bb3a5a24d4000fcd1c1a544a65;

       #(CLKPERIOD)
       ydataWrite    = 256'h0010d20ed15901370011cdf52e5d55300012d880ef63c8b9e201595705eb2b2f;

       #(CLKPERIOD)
       ydataWrite    = 256'h0;

       #(CLKPERIOD) //should go to s1 after this
       exDone        = 1;
       ydataWrite    = 256'h0;

       #(CLKPERIOD) 
       exDone        = 0;
       dataready     = 0;
       ydataWrite    = 256'h0;

       #(CLKPERIOD-1) 
       dataready     = 1;
       ydataWrite    = 256'h005600570059005b000000000000000000000000000000000000000000000000;
                        //shouldn't make a difference. just the pointer

       #(CLKPERIOD) 
       ydataWrite    = 256'h0013d5f1fd5f6175e51061d601ed36530000d20ed15901370001d10e17647821;

       #(CLKPERIOD) 
       ydataWrite    = 256'h0004d622f95e48f60005d2093c5b6ed00006cc110456f067e6115e39d2ed0b7c;

       #(CLKPERIOD) //should be done after this
       exDone        = 1;




	    #(9*CLKPERIOD) $finish;
	  end
	
	always #(CLKPERIOD/2) clock = ~clock;



      filt_yVal U1 (.clock(clock), .reset(reset), .exModDone(exDone), .chng_img(inImg),
                   .chng_row(rowIn), .chng_col(colIn), .chng_real(inReal), 
                   .ymem_data(ydataWrite), .filt_EN(filt_EN), .yMemDataReadyNextCycle(dataready),
                   //Outputs
                   .op_y_row(rowToFetchNext), .op_yVal1(yRAMout1), .op_yVal2(yRAMout2),
                   .op_EX_EN(exEnableNext), .op_Done(doneOut)
                   );
	
	
endmodule

