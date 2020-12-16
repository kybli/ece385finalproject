module  bar ( input Reset, frame_clk,
					input [7:0] keycode,
               output [9:0]  BarX, BarY, BarW, BarH );
    
    logic [9:0] Bar_X_Pos, Bar_Y_Pos, Bar_Width, Bar_Height, Bar_H_Motion, Target_Height;
	 //Ball_X_Motion, Ball_Y_Motion, 
	 
    parameter [9:0] X_Center=320;  // Center position on the X axis
    parameter [9:0] Y_Center=240;  // Center position on the Y axis
    parameter [9:0] X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] X_Step=1;      // Step size on the X axis
    parameter [9:0] Y_Step=1;      // Step size on the Y axis

	 
	 //assign Bar_X_Pos = X_Center;
	 //assign Bar_Y_Pos = Y_Center;
	 
	 
	 
	 assign Bar_Width = 4;
	 //assign Bar_Height = 0;
	 
	 
	 //assign Target_Height = 50;
	 
	 always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Bar
        if (Reset)  // Asynchronous Reset
        begin 
				Bar_H_Motion <= 10'd0; //Ball_X_Step;
				Bar_Y_Pos <= Y_Center;
				Bar_X_Pos <= X_Center;
				Bar_Height <= 10'd0;
				Target_Height <= 10'b0000110010;
        end
		  
		  else 
        begin 
				 if (Bar_Height == Target_Height && Target_Height == 10'b0000110010)
						Target_Height <= 10'b0000000010;
						
				 else if (Bar_Height == Target_Height && Target_Height == 10'b0000000010)
						Target_Height <= 10'b0000110010;
						
				 if ( Bar_Height < Target_Height )  // Ball is at the bottom edge, BOUNCE!
					  Bar_H_Motion <= Y_Step;  // 2's complement.
					  
				 else if ( Bar_Height > Target_Height && Bar_Height > 10'b0)
					  Bar_H_Motion <= (~ (Y_Step) + 1'b1);
				
				 else
					  Bar_H_Motion <= 0;
			
				 Bar_Height <= (Bar_Height + Bar_H_Motion);  // Update bar height
			end
		end
		
		
	 assign BarX = Bar_X_Pos;
	 assign BarY = Bar_Y_Pos;
	 assign BarW = Bar_Width;
	 assign BarH = Bar_Height;
	 
		
	 
    /*assign Ball_Size = 4;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
        end
           
        else 
        begin 
				 if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
					  Ball_Y_Motion <= (~ (Ball_Y_Step) + 1'b1);  // 2's complement.
					  
				 else if ( (Ball_Y_Pos - Ball_Size) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
					  Ball_Y_Motion <= Ball_Y_Step;
					  
				  else if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max )  // Ball is at the Right edge, BOUNCE!
					  Ball_X_Motion <= (~ (Ball_X_Step) + 1'b1);  // 2's complement.
					  
				 else if ( (Ball_X_Pos - Ball_Size) <= Ball_X_Min )  // Ball is at the Left edge, BOUNCE!
					  Ball_X_Motion <= Ball_X_Step;
					  
				 else 
					  Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
					  
				 
				 case (keycode)
					8'h04 : begin

								Ball_X_Motion <= -1;//A
								Ball_Y_Motion<= 0;
							  end
					        
					8'h07 : begin
								
					        Ball_X_Motion <= 1;//D
							  Ball_Y_Motion <= 0;
							  end

							  
					8'h16 : begin

					        Ball_Y_Motion <= 1;//S
							  Ball_X_Motion <= 0;
							 end
							  
					8'h1A : begin
					        Ball_Y_Motion <= -1;//W
							  Ball_X_Motion <= 0;
							 end	  
					default: ;
			   endcase
				 
				 Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
				 Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
			*/
			
	  /**************************************************************************************
	    ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
		 Hidden Question #2/2:
          Note that Ball_Y_Motion in the above statement may have been changed at the same clock edge
          that is causing the assignment of Ball_Y_pos.  Will the new value of Ball_Y_Motion be used,
          or the old?  How will this impact behavior of the ball during a bounce, and how might that 
          interact with a response to a keypress?  Can you fix it?  Give an answer in your Post-Lab.
      **************************************************************************************/
      
		/*	
		end  
    end
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
    */

endmodule
