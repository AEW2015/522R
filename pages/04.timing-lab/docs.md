---
title: 'Timing Lab'
taxonomy:
    category:
        - docs
visible: true
---

#Timing Lab

##Part 1

###Summary

Create a 16 bit wide counter with the defualt clock and review the timing report.

###Code

<details><summary>counter.v</summary><p> 
<pre><code class="verilog">
`timescale 1ns / 1ps
module hbTest #(parameter OUTPUT_WIDTH = 16, parameter INCVAL_MULTIPLIER = 3)(input clk, input clr, input inc, input [7:0] incVal, input dec, input [7:0] decVal, output reg [OUTPUT_WIDTH - 1:0] q);
    always @(posedge clk)
    begin
        if(clr == 1'b1)
        begin
            q &lt;= 0;
        end
        else if(inc == 1'b1)
        begin
            q &lt;= q + {{8{incVal[7]}}, incVal[7:0]} * INCVAL_MULTIPLIER;
        end
        else if(dec == 1'b1)
        begin
            q &lt;= q - {{8{decVal[7]}}, decVal[7:0]};
        end
        else
        begin
            q &lt;= q;
        end
    end
endmodule
</code></pre></p></details>

###Steps:
Does the synthesized schematic make sense to you?

A rough hand sketch of both the top level design and the inside of the counter block.

![Counter Top](top_counter.png)

![Counter Schematic](schematic_counter.png)

Explain the resulting circuits.

Do you understand why the synthesis tool did what it did and how it implmenets your circuit?

Bring up timing report and find critical path and draw it on the sketch.

![Counter Critical Path](crit_path_counter.png)

###Questions:

Q:What is its slack and what does that mean?

A:Slack is the amount of extra time the Data path has before violating tSetup. A postive slack means you can go faster. A zero slack means you are going the fastest possible.
A Negative Slack mean your design does not meet timing and violates tSetup.

What is the launch edge (beginning) of the path?

When does the clock edge that launches the signal arrive at the launch flip flop?

What is the capture point (end) of the path? When does the clock arrive there? Does this make sense knowing what you know about the path from the input pin to the flip flops?

When is the signal required to be at the endpoint?

If you do the arithmetic, how do the various numbers work out? Do the values above take into account clock skew or not?

What are the various delays making up the critical path? Which ones dominate? Which ones are smaller than you might have anticipated? Any surprises here?

##Part 2

###Summary 

Add a PLL to the design and see the change in timing.

###Questions:

How does adding the PLL change things that you see in the synthesized circuit and in the timing report? Explain. 

Do the actual path delays change or is the time scale simply shifted and by how much? 

Can you make sense of this based on the clock path?

##Part 3

###Summary

Change the counter to be 64 bits wide and rerun

###Questions

Based on what you see, how wide of a counter do you estimate would work at this clock rate? 

Other than having a longer worst case combinational path, does having a much longer counter affect anything else you see in this timing report? Can you explain this?

##Part 4

###Summary
Set an input delay for the LSB of the incVal and an output delay for the MSB of the q. Look at the timing report.

###Questions:

Q:What is an input delay? 

A: This helps the tool understand the time between the edge of the input to the next flipflop.

Q.What is an output delay? 

A: This helps the tool understand the time between the last flipflop to the external output capture device.

With these new assumptions, is your PLL set up correctly or do you see something you should do to it to make the whole board-level design work better? 

For example, would changing the phase of the PLL for your internal circuitry help in any way? 

If you decide something should be done, you need not do it, but simply explain what you would do and why you would do it.

##Part 5

###Summary

Modify the constraints and determine the maximum frequency.

###Questions:

In the end, what is the limiting factor? 

How much of the final critical path is Tclk-Q, Tlogic, Tsetup, Twiring, and Tskew?

##Final Summary

(a) did you do everything requested? 

(b) does your writeup evidence that you have figured out the basics of the timing report, the use of PLL's in this scenario, and the use of clock/input/output constraints?
