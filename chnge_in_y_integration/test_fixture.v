module test_fix_top;
   parameter CLOCKPERIOD = 10;
   reg clock,reset; // used instead of reg/wire

   reg [23:0] dataR,dataI; //real and imaginary parts
   reg [15:0] row,col;

   integer data_file,scan_file;
   integer isram_file,isram_scan;


   initial
   begin
      data_file = $fopen("change_data1.txt","r");
      if(data_file == 0) begin
         $display(" File Handle was NULL\n");
         $finish;
      end
	   $readmemh("imem_data1.mem", top_mem.mem_inst_isram.Register); 	
      if(data_file == 0) begin
         $display(" File Handle was NULL\n");
         $finish;
      end
   end


   initial
   begin
      while(!$feof(data_file)) begin
      scan_file = $fscanf(data_file, "%h %h %h %h\n",row,col,dataR, dataI); //$fscanf returns the number of successful operations performed
      $display("Row: %h  Col: %h DataR: %h  DataI: %h \n",row,col,dataR,dataI);
      end
      $finish;
   end
endmodule



