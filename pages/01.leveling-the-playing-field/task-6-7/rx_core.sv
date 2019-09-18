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

import uart_pkg::*;


module rx_core(

    input  logic clk,
    input  logic rst_n,
    input  logic rx,
    output logic rec_data,
    output logic err_data,
    output logic rx_busy,
    output logic[7:0] data_rx
    );
    
    
    localparam BIT_COUNTER_MAX_VAL = CLK_RATE/BAUD_RATE/16 - 1;
    localparam BIT_COUNTER_BITS = clog2(BIT_COUNTER_MAX_VAL);
        
    typedef enum {POWERUP,IDLE,STRT,DATAREAD,PARITY,STP} st_type;
    
    
    st_type state,state_next;
    logic [BIT_COUNTER_BITS-1:0] bit_timer;
    logic [BIT_COUNTER_BITS-1:0] bit_timer_next;
    logic [7:0] data,data_next;
    logic [3:0] stime,stime_next;
    logic [2:0] dtime,dtime_next;
        
    logic rx_logic;
    logic parity_logic;
    logic parity_logic_next;
    logic pulse;
    
    always_ff @ (posedge clk, negedge rst_n)
    begin
        if (rst_n==1'b0) 
        begin
            state <= POWERUP;
            data <= 0;
            stime <= 0;
            dtime <= 0;
            bit_timer <= 0;
            parity_logic <= 0;
            rx_logic <= 0;
        end
        else if (clk==1'b1) 
        begin
            state <=state_next;
            data <= data_next;
            stime <= stime_next;
            dtime <= dtime_next;
            bit_timer <= bit_timer_next;
            parity_logic <= parity_logic_next;
            rx_logic <= rx;
        end
    end
    
    always_comb
    begin
        rx_busy = 1'b1;
        rec_data = 1'b0;
        err_data = 1'b0;
        state_next = state;
        stime_next = stime;
        dtime_next = dtime;
        data_next = data;
        parity_logic_next = parity_logic;
        unique case(state)
            POWERUP:
                if (rx_logic==1'b1)
                    state_next = IDLE;
            IDLE: begin
                rx_busy = 0;
                if( rx_logic==1'b0)
                    state_next = STRT;  
            end
            STRT: begin
                if (pulse == 1'b1)
                    if (stime == 4'b0111)
                    begin
                        stime_next = 0;
                        dtime_next = 0;
                        parity_logic_next = 1'b1;
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
                        data_next = {rx_logic,data[7:1]};
                        parity_logic_next = parity_logic ^ rx_logic;
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
                     parity_logic_next = parity_logic ^ rx_logic;
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
                     if (rx_logic == 1'b1) 
                     begin
                        rec_data = !parity_logic;
                        err_data = parity_logic;
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
