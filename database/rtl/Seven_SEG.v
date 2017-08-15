module Seven_SEG (FPGA_nRST, CLK_1K, Hide, Number, Dot, SEG_HEX, SEG_SEG);
	
	input FPGA_nRST, CLK_1K;
	input [5:0] Hide, Dot;
	input [23:0] Number;
	output reg [5:0] SEG_HEX;
	output reg [7:0] SEG_SEG;
	
	reg [2:0] Scan_count;
	reg [3:0] Number_buffer;
	
	always @(posedge CLK_1K or negedge FPGA_nRST) begin
		if (!FPGA_nRST)
			Scan_count <= 0;
		else if (Scan_count==5)
			Scan_count <= 0;
		else
			Scan_count <= Scan_count + 1'b1;
	end
	
	always @(Scan_count or FPGA_nRST) begin
		if (!FPGA_nRST)
			SEG_HEX = 6'b111111;
		else
			case (Scan_count)
				0:		SEG_HEX = 6'b111110;
				1:		SEG_HEX = 6'b111101;
				2:		SEG_HEX = 6'b111011;
				3:		SEG_HEX = 6'b110111;
				4:		SEG_HEX = 6'b101111;
				5:		SEG_HEX = 6'b011111;				
			default:	SEG_HEX = 6'b111111;
			endcase
	end
	
	always @(Scan_count) begin
		case (Scan_count)
			0:		Number_buffer = Number[3:0];
			1:		Number_buffer = Number[7:4];
			2:		Number_buffer = Number[11:8];
			3:		Number_buffer = Number[15:12];
			4:		Number_buffer = Number[19:16];
			5:		Number_buffer = Number[23:20];		
		default:	Number_buffer = 4'bxxxx;
		endcase
	end
	
	always @(*) begin
		if (Hide[Scan_count]==1)
			SEG_SEG = 8'hff;
		else
			case (Number_buffer)
				4'h0:		SEG_SEG = {Dot[Scan_count], 7'b100_0000};
				4'h1:		SEG_SEG = {Dot[Scan_count], 7'b111_1001};
				4'h2:		SEG_SEG = {Dot[Scan_count], 7'b010_0100};
				4'h3:		SEG_SEG = {Dot[Scan_count], 7'b011_0000};
				4'h4:		SEG_SEG = {Dot[Scan_count], 7'b001_1001};
				4'h5:		SEG_SEG = {Dot[Scan_count], 7'b001_0010};
				4'h6:		SEG_SEG = {Dot[Scan_count], 7'b000_0010};
				4'h7:		SEG_SEG = {Dot[Scan_count], 7'b111_1000};
				4'h8:		SEG_SEG = {Dot[Scan_count], 7'b000_0000};
				4'h9:		SEG_SEG = {Dot[Scan_count], 7'b001_1000};
				
				4'ha:		SEG_SEG = {Dot[Scan_count], 7'b000_1000};
				4'hb:		SEG_SEG = {Dot[Scan_count], 7'b000_0011};
				4'hc:		SEG_SEG = {Dot[Scan_count], 7'b100_0110};
				4'hd:		SEG_SEG = {Dot[Scan_count], 7'b010_0001};
				4'he:		SEG_SEG = {Dot[Scan_count], 7'b000_0110};
				4'hf:		SEG_SEG = {Dot[Scan_count], 7'b000_1110};
			default:		SEG_SEG = 8'hff;
			endcase
	end
	
endmodule
