//`timescale 1ns/10ps
module Controller (clock,reset,
		   Address1, Address2
		  );
		  
 	input clock, reset;
 	
 	output  [7:0] 	Address1;
 	output  [7:0] 	Address2;
 	
 	reg 	[7:0] 	Address1;		  
 	reg 	[7:0] 	Address2;		  
	
	always@(posedge clock) begin
	  	if (reset) begin
	  		Address1 <= 0;
	  		Address2 <= 1;
	  	end
	  	else  begin
	  		Address1 <= Address1 + 7'd2;
	  		Address2 <= Address2 + 7'd2;
	  	end
	end 

endmodule
