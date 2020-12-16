//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8 (

      ///////// Clocks /////////
      input              Clk,

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


////////////////////

// NEW ADDITIONs
logic [9:0] bombxsig, bombysig;
logic [3:0] hex_life;


////////////////////

//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
	logic [7:0] Red, Blue, Green;
	logic [7:0] keycode;
	
	logic aud_i2c_sda_in;
	logic aud_i2c_scl_in;
	logic aud_i2c_sda_oe;
	logic aud_i2c_scl_oe;

	logic [1:0] aud_mclk_ctr;

	logic SCLK;
	logic LRCLK;
	logic MCLK;
	logic I2S_DIN;
	logic I2S_DOUT;

	logic LEFT_CLK, LOAD_LEFT;
	logic [31:0] LEFT_IN, LEFT_OUT;
	logic RIGHT_CLK, LOAD_RIGHT;
	logic [31:0] RIGHT_IN, RIGHT_OUT;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	/*
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	*/
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	
	
	lab8_soc u0 (
		.clk_clk                           (Clk),            //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		//.clk_sdram_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode),
		
		.i2c0_sda_in(aud_i2c_sda_in),
		.i2c0_scl_in(aud_i2c_scl_in),
		.i2c0_sda_oe(aud_i2c_sda_oe),
		.i2c0_scl_oe(aud_i2c_scl_oe),

		.audio_data_0_readdata(hex_info),                         // conduit_end.readdata
		.audio_data_0_lrclk(LRCLK),
		.audio_data_0_sclk(SCLK),
		.audio_data_0_queue_parallel_out(queue_parallel_out),
		.audio_data_0_audio_out(audio_out),
		.audio_data_0_ld_q(LD_Q)

	 );


	//instantiate a vga_controller, ball, and color_mapper here with the ports.
	vga_controller		vga_module (.Clk(Clk), .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(VGA_Clk), .blank(blank), .sync(sync), .DrawX(drawxsig), .DrawY(drawysig));

	//ball					ball_module (.Reset(Reset_h), .frame_clk(VGA_VS), .keycode(keycode), .BallX(ballxsig), .BallY(ballysig), .BallS(ballsizesig));
	
	//color_mapper		color_module (.BallX(ballxsig), .BallY(ballysig), .DrawX(drawxsig), .DrawY(drawysig), .Ball_size(ballsizesig), .Red(Red), .Green(Green), .Blue(Blue));

	
	
	//*****SINGLE BAR VER*****//
	/*
	//logic [9:0] barxsig, barysig, barwsig, barhsig;
	color_mapper		color_module (.BarX(barxsig), .BarY(barysig), .BarW(barwsig), .BarH(barhsig), .DrawX(drawxsig), .DrawY(drawysig), .Red(Red), .Green(Green), .Blue(Blue));
	
	bar					bar_module (.Reset(Reset_h), .frame_clk(VGA_VS), .keycode(keycode), .BarX(barxsig), .BarY(barysig), .BarH(barhsig), .BarW(barwsig));
	*/
	
	
	//*****MULTIPLE BAR VER*****//
	parameter int bar_count = 128;
	
	logic [9:0] num_bars;
	logic [9:0] bar_x [bar_count - 1:0];
	logic [9:0] bar_y [bar_count - 1:0];
	logic [9:0] bar_width;
	logic [9:0] bar_height [bar_count - 1:0];
	
	logic [9:0] max_x;
	
	// logic [8191:0] audio_out; // Connected to the audio out of the SoC
	
	bar_generator #( .bar_count(bar_count))		bar_gen_module ( .Reset(Reset_h), .frame_clk(VGA_VS),
																					  .num_bars(num_bars),
																					  .bar_x(bar_x),
																					  .bar_y(bar_y),
																					  .bar_width(bar_width),
																					  .bar_height(bar_height),
																					  .audio_output(queue_parallel_out),
																					  .max_x(max_x) );
								 
	bar_color_mapper #( .bar_count(bar_count))	bar_map_module ( .DrawX(drawxsig), .DrawY(drawysig),
																					  .bar_x(bar_x),
																					  .bar_y(bar_y),
																					  .bar_width(bar_width),
																					  .bar_height(bar_height),
																					  .Red(Red), .Green(Green), .Blue(Blue),
																					  .BallX(ballxsig), .BallY(ballysig), .Ball_size(ballsizesig),
																					  .BombX(bombxsig), .BombY(bombysig));
	
	
	
	
	//HexDriver			hex0_module (keycode[3:0], HEX0);
	//HexDriver			hex1_module (keycode[7:4], HEX1);
	assign aud_i2c_scl_in = ARDUINO_IO[15];              //AUD_I2C_SCL 
	assign ARDUINO_IO[15] = aud_i2c_scl_oe ? 1'b0 : 1'bZ; //pull down if OE is high
 
	assign aud_i2c_sda_in = ARDUINO_IO[14];              //AUD_I2C_SDA
	assign ARDUINO_IO[14] = aud_i2c_sda_oe ? 1'b0 : 1'bZ; //pull down if OE is high
	
	assign ARDUINO_IO[3] = aud_mclk_ctr[1];	 //generate 12.5MHz CODEC mclk
	
	// always_ff @(posedge MAX10_CLK2_50) begin
	always_ff @(posedge Clk) begin
		aud_mclk_ctr <= aud_mclk_ctr + 1;
	end

	// I2S
	assign SCLK = ARDUINO_IO[5];
	assign LRCLK = ARDUINO_IO[4];
	assign MCLK = ARDUINO_IO[3];
	assign ARDUINO_IO[2] = I2S_DIN;
	assign I2S_DOUT = ARDUINO_IO[1];

	/*
	always_comb
	begin
		case(LRCLK)
			1'b0: begin 
				LEFT_CLK = SCLK;
				RIGHT_CLK = 1'b0;
				I2S_DIN = LEFT_OUT;
			end
			1'b1: begin
				RIGHT_CLK = SCLK;
				LEFT_CLK = 1'b0;
				I2S_DIN = RIGHT_OUT;
			end
			default: begin
				LEFT_CLK = 1'b0;
				RIGHT_CLK = 1'b0;
			end
		endcase
	end
	assign LOAD_LEFT = I2S_DIN;
	assign LOAD_RIGHT = I2S_DIN;
	*/
	assign I2S_DIN = I2S_DOUT;


	logic queue_shift_out;
	logic [8191:0] queue_parallel_out;
	logic LD_Q;
	// Din queue 

		//shift_reg_var #(.size(8192))	data_in_queue 	(.Clk(SCLK), .Reset(Reset_h), .Shift_In(1'b1), .Load(1'h0), .Shift_En(LD_Q),
	shift_reg_var #(.size(8192))	data_in_queue 	(.Clk(SCLK), .Reset(Reset_h), .Shift_In(I2S_DIN), .Load(1'h0), .Shift_En(LD_Q),
              .D(8192'h0),
              .Shift_Out(queue_shift_out),
              .Data_Out(queue_parallel_out));


	// Shift register 0. Left shift This is directly connected to I2S
	shift_reg_variable #(.size(32)) left (.Clk(LEFT_CLK), .Reset(Reset_h), .Parallel_Load(LOAD_LEFT),
							.D(LEFT_IN),
							.Data_Out(LEFT_OUT));
	// Shift register 1
	shift_reg_variable #(.size(32)) right (.Clk(RIGHT_CLK), .Reset(Reset_h), .Parallel_Load(LOAD_RIGHT),
							.D(RIGHT_IN),
							.Data_Out(RIGHT_OUT));

	logic [31:0] hex_info;
	
	//HexDriver driver0 (.In0(hex_info[3:0]), .Out0(HEX0));
	//HexDriver driver1 (.In0(hex_info[7:4]), .Out0(HEX1));
	//HexDriver driver2 (.In0(hex_info[11:8]), .Out0(HEX2));
	//HexDriver driver3 (.In0(hex_info[15:12]), .Out0(HEX3));
	//HexDriver driver4 (.In0(hex_info[19:16]), .Out0(HEX4));
	//HexDriver driver5 (.In0(hex_info[23:20]), .Out0(HEX5));
	
	
	
	main_character		mc_module (.Reset(Reset_h), .frame_clk(VGA_VS), .keycode(keycode), .mcX(ballxsig), .mcY(ballysig), .mcS(ballsizesig));
	bomb					bomb_module (.Reset(Reset_h), .frame_clk(VGA_VS), .keycode(keycode), .bombX(bombxsig), .bombY(bombysig), .curPoints(hex_life), .max_x(max_x));
	lives					life_ctr(.Reset(Reset_h), .frame_clk(VGA_VS), .bombX(bombxsig), .bombY(bombysig), .mcX(ballxsig), .mcY(ballysig), .hex_life(hex_life));
	HexDriver hex_driver0 (hex_life, HEX0[6:0]);
	
	
endmodule
