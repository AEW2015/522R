---
title: 'Leveling The Playing Field'
taxonomy:
    category: docs
---

### Leveling The Playing Field


Everyone coming into this class comes with slightly different preparation. Two students had a previous version of 620 and so are SystemVerilog and testbench experts. Four students have had 320 and so have some background with VHDL in addition to the Verilog they learned in 220. One student has had 323 and so learned SystemVerilog as an undergrad. And, some students are familiar with ISE while others know Vivado.

The goal of this assignment is to give everyone a chance to come up to speed on the HDL's they are either rusty or unfamiliar with.

1. Run the Vivado tutorial here to ensure you are up to speed on Vivado (the needed .zip file can be found here). Thanks to our friends at Univ of Toronto for the tutorial, which was based on previous Xilinx materials. While the Vivado version we are using this semester is close to that discussed in the tutorial, there may be slight differences so be aware of that and be creative as you work through it.
  * The tutorial is specific to the board in the Digital Lab and so, unless you have the same board at your desk, you will at least have to go into the lab to do your download (or, you may use an FPGA board you may have access to on your desk if you like, but talk to me about it first).
  * You may use any version of Vivado you would like on any computer. Just be aware that I strongly recommend you use the version that is being used in the Digital Lab (2019.1). It is a given that every time a new version is released it fixes many bugs in the old version but inevitably introduces new bugs. You really do not want to be struggling with different versions of Vivado as you move between systems.
  * Notes on tutorial (I was running 2019.1 on an Ubuntu Linux machine):
	  	  * Step 3.1.3: The “Project Summary” can be found under the 'Window' menu item.
		  * Section 7:
				  * Did not source settings64.csh (not in tutorial directory).
				  * Also, did not run with -mode batch. Rather, ran with -mode tcl and then executed “source tutorial_tcl_with_sim.tcl” from within tcl command line prompt.
2. Design a UART transmitter and receiver using Vivado and either Verilog or SystemVerilog.
  * Carefully verify its correctness through simulation using a testbench you also created using either Verilog or SystemVerilog. In your writeup for this step show how you went about verifying it and convince the reader that it is correct. Make your design work for a BAUD rate of 19200 have it send 8 bits of data plus an odd parity bit. The ECEn 220 wiki (http://ecen220wiki.groups.et.byu.net/dokuwiki/doku.php?id=start) contains a lab on a UART transmitter that you may follow to help you figure out how to set up your test system using putty.
3. Turn your results in by:
  * Creating a webpage (web page, wiki, whatever) where you place your results (PDF of writeup + video showing demo)
  * Send Prof Nelson the path to your work so he can go in and view and evaluate it.
  * The criteria which will be used to evaluate your work include:
  	 	* Have you convinced the reader that you have fully verified your designs in simulation?
    	* How well structured and documented is your code (including your simulation testbench)?
3. Synthesize your UART and download to the FPGA board in the digital lab. Demonstrate it operating correctly. Turn in a video you have made of you demonstrating its correct operation. For transmission, use switches and a button to send to a PC and use a terminal emulator such as PUTTY to display the received characters on the screen. For reception, send from the terminal emulator to your FPGA board and show the received ASCII on LED's or on the 7-segment display. You are free to use any pre-existing blocks you may have previously designed to debounce buttons or to drive the 7-segment display.
5. Alternatively, if you have experience doing so, you may use a soft-core Microblaze processor to help you exercise your hardware design. There is a Microblaze tutorial here to help you.
6. If you did the step above in SystemVerilog you are done. If not, then:
    * Modify your design to use SystemVerilog. Use at least the following features anywhere it makes sense to do so.
    	* packages - can be used to hold type declarations, function declarations, and other things that will be included and used. Using this feature is not required but use if it makes sense for what you are doing.
    	* typedefs - allows you to define new data types and then use them. These are crucially important when defining state machines.
    	* the logic type - removes the need to differentiate between wires and reg.
    	* always_ff and always_comb - makes your intent crystal clear when writing an always block (in Verilog you could write always blocks incorrectly that had combinational and sequential characteristics - not something you probably intended). Note that
    	* unique case - tells the tools that the choices in a case statement are non-overlapping and can be evaluated in parallel - probably what you really meant if you were coding up a MUX.
   	 	* .* - when wiring up ports in a module instantiation, this tells the tool to wire up all ports to a signal with the same name. Saves lots of typing (and sources of errors). Can be mixed with regular dot notation for wiring up ports.
   		* enums - great for definining symbolic state names and op code names
   * Re-use the testbench from above to simulate your new design and verify it.
   * Implement it on the board as above using the identical setup.
7. Turn your results in by:
  * Sending Prof Nelson the path to your work so he can go in and view and evaluate it.
  * The criteria which will be used to evaluate your work include:
    	* Does it still simulate correctly (like before)?
    	* Did you get it work in hardware as evidenced by the videos you produced?
    	* Did you use the appropriate SystemVerilog features in your second version?

Parts of what you need to know for the UART design is in the recent 220 textbook. Specifically, it contains chapters on debouncing buttons and on the design of a UART. It also contains a good overview of SystemVerilog which should contain everything you need to know for this class. There is a version of the textbook in the digital lab chained to the TA table you may refer to. Or, you may find it on Amazon for cheap (just be sure to get the one with “v2.0” in the title).

Also, information on how to hook up the FPGA board to a PC and run a terminal emulator (among other things) is available on the ECEn 220 Lab web pages. In fact, some of the earlier tutorials will be great references to help you remember how to constrain top level ports to physical I/O pins (and even provide a full constraints file for the board we are using).

Finally, note that the time that assignments are due will always be 10AM.
