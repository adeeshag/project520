`timescale 1ns/10ps
module tb_cntrControl;
	parameter CLKPERIOD = 50;
	reg clock, reset;
	reg accumDone,enableEntire;

   wire doneOut,enableNext;
	
   
	initial	begin
	  	//$dumpfile("Tut2.vcd"); // save waveforms in this file
	  	//$dumpvars;  // saves all waveforms
      
      reset          = 0;
      clock          = 0;
      accumDone      = 0;
      enableEntire   = 0;

      #(CLKPERIOD*2)
            reset    = 1;
      accumDone      = 0;
      enableEntire   = 1;

      #(CLKPERIOD*10)
      accumDone      = 1;

      #CLKPERIOD
      accumDone      = 0;

       


	    #(100*CLKPERIOD) $finish;
	  end
	
	always #(CLKPERIOD/2) clock = ~clock;

controlCounterIter ctrlI1( .reset(reset), .clock(clock),
                           .in_accumCalcDoneFlag(accumDone),   
                           .in_enableEntireModule(enableEntire),

                           .op_enableAccumCalc(enableNext),
                           .op_allItersDoneFlag(doneOut)
      );

	
	
endmodule

