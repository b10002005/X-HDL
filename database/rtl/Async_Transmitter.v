module Async_Transmitter(clk, TxD_start, TxD_data, TxD, TxD_busy);
    input clk, TxD_start;
    input [7:0] TxD_data;
    output TxD, TxD_busy;

    parameter ClkFrequency = 50000000; 
    parameter Baud = 115200;

    parameter BaudGeneratorAccWidth = 16;
    parameter BaudGeneratorInc = ((Baud<<(BaudGeneratorAccWidth-4))+(ClkFrequency>>5))/(ClkFrequency>>4);
    
    reg [BaudGeneratorAccWidth:0] BaudGeneratorAcc;
    wire BaudTick = BaudGeneratorAcc[BaudGeneratorAccWidth];
    wire TxD_busy;
    
    always @(posedge clk) 
    begin
        if(TxD_busy) BaudGeneratorAcc <= BaudGeneratorAcc[BaudGeneratorAccWidth-1:0] + BaudGeneratorInc;
    end
    
    reg [3:0] state;
    assign TxD_busy = (state!=0);

    always @(posedge clk)
    begin
        case(state)
            4'b0000: if(TxD_start) state <= 4'b0100;
            4'b0100: if(BaudTick) state <= 4'b1000;  
            4'b1000: if(BaudTick) state <= 4'b1001;  
            4'b1001: if(BaudTick) state <= 4'b1010;  
            4'b1010: if(BaudTick) state <= 4'b1011;  
            4'b1011: if(BaudTick) state <= 4'b1100;  
            4'b1100: if(BaudTick) state <= 4'b1101;  
            4'b1101: if(BaudTick) state <= 4'b1110;  
            4'b1110: if(BaudTick) state <= 4'b1111;  
            4'b1111: if(BaudTick) state <= 4'b0001;  
            4'b0001: if(BaudTick) state <= 4'b0010;  
            4'b0010: if(BaudTick) state <= 4'b0000; 
            default: if(BaudTick) state <= 4'b0000;
        endcase
    end

    reg muxbit;
    always @(state[2:0] or TxD_data)
    begin
        case(state[2:0])
            0: muxbit <= TxD_data[0];
            1: muxbit <= TxD_data[1];
            2: muxbit <= TxD_data[2];
            3: muxbit <= TxD_data[3];
            4: muxbit <= TxD_data[4];
            5: muxbit <= TxD_data[5];
            6: muxbit <= TxD_data[6];
            7: muxbit <= TxD_data[7];
        endcase
    end

    reg TxD;
    always @(posedge clk) 
    begin
        TxD <= (state<4) | (state[3] & muxbit); 
    end
    
endmodule
