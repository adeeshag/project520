module yAddrDecodr(clock, reset, 
      yAD_readRowNum,
      yAD_readAddr1, yAD_readAddr2, 
      yAD_readRowData,
      yAD_outAddr1,yAD_outAddr2
      );

input clock,reset;
input [10:0] yAD_readAddr1,yAD_readAddr2;
input [10:0] yAD_readRowNum;
input [255:0] yAD_readRowData;

output [10:0] yAD_outAddr1,yAD_outAddr2;


reg [10:0] yAD_outAddr1,yAD_outAddr2;

wire [10:0] wire_outAddr1; 

always@(posedge clock)
begin
   if(!reset) //synchronous reset
   begin
      yAD_outAddr1 = 11'b0; 
      yAD_outAddr2 = 11'd0;
   end
   else
   begin
      casex({(|yAD_readAddr1),(|yAD_readAddr2)})
      2'd0: begin
               yAD_outAddr1 = (yAD_readRowNum>>4);
               yAD_outAddr2 = 11'd0;
            end
      2'd1: begin
               yAD_outAddr1 = 11'bz;
               yAD_outAddr2 = 11'bz;
            end
      2'd3: begin
               yAD_outAddr1 = yAD_readAddr1;
               yAD_outAddr2 = yAD_readAddr2;
            end
      2'd2: begin
               yAD_outAddr1 = wire_outAddr1;
               yAD_outAddr2 = wire_outAddr1 + 1; //Ripple Carry Adder
            end
      default: begin
                  yAD_outAddr1 = 11'bz; // Should never come here
                  yAD_outAddr2 = 11'bz;
               end
      endcase
   end //If - else for reset
end


getYMatAddress gY2 (.gYMA_row(yAD_readRowNum), .gYMA_readData(yAD_readRowData),
                        .gYMA_row_addr1(wire_outAddr1) );

endmodule
