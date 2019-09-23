`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/11/2019 01:18:01 PM
// Design Name: 
// Module Name: tx_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rx_tb;
	logic taskFailed, testFailed;
    int numTaskFailed;
    int k;
    logic clk,rst_n,rec_data,err_data;
    logic [7:0] data_rx;
    logic rx,rx_busy;
    
    
    
    rx_vhd dut(clk,rst_n,rx,rec_data,err_data,rx_busy,data_rx);
    
    task resetDUT ();
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        test_signal(rec_data,0,"tx");
        test_signal(err_data,0,"tx");
        rst_n = 1;
    endtask
    
    task test_signal(int acutal,int expected, string name);
        if(acutal!=expected)
            begin
            $display("\[%0tns]ERROR:%s is wrong value", $time, name);
            $display("    Expected value: %2d Acutal value: %2d",expected,acutal);
            testFailed = 1;
            taskFailed = 1;
            end
    endtask
    
    task test_byte (logic [7:0] input_byte, logic parity_error);
        automatic string parity_string = "";
        if ( parity_error )
            parity_string = " with parity error";
        $display("[%0tns]Testing data_rx = %02H", $time, input_byte,parity_string);
        @(negedge clk);
        
        rx = 0;
        #52080ns
        rx = input_byte[0];
        #52080ns
         rx = input_byte[1];
        #52080ns
         rx = input_byte[2];
        #52080ns
         rx = input_byte[3];
        #52080ns
         rx = input_byte[4];
        #52080ns
         rx = input_byte[5];
        #52080ns
         rx = input_byte[6];
        #52080ns
         rx = input_byte[7];
        #52080ns
          rx = ^{!parity_error,input_byte};
        #52080ns
        rx = 1;
        wait(rec_data==1'b1 || err_data==1'b1);
        test_signal(rec_data,!parity_error,"rec_data");
        test_signal(err_data,parity_error,"err_data");
        test_signal(data_rx,input_byte,"data_rx");
    endtask      

	task randomTests (int num);
		numTaskFailed = 0;
		$display("[%0tns]Testing %0d random commands", $time, num);
		for (k=0; k<num; k=k+1) 
		begin
			taskFailed = 0;
			test_byte($urandom,$urandom);
			if(taskFailed==1)
			begin
			numTaskFailed= numTaskFailed+1;
			$display("[%0tns]Test case failed", $time);
			end
		end
		$display("[%0tns]%0d/%0d Passed", $time, num-numTaskFailed, num);
	endtask


    always  
	begin
		clk <=1; #5ns;
		clk <=0; #5ns;
	end

	initial
	begin
	testFailed = 0;
	rx = 1;
	resetDUT();
    #1000ns
    randomTests(50);
	if(testFailed == 1)
			$display("[%0tns]ERROR:Test Failed", $time);
		else
			$display("[%0tns]Test Passed", $time);
	$finish;
	end



endmodule