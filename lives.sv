module  lives ( input Reset, frame_clk,
					 input [9:0]  bombX, bombY,
					 input [9:0] mcX, mcY,
					 output [3:0] hex_life);
logic [3:0] life;
logic touching;
int DistX, DistY;

assign DistX = mcX - bombX;
assign DistY = mcY - bombY;

always_ff @ (posedge Reset or posedge frame_clk )
    begin: Yes
        if (Reset)  // Asynchronous Reset
        begin 
				life <= 4'd0;
				touching <= 1'd0;
        end
           
        else 
        begin 
		  
			  if(touching == 1'd1 && (DistX < -6 || DistX > 6 ||  DistY > 12))
					touching <= 1'd0;
			  
			  if(DistX > -6 && DistX < 6 && DistY < 12 && touching == 1'd0)
			  begin
			
			  touching <= 1'd1;
			  life <= life + 1'd1;
		
			  end
		  
		  end
end
		

assign hex_life = life;

endmodule 