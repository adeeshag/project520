module cnt_tb;
   parameter CLOCKPERIOD = 10;
   reg clock,reset,countEN; 
   wire out;



   initial
   begin
   #0 clock =0; reset = 0; countEN =0;

#CLOCKPERIOD 
   countEN =1; 
   reset = 1;
#CLOCKPERIOD 
#CLOCKPERIOD 
#CLOCKPERIOD 
#CLOCKPERIOD 
   countEN =0; 

#CLOCKPERIOD 
#CLOCKPERIOD 
   countEN =1; 

#(CLOCKPERIOD*5)
   $finish;
      
   end

	always #(CLOCKPERIOD/2) clock = ~clock;

counterMod U21( .clock(clock), .reset(reset), .countEN(enable),
                        .op_done(out));
endmodule

