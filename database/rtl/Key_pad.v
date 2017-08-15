module Key_pad (CLK_50M, CLK_50, KPD_R, KPD_C, KPD_state, KPD_down, KPD_up, KPD_value);
	
	input CLK_50M, CLK_50;
	output reg [2:0] KPD_R;
	input [3:0] KPD_C;
	output reg KPD_state;
	output KPD_down, KPD_up;
	output reg [3:0] KPD_value;
	
	reg [1:0] Scan_count;
	
	wire KPD;				assign KPD = & KPD_C;
	reg KPD_sync_0;		always @(posedge CLK_50M) KPD_sync_0 <= ~KPD;
	reg KPD_sync_1;		always @(posedge CLK_50M) KPD_sync_1 <= KPD_sync_0;
	
	reg [19:0] KPD_count;
	
	wire KPD_idle = (KPD_state==KPD_sync_1);
	wire KPD_count_max = &KPD_count;
	
	always @(posedge CLK_50M) begin
		if (KPD)
			if (Scan_count==2)
				Scan_count <= 0;
			else
				Scan_count <= Scan_count + 1'b1;
	end
	
	always @(Scan_count) begin
		case (Scan_count)
			0:		KPD_R = 3'b110;
			1:		KPD_R = 3'b101;
			2:		KPD_R = 3'b011;			
		default:	KPD_R = 3'bxxx;
		endcase
	end
	
	always @(posedge CLK_50M) begin
		if (KPD_idle)
			KPD_count <= 0;
		else begin
			KPD_count <= KPD_count + 19'd1;
			if (KPD_count_max)
				KPD_state <= ~KPD_state;
		end
	end
	
	assign KPD_down = ~KPD_idle & KPD_count_max & ~KPD_state;
	assign KPD_up   = ~KPD_idle & KPD_count_max &  KPD_state;
	
	always @(KPD_R, KPD_C) begin
		case ({KPD_R, KPD_C})
			7'b110_1110:	KPD_value = 4'h1;
			7'b110_1101:	KPD_value = 4'h2;
			7'b110_1011:	KPD_value = 4'h3;
			7'b110_0111:	KPD_value = 4'ha;
			
			7'b101_1110:	KPD_value = 4'h4;
			7'b101_1101:	KPD_value = 4'h5;
			7'b101_1011:	KPD_value = 4'h6;
			7'b101_0111:	KPD_value = 4'hb;
			
			7'b011_1110:	KPD_value = 4'h7;
			7'b011_1101:	KPD_value = 4'h8;
			7'b011_1011:	KPD_value = 4'h9;
			7'b011_0111:	KPD_value = 4'h0;
			
			default:			KPD_value = 4'hf;
		endcase
	end
	
endmodule
