module audio_data_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [10:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA,		// Exported Conduit Signal to LEDs

    // Audio bitstream
    input logic SCLK,
    input logic LRCLK,

	// Parallel Load Audio Data
	input logic [8191:0] queue_parallel_out,

	output logic [8191:0] audio_out,
	output logic LD_Q
	
);


// Let the audio information have addresses 0-255, let the audio_out information have addresses 256-511 and let the control have address 512

logic reg_load [256];
logic [31:0] reg_data [256];
logic [31:0] reg_out [256];
logic [8191:0] reg_out_packed;
genvar i;
// 256 registers each 32 bit
generate
for (i = 0; i < 256; i++) begin : audio_samples
     reg_variable #(.size(32)) AUDIO_DATA	(.Clk(SCLK), .Reset(RESET), .Load(LD_REG), .D(reg_data[i]), .Data_Out(reg_out[i]));
    //reg_variable #(.size(32)) AUDIO_DATA	(.Clk(CLK), .Reset(RESET), .Load(1'b1), .D(32'H0007), .Data_Out(reg_out[i]));
	// Register control signals
	assign reg_data[i] = queue_parallel_out[8191 - (i*32) : 8160 - (i*32)];
	assign reg_out_packed[8191 - (i*32) : 8160 - (i*32)] = reg_out[i];
	//assign reg_out_packed[8191 - (i*32) : 8160 - (i*32)] = 32'h5;
end
endgenerate

logic [31:0] audio_output [256];
logic [255:0] fft_load;
generate
for (i = 0; i < 256; i++) begin : fft_magnitudes
    reg_variable #(.size(32)) FFT_DATA	(.Clk(CLK), .Reset(RESET), .Load(fft_load[i]), .D(AVL_WRITEDATA), .Data_Out(audio_output[i]));
	assign audio_out[8191 - (i*32) : 8160 - (i*32)] = audio_output[i];
end
endgenerate

// Test functionality
assign EXPORT_DATA = audio_out[7935 : 7904];


logic READY_load;
logic [31:0] READY_out;

reg_variable #(.size(32)) READY	(.Clk(CLK), .Reset(RESET), .Load(READY_load), .D(AVL_WRITEDATA), .Data_Out(READY_out));
// When the bit inside READY is 1, there is data being transferred

audio_mux addr_mux (	.AVL_ADDR(AVL_ADDR), .AVL_WRITEDATA(AVL_WRITEDATA), .reg_out_packed(reg_out_packed), .READY_out(READY_out),
					 .AVL_READDATA(AVL_READDATA), .READY_load(READY_load), .fft_load(fft_load));

logic LD_REG;
transfer_FSM fsm (.RESET(RESET), .SCLK(SCLK), .LRCLK(LRCLK), .OCCUPIED(READY_out[0]), .LD_REG(LD_REG), .LD_Q(LD_Q));

endmodule

module transfer_FSM (	input logic RESET, SCLK, LRCLK, OCCUPIED,
						output logic LD_REG, LD_Q
);
	enum logic [2:0] {Load_queue, Load_reg, Load_neither} State, Next;
	logic fsm_ld_reg;
	always_ff @ (posedge SCLK) begin
		if (RESET)
			State <= Load_neither;
		else 
			State <= Next;
	end

	always_comb begin
		// Default is to stay at current state
		// Default control signal values
		Next = State;
		fsm_ld_reg = 1'b0;
		LD_Q = 1'b0;

		unique case (State)
			Load_queue: begin
				LD_Q = 1'b1;
				if (LRCLK == 1'b1)
					Next = Load_reg;
				else
					Next = Load_queue;
			end
			Load_reg: begin
				fsm_ld_reg = 1'b1;
				Next = Load_neither;
			end
			Load_neither: begin
				if (LRCLK == 1'b0) 
					Next = Load_queue;
				else
					Next = Load_neither;
			end
			default: ;
		endcase

		unique case (OCCUPIED) 
			1'b0: LD_REG = fsm_ld_reg;
			1'b1: LD_REG = 1'b0;
			default: ;
		endcase
	end

endmodule