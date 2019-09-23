---
title: 'Task 6-7'
taxonomy:
    category:
        - docs
visible: true
---

Here is my VHDL uart.

This uart operates as the same as the other uarts.

100Mhz clk and 19200 buad.


<details><summary>rx.vhd</summary><p><pre><code class="vhdl">library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity rx_vhd is
    Generic (
        CLK_RATE: natural :=100_000_000;
        BAUD_RATE: natural :=19200);
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           rx : in STD_LOGIC;
           rec_data : out STD_LOGIC;
           err_data : out STD_LOGIC;
           rx_busy : out STD_LOGIC;
           data_rx : out STD_LOGIC_VECTOR (7 downto 0));
end rx_vhd;

architecture Behavioral of rx_vhd is
-----------------------------------------------
function log2c (n: integer) return integer is 
variable m, p: integer; 
begin 
m := 0; 
p := 1; 
while p &lt; n loop 
m := m + 1; 
p := p * 2; 
end loop; 
return m; 
end log2c;
---------------------------------------------------
constant BIT_COUNTER_MAX_VAL : Natural := CLK_RATE/BAUD_RATE/16 - 1;
constant BIT_COUNTER_BITS : Natural := log2c(BIT_COUNTER_MAX_VAL);
type fsm is (POWERUP,IDLE,STRT,DATAREAD,PARITY,STP);
signal state,state_next: fsm;
signal bit_timer,bit_timer_next : unsigned(BIT_COUNTER_BITS-1 downto 0);
signal data, data_next : std_logic_vector(7 downto 0);
signal stime, stime_next : unsigned(3 downto 0);
signal dtime, dtime_next : unsigned(2 downto 0);
signal pulse: std_logic;
signal rx_reg : std_logic;
signal parity_logic,parity_logic_next : std_logic;

begin

process(rst_n,clk)
begin
	if(rst_n='0') then
		state&lt;=POWERUP;
		data&lt;=(others=&gt;'0');
		stime&lt;=(others=&gt;'0');
		dtime&lt;=(others=&gt;'0');
		bit_timer&lt;=(others=&gt;'0');
		rx_reg &lt;= '0';
		parity_logic &lt;= '0';
	elsif (clk'event and clk ='1') then
		state&lt;=state_next;
		data&lt;=data_next;
		stime&lt;=stime_next;
		dtime&lt;=dtime_next;
		bit_timer&lt;=bit_timer_next;
		rx_reg &lt;= rx;
		parity_logic &lt;= parity_logic_next;
	end if;
end process;

process(state,pulse,stime,dtime,data,rx_reg,parity_logic_next)
begin
	rx_busy&lt;='1';
	rec_data&lt;='0';
	err_data&lt;='0';
	stime_next&lt;=stime;
	dtime_next&lt;=dtime;
	data_next&lt;=data;
    parity_logic_next &lt;= parity_logic;
    state_next &lt;= state;
	case state is 
		when POWERUP=&gt;
			if(rx_reg = '1') then
				state_next&lt;=IDLE;
			else
				state_next&lt;=POWERUP;
			end if;
		when IDLE=&gt;
		rx_busy&lt;='0';
			if(rx_reg = '1') then
				state_next&lt;=IDLE;
			else
				state_next&lt;=STRT;
			end if;
		when STRT=&gt;
			if(pulse = '1') then
				if(stime = "0111") then
					stime_next&lt;=(others=&gt;'0');
					dtime_next&lt;=(others=&gt;'0');
                    parity_logic_next &lt;= '1';
					state_next&lt;=DATAREAD;
				else
					stime_next&lt;=stime+1;
				end if;
			end if;
		when DATAREAD=&gt;
			if(pulse = '1') then
				if(stime = "1111") then
					stime_next&lt;=(others=&gt;'0');
					data_next&lt;=rx_reg&amp;data(7 downto 1);
                    parity_logic_next &lt;= parity_logic xor rx_reg;
					if(dtime="111") then
						dtime_next&lt;=(others=&gt;'0');
						state_next&lt;=PARITY;
					else
						dtime_next&lt;=dtime+1;
					end if;
				else
					stime_next&lt;=stime+1;
				end if;
			end if; 
	    when PARITY =&gt;
	       if(pulse = '1') then
                if(stime = "1111") then
                        stime_next&lt;=(others=&gt;'0');
                        parity_logic_next&lt;= parity_logic xor rx_reg;
                        state_next&lt;=STP;
                else
                    stime_next&lt;=stime+1;
                end if;
            end if; 
		when STP=&gt;
			if(pulse = '1') then
				if(stime = "1111") then
				    stime_next&lt;=(others=&gt;'0');
					if(rx_reg='1') then
						stime_next&lt;=(others=&gt;'0');
						rec_data&lt;= not parity_logic;
						err_data&lt;= parity_logic;
						state_next&lt;=IDLE;
				    else
				        err_data&lt;= '1';
				        state_next &lt;= IDLE;
					end if;
				else
					stime_next&lt;=stime+1;
				end if;
			end if; 
		--add data strobe
	end case;
end process;
--other logic
bit_timer_next&lt;= (others=&gt;'0') when (bit_timer = BIT_COUNTER_MAX_VAL) else
						bit_timer+1;
pulse &lt;= '1' when bit_timer = BIT_COUNTER_MAX_VAL else
				'0';
--output
data_rx&lt;= data;		



end Behavioral;
</code></pre></p></details>


<details><summary>tx.vhd</summary><p><pre><code class="vhdl">library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity tx_vhd is
    Generic (
        CLK_RATE: natural :=100_000_000;
        BAUD_RATE: natural :=19200);
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           send_data : in STD_LOGIC;
           data_tx : in STD_LOGIC_VECTOR (7 downto 0);
           tx : out STD_LOGIC;
           tx_busy : out STD_LOGIC);
