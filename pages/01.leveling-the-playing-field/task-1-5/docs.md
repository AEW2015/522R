---
title: 'Task 1-5'
taxonomy:
    category:
        - docs
visible: true
---

Here is my uart for tasks 1-5
This uart has configurable clock rate and baud rate.
It uses odd parity.
The reciever core will report any errors in the parity of recieved bytes.

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2019 10:44:49 AM
// Design Name: 
// Module Name: Reciever_Core
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



module Reciever_Core(

    input  wire clk,
    input  wire rst_n,
    input  wire rx,
    output reg rec_data,
    output reg err_data,
    output reg rx_busy,
    output wire[7:0] data_rx
    );
    
    function integer clog2;
    input integer value;
    begin
    value = value-1;
    for (clog2=0; value>0; clog2=clog2+1)
    value = value>>1;
    end
    endfunction
    
    parameter CLK_RATE   = 100_000_000;
    parameter BAUD_RATE  = 19200;
    
    localparam BIT_COUNTER_MAX_VAL = CLK_RATE/BAUD_RATE/16 - 1;
    localparam BIT_COUNTER_BITS = clog2(BIT_COUNTER_MAX_VAL);
    
    parameter POWERUP  = 3'b000;    
    parameter IDLE     = 3'b001;    
    parameter STRT     = 3'b010;    
    parameter DATAREAD = 3'b011;    
    parameter PARITY   = 3'b100;   
    parameter STP      = 3'b101;
    
    reg [2:0] state,state_next;
    reg [BIT_COUNTER_BITS-1:0] bit_timer;
    wire [BIT_COUNTER_BITS-1:0] bit_timer_next;
    reg [7:0] data,data_next;
    reg [3:0] stime,stime_next;
    reg [2:0] dtime,dtime_next;
        
    reg parity_reg;
    reg parity_reg_next;
    wire pulse;
    
    always @ (posedge clk, negedge rst_n)
    begin
        if (rst_n==1'b0) 
        begin
            state <= POWERUP;
            data <= 0;
            stime <= 0;
            dtime <= 0;
            bit_timer <= 0;
            parity_reg <= 0;
        end
        else if (clk==1'b1) 
        begin
            state <=state_next;
            data <= data_next;
            stime <= stime_next;
            dtime <= dtime_next;
            bit_timer <= bit_timer_next;
            parity_reg <= parity_reg_next;
        end
    end
    
    always @ (state,pulse,stime,dtime,data,rx,parity_reg)
    begin
        rx_busy = 1'b1;
        rec_data = 1'b0;
        err_data = 1'b0;
        state_next = state;
        stime_next = stime;
        dtime_next = dtime;
        data_next = data;
        parity_reg_next = parity_reg;
        case(state)
            POWERUP:
                if (rx==1'b1)
                    state_next = IDLE;
            IDLE: begin
                rx_busy = 0;
                if( rx==1'b0)
                    state_next = STRT;  
            end
            STRT: begin
                if (pulse == 1'b1)
                    if (stime == 4'b0111)
                    begin
                        stime_next = 0;
                        dtime_next = 0;
                        parity_reg_next = 1'b1;
                        state_next = DATAREAD;
                    end
                    else
                        stime_next = stime + 1;
            end
            DATAREAD : begin
                if (pulse == 1'b1)
                    if (stime == 4'b1111)
                    begin
                        stime_next = 0;
                        data_next = {rx,data[7:1]};
                        parity_reg_next = parity_reg ^ rx;
                        if (dtime == 3'b111)
                        begin
                            dtime_next = 0;
                            state_next = PARITY;
                        end
                        else
                            dtime_next = dtime + 1;
                    end
                    else
                        stime_next = stime + 1;
            end
            PARITY: begin
               if (pulse == 1'b1)
                 if (stime == 4'b1111)
                 begin
                     stime_next = 0;
                     parity_reg_next = parity_reg ^ rx;
                     state_next = STP;
                   
                 end
                 else
                     stime_next = stime + 1;
            end
            STP: begin
               if (pulse == 1'b1)
                 if (stime == 4'b1111)
                 begin
                     stime_next = 0;
                     if (rx == 1'b1) 
                     begin
                        rec_data = !parity_reg;
                        err_data = parity_reg;
                        state_next = IDLE;
                     end
                     else
                     begin
                        err_data = 1'b1;
                        state_next = IDLE;
                     end
                 end
                 else
                     stime_next = stime + 1;
            end
            default: state_next = POWERUP;
    
        endcase
    end
    
 assign bit_timer_next = (bit_timer == BIT_COUNTER_MAX_VAL) ? 0 : (bit_timer+1);
 assign pulse = (bit_timer == BIT_COUNTER_MAX_VAL) ? 1'b1 : 0;
 assign data_rx = data;
endmodule
```

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2019 12:13:19 PM
// Design Name: 
// Module Name: transmitter_core
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


module transmitter_core(
    input clk,
    input rst_n,
    input send_data,
    input [7:0] data_tx,
    output tx,
    output reg tx_busy
    );
        function integer clog2;
    input integer value;
    begin
    value = value-1;
    for (clog2=0; value>0; clog2=clog2+1)
    value = value>>1;
    end
    endfunction
    
    parameter CLK_RATE   = 100_000_000;
    parameter BAUD_RATE  = 19200;
    
    localparam BIT_COUNTER_MAX_VAL = CLK_RATE/BAUD_RATE - 1;
    localparam BIT_COUNTER_BITS = clog2(BIT_COUNTER_MAX_VAL);
    
    parameter IDLE     = 3'b000;    
    parameter STRT     = 3'b001;    
    parameter DATASEND = 3'b010;    
    parameter PARITY   = 3'b011;    
    parameter STP      = 3'b100;
    
    reg [2:0] state,state_next;
    reg [BIT_COUNTER_BITS-1:0] bit_timer;
    wire [BIT_COUNTER_BITS-1:0] bit_timer_next;
    reg [7:0] data;
    wire [7:0] data_next;
    reg [2:0] dtime,dtime_next;
    wire pulse;
    reg tx_reg;
    wire tx_reg_next;
    
    reg parity_reg;
    reg parity_reg_next;
    
    reg shift,load,stop,start,clrTimer,parity_bit;
    wire shift_out;
    
   always @ (posedge clk, negedge rst_n)
    begin
        if (rst_n==1'b0) 
        begin
            state <= IDLE;
            data <= 0;
            dtime <= 0;
            bit_timer <= 0;
            tx_reg   <= 1'b1;
            parity_reg   <= 1'b0;
        end
        else if (clk==1'b1) 
        begin
            state <=state_next;
            data <= data_next;
            dtime <= dtime_next;
            bit_timer <= bit_timer_next;
            tx_reg <= tx_reg_next;
            parity_reg <= parity_reg_next;
        end
    end 
    
    
    always @ (send_data,state,pulse,dtime,parity_reg,data)
    begin
        shift = 0;
        load = 0;
        stop = 0;
        parity_bit = 0;
        start = 0;
        clrTimer = 0;
        tx_busy = 1'b1;
        parity_reg_next = parity_reg;
        dtime_next = dtime;
        state_next = state;
        case (state)
            IDLE: begin            
                tx_busy = 0;
                stop = 1'b1;
                clrTimer = 1'b1;
                if ( send_data == 1'b1)
                begin
                    load = 1'b1;
                    state_next = STRT;
                    parity_reg_next = 1'b1;
                end
            end
            STRT : begin
                start = 1;
                if (pulse == 1'b1)
                    state_next = DATASEND;
            end
            DATASEND : begin
                if (pulse == 1'b1)
                begin
                    shift = 1'b1;
                    parity_reg_next = parity_reg ^ data[0];
                    if (dtime == 3'b111)
                    begin
                        dtime_next = 0;
                        state_next = PARITY;
                    end
                    else
                        dtime_next = dtime + 1;
                end
            end            
            PARITY: begin
                    parity_bit = 1'b1;
                    if (pulse == 1'b1)
                        state_next = STP;
            end
            STP: begin
                stop = 1'b1;
                if (pulse == 1'b1)
                    state_next = IDLE;
            end
        endcase
    
    end
    
    
assign bit_timer_next = (clrTimer==1'b1) ? 0 : (bit_timer == BIT_COUNTER_MAX_VAL) ? 0 : (bit_timer + 1);
assign pulse = (bit_timer == BIT_COUNTER_MAX_VAL) ? 1'b1 : 0;
assign data_next = (load == 1'b1) ? data_tx : (shift == 1'b1) ? {1'b0,data[7:1]} : data;
assign shift_out = data[0];
assign tx_reg_next = (stop==1'b1) ? 1'b1 : (start==1'b1) ? 1'b0 : (parity_bit == 1'b1) ? parity_reg : shift_out;

assign tx = tx_reg;

endmodule
```



![block diagram](ublaze_uart.JPG)


![uart video](user://media/uarty.mp4?resize=300,600&autoplay=1))