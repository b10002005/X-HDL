module VGA_Timing(CLK_50M, FPGA_nRST, VGA_VS, VGA_HS, VS_Count, HS_Count, Data_valid);
	input  CLK_50M, FPGA_nRST;
	output reg VGA_VS, VGA_HS;
	output reg [9:0] HS_Count;
	output reg [9:0] VS_Count;
	output wire Data_valid;
	
	reg CLK_25M;
	reg [1:0]CLK_cnt;
	
	parameter H_Visible_area 	= 640	;
	parameter H_Front_proch 	= 16	;
	parameter H_Sync_pulse 		= 96	;
	parameter H_Back_porch 		= 48	;
	parameter H_Whole_line 		= 800	;
	
	parameter H1 = H_Sync_pulse;
	parameter H2 = H_Sync_pulse + H_Back_porch;
	parameter H3 = H_Sync_pulse + H_Back_porch + H_Visible_area;
	parameter H4 =	H_Sync_pulse + H_Back_porch + H_Visible_area + H_Front_proch;
	
	parameter V_Visible_area 	= 480	;
	parameter V_Front_proch 	= 10	;
	parameter V_Sync_pulse 		= 2	;
	parameter V_Back_porch 		= 33	;
	parameter V_Whole_frame		= 525	;
	
	parameter V1 = V_Sync_pulse;
	parameter V2 = V_Sync_pulse + V_Back_porch;
	parameter V3 = V_Sync_pulse + V_Back_porch + V_Visible_area;
	parameter V4 =	V_Sync_pulse + V_Back_porch + V_Visible_area + V_Front_proch;	
	
	always @(posedge CLK_50M or negedge FPGA_nRST)
	begin
		if(!FPGA_nRST)
			CLK_cnt<=0;
		else if(CLK_cnt==1)
			CLK_cnt<=0;
		else 
			CLK_cnt<=CLK_cnt+1;
	end
	
	always @(posedge CLK_50M or negedge FPGA_nRST)
	begin
		if(!FPGA_nRST)
			CLK_25M<=0;
		else if(CLK_cnt==1)
			CLK_25M<=0;
		else 
			CLK_25M<=1;		
	end	
	
	always @(posedge CLK_25M or negedge FPGA_nRST)
	begin	
		if(!FPGA_nRST)
			HS_Count<=0;
		else if(HS_Count==H_Whole_line-1)
			HS_Count<=0;
		else 
			HS_Count<=HS_Count+1;
	end

	always @(posedge CLK_25M or negedge FPGA_nRST)
	begin	
		if(!FPGA_nRST)
			VS_Count<=0;
		else if(VS_Count==V_Whole_frame-1 && HS_Count==H_Whole_line-1)
			VS_Count<=0;
		else if(HS_Count==H_Whole_line-1) 
			VS_Count<=VS_Count+1;
	end
	
	always @(posedge CLK_25M or negedge FPGA_nRST)
	begin	
		if(!FPGA_nRST)
			VGA_HS<=0;
		else if(HS_Count<H_Sync_pulse)
			VGA_HS<=0;
		else 
			VGA_HS<=1;
	end
	
	always @(posedge CLK_25M or negedge FPGA_nRST)
	begin	
		if(!FPGA_nRST)
			VGA_VS<=0;
		else if(VS_Count<V_Sync_pulse)
			VGA_VS<=0;
		else 
			VGA_VS<=1;
	end	
	
	assign Data_valid = (HS_Count >= H2) && (HS_Count < H3)
							&&(VS_Count >= V2) && (VS_Count < V3);

endmodule


