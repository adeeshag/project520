/* Combinational logic to get the actual row number */

module getYMatRow(//clock, reset, 
      gYMR_row_in, gYMR_row_addr //cIYM_col,// cIYM_real, cIYM_img, //inputs
      );
   
//input clock,reset;

input  [10:0] gYMR_row_in;
output [10:0] gYMR_row_addr;

reg [10:0] gYMR_row_addr;
//input [] cIYM_real, cIYM_img;
//
//wire 

always@(gYMR_row_in)
begin
   gYMR_row_addr <= (gYMR_row_in>>4); //Divide by 16 or 2^^4 
   end
endmodule


