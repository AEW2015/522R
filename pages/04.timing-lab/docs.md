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

insert counter code here

</code></pre></p></details>

###Steps:
Does the synthesized schematic make sense to you?

A rough hand sketch of both the top level design and the inside of the counter block.

Explain the resulting circuits.

Do you understand why the synthesis tool did what it did and how it implmenets your circuit?

Bring up timing report and find critical path and draw it on the sketch.

###Questions:

Q:What is its slack and what does that mean?

A:The slack is 6.428. Slack is the amount of extra time the Data path has before violating tSetup. A postive slack means you can go faster. A zero slack means you are going the fastest possible.
A Negative Slack mean your design does not meet timing and violates tSetup. So we could reduce the clock period by 6.428ns and still meet timing.

What is the launch edge (beginning) of the path? 

A:FDRE(q_reg[2])

When does the clock edge that launches the signal arrive at the launch flip flop? 
A:The clock arrives at 2.140ns.

What is the capture point (end) of the path? When does the clock arrive there? Does this make sense knowing what you know about the path from the input pin to the flip flops? 

A:The capture point is FDRE(q_reg[13]). The clock arrives there at 5.530ns. 

When is the signal required to be at the endpoint? 

A:At 11.958ns.

If you do the arithmetic, how do the various numbers work out? Do the values above take into account clock skew or not?

A:Subtracting the difference of the data arriving at the capture flip flop(5.530) from the required capture point flip flop(11.958) which gives us the slack of 6.428ns. Yes, it takes the clock skew into account in the required time to get to the capture flip flop.

What are the various delays making up the critical path? Which ones dominate? Which ones are smaller than you might have anticipated? Any surprises here?

A:The first flip flop's delay is 1.134ns, LUT4's delay is .965ns, LUT5's delay is .327ns, the first CARRY4's delay is .401ns, the second CARRY4's delay is .114ns, the third CARRY4's delay is .114ns, the last CARRY$'s delay is .334ns. The first flip flop and first LUT dominate, adding the largest delay. The CARRY4 delays were smaller than we thought they would be. We were surprised at the difference in delays between the two LUTs as well as the four CARRY4s.

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
