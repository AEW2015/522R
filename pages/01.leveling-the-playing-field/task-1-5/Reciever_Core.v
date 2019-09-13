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
