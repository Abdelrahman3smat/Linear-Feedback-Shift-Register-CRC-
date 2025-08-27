`timescale 1ns/1ps

module LFSR_CRC_tb ();

// Parameters 
parameter CRC_width_tb = 8;
parameter CLK_Period = 100;
parameter Test_Cases = 10;

integer operation;


// DUT Signals
reg     Data_tb;
reg     Active_tb;
reg     CLK_tb;
reg     RST_tb;
wire    CRC_tb;
wire    Valid_tb;


// Memories
reg     [CRC_width_tb-1:0]  Data_IN_H   [0:Test_Cases-1];
reg     [CRC_width_tb-1:0]  Excpec_OUT_H   [0:Test_Cases-1];


// DUT Instantiation
LFSR_CRC DUT (
    .Data (Data_tb),
    .Active (Active_tb),
    .CLK (CLK_tb),
    .RST (RST_tb),
    .CRC (CRC_tb),
    .Valid (Valid_tb)
);


// Clock Generation 
always #(CLK_Period/2) CLK_tb = ~CLK_tb;



// Initial Block
initial 
    begin
        
        $monitor("** Time = %0t, Active = %d, Valid = %d **", $time, Active_tb, Valid_tb);  // to make sure that Active and Valid not High together

        $dumpfile("LFSR_CRC_tb.vcd");
        $dumpvars;
    
    // Read Files
        $readmemh ("DATA_h.txt", Data_IN_H);
        $readmemh ("Expec_Out_h.txt", Excpec_OUT_H);

        intialization();
    
    // Test cases
        for (operation = 0 ; operation < Test_Cases ; operation = operation+1) 
            begin
                Read (Data_IN_H[operation]);
                write (Excpec_OUT_H[operation] , operation);
            end

        #100
        $finish ;
    end



// Tasks


// Initialiation
task intialization;
    begin
        CLK_tb = 1'b0;
        RST_tb = 1'b0;
        Active_tb = 1'b0;
        Data_tb = 1'b0;
    end
endtask



// Reset
task Reset;
    begin
        RST_tb = 1'b1;
        #(CLK_Period)
        RST_tb = 1'b0;
        #(CLK_Period)
        RST_tb = 1'b1;
        Active_tb = 1'b1;
    end
endtask



// Read_Operation from data
task Read ; 
    
    input   [CRC_width_tb-1:0]  IN_Data;
    integer j;

    begin
        
        Reset();
        Active_tb = 1'b1;
        
        for (j=0 ; j<8 ; j=j+1)
            begin
                Data_tb = IN_Data[j];
                #(CLK_Period);
            end
        Active_tb = 1'b0;

    end
endtask 



// Write_Operation (CRC_Output Check)
task write;
    
    input   reg     [CRC_width_tb-1:0]    expec_out_tb;     // to check the CRC output from the file
    input   integer                       oper_num;
    reg             [CRC_width_tb-1:0]    Check_reg;      // the result from the design
    integer i;
    
    begin
        
        Active_tb = 1'b0;

        @(posedge Valid_tb)
        for (i=0 ; i < 8 ; i=i+1)
            begin 
                #(CLK_Period);  
                Check_reg[i] = CRC_tb;
            end
        
        if (Check_reg == expec_out_tb)
            begin
                 $display ("** Test Case (%0d) Passed at time: %0t with CRC_Out = %h **", oper_num, $time, Check_reg);
            end

        else 
            begin
                $display ("** Test Case (%0d) Failed at time: %0t **", oper_num, $time);   
            end
           
    end
endtask


endmodule


