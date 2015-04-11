module memory(Y_WE,Y_WriteAddress,Y_ReadAddress1,Y_ReadAddress2,Y_WriteBus,Y_ReadBus1,Y_ReadBus2
	,clock);

input clock;
//inputs and outputs of Y sram
input   Y_WE; 
input  [10:0] Y_WriteAddress, Y_ReadAddress1, Y_ReadAddress2; // Change as you change size of SRAM
input  [255:0] Y_WriteBus;
output [255:0] Y_ReadBus1;
output [255:0] Y_ReadBus2;



y_sram  Y1(.clock(clock), .WE(Y_WE), .WriteAddress(Y_WriteAddress), .ReadAddress1(Y_ReadAddress1), .ReadAddress2(Y_ReadAddress2), .WriteBus(Y_WriteBus), .ReadBus1(Y_ReadBus1), .ReadBus2(Y_ReadBus2));


endmodule
  
