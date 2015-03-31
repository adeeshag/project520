/* ***********************************
 *
 * Decodes the address of Y from row/col obtained from change.txt
 * and outputs two lines  (2x 256 bits)  of content at the output.
 * It takes two clock cycles to give output from the row computed.
 * If the input is an address. It just sends out the same thing.
 * Might need an extra ReadEnable signal in/out of the module.
 * The value of yAD_readRowData only matters in the second Clk 
 * cycle. 
 *
 * ***********************************/



module yAddrDecodr(clock, reset, 
      yAD_readRowNum,
    //  yAD_readAddr1, yAD_readAddr2, 
      yAD_readRowData,
      yAD_outAddr1,yAD_outAddr2
      );

input clock,reset;
//input [10:0] yAD_readAddr1,yAD_readAddr2;
input [15:0] yAD_readRowNum;
input [255:0] yAD_readRowData;

output [10:0] yAD_outAddr1,yAD_outAddr2;


reg [10:0] yAD_outAddr1,yAD_outAddr2;

wire [10:0] wire_outAddr1; 
reg reg_readEn;


always@(posedge clock or negedge reset)
begin
   if(!reset) //synchronous reset
   begin
      yAD_outAddr1 = 11'h7FF; 
      yAD_outAddr2 = 11'h7FF;
   end
   else
   begin
      //casex({(|yAD_readAddr1),(|yAD_readAddr2)})
      casex({(&yAD_outAddr1),(&yAD_outAddr2)})
      2'd3: begin
               yAD_outAddr1 <= (yAD_readRowNum>>4);
               yAD_outAddr2 <= 11'h7FF;
               reg_readEn   <= 1'b1;
            end
      2'd2: begin
               yAD_outAddr1 <= 11'bz;
               yAD_outAddr2 <= 11'bz;
               reg_readEn   <= 1'b0;
            end
      2'd0: begin
               yAD_outAddr1 <= yAD_outAddr1;
               yAD_outAddr2 <= yAD_outAddr2;
               reg_readEn   <= 1'b0;
            end
      2'd1: begin
               yAD_outAddr1 <= wire_outAddr1;
               yAD_outAddr2 <= wire_outAddr1 + 1; //Ripple Carry Adder
               reg_readEn   <= 1'b0;
            end
      default: begin
                  yAD_outAddr1 <= 11'bz; // Should never come here
                  yAD_outAddr2 <= 11'bz;
                  reg_readEn   <= 1'b0;
               end
      endcase
   end //If - else for reset
end



getYMatAddress gY2 (.gYMA_row(yAD_readRowNum), .gYMA_readData(yAD_readRowData),
                        .gYMA_row_addr1(wire_outAddr1) , .readEnable(reg_readEn));
endmodule
