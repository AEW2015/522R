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

import uart_pkg::*;

module tx_core(
    input logic clk,
    input logic rst_n,
    input logic send_data,
    input logic [7:0] data_tx,
    output logic tx,
    output logic tx_busy
    );

        
    localparam BIT_COUNTER_MAX_VAL = CLK_RATE/BAUD_RATE - 1;
    localparam BIT_COUNTER_BITS = clog2(BIT_COUNTER_MAX_VAL);
    
    typedef enum {IDLE,STRT,DATASEND,PARITY,STP} st_type;  
    
    st_type state,state_next;
    logic [BIT_COUNTER_BITS-1:0] bit_timer;
    logic [BIT_COUNTER_BITS-1:0] bit_timer_next;
    logic [7:0] data;
    logic [7:0] data_next;
    logic [2:0] dtime,dtime_next;
    logic pulse;
    logic tx_logic;
    logic tx_logic_next;
    
    logic parity_logic;
    logic parity_logic_next;
    
    logic shift,load,stop,start,clrTimer,parity_bit;
    logic shift_out;
    
   always_ff @ (posedge clk, negedge rst_n)
    begin
        if (rst_n==1'b0) 
        begin
            state <= IDLE;
            data <= 0;
            dtime <= 0;
            bit_timer <= 0;
            tx_logic   <= 1'b1;
            parity_logic   <= 1'b0;
        end
        else if (clk==1'b1) 
        begin
            state <=state_next;
            data <= data_next;
            dtime <= dtime_next;
            bit_timer <= bit_timer_next;
            tx_logic <= tx_logic_next;
            parity_logic <= parity_logic_next;
        end
    end 
    
    
    always_comb
    begin
        shift = 0;
        load = 0;
        stop = 0;
        parity_bit = 0;
        start = 0;
        clrTimer = 0;
        tx_busy = 1'b1;
        parity_logic_next = parity_logic;
        dtime_next = dtime;
        state_next = state;
        unique case (state)
            IDLE: begin            
                tx_busy = 0;
                stop = 1'b1;
                clrTimer = 1'b1;
                if ( send_data == 1'b1)
                begin
                    load = 1'b1;
                    state_next = STRT;
                    parity_logic_next = 1'b1;
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
                    parity_logic_next = parity_logic ^ data[0];
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
assign tx_logic_next = (stop==1'b1) ? 1'b1 : (start==1'b1) ? 1'b0 : (parity_bit == 1'b1) ? parity_logic : shift_out;

assign tx = tx_logic;

endmodule