end tx_vhd;

architecture Behavioral of tx_vhd is
-----------------------------------------------
function log2c (n: integer) return integer is 
variable m, p: integer; 
begin 
m := 0; 
p := 1; 
while p &lt; n loop 
m := m + 1; 
p := p * 2; 
end loop; 
return m; 
end log2c;
---------------------------------------------------

type fsm is (IDLE,STRT,B0,B1,B2,B3,B4,B5,B6,B7,PARITY,STP);
signal state,state_next: fsm;
constant BIT_COUNTER_MAX_VAL : Natural := CLK_RATE / BAUD_RATE - 1;
constant BIT_COUNTER_BITS : Natural := log2c(BIT_COUNTER_MAX_VAL);
signal bit_timer,bit_timer_next : unsigned(BIT_COUNTER_BITS-1 downto 0);
signal reg, reg_next : std_logic_vector(7 downto 0);
signal tx_reg: std_logic:='1';
signal tx_reg_next: std_logic;
signal tx_bit,shift,load,stop,start,shift_out,clrTimer: std_logic;
signal parity_logic, parity_logic_next: std_logic;
signal parity_bit : std_logic;
begin
process(rst_n,clk)
begin
    if(rst_n ='0') then
        state &lt;= IDLE;
        bit_timer&lt;= (others=&gt;'0');
        reg&lt;=(others=&gt;'0');
        tx_reg&lt;='1';
        parity_logic&lt;='0';
    elsif (clk'event and clk = '1') then
        state&lt;=state_next;
        bit_timer&lt;=bit_timer_next;
        reg&lt;=reg_next;
        tx_reg&lt;=tx_reg_next;
        parity_logic&lt;=parity_logic_next;
    end if;
end process;

------------------------
--FSM NEXT STATE LOGIC--
------------------------
process(send_data,state,tx_bit,parity_logic)
begin
    shift &lt;= '0';
    load &lt;= '0';
    stop &lt;= '0';
    start &lt;= '0';
    parity_bit &lt;= '0';
    clrTimer &lt;= '0';
    tx_busy&lt;= '1';
    parity_logic_next &lt;= parity_logic;
    case state is
        when IDLE =&gt;
            tx_busy&lt;= '0';
            stop&lt;= '1';
            clrTimer&lt;='1';
            if (send_data = '1') then
                state_next &lt;= STRT;
                load &lt;= '1';
                parity_logic_next &lt;= '1';
            else
                state_next &lt;= IDLE;
            end if;
        when STRT =&gt;
            start &lt;= '1';
            if (tx_bit = '1') then
                state_next &lt;= B0;
            else
                state_next &lt;= STRT;
            end if;
        when B0 =&gt;
            if (tx_bit = '1') then
                state_next &lt;= B1;
                shift &lt;= '1';
                parity_logic_next &lt;= parity_logic xor reg(0);
            else
                state_next &lt;= B0;
            end if;
        when B1 =&gt;
            if (tx_bit = '1') then
                state_next &lt;= B2;
                shift &lt;= '1';
                parity_logic_next &lt;= parity_logic xor reg(0);
            else
                state_next &lt;= B1;
            end if;
        when B2 =&gt;
            if (tx_bit = '1') then
                state_next &lt;= B3;
                shift &lt;= '1';
                parity_logic_next &lt;= parity_logic xor reg(0);
            else
                state_next &lt;= B2;
            end if;
        when B3 =&gt;
            if (tx_bit = '1') then
                state_next &lt;= B4;
                shift &lt;= '1';
                parity_logic_next &lt;= parity_logic xor reg(0);
            else
                state_next &lt;= B3;
            end if;
        when B4 =&gt;
            if (tx_bit = '1') then
                state_next &lt;= B5;
                shift &lt;= '1';
                parity_logic_next &lt;= parity_logic xor reg(0);
            else
                state_next &lt;= B4;
            end if;
        when B5 =&gt;
            if (tx_bit = '1') then
                state_next &lt;= B6;
                shift &lt;= '1';
                parity_logic_next &lt;= parity_logic xor reg(0);
            else
                state_next &lt;= B5;
            end if;
        when B6 =&gt;
            if (tx_bit = '1') then
                state_next &lt;= B7;
                shift &lt;= '1';
                parity_logic_next &lt;= parity_logic xor reg(0);
            else
                state_next &lt;= B6;
            end if;
        when B7 =&gt;
            if (tx_bit = '1') then
                state_next &lt;= PARITY;
                shift &lt;= '1';
                parity_logic_next &lt;= parity_logic xor reg(0);
            else
                state_next &lt;= B7;
            end if;	
        when PARITY =&gt;
            parity_bit &lt;= '1';
            if (tx_bit = '1') then
                state_next &lt;= STP;
            else
                state_next &lt;= PARITY;
            end if;	
        when STP =&gt;
            stop&lt;= '1';
            if (tx_bit = '1') then
                state_next &lt;= IDLE;
            else
                state_next &lt;= STP;
            end if;
    end case;
end process;

----------------------------------------
--COUNTER NEXT STATE LOGIC--------------
----------------------------------------
bit_timer_next&lt;= (others=&gt;'0') when (clrTimer='1' or bit_timer = BIT_COUNTER_MAX_VAL) else
						bit_timer+1;
tx_bit &lt;= '1' when bit_timer = BIT_COUNTER_MAX_VAL else
				'0';
						
reg_next &lt;= Data_TX when load = '1' else
				'0' &amp; reg(7 downto 1) when shift='1' else
				reg;
shift_out &lt;= reg(0);
				
tx_reg_next&lt;= '1' when stop = '1' else 
			'0' when start = '1' else
			parity_logic when parity_bit = '1' else
			shift_out;
				

----------------------
--outputs
TX&lt;= tx_reg;

end Behavioral;
</code></pre></p></details>


Reciever Test Bench

This test bench tests 50 random cases with some including parity errors.

The design passed all the tests given.

<details><summary>rx_tb.v</summary><p><pre><code class="verilog">
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
        test_signal(rec_data,!parity_error,"tx");
        test_signal(err_data,parity_error,"tx");
        test_signal(data_rx,input_byte,"tx");
    endtask      

	task randomTests (int num);
		numTaskFailed = 0;
		$display("[%0tns]Testing %0d random commands", $time, num);
		for (k=0; k&lt;num; k=k+1) 
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
		clk &lt;=1; #5ns;
		clk &lt;=0; #5ns;
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
</code></pre></p></details>

![RX Waveform](rx_waveform.JPG)

<details><summary>Output:</summary><p><pre><code class="bash">
[1015000ns]Testing 50 random commands
[1015000ns]Testing data_rx = 24 with parity error
[546000000ns]Testing data_rx = 24 with parity error
[1092000000ns]Testing data_rx = 09 with parity error
[1638000000ns]Testing data_rx = 0d with parity error
[2184000000ns]Testing data_rx = 65
[2730000000ns]Testing data_rx = 01 with parity error
[3276000000ns]Testing data_rx = 76 with parity error
[3822000000ns]Testing data_rx = ed
[4368000000ns]Testing data_rx = f9
[4914000000ns]Testing data_rx = c5
[5460000000ns]Testing data_rx = e5 with parity error
[6006000000ns]Testing data_rx = 12 with parity error
[6552000000ns]Testing data_rx = f2
[7098000000ns]Testing data_rx = e8 with parity error
[7644000000ns]Testing data_rx = 5c with parity error
[8190000000ns]Testing data_rx = 2d with parity error
[8736000000ns]Testing data_rx = 63
[9282000000ns]Testing data_rx = 80
[9828000000ns]Testing data_rx = aa with parity error
[10374000000ns]Testing data_rx = 96 with parity error
[10920000000ns]Testing data_rx = 0d with parity error
[11466000000ns]Testing data_rx = 6b with parity error
[12012000000ns]Testing data_rx = 02
[12558000000ns]Testing data_rx = 1d with parity error
[13104000000ns]Testing data_rx = 23
[13650000000ns]Testing data_rx = ca
[14196000000ns]Testing data_rx = f2
[14742000000ns]Testing data_rx = 41
[15288000000ns]Testing data_rx = 78 with parity error
[15834000000ns]Testing data_rx = eb
[16380000000ns]Testing data_rx = c6
[16926000000ns]Testing data_rx = bc
[17472000000ns]Testing data_rx = 0b with parity error
[18018000000ns]Testing data_rx = 85 with parity error
[18564000000ns]Testing data_rx = 3b
[19110000000ns]Testing data_rx = 7e with parity error
[19656000000ns]Testing data_rx = f1 with parity error
[20202000000ns]Testing data_rx = 62
[20748000000ns]Testing data_rx = 9f with parity error
[21294000000ns]Testing data_rx = f8 with parity error
[21840000000ns]Testing data_rx = 9f
[22386000000ns]Testing data_rx = 5b with parity error
[22932000000ns]Testing data_rx = 49
[23478000000ns]Testing data_rx = d7 with parity error
[24024000000ns]Testing data_rx = 96
[24570000000ns]Testing data_rx = c2
[25116000000ns]Testing data_rx = 77 with parity error
[25662000000ns]Testing data_rx = 12
[26208000000ns]Testing data_rx = 6d with parity error
[26754000000ns]Testing data_rx = 1f with parity error
[27300000000ns]50/50 Passed
[27300000000ns]Test Passed
$finish called at time : 27300 us : File "C:/xup/R522/arty_ublaze/arty_ublaze.srcs/sim_1/new/rx_tb.sv" Line 122
</code></pre></p></details>

Transmitter Test Bench

This Test bench also tests 50 randoms cases and verifys the design works.

The design passed all the tests given.

<details><summary>tx_tb.sv</summary><p><pre><code class="verilog">
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
        test_signal(tx,^{1'b1,input_byte},"tx");
        #52080ns
        test_signal(tx,1,"tx");
        wait(tx_busy==1'b0);
    endtask      

	task randomTests (int num);
		numTaskFailed = 0;
		$display("[%0tns]Testing %0d random commands", $time, num);
		for (k=0; k&lt;num; k=k+1) 
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
		clk &lt;=1; #5ns;
		clk &lt;=0; #5ns;
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
</code></pre></p></details>

![TX Waveform](tx_waveform.JPG)

<details><summary>Output:</summary><p><pre><code class="bash">
[1015000ns]Testing 50 random commands
[1015000ns]Testing data_tx = 24
[573900000ns]Testing data_tx = 24
[1146790000ns]Testing data_tx = 81
[1719680000ns]Testing data_tx = 09
[2292570000ns]Testing data_tx = 63
[2865460000ns]Testing data_tx = 0d
[3438350000ns]Testing data_tx = 8d
[4011240000ns]Testing data_tx = 65
[4584130000ns]Testing data_tx = 12
[5157020000ns]Testing data_tx = 01
[5729910000ns]Testing data_tx = 0d
[6302800000ns]Testing data_tx = 76
[6875690000ns]Testing data_tx = 3d
[7448580000ns]Testing data_tx = ed
[8021470000ns]Testing data_tx = 8c
[8594360000ns]Testing data_tx = f9
[9167250000ns]Testing data_tx = c6
[9740140000ns]Testing data_tx = c5
[10313030000ns]Testing data_tx = aa
[10885920000ns]Testing data_tx = e5
[11458810000ns]Testing data_tx = 77
[12031700000ns]Testing data_tx = 12
[12604590000ns]Testing data_tx = 8f
[13177480000ns]Testing data_tx = f2
[13750370000ns]Testing data_tx = ce
[14323260000ns]Testing data_tx = e8
[14896150000ns]Testing data_tx = c5
[15469040000ns]Testing data_tx = 5c
[16041930000ns]Testing data_tx = bd
[16614820000ns]Testing data_tx = 2d
[17187710000ns]Testing data_tx = 65
[17760600000ns]Testing data_tx = 63
[18333490000ns]Testing data_tx = 0a
[18906380000ns]Testing data_tx = 80
[19479270000ns]Testing data_tx = 20
[20052160000ns]Testing data_tx = aa
[20625050000ns]Testing data_tx = 9d
[21197940000ns]Testing data_tx = 96
[21770830000ns]Testing data_tx = 13
[22343720000ns]Testing data_tx = 0d
[22916610000ns]Testing data_tx = 53
[23489500000ns]Testing data_tx = 6b
[24062390000ns]Testing data_tx = d5
[24635280000ns]Testing data_tx = 02
[25208170000ns]Testing data_tx = ae
[25781060000ns]Testing data_tx = 1d
[26353950000ns]Testing data_tx = cf
[26926840000ns]Testing data_tx = 23
[27499730000ns]Testing data_tx = 0a
[28072620000ns]Testing data_tx = ca
[28645510000ns]50/50 Passed
[28645510000ns]Test Passed
$finish called at time : 28645510 ns : File "C:/xup/R522/arty_ublaze/arty_ublaze.srcs/sim_1/new/tx_tb.sv" Line 121
</code></pre></p></details>

This is the verilog file that connects the uart to the axi lite bus.

Fifos were included to buffer multiple data bytes.

<details><summary>myUart_v1_0_S00_AXI.v</summary><p><pre><code class="verilog">
`timescale 1 ns / 1 ps

	module myUart_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
        (* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 m_uart RxD" *)
        input m_rxd, // Serial Input (required)
        (* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 m_uart TxD" *)
        output m_txd, // Serial Output (required)
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
	reg	 aw_en;
	reg [31:0] error_counter; 
	wire [31:0] error_counter_next; 

	
	wire rec_data,err_data;
    wire [7:0] data_rx;
    wire rx_busy;
	wire send_data;
    wire [7:0] data_tx;
    wire tx_busy;
    
    
    wire tx_fifo_empty,tx_fifo_full;
    wire tx_fifo_rd,tx_fifo_wr;
    
    
    wire rx_fifo_empty,rx_fifo_full;
    wire rx_fifo_rd,rx_fifo_wr;
    
    wire [7:0] data_rx_out;
	
	
	
	// I/O Connections assignments
	
	

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready &lt;= 1'b0;
	      aw_en &lt;= 1'b1;
	    end 
	  else
	    begin    
	      if (~axi_awready &amp;&amp; S_AXI_AWVALID &amp;&amp; S_AXI_WVALID &amp;&amp; aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready &lt;= 1'b1;
	          aw_en &lt;= 1'b0;
	        end
	        else if (S_AXI_BREADY &amp;&amp; axi_bvalid)
	            begin
	              aw_en &lt;= 1'b1;
	              axi_awready &lt;= 1'b0;
	            end
	      else           
	        begin
	          axi_awready &lt;= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr &lt;= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready &amp;&amp; S_AXI_AWVALID &amp;&amp; S_AXI_WVALID &amp;&amp; aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr &lt;= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready &lt;= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready &amp;&amp; S_AXI_WVALID &amp;&amp; S_AXI_AWVALID &amp;&amp; aw_en )
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready &lt;= 1'b1;
	        end
	      else
	        begin
	          axi_wready &lt;= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready &amp;&amp; S_AXI_WVALID &amp;&amp; axi_awready &amp;&amp; S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 &lt;= 0;
	      slv_reg1 &lt;= 0;
	      slv_reg2 &lt;= 0;
	      slv_reg3 &lt;= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          2'h0:
	            for ( byte_index = 0; byte_index &lt;= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] &lt;= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h1:
	            for ( byte_index = 0; byte_index &lt;= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] &lt;= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h2:
	            for ( byte_index = 0; byte_index &lt;= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] &lt;= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h3:
	            for ( byte_index = 0; byte_index &lt;= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                slv_reg3[(byte_index*8) +: 8] &lt;= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 &lt;= slv_reg0;
	                      slv_reg1 &lt;= slv_reg1;
	                      slv_reg2 &lt;= slv_reg2;
	                      slv_reg3 &lt;= slv_reg3;
	                    end
	        endcase
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  &lt;= 0;
	      axi_bresp   &lt;= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready &amp;&amp; S_AXI_AWVALID &amp;&amp; ~axi_bvalid &amp;&amp; axi_wready &amp;&amp; S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid &lt;= 1'b1;
	          axi_bresp  &lt;= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY &amp;&amp; axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid &lt;= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready &lt;= 1'b0;
	      axi_araddr  &lt;= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready &amp;&amp; S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready &lt;= 1'b1;
	          // Read address latching
	          axi_araddr  &lt;= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready &lt;= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid &lt;= 0;
	      axi_rresp  &lt;= 0;
	    end 
	  else
	    begin    
	      if (axi_arready &amp;&amp; S_AXI_ARVALID &amp;&amp; ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid &lt;= 1'b1;
	          axi_rresp  &lt;= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid &amp;&amp; S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid &lt;= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready &amp; S_AXI_ARVALID &amp; ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        2'h0   : reg_data_out = {31'd0,!tx_fifo_full};
	        2'h1   : reg_data_out = slv_reg1;
	        2'h2   : reg_data_out = {23'd0,!rx_fifo_empty,data_rx_out};
	        2'h3   : reg_data_out = error_counter;
	        default : reg_data_out = 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  &lt;= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata &lt;= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here
    rx_vhd rx_inst(clk,rst_n,rx,rec_data,err_data,rx_busy,data_rx);
    tx_vhd tx_inst(clk,rst_n,send_data,data_tx,tx,tx_busy);
	
	assign send_data = ! tx_fifo_empty &amp;&amp; ! tx_busy;
	assign tx_fifo_rd = ! tx_fifo_empty &amp;&amp; ! tx_busy;
	assign tx_fifo_wr = (slv_reg_wren &amp;&amp; axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h1) ? 1 : 0;
	
	fifo_generator_0 tx_fifo (
      .clk(S_AXI_ACLK),      // input wire clk
      .din(S_AXI_WDATA[7:0]),      // input wire [7 : 0] din
      .wr_en(tx_fifo_wr),  // input wire wr_en
      .rd_en(tx_fifo_rd),  // input wire rd_en
      .dout(data_tx),    // output wire [7 : 0] dout
      .full(tx_fifo_full),    // output wire full
      .empty(tx_fifo_empty)  // output wire empty
    );
    
    assign rx_fifo_rd = (slv_reg_rden &amp;&amp; axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h2) ? 1 : 0;
    
    fifo_generator_0 rx_fifo (
      .clk(S_AXI_ACLK),      // input wire clk
      .din(data_rx),      // input wire [7 : 0] din
      .wr_en(rec_data),  // input wire wr_en
      .rd_en(rx_fifo_rd),  // input wire rd_en
      .dout(data_rx_out),    // output wire [7 : 0] dout
      .full(rx_fifo_full),    // output wire full
      .empty(rx_fifo_empty)  // output wire empty
    );


	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
        error_counter &lt;= 0;
	  else
       error_counter &lt;= error_counter_next;
	end     
	
	assign error_counter_next = (err_data==1'b1) ? error_counter+1 : error_counter;
	// User logic ends

	endmodule
</code></pre></p></details>

This is the block diagram of connecting myUart to the Microblaze.

![block diagram](ublaze_uart.JPG)

These are the addresses I assigned to all the perpherials.

![Addresses](addresses.JPG)

The microblaze code allows for two modes.
 * Mode one (BLUE LED) echos all characters recieved. The leds keep count of characters recieved.
 * Mode two (GREEN LED) transmits all possible character sequentially

<details><summary>code.c</summary><p><pre><code class="c">
#include &lt;stdio.h&gt;
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"


int main()
{
    init_platform();

    u32 input;
    u32 uart_counter = 0;
    u32 dip_swi = 0;
    u32 send_byte = 0x00;
    Xil_Out32(0x11100004,0x00);

    Xil_Out32(0x11100000,0x1);


    Xil_Out32(0x40000004,0x00);



    while(1){
    	Xil_Out32(0x40000000,uart_counter);
    	dip_swi = Xil_In32(0x11100008);



    	input = Xil_In32(0x44A00008);



    	if((0x1&amp;dip_swi)==0){
    		Xil_Out32(0x11100000,0x1);
    	if(0x100&amp;input){
    		uart_counter++;
    		Xil_Out32(0x44a00004,0x0A);;
    		Xil_Out32(0x44a00004,0x7E);
    		Xil_Out32(0x44a00004,input);
    	}

    	}
    	else
    	{
    		Xil_Out32(0x11100000,0x2);
    		Xil_Out32(0x44a00004,send_byte++);
    		for( int i = 0; i&lt;0xFFFFF;i++);
    	}




    }

    cleanup_platform();
    return 0;
}
</code></pre></p></details>


Here is the video of its operation.

![uart video](user://media/uart_001.mp4?resize=300,600))

All the files and (future) build scripts will be included here:
[Github page](https://github.com/AEW2015/522R/tree/master/pages/01.leveling-the-playing-field/task-6-7)