module  bar_generator #( parameter bar_count = 1)
							  ( input Reset, frame_clk,
							    output [9:0] num_bars,
								 output [9:0] bar_x 		 [bar_count - 1:0],
								 output [9:0] bar_y 		 [bar_count - 1:0],
								 output [9:0] bar_width,
								 output [9:0] bar_height [bar_count - 1:0],
								 output [9:0] max_x,
								 
								//  input logic [31:0] audio_output [256]
								 input logic [8191:0] audio_output
								 );
								 
	parameter [9:0] x_center=320;  // Center position on the X axis
   parameter [9:0] y_center=240;  // Center position on the Y axis
   parameter [9:0] x_min=0;       // Leftmost point on the X axis
   parameter [9:0] x_max=639;     // Rightmost point on the X axis
   parameter [9:0] y_min=0;       // Topmost point on the Y axis
   parameter [9:0] y_max=479;     // Bottommost point on the Y axis
   parameter [9:0] x_step=1;      // Step size on the X axis
   parameter [9:0] y_step=1;      // Step size on the Y axis
	
	int x_offset;
	
	//logic [9:0] curMax;
	
	always_ff @ (posedge Reset or posedge frame_clk )
    begin: YES
        if (Reset)  // Asynchronous Reset
        begin 
            max_x <= 10'd0;
				//curMax <= 10'd0;
        end
        /*
		  else if(max_x > 10'd1)
		  begin
				max_x <= 10'd0;
		  end
	*/
        else 
		  begin
				
			  for (int i = 0; i < bar_count; i++)
			  begin
					//if(bar_height[i] > curMax)
					//begin
						//curMax <= bar_height[i];
						max_x <= bar_x[i];
					
					//end
			  end
		  
		  end
	end
	
	
	assign bar_width = x_max / bar_count;
	assign num_bars = bar_count;
	
	//assign x_offset = (x_max - (bar_width * bar_count)) / 2;
	
	//make local vars for these
	genvar i;
	generate
	
	// always_comb
	// begin
		for (i = 0; i < bar_count; i++)
		begin : initialize_connections
			assign bar_x[i] = (bar_width * i);
			assign bar_y[i] = y_center;
			//assign bar_height[i] = int'(audio_output[((i * 32) + 27) : ((i * 32) + 19)]);
			
			assign bar_height[i] = {3'b0, audio_output[((i * 32) + 27) : ((i * 32) + 22)]};
			//assign bar_height[i] = 20;
			//assign max_x = bar_x[i];
		end
	// end
	endgenerate
	
								 
								 
endmodule 