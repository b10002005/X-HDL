module UART (CLK_50M, FPGA_nRST, UART_TX, UART_RX, UART_RTS, UART_CTS,BTN,R_Data,Data_ready);
    input  CLK_50M, FPGA_nRST;
    input  UART_RX, UART_CTS; 
    output UART_TX, UART_RTS;
    
    input BTN; 
    output [7:0]R_Data;
    output Data_ready;
        
    wire TxD_start;
    wire TxD_busy;  
    reg [7:0]TxD_data;
	wire    RxD_endofpacket,RxD_idle; 
	wire BufFull;
    
    assign TxD_start = BTN;
    
    always @(posedge CLK_50M or negedge FPGA_nRST)
    begin
        if(!FPGA_nRST)
            TxD_data<=8'h20;
        else if(TxD_busy==0) begin
            TxD_data<=8'h30;
        end 
    end
    
	Async_Transmitter   u0(
        .clk(CLK_50M),
        .TxD_start(TxD_start), 
        .TxD_data(TxD_data),
        .TxD(UART_TX),
        .TxD_busy(TxD_busy)
    );
 
	Async_Receiver      u1(
        .clk(CLK_50M),
        .RxD(UART_RX),
        .RxD_data_ready(Data_ready),
        .RxD_data(R_Data),
        .RxD_endofpacket(RxD_endofpacket),
        .RxD_idle(RxD_idle)
    );
  
endmodule
