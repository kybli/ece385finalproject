module  bar_color_mapper #( parameter bar_count = 1)
								  ( input        	[9:0] DrawX, DrawY,
									 input			[9:0] bar_x 		 [bar_count - 1:0],
									 input			[9:0] bar_y 		 [bar_count - 1:0],
									 input			[9:0] bar_width,
									 input	 		[9:0] bar_height  [bar_count - 1:0],
									 output logic 	[7:0] Red, Green, Blue,
									 input         [9:0] BallX, BallY, Ball_size,
									 input			[9:0] BombX, BombY );

	parameter [9:0] x_max=639;     // Rightmost point on the X axis
									
	logic bar_on;
	
	logic ball_on;
	 
	logic bomb_on, bomb_tail_on, bomb_head_on;
	
	int DistX, DistY, Size;
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
	 
	 int bombDistX, bombDistY;
	 
	 assign bombDistX = DrawX - BombX;
	 assign bombDistY = DrawY - BombY;
	 
	 
	
	
	int dist_x, dist_y, height, width, cur_bar_idx, x_offset, display_bar_width;
	
	assign color_one_r = 8'h00;
	assign color_one_g = 8'ha8;
	assign color_one_b = 8'hff;
	
	assign color_two_r = 8'h14;
	assign color_two_g = 8'hff;
	assign color_two_b = 8'hb5;
	
	
	//assign x_offset = (x_max - (bar_x[bar_count - 1] + bar_width)) / 2;
	
	always_comb
	begin: Get_Cur_Bar_Info
		
		cur_bar_idx = (DrawX) / bar_width;
		//cur_bar_idx = 0;
		// if current index out of bounds, use index 0 data
		if (cur_bar_idx < 0 || cur_bar_idx > bar_count - 1)
			cur_bar_idx = 0;
		
		//don't really need dist_x since bars should cover entire width of screen
		// BUT ALREADY IMPLEMENTED SO DONT TOUCH IT
		dist_x = DrawX - bar_x[cur_bar_idx];
		dist_y = bar_y[cur_bar_idx] - DrawY;
		
		height = bar_height[cur_bar_idx];
		width = bar_width;
		display_bar_width = bar_width / 2;
		
	end
	
	
	
	always_comb
    begin:Ball_on_proc
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
		  
		  
		  bomb_on = 1'b0;
		  bomb_head_on = 1'b0;
		  bomb_tail_on = 1'b0;
		  
		  if(  ( ( (bombDistX * bombDistX) / (4 * 4) ) + ( (bombDistY * bombDistY) / (16 * 16) ) ) >= 1 && bombDistX > -2 && bombDistX < 2 && bombDistY < 0 && bombDistY > -10)
				bomb_tail_on = 1'b1;
		  
		  if( ( (bombDistX * bombDistX) * (Size * Size) ) + ( (bombDistY * bombDistY) ) < (Size * Size * Size * Size))
		  begin
		  	   if(bombDistY > 4)
					bomb_head_on = 1'b1;
				else
					bomb_on = 1'b1;
		  end
		  
     end 
	  
	  

	
	
	always_comb
   begin:Should_Color_Bar
		if ( dist_x >= 0 && dist_x < display_bar_width && dist_y >= 0 && dist_y <= height) 
			bar_on = 1'b1;
      
		else 
			bar_on = 1'b0;
   end
	
	
       
   always_comb
   begin:RGB_Display
		  if ((bar_on == 1'b1)) 
        begin 
            /*
				Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
				*//*
				Red = color_one_r + (DrawX / ((bar_x[bar_count - 1] + display_bar_width) / (color_two_r - color_one_r)));
            Green = color_one_g + (DrawX / ((bar_x[bar_count - 1] + display_bar_width) / (color_two_g - color_one_g)));
            Blue = color_one_b + (DrawX / ((bar_x[bar_count - 1] + display_bar_width) / (color_two_b - color_one_b)));
				*/
				Red = 8'h00 + DrawX[9:4];
            Green = 8'ha8 + DrawX[9:2];
            Blue = 8'hff - DrawX[9:3];
				
        end

		  else if ((ball_on == 1'b1)) 
        begin 
            Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
        end 
		  
		  //else if(bomb_head_on == 1'b1 || bomb_tail_on == 1'b1)
		  else if(bomb_head_on == 1'b1)
		  begin
				Red = 8'hff;
            Green = 8'h00;
            Blue = 8'h00;
		  end
		  
		  else if (bomb_on == 1'b1)
		  begin
				Red = 8'h00;
            Green = 8'hff;
            Blue = 8'h00;
		  end
		  
        else 
        begin 
            Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'h7f - DrawX[9:3];
        end      
   end 
	
	
endmodule 