---
title: Clocks
taxonomy:
    category:
        - docs
visible: true
---

## Basic Clock Generation, On-chip Feedback 

Clock block diagram

![Clock block diagram](clkbd.png)

This block diagram matches the PLLE2_ADV in Figure 3-5 in ug472.

The Input clk was multiplied by 41 and divided by 5 to get a VCO of 820 MHz.
This VCO was divided by 82 to get an output clk of 10 MHz.


The output clks can be determined by the generics  for the PLL.
The VCO must be between 800 MHz to 1600 MHz.
The VCO is generated from an input clk by applying the CLKFBOUT_MULT and the DIVCLK_DIVIDE.
This one VCO feed the rest of the output clks by applying this CLKOUT*_DIVIDE  value per output clk.

CLKOUT0 = ((CLKIN * CLKFBOUT_MULT)/DIVCLK_DIVIDE)/CLKOUT0_DIVIDE

CLKOUT1 = ((CLKIN * CLKFBOUT_MULT)/DIVCLK_DIVIDE)/CLKOUT1_DIVIDE

CLKOUT2 = ((CLKIN * CLKFBOUT_MULT)/DIVCLK_DIVIDE)/CLKOUT2_DIVIDE

CLKOUT3 = ((CLKIN * CLKFBOUT_MULT)/DIVCLK_DIVIDE)/CLKOUT3_DIVIDE

CLKOUT4 = ((CLKIN * CLKFBOUT_MULT)/DIVCLK_DIVIDE)/CLKOUT4_DIVIDE

CLKOUT5 = ((CLKIN * CLKFBOUT_MULT)/DIVCLK_DIVIDE)/CLKOUT5_DIVIDE


For the MCM, the CLKFBOUT_MULT can 2 to 64 or 2.000 to 64.000 in increments of 0.125.
Assuming they are using fixed point.
The PLL can only do integers from 2 to 64.


The MCMM DIVCLK_DIVIDE is 1 to 106 and PLL DIVCLK_DIVIDE is 1 to 56.

CLKOUT*_DIVIDE go to 1 to 128.

The MCMM does have a CLKOUT0_DIVIDE_F can 2 to 128 or 2.000 to 64.000 in increments of 0.125.

All the clocks are based on one VCO and any combination of outputs may not be possible.
The clocking wizard will try to give the best solution if possible or not work at all.

Such combinations as a 500 Mhz input clk, and a 600 Mhz and 550 Mhz output clks will result in two 600 Mhz Output clks.
Or a 500 Mhz input clk, and a 600 Mhz and 7 Mhz output clks will be impossible and the tools will not allow it.

The first clock in the clocking wizard get proirty in generating the VCO.
All other clocks are generated from that VCO.
The first clock should be the most important or hardest to get.
Or just rotating the clocks in the first position will get you different varitions of acutal output clk speeds.

![Clock Tables](clktab.png)


## Basic Clock Generation, On-chip Feedback, Fixed Phase Shifting 

The Phase is dependent on the give frequency of the VCO and the main clock divide chosen.

This is confirmed by ug472.
CLKOUT[0:6]_PHASE is a real number between –360.000 to 360.000 in increments of 1/56 the FVCO and/or increments depending on CLKOUT_DIVIDE.
Each clock out can have its own phase shift.

## Clock Demo 

<details><summary>my_pll.vhd</summary><p><pre><code class="vhdl">library IEEE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity my_pll is
  port (
    clk_out1 : out STD_LOGIC;
    clk_out2 : out STD_LOGIC;
    clk_out3 : out STD_LOGIC;
    clk_out4 : out STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );
end my_pll;

architecture STRUCTURE of my_pll is
  signal clk_in1_clk_wiz_0 : STD_LOGIC;
  signal clk_out1_clk_wiz_0 : STD_LOGIC;
  signal clk_out2_clk_wiz_0 : STD_LOGIC;
  signal clk_out3_clk_wiz_0 : STD_LOGIC;
  signal clk_out4_clk_wiz_0 : STD_LOGIC;
  signal clkfbout_buf_clk_wiz_0 : STD_LOGIC;
  signal clkfbout_clk_wiz_0 : STD_LOGIC;
begin
clkf_buf: unisim.vcomponents.BUFG
     port map (
      I =&gt; clkfbout_clk_wiz_0,
      O =&gt; clkfbout_buf_clk_wiz_0
    );
