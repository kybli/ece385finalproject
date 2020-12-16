//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  bomb ( input Reset, frame_clk,
								 input [7:0] keycode,
								 output [9:0]  bombX, bombY,
								 input [3:0] curPoints);
    
    logic [9:0] X_Pos, X_Motion, Y_Pos, Y_Motion, Size;
	 logic falling;
	 logic [4:0] ctr;
	 
    parameter [9:0] X_Center=320;  // Center position on the X axis
    parameter [9:0] Y_Center=240;  // Center position on the Y axis
    parameter [9:0] X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] X_Step=1;      // Step size on the X axis
    parameter [9:0] Y_Step=1;      // Step size on the Y axis

    assign Size = 4;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Bomb
        if (Reset)  // Asynchronous Reset
        begin 
            Y_Motion <= 10'd0; //Y_Step;
				X_Motion <= 10'd0; //X_Step;
				Y_Pos <= Y_Center;
				X_Pos <= X_Center + 50;
				falling <= 1'd0;
				ctr <= 5'd0;
        end
           
        else 
        begin 
				
				if(falling == 1'b1)
				begin	
					if(Y_Pos + Y_Motion + 1 >= Y_Max)
					begin
						Y_Pos <= Y_Max;
						Y_Motion <= 10'd0;
						falling <= 1'b0;
					end
					
					else
					begin
						if(ctr == 5'd20 - (2 * curPoints))
						begin
							Y_Motion <= Y_Motion + 1'd1;
							ctr <= 3'd0;
						end
						
						else
							ctr <= ctr + 1'd1;
						Y_Pos <= (Y_Pos + Y_Motion);  // Update ball position
					end
				end
				
				else
				begin
					Y_Pos <= Y_Center;
					Y_Motion <= 10'd0;
				
					//if(keycode == 8'h16)
					//begin
						falling <= 1'b1;
					//end
				
				end
				
				 
				 
				 
				 X_Pos <= (X_Pos + X_Motion);
			
			
	  /**************************************************************************************
	    ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
		 Hidden Question #2/2:
          Note that Y_Motion in the above statement may have been changed at the same clock edge
          that is causing the assignment of Y_pos.  Will the new value of Y_Motion be used,
          or the old?  How will this impact behavior of the ball during a bounce, and how might that 
          interact with a response to a keypress?  Can you fix it?  Give an answer in your Post-Lab.
      **************************************************************************************/
      
			
		end  
    end
	 
       
    assign bombX = X_Pos;
   
    assign bombY = Y_Pos;
    

endmodule