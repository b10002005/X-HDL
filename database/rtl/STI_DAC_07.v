module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	       so_data, so_valid,
	       pixel_finish, pixel_dataout, pixel_addr,
	       pixel_wr);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end; 
input		[15:0]	pi_data;
input		[1:0]	pi_length;
input		pi_fill;
output		so_data, so_valid;

output 	 	pixel_finish, pixel_wr;
output 		[7:0] pixel_addr;
output 		[7:0] pixel_dataout;

//==============================================================================



reg 		t_pi_msb, t_pi_low,t_pi_fill;
reg			[1:0]	t_pi_length;
reg			[15:0]	t_pi_data;
reg			d[15:0] ;
reg			ss ;
reg			so_data  ;
reg 		so_valid ;
wire 		ff ;
reg			[31:0] buffer ; 
reg			[4:0]data_cnt  ;
reg 		load_cnt ;
reg			[4:0]so_cnt ;
reg			[4:0]men_cnt ;
reg			[7:0]pixel_addr,da ,q;
reg 		pixel_wr ;
reg 		d_so_valid ,x;
reg			pixel_finish ;
wire 		[7:0]pp ;
reg 		[7:0]pixel_dataout ;
reg		finish ;



assign		ff = buffer[data_cnt] ; 
assign 		pp = (men_cnt[3:0]==4'd0) ? da :  pixel_dataout ;

always @ (posedge clk or posedge reset)
begin 
	if(reset)begin 
		pixel_dataout <=8'd0 ;
	end 
	else begin//32bit
		pixel_dataout <= pp;
	end
end

always @ (posedge clk or posedge reset)
begin//32bit
	if(reset)
		so_data <=  ff ;
	else begin 
		so_data <= ff ; 
	end
end

always @ (posedge clk or posedge reset)
begin
	if(reset)
		finish<=1'b0 ;
	else begin
		if(pixel_addr==8'd255)	begin 
			finish<=1'b1 ;
		end
	end	
end 	

always @(posedge clk or posedge reset)
begin 
	if(reset)begin 
		pixel_finish<=1'b0 ;
	end
	else begin 
		pixel_finish<=finish ;
	end 
end 

always @ (posedge clk or posedge reset)
begin
	if(reset)begin 
		x <=1'b0 ;
	end 
	else begin 
		if((so_cnt==5'd0) && pi_end)begin 
			x <=1'b1 ;
		end
	end 	
end

always @ (posedge clk or posedge reset)
begin 
	if(reset)begin 
		da <= 8'd0 ;
	end 
	else begin 
		if(!x)begin 
			if(ss)begin 
				
					da[0] <=buffer[data_cnt] ;
					da[1] <=da[0];
					da[2] <=da[1];
					da[3] <=da[2];
					da[4] <=da[3];
					da[5] <=da[4];
					da[6] <=da[5];
					da[7] <=da[6];
				end
				// else begin 
					// pixel_dataout <= 8'd0 ;
				// end 

		end	
		else begin//32bit
			da <= 8'd0 ;
		end
	end 	
end 	

always @ (posedge clk or posedge reset)
begin 
	if(reset)begin 
		so_valid <= 1'b0 ;
	end 
	else begin 
		so_valid <= ss ;
	end
end 	

always @ (posedge clk or posedge reset)//pixel_addr
begin
	if(reset)begin 
		pixel_wr <= 1'd0  ;
	end 
	else begin
		if(!x)begin 
			if(men_cnt==4'd0)begin 
				if(q>8'd3)begin
					pixel_wr <= 1'd1 ;
				end	
			end 
			else begin
				pixel_wr <= 1'd0  ;
			end
		end
		else begin 
			pixel_wr <=!pixel_wr ;
		end
	end
end

always @ (posedge clk or posedge reset)//pixel_addr
begin
	if(reset)begin 
		pixel_addr <= 8'd0  ;
	end 
	else begin
		if(!x)begin 
			if(men_cnt==4'd1)begin 
				if(q>8'd3)begin 
					pixel_addr <= pixel_addr + 8'd1 ;
				end	
			end 
		end
		else begin 
			if(pixel_wr)begin 
				pixel_addr <= pixel_addr + 8'd1 ;
			end	
		end 
	end
end


always @ (posedge clk or posedge reset)
begin 
	if(reset)begin
		men_cnt <= 5'b00000 ;
	end 
	else begin

		if(ss) begin 
			if(men_cnt[3:0] < 4'd7)begin 
				men_cnt[3:0] <= men_cnt [3:0]+ 4'd1 ;
			end	
			else 	
				men_cnt[3:0] <= 4'd0 ; 
		end	
		else begin
			men_cnt [3:0]<= 4'd0 ;
		end
	end
end


always @ (posedge clk or posedge reset)
begin 
	if(reset)begin
		q<= 8'd0 ;
	end 
	else begin

			if(ss&&(men_cnt < 4'd7)&&(q<8'd254))begin 
					q <= q + 8'd1 ;
			end	
	end
end

always @ (posedge clk or posedge reset)//so_cnt
begin 
	if(reset)begin 
		so_cnt<=5'd31 ; 
	end 
	else begin 
		if(load)begin
			case (pi_length)
				2'd0: so_cnt<= 5'd7 ;
				2'd1: so_cnt<= 5'd15 ;
				2'd2: so_cnt<= 5'd23 ;
				2'd3: so_cnt<= 5'd31 ;
			endcase
		end	
		else begin
			if(ss)begin
				if(so_cnt>5'd0)begin 
					so_cnt <= so_cnt -5'd1 ;
				end 	
			end
		end 
	end 	
end 	

always @ (posedge clk or posedge reset) //ss
begin
	if(reset)begin 
		ss <=1'b0 ;
	end 
	else begin
		if(load_cnt)begin 
			ss <= 1'b1 ;
		end	
		else begin 
			if(so_cnt==5'd0)begin // 詨
				ss <=1'b0 ;
			end	
		end
	end 
end 	

always @ (posedge clk or posedge reset)//load_cnt
begin 
	if(reset)begin 
		load_cnt <=1'b0 ;
	end 	
	else begin 
		if(load)begin 
			load_cnt <=1'b1 ;
		end
		else if(ss) begin 
			load_cnt <=1'b0 ;
		end
	end
end 	

always @ (posedge clk or posedge reset )// load data
begin 
	if(reset)begin 
		t_pi_msb <= 1'b0 ;
		t_pi_low <= 1'b0 ;
		t_pi_fill <= 1'b0 ;
		t_pi_length <= 2'd0 ;
		t_pi_data	<= 16'd0 ;	
	end 
	else begin
		if(load)begin
			t_pi_msb 	<= pi_msb 	 ;
			t_pi_low 	<= pi_low 	 ;
			t_pi_fill 	<= pi_fill 	 ;
			t_pi_length <= pi_length ;		
			t_pi_data	<= pi_data ;			
		end 
	end	
end 	

always @ (*)// arrange buffer
begin
	if(t_pi_length==2'd0)begin//8bit
		buffer[31:8] = 24'd0 ;
		if(t_pi_low)begin // MSB
			buffer[7:0] = t_pi_data [15:8] ;
		end	
		else begin 	//LSB
			buffer[7:0] = t_pi_data [7:0] ;
		end
	end 
	else if(t_pi_length==2'd1)begin //16bit
		buffer[31:16] = 16'd0 ;
		buffer[15:0]  = t_pi_data ;
	end 
	else if(t_pi_length==2'd2)begin //24bit 
		buffer[31:24] = 8'd0 ;
		if(t_pi_fill)begin //mab
			buffer[23:8]  =	 t_pi_data;
			buffer[7:0]   =  8'd0; 
		end	
		else begin	
			buffer[23:16] =	 8'd0;
			buffer[15:0]  =  t_pi_data ;
		end
	end 
	else begin//32bit
		if(t_pi_fill)begin //mab
			buffer[31:16]  =  t_pi_data;
			buffer[15:0]   =  8'd0; 
		end	
		else begin	
			buffer[31:16] =	 8'd0;
			buffer[15:0]  =  t_pi_data ;
		end	
	end 
end 

always @ (posedge clk or posedge reset)//data_cnt
begin
	if(reset)begin 
		data_cnt <= 5'd0 ;
	end
	else begin 
		if(load)begin 
			if(pi_msb)begin //  msb
				if(pi_length==2'd0)begin
					data_cnt <= 5'd7 ;
				end
				else if(pi_length==2'd1)begin
					data_cnt <= 5'd15 ;
				end
				else if(pi_length==2'd2)begin
					data_cnt <= 5'd23 ;
				end
				else begin
					data_cnt <= 5'd31 ;
				end
			end 
			else begin 
				data_cnt <= 5'd0 ;
			end
		end 
		else begin
			if(ss)begin 
				if(t_pi_msb)begin //  msb
					if(data_cnt > 5'd0)
						data_cnt <= data_cnt - 5'd1 ;
				end 
				else begin 	
					if((t_pi_length==2'd0) && (data_cnt < 5'd7) )begin
						data_cnt <= data_cnt + 5'd1 ;
					end
					else if((t_pi_length==2'd1) && (data_cnt <5'd15) )begin
						data_cnt <= data_cnt + 5'd1 ;
					end
					else if((t_pi_length==2'd2) && (data_cnt <5'd23) )begin
						data_cnt <= data_cnt + 5'd1 ;
					end
					else if((t_pi_length==2'd3) && (data_cnt <5'd31) )begin
						data_cnt <= data_cnt + 5'd1 ;
					end			
				end	
			end	
		end
	end 
end

endmodule
