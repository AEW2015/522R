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


module tx_tb;
	logic taskFailed, testFailed;
    int numTaskFailed;
    int k;
    logic clk,rst_n,send_data;
    logic [7:0] data_tx;
    logic tx,tx_busy;
    
    
    
    tx_vhd dut(clk,rst_n,send_data,data_tx,tx,tx_busy);
    
    task resetDUT ();
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        test_signal(tx,1,"tx");
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
    
    task test_byte (logic [7:0] input_byte);
        $display("[%0tns]Testing data_tx = %02H", $time, input_byte);
        @(negedge clk);
        test_signal(tx,1,"tx");
        send_data = 1;
        data_tx = input_byte;
        wait(tx_busy==1'b1);
        #25000ns
        //start bit
        test_signal(tx,0,"tx");
        #52080ns
        test_signal(tx,input_byte[0],"tx");
        #52080ns
        test_signal(tx,input_byte[1],"tx");
        #52080ns
        test_signal(tx,input_byte[2],"tx");
        #52080ns
        test_signal(tx,input_byte[3],"tx");
        #52080ns
        test_signal(tx,input_byte[4],"tx");
        #52080ns
        test_signal(tx,input_byte[5],"tx");
        #52080ns
        test_signal(tx,input_byte[6],"tx");
        #52080ns
        test_signal(tx,input_byte[7],"tx");
        #52080ns
        test_signal(tx,^{1'b1,input_byte},"odd_parity");
        #52080ns
        test_signal(tx,1,"tx");
        wait(tx_busy==1'b0);
    endtask      

	task randomTests (int num);
		numTaskFailed = 0;
		$display("[%0tns]Testing %0d random commands", $time, num);
		for (k=0; k<num; k=k+1) 
		begin
			taskFailed = 0;
			test_byte($urandom);
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
	send_data = 0;
	data_tx = 8'h00;
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