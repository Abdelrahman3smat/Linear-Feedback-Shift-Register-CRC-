module LFSR_CRC #(parameter CRC_width = 8) 
( 
 input 		 Data,
 input 		 Active,
 input 		 CLK,
 input 		 RST,
 output reg  CRC,
 output reg	 Valid
);

// Signals

wire    [CRC_width-1:0]    Seed;
reg     [CRC_width-1:0]    Register;       // LFSR Registers
wire                       Feedback;
reg     [3:0]              Counter;                    // To count 8 clk cycles


assign Seed = 'hD8;
assign Feedback = Data ^ Register[0];


always @ (posedge CLK or negedge RST)
    begin
        if (!RST)
            begin
                Register <= Seed;       // seed value will be assigned to the LFSR
                CRC <= 1'b0;
	    		Valid <= 1'b0;
                Counter <= 1'b0;
            end

        else if (Active)
            begin
                Valid <= 1'b0;
                Counter <= 1'b0;
                CRC <= 1'b0;
            // LFSR Operation Activated
                Register[7] <= Feedback;
                Register[6] <= Feedback ^ Register[7];
                Register[5] <= Register[6];
                Register[4] <= Register[5];
                Register[3] <= Register[4];
                Register[2] <= Feedback ^ Register[3];
                Register[1] <= Register[2];
                Register[0] <= Register[1];
            end

        else if (!Active && Counter < 'd8)
            begin
                Valid <= 1'd1;
            // CRC Out bit by bit
                CRC <= Register[0];
                Register <= Register >> 1;

                /*Register[0] <= Register[1];
                Register[1] <= Register[2];
                Register[2] <= Register[3];
                Register[3] <= Register[4];
                Register[4] <= Register[5];
                Register[5] <= Register[6];
                Register[6] <= Register[7];*/
                
                Counter <= Counter+1;           
            end

        
        else 
            begin
                Valid <= 1'd0;
                CRC <= 1'd0;
                Register <= 1'd0;
                Counter <= 1'b0;
            end
    end


endmodule
