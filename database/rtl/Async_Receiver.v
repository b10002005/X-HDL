module Async_Receiver(clk, RxD, RxD_data_ready, RxD_data, RxD_endofpacket, RxD_idle);
	input clk, RxD;
	output RxD_data_ready;  
	output [7:0] RxD_data;

	parameter ClkFrequency = 50000000; 
	parameter Baud = 115200;

	output RxD_endofpacket;  
	output RxD_idle; 

	parameter Baud8 = Baud*8;
	parameter Baud8GeneratorAccWidth = 16;
	parameter Baud8GeneratorInc = ((Baud8<<(Baud8GeneratorAccWidth-7))+(ClkFrequency>>8))/(ClkFrequency>>7);
	reg [Baud8GeneratorAccWidth:0] Baud8GeneratorAcc;
	
	always @(posedge clk)
	begin
		Baud8GeneratorAcc <= Baud8GeneratorAcc[Baud8GeneratorAccWidth-1:0] + Baud8GeneratorInc;
	end
	
	wire Baud8Tick = Baud8GeneratorAcc[Baud8GeneratorAccWidth];

	reg [1:0] RxD_sync_inv;
	always @(posedge clk) 
	begin
		if(Baud8Tick) RxD_sync_inv <= {RxD_sync_inv[0], ~RxD};
	end

	reg [1:0] RxD_cnt_inv;
	reg RxD_bit_inv;

	always @(posedge clk)
	begin
	if(Baud8Tick)
		begin
			if( RxD_sync_inv[1] && RxD_cnt_inv!=2'b11) 
				RxD_cnt_inv <= RxD_cnt_inv + 1;
			else if(~RxD_sync_inv[1] && RxD_cnt_inv!=2'b00) 
				RxD_cnt_inv <= RxD_cnt_inv - 1;

			if(RxD_cnt_inv==2'b00) 
				RxD_bit_inv <= 0;
			else if(RxD_cnt_inv==2'b11) 
				RxD_bit_inv <= 1;
		end
	end

	reg [3:0] state;
	reg [3:0] bit_spacing;

	wire next_bit = (bit_spacing==10);

	always @(posedge clk)
	begin
		if(state==0)
		  bit_spacing <= 0;
		else if(Baud8Tick)
		  bit_spacing <= {bit_spacing[2:0] + 1} | {bit_spacing[3], 3'b000};
	end

	always @(posedge clk)
	begin
	if(Baud8Tick)
		case(state)
			4'b0000: if(RxD_bit_inv) state <= 4'b1000; 
			4'b1000: if(next_bit) state <= 4'b1001;  
			4'b1001: if(next_bit) state <= 4'b1010;  
			4'b1010: if(next_bit) state <= 4'b1011;  
			4'b1011: if(next_bit) state <= 4'b1100;  
			4'b1100: if(next_bit) state <= 4'b1101;  
			4'b1101: if(next_bit) state <= 4'b1110;  
			4'b1110: if(next_bit) state <= 4'b1111;  
			4'b1111: if(next_bit) state <= 4'b0001; 
			4'b0001: if(next_bit) state <= 4'b0000; 
			default: state <= 4'b0000;
		endcase
	end

	reg [7:0] RxD_data;
	
	always @(posedge clk)
	begin
		if(Baud8Tick && next_bit && state[3])
			RxD_data <= {~RxD_bit_inv, RxD_data[7:1]};
	end
	
	reg RxD_data_ready, RxD_data_error;
	always @(posedge clk)
	begin
	  RxD_data_ready <= (Baud8Tick && next_bit && state==4'b0001 && ~RxD_bit_inv);
	  RxD_data_error <= (Baud8Tick && next_bit && state==4'b0001 &&  RxD_bit_inv);
	end

	reg [4:0] gap_count;
	
	always @(posedge clk) 
	begin
		if (state!=0) 
			gap_count<=0; 
		else if(Baud8Tick & ~gap_count[4]) 
			gap_count <= gap_count + 1;
	end
	
	assign RxD_idle = gap_count[4];
	reg RxD_endofpacket; 
	
	always @(posedge clk) 
	begin
		RxD_endofpacket <= Baud8Tick & (gap_count==15);
	end

endmodule
