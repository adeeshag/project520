`timescale 1ns/10ps
module tb_write;
	parameter CLKPERIOD = 50;
	reg 				clock, reset;
	reg cpflag,dpflag;
   reg [10:0] diagAddr,nonDiagAddr;
   reg [3:0]  diagOH, NdiagOH;
   reg [47:0] yComputedVal;
//	wire 	[7:0] 		data1, data2;
//	wire 	[9:0] 		address1, address2;
//	wire				rd_en1, rd_en2;
//
//Outputs
   wire [255:0] ydataRead1,ydataRead2;
   wire[255:0] writeData;
   wire[10:0]  writeAddr,readStrAddr;
   wire doneOut, writeENBit;
	
   
	initial	begin
	  	//$dumpfile("Tut2.vcd"); // save waveforms in this file
	  	//$dumpvars;  // saves all waveforms
	   $readmemh("ymem_datasingle.mem", Y_mem.Register); 	
       
	    clock      = 0; 
	    reset      = 0;

       cpflag = 0; dpflag =0;
       yComputedVal = 0;
       diagAddr = 11'h7ff ; nonDiagAddr = 11'h7ff ;
       diagOH = 4'h0; NdiagOH = 4'h0;

		 #(((CLKPERIOD*3)/2)-1) reset =1'b1; 		 // start the design at a known state
       //First CLK cycle

       #(CLKPERIOD+1) 

       #(CLKPERIOD*2) 

       cpflag = 0; dpflag =1;
       yComputedVal = 48'h5b9138_e6d6fd;
       diagAddr =11'h3f ; nonDiagAddr = 11'h40 ;
       diagOH = 4'h8; NdiagOH = 4'h8;



         
       #(CLKPERIOD)
       cpflag = 0; dpflag =0;
       yComputedVal = 0;
       diagAddr = 11'h7ff ; nonDiagAddr = 11'h7ff ;
       diagOH = 4'h0; NdiagOH = 4'h0;

       #(CLKPERIOD*5)
       cpflag = 1; dpflag =1;
       yComputedVal = 48'h61d084_ed37c1;
       diagAddr =11'h56 ; nonDiagAddr = 11'h56 ;
       diagOH = 4'h4; NdiagOH = 4'h2;

       #(CLKPERIOD)
       cpflag = 0; dpflag =0;
       yComputedVal = 0;
       diagAddr = 11'h7ff ; nonDiagAddr = 11'h7ff ;
       diagOH = 4'h0; NdiagOH = 4'h0;

       #(CLKPERIOD) 

       #(CLKPERIOD) 

       #(CLKPERIOD-1) 
                        

       #(CLKPERIOD) 

       #(CLKPERIOD) 

       #(CLKPERIOD) 




	    #(20*CLKPERIOD) $finish;
	  end
	
	always #(CLKPERIOD/2) clock = ~clock;


busWriteY br1(.clock(clock), .reset(reset), .inModuleEnable(1'b1),
      .cpDoneFlag(cpflag),   .dpDoneFlag(dpflag),
      .inDiagAddr(diagAddr),   .inNonDAddr(nonDiagAddr),
      .inDiagOH(diagOH),     .inNonDiagOH(NdiagOH),
      .inYreadData1(ydataRead1), .inYreadData2(ydataRead2),
      .inYComputedVal(yComputedVal),
      .inYchngData(48'h4ebd905c2e27), 

      .op_writeData(writeData), .op_writeAddress(writeAddr),
      .op_readStoreAddr(readStrAddr), .op_WEbit(writeENBit), 
      .op_writeDone(doneOut)
      );

	
y_sram Y_mem(.clock(clock), .WE(writeENBit), .WriteAddress(writeAddr),
      .ReadAddress1(writeAddr),
      .ReadAddress2(readStrAddr), .WriteBus(writeData), .ReadBus1(ydataRead1),
      .ReadBus2(ydataRead2));
	
endmodule

