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


module  main_character ( input Reset, frame_clk,
								 input [7:0] keycode,
								 output [9:0]  mcX, mcY, mcS);
    
    logic [9:0] X_Pos, X_Motion, Y_Pos, Y_Motion, Size;
	 logic jump;
	 
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
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Y_Motion <= 10'd0; //Y_Step;
				X_Motion <= 10'd0; //X_Step;
				Y_Pos <= Y_Max - 20;
				X_Pos <= X_Center;
				jump <= 1'd0;
        end
           
        else 
        begin 
		  /*
				 if ( (Y_Pos + Size) >= Y_Max )  // Ball is at the bottom edge, BOUNCE!
					  Y_Motion <= (~ (Y_Step) + 1'b1);  // 2's complement.
					  
				 else if ( (Y_Pos - Size) <= Y_Min )  // Ball is at the top edge, BOUNCE!
					  Y_Motion <= Y_Step;
					  
				  else if ( (X_Pos + Size) >= X_Max )  // Ball is at the Right edge, BOUNCE!
					  X_Motion <= (~ (X_Step) + 1'b1);  // 2's complement.
					  
				 else if ( (X_Pos - Size) <= X_Min )  // Ball is at the Left edge, BOUNCE!
					  X_Motion <= X_Step;
					  
				 else 
					  Y_Motion <= Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
					 */ 
				 
				X_Motion <= 0;
				Y_Motion <= 0;
				 
				 /*
				 else
				 begin
					X_Motion <= 0;
				 
					Y_Motion <= Y_Motion + 1;
					
					if(Y_Pos + Y_Motion + Y_Motion + 3 >= Y_Center)
					begin
						jump <= 0;
					end
					
					if(Y_Pos + Y_Motion + 1 + Size >= Y_Center + Size)
					begin
						Y_Motion <= Y_Center - Y_Motion;
					end
				 end
				 */
				 case (keycode)
					8'h04 : begin

								if ((X_Pos - Size) > X_Min + 10)
								begin
									X_Motion <= -1;//A
									//Y_Motion<= 0;
								end
							  end
					        
					8'h07 : begin
							
								if((X_Pos + Size) < X_Max)
								begin
								  X_Motion <= 1;//D
								  //Y_Motion <= 0;
								end
							  end

							/*  
					8'h16 : begin
								
					        Y_Motion <= 1;//S
							  X_Motion <= 0;
							  
							  Y_Motion <= 0;//S
							  X_Motion <= 0;
							 end
							  
							  
					8'h1A : begin
								if((Y_Pos + Size) >= Y_Center && jump == 0)
								begin
									Y_Motion <= -4;
									jump <= 1;
								end
							  
					        Y_Motion <= -1;//W
							  X_Motion <= 0;
							  
					        Y_Motion <= 0;//W
							  X_Motion <= 0;
							 end	  */
					default: ;
			   endcase
				 
				 Y_Pos <= (Y_Pos + Y_Motion);  // Update ball position
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
	 
	 /*
	 logic [9:0] Y_Motion_in;
	 parameter [9:0] init_vel = 20;
	 logic [9:0] Y_Pos_in;
	 
	 always_comb
	 begin
		Y_Motion_in = Y_Motion + 1;
		Y_Pos = Y_Pos_in;
		
		if(keycode == 8'h1A)
		begin
			
			if(Y_Pos >= Y_Center)
			begin
					Y_Motion_in = (~init_vel) + 1'b1;
			end
			
			else if((Y_Pos + Y_Motion) > Y_Center)
			begin
					Y_Pos_in = Y_Center;
			end
			
			else
			begin
					Y_Pos_in = (Y_Pos + Y_Motion);
			end
		end
	 end*/
	 
       
    assign mcX = X_Pos;
   
    assign mcY = Y_Pos;
   
    assign mcS = Size;
    

endmodule