clkin1_ibufg: unisim.vcomponents.IBUF
    generic map(
      IOSTANDARD =&gt; "DEFAULT"
    )
        port map (
      I =&gt; clk_in1,
      O =&gt; clk_in1_clk_wiz_0
    );
clkout1_buf: unisim.vcomponents.BUFG
     port map (
      I =&gt; clk_out1_clk_wiz_0,
      O =&gt; clk_out1
    );
clkout2_buf: unisim.vcomponents.BUFG
     port map (
      I =&gt; clk_out2_clk_wiz_0,
      O =&gt; clk_out2
    );
clkout3_buf: unisim.vcomponents.BUFG
     port map (
      I =&gt; clk_out3_clk_wiz_0,
      O =&gt; clk_out3
    );
clkout4_buf: unisim.vcomponents.BUFG
     port map (
      I =&gt; clk_out4_clk_wiz_0,
      O =&gt; clk_out4
    );
plle2_adv_inst: unisim.vcomponents.PLLE2_ADV
    generic map(
      BANDWIDTH =&gt; "OPTIMIZED",
      CLKFBOUT_MULT =&gt; 9,
      CLKFBOUT_PHASE =&gt; 0.000000,
      CLKIN1_PERIOD =&gt; 10.000000,
      CLKIN2_PERIOD =&gt; 0.000000,
      CLKOUT0_DIVIDE =&gt; 90,
      CLKOUT0_DUTY_CYCLE =&gt; 0.500000,
      CLKOUT0_PHASE =&gt; 0.000000,
      CLKOUT1_DIVIDE =&gt; 90,
      CLKOUT1_DUTY_CYCLE =&gt; 0.500000,
      CLKOUT1_PHASE =&gt; 90.000000,
      CLKOUT2_DIVIDE =&gt; 3,
      CLKOUT2_DUTY_CYCLE =&gt; 0.500000,
      CLKOUT2_PHASE =&gt; 0.000000,
      CLKOUT3_DIVIDE =&gt; 12,
      CLKOUT3_DUTY_CYCLE =&gt; 0.500000,
      CLKOUT3_PHASE =&gt; 0.000000,
      CLKOUT4_DIVIDE =&gt; 1,
      CLKOUT4_DUTY_CYCLE =&gt; 0.500000,
      CLKOUT4_PHASE =&gt; 0.000000,
      CLKOUT5_DIVIDE =&gt; 1,
      CLKOUT5_DUTY_CYCLE =&gt; 0.500000,
      CLKOUT5_PHASE =&gt; 0.000000,
      COMPENSATION =&gt; "ZHOLD",
      DIVCLK_DIVIDE =&gt; 1,
      IS_CLKINSEL_INVERTED =&gt; '0',
      IS_PWRDWN_INVERTED =&gt; '0',
      IS_RST_INVERTED =&gt; '0',
      REF_JITTER1 =&gt; 0.010000,
      REF_JITTER2 =&gt; 0.010000,
      STARTUP_WAIT =&gt; "FALSE"
    )
        port map (
      CLKFBIN =&gt; clkfbout_buf_clk_wiz_0,
      CLKFBOUT =&gt; clkfbout_clk_wiz_0,
      CLKIN1 =&gt; clk_in1_clk_wiz_0,
      CLKIN2 =&gt; '0',
      CLKINSEL =&gt; '1',
      CLKOUT0 =&gt; clk_out1_clk_wiz_0,
      CLKOUT1 =&gt; clk_out2_clk_wiz_0,
      CLKOUT2 =&gt; clk_out3_clk_wiz_0,
      CLKOUT3 =&gt; clk_out4_clk_wiz_0,
      CLKOUT4 =&gt; open,
      CLKOUT5 =&gt; open,
      DADDR(6 downto 0) =&gt; B"0000000",
      DCLK =&gt; '0',
      DEN =&gt; '0',
      DI(15 downto 0) =&gt; B"0000000000000000",
      DO(15 downto 0) =&gt; open(15 downto 0),
      DRDY =&gt; open,
      DWE =&gt; '0',
      LOCKED =&gt; locked,
      PWRDWN =&gt; '0',
      RST =&gt; '0'
    );
end STRUCTURE;
</code></pre></p></details>

![My PLL Block](my_pll_bd.png)


![bram video](user://media/clk000.mp4?resize=620,480))