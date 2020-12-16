// Variable sized register (DFF)
module reg_variable #(parameter size = 1) (input  logic Clk, Reset, Load,
						  input  logic [size-1:0]  D,
						  output logic [size-1:0]  Data_Out);
	
	logic [size-1:0] Data_Next;
	
	always_ff @ (posedge Clk)
	begin
		
		Data_Out <= Data_Next;
		
	end
	
	always_comb
	begin
		
		//Default Data_Next
		Data_Next = Data_Out;
		
		if(Reset)
			Data_Next = 0;
		
		else if(Load)
			Data_Next = D;
		
	end

endmodule	







module shift_reg_var #(parameter size = 1) (input  logic Clk, Reset, Shift_In, Load, Shift_En,
              input  logic [size - 1:0]  D,
              output logic Shift_Out,
              output logic [size - 1:0]  Data_Out);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset) //notice, this is a synchronous reset, which is recommended on the FPGA
			  Data_Out <= {(size){1'b0}};
		 else if (Load)
			  Data_Out <= D;
		 else if (Shift_En)
		 begin
			  //concatenate shifted in data to the previous left-most 7 bits
			  //note this works because we are in always_ff procedure block
			  Data_Out <= { Shift_In, Data_Out[size - 1:1] }; 
	    end
    end
	
    assign Shift_Out = Data_Out[0];

endmodule










module shift_reg_variable #(parameter size = 1) (input logic Clk, Reset, Parallel_Load,
							input logic [size-1:0] D,
							output logic [size-1:0] Data_Out);

	
	always_ff @ (posedge Clk)
	begin
		if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			Data_Out <= {size{1'b0}};
		else if (Parallel_Load)
			Data_Out <= D;
		else 
		begin
			//concatenate shifted in data to the previous left-most 7 bits
			//note this works because we are in always_ff procedure block
			Data_Out <= { Data_Out[size-2:0], 1'b0 }; 
	    end
	end

endmodule

module Reg_8 (input  logic Clk, Reset, Shift_In, Load, Shift_En,
              input  logic [7:0]  D,
              output logic Shift_Out,
              output logic [7:0]  Data_Out);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			  Data_Out <= 8'h0;
		 else if (Load)
			  Data_Out <= D;
		 else if (Shift_En)
		 begin
			  //concatenate shifted in data to the previous left-most 7 bits
			  //note this works because we are in always_ff procedure block
			  Data_Out <= { Shift_In, Data_Out[7:1] }; 
	    end
    end
	
    assign Shift_Out = Data_Out[0];

endmodule